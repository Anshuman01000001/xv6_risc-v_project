#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// ----------------------------------------------------------------
//  matrix  –  deterministic CPU workload for thermal scheduler tests
//
//  Each child multiplies two NxN matrices a fixed number of times.
//  The work is purely arithmetic (no uptime polling), so every run
//  produces identical per-process CPU load regardless of timer jitter.
// ----------------------------------------------------------------

#define NCHILD   5      // number of child processes
#define N       20      // matrix dimension  (NxN)
#define ROUNDS   3      // number of multiply passes per child

// Statically-allocated matrices (shared copy-on-write after fork,
// but each child gets its own copy once it writes).
static int A[N][N];
static int B[N][N];
static int C[N][N];

// Fill a matrix with a simple deterministic pattern.
static void
mat_init(int m[N][N], int seed)
{
  for(int i = 0; i < N; i++)
    for(int j = 0; j < N; j++)
      m[i][j] = (seed + i * N + j) % 97;   // small primes keep values bounded
}

// C = A * B   (standard O(n^3) multiply – intentionally heavy)
static void
mat_mul(void)
{
  for(int i = 0; i < N; i++)
    for(int j = 0; j < N; j++){
      int sum = 0;
      for(int k = 0; k < N; k++)
        sum += A[i][k] * B[k][j];
      C[i][j] = sum;
    }
}

// Return a simple checksum so the compiler cannot optimise the
// multiply away entirely.
static int
mat_checksum(void)
{
  int s = 0;
  for(int i = 0; i < N; i++)
    for(int j = 0; j < N; j++)
      s += C[i][j];
  return s;
}

// Each child: heavier children get more rounds (child_id 1 = heaviest).
static void
child_work(int child_id)
{
  int extra = NCHILD - child_id + 1;   // child 1→5 rounds, child 5→1 round
  int total = ROUNDS + extra;

  mat_init(A, child_id);
  mat_init(B, child_id + 37);

  int chk = 0;
  for(int r = 0; r < total; r++){
    mat_mul();
    chk += mat_checksum();
    // Feed A with previous result to chain dependencies
    for(int i = 0; i < N; i++)
      for(int j = 0; j < N; j++)
        A[i][j] = C[i][j] % 97;
  }

  printf("  Child %d (PID %d): %d rounds, checksum %d\n",
         child_id, getpid(), total, chk);
}

int
main(void)
{
  printf("matrix: forking %d children (N=%d)\n", NCHILD, N);

  for(int i = 0; i < NCHILD; i++){
    int pid = fork();
    if(pid < 0){
      printf("matrix: fork failed for child %d\n", i + 1);
      exit(1);
    }
    if(pid == 0){
      child_work(i + 1);
      exit(0);
    }
    printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
  }

  // Wait for all children
  for(int i = 0; i < NCHILD; i++)
    wait(0);

  printf("matrix: all children finished\n");
  exit(0);
}
