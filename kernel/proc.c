#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
//----------------
// ---- Thermal thresholds (CPU temperature) ----
#define COOL_TEMP         30
#define WARM_TEMP         60
#define HOT_TEMP          80
#define THROTTLE_TEMP     90   // force idle cooling above this

// ---- Per-process heat tracking constants ----
#define HEAT_INCREMENT    10   // heat gained per scheduling quantum
#define HEAT_DECAY         2   // heat lost per idle scheduler tick
#define MAX_HEAT         100   // cap to avoid overflow
#define HEAT_COOL_THRESH  30   // "cool" process threshold
#define HEAT_WARM_THRESH  60   // "warm" process threshold
#define THERMAL_LOG_INTERVAL 10 // print thermal log every N rounds

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

int cpu_temp = 25; // starting temp

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// Update CPU temperature dynamically.
// process_heat > 0  →  a process with that heat level is running (heating)
// process_heat == 0 →  CPU is idle (cooling)
void update_cpu_temp(int process_heat) {
  if (process_heat > 0) {
    // Heating proportional to process heat: hotter processes raise temp faster
    int heat_factor = 1 + process_heat / 30;  // 1‒4
    cpu_temp += heat_factor;
  } else {
    // Cooling when idle
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
  }

  // Clamp to [20, 100]
  if(cpu_temp > 100)
    cpu_temp = 100;
  else if(cpu_temp < 20)
    cpu_temp = 20;
}


// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  p->waiting_tick = 0;
  p->heat = 0;              // new process starts cool

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->heat = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if(sz + n > TRAPFRAME) {
      return -1;
    }
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
kfork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
kexit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
kwait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          // printf("schedtests: pid=%d waiting_tick=%d\n", pp->pid, pp->waiting_tick);
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  struct proc *chosen = 0;
  static int sched_round = 0;   // for periodic thermal logging

  c->proc = 0;
  for(;;){
    // Enable interrupts briefly to avoid deadlock if all procs wait.
    intr_on();
    intr_off();

    chosen = 0;
    sched_round++;

    // =========================================================
    //  STEP 1 – Heat decay for every idle (non‑RUNNING) process
    // =========================================================
    for(p = proc; p < &proc[NPROC]; p++){
      acquire(&p->lock);
      if(p->state == RUNNABLE || p->state == SLEEPING){
        if(p->heat > 0){
          p->heat -= HEAT_DECAY;
          if(p->heat < 0) p->heat = 0;
        }
      }
      release(&p->lock);
    }

    // =========================================================
    //  STEP 2 – Active throttle: force idle when CPU is too hot
    // =========================================================
    if(cpu_temp >= THROTTLE_TEMP){
      if(sched_round % THERMAL_LOG_INTERVAL == 0)
        printf("  [COOLING] Temp: %d/%d  | Throttling -- idle cycle to cool down\n", cpu_temp, THROTTLE_TEMP);
      update_cpu_temp(0);  // idle cooling
      asm volatile("wfi");
      continue;            // restart scheduler loop without running anyone
    }

    // =========================================================
    //  STEP 3 – Thermal‑aware process selection
    // =========================================================

    // --- Pass A: among schedtest children, pick lowest PID that
    //             passes the thermal gate.
    for(p = proc; p < &proc[NPROC]; p++){
      acquire(&p->lock);
      if(p->state == RUNNABLE){
        // ---- thermal gate ----
        if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
          release(&p->lock);
          continue;   // CPU hot → skip hot processes
        }
        if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
          release(&p->lock);
          continue;   // CPU warm → skip very hot processes
        }
        // ---- schedtest priority: lowest PID ----
        if(p->parent != 0 &&
           strncmp(p->parent->name, "schedtest", 9) == 0){
          if(chosen == 0 || p->pid < chosen->pid)
            chosen = p;
        }
      }
      release(&p->lock);
    }

    // --- Pass B: if no schedtest child found, pick the RUNNABLE
    //             process with the *lowest heat* that passes the
    //             thermal gate (thermal‑aware, prefer cooler procs).
    if(chosen == 0){
      int lowest_heat = MAX_HEAT + 1;
      for(p = proc; p < &proc[NPROC]; p++){
        acquire(&p->lock);
        if(p->state == RUNNABLE){
          // thermal gate
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
            release(&p->lock);
            continue;
          }
          if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
            release(&p->lock);
            continue;
          }
          if(p->heat < lowest_heat){
            chosen = p;
            lowest_heat = p->heat;
          }
        }
        release(&p->lock);
      }
    }

    // --- Pass C: anti‑starvation fallback – if every RUNNABLE
    //             process was throttled, pick *any* RUNNABLE.
    if(chosen == 0){
      for(p = proc; p < &proc[NPROC]; p++){
        acquire(&p->lock);
        if(p->state == RUNNABLE){
          chosen = p;
          release(&p->lock);
          break;
        }
        release(&p->lock);
      }
    }

    // =========================================================
    //  STEP 4 – Bookkeeping for non‑chosen RUNNABLE procs
    // =========================================================
    for(p = proc; p < &proc[NPROC]; p++){
      acquire(&p->lock);
      if(p->state == RUNNABLE && p != chosen){
        p->waiting_tick++;
      }
      release(&p->lock);
    }

    // =========================================================
    //  STEP 5 – Context‑switch (or idle)
    // =========================================================
    if(chosen == 0){
      update_cpu_temp(0);  // idle cooling
      asm volatile("wfi");
    } else {
      acquire(&chosen->lock);
      if(chosen->state == RUNNABLE){
        // --- Periodic thermal log ---
        if(sched_round % THERMAL_LOG_INTERVAL == 0){
          char *zone = "COOL";
          if(cpu_temp >= 80) zone = "HOT ";
          else if(cpu_temp >= 60) zone = "WARM";
          printf("  [THERMAL] Temp: %d [%s] | PID: %d | Heat: %d | %s\n",
                 cpu_temp, zone, chosen->pid, chosen->heat, chosen->name);
        }

        chosen->state = RUNNING;
        c->proc = chosen;

        // Increment process heat proportional to running
        chosen->heat += HEAT_INCREMENT;
        if(chosen->heat > MAX_HEAT)
          chosen->heat = MAX_HEAT;

        // CPU temp rises based on the running process's heat
        update_cpu_temp(chosen->heat);

        swtch(&c->context, &chosen->context);

        c->proc = 0;
      }
      release(&chosen->lock);
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched RUNNING");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();

  // Still holding p->lock from scheduler.
  release(&p->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    if (p->trapframe->a0 == -1) {
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
  uint64 satp = MAKE_SATP(p->pagetable);
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    printf("\n");
  }
}


int
kps(char *arguments)
{
  struct proc *p;

  static char *states[] = {
  [UNUSED]    "UNUSED",
  [USED]      "USED",
  [SLEEPING]  "SLEEPING",
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
      }
    }
    printf("\n");
  }else if(strncmp(arguments, "-l", 2)==0){
    printf("PID\tSTATE\t\tNAME\n");
    printf("-------------------------------\n");
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
      }
    }
  }else if(strncmp(arguments, "-t", 2)==0){
    // Thermal / heat monitoring view
    printf("===== Thermal Monitor =====\n");
    printf("CPU Temperature: %d / 100", cpu_temp);
    if(cpu_temp >= 80)
      printf("  [HOT]\n");
    else if(cpu_temp >= 60)
      printf("  [WARM]\n");
    else
      printf("  [COOL]\n");
    printf("\nPID\tSTATE\t\tHEAT\tNAME\n");
    printf("---------------------------------------\n");
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
      }
    }
  }else{
    printf("Usage: ps [-o | -l | -t]\n");
  }

  return 0;

}