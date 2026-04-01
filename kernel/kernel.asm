
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	83813103          	ld	sp,-1992(sp) # 8000b838 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd98d7>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	209020ef          	jal	80002b22 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	00013517          	auipc	a0,0x13
    80000196:	70e50513          	addi	a0,a0,1806 # 800138a0 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00013497          	auipc	s1,0x13
    800001a2:	70248493          	addi	s1,s1,1794 # 800138a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00013917          	auipc	s2,0x13
    800001aa:	79290913          	addi	s2,s2,1938 # 80013938 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	0f9010ef          	jal	80001ab6 <myproc>
    800001c2:	7f8020ef          	jal	800029ba <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	5b2020ef          	jal	8000277e <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00013717          	auipc	a4,0x13
    800001e2:	6c270713          	addi	a4,a4,1730 # 800138a0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	0c9020ef          	jal	80002ad8 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	00013517          	auipc	a0,0x13
    8000022c:	67850513          	addi	a0,a0,1656 # 800138a0 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	00013717          	auipc	a4,0x13
    80000252:	6ef72523          	sw	a5,1770(a4) # 80013938 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00013517          	auipc	a0,0x13
    80000268:	63c50513          	addi	a0,a0,1596 # 800138a0 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00013517          	auipc	a0,0x13
    800002bc:	5e850513          	addi	a0,a0,1512 # 800138a0 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	093020ef          	jal	80002b6c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00013517          	auipc	a0,0x13
    800002e2:	5c250513          	addi	a0,a0,1474 # 800138a0 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	00013717          	auipc	a4,0x13
    80000300:	5a470713          	addi	a4,a4,1444 # 800138a0 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	00013717          	auipc	a4,0x13
    80000326:	57e70713          	addi	a4,a4,1406 # 800138a0 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	00013717          	auipc	a4,0x13
    80000350:	5ec72703          	lw	a4,1516(a4) # 80013938 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00013717          	auipc	a4,0x13
    80000366:	53e70713          	addi	a4,a4,1342 # 800138a0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00013497          	auipc	s1,0x13
    80000376:	52e48493          	addi	s1,s1,1326 # 800138a0 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	00013717          	auipc	a4,0x13
    800003b8:	4ec70713          	addi	a4,a4,1260 # 800138a0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00013717          	auipc	a4,0x13
    800003ce:	56f72b23          	sw	a5,1398(a4) # 80013940 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	00013797          	auipc	a5,0x13
    800003ec:	4b878793          	addi	a5,a5,1208 # 800138a0 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00013797          	auipc	a5,0x13
    8000040e:	52c7a923          	sw	a2,1330(a5) # 8001393c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00013517          	auipc	a0,0x13
    80000416:	52650513          	addi	a0,a0,1318 # 80013938 <cons+0x98>
    8000041a:	3b0020ef          	jal	800027ca <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00008597          	auipc	a1,0x8
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80008000 <etext>
    80000430:	00013517          	auipc	a0,0x13
    80000434:	47050513          	addi	a0,a0,1136 # 800138a0 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00024797          	auipc	a5,0x24
    80000444:	95078793          	addi	a5,a5,-1712 # 80023d90 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00008817          	auipc	a6,0x8
    80000482:	71a80813          	addi	a6,a6,1818 # 80008b98 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000b797          	auipc	a5,0xb
    8000051c:	33c7a783          	lw	a5,828(a5) # 8000b854 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	00013517          	auipc	a0,0x13
    80000562:	3ea50513          	addi	a0,a0,1002 # 80013948 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00008c97          	auipc	s9,0x8
    800006d6:	4c6c8c93          	addi	s9,s9,1222 # 80008b98 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00008a17          	auipc	s4,0x8
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80008008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	0000b797          	auipc	a5,0xb
    8000075e:	0fa7a783          	lw	a5,250(a5) # 8000b854 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	00013517          	auipc	a0,0x13
    80000788:	1c450513          	addi	a0,a0,452 # 80013948 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	0000b797          	auipc	a5,0xb
    80000838:	0297a023          	sw	s1,32(a5) # 8000b854 <panicking>
  printf("panic: ");
    8000083c:	00007517          	auipc	a0,0x7
    80000840:	7dc50513          	addi	a0,a0,2012 # 80008018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00007517          	auipc	a0,0x7
    8000084e:	7d650513          	addi	a0,a0,2006 # 80008020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000b797          	auipc	a5,0xb
    8000085a:	fe97ad23          	sw	s1,-6(a5) # 8000b850 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00007597          	auipc	a1,0x7
    8000086c:	7c058593          	addi	a1,a1,1984 # 80008028 <etext+0x28>
    80000870:	00013517          	auipc	a0,0x13
    80000874:	0d850513          	addi	a0,a0,216 # 80013948 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00007597          	auipc	a1,0x7
    800008c2:	77258593          	addi	a1,a1,1906 # 80008030 <etext+0x30>
    800008c6:	00013517          	auipc	a0,0x13
    800008ca:	09a50513          	addi	a0,a0,154 # 80013960 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	00013517          	auipc	a0,0x13
    800008ee:	07650513          	addi	a0,a0,118 # 80013960 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	0000b497          	auipc	s1,0xb
    8000090c:	f5448493          	addi	s1,s1,-172 # 8000b85c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00013997          	auipc	s3,0x13
    80000914:	05098993          	addi	s3,s3,80 # 80013960 <tx_lock>
    80000918:	0000b917          	auipc	s2,0xb
    8000091c:	f4090913          	addi	s2,s2,-192 # 8000b858 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	653010ef          	jal	8000277e <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	00013517          	auipc	a0,0x13
    8000095a:	00a50513          	addi	a0,a0,10 # 80013960 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	0000b797          	auipc	a5,0xb
    8000097e:	eda7a783          	lw	a5,-294(a5) # 8000b854 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000b797          	auipc	a5,0xb
    80000988:	ecc7a783          	lw	a5,-308(a5) # 8000b850 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	0000b797          	auipc	a5,0xb
    800009ae:	eaa7a783          	lw	a5,-342(a5) # 8000b854 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	00013517          	auipc	a0,0x13
    80000a0a:	f5a50513          	addi	a0,a0,-166 # 80013960 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	00013517          	auipc	a0,0x13
    80000a24:	f4050513          	addi	a0,a0,-192 # 80013960 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	0000b797          	auipc	a5,0xb
    80000a40:	e207a023          	sw	zero,-480(a5) # 8000b85c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000b517          	auipc	a0,0xb
    80000a48:	e1450513          	addi	a0,a0,-492 # 8000b858 <tx_chan>
    80000a4c:	57f010ef          	jal	800027ca <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00024797          	auipc	a5,0x24
    80000a6c:	4c078793          	addi	a5,a5,1216 # 80024f28 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	00013917          	auipc	s2,0x13
    80000a96:	ee690913          	addi	s2,s2,-282 # 80013978 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00007517          	auipc	a0,0x7
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80008038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00007597          	auipc	a1,0x7
    80000b1c:	52858593          	addi	a1,a1,1320 # 80008040 <etext+0x40>
    80000b20:	00013517          	auipc	a0,0x13
    80000b24:	e5850513          	addi	a0,a0,-424 # 80013978 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00024517          	auipc	a0,0x24
    80000b34:	3f850513          	addi	a0,a0,1016 # 80024f28 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	00013517          	auipc	a0,0x13
    80000b52:	e2a50513          	addi	a0,a0,-470 # 80013978 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00013497          	auipc	s1,0x13
    80000b5e:	e364b483          	ld	s1,-458(s1) # 80013990 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00013717          	auipc	a4,0x13
    80000b6a:	e2f73523          	sd	a5,-470(a4) # 80013990 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00013517          	auipc	a0,0x13
    80000b72:	e0a50513          	addi	a0,a0,-502 # 80013978 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	00013517          	auipc	a0,0x13
    80000b94:	de850513          	addi	a0,a0,-536 # 80013978 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	6c9000ef          	jal	80001a96 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	699000ef          	jal	80001a96 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	691000ef          	jal	80001a96 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	67d000ef          	jal	80001a96 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	647000ef          	jal	80001a96 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00007517          	auipc	a0,0x7
    80000c64:	3e850513          	addi	a0,a0,1000 # 80008048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	623000ef          	jal	80001a96 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80008050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00007517          	auipc	a0,0x7
    80000cb4:	3b850513          	addi	a0,a0,952 # 80008068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	38450513          	addi	a0,a0,900 # 80008070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	3cd000ef          	jal	80001a82 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	0000b717          	auipc	a4,0xb
    80000ebe:	9a670713          	addi	a4,a4,-1626 # 8000b860 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	3b5000ef          	jal	80001a82 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00007517          	auipc	a0,0x7
    80000ed8:	1c450513          	addi	a0,a0,452 # 80008098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	79f010ef          	jal	80002e82 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	050050ef          	jal	80005f38 <plicinithart>
  }

  scheduler();        
    80000eec:	04e010ef          	jal	80001f3a <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00007517          	auipc	a0,0x7
    80000efc:	18050513          	addi	a0,a0,384 # 80008078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	17c50513          	addi	a0,a0,380 # 80008080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00007517          	auipc	a0,0x7
    80000f14:	16850513          	addi	a0,a0,360 # 80008078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	2a5000ef          	jal	800019cc <procinit>
    trapinit();      // trap vectors
    80000f2c:	733010ef          	jal	80002e5e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	753010ef          	jal	80002e82 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	7eb040ef          	jal	80005f1e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	000050ef          	jal	80005f38 <plicinithart>
    binit();         // buffer cache
    80000f3c:	62a020ef          	jal	80003566 <binit>
    iinit();         // inode table
    80000f40:	37d020ef          	jal	80003abc <iinit>
    fileinit();      // file table
    80000f44:	2a9030ef          	jal	800049ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	0e0050ef          	jal	80006028 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	643000ef          	jal	80001d8e <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	0000b717          	auipc	a4,0xb
    80000f5a:	90f72523          	sw	a5,-1782(a4) # 8000b860 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	0000b797          	auipc	a5,0xb
    80000f70:	8fc7b783          	ld	a5,-1796(a5) # 8000b868 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	0be50513          	addi	a0,a0,190 # 800080b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00007517          	auipc	a0,0x7
    800010ce:	fee50513          	addi	a0,a0,-18 # 800080b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00007517          	auipc	a0,0x7
    800010da:	00250513          	addi	a0,a0,2 # 800080d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00007517          	auipc	a0,0x7
    800010e6:	01650513          	addi	a0,a0,22 # 800080f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00007517          	auipc	a0,0x7
    800010f2:	01a50513          	addi	a0,a0,26 # 80008108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	fe650513          	addi	a0,a0,-26 # 80008118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80007697          	auipc	a3,0x80007
    8000118e:	e7668693          	addi	a3,a3,-394 # 8000 <_entry-0x7fff8000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00007697          	auipc	a3,0x7
    800011a4:	e6068693          	addi	a3,a3,-416 # 80008000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00007617          	auipc	a2,0x7
    800011b4:	e5060613          	addi	a2,a2,-432 # 80008000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00006617          	auipc	a2,0x6
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80007000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	74c000ef          	jal	80001928 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	0000a797          	auipc	a5,0xa
    800011fc:	66a7b823          	sd	a0,1648(a5) # 8000b868 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00007517          	auipc	a0,0x7
    8000126c:	eb850513          	addi	a0,a0,-328 # 80008120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00007517          	auipc	a0,0x7
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80008138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80008148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	4d6000ef          	jal	80001ab6 <myproc>
  if (va >= p->sz)
    800015e4:	693c                	ld	a5,80(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	6ca8                	ld	a0,88(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <tm_find>:
static int   tm_cooling_cycles = 0;
static int   tm_had_children = 0; // 1 if we saw schedtest children

static struct thermal_metrics*
tm_find(int pid)
{
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  // find existing or allocate a new slot
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017a8:	00012617          	auipc	a2,0x12
    800017ac:	1f060613          	addi	a2,a2,496 # 80013998 <tm>
{
    800017b0:	8732                	mv	a4,a2
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017b2:	4781                	li	a5,0
    800017b4:	45c1                	li	a1,16
    if(tm[i].pid == pid) return &tm[i];
    800017b6:	4314                	lw	a3,0(a4)
    800017b8:	02a68063          	beq	a3,a0,800017d8 <tm_find+0x38>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017bc:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda0d9>
    800017be:	0761                	addi	a4,a4,24
    800017c0:	feb79be3          	bne	a5,a1,800017b6 <tm_find+0x16>
  }
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017c4:	4781                	li	a5,0
    800017c6:	46c1                	li	a3,16
    if(tm[i].pid == 0){
    800017c8:	4218                	lw	a4,0(a2)
    800017ca:	c705                	beqz	a4,800017f2 <tm_find+0x52>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017cc:	2785                	addiw	a5,a5,1
    800017ce:	0661                	addi	a2,a2,24
    800017d0:	fed79ce3          	bne	a5,a3,800017c8 <tm_find+0x28>
      tm[i].heat_min = MAX_HEAT + 1;
      tm[i].heat_max = -1;
      return &tm[i];
    }
  }
  return 0; // table full
    800017d4:	4501                	li	a0,0
    800017d6:	a811                	j	800017ea <tm_find+0x4a>
    if(tm[i].pid == pid) return &tm[i];
    800017d8:	00179713          	slli	a4,a5,0x1
    800017dc:	97ba                	add	a5,a5,a4
    800017de:	078e                	slli	a5,a5,0x3
    800017e0:	00012517          	auipc	a0,0x12
    800017e4:	1b850513          	addi	a0,a0,440 # 80013998 <tm>
    800017e8:	953e                	add	a0,a0,a5
}
    800017ea:	60a2                	ld	ra,8(sp)
    800017ec:	6402                	ld	s0,0(sp)
    800017ee:	0141                	addi	sp,sp,16
    800017f0:	8082                	ret
      tm[i].pid = pid;
    800017f2:	00012717          	auipc	a4,0x12
    800017f6:	1a670713          	addi	a4,a4,422 # 80013998 <tm>
    800017fa:	00179613          	slli	a2,a5,0x1
    800017fe:	00f606b3          	add	a3,a2,a5
    80001802:	068e                	slli	a3,a3,0x3
    80001804:	96ba                	add	a3,a3,a4
    80001806:	c288                	sw	a0,0(a3)
      tm[i].heat_min = MAX_HEAT + 1;
    80001808:	06500593          	li	a1,101
    8000180c:	ca8c                	sw	a1,16(a3)
      tm[i].heat_max = -1;
    8000180e:	55fd                	li	a1,-1
    80001810:	cacc                	sw	a1,20(a3)
      return &tm[i];
    80001812:	8536                	mv	a0,a3
    80001814:	bfd9                	j	800017ea <tm_find+0x4a>

0000000080001816 <tm_record_skip>:
  if(cpu_temp > tm_temp_max) tm_temp_max = cpu_temp;
}

static void
tm_record_skip(int pid)
{
    80001816:	1141                	addi	sp,sp,-16
    80001818:	e406                	sd	ra,8(sp)
    8000181a:	e022                	sd	s0,0(sp)
    8000181c:	0800                	addi	s0,sp,16
  struct thermal_metrics *m = tm_find(pid);
    8000181e:	f83ff0ef          	jal	800017a0 <tm_find>
  if(!m) return;
    80001822:	c501                	beqz	a0,8000182a <tm_record_skip+0x14>
  m->skip_count++;
    80001824:	451c                	lw	a5,8(a0)
    80001826:	2785                	addiw	a5,a5,1
    80001828:	c51c                	sw	a5,8(a0)
}
    8000182a:	60a2                	ld	ra,8(sp)
    8000182c:	6402                	ld	s0,0(sp)
    8000182e:	0141                	addi	sp,sp,16
    80001830:	8082                	ret

0000000080001832 <printpad>:

// Print integer right-aligned in a field of 'width' characters.
// xv6 printf has no width specifiers, so we do it manually.
static void
printpad(int val, int width)
{
    80001832:	7179                	addi	sp,sp,-48
    80001834:	f406                	sd	ra,40(sp)
    80001836:	f022                	sd	s0,32(sp)
    80001838:	e84a                	sd	s2,16(sp)
    8000183a:	e44e                	sd	s3,8(sp)
    8000183c:	1800                	addi	s0,sp,48
    8000183e:	89aa                	mv	s3,a0
  // Count digits
  int tmp = val;
  int digits = 0;
  if(tmp <= 0) digits = 1;
    80001840:	00152693          	slti	a3,a0,1
  while(tmp > 0){ digits++; tmp /= 10; }
    80001844:	02a05363          	blez	a0,8000186a <printpad+0x38>
    80001848:	87aa                	mv	a5,a0
    8000184a:	66666537          	lui	a0,0x66666
    8000184e:	66750513          	addi	a0,a0,1639 # 66666667 <_entry-0x19999999>
    80001852:	4825                	li	a6,9
    80001854:	2685                	addiw	a3,a3,1 # fffffffffffff001 <end+0xffffffff7ffda0d9>
    80001856:	863e                	mv	a2,a5
    80001858:	02a78733          	mul	a4,a5,a0
    8000185c:	9709                	srai	a4,a4,0x22
    8000185e:	41f7d79b          	sraiw	a5,a5,0x1f
    80001862:	40f707bb          	subw	a5,a4,a5
    80001866:	fec847e3          	blt	a6,a2,80001854 <printpad+0x22>
  // Print leading spaces
  for(int i = 0; i < width - digits; i++)
    8000186a:	40d5893b          	subw	s2,a1,a3
    8000186e:	03205163          	blez	s2,80001890 <printpad+0x5e>
    80001872:	ec26                	sd	s1,24(sp)
    80001874:	e052                	sd	s4,0(sp)
    80001876:	4481                	li	s1,0
    printf(" ");
    80001878:	00007a17          	auipc	s4,0x7
    8000187c:	8e0a0a13          	addi	s4,s4,-1824 # 80008158 <etext+0x158>
    80001880:	8552                	mv	a0,s4
    80001882:	c79fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < width - digits; i++)
    80001886:	2485                	addiw	s1,s1,1
    80001888:	ff249ce3          	bne	s1,s2,80001880 <printpad+0x4e>
    8000188c:	64e2                	ld	s1,24(sp)
    8000188e:	6a02                	ld	s4,0(sp)
  printf("%d", val);
    80001890:	85ce                	mv	a1,s3
    80001892:	00007517          	auipc	a0,0x7
    80001896:	8ce50513          	addi	a0,a0,-1842 # 80008160 <etext+0x160>
    8000189a:	c61fe0ef          	jal	800004fa <printf>
}
    8000189e:	70a2                	ld	ra,40(sp)
    800018a0:	7402                	ld	s0,32(sp)
    800018a2:	6942                	ld	s2,16(sp)
    800018a4:	69a2                	ld	s3,8(sp)
    800018a6:	6145                	addi	sp,sp,48
    800018a8:	8082                	ret

00000000800018aa <update_cpu_temp>:
void update_cpu_temp(int process_heat) {
    800018aa:	1141                	addi	sp,sp,-16
    800018ac:	e406                	sd	ra,8(sp)
    800018ae:	e022                	sd	s0,0(sp)
    800018b0:	0800                	addi	s0,sp,16
  if (process_heat > 0) {
    800018b2:	04a05263          	blez	a0,800018f6 <update_cpu_temp+0x4c>
    int heat_factor = 1 + process_heat / 30;  // 1‒4
    800018b6:	888897b7          	lui	a5,0x88889
    800018ba:	88978793          	addi	a5,a5,-1911 # ffffffff88888889 <end+0xffffffff08863961>
    800018be:	02f507b3          	mul	a5,a0,a5
    800018c2:	9381                	srli	a5,a5,0x20
    800018c4:	9fa9                	addw	a5,a5,a0
    800018c6:	4047d79b          	sraiw	a5,a5,0x4
    800018ca:	41f5551b          	sraiw	a0,a0,0x1f
    800018ce:	9f89                	subw	a5,a5,a0
    800018d0:	2785                	addiw	a5,a5,1
    cpu_temp += heat_factor;
    800018d2:	0000a717          	auipc	a4,0xa
    800018d6:	f5672703          	lw	a4,-170(a4) # 8000b828 <cpu_temp>
    800018da:	9fb9                	addw	a5,a5,a4
  if(cpu_temp > 100)
    800018dc:	06400713          	li	a4,100
    800018e0:	02f75663          	bge	a4,a5,8000190c <update_cpu_temp+0x62>
    cpu_temp = 100;
    800018e4:	87ba                	mv	a5,a4
    800018e6:	0000a717          	auipc	a4,0xa
    800018ea:	f4f72123          	sw	a5,-190(a4) # 8000b828 <cpu_temp>
}
    800018ee:	60a2                	ld	ra,8(sp)
    800018f0:	6402                	ld	s0,0(sp)
    800018f2:	0141                	addi	sp,sp,16
    800018f4:	8082                	ret
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
    800018f6:	0000a797          	auipc	a5,0xa
    800018fa:	f327a783          	lw	a5,-206(a5) # 8000b828 <cpu_temp>
    800018fe:	03200713          	li	a4,50
    80001902:	00f72733          	slt	a4,a4,a5
    80001906:	0705                	addi	a4,a4,1
    80001908:	9f99                	subw	a5,a5,a4
    8000190a:	bfc9                	j	800018dc <update_cpu_temp+0x32>
  else if(cpu_temp < 20)
    8000190c:	474d                	li	a4,19
    8000190e:	00f75763          	bge	a4,a5,8000191c <update_cpu_temp+0x72>
    cpu_temp += heat_factor;
    80001912:	0000a717          	auipc	a4,0xa
    80001916:	f0f72b23          	sw	a5,-234(a4) # 8000b828 <cpu_temp>
    8000191a:	bfd1                	j	800018ee <update_cpu_temp+0x44>
    cpu_temp = 20;
    8000191c:	47d1                	li	a5,20
    8000191e:	0000a717          	auipc	a4,0xa
    80001922:	f0f72523          	sw	a5,-246(a4) # 8000b828 <cpu_temp>
}
    80001926:	b7e1                	j	800018ee <update_cpu_temp+0x44>

0000000080001928 <proc_mapstacks>:
{
    80001928:	715d                	addi	sp,sp,-80
    8000192a:	e486                	sd	ra,72(sp)
    8000192c:	e0a2                	sd	s0,64(sp)
    8000192e:	fc26                	sd	s1,56(sp)
    80001930:	f84a                	sd	s2,48(sp)
    80001932:	f44e                	sd	s3,40(sp)
    80001934:	f052                	sd	s4,32(sp)
    80001936:	ec56                	sd	s5,24(sp)
    80001938:	e85a                	sd	s6,16(sp)
    8000193a:	e45e                	sd	s7,8(sp)
    8000193c:	e062                	sd	s8,0(sp)
    8000193e:	0880                	addi	s0,sp,80
    80001940:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	00012497          	auipc	s1,0x12
    80001946:	60648493          	addi	s1,s1,1542 # 80013f48 <proc>
    uint64 va = KSTACK((int) (p - proc));
    8000194a:	8c26                	mv	s8,s1
    8000194c:	ff4df937          	lui	s2,0xff4df
    80001950:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a95>
    80001954:	0936                	slli	s2,s2,0xd
    80001956:	6f590913          	addi	s2,s2,1781
    8000195a:	0936                	slli	s2,s2,0xd
    8000195c:	bd390913          	addi	s2,s2,-1069
    80001960:	0932                	slli	s2,s2,0xc
    80001962:	7a790913          	addi	s2,s2,1959
    80001966:	040009b7          	lui	s3,0x4000
    8000196a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000196c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000196e:	4b99                	li	s7,6
    80001970:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001972:	00018a97          	auipc	s5,0x18
    80001976:	1d6a8a93          	addi	s5,s5,470 # 80019b48 <tickslock>
    char *pa = kalloc();
    8000197a:	9caff0ef          	jal	80000b44 <kalloc>
    8000197e:	862a                	mv	a2,a0
    if(pa == 0)
    80001980:	c121                	beqz	a0,800019c0 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    80001982:	418485b3          	sub	a1,s1,s8
    80001986:	8591                	srai	a1,a1,0x4
    80001988:	032585b3          	mul	a1,a1,s2
    8000198c:	05b6                	slli	a1,a1,0xd
    8000198e:	6789                	lui	a5,0x2
    80001990:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001992:	875e                	mv	a4,s7
    80001994:	86da                	mv	a3,s6
    80001996:	40b985b3          	sub	a1,s3,a1
    8000199a:	8552                	mv	a0,s4
    8000199c:	f7aff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	17048493          	addi	s1,s1,368
    800019a4:	fd549be3          	bne	s1,s5,8000197a <proc_mapstacks+0x52>
}
    800019a8:	60a6                	ld	ra,72(sp)
    800019aa:	6406                	ld	s0,64(sp)
    800019ac:	74e2                	ld	s1,56(sp)
    800019ae:	7942                	ld	s2,48(sp)
    800019b0:	79a2                	ld	s3,40(sp)
    800019b2:	7a02                	ld	s4,32(sp)
    800019b4:	6ae2                	ld	s5,24(sp)
    800019b6:	6b42                	ld	s6,16(sp)
    800019b8:	6ba2                	ld	s7,8(sp)
    800019ba:	6c02                	ld	s8,0(sp)
    800019bc:	6161                	addi	sp,sp,80
    800019be:	8082                	ret
      panic("kalloc");
    800019c0:	00006517          	auipc	a0,0x6
    800019c4:	7a850513          	addi	a0,a0,1960 # 80008168 <etext+0x168>
    800019c8:	e5dfe0ef          	jal	80000824 <panic>

00000000800019cc <procinit>:
{
    800019cc:	7139                	addi	sp,sp,-64
    800019ce:	fc06                	sd	ra,56(sp)
    800019d0:	f822                	sd	s0,48(sp)
    800019d2:	f426                	sd	s1,40(sp)
    800019d4:	f04a                	sd	s2,32(sp)
    800019d6:	ec4e                	sd	s3,24(sp)
    800019d8:	e852                	sd	s4,16(sp)
    800019da:	e456                	sd	s5,8(sp)
    800019dc:	e05a                	sd	s6,0(sp)
    800019de:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800019e0:	00006597          	auipc	a1,0x6
    800019e4:	79058593          	addi	a1,a1,1936 # 80008170 <etext+0x170>
    800019e8:	00012517          	auipc	a0,0x12
    800019ec:	13050513          	addi	a0,a0,304 # 80013b18 <pid_lock>
    800019f0:	9aeff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800019f4:	00006597          	auipc	a1,0x6
    800019f8:	78458593          	addi	a1,a1,1924 # 80008178 <etext+0x178>
    800019fc:	00012517          	auipc	a0,0x12
    80001a00:	13450513          	addi	a0,a0,308 # 80013b30 <wait_lock>
    80001a04:	99aff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a08:	00012497          	auipc	s1,0x12
    80001a0c:	54048493          	addi	s1,s1,1344 # 80013f48 <proc>
      initlock(&p->lock, "proc");
    80001a10:	00006b17          	auipc	s6,0x6
    80001a14:	778b0b13          	addi	s6,s6,1912 # 80008188 <etext+0x188>
      p->kstack = KSTACK((int) (p - proc));
    80001a18:	8aa6                	mv	s5,s1
    80001a1a:	ff4df937          	lui	s2,0xff4df
    80001a1e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a95>
    80001a22:	0936                	slli	s2,s2,0xd
    80001a24:	6f590913          	addi	s2,s2,1781
    80001a28:	0936                	slli	s2,s2,0xd
    80001a2a:	bd390913          	addi	s2,s2,-1069
    80001a2e:	0932                	slli	s2,s2,0xc
    80001a30:	7a790913          	addi	s2,s2,1959
    80001a34:	040009b7          	lui	s3,0x4000
    80001a38:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a3a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a3c:	00018a17          	auipc	s4,0x18
    80001a40:	10ca0a13          	addi	s4,s4,268 # 80019b48 <tickslock>
      initlock(&p->lock, "proc");
    80001a44:	85da                	mv	a1,s6
    80001a46:	8526                	mv	a0,s1
    80001a48:	956ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    80001a4c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a50:	415487b3          	sub	a5,s1,s5
    80001a54:	8791                	srai	a5,a5,0x4
    80001a56:	032787b3          	mul	a5,a5,s2
    80001a5a:	07b6                	slli	a5,a5,0xd
    80001a5c:	6709                	lui	a4,0x2
    80001a5e:	9fb9                	addw	a5,a5,a4
    80001a60:	40f987b3          	sub	a5,s3,a5
    80001a64:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a66:	17048493          	addi	s1,s1,368
    80001a6a:	fd449de3          	bne	s1,s4,80001a44 <procinit+0x78>
}
    80001a6e:	70e2                	ld	ra,56(sp)
    80001a70:	7442                	ld	s0,48(sp)
    80001a72:	74a2                	ld	s1,40(sp)
    80001a74:	7902                	ld	s2,32(sp)
    80001a76:	69e2                	ld	s3,24(sp)
    80001a78:	6a42                	ld	s4,16(sp)
    80001a7a:	6aa2                	ld	s5,8(sp)
    80001a7c:	6b02                	ld	s6,0(sp)
    80001a7e:	6121                	addi	sp,sp,64
    80001a80:	8082                	ret

0000000080001a82 <cpuid>:
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a8a:	8512                	mv	a0,tp
}
    80001a8c:	2501                	sext.w	a0,a0
    80001a8e:	60a2                	ld	ra,8(sp)
    80001a90:	6402                	ld	s0,0(sp)
    80001a92:	0141                	addi	sp,sp,16
    80001a94:	8082                	ret

0000000080001a96 <mycpu>:
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
    80001a9e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001aa0:	2781                	sext.w	a5,a5
    80001aa2:	079e                	slli	a5,a5,0x7
}
    80001aa4:	00012517          	auipc	a0,0x12
    80001aa8:	0a450513          	addi	a0,a0,164 # 80013b48 <cpus>
    80001aac:	953e                	add	a0,a0,a5
    80001aae:	60a2                	ld	ra,8(sp)
    80001ab0:	6402                	ld	s0,0(sp)
    80001ab2:	0141                	addi	sp,sp,16
    80001ab4:	8082                	ret

0000000080001ab6 <myproc>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	1000                	addi	s0,sp,32
  push_off();
    80001ac0:	924ff0ef          	jal	80000be4 <push_off>
    80001ac4:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ac6:	2781                	sext.w	a5,a5
    80001ac8:	079e                	slli	a5,a5,0x7
    80001aca:	00012717          	auipc	a4,0x12
    80001ace:	ece70713          	addi	a4,a4,-306 # 80013998 <tm>
    80001ad2:	97ba                	add	a5,a5,a4
    80001ad4:	1b07b783          	ld	a5,432(a5) # 21b0 <_entry-0x7fffde50>
    80001ad8:	84be                	mv	s1,a5
  pop_off();
    80001ada:	992ff0ef          	jal	80000c6c <pop_off>
}
    80001ade:	8526                	mv	a0,s1
    80001ae0:	60e2                	ld	ra,24(sp)
    80001ae2:	6442                	ld	s0,16(sp)
    80001ae4:	64a2                	ld	s1,8(sp)
    80001ae6:	6105                	addi	sp,sp,32
    80001ae8:	8082                	ret

0000000080001aea <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001aea:	7179                	addi	sp,sp,-48
    80001aec:	f406                	sd	ra,40(sp)
    80001aee:	f022                	sd	s0,32(sp)
    80001af0:	ec26                	sd	s1,24(sp)
    80001af2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001af4:	fc3ff0ef          	jal	80001ab6 <myproc>
    80001af8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001afa:	9c2ff0ef          	jal	80000cbc <release>

  if (first) {
    80001afe:	0000a797          	auipc	a5,0xa
    80001b02:	d227a783          	lw	a5,-734(a5) # 8000b820 <first.2>
    80001b06:	cf95                	beqz	a5,80001b42 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b08:	4505                	li	a0,1
    80001b0a:	46e020ef          	jal	80003f78 <fsinit>

    first = 0;
    80001b0e:	0000a797          	auipc	a5,0xa
    80001b12:	d007a923          	sw	zero,-750(a5) # 8000b820 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b16:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b1a:	00006797          	auipc	a5,0x6
    80001b1e:	67678793          	addi	a5,a5,1654 # 80008190 <etext+0x190>
    80001b22:	fcf43823          	sd	a5,-48(s0)
    80001b26:	fc043c23          	sd	zero,-40(s0)
    80001b2a:	fd040593          	addi	a1,s0,-48
    80001b2e:	853e                	mv	a0,a5
    80001b30:	612030ef          	jal	80005142 <kexec>
    80001b34:	70bc                	ld	a5,96(s1)
    80001b36:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b38:	70bc                	ld	a5,96(s1)
    80001b3a:	7bb8                	ld	a4,112(a5)
    80001b3c:	57fd                	li	a5,-1
    80001b3e:	02f70d63          	beq	a4,a5,80001b78 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b42:	35c010ef          	jal	80002e9e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b46:	6ca8                	ld	a0,88(s1)
    80001b48:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b4a:	04000737          	lui	a4,0x4000
    80001b4e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	0732                	slli	a4,a4,0xc
    80001b52:	00005797          	auipc	a5,0x5
    80001b56:	54a78793          	addi	a5,a5,1354 # 8000709c <userret>
    80001b5a:	00005697          	auipc	a3,0x5
    80001b5e:	4a668693          	addi	a3,a3,1190 # 80007000 <_trampoline>
    80001b62:	8f95                	sub	a5,a5,a3
    80001b64:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b66:	577d                	li	a4,-1
    80001b68:	177e                	slli	a4,a4,0x3f
    80001b6a:	8d59                	or	a0,a0,a4
    80001b6c:	9782                	jalr	a5
}
    80001b6e:	70a2                	ld	ra,40(sp)
    80001b70:	7402                	ld	s0,32(sp)
    80001b72:	64e2                	ld	s1,24(sp)
    80001b74:	6145                	addi	sp,sp,48
    80001b76:	8082                	ret
      panic("exec");
    80001b78:	00006517          	auipc	a0,0x6
    80001b7c:	62050513          	addi	a0,a0,1568 # 80008198 <etext+0x198>
    80001b80:	ca5fe0ef          	jal	80000824 <panic>

0000000080001b84 <allocpid>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b8e:	00012517          	auipc	a0,0x12
    80001b92:	f8a50513          	addi	a0,a0,-118 # 80013b18 <pid_lock>
    80001b96:	892ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001b9a:	0000a797          	auipc	a5,0xa
    80001b9e:	c9278793          	addi	a5,a5,-878 # 8000b82c <nextpid>
    80001ba2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ba4:	0014871b          	addiw	a4,s1,1
    80001ba8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001baa:	00012517          	auipc	a0,0x12
    80001bae:	f6e50513          	addi	a0,a0,-146 # 80013b18 <pid_lock>
    80001bb2:	90aff0ef          	jal	80000cbc <release>
}
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	60e2                	ld	ra,24(sp)
    80001bba:	6442                	ld	s0,16(sp)
    80001bbc:	64a2                	ld	s1,8(sp)
    80001bbe:	6105                	addi	sp,sp,32
    80001bc0:	8082                	ret

0000000080001bc2 <proc_pagetable>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	e04a                	sd	s2,0(sp)
    80001bcc:	1000                	addi	s0,sp,32
    80001bce:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bd0:	e38ff0ef          	jal	80001208 <uvmcreate>
    80001bd4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bd6:	cd05                	beqz	a0,80001c0e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bd8:	4729                	li	a4,10
    80001bda:	00005697          	auipc	a3,0x5
    80001bde:	42668693          	addi	a3,a3,1062 # 80007000 <_trampoline>
    80001be2:	6605                	lui	a2,0x1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	c74ff0ef          	jal	80001060 <mappages>
    80001bf0:	02054663          	bltz	a0,80001c1c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bf4:	4719                	li	a4,6
    80001bf6:	06093683          	ld	a3,96(s2)
    80001bfa:	6605                	lui	a2,0x1
    80001bfc:	020005b7          	lui	a1,0x2000
    80001c00:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c02:	05b6                	slli	a1,a1,0xd
    80001c04:	8526                	mv	a0,s1
    80001c06:	c5aff0ef          	jal	80001060 <mappages>
    80001c0a:	00054f63          	bltz	a0,80001c28 <proc_pagetable+0x66>
}
    80001c0e:	8526                	mv	a0,s1
    80001c10:	60e2                	ld	ra,24(sp)
    80001c12:	6442                	ld	s0,16(sp)
    80001c14:	64a2                	ld	s1,8(sp)
    80001c16:	6902                	ld	s2,0(sp)
    80001c18:	6105                	addi	sp,sp,32
    80001c1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c1c:	4581                	li	a1,0
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fe2ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c24:	4481                	li	s1,0
    80001c26:	b7e5                	j	80001c0e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c28:	4681                	li	a3,0
    80001c2a:	4605                	li	a2,1
    80001c2c:	040005b7          	lui	a1,0x4000
    80001c30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c32:	05b2                	slli	a1,a1,0xc
    80001c34:	8526                	mv	a0,s1
    80001c36:	df8ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001c3a:	4581                	li	a1,0
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fc4ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	b7e9                	j	80001c0e <proc_pagetable+0x4c>

0000000080001c46 <proc_freepagetable>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	84aa                	mv	s1,a0
    80001c54:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c56:	4681                	li	a3,0
    80001c58:	4605                	li	a2,1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	dccff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c66:	4681                	li	a3,0
    80001c68:	4605                	li	a2,1
    80001c6a:	020005b7          	lui	a1,0x2000
    80001c6e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c70:	05b6                	slli	a1,a1,0xd
    80001c72:	8526                	mv	a0,s1
    80001c74:	dbaff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001c78:	85ca                	mv	a1,s2
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	f86ff0ef          	jal	80001402 <uvmfree>
}
    80001c80:	60e2                	ld	ra,24(sp)
    80001c82:	6442                	ld	s0,16(sp)
    80001c84:	64a2                	ld	s1,8(sp)
    80001c86:	6902                	ld	s2,0(sp)
    80001c88:	6105                	addi	sp,sp,32
    80001c8a:	8082                	ret

0000000080001c8c <freeproc>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c98:	7128                	ld	a0,96(a0)
    80001c9a:	c119                	beqz	a0,80001ca0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c9c:	dc1fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001ca0:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ca4:	6ca8                	ld	a0,88(s1)
    80001ca6:	c501                	beqz	a0,80001cae <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ca8:	68ac                	ld	a1,80(s1)
    80001caa:	f9dff0ef          	jal	80001c46 <proc_freepagetable>
  p->pagetable = 0;
    80001cae:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cb2:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cb6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cba:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001cbe:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cc2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cc6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cca:	0204a623          	sw	zero,44(s1)
  p->heat = 0;
    80001cce:	0204ac23          	sw	zero,56(s1)
  p->state = UNUSED;
    80001cd2:	0004ac23          	sw	zero,24(s1)
}
    80001cd6:	60e2                	ld	ra,24(sp)
    80001cd8:	6442                	ld	s0,16(sp)
    80001cda:	64a2                	ld	s1,8(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret

0000000080001ce0 <allocproc>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	e04a                	sd	s2,0(sp)
    80001cea:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cec:	00012497          	auipc	s1,0x12
    80001cf0:	25c48493          	addi	s1,s1,604 # 80013f48 <proc>
    80001cf4:	00018917          	auipc	s2,0x18
    80001cf8:	e5490913          	addi	s2,s2,-428 # 80019b48 <tickslock>
    acquire(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	f2bfe0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001d02:	4c9c                	lw	a5,24(s1)
    80001d04:	cb91                	beqz	a5,80001d18 <allocproc+0x38>
      release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fb5fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0c:	17048493          	addi	s1,s1,368
    80001d10:	ff2496e3          	bne	s1,s2,80001cfc <allocproc+0x1c>
  return 0;
    80001d14:	4481                	li	s1,0
    80001d16:	a0a9                	j	80001d60 <allocproc+0x80>
  p->pid = allocpid();
    80001d18:	e6dff0ef          	jal	80001b84 <allocpid>
    80001d1c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d1e:	4785                	li	a5,1
    80001d20:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001d22:	0204aa23          	sw	zero,52(s1)
  p->heat = 0;              // new process starts cool
    80001d26:	0204ac23          	sw	zero,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d2a:	e1bfe0ef          	jal	80000b44 <kalloc>
    80001d2e:	892a                	mv	s2,a0
    80001d30:	f0a8                	sd	a0,96(s1)
    80001d32:	cd15                	beqz	a0,80001d6e <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001d34:	8526                	mv	a0,s1
    80001d36:	e8dff0ef          	jal	80001bc2 <proc_pagetable>
    80001d3a:	892a                	mv	s2,a0
    80001d3c:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001d3e:	c121                	beqz	a0,80001d7e <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001d40:	07000613          	li	a2,112
    80001d44:	4581                	li	a1,0
    80001d46:	06848513          	addi	a0,s1,104
    80001d4a:	faffe0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001d4e:	00000797          	auipc	a5,0x0
    80001d52:	d9c78793          	addi	a5,a5,-612 # 80001aea <forkret>
    80001d56:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d58:	64bc                	ld	a5,72(s1)
    80001d5a:	6705                	lui	a4,0x1
    80001d5c:	97ba                	add	a5,a5,a4
    80001d5e:	f8bc                	sd	a5,112(s1)
}
    80001d60:	8526                	mv	a0,s1
    80001d62:	60e2                	ld	ra,24(sp)
    80001d64:	6442                	ld	s0,16(sp)
    80001d66:	64a2                	ld	s1,8(sp)
    80001d68:	6902                	ld	s2,0(sp)
    80001d6a:	6105                	addi	sp,sp,32
    80001d6c:	8082                	ret
    freeproc(p);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	f1dff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	f47fe0ef          	jal	80000cbc <release>
    return 0;
    80001d7a:	84ca                	mv	s1,s2
    80001d7c:	b7d5                	j	80001d60 <allocproc+0x80>
    freeproc(p);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	f0dff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	f37fe0ef          	jal	80000cbc <release>
    return 0;
    80001d8a:	84ca                	mv	s1,s2
    80001d8c:	bfd1                	j	80001d60 <allocproc+0x80>

0000000080001d8e <userinit>:
{
    80001d8e:	1101                	addi	sp,sp,-32
    80001d90:	ec06                	sd	ra,24(sp)
    80001d92:	e822                	sd	s0,16(sp)
    80001d94:	e426                	sd	s1,8(sp)
    80001d96:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d98:	f49ff0ef          	jal	80001ce0 <allocproc>
    80001d9c:	84aa                	mv	s1,a0
  initproc = p;
    80001d9e:	0000a797          	auipc	a5,0xa
    80001da2:	aea7b923          	sd	a0,-1294(a5) # 8000b890 <initproc>
  p->cwd = namei("/");
    80001da6:	00006517          	auipc	a0,0x6
    80001daa:	3fa50513          	addi	a0,a0,1018 # 800081a0 <etext+0x1a0>
    80001dae:	704020ef          	jal	800044b2 <namei>
    80001db2:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001db6:	478d                	li	a5,3
    80001db8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	f01fe0ef          	jal	80000cbc <release>
}
    80001dc0:	60e2                	ld	ra,24(sp)
    80001dc2:	6442                	ld	s0,16(sp)
    80001dc4:	64a2                	ld	s1,8(sp)
    80001dc6:	6105                	addi	sp,sp,32
    80001dc8:	8082                	ret

0000000080001dca <growproc>:
{
    80001dca:	1101                	addi	sp,sp,-32
    80001dcc:	ec06                	sd	ra,24(sp)
    80001dce:	e822                	sd	s0,16(sp)
    80001dd0:	e426                	sd	s1,8(sp)
    80001dd2:	e04a                	sd	s2,0(sp)
    80001dd4:	1000                	addi	s0,sp,32
    80001dd6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dd8:	cdfff0ef          	jal	80001ab6 <myproc>
    80001ddc:	892a                	mv	s2,a0
  sz = p->sz;
    80001dde:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001de0:	02905963          	blez	s1,80001e12 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001de4:	00b48633          	add	a2,s1,a1
    80001de8:	020007b7          	lui	a5,0x2000
    80001dec:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001dee:	07b6                	slli	a5,a5,0xd
    80001df0:	02c7ea63          	bltu	a5,a2,80001e24 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001df4:	4691                	li	a3,4
    80001df6:	6d28                	ld	a0,88(a0)
    80001df8:	d04ff0ef          	jal	800012fc <uvmalloc>
    80001dfc:	85aa                	mv	a1,a0
    80001dfe:	c50d                	beqz	a0,80001e28 <growproc+0x5e>
  p->sz = sz;
    80001e00:	04b93823          	sd	a1,80(s2)
  return 0;
    80001e04:	4501                	li	a0,0
}
    80001e06:	60e2                	ld	ra,24(sp)
    80001e08:	6442                	ld	s0,16(sp)
    80001e0a:	64a2                	ld	s1,8(sp)
    80001e0c:	6902                	ld	s2,0(sp)
    80001e0e:	6105                	addi	sp,sp,32
    80001e10:	8082                	ret
  } else if(n < 0){
    80001e12:	fe04d7e3          	bgez	s1,80001e00 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e16:	00b48633          	add	a2,s1,a1
    80001e1a:	6d28                	ld	a0,88(a0)
    80001e1c:	c9cff0ef          	jal	800012b8 <uvmdealloc>
    80001e20:	85aa                	mv	a1,a0
    80001e22:	bff9                	j	80001e00 <growproc+0x36>
      return -1;
    80001e24:	557d                	li	a0,-1
    80001e26:	b7c5                	j	80001e06 <growproc+0x3c>
      return -1;
    80001e28:	557d                	li	a0,-1
    80001e2a:	bff1                	j	80001e06 <growproc+0x3c>

0000000080001e2c <kfork>:
{
    80001e2c:	7139                	addi	sp,sp,-64
    80001e2e:	fc06                	sd	ra,56(sp)
    80001e30:	f822                	sd	s0,48(sp)
    80001e32:	f426                	sd	s1,40(sp)
    80001e34:	e456                	sd	s5,8(sp)
    80001e36:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e38:	c7fff0ef          	jal	80001ab6 <myproc>
    80001e3c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e3e:	ea3ff0ef          	jal	80001ce0 <allocproc>
    80001e42:	0e050a63          	beqz	a0,80001f36 <kfork+0x10a>
    80001e46:	e852                	sd	s4,16(sp)
    80001e48:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e4a:	050ab603          	ld	a2,80(s5)
    80001e4e:	6d2c                	ld	a1,88(a0)
    80001e50:	058ab503          	ld	a0,88(s5)
    80001e54:	de0ff0ef          	jal	80001434 <uvmcopy>
    80001e58:	04054863          	bltz	a0,80001ea8 <kfork+0x7c>
    80001e5c:	f04a                	sd	s2,32(sp)
    80001e5e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e60:	050ab783          	ld	a5,80(s5)
    80001e64:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e68:	060ab683          	ld	a3,96(s5)
    80001e6c:	87b6                	mv	a5,a3
    80001e6e:	060a3703          	ld	a4,96(s4)
    80001e72:	12068693          	addi	a3,a3,288
    80001e76:	6388                	ld	a0,0(a5)
    80001e78:	678c                	ld	a1,8(a5)
    80001e7a:	6b90                	ld	a2,16(a5)
    80001e7c:	e308                	sd	a0,0(a4)
    80001e7e:	e70c                	sd	a1,8(a4)
    80001e80:	eb10                	sd	a2,16(a4)
    80001e82:	6f90                	ld	a2,24(a5)
    80001e84:	ef10                	sd	a2,24(a4)
    80001e86:	02078793          	addi	a5,a5,32
    80001e8a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001e8e:	fed794e3          	bne	a5,a3,80001e76 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e92:	060a3783          	ld	a5,96(s4)
    80001e96:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e9a:	0d8a8493          	addi	s1,s5,216
    80001e9e:	0d8a0913          	addi	s2,s4,216
    80001ea2:	158a8993          	addi	s3,s5,344
    80001ea6:	a831                	j	80001ec2 <kfork+0x96>
    freeproc(np);
    80001ea8:	8552                	mv	a0,s4
    80001eaa:	de3ff0ef          	jal	80001c8c <freeproc>
    release(&np->lock);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	e0dfe0ef          	jal	80000cbc <release>
    return -1;
    80001eb4:	54fd                	li	s1,-1
    80001eb6:	6a42                	ld	s4,16(sp)
    80001eb8:	a885                	j	80001f28 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001eba:	04a1                	addi	s1,s1,8
    80001ebc:	0921                	addi	s2,s2,8
    80001ebe:	01348963          	beq	s1,s3,80001ed0 <kfork+0xa4>
    if(p->ofile[i])
    80001ec2:	6088                	ld	a0,0(s1)
    80001ec4:	d97d                	beqz	a0,80001eba <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ec6:	3a9020ef          	jal	80004a6e <filedup>
    80001eca:	00a93023          	sd	a0,0(s2)
    80001ece:	b7f5                	j	80001eba <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001ed0:	158ab503          	ld	a0,344(s5)
    80001ed4:	57b010ef          	jal	80003c4e <idup>
    80001ed8:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001edc:	4641                	li	a2,16
    80001ede:	160a8593          	addi	a1,s5,352
    80001ee2:	160a0513          	addi	a0,s4,352
    80001ee6:	f67fe0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001eea:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	dcdfe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001ef4:	00012517          	auipc	a0,0x12
    80001ef8:	c3c50513          	addi	a0,a0,-964 # 80013b30 <wait_lock>
    80001efc:	d2dfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f00:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f04:	00012517          	auipc	a0,0x12
    80001f08:	c2c50513          	addi	a0,a0,-980 # 80013b30 <wait_lock>
    80001f0c:	db1fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	d17fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f16:	478d                	li	a5,3
    80001f18:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f1c:	8552                	mv	a0,s4
    80001f1e:	d9ffe0ef          	jal	80000cbc <release>
  return pid;
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	69e2                	ld	s3,24(sp)
    80001f26:	6a42                	ld	s4,16(sp)
}
    80001f28:	8526                	mv	a0,s1
    80001f2a:	70e2                	ld	ra,56(sp)
    80001f2c:	7442                	ld	s0,48(sp)
    80001f2e:	74a2                	ld	s1,40(sp)
    80001f30:	6aa2                	ld	s5,8(sp)
    80001f32:	6121                	addi	sp,sp,64
    80001f34:	8082                	ret
    return -1;
    80001f36:	54fd                	li	s1,-1
    80001f38:	bfc5                	j	80001f28 <kfork+0xfc>

0000000080001f3a <scheduler>:
{
    80001f3a:	7119                	addi	sp,sp,-128
    80001f3c:	fc86                	sd	ra,120(sp)
    80001f3e:	f8a2                	sd	s0,112(sp)
    80001f40:	f4a6                	sd	s1,104(sp)
    80001f42:	f0ca                	sd	s2,96(sp)
    80001f44:	ecce                	sd	s3,88(sp)
    80001f46:	e8d2                	sd	s4,80(sp)
    80001f48:	e4d6                	sd	s5,72(sp)
    80001f4a:	e0da                	sd	s6,64(sp)
    80001f4c:	fc5e                	sd	s7,56(sp)
    80001f4e:	f862                	sd	s8,48(sp)
    80001f50:	f466                	sd	s9,40(sp)
    80001f52:	f06a                	sd	s10,32(sp)
    80001f54:	ec6e                	sd	s11,24(sp)
    80001f56:	0100                	addi	s0,sp,128
    80001f58:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5c:	00779693          	slli	a3,a5,0x7
    80001f60:	00012717          	auipc	a4,0x12
    80001f64:	a3870713          	addi	a4,a4,-1480 # 80013998 <tm>
    80001f68:	9736                	add	a4,a4,a3
    80001f6a:	1a073823          	sd	zero,432(a4)
        swtch(&c->context, &chosen->context);
    80001f6e:	00012717          	auipc	a4,0x12
    80001f72:	be270713          	addi	a4,a4,-1054 # 80013b50 <cpus+0x8>
    80001f76:	9736                	add	a4,a4,a3
    80001f78:	f8e43023          	sd	a4,-128(s0)
      for(p = proc; p < &proc[NPROC]; p++){
    80001f7c:	00018497          	auipc	s1,0x18
    80001f80:	bcc48493          	addi	s1,s1,-1076 # 80019b48 <tickslock>
        summary_printed = 1;   // set BEFORE printing to block other CPUs
    80001f84:	4905                	li	s2,1
        c->proc = chosen;
    80001f86:	00012717          	auipc	a4,0x12
    80001f8a:	a1270713          	addi	a4,a4,-1518 # 80013998 <tm>
    80001f8e:	00d707b3          	add	a5,a4,a3
    80001f92:	f8f43423          	sd	a5,-120(s0)
    80001f96:	ae01                	j	800022a6 <scheduler+0x36c>
      for(p = proc; p < &proc[NPROC]; p++){
    80001f98:	00012997          	auipc	s3,0x12
    80001f9c:	fb098993          	addi	s3,s3,-80 # 80013f48 <proc>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001fa0:	4aa5                	li	s5,9
    80001fa2:	00006a17          	auipc	s4,0x6
    80001fa6:	21ea0a13          	addi	s4,s4,542 # 800081c0 <etext+0x1c0>
    80001faa:	a801                	j	80001fba <scheduler+0x80>
        release(&p->lock);
    80001fac:	854e                	mv	a0,s3
    80001fae:	d0ffe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80001fb2:	17098993          	addi	s3,s3,368
    80001fb6:	02998863          	beq	s3,s1,80001fe6 <scheduler+0xac>
        acquire(&p->lock);
    80001fba:	854e                	mv	a0,s3
    80001fbc:	c6dfe0ef          	jal	80000c28 <acquire>
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80001fc0:	0189a783          	lw	a5,24(s3)
    80001fc4:	d7e5                	beqz	a5,80001fac <scheduler+0x72>
    80001fc6:	17ed                	addi	a5,a5,-5
    80001fc8:	d3f5                	beqz	a5,80001fac <scheduler+0x72>
           p->parent != 0 &&
    80001fca:	0409b503          	ld	a0,64(s3)
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80001fce:	dd79                	beqz	a0,80001fac <scheduler+0x72>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001fd0:	8656                	mv	a2,s5
    80001fd2:	85d2                	mv	a1,s4
    80001fd4:	16050513          	addi	a0,a0,352
    80001fd8:	df5fe0ef          	jal	80000dcc <strncmp>
           p->parent != 0 &&
    80001fdc:	f961                	bnez	a0,80001fac <scheduler+0x72>
          release(&p->lock);
    80001fde:	854e                	mv	a0,s3
    80001fe0:	cddfe0ef          	jal	80000cbc <release>
      if(!still_active){
    80001fe4:	acf5                	j	800022e0 <scheduler+0x3a6>
        summary_printed = 1;   // set BEFORE printing to block other CPUs
    80001fe6:	0000a797          	auipc	a5,0xa
    80001fea:	8927a523          	sw	s2,-1910(a5) # 8000b870 <summary_printed.3>
  printf("\n");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	08a50513          	addi	a0,a0,138 # 80008078 <etext+0x78>
    80001ff6:	d04fe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    80001ffa:	00006517          	auipc	a0,0x6
    80001ffe:	1d650513          	addi	a0,a0,470 # 800081d0 <etext+0x1d0>
    80002002:	cf8fe0ef          	jal	800004fa <printf>
  printf("  ===          THERMAL SCHEDULING SUMMARY                  ===\n");
    80002006:	00006517          	auipc	a0,0x6
    8000200a:	20a50513          	addi	a0,a0,522 # 80008210 <etext+0x210>
    8000200e:	cecfe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    80002012:	00006517          	auipc	a0,0x6
    80002016:	1be50513          	addi	a0,a0,446 # 800081d0 <etext+0x1d0>
    8000201a:	ce0fe0ef          	jal	800004fa <printf>
  printf("\n");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	05a50513          	addi	a0,a0,90 # 80008078 <etext+0x78>
    80002026:	cd4fe0ef          	jal	800004fa <printf>
  int avg_temp = tm_temp_count > 0 ? tm_temp_sum / tm_temp_count : 0;
    8000202a:	0000a797          	auipc	a5,0xa
    8000202e:	85a7a783          	lw	a5,-1958(a5) # 8000b884 <tm_temp_count>
    80002032:	89ee                	mv	s3,s11
    80002034:	00f05863          	blez	a5,80002044 <scheduler+0x10a>
    80002038:	0000a997          	auipc	s3,0xa
    8000203c:	8509a983          	lw	s3,-1968(s3) # 8000b888 <tm_temp_sum>
    80002040:	02f9c9bb          	divw	s3,s3,a5
  printf("  CPU Temperature\n");
    80002044:	00006517          	auipc	a0,0x6
    80002048:	20c50513          	addi	a0,a0,524 # 80008250 <etext+0x250>
    8000204c:	caefe0ef          	jal	800004fa <printf>
  printf("  -----------------------------------------------------------\n");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	21850513          	addi	a0,a0,536 # 80008268 <etext+0x268>
    80002058:	ca2fe0ef          	jal	800004fa <printf>
  printf("    Average : %d    Min : %d    Max : %d\n", avg_temp, tm_temp_min, tm_temp_max);
    8000205c:	0000a697          	auipc	a3,0xa
    80002060:	8246a683          	lw	a3,-2012(a3) # 8000b880 <tm_temp_max>
    80002064:	00009617          	auipc	a2,0x9
    80002068:	7c062603          	lw	a2,1984(a2) # 8000b824 <tm_temp_min>
    8000206c:	85ce                	mv	a1,s3
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	23a50513          	addi	a0,a0,570 # 800082a8 <etext+0x2a8>
    80002076:	c84fe0ef          	jal	800004fa <printf>
  printf("    Cooling cycles (throttled) : %d\n", tm_cooling_cycles);
    8000207a:	0000a597          	auipc	a1,0xa
    8000207e:	8025a583          	lw	a1,-2046(a1) # 8000b87c <tm_cooling_cycles>
    80002082:	00006517          	auipc	a0,0x6
    80002086:	25650513          	addi	a0,a0,598 # 800082d8 <etext+0x2d8>
    8000208a:	c70fe0ef          	jal	800004fa <printf>
  printf("    Total schedule events      : %d\n", tm_temp_count);
    8000208e:	00009597          	auipc	a1,0x9
    80002092:	7f65a583          	lw	a1,2038(a1) # 8000b884 <tm_temp_count>
    80002096:	00006517          	auipc	a0,0x6
    8000209a:	26a50513          	addi	a0,a0,618 # 80008300 <etext+0x300>
    8000209e:	c5cfe0ef          	jal	800004fa <printf>
  printf("\n");
    800020a2:	00006517          	auipc	a0,0x6
    800020a6:	fd650513          	addi	a0,a0,-42 # 80008078 <etext+0x78>
    800020aa:	c50fe0ef          	jal	800004fa <printf>
  printf("  Per-Process Heat Metrics\n");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	27a50513          	addi	a0,a0,634 # 80008328 <etext+0x328>
    800020b6:	c44fe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    800020ba:	00006517          	auipc	a0,0x6
    800020be:	28e50513          	addi	a0,a0,654 # 80008348 <etext+0x348>
    800020c2:	c38fe0ef          	jal	800004fa <printf>
  printf("  PID  | Scheduled | Skipped | Avg Heat | Min Heat | Max Heat\n");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	2ca50513          	addi	a0,a0,714 # 80008390 <etext+0x390>
    800020ce:	c2cfe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	27650513          	addi	a0,a0,630 # 80008348 <etext+0x348>
    800020da:	c20fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800020de:	00012997          	auipc	s3,0x12
    800020e2:	8ba98993          	addi	s3,s3,-1862 # 80013998 <tm>
    800020e6:	00012d17          	auipc	s10,0x12
    800020ea:	a32d0d13          	addi	s10,s10,-1486 # 80013b18 <pid_lock>
  printf("  ---------------------------------------------------------------\n");
    800020ee:	8a4e                	mv	s4,s3
    printf(" |");
    800020f0:	00006b97          	auipc	s7,0x6
    800020f4:	2f0b8b93          	addi	s7,s7,752 # 800083e0 <etext+0x3e0>
    800020f8:	a059                	j	8000217e <scheduler+0x244>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    800020fa:	014aa783          	lw	a5,20(s5)
    800020fe:	8b3e                	mv	s6,a5
    80002100:	0a07c463          	bltz	a5,800021a8 <scheduler+0x26e>
    80002104:	2b01                	sext.w	s6,s6
    printf("  ");
    80002106:	00006517          	auipc	a0,0x6
    8000210a:	2ca50513          	addi	a0,a0,714 # 800083d0 <etext+0x3d0>
    8000210e:	becfe0ef          	jal	800004fa <printf>
    printpad(tm[i].pid, 4);
    80002112:	4591                	li	a1,4
    80002114:	000aa503          	lw	a0,0(s5)
    80002118:	f1aff0ef          	jal	80001832 <printpad>
    printf("  |");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	2bc50513          	addi	a0,a0,700 # 800083d8 <etext+0x3d8>
    80002124:	bd6fe0ef          	jal	800004fa <printf>
    printpad(tm[i].sched_count, 10);
    80002128:	45a9                	li	a1,10
    8000212a:	004aa503          	lw	a0,4(s5)
    8000212e:	f04ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002132:	855e                	mv	a0,s7
    80002134:	bc6fe0ef          	jal	800004fa <printf>
    printpad(tm[i].skip_count, 8);
    80002138:	45a1                	li	a1,8
    8000213a:	008aa503          	lw	a0,8(s5)
    8000213e:	ef4ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002142:	855e                	mv	a0,s7
    80002144:	bb6fe0ef          	jal	800004fa <printf>
    printpad(avg_heat, 9);
    80002148:	45a5                	li	a1,9
    8000214a:	8562                	mv	a0,s8
    8000214c:	ee6ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002150:	855e                	mv	a0,s7
    80002152:	ba8fe0ef          	jal	800004fa <printf>
    printpad(mn, 9);
    80002156:	45a5                	li	a1,9
    80002158:	8566                	mv	a0,s9
    8000215a:	ed8ff0ef          	jal	80001832 <printpad>
    printf(" |");
    8000215e:	855e                	mv	a0,s7
    80002160:	b9afe0ef          	jal	800004fa <printf>
    printpad(mx, 9);
    80002164:	45a5                	li	a1,9
    80002166:	855a                	mv	a0,s6
    80002168:	ecaff0ef          	jal	80001832 <printpad>
    printf("\n");
    8000216c:	00006517          	auipc	a0,0x6
    80002170:	f0c50513          	addi	a0,a0,-244 # 80008078 <etext+0x78>
    80002174:	b86fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    80002178:	0a61                	addi	s4,s4,24
    8000217a:	03aa0963          	beq	s4,s10,800021ac <scheduler+0x272>
    if(tm[i].pid == 0) continue;
    8000217e:	8ad2                	mv	s5,s4
    80002180:	000a2783          	lw	a5,0(s4)
    80002184:	dbf5                	beqz	a5,80002178 <scheduler+0x23e>
    int avg_heat = tm[i].sched_count > 0
    80002186:	004a2783          	lw	a5,4(s4)
    8000218a:	8c6e                	mv	s8,s11
                   ? tm[i].heat_sum / tm[i].sched_count : 0;
    8000218c:	00f05663          	blez	a5,80002198 <scheduler+0x25e>
    int avg_heat = tm[i].sched_count > 0
    80002190:	00ca2c03          	lw	s8,12(s4)
    80002194:	02fc4c3b          	divw	s8,s8,a5
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    80002198:	010aac83          	lw	s9,16(s5)
    8000219c:	06400793          	li	a5,100
    800021a0:	f597dde3          	bge	a5,s9,800020fa <scheduler+0x1c0>
    800021a4:	8cee                	mv	s9,s11
    800021a6:	bf91                	j	800020fa <scheduler+0x1c0>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    800021a8:	4b01                	li	s6,0
    800021aa:	bfa9                	j	80002104 <scheduler+0x1ca>
  printf("  ---------------------------------------------------------------\n");
    800021ac:	00006517          	auipc	a0,0x6
    800021b0:	19c50513          	addi	a0,a0,412 # 80008348 <etext+0x348>
    800021b4:	b46fe0ef          	jal	800004fa <printf>
  printf("\n");
    800021b8:	00006517          	auipc	a0,0x6
    800021bc:	ec050513          	addi	a0,a0,-320 # 80008078 <etext+0x78>
    800021c0:	b3afe0ef          	jal	800004fa <printf>
    tm[i].heat_min = MAX_HEAT + 1;
    800021c4:	06500713          	li	a4,101
    tm[i].heat_max = -1;
    800021c8:	57fd                	li	a5,-1
    tm[i].pid = 0;
    800021ca:	0009a023          	sw	zero,0(s3)
    tm[i].sched_count = 0;
    800021ce:	0009a223          	sw	zero,4(s3)
    tm[i].skip_count = 0;
    800021d2:	0009a423          	sw	zero,8(s3)
    tm[i].heat_sum = 0;
    800021d6:	0009a623          	sw	zero,12(s3)
    tm[i].heat_min = MAX_HEAT + 1;
    800021da:	00e9a823          	sw	a4,16(s3)
    tm[i].heat_max = -1;
    800021de:	00f9aa23          	sw	a5,20(s3)
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800021e2:	09e1                	addi	s3,s3,24
    800021e4:	ffa993e3          	bne	s3,s10,800021ca <scheduler+0x290>
  tm_temp_sum = 0;
    800021e8:	00009797          	auipc	a5,0x9
    800021ec:	6a07a023          	sw	zero,1696(a5) # 8000b888 <tm_temp_sum>
  tm_temp_count = 0;
    800021f0:	00009797          	auipc	a5,0x9
    800021f4:	6807aa23          	sw	zero,1684(a5) # 8000b884 <tm_temp_count>
  tm_temp_min = 100;
    800021f8:	06400793          	li	a5,100
    800021fc:	00009717          	auipc	a4,0x9
    80002200:	62f72423          	sw	a5,1576(a4) # 8000b824 <tm_temp_min>
  tm_temp_max = 0;
    80002204:	00009797          	auipc	a5,0x9
    80002208:	6607ae23          	sw	zero,1660(a5) # 8000b880 <tm_temp_max>
  tm_cooling_cycles = 0;
    8000220c:	00009797          	auipc	a5,0x9
    80002210:	6607a823          	sw	zero,1648(a5) # 8000b87c <tm_cooling_cycles>
  tm_had_children = 0;
    80002214:	00009797          	auipc	a5,0x9
    80002218:	6607a223          	sw	zero,1636(a5) # 8000b878 <tm_had_children>
}
    8000221c:	a0d1                	j	800022e0 <scheduler+0x3a6>
          if(p->heat < 0) p->heat = 0;
    8000221e:	0209ac23          	sw	zero,56(s3)
      release(&p->lock);
    80002222:	854e                	mv	a0,s3
    80002224:	a99fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002228:	17098993          	addi	s3,s3,368
    8000222c:	02998463          	beq	s3,s1,80002254 <scheduler+0x31a>
      acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	9f7fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    80002236:	0189a783          	lw	a5,24(s3)
    8000223a:	37f9                	addiw	a5,a5,-2
    8000223c:	fef963e3          	bltu	s2,a5,80002222 <scheduler+0x2e8>
        if(p->heat > 0){
    80002240:	0389a783          	lw	a5,56(s3)
    80002244:	fcf05fe3          	blez	a5,80002222 <scheduler+0x2e8>
          p->heat -= HEAT_DECAY;
    80002248:	37f9                	addiw	a5,a5,-2
          if(p->heat < 0) p->heat = 0;
    8000224a:	fc07cae3          	bltz	a5,8000221e <scheduler+0x2e4>
          p->heat -= HEAT_DECAY;
    8000224e:	02f9ac23          	sw	a5,56(s3)
    80002252:	bfc1                	j	80002222 <scheduler+0x2e8>
    if(cpu_temp >= THROTTLE_TEMP){
    80002254:	00009597          	auipc	a1,0x9
    80002258:	5d45a583          	lw	a1,1492(a1) # 8000b828 <cpu_temp>
    8000225c:	05900793          	li	a5,89
    80002260:	08b7de63          	bge	a5,a1,800022fc <scheduler+0x3c2>
      tm_cooling_cycles++;
    80002264:	00009717          	auipc	a4,0x9
    80002268:	61870713          	addi	a4,a4,1560 # 8000b87c <tm_cooling_cycles>
    8000226c:	431c                	lw	a5,0(a4)
    8000226e:	2785                	addiw	a5,a5,1
    80002270:	c31c                	sw	a5,0(a4)
      if(sched_round % THERMAL_LOG_INTERVAL == 0)
    80002272:	00009717          	auipc	a4,0x9
    80002276:	60272703          	lw	a4,1538(a4) # 8000b874 <sched_round.4>
    8000227a:	666667b7          	lui	a5,0x66666
    8000227e:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    80002282:	02f707b3          	mul	a5,a4,a5
    80002286:	9789                	srai	a5,a5,0x22
    80002288:	41f7569b          	sraiw	a3,a4,0x1f
    8000228c:	9f95                	subw	a5,a5,a3
    8000228e:	0027969b          	slliw	a3,a5,0x2
    80002292:	9fb5                	addw	a5,a5,a3
    80002294:	0017979b          	slliw	a5,a5,0x1
    80002298:	9f1d                	subw	a4,a4,a5
    8000229a:	cb21                	beqz	a4,800022ea <scheduler+0x3b0>
      update_cpu_temp(0);  // idle cooling
    8000229c:	4501                	li	a0,0
    8000229e:	e0cff0ef          	jal	800018aa <update_cpu_temp>
      asm volatile("wfi");
    800022a2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022a6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022aa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ae:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800022b6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022b8:	10079073          	csrw	sstatus,a5
    sched_round++;
    800022bc:	00009717          	auipc	a4,0x9
    800022c0:	5b870713          	addi	a4,a4,1464 # 8000b874 <sched_round.4>
    800022c4:	431c                	lw	a5,0(a4)
    800022c6:	2785                	addiw	a5,a5,1
    800022c8:	c31c                	sw	a5,0(a4)
    if(tm_had_children && !summary_printed){
    800022ca:	00009797          	auipc	a5,0x9
    800022ce:	5ae7a783          	lw	a5,1454(a5) # 8000b878 <tm_had_children>
    800022d2:	c799                	beqz	a5,800022e0 <scheduler+0x3a6>
    800022d4:	00009d97          	auipc	s11,0x9
    800022d8:	59cdad83          	lw	s11,1436(s11) # 8000b870 <summary_printed.3>
    800022dc:	ca0d8ee3          	beqz	s11,80001f98 <scheduler+0x5e>
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    800022e0:	00012997          	auipc	s3,0x12
    800022e4:	c6898993          	addi	s3,s3,-920 # 80013f48 <proc>
    800022e8:	b7a1                	j	80002230 <scheduler+0x2f6>
        printf("  [COOLING] Temp: %d/%d  | Throttling -- idle cycle to cool down\n", cpu_temp, THROTTLE_TEMP);
    800022ea:	05a00613          	li	a2,90
    800022ee:	00006517          	auipc	a0,0x6
    800022f2:	0fa50513          	addi	a0,a0,250 # 800083e8 <etext+0x3e8>
    800022f6:	a04fe0ef          	jal	800004fa <printf>
    800022fa:	b74d                	j	8000229c <scheduler+0x362>
    skipped = 0;
    800022fc:	4a81                	li	s5,0
    chosen = 0;
    800022fe:	4981                	li	s3,0
    for(p = proc; p < &proc[NPROC]; p++){
    80002300:	00012a17          	auipc	s4,0x12
    80002304:	c48a0a13          	addi	s4,s4,-952 # 80013f48 <proc>
      if(p->state == RUNNABLE){
    80002308:	4b0d                	li	s6,3
        if(p->waiting_tick < STARVE_TICKS){
    8000230a:	0c700b93          	li	s7,199
           strncmp(p->parent->name, "schedtest", 9) == 0){
    8000230e:	4ca5                	li	s9,9
    80002310:	00006c17          	auipc	s8,0x6
    80002314:	eb0c0c13          	addi	s8,s8,-336 # 800081c0 <etext+0x1c0>
          if(!tm_had_children){
    80002318:	00009d17          	auipc	s10,0x9
    8000231c:	560d0d13          	addi	s10,s10,1376 # 8000b878 <tm_had_children>
            summary_printed = 0;  // reset guard only on 0→1 transition (new run)
    80002320:	00009d97          	auipc	s11,0x9
    80002324:	550d8d93          	addi	s11,s11,1360 # 8000b870 <summary_printed.3>
    80002328:	a0a9                	j	80002372 <scheduler+0x438>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    8000232a:	03b00713          	li	a4,59
    8000232e:	0af74863          	blt	a4,a5,800023de <scheduler+0x4a4>
        if(p->parent != 0 &&
    80002332:	040a3503          	ld	a0,64(s4)
    80002336:	c51d                	beqz	a0,80002364 <scheduler+0x42a>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80002338:	8666                	mv	a2,s9
    8000233a:	85e2                	mv	a1,s8
    8000233c:	16050513          	addi	a0,a0,352
    80002340:	a8dfe0ef          	jal	80000dcc <strncmp>
        if(p->parent != 0 &&
    80002344:	e105                	bnez	a0,80002364 <scheduler+0x42a>
          if(!tm_had_children){
    80002346:	000d2783          	lw	a5,0(s10)
    8000234a:	e399                	bnez	a5,80002350 <scheduler+0x416>
            summary_printed = 0;  // reset guard only on 0→1 transition (new run)
    8000234c:	000da023          	sw	zero,0(s11)
          tm_had_children = 1;
    80002350:	012d2023          	sw	s2,0(s10)
          if(chosen == 0 || p->pid < chosen->pid)
    80002354:	0a098d63          	beqz	s3,8000240e <scheduler+0x4d4>
    80002358:	030a2703          	lw	a4,48(s4)
    8000235c:	0309a783          	lw	a5,48(s3)
    80002360:	0af74963          	blt	a4,a5,80002412 <scheduler+0x4d8>
      release(&p->lock);
    80002364:	8552                	mv	a0,s4
    80002366:	957fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    8000236a:	170a0a13          	addi	s4,s4,368
    8000236e:	0a9a0463          	beq	s4,s1,80002416 <scheduler+0x4dc>
      acquire(&p->lock);
    80002372:	8552                	mv	a0,s4
    80002374:	8b5fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE){
    80002378:	018a2783          	lw	a5,24(s4)
    8000237c:	ff6794e3          	bne	a5,s6,80002364 <scheduler+0x42a>
        if(p->waiting_tick < STARVE_TICKS){
    80002380:	034a2783          	lw	a5,52(s4)
    80002384:	fafbc7e3          	blt	s7,a5,80002332 <scheduler+0x3f8>
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002388:	00009797          	auipc	a5,0x9
    8000238c:	4a07a783          	lw	a5,1184(a5) # 8000b828 <cpu_temp>
    80002390:	04f00713          	li	a4,79
    80002394:	f8f75be3          	bge	a4,a5,8000232a <scheduler+0x3f0>
    80002398:	038a2703          	lw	a4,56(s4)
    8000239c:	47f5                	li	a5,29
    8000239e:	f8e7dae3          	bge	a5,a4,80002332 <scheduler+0x3f8>
          skipped++;
    800023a2:	2a85                	addiw	s5,s5,1
          tm_record_skip(p->pid);
    800023a4:	030a2503          	lw	a0,48(s4)
    800023a8:	c6eff0ef          	jal	80001816 <tm_record_skip>
          if(sched_round % THERMAL_LOG_INTERVAL == 0)
    800023ac:	00009717          	auipc	a4,0x9
    800023b0:	4c872703          	lw	a4,1224(a4) # 8000b874 <sched_round.4>
    800023b4:	666667b7          	lui	a5,0x66666
    800023b8:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    800023bc:	02f707b3          	mul	a5,a4,a5
    800023c0:	9789                	srai	a5,a5,0x22
    800023c2:	41f7569b          	sraiw	a3,a4,0x1f
    800023c6:	9f95                	subw	a5,a5,a3
    800023c8:	0027969b          	slliw	a3,a5,0x2
    800023cc:	9fb5                	addw	a5,a5,a3
    800023ce:	0017979b          	slliw	a5,a5,0x1
    800023d2:	9f1d                	subw	a4,a4,a5
    800023d4:	cf01                	beqz	a4,800023ec <scheduler+0x4b2>
          release(&p->lock);
    800023d6:	8552                	mv	a0,s4
    800023d8:	8e5fe0ef          	jal	80000cbc <release>
          continue;
    800023dc:	b779                	j	8000236a <scheduler+0x430>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    800023de:	038a2703          	lw	a4,56(s4)
    800023e2:	03b00793          	li	a5,59
    800023e6:	fae7cee3          	blt	a5,a4,800023a2 <scheduler+0x468>
    800023ea:	b7a1                	j	80002332 <scheduler+0x3f8>
            printf("  [SKIPPED] PID: %d | Heat: %d | Waited: %d | Temp: %d\n",
    800023ec:	00009717          	auipc	a4,0x9
    800023f0:	43c72703          	lw	a4,1084(a4) # 8000b828 <cpu_temp>
    800023f4:	034a2683          	lw	a3,52(s4)
    800023f8:	038a2603          	lw	a2,56(s4)
    800023fc:	030a2583          	lw	a1,48(s4)
    80002400:	00006517          	auipc	a0,0x6
    80002404:	03050513          	addi	a0,a0,48 # 80008430 <etext+0x430>
    80002408:	8f2fe0ef          	jal	800004fa <printf>
    8000240c:	b7e9                	j	800023d6 <scheduler+0x49c>
            chosen = p;
    8000240e:	89d2                	mv	s3,s4
    80002410:	bf91                	j	80002364 <scheduler+0x42a>
    80002412:	89d2                	mv	s3,s4
    80002414:	bf81                	j	80002364 <scheduler+0x42a>
    if(chosen == 0){
    80002416:	00098763          	beqz	s3,80002424 <scheduler+0x4ea>
    for(p = proc; p < &proc[NPROC]; p++){
    8000241a:	00012a17          	auipc	s4,0x12
    8000241e:	b2ea0a13          	addi	s4,s4,-1234 # 80013f48 <proc>
    80002422:	a8d1                	j	800024f6 <scheduler+0x5bc>
      int lowest_heat = MAX_HEAT + 1;
    80002424:	06500b93          	li	s7,101
      for(p = proc; p < &proc[NPROC]; p++){
    80002428:	00012a17          	auipc	s4,0x12
    8000242c:	b20a0a13          	addi	s4,s4,-1248 # 80013f48 <proc>
        if(p->state == RUNNABLE){
    80002430:	4b0d                	li	s6,3
          if(p->waiting_tick < STARVE_TICKS){
    80002432:	0c700c13          	li	s8,199
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002436:	00009d17          	auipc	s10,0x9
    8000243a:	3f2d0d13          	addi	s10,s10,1010 # 8000b828 <cpu_temp>
    8000243e:	04f00c93          	li	s9,79
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002442:	03b00d93          	li	s11,59
    80002446:	a005                	j	80002466 <scheduler+0x52c>
    80002448:	04fdcc63          	blt	s11,a5,800024a0 <scheduler+0x566>
          if(p->heat < lowest_heat){
    8000244c:	038a2783          	lw	a5,56(s4)
    80002450:	0177d463          	bge	a5,s7,80002458 <scheduler+0x51e>
            lowest_heat = p->heat;
    80002454:	8bbe                	mv	s7,a5
            chosen = p;
    80002456:	89d2                	mv	s3,s4
        release(&p->lock);
    80002458:	8552                	mv	a0,s4
    8000245a:	863fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    8000245e:	170a0a13          	addi	s4,s4,368
    80002462:	049a0463          	beq	s4,s1,800024aa <scheduler+0x570>
        acquire(&p->lock);
    80002466:	8552                	mv	a0,s4
    80002468:	fc0fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    8000246c:	018a2783          	lw	a5,24(s4)
    80002470:	ff6794e3          	bne	a5,s6,80002458 <scheduler+0x51e>
          if(p->waiting_tick < STARVE_TICKS){
    80002474:	034a2783          	lw	a5,52(s4)
    80002478:	fcfc4ae3          	blt	s8,a5,8000244c <scheduler+0x512>
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    8000247c:	000d2783          	lw	a5,0(s10)
    80002480:	fcfcd4e3          	bge	s9,a5,80002448 <scheduler+0x50e>
    80002484:	038a2783          	lw	a5,56(s4)
    80002488:	4775                	li	a4,29
    8000248a:	fcf751e3          	bge	a4,a5,8000244c <scheduler+0x512>
            skipped++;
    8000248e:	2a85                	addiw	s5,s5,1
            tm_record_skip(p->pid);
    80002490:	030a2503          	lw	a0,48(s4)
    80002494:	b82ff0ef          	jal	80001816 <tm_record_skip>
            release(&p->lock);
    80002498:	8552                	mv	a0,s4
    8000249a:	823fe0ef          	jal	80000cbc <release>
            continue;
    8000249e:	b7c1                	j	8000245e <scheduler+0x524>
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    800024a0:	038a2783          	lw	a5,56(s4)
    800024a4:	fefdc5e3          	blt	s11,a5,8000248e <scheduler+0x554>
    800024a8:	b755                	j	8000244c <scheduler+0x512>
    if(chosen == 0){
    800024aa:	f60998e3          	bnez	s3,8000241a <scheduler+0x4e0>
      for(p = proc; p < &proc[NPROC]; p++){
    800024ae:	00012a17          	auipc	s4,0x12
    800024b2:	a9aa0a13          	addi	s4,s4,-1382 # 80013f48 <proc>
        if(p->state == RUNNABLE){
    800024b6:	4b8d                	li	s7,3
      for(p = proc; p < &proc[NPROC]; p++){
    800024b8:	00017b17          	auipc	s6,0x17
    800024bc:	690b0b13          	addi	s6,s6,1680 # 80019b48 <tickslock>
        acquire(&p->lock);
    800024c0:	8552                	mv	a0,s4
    800024c2:	f66fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    800024c6:	018a2783          	lw	a5,24(s4)
    800024ca:	01778a63          	beq	a5,s7,800024de <scheduler+0x5a4>
        release(&p->lock);
    800024ce:	8552                	mv	a0,s4
    800024d0:	fecfe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    800024d4:	170a0a13          	addi	s4,s4,368
    800024d8:	ff6a14e3          	bne	s4,s6,800024c0 <scheduler+0x586>
    800024dc:	bf3d                	j	8000241a <scheduler+0x4e0>
          release(&p->lock);
    800024de:	8552                	mv	a0,s4
    800024e0:	fdcfe0ef          	jal	80000cbc <release>
          chosen = p;
    800024e4:	89d2                	mv	s3,s4
          break;
    800024e6:	bf15                	j	8000241a <scheduler+0x4e0>
      release(&p->lock);
    800024e8:	8552                	mv	a0,s4
    800024ea:	fd2fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    800024ee:	170a0a13          	addi	s4,s4,368
    800024f2:	029a0163          	beq	s4,s1,80002514 <scheduler+0x5da>
      acquire(&p->lock);
    800024f6:	8552                	mv	a0,s4
    800024f8:	f30fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen){
    800024fc:	018a2783          	lw	a5,24(s4)
    80002500:	17f5                	addi	a5,a5,-3
    80002502:	f3fd                	bnez	a5,800024e8 <scheduler+0x5ae>
    80002504:	ff4982e3          	beq	s3,s4,800024e8 <scheduler+0x5ae>
        p->waiting_tick++;
    80002508:	034a2783          	lw	a5,52(s4)
    8000250c:	2785                	addiw	a5,a5,1
    8000250e:	02fa2a23          	sw	a5,52(s4)
    80002512:	bfd9                	j	800024e8 <scheduler+0x5ae>
    if(chosen == 0){
    80002514:	00098f63          	beqz	s3,80002532 <scheduler+0x5f8>
      acquire(&chosen->lock);
    80002518:	8a4e                	mv	s4,s3
    8000251a:	854e                	mv	a0,s3
    8000251c:	f0cfe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    80002520:	0189a703          	lw	a4,24(s3)
    80002524:	478d                	li	a5,3
    80002526:	00f70c63          	beq	a4,a5,8000253e <scheduler+0x604>
      release(&chosen->lock);
    8000252a:	8552                	mv	a0,s4
    8000252c:	f90fe0ef          	jal	80000cbc <release>
    80002530:	bb9d                	j	800022a6 <scheduler+0x36c>
      update_cpu_temp(0);  // idle cooling
    80002532:	4501                	li	a0,0
    80002534:	b76ff0ef          	jal	800018aa <update_cpu_temp>
      asm volatile("wfi");
    80002538:	10500073          	wfi
    8000253c:	b3ad                	j	800022a6 <scheduler+0x36c>
        if(cpu_temp >= HOT_TEMP)       zone = "HOT ";
    8000253e:	00009597          	auipc	a1,0x9
    80002542:	2ea5a583          	lw	a1,746(a1) # 8000b828 <cpu_temp>
    80002546:	04f00793          	li	a5,79
    8000254a:	00006617          	auipc	a2,0x6
    8000254e:	c5e60613          	addi	a2,a2,-930 # 800081a8 <etext+0x1a8>
    80002552:	00b7ce63          	blt	a5,a1,8000256e <scheduler+0x634>
        else if(cpu_temp >= WARM_TEMP) zone = "WARM";
    80002556:	03b00793          	li	a5,59
    8000255a:	00006617          	auipc	a2,0x6
    8000255e:	c5e60613          	addi	a2,a2,-930 # 800081b8 <etext+0x1b8>
    80002562:	00b7c663          	blt	a5,a1,8000256e <scheduler+0x634>
        char *zone = "COOL";
    80002566:	00006617          	auipc	a2,0x6
    8000256a:	c4a60613          	addi	a2,a2,-950 # 800081b0 <etext+0x1b0>
        if(sched_round % THERMAL_LOG_INTERVAL == 0){
    8000256e:	00009717          	auipc	a4,0x9
    80002572:	30672703          	lw	a4,774(a4) # 8000b874 <sched_round.4>
    80002576:	666667b7          	lui	a5,0x66666
    8000257a:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    8000257e:	02f707b3          	mul	a5,a4,a5
    80002582:	9789                	srai	a5,a5,0x22
    80002584:	41f7569b          	sraiw	a3,a4,0x1f
    80002588:	9f95                	subw	a5,a5,a3
    8000258a:	0027969b          	slliw	a3,a5,0x2
    8000258e:	9fb5                	addw	a5,a5,a3
    80002590:	0017979b          	slliw	a5,a5,0x1
    80002594:	9f1d                	subw	a4,a4,a5
    80002596:	c379                	beqz	a4,8000265c <scheduler+0x722>
        chosen->state = RUNNING;
    80002598:	4791                	li	a5,4
    8000259a:	00f9ac23          	sw	a5,24(s3)
        c->proc = chosen;
    8000259e:	f8843783          	ld	a5,-120(s0)
    800025a2:	1b37b823          	sd	s3,432(a5)
        tm_record_schedule(chosen->pid, chosen->heat);
    800025a6:	0389aa83          	lw	s5,56(s3)
  struct thermal_metrics *m = tm_find(pid);
    800025aa:	0309a503          	lw	a0,48(s3)
    800025ae:	9f2ff0ef          	jal	800017a0 <tm_find>
    800025b2:	87aa                	mv	a5,a0
  if(!m) return;
    800025b4:	c925                	beqz	a0,80002624 <scheduler+0x6ea>
  m->sched_count++;
    800025b6:	4158                	lw	a4,4(a0)
    800025b8:	2705                	addiw	a4,a4,1
    800025ba:	c158                	sw	a4,4(a0)
  m->heat_sum += heat;
    800025bc:	4558                	lw	a4,12(a0)
    800025be:	0157073b          	addw	a4,a4,s5
    800025c2:	c558                	sw	a4,12(a0)
  if(heat < m->heat_min) m->heat_min = heat;
    800025c4:	4918                	lw	a4,16(a0)
    800025c6:	00ead463          	bge	s5,a4,800025ce <scheduler+0x694>
    800025ca:	01552823          	sw	s5,16(a0)
  if(heat > m->heat_max) m->heat_max = heat;
    800025ce:	4bd8                	lw	a4,20(a5)
    800025d0:	01575463          	bge	a4,s5,800025d8 <scheduler+0x69e>
    800025d4:	0157aa23          	sw	s5,20(a5)
  tm_temp_sum += cpu_temp;
    800025d8:	00009797          	auipc	a5,0x9
    800025dc:	2507a783          	lw	a5,592(a5) # 8000b828 <cpu_temp>
    800025e0:	00009697          	auipc	a3,0x9
    800025e4:	2a868693          	addi	a3,a3,680 # 8000b888 <tm_temp_sum>
    800025e8:	4298                	lw	a4,0(a3)
    800025ea:	9f3d                	addw	a4,a4,a5
    800025ec:	c298                	sw	a4,0(a3)
  tm_temp_count++;
    800025ee:	00009697          	auipc	a3,0x9
    800025f2:	29668693          	addi	a3,a3,662 # 8000b884 <tm_temp_count>
    800025f6:	4298                	lw	a4,0(a3)
    800025f8:	2705                	addiw	a4,a4,1
    800025fa:	c298                	sw	a4,0(a3)
  if(cpu_temp < tm_temp_min) tm_temp_min = cpu_temp;
    800025fc:	00009717          	auipc	a4,0x9
    80002600:	22872703          	lw	a4,552(a4) # 8000b824 <tm_temp_min>
    80002604:	00e7d663          	bge	a5,a4,80002610 <scheduler+0x6d6>
    80002608:	00009717          	auipc	a4,0x9
    8000260c:	20f72e23          	sw	a5,540(a4) # 8000b824 <tm_temp_min>
  if(cpu_temp > tm_temp_max) tm_temp_max = cpu_temp;
    80002610:	00009717          	auipc	a4,0x9
    80002614:	27072703          	lw	a4,624(a4) # 8000b880 <tm_temp_max>
    80002618:	00f75663          	bge	a4,a5,80002624 <scheduler+0x6ea>
    8000261c:	00009717          	auipc	a4,0x9
    80002620:	26f72223          	sw	a5,612(a4) # 8000b880 <tm_temp_max>
        chosen->waiting_tick = 0;
    80002624:	0209aa23          	sw	zero,52(s3)
        chosen->heat += HEAT_INCREMENT;
    80002628:	0389a783          	lw	a5,56(s3)
    8000262c:	27a9                	addiw	a5,a5,10
    8000262e:	853e                	mv	a0,a5
        if(chosen->heat > MAX_HEAT)
    80002630:	06400713          	li	a4,100
    80002634:	00f75463          	bge	a4,a5,8000263c <scheduler+0x702>
    80002638:	06400513          	li	a0,100
    8000263c:	02a9ac23          	sw	a0,56(s3)
        update_cpu_temp(chosen->heat);
    80002640:	2501                	sext.w	a0,a0
    80002642:	a68ff0ef          	jal	800018aa <update_cpu_temp>
        swtch(&c->context, &chosen->context);
    80002646:	06898593          	addi	a1,s3,104
    8000264a:	f8043503          	ld	a0,-128(s0)
    8000264e:	7a6000ef          	jal	80002df4 <swtch>
        c->proc = 0;
    80002652:	f8843783          	ld	a5,-120(s0)
    80002656:	1a07b823          	sd	zero,432(a5)
    8000265a:	bdc1                	j	8000252a <scheduler+0x5f0>
          printf("  [THERMAL] Temp: %d [%s] | PID: %d | Heat: %d | %s",
    8000265c:	16098793          	addi	a5,s3,352
    80002660:	0389a703          	lw	a4,56(s3)
    80002664:	0309a683          	lw	a3,48(s3)
    80002668:	00006517          	auipc	a0,0x6
    8000266c:	e0050513          	addi	a0,a0,-512 # 80008468 <etext+0x468>
    80002670:	e8bfd0ef          	jal	800004fa <printf>
          if(skipped > 0)
    80002674:	01504963          	bgtz	s5,80002686 <scheduler+0x74c>
          printf("\n");
    80002678:	00006517          	auipc	a0,0x6
    8000267c:	a0050513          	addi	a0,a0,-1536 # 80008078 <etext+0x78>
    80002680:	e7bfd0ef          	jal	800004fa <printf>
    80002684:	bf11                	j	80002598 <scheduler+0x65e>
            printf(" | %d skipped", skipped);
    80002686:	85d6                	mv	a1,s5
    80002688:	00006517          	auipc	a0,0x6
    8000268c:	e1850513          	addi	a0,a0,-488 # 800084a0 <etext+0x4a0>
    80002690:	e6bfd0ef          	jal	800004fa <printf>
    80002694:	b7d5                	j	80002678 <scheduler+0x73e>

0000000080002696 <sched>:
{
    80002696:	7179                	addi	sp,sp,-48
    80002698:	f406                	sd	ra,40(sp)
    8000269a:	f022                	sd	s0,32(sp)
    8000269c:	ec26                	sd	s1,24(sp)
    8000269e:	e84a                	sd	s2,16(sp)
    800026a0:	e44e                	sd	s3,8(sp)
    800026a2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800026a4:	c12ff0ef          	jal	80001ab6 <myproc>
    800026a8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800026aa:	d0efe0ef          	jal	80000bb8 <holding>
    800026ae:	c935                	beqz	a0,80002722 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026b0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800026b2:	2781                	sext.w	a5,a5
    800026b4:	079e                	slli	a5,a5,0x7
    800026b6:	00011717          	auipc	a4,0x11
    800026ba:	2e270713          	addi	a4,a4,738 # 80013998 <tm>
    800026be:	97ba                	add	a5,a5,a4
    800026c0:	2287a703          	lw	a4,552(a5)
    800026c4:	4785                	li	a5,1
    800026c6:	06f71463          	bne	a4,a5,8000272e <sched+0x98>
  if(p->state == RUNNING)
    800026ca:	4c98                	lw	a4,24(s1)
    800026cc:	4791                	li	a5,4
    800026ce:	06f70663          	beq	a4,a5,8000273a <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026d6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800026d8:	e7bd                	bnez	a5,80002746 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026da:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800026dc:	00011917          	auipc	s2,0x11
    800026e0:	2bc90913          	addi	s2,s2,700 # 80013998 <tm>
    800026e4:	2781                	sext.w	a5,a5
    800026e6:	079e                	slli	a5,a5,0x7
    800026e8:	97ca                	add	a5,a5,s2
    800026ea:	22c7a983          	lw	s3,556(a5)
    800026ee:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800026f0:	2781                	sext.w	a5,a5
    800026f2:	079e                	slli	a5,a5,0x7
    800026f4:	07a1                	addi	a5,a5,8
    800026f6:	00011597          	auipc	a1,0x11
    800026fa:	45258593          	addi	a1,a1,1106 # 80013b48 <cpus>
    800026fe:	95be                	add	a1,a1,a5
    80002700:	06848513          	addi	a0,s1,104
    80002704:	6f0000ef          	jal	80002df4 <swtch>
    80002708:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000270a:	2781                	sext.w	a5,a5
    8000270c:	079e                	slli	a5,a5,0x7
    8000270e:	993e                	add	s2,s2,a5
    80002710:	23392623          	sw	s3,556(s2)
}
    80002714:	70a2                	ld	ra,40(sp)
    80002716:	7402                	ld	s0,32(sp)
    80002718:	64e2                	ld	s1,24(sp)
    8000271a:	6942                	ld	s2,16(sp)
    8000271c:	69a2                	ld	s3,8(sp)
    8000271e:	6145                	addi	sp,sp,48
    80002720:	8082                	ret
    panic("sched p->lock");
    80002722:	00006517          	auipc	a0,0x6
    80002726:	d8e50513          	addi	a0,a0,-626 # 800084b0 <etext+0x4b0>
    8000272a:	8fafe0ef          	jal	80000824 <panic>
    panic("sched locks");
    8000272e:	00006517          	auipc	a0,0x6
    80002732:	d9250513          	addi	a0,a0,-622 # 800084c0 <etext+0x4c0>
    80002736:	8eefe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    8000273a:	00006517          	auipc	a0,0x6
    8000273e:	d9650513          	addi	a0,a0,-618 # 800084d0 <etext+0x4d0>
    80002742:	8e2fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80002746:	00006517          	auipc	a0,0x6
    8000274a:	d9a50513          	addi	a0,a0,-614 # 800084e0 <etext+0x4e0>
    8000274e:	8d6fe0ef          	jal	80000824 <panic>

0000000080002752 <yield>:
{
    80002752:	1101                	addi	sp,sp,-32
    80002754:	ec06                	sd	ra,24(sp)
    80002756:	e822                	sd	s0,16(sp)
    80002758:	e426                	sd	s1,8(sp)
    8000275a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000275c:	b5aff0ef          	jal	80001ab6 <myproc>
    80002760:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002762:	cc6fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002766:	478d                	li	a5,3
    80002768:	cc9c                	sw	a5,24(s1)
  sched();
    8000276a:	f2dff0ef          	jal	80002696 <sched>
  release(&p->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	d4cfe0ef          	jal	80000cbc <release>
}
    80002774:	60e2                	ld	ra,24(sp)
    80002776:	6442                	ld	s0,16(sp)
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	6105                	addi	sp,sp,32
    8000277c:	8082                	ret

000000008000277e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000277e:	7179                	addi	sp,sp,-48
    80002780:	f406                	sd	ra,40(sp)
    80002782:	f022                	sd	s0,32(sp)
    80002784:	ec26                	sd	s1,24(sp)
    80002786:	e84a                	sd	s2,16(sp)
    80002788:	e44e                	sd	s3,8(sp)
    8000278a:	1800                	addi	s0,sp,48
    8000278c:	89aa                	mv	s3,a0
    8000278e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002790:	b26ff0ef          	jal	80001ab6 <myproc>
    80002794:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002796:	c92fe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000279a:	854a                	mv	a0,s2
    8000279c:	d20fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    800027a0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027a4:	4789                	li	a5,2
    800027a6:	cc9c                	sw	a5,24(s1)

  sched();
    800027a8:	eefff0ef          	jal	80002696 <sched>

  // Tidy up.
  p->chan = 0;
    800027ac:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800027b0:	8526                	mv	a0,s1
    800027b2:	d0afe0ef          	jal	80000cbc <release>
  acquire(lk);
    800027b6:	854a                	mv	a0,s2
    800027b8:	c70fe0ef          	jal	80000c28 <acquire>
}
    800027bc:	70a2                	ld	ra,40(sp)
    800027be:	7402                	ld	s0,32(sp)
    800027c0:	64e2                	ld	s1,24(sp)
    800027c2:	6942                	ld	s2,16(sp)
    800027c4:	69a2                	ld	s3,8(sp)
    800027c6:	6145                	addi	sp,sp,48
    800027c8:	8082                	ret

00000000800027ca <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800027ca:	7139                	addi	sp,sp,-64
    800027cc:	fc06                	sd	ra,56(sp)
    800027ce:	f822                	sd	s0,48(sp)
    800027d0:	f426                	sd	s1,40(sp)
    800027d2:	f04a                	sd	s2,32(sp)
    800027d4:	ec4e                	sd	s3,24(sp)
    800027d6:	e852                	sd	s4,16(sp)
    800027d8:	e456                	sd	s5,8(sp)
    800027da:	0080                	addi	s0,sp,64
    800027dc:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800027de:	00011497          	auipc	s1,0x11
    800027e2:	76a48493          	addi	s1,s1,1898 # 80013f48 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800027e6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800027e8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800027ea:	00017917          	auipc	s2,0x17
    800027ee:	35e90913          	addi	s2,s2,862 # 80019b48 <tickslock>
    800027f2:	a801                	j	80002802 <wakeup+0x38>
      }
      release(&p->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	cc6fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800027fa:	17048493          	addi	s1,s1,368
    800027fe:	03248263          	beq	s1,s2,80002822 <wakeup+0x58>
    if(p != myproc()){
    80002802:	ab4ff0ef          	jal	80001ab6 <myproc>
    80002806:	fe950ae3          	beq	a0,s1,800027fa <wakeup+0x30>
      acquire(&p->lock);
    8000280a:	8526                	mv	a0,s1
    8000280c:	c1cfe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002810:	4c9c                	lw	a5,24(s1)
    80002812:	ff3791e3          	bne	a5,s3,800027f4 <wakeup+0x2a>
    80002816:	709c                	ld	a5,32(s1)
    80002818:	fd479ee3          	bne	a5,s4,800027f4 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000281c:	0154ac23          	sw	s5,24(s1)
    80002820:	bfd1                	j	800027f4 <wakeup+0x2a>
    }
  }
}
    80002822:	70e2                	ld	ra,56(sp)
    80002824:	7442                	ld	s0,48(sp)
    80002826:	74a2                	ld	s1,40(sp)
    80002828:	7902                	ld	s2,32(sp)
    8000282a:	69e2                	ld	s3,24(sp)
    8000282c:	6a42                	ld	s4,16(sp)
    8000282e:	6aa2                	ld	s5,8(sp)
    80002830:	6121                	addi	sp,sp,64
    80002832:	8082                	ret

0000000080002834 <reparent>:
{
    80002834:	7179                	addi	sp,sp,-48
    80002836:	f406                	sd	ra,40(sp)
    80002838:	f022                	sd	s0,32(sp)
    8000283a:	ec26                	sd	s1,24(sp)
    8000283c:	e84a                	sd	s2,16(sp)
    8000283e:	e44e                	sd	s3,8(sp)
    80002840:	e052                	sd	s4,0(sp)
    80002842:	1800                	addi	s0,sp,48
    80002844:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002846:	00011497          	auipc	s1,0x11
    8000284a:	70248493          	addi	s1,s1,1794 # 80013f48 <proc>
      pp->parent = initproc;
    8000284e:	00009a17          	auipc	s4,0x9
    80002852:	042a0a13          	addi	s4,s4,66 # 8000b890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002856:	00017997          	auipc	s3,0x17
    8000285a:	2f298993          	addi	s3,s3,754 # 80019b48 <tickslock>
    8000285e:	a029                	j	80002868 <reparent+0x34>
    80002860:	17048493          	addi	s1,s1,368
    80002864:	01348b63          	beq	s1,s3,8000287a <reparent+0x46>
    if(pp->parent == p){
    80002868:	60bc                	ld	a5,64(s1)
    8000286a:	ff279be3          	bne	a5,s2,80002860 <reparent+0x2c>
      pp->parent = initproc;
    8000286e:	000a3503          	ld	a0,0(s4)
    80002872:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002874:	f57ff0ef          	jal	800027ca <wakeup>
    80002878:	b7e5                	j	80002860 <reparent+0x2c>
}
    8000287a:	70a2                	ld	ra,40(sp)
    8000287c:	7402                	ld	s0,32(sp)
    8000287e:	64e2                	ld	s1,24(sp)
    80002880:	6942                	ld	s2,16(sp)
    80002882:	69a2                	ld	s3,8(sp)
    80002884:	6a02                	ld	s4,0(sp)
    80002886:	6145                	addi	sp,sp,48
    80002888:	8082                	ret

000000008000288a <kexit>:
{
    8000288a:	7179                	addi	sp,sp,-48
    8000288c:	f406                	sd	ra,40(sp)
    8000288e:	f022                	sd	s0,32(sp)
    80002890:	ec26                	sd	s1,24(sp)
    80002892:	e84a                	sd	s2,16(sp)
    80002894:	e44e                	sd	s3,8(sp)
    80002896:	e052                	sd	s4,0(sp)
    80002898:	1800                	addi	s0,sp,48
    8000289a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000289c:	a1aff0ef          	jal	80001ab6 <myproc>
    800028a0:	89aa                	mv	s3,a0
  if(p == initproc)
    800028a2:	00009797          	auipc	a5,0x9
    800028a6:	fee7b783          	ld	a5,-18(a5) # 8000b890 <initproc>
    800028aa:	0d850493          	addi	s1,a0,216
    800028ae:	15850913          	addi	s2,a0,344
    800028b2:	00a79b63          	bne	a5,a0,800028c8 <kexit+0x3e>
    panic("init exiting");
    800028b6:	00006517          	auipc	a0,0x6
    800028ba:	c4250513          	addi	a0,a0,-958 # 800084f8 <etext+0x4f8>
    800028be:	f67fd0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800028c2:	04a1                	addi	s1,s1,8
    800028c4:	01248963          	beq	s1,s2,800028d6 <kexit+0x4c>
    if(p->ofile[fd]){
    800028c8:	6088                	ld	a0,0(s1)
    800028ca:	dd65                	beqz	a0,800028c2 <kexit+0x38>
      fileclose(f);
    800028cc:	1e8020ef          	jal	80004ab4 <fileclose>
      p->ofile[fd] = 0;
    800028d0:	0004b023          	sd	zero,0(s1)
    800028d4:	b7fd                	j	800028c2 <kexit+0x38>
  begin_op();
    800028d6:	5bb010ef          	jal	80004690 <begin_op>
  iput(p->cwd);
    800028da:	1589b503          	ld	a0,344(s3)
    800028de:	528010ef          	jal	80003e06 <iput>
  end_op();
    800028e2:	61f010ef          	jal	80004700 <end_op>
  p->cwd = 0;
    800028e6:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800028ea:	00011517          	auipc	a0,0x11
    800028ee:	24650513          	addi	a0,a0,582 # 80013b30 <wait_lock>
    800028f2:	b36fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800028f6:	854e                	mv	a0,s3
    800028f8:	f3dff0ef          	jal	80002834 <reparent>
  wakeup(p->parent);
    800028fc:	0409b503          	ld	a0,64(s3)
    80002900:	ecbff0ef          	jal	800027ca <wakeup>
  acquire(&p->lock);
    80002904:	854e                	mv	a0,s3
    80002906:	b22fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000290a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000290e:	4795                	li	a5,5
    80002910:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002914:	00011517          	auipc	a0,0x11
    80002918:	21c50513          	addi	a0,a0,540 # 80013b30 <wait_lock>
    8000291c:	ba0fe0ef          	jal	80000cbc <release>
  sched();
    80002920:	d77ff0ef          	jal	80002696 <sched>
  panic("zombie exit");
    80002924:	00006517          	auipc	a0,0x6
    80002928:	be450513          	addi	a0,a0,-1052 # 80008508 <etext+0x508>
    8000292c:	ef9fd0ef          	jal	80000824 <panic>

0000000080002930 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002930:	7179                	addi	sp,sp,-48
    80002932:	f406                	sd	ra,40(sp)
    80002934:	f022                	sd	s0,32(sp)
    80002936:	ec26                	sd	s1,24(sp)
    80002938:	e84a                	sd	s2,16(sp)
    8000293a:	e44e                	sd	s3,8(sp)
    8000293c:	1800                	addi	s0,sp,48
    8000293e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002940:	00011497          	auipc	s1,0x11
    80002944:	60848493          	addi	s1,s1,1544 # 80013f48 <proc>
    80002948:	00017997          	auipc	s3,0x17
    8000294c:	20098993          	addi	s3,s3,512 # 80019b48 <tickslock>
    acquire(&p->lock);
    80002950:	8526                	mv	a0,s1
    80002952:	ad6fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002956:	589c                	lw	a5,48(s1)
    80002958:	01278b63          	beq	a5,s2,8000296e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000295c:	8526                	mv	a0,s1
    8000295e:	b5efe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002962:	17048493          	addi	s1,s1,368
    80002966:	ff3495e3          	bne	s1,s3,80002950 <kkill+0x20>
  }
  return -1;
    8000296a:	557d                	li	a0,-1
    8000296c:	a819                	j	80002982 <kkill+0x52>
      p->killed = 1;
    8000296e:	4785                	li	a5,1
    80002970:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002972:	4c98                	lw	a4,24(s1)
    80002974:	4789                	li	a5,2
    80002976:	00f70d63          	beq	a4,a5,80002990 <kkill+0x60>
      release(&p->lock);
    8000297a:	8526                	mv	a0,s1
    8000297c:	b40fe0ef          	jal	80000cbc <release>
      return 0;
    80002980:	4501                	li	a0,0
}
    80002982:	70a2                	ld	ra,40(sp)
    80002984:	7402                	ld	s0,32(sp)
    80002986:	64e2                	ld	s1,24(sp)
    80002988:	6942                	ld	s2,16(sp)
    8000298a:	69a2                	ld	s3,8(sp)
    8000298c:	6145                	addi	sp,sp,48
    8000298e:	8082                	ret
        p->state = RUNNABLE;
    80002990:	478d                	li	a5,3
    80002992:	cc9c                	sw	a5,24(s1)
    80002994:	b7dd                	j	8000297a <kkill+0x4a>

0000000080002996 <setkilled>:

void
setkilled(struct proc *p)
{
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	1000                	addi	s0,sp,32
    800029a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800029a2:	a86fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800029a6:	4785                	li	a5,1
    800029a8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800029aa:	8526                	mv	a0,s1
    800029ac:	b10fe0ef          	jal	80000cbc <release>
}
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <killed>:

int
killed(struct proc *p)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	e04a                	sd	s2,0(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800029c8:	a60fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800029cc:	549c                	lw	a5,40(s1)
    800029ce:	893e                	mv	s2,a5
  release(&p->lock);
    800029d0:	8526                	mv	a0,s1
    800029d2:	aeafe0ef          	jal	80000cbc <release>
  return k;
}
    800029d6:	854a                	mv	a0,s2
    800029d8:	60e2                	ld	ra,24(sp)
    800029da:	6442                	ld	s0,16(sp)
    800029dc:	64a2                	ld	s1,8(sp)
    800029de:	6902                	ld	s2,0(sp)
    800029e0:	6105                	addi	sp,sp,32
    800029e2:	8082                	ret

00000000800029e4 <kwait>:
{
    800029e4:	715d                	addi	sp,sp,-80
    800029e6:	e486                	sd	ra,72(sp)
    800029e8:	e0a2                	sd	s0,64(sp)
    800029ea:	fc26                	sd	s1,56(sp)
    800029ec:	f84a                	sd	s2,48(sp)
    800029ee:	f44e                	sd	s3,40(sp)
    800029f0:	f052                	sd	s4,32(sp)
    800029f2:	ec56                	sd	s5,24(sp)
    800029f4:	e85a                	sd	s6,16(sp)
    800029f6:	e45e                	sd	s7,8(sp)
    800029f8:	0880                	addi	s0,sp,80
    800029fa:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800029fc:	8baff0ef          	jal	80001ab6 <myproc>
    80002a00:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a02:	00011517          	auipc	a0,0x11
    80002a06:	12e50513          	addi	a0,a0,302 # 80013b30 <wait_lock>
    80002a0a:	a1efe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002a0e:	4a15                	li	s4,5
        havekids = 1;
    80002a10:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a12:	00017997          	auipc	s3,0x17
    80002a16:	13698993          	addi	s3,s3,310 # 80019b48 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a1a:	00011b17          	auipc	s6,0x11
    80002a1e:	116b0b13          	addi	s6,s6,278 # 80013b30 <wait_lock>
    80002a22:	a869                	j	80002abc <kwait+0xd8>
          pid = pp->pid;
    80002a24:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a28:	000b8c63          	beqz	s7,80002a40 <kwait+0x5c>
    80002a2c:	4691                	li	a3,4
    80002a2e:	02c48613          	addi	a2,s1,44
    80002a32:	85de                	mv	a1,s7
    80002a34:	05893503          	ld	a0,88(s2)
    80002a38:	c1dfe0ef          	jal	80001654 <copyout>
    80002a3c:	02054a63          	bltz	a0,80002a70 <kwait+0x8c>
          freeproc(pp);
    80002a40:	8526                	mv	a0,s1
    80002a42:	a4aff0ef          	jal	80001c8c <freeproc>
          release(&pp->lock);
    80002a46:	8526                	mv	a0,s1
    80002a48:	a74fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002a4c:	00011517          	auipc	a0,0x11
    80002a50:	0e450513          	addi	a0,a0,228 # 80013b30 <wait_lock>
    80002a54:	a68fe0ef          	jal	80000cbc <release>
}
    80002a58:	854e                	mv	a0,s3
    80002a5a:	60a6                	ld	ra,72(sp)
    80002a5c:	6406                	ld	s0,64(sp)
    80002a5e:	74e2                	ld	s1,56(sp)
    80002a60:	7942                	ld	s2,48(sp)
    80002a62:	79a2                	ld	s3,40(sp)
    80002a64:	7a02                	ld	s4,32(sp)
    80002a66:	6ae2                	ld	s5,24(sp)
    80002a68:	6b42                	ld	s6,16(sp)
    80002a6a:	6ba2                	ld	s7,8(sp)
    80002a6c:	6161                	addi	sp,sp,80
    80002a6e:	8082                	ret
            release(&pp->lock);
    80002a70:	8526                	mv	a0,s1
    80002a72:	a4afe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002a76:	00011517          	auipc	a0,0x11
    80002a7a:	0ba50513          	addi	a0,a0,186 # 80013b30 <wait_lock>
    80002a7e:	a3efe0ef          	jal	80000cbc <release>
            return -1;
    80002a82:	59fd                	li	s3,-1
    80002a84:	bfd1                	j	80002a58 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a86:	17048493          	addi	s1,s1,368
    80002a8a:	03348063          	beq	s1,s3,80002aaa <kwait+0xc6>
      if(pp->parent == p){
    80002a8e:	60bc                	ld	a5,64(s1)
    80002a90:	ff279be3          	bne	a5,s2,80002a86 <kwait+0xa2>
        acquire(&pp->lock);
    80002a94:	8526                	mv	a0,s1
    80002a96:	992fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002a9a:	4c9c                	lw	a5,24(s1)
    80002a9c:	f94784e3          	beq	a5,s4,80002a24 <kwait+0x40>
        release(&pp->lock);
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	a1afe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002aa6:	8756                	mv	a4,s5
    80002aa8:	bff9                	j	80002a86 <kwait+0xa2>
    if(!havekids || killed(p)){
    80002aaa:	cf19                	beqz	a4,80002ac8 <kwait+0xe4>
    80002aac:	854a                	mv	a0,s2
    80002aae:	f0dff0ef          	jal	800029ba <killed>
    80002ab2:	e919                	bnez	a0,80002ac8 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002ab4:	85da                	mv	a1,s6
    80002ab6:	854a                	mv	a0,s2
    80002ab8:	cc7ff0ef          	jal	8000277e <sleep>
    havekids = 0;
    80002abc:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002abe:	00011497          	auipc	s1,0x11
    80002ac2:	48a48493          	addi	s1,s1,1162 # 80013f48 <proc>
    80002ac6:	b7e1                	j	80002a8e <kwait+0xaa>
      release(&wait_lock);
    80002ac8:	00011517          	auipc	a0,0x11
    80002acc:	06850513          	addi	a0,a0,104 # 80013b30 <wait_lock>
    80002ad0:	9ecfe0ef          	jal	80000cbc <release>
      return -1;
    80002ad4:	59fd                	li	s3,-1
    80002ad6:	b749                	j	80002a58 <kwait+0x74>

0000000080002ad8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002ad8:	7179                	addi	sp,sp,-48
    80002ada:	f406                	sd	ra,40(sp)
    80002adc:	f022                	sd	s0,32(sp)
    80002ade:	ec26                	sd	s1,24(sp)
    80002ae0:	e84a                	sd	s2,16(sp)
    80002ae2:	e44e                	sd	s3,8(sp)
    80002ae4:	e052                	sd	s4,0(sp)
    80002ae6:	1800                	addi	s0,sp,48
    80002ae8:	84aa                	mv	s1,a0
    80002aea:	8a2e                	mv	s4,a1
    80002aec:	89b2                	mv	s3,a2
    80002aee:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002af0:	fc7fe0ef          	jal	80001ab6 <myproc>
  if(user_dst){
    80002af4:	cc99                	beqz	s1,80002b12 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002af6:	86ca                	mv	a3,s2
    80002af8:	864e                	mv	a2,s3
    80002afa:	85d2                	mv	a1,s4
    80002afc:	6d28                	ld	a0,88(a0)
    80002afe:	b57fe0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6a02                	ld	s4,0(sp)
    80002b0e:	6145                	addi	sp,sp,48
    80002b10:	8082                	ret
    memmove((char *)dst, src, len);
    80002b12:	0009061b          	sext.w	a2,s2
    80002b16:	85ce                	mv	a1,s3
    80002b18:	8552                	mv	a0,s4
    80002b1a:	a3efe0ef          	jal	80000d58 <memmove>
    return 0;
    80002b1e:	8526                	mv	a0,s1
    80002b20:	b7cd                	j	80002b02 <either_copyout+0x2a>

0000000080002b22 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b22:	7179                	addi	sp,sp,-48
    80002b24:	f406                	sd	ra,40(sp)
    80002b26:	f022                	sd	s0,32(sp)
    80002b28:	ec26                	sd	s1,24(sp)
    80002b2a:	e84a                	sd	s2,16(sp)
    80002b2c:	e44e                	sd	s3,8(sp)
    80002b2e:	e052                	sd	s4,0(sp)
    80002b30:	1800                	addi	s0,sp,48
    80002b32:	8a2a                	mv	s4,a0
    80002b34:	84ae                	mv	s1,a1
    80002b36:	89b2                	mv	s3,a2
    80002b38:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002b3a:	f7dfe0ef          	jal	80001ab6 <myproc>
  if(user_src){
    80002b3e:	cc99                	beqz	s1,80002b5c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002b40:	86ca                	mv	a3,s2
    80002b42:	864e                	mv	a2,s3
    80002b44:	85d2                	mv	a1,s4
    80002b46:	6d28                	ld	a0,88(a0)
    80002b48:	bcbfe0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b4c:	70a2                	ld	ra,40(sp)
    80002b4e:	7402                	ld	s0,32(sp)
    80002b50:	64e2                	ld	s1,24(sp)
    80002b52:	6942                	ld	s2,16(sp)
    80002b54:	69a2                	ld	s3,8(sp)
    80002b56:	6a02                	ld	s4,0(sp)
    80002b58:	6145                	addi	sp,sp,48
    80002b5a:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b5c:	0009061b          	sext.w	a2,s2
    80002b60:	85ce                	mv	a1,s3
    80002b62:	8552                	mv	a0,s4
    80002b64:	9f4fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002b68:	8526                	mv	a0,s1
    80002b6a:	b7cd                	j	80002b4c <either_copyin+0x2a>

0000000080002b6c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b6c:	715d                	addi	sp,sp,-80
    80002b6e:	e486                	sd	ra,72(sp)
    80002b70:	e0a2                	sd	s0,64(sp)
    80002b72:	fc26                	sd	s1,56(sp)
    80002b74:	f84a                	sd	s2,48(sp)
    80002b76:	f44e                	sd	s3,40(sp)
    80002b78:	f052                	sd	s4,32(sp)
    80002b7a:	ec56                	sd	s5,24(sp)
    80002b7c:	e85a                	sd	s6,16(sp)
    80002b7e:	e45e                	sd	s7,8(sp)
    80002b80:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b82:	00005517          	auipc	a0,0x5
    80002b86:	4f650513          	addi	a0,a0,1270 # 80008078 <etext+0x78>
    80002b8a:	971fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b8e:	00011497          	auipc	s1,0x11
    80002b92:	51a48493          	addi	s1,s1,1306 # 800140a8 <proc+0x160>
    80002b96:	00017917          	auipc	s2,0x17
    80002b9a:	11290913          	addi	s2,s2,274 # 80019ca8 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b9e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002ba0:	00006997          	auipc	s3,0x6
    80002ba4:	97898993          	addi	s3,s3,-1672 # 80008518 <etext+0x518>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002ba8:	00006a97          	auipc	s5,0x6
    80002bac:	978a8a93          	addi	s5,s5,-1672 # 80008520 <etext+0x520>
    printf("\n");
    80002bb0:	00005a17          	auipc	s4,0x5
    80002bb4:	4c8a0a13          	addi	s4,s4,1224 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bb8:	00006b97          	auipc	s7,0x6
    80002bbc:	ff8b8b93          	addi	s7,s7,-8 # 80008bb0 <states.1>
    80002bc0:	a839                	j	80002bde <procdump+0x72>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002bc2:	ed86a703          	lw	a4,-296(a3)
    80002bc6:	ed06a583          	lw	a1,-304(a3)
    80002bca:	8556                	mv	a0,s5
    80002bcc:	92ffd0ef          	jal	800004fa <printf>
    printf("\n");
    80002bd0:	8552                	mv	a0,s4
    80002bd2:	929fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bd6:	17048493          	addi	s1,s1,368
    80002bda:	03248263          	beq	s1,s2,80002bfe <procdump+0x92>
    if(p->state == UNUSED)
    80002bde:	86a6                	mv	a3,s1
    80002be0:	eb84a783          	lw	a5,-328(s1)
    80002be4:	dbed                	beqz	a5,80002bd6 <procdump+0x6a>
      state = "???";
    80002be6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002be8:	fcfb6de3          	bltu	s6,a5,80002bc2 <procdump+0x56>
    80002bec:	02079713          	slli	a4,a5,0x20
    80002bf0:	01d75793          	srli	a5,a4,0x1d
    80002bf4:	97de                	add	a5,a5,s7
    80002bf6:	6390                	ld	a2,0(a5)
    80002bf8:	f669                	bnez	a2,80002bc2 <procdump+0x56>
      state = "???";
    80002bfa:	864e                	mv	a2,s3
    80002bfc:	b7d9                	j	80002bc2 <procdump+0x56>
  }
}
    80002bfe:	60a6                	ld	ra,72(sp)
    80002c00:	6406                	ld	s0,64(sp)
    80002c02:	74e2                	ld	s1,56(sp)
    80002c04:	7942                	ld	s2,48(sp)
    80002c06:	79a2                	ld	s3,40(sp)
    80002c08:	7a02                	ld	s4,32(sp)
    80002c0a:	6ae2                	ld	s5,24(sp)
    80002c0c:	6b42                	ld	s6,16(sp)
    80002c0e:	6ba2                	ld	s7,8(sp)
    80002c10:	6161                	addi	sp,sp,80
    80002c12:	8082                	ret

0000000080002c14 <kps>:


int
kps(char *arguments)
{
    80002c14:	7179                	addi	sp,sp,-48
    80002c16:	f406                	sd	ra,40(sp)
    80002c18:	f022                	sd	s0,32(sp)
    80002c1a:	ec26                	sd	s1,24(sp)
    80002c1c:	1800                	addi	s0,sp,48
    80002c1e:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    80002c20:	4609                	li	a2,2
    80002c22:	00006597          	auipc	a1,0x6
    80002c26:	91658593          	addi	a1,a1,-1770 # 80008538 <etext+0x538>
    80002c2a:	9a2fe0ef          	jal	80000dcc <strncmp>
    80002c2e:	e931                	bnez	a0,80002c82 <kps+0x6e>
    80002c30:	e84a                	sd	s2,16(sp)
    80002c32:	e44e                	sd	s3,8(sp)
    80002c34:	00011497          	auipc	s1,0x11
    80002c38:	47448493          	addi	s1,s1,1140 # 800140a8 <proc+0x160>
    80002c3c:	00017917          	auipc	s2,0x17
    80002c40:	06c90913          	addi	s2,s2,108 # 80019ca8 <bcache+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    80002c44:	00006997          	auipc	s3,0x6
    80002c48:	8fc98993          	addi	s3,s3,-1796 # 80008540 <etext+0x540>
    80002c4c:	a029                	j	80002c56 <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    80002c4e:	17048493          	addi	s1,s1,368
    80002c52:	01248a63          	beq	s1,s2,80002c66 <kps+0x52>
      if (p->state != UNUSED){
    80002c56:	eb84a783          	lw	a5,-328(s1)
    80002c5a:	dbf5                	beqz	a5,80002c4e <kps+0x3a>
        printf("%s ", p->name);
    80002c5c:	85a6                	mv	a1,s1
    80002c5e:	854e                	mv	a0,s3
    80002c60:	89bfd0ef          	jal	800004fa <printf>
    80002c64:	b7ed                	j	80002c4e <kps+0x3a>
      }
    }
    printf("\n");
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	41250513          	addi	a0,a0,1042 # 80008078 <etext+0x78>
    80002c6e:	88dfd0ef          	jal	800004fa <printf>
    80002c72:	6942                	ld	s2,16(sp)
    80002c74:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l | -t]\n");
  }

  return 0;

    80002c76:	4501                	li	a0,0
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6145                	addi	sp,sp,48
    80002c80:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    80002c82:	4609                	li	a2,2
    80002c84:	00006597          	auipc	a1,0x6
    80002c88:	8c458593          	addi	a1,a1,-1852 # 80008548 <etext+0x548>
    80002c8c:	8526                	mv	a0,s1
    80002c8e:	93efe0ef          	jal	80000dcc <strncmp>
    80002c92:	e92d                	bnez	a0,80002d04 <kps+0xf0>
    80002c94:	e84a                	sd	s2,16(sp)
    80002c96:	e44e                	sd	s3,8(sp)
    80002c98:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    80002c9a:	00006517          	auipc	a0,0x6
    80002c9e:	8b650513          	addi	a0,a0,-1866 # 80008550 <etext+0x550>
    80002ca2:	859fd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    80002ca6:	00006517          	auipc	a0,0x6
    80002caa:	96a50513          	addi	a0,a0,-1686 # 80008610 <etext+0x610>
    80002cae:	84dfd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002cb2:	00011497          	auipc	s1,0x11
    80002cb6:	3f648493          	addi	s1,s1,1014 # 800140a8 <proc+0x160>
    80002cba:	00017917          	auipc	s2,0x17
    80002cbe:	fee90913          	addi	s2,s2,-18 # 80019ca8 <bcache+0x148>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002cc2:	00006a17          	auipc	s4,0x6
    80002cc6:	eeea0a13          	addi	s4,s4,-274 # 80008bb0 <states.1>
    80002cca:	00006997          	auipc	s3,0x6
    80002cce:	89e98993          	addi	s3,s3,-1890 # 80008568 <etext+0x568>
    80002cd2:	a029                	j	80002cdc <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    80002cd4:	17048493          	addi	s1,s1,368
    80002cd8:	03248263          	beq	s1,s2,80002cfc <kps+0xe8>
      if (p->state != UNUSED){
    80002cdc:	eb84a783          	lw	a5,-328(s1)
    80002ce0:	dbf5                	beqz	a5,80002cd4 <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002ce2:	02079713          	slli	a4,a5,0x20
    80002ce6:	01d75793          	srli	a5,a4,0x1d
    80002cea:	97d2                	add	a5,a5,s4
    80002cec:	86a6                	mv	a3,s1
    80002cee:	7b90                	ld	a2,48(a5)
    80002cf0:	ed04a583          	lw	a1,-304(s1)
    80002cf4:	854e                	mv	a0,s3
    80002cf6:	805fd0ef          	jal	800004fa <printf>
    80002cfa:	bfe9                	j	80002cd4 <kps+0xc0>
    80002cfc:	6942                	ld	s2,16(sp)
    80002cfe:	69a2                	ld	s3,8(sp)
    80002d00:	6a02                	ld	s4,0(sp)
    80002d02:	bf95                	j	80002c76 <kps+0x62>
  }else if(strncmp(arguments, "-t", 2)==0){
    80002d04:	4609                	li	a2,2
    80002d06:	00006597          	auipc	a1,0x6
    80002d0a:	87258593          	addi	a1,a1,-1934 # 80008578 <etext+0x578>
    80002d0e:	8526                	mv	a0,s1
    80002d10:	8bcfe0ef          	jal	80000dcc <strncmp>
    80002d14:	e969                	bnez	a0,80002de6 <kps+0x1d2>
    80002d16:	e84a                	sd	s2,16(sp)
    80002d18:	e44e                	sd	s3,8(sp)
    80002d1a:	e052                	sd	s4,0(sp)
    printf("===== Thermal Monitor =====\n");
    80002d1c:	00006517          	auipc	a0,0x6
    80002d20:	86450513          	addi	a0,a0,-1948 # 80008580 <etext+0x580>
    80002d24:	fd6fd0ef          	jal	800004fa <printf>
    printf("CPU Temperature: %d / 100", cpu_temp);
    80002d28:	00009497          	auipc	s1,0x9
    80002d2c:	b0048493          	addi	s1,s1,-1280 # 8000b828 <cpu_temp>
    80002d30:	408c                	lw	a1,0(s1)
    80002d32:	00006517          	auipc	a0,0x6
    80002d36:	86e50513          	addi	a0,a0,-1938 # 800085a0 <etext+0x5a0>
    80002d3a:	fc0fd0ef          	jal	800004fa <printf>
    if(cpu_temp >= 80)
    80002d3e:	409c                	lw	a5,0(s1)
    80002d40:	04f00713          	li	a4,79
    80002d44:	04f74963          	blt	a4,a5,80002d96 <kps+0x182>
    else if(cpu_temp >= 60)
    80002d48:	03b00713          	li	a4,59
    80002d4c:	04f75c63          	bge	a4,a5,80002da4 <kps+0x190>
      printf("  [WARM]\n");
    80002d50:	00006517          	auipc	a0,0x6
    80002d54:	88050513          	addi	a0,a0,-1920 # 800085d0 <etext+0x5d0>
    80002d58:	fa2fd0ef          	jal	800004fa <printf>
    printf("\nPID\tSTATE\t\tHEAT\tNAME\n");
    80002d5c:	00006517          	auipc	a0,0x6
    80002d60:	89450513          	addi	a0,a0,-1900 # 800085f0 <etext+0x5f0>
    80002d64:	f96fd0ef          	jal	800004fa <printf>
    printf("---------------------------------------\n");
    80002d68:	00006517          	auipc	a0,0x6
    80002d6c:	8a050513          	addi	a0,a0,-1888 # 80008608 <etext+0x608>
    80002d70:	f8afd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002d74:	00011497          	auipc	s1,0x11
    80002d78:	33448493          	addi	s1,s1,820 # 800140a8 <proc+0x160>
    80002d7c:	00017917          	auipc	s2,0x17
    80002d80:	f2c90913          	addi	s2,s2,-212 # 80019ca8 <bcache+0x148>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002d84:	00006a17          	auipc	s4,0x6
    80002d88:	e2ca0a13          	addi	s4,s4,-468 # 80008bb0 <states.1>
    80002d8c:	00006997          	auipc	s3,0x6
    80002d90:	8ac98993          	addi	s3,s3,-1876 # 80008638 <etext+0x638>
    80002d94:	a01d                	j	80002dba <kps+0x1a6>
      printf("  [HOT]\n");
    80002d96:	00006517          	auipc	a0,0x6
    80002d9a:	82a50513          	addi	a0,a0,-2006 # 800085c0 <etext+0x5c0>
    80002d9e:	f5cfd0ef          	jal	800004fa <printf>
    80002da2:	bf6d                	j	80002d5c <kps+0x148>
      printf("  [COOL]\n");
    80002da4:	00006517          	auipc	a0,0x6
    80002da8:	83c50513          	addi	a0,a0,-1988 # 800085e0 <etext+0x5e0>
    80002dac:	f4efd0ef          	jal	800004fa <printf>
    80002db0:	b775                	j	80002d5c <kps+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
    80002db2:	17048493          	addi	s1,s1,368
    80002db6:	03248463          	beq	s1,s2,80002dde <kps+0x1ca>
      if (p->state != UNUSED){
    80002dba:	eb84a783          	lw	a5,-328(s1)
    80002dbe:	dbf5                	beqz	a5,80002db2 <kps+0x19e>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002dc0:	02079713          	slli	a4,a5,0x20
    80002dc4:	01d75793          	srli	a5,a4,0x1d
    80002dc8:	97d2                	add	a5,a5,s4
    80002dca:	8726                	mv	a4,s1
    80002dcc:	ed84a683          	lw	a3,-296(s1)
    80002dd0:	7b90                	ld	a2,48(a5)
    80002dd2:	ed04a583          	lw	a1,-304(s1)
    80002dd6:	854e                	mv	a0,s3
    80002dd8:	f22fd0ef          	jal	800004fa <printf>
    80002ddc:	bfd9                	j	80002db2 <kps+0x19e>
    80002dde:	6942                	ld	s2,16(sp)
    80002de0:	69a2                	ld	s3,8(sp)
    80002de2:	6a02                	ld	s4,0(sp)
    80002de4:	bd49                	j	80002c76 <kps+0x62>
    printf("Usage: ps [-o | -l | -t]\n");
    80002de6:	00006517          	auipc	a0,0x6
    80002dea:	86250513          	addi	a0,a0,-1950 # 80008648 <etext+0x648>
    80002dee:	f0cfd0ef          	jal	800004fa <printf>
    80002df2:	b551                	j	80002c76 <kps+0x62>

0000000080002df4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002df4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002df8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002dfc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002dfe:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002e00:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002e04:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002e08:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002e0c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002e10:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002e14:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002e18:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002e1c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002e20:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002e24:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002e28:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002e2c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002e30:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002e32:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002e34:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002e38:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002e3c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002e40:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002e44:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002e48:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002e4c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002e50:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002e54:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002e58:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002e5c:	8082                	ret

0000000080002e5e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e5e:	1141                	addi	sp,sp,-16
    80002e60:	e406                	sd	ra,8(sp)
    80002e62:	e022                	sd	s0,0(sp)
    80002e64:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e66:	00006597          	auipc	a1,0x6
    80002e6a:	87258593          	addi	a1,a1,-1934 # 800086d8 <etext+0x6d8>
    80002e6e:	00017517          	auipc	a0,0x17
    80002e72:	cda50513          	addi	a0,a0,-806 # 80019b48 <tickslock>
    80002e76:	d29fd0ef          	jal	80000b9e <initlock>
}
    80002e7a:	60a2                	ld	ra,8(sp)
    80002e7c:	6402                	ld	s0,0(sp)
    80002e7e:	0141                	addi	sp,sp,16
    80002e80:	8082                	ret

0000000080002e82 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002e82:	1141                	addi	sp,sp,-16
    80002e84:	e406                	sd	ra,8(sp)
    80002e86:	e022                	sd	s0,0(sp)
    80002e88:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e8a:	00003797          	auipc	a5,0x3
    80002e8e:	03678793          	addi	a5,a5,54 # 80005ec0 <kernelvec>
    80002e92:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002e96:	60a2                	ld	ra,8(sp)
    80002e98:	6402                	ld	s0,0(sp)
    80002e9a:	0141                	addi	sp,sp,16
    80002e9c:	8082                	ret

0000000080002e9e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002e9e:	1141                	addi	sp,sp,-16
    80002ea0:	e406                	sd	ra,8(sp)
    80002ea2:	e022                	sd	s0,0(sp)
    80002ea4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ea6:	c11fe0ef          	jal	80001ab6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eaa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002eae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eb0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002eb4:	04000737          	lui	a4,0x4000
    80002eb8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002eba:	0732                	slli	a4,a4,0xc
    80002ebc:	00004797          	auipc	a5,0x4
    80002ec0:	14478793          	addi	a5,a5,324 # 80007000 <_trampoline>
    80002ec4:	00004697          	auipc	a3,0x4
    80002ec8:	13c68693          	addi	a3,a3,316 # 80007000 <_trampoline>
    80002ecc:	8f95                	sub	a5,a5,a3
    80002ece:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ed0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ed4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ed6:	18002773          	csrr	a4,satp
    80002eda:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002edc:	7138                	ld	a4,96(a0)
    80002ede:	653c                	ld	a5,72(a0)
    80002ee0:	6685                	lui	a3,0x1
    80002ee2:	97b6                	add	a5,a5,a3
    80002ee4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ee6:	713c                	ld	a5,96(a0)
    80002ee8:	00000717          	auipc	a4,0x0
    80002eec:	11c70713          	addi	a4,a4,284 # 80003004 <usertrap>
    80002ef0:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ef2:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ef4:	8712                	mv	a4,tp
    80002ef6:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ef8:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002efc:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f00:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f04:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f08:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f0a:	6f9c                	ld	a5,24(a5)
    80002f0c:	14179073          	csrw	sepc,a5
}
    80002f10:	60a2                	ld	ra,8(sp)
    80002f12:	6402                	ld	s0,0(sp)
    80002f14:	0141                	addi	sp,sp,16
    80002f16:	8082                	ret

0000000080002f18 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002f18:	1141                	addi	sp,sp,-16
    80002f1a:	e406                	sd	ra,8(sp)
    80002f1c:	e022                	sd	s0,0(sp)
    80002f1e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002f20:	b63fe0ef          	jal	80001a82 <cpuid>
    80002f24:	c915                	beqz	a0,80002f58 <clockintr+0x40>
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  if (myproc() != 0 && myproc()->state == RUNNING) {
    80002f26:	b91fe0ef          	jal	80001ab6 <myproc>
    80002f2a:	c519                	beqz	a0,80002f38 <clockintr+0x20>
    80002f2c:	b8bfe0ef          	jal	80001ab6 <myproc>
    80002f30:	4d18                	lw	a4,24(a0)
    80002f32:	4791                	li	a5,4
    80002f34:	04f70963          	beq	a4,a5,80002f86 <clockintr+0x6e>
    update_cpu_temp(1);   // CPU is active
  } else {
    update_cpu_temp(0);   // CPU is idle
    80002f38:	4501                	li	a0,0
    80002f3a:	971fe0ef          	jal	800018aa <update_cpu_temp>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002f3e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002f42:	000f4737          	lui	a4,0xf4
    80002f46:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002f4a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002f4c:	14d79073          	csrw	stimecmp,a5
}
    80002f50:	60a2                	ld	ra,8(sp)
    80002f52:	6402                	ld	s0,0(sp)
    80002f54:	0141                	addi	sp,sp,16
    80002f56:	8082                	ret
    acquire(&tickslock);
    80002f58:	00017517          	auipc	a0,0x17
    80002f5c:	bf050513          	addi	a0,a0,-1040 # 80019b48 <tickslock>
    80002f60:	cc9fd0ef          	jal	80000c28 <acquire>
    ticks++;
    80002f64:	00009717          	auipc	a4,0x9
    80002f68:	93470713          	addi	a4,a4,-1740 # 8000b898 <ticks>
    80002f6c:	431c                	lw	a5,0(a4)
    80002f6e:	2785                	addiw	a5,a5,1
    80002f70:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002f72:	853a                	mv	a0,a4
    80002f74:	857ff0ef          	jal	800027ca <wakeup>
    release(&tickslock);
    80002f78:	00017517          	auipc	a0,0x17
    80002f7c:	bd050513          	addi	a0,a0,-1072 # 80019b48 <tickslock>
    80002f80:	d3dfd0ef          	jal	80000cbc <release>
    80002f84:	b74d                	j	80002f26 <clockintr+0xe>
    update_cpu_temp(1);   // CPU is active
    80002f86:	4505                	li	a0,1
    80002f88:	923fe0ef          	jal	800018aa <update_cpu_temp>
    80002f8c:	bf4d                	j	80002f3e <clockintr+0x26>

0000000080002f8e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002f8e:	1101                	addi	sp,sp,-32
    80002f90:	ec06                	sd	ra,24(sp)
    80002f92:	e822                	sd	s0,16(sp)
    80002f94:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f96:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002f9a:	57fd                	li	a5,-1
    80002f9c:	17fe                	slli	a5,a5,0x3f
    80002f9e:	07a5                	addi	a5,a5,9
    80002fa0:	00f70c63          	beq	a4,a5,80002fb8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002fa4:	57fd                	li	a5,-1
    80002fa6:	17fe                	slli	a5,a5,0x3f
    80002fa8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002faa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002fac:	04f70863          	beq	a4,a5,80002ffc <devintr+0x6e>
  }
}
    80002fb0:	60e2                	ld	ra,24(sp)
    80002fb2:	6442                	ld	s0,16(sp)
    80002fb4:	6105                	addi	sp,sp,32
    80002fb6:	8082                	ret
    80002fb8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002fba:	7b3020ef          	jal	80005f6c <plic_claim>
    80002fbe:	872a                	mv	a4,a0
    80002fc0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002fc2:	47a9                	li	a5,10
    80002fc4:	00f50963          	beq	a0,a5,80002fd6 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002fc8:	4785                	li	a5,1
    80002fca:	00f50963          	beq	a0,a5,80002fdc <devintr+0x4e>
    return 1;
    80002fce:	4505                	li	a0,1
    } else if(irq){
    80002fd0:	eb09                	bnez	a4,80002fe2 <devintr+0x54>
    80002fd2:	64a2                	ld	s1,8(sp)
    80002fd4:	bff1                	j	80002fb0 <devintr+0x22>
      uartintr();
    80002fd6:	a1ffd0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002fda:	a819                	j	80002ff0 <devintr+0x62>
      virtio_disk_intr();
    80002fdc:	426030ef          	jal	80006402 <virtio_disk_intr>
    if(irq)
    80002fe0:	a801                	j	80002ff0 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002fe2:	85ba                	mv	a1,a4
    80002fe4:	00005517          	auipc	a0,0x5
    80002fe8:	6fc50513          	addi	a0,a0,1788 # 800086e0 <etext+0x6e0>
    80002fec:	d0efd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002ff0:	8526                	mv	a0,s1
    80002ff2:	79b020ef          	jal	80005f8c <plic_complete>
    return 1;
    80002ff6:	4505                	li	a0,1
    80002ff8:	64a2                	ld	s1,8(sp)
    80002ffa:	bf5d                	j	80002fb0 <devintr+0x22>
    clockintr();
    80002ffc:	f1dff0ef          	jal	80002f18 <clockintr>
    return 2;
    80003000:	4509                	li	a0,2
    80003002:	b77d                	j	80002fb0 <devintr+0x22>

0000000080003004 <usertrap>:
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	e04a                	sd	s2,0(sp)
    8000300e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003010:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003014:	1007f793          	andi	a5,a5,256
    80003018:	eba5                	bnez	a5,80003088 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000301a:	00003797          	auipc	a5,0x3
    8000301e:	ea678793          	addi	a5,a5,-346 # 80005ec0 <kernelvec>
    80003022:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003026:	a91fe0ef          	jal	80001ab6 <myproc>
    8000302a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000302c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000302e:	14102773          	csrr	a4,sepc
    80003032:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003034:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003038:	47a1                	li	a5,8
    8000303a:	04f70d63          	beq	a4,a5,80003094 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000303e:	f51ff0ef          	jal	80002f8e <devintr>
    80003042:	892a                	mv	s2,a0
    80003044:	e945                	bnez	a0,800030f4 <usertrap+0xf0>
    80003046:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000304a:	47bd                	li	a5,15
    8000304c:	08f70863          	beq	a4,a5,800030dc <usertrap+0xd8>
    80003050:	14202773          	csrr	a4,scause
    80003054:	47b5                	li	a5,13
    80003056:	08f70363          	beq	a4,a5,800030dc <usertrap+0xd8>
    8000305a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000305e:	5890                	lw	a2,48(s1)
    80003060:	00005517          	auipc	a0,0x5
    80003064:	6c050513          	addi	a0,a0,1728 # 80008720 <etext+0x720>
    80003068:	c92fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000306c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003070:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003074:	00005517          	auipc	a0,0x5
    80003078:	6dc50513          	addi	a0,a0,1756 # 80008750 <etext+0x750>
    8000307c:	c7efd0ef          	jal	800004fa <printf>
    setkilled(p);
    80003080:	8526                	mv	a0,s1
    80003082:	915ff0ef          	jal	80002996 <setkilled>
    80003086:	a035                	j	800030b2 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80003088:	00005517          	auipc	a0,0x5
    8000308c:	67850513          	addi	a0,a0,1656 # 80008700 <etext+0x700>
    80003090:	f94fd0ef          	jal	80000824 <panic>
    if(killed(p))
    80003094:	927ff0ef          	jal	800029ba <killed>
    80003098:	ed15                	bnez	a0,800030d4 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000309a:	70b8                	ld	a4,96(s1)
    8000309c:	6f1c                	ld	a5,24(a4)
    8000309e:	0791                	addi	a5,a5,4
    800030a0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800030a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030aa:	10079073          	csrw	sstatus,a5
    syscall();
    800030ae:	240000ef          	jal	800032ee <syscall>
  if(killed(p))
    800030b2:	8526                	mv	a0,s1
    800030b4:	907ff0ef          	jal	800029ba <killed>
    800030b8:	e139                	bnez	a0,800030fe <usertrap+0xfa>
  prepare_return();
    800030ba:	de5ff0ef          	jal	80002e9e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800030be:	6ca8                	ld	a0,88(s1)
    800030c0:	8131                	srli	a0,a0,0xc
    800030c2:	57fd                	li	a5,-1
    800030c4:	17fe                	slli	a5,a5,0x3f
    800030c6:	8d5d                	or	a0,a0,a5
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6902                	ld	s2,0(sp)
    800030d0:	6105                	addi	sp,sp,32
    800030d2:	8082                	ret
      kexit(-1);
    800030d4:	557d                	li	a0,-1
    800030d6:	fb4ff0ef          	jal	8000288a <kexit>
    800030da:	b7c1                	j	8000309a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030dc:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030e0:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800030e4:	164d                	addi	a2,a2,-13
    800030e6:	00163613          	seqz	a2,a2
    800030ea:	6ca8                	ld	a0,88(s1)
    800030ec:	ce4fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800030f0:	f169                	bnez	a0,800030b2 <usertrap+0xae>
    800030f2:	b7a5                	j	8000305a <usertrap+0x56>
  if(killed(p))
    800030f4:	8526                	mv	a0,s1
    800030f6:	8c5ff0ef          	jal	800029ba <killed>
    800030fa:	c511                	beqz	a0,80003106 <usertrap+0x102>
    800030fc:	a011                	j	80003100 <usertrap+0xfc>
    800030fe:	4901                	li	s2,0
    kexit(-1);
    80003100:	557d                	li	a0,-1
    80003102:	f88ff0ef          	jal	8000288a <kexit>
  if(which_dev == 2)
    80003106:	4789                	li	a5,2
    80003108:	faf919e3          	bne	s2,a5,800030ba <usertrap+0xb6>
    yield();
    8000310c:	e46ff0ef          	jal	80002752 <yield>
    80003110:	b76d                	j	800030ba <usertrap+0xb6>

0000000080003112 <kerneltrap>:
{
    80003112:	7179                	addi	sp,sp,-48
    80003114:	f406                	sd	ra,40(sp)
    80003116:	f022                	sd	s0,32(sp)
    80003118:	ec26                	sd	s1,24(sp)
    8000311a:	e84a                	sd	s2,16(sp)
    8000311c:	e44e                	sd	s3,8(sp)
    8000311e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003120:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003124:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003128:	142027f3          	csrr	a5,scause
    8000312c:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000312e:	1004f793          	andi	a5,s1,256
    80003132:	c795                	beqz	a5,8000315e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003134:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003138:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000313a:	eb85                	bnez	a5,8000316a <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    8000313c:	e53ff0ef          	jal	80002f8e <devintr>
    80003140:	c91d                	beqz	a0,80003176 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80003142:	4789                	li	a5,2
    80003144:	04f50a63          	beq	a0,a5,80003198 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003148:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000314c:	10049073          	csrw	sstatus,s1
}
    80003150:	70a2                	ld	ra,40(sp)
    80003152:	7402                	ld	s0,32(sp)
    80003154:	64e2                	ld	s1,24(sp)
    80003156:	6942                	ld	s2,16(sp)
    80003158:	69a2                	ld	s3,8(sp)
    8000315a:	6145                	addi	sp,sp,48
    8000315c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000315e:	00005517          	auipc	a0,0x5
    80003162:	61a50513          	addi	a0,a0,1562 # 80008778 <etext+0x778>
    80003166:	ebefd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000316a:	00005517          	auipc	a0,0x5
    8000316e:	63650513          	addi	a0,a0,1590 # 800087a0 <etext+0x7a0>
    80003172:	eb2fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003176:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000317a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000317e:	85ce                	mv	a1,s3
    80003180:	00005517          	auipc	a0,0x5
    80003184:	64050513          	addi	a0,a0,1600 # 800087c0 <etext+0x7c0>
    80003188:	b72fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	65c50513          	addi	a0,a0,1628 # 800087e8 <etext+0x7e8>
    80003194:	e90fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80003198:	91ffe0ef          	jal	80001ab6 <myproc>
    8000319c:	d555                	beqz	a0,80003148 <kerneltrap+0x36>
    yield();
    8000319e:	db4ff0ef          	jal	80002752 <yield>
    800031a2:	b75d                	j	80003148 <kerneltrap+0x36>

00000000800031a4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	e426                	sd	s1,8(sp)
    800031ac:	1000                	addi	s0,sp,32
    800031ae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031b0:	907fe0ef          	jal	80001ab6 <myproc>
  switch (n) {
    800031b4:	4795                	li	a5,5
    800031b6:	0497e163          	bltu	a5,s1,800031f8 <argraw+0x54>
    800031ba:	048a                	slli	s1,s1,0x2
    800031bc:	00006717          	auipc	a4,0x6
    800031c0:	a5470713          	addi	a4,a4,-1452 # 80008c10 <states.0+0x30>
    800031c4:	94ba                	add	s1,s1,a4
    800031c6:	409c                	lw	a5,0(s1)
    800031c8:	97ba                	add	a5,a5,a4
    800031ca:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800031cc:	713c                	ld	a5,96(a0)
    800031ce:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret
    return p->trapframe->a1;
    800031da:	713c                	ld	a5,96(a0)
    800031dc:	7fa8                	ld	a0,120(a5)
    800031de:	bfcd                	j	800031d0 <argraw+0x2c>
    return p->trapframe->a2;
    800031e0:	713c                	ld	a5,96(a0)
    800031e2:	63c8                	ld	a0,128(a5)
    800031e4:	b7f5                	j	800031d0 <argraw+0x2c>
    return p->trapframe->a3;
    800031e6:	713c                	ld	a5,96(a0)
    800031e8:	67c8                	ld	a0,136(a5)
    800031ea:	b7dd                	j	800031d0 <argraw+0x2c>
    return p->trapframe->a4;
    800031ec:	713c                	ld	a5,96(a0)
    800031ee:	6bc8                	ld	a0,144(a5)
    800031f0:	b7c5                	j	800031d0 <argraw+0x2c>
    return p->trapframe->a5;
    800031f2:	713c                	ld	a5,96(a0)
    800031f4:	6fc8                	ld	a0,152(a5)
    800031f6:	bfe9                	j	800031d0 <argraw+0x2c>
  panic("argraw");
    800031f8:	00005517          	auipc	a0,0x5
    800031fc:	60050513          	addi	a0,a0,1536 # 800087f8 <etext+0x7f8>
    80003200:	e24fd0ef          	jal	80000824 <panic>

0000000080003204 <fetchaddr>:
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	e426                	sd	s1,8(sp)
    8000320c:	e04a                	sd	s2,0(sp)
    8000320e:	1000                	addi	s0,sp,32
    80003210:	84aa                	mv	s1,a0
    80003212:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003214:	8a3fe0ef          	jal	80001ab6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003218:	693c                	ld	a5,80(a0)
    8000321a:	02f4f663          	bgeu	s1,a5,80003246 <fetchaddr+0x42>
    8000321e:	00848713          	addi	a4,s1,8
    80003222:	02e7e463          	bltu	a5,a4,8000324a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003226:	46a1                	li	a3,8
    80003228:	8626                	mv	a2,s1
    8000322a:	85ca                	mv	a1,s2
    8000322c:	6d28                	ld	a0,88(a0)
    8000322e:	ce4fe0ef          	jal	80001712 <copyin>
    80003232:	00a03533          	snez	a0,a0
    80003236:	40a0053b          	negw	a0,a0
}
    8000323a:	60e2                	ld	ra,24(sp)
    8000323c:	6442                	ld	s0,16(sp)
    8000323e:	64a2                	ld	s1,8(sp)
    80003240:	6902                	ld	s2,0(sp)
    80003242:	6105                	addi	sp,sp,32
    80003244:	8082                	ret
    return -1;
    80003246:	557d                	li	a0,-1
    80003248:	bfcd                	j	8000323a <fetchaddr+0x36>
    8000324a:	557d                	li	a0,-1
    8000324c:	b7fd                	j	8000323a <fetchaddr+0x36>

000000008000324e <fetchstr>:
{
    8000324e:	7179                	addi	sp,sp,-48
    80003250:	f406                	sd	ra,40(sp)
    80003252:	f022                	sd	s0,32(sp)
    80003254:	ec26                	sd	s1,24(sp)
    80003256:	e84a                	sd	s2,16(sp)
    80003258:	e44e                	sd	s3,8(sp)
    8000325a:	1800                	addi	s0,sp,48
    8000325c:	89aa                	mv	s3,a0
    8000325e:	84ae                	mv	s1,a1
    80003260:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80003262:	855fe0ef          	jal	80001ab6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003266:	86ca                	mv	a3,s2
    80003268:	864e                	mv	a2,s3
    8000326a:	85a6                	mv	a1,s1
    8000326c:	6d28                	ld	a0,88(a0)
    8000326e:	a8afe0ef          	jal	800014f8 <copyinstr>
    80003272:	00054c63          	bltz	a0,8000328a <fetchstr+0x3c>
  return strlen(buf);
    80003276:	8526                	mv	a0,s1
    80003278:	c0bfd0ef          	jal	80000e82 <strlen>
}
    8000327c:	70a2                	ld	ra,40(sp)
    8000327e:	7402                	ld	s0,32(sp)
    80003280:	64e2                	ld	s1,24(sp)
    80003282:	6942                	ld	s2,16(sp)
    80003284:	69a2                	ld	s3,8(sp)
    80003286:	6145                	addi	sp,sp,48
    80003288:	8082                	ret
    return -1;
    8000328a:	557d                	li	a0,-1
    8000328c:	bfc5                	j	8000327c <fetchstr+0x2e>

000000008000328e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	1000                	addi	s0,sp,32
    80003298:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000329a:	f0bff0ef          	jal	800031a4 <argraw>
    8000329e:	c088                	sw	a0,0(s1)
}
    800032a0:	60e2                	ld	ra,24(sp)
    800032a2:	6442                	ld	s0,16(sp)
    800032a4:	64a2                	ld	s1,8(sp)
    800032a6:	6105                	addi	sp,sp,32
    800032a8:	8082                	ret

00000000800032aa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800032aa:	1101                	addi	sp,sp,-32
    800032ac:	ec06                	sd	ra,24(sp)
    800032ae:	e822                	sd	s0,16(sp)
    800032b0:	e426                	sd	s1,8(sp)
    800032b2:	1000                	addi	s0,sp,32
    800032b4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032b6:	eefff0ef          	jal	800031a4 <argraw>
    800032ba:	e088                	sd	a0,0(s1)
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	64a2                	ld	s1,8(sp)
    800032c2:	6105                	addi	sp,sp,32
    800032c4:	8082                	ret

00000000800032c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032c6:	1101                	addi	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	e04a                	sd	s2,0(sp)
    800032d0:	1000                	addi	s0,sp,32
    800032d2:	892e                	mv	s2,a1
    800032d4:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800032d6:	ecfff0ef          	jal	800031a4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800032da:	8626                	mv	a2,s1
    800032dc:	85ca                	mv	a1,s2
    800032de:	f71ff0ef          	jal	8000324e <fetchstr>
}
    800032e2:	60e2                	ld	ra,24(sp)
    800032e4:	6442                	ld	s0,16(sp)
    800032e6:	64a2                	ld	s1,8(sp)
    800032e8:	6902                	ld	s2,0(sp)
    800032ea:	6105                	addi	sp,sp,32
    800032ec:	8082                	ret

00000000800032ee <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	e426                	sd	s1,8(sp)
    800032f6:	e04a                	sd	s2,0(sp)
    800032f8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800032fa:	fbcfe0ef          	jal	80001ab6 <myproc>
    800032fe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003300:	06053903          	ld	s2,96(a0)
    80003304:	0a893783          	ld	a5,168(s2)
    80003308:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000330c:	37fd                	addiw	a5,a5,-1
    8000330e:	4755                	li	a4,21
    80003310:	00f76f63          	bltu	a4,a5,8000332e <syscall+0x40>
    80003314:	00369713          	slli	a4,a3,0x3
    80003318:	00006797          	auipc	a5,0x6
    8000331c:	91078793          	addi	a5,a5,-1776 # 80008c28 <syscalls>
    80003320:	97ba                	add	a5,a5,a4
    80003322:	639c                	ld	a5,0(a5)
    80003324:	c789                	beqz	a5,8000332e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003326:	9782                	jalr	a5
    80003328:	06a93823          	sd	a0,112(s2)
    8000332c:	a829                	j	80003346 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000332e:	16048613          	addi	a2,s1,352
    80003332:	588c                	lw	a1,48(s1)
    80003334:	00005517          	auipc	a0,0x5
    80003338:	4cc50513          	addi	a0,a0,1228 # 80008800 <etext+0x800>
    8000333c:	9befd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003340:	70bc                	ld	a5,96(s1)
    80003342:	577d                	li	a4,-1
    80003344:	fbb8                	sd	a4,112(a5)
  }
}
    80003346:	60e2                	ld	ra,24(sp)
    80003348:	6442                	ld	s0,16(sp)
    8000334a:	64a2                	ld	s1,8(sp)
    8000334c:	6902                	ld	s2,0(sp)
    8000334e:	6105                	addi	sp,sp,32
    80003350:	8082                	ret

0000000080003352 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80003352:	1101                	addi	sp,sp,-32
    80003354:	ec06                	sd	ra,24(sp)
    80003356:	e822                	sd	s0,16(sp)
    80003358:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000335a:	fec40593          	addi	a1,s0,-20
    8000335e:	4501                	li	a0,0
    80003360:	f2fff0ef          	jal	8000328e <argint>
  kexit(n);
    80003364:	fec42503          	lw	a0,-20(s0)
    80003368:	d22ff0ef          	jal	8000288a <kexit>
  return 0;  // not reached
}
    8000336c:	4501                	li	a0,0
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret

0000000080003376 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003376:	1141                	addi	sp,sp,-16
    80003378:	e406                	sd	ra,8(sp)
    8000337a:	e022                	sd	s0,0(sp)
    8000337c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000337e:	f38fe0ef          	jal	80001ab6 <myproc>
}
    80003382:	5908                	lw	a0,48(a0)
    80003384:	60a2                	ld	ra,8(sp)
    80003386:	6402                	ld	s0,0(sp)
    80003388:	0141                	addi	sp,sp,16
    8000338a:	8082                	ret

000000008000338c <sys_fork>:

uint64
sys_fork(void)
{
    8000338c:	1141                	addi	sp,sp,-16
    8000338e:	e406                	sd	ra,8(sp)
    80003390:	e022                	sd	s0,0(sp)
    80003392:	0800                	addi	s0,sp,16
  return kfork();
    80003394:	a99fe0ef          	jal	80001e2c <kfork>
}
    80003398:	60a2                	ld	ra,8(sp)
    8000339a:	6402                	ld	s0,0(sp)
    8000339c:	0141                	addi	sp,sp,16
    8000339e:	8082                	ret

00000000800033a0 <sys_wait>:

uint64
sys_wait(void)
{
    800033a0:	1101                	addi	sp,sp,-32
    800033a2:	ec06                	sd	ra,24(sp)
    800033a4:	e822                	sd	s0,16(sp)
    800033a6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033a8:	fe840593          	addi	a1,s0,-24
    800033ac:	4501                	li	a0,0
    800033ae:	efdff0ef          	jal	800032aa <argaddr>
  return kwait(p);
    800033b2:	fe843503          	ld	a0,-24(s0)
    800033b6:	e2eff0ef          	jal	800029e4 <kwait>
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret

00000000800033c2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033c2:	7179                	addi	sp,sp,-48
    800033c4:	f406                	sd	ra,40(sp)
    800033c6:	f022                	sd	s0,32(sp)
    800033c8:	ec26                	sd	s1,24(sp)
    800033ca:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800033cc:	fd840593          	addi	a1,s0,-40
    800033d0:	4501                	li	a0,0
    800033d2:	ebdff0ef          	jal	8000328e <argint>
  argint(1, &t);
    800033d6:	fdc40593          	addi	a1,s0,-36
    800033da:	4505                	li	a0,1
    800033dc:	eb3ff0ef          	jal	8000328e <argint>
  addr = myproc()->sz;
    800033e0:	ed6fe0ef          	jal	80001ab6 <myproc>
    800033e4:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    800033e6:	fdc42703          	lw	a4,-36(s0)
    800033ea:	4785                	li	a5,1
    800033ec:	02f70763          	beq	a4,a5,8000341a <sys_sbrk+0x58>
    800033f0:	fd842783          	lw	a5,-40(s0)
    800033f4:	0207c363          	bltz	a5,8000341a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800033f8:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800033fa:	02000737          	lui	a4,0x2000
    800033fe:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80003400:	0736                	slli	a4,a4,0xd
    80003402:	02f76a63          	bltu	a4,a5,80003436 <sys_sbrk+0x74>
    80003406:	0297e863          	bltu	a5,s1,80003436 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    8000340a:	eacfe0ef          	jal	80001ab6 <myproc>
    8000340e:	fd842703          	lw	a4,-40(s0)
    80003412:	693c                	ld	a5,80(a0)
    80003414:	97ba                	add	a5,a5,a4
    80003416:	e93c                	sd	a5,80(a0)
    80003418:	a039                	j	80003426 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000341a:	fd842503          	lw	a0,-40(s0)
    8000341e:	9adfe0ef          	jal	80001dca <growproc>
    80003422:	00054863          	bltz	a0,80003432 <sys_sbrk+0x70>
  }
  return addr;
}
    80003426:	8526                	mv	a0,s1
    80003428:	70a2                	ld	ra,40(sp)
    8000342a:	7402                	ld	s0,32(sp)
    8000342c:	64e2                	ld	s1,24(sp)
    8000342e:	6145                	addi	sp,sp,48
    80003430:	8082                	ret
      return -1;
    80003432:	54fd                	li	s1,-1
    80003434:	bfcd                	j	80003426 <sys_sbrk+0x64>
      return -1;
    80003436:	54fd                	li	s1,-1
    80003438:	b7fd                	j	80003426 <sys_sbrk+0x64>

000000008000343a <sys_pause>:

uint64
sys_pause(void)
{
    8000343a:	7139                	addi	sp,sp,-64
    8000343c:	fc06                	sd	ra,56(sp)
    8000343e:	f822                	sd	s0,48(sp)
    80003440:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003442:	fcc40593          	addi	a1,s0,-52
    80003446:	4501                	li	a0,0
    80003448:	e47ff0ef          	jal	8000328e <argint>
  if(n < 0)
    8000344c:	fcc42783          	lw	a5,-52(s0)
    80003450:	0607c863          	bltz	a5,800034c0 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003454:	00016517          	auipc	a0,0x16
    80003458:	6f450513          	addi	a0,a0,1780 # 80019b48 <tickslock>
    8000345c:	fccfd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80003460:	fcc42783          	lw	a5,-52(s0)
    80003464:	c3b9                	beqz	a5,800034aa <sys_pause+0x70>
    80003466:	f426                	sd	s1,40(sp)
    80003468:	f04a                	sd	s2,32(sp)
    8000346a:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    8000346c:	00008997          	auipc	s3,0x8
    80003470:	42c9a983          	lw	s3,1068(s3) # 8000b898 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003474:	00016917          	auipc	s2,0x16
    80003478:	6d490913          	addi	s2,s2,1748 # 80019b48 <tickslock>
    8000347c:	00008497          	auipc	s1,0x8
    80003480:	41c48493          	addi	s1,s1,1052 # 8000b898 <ticks>
    if(killed(myproc())){
    80003484:	e32fe0ef          	jal	80001ab6 <myproc>
    80003488:	d32ff0ef          	jal	800029ba <killed>
    8000348c:	ed0d                	bnez	a0,800034c6 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000348e:	85ca                	mv	a1,s2
    80003490:	8526                	mv	a0,s1
    80003492:	aecff0ef          	jal	8000277e <sleep>
  while(ticks - ticks0 < n){
    80003496:	409c                	lw	a5,0(s1)
    80003498:	413787bb          	subw	a5,a5,s3
    8000349c:	fcc42703          	lw	a4,-52(s0)
    800034a0:	fee7e2e3          	bltu	a5,a4,80003484 <sys_pause+0x4a>
    800034a4:	74a2                	ld	s1,40(sp)
    800034a6:	7902                	ld	s2,32(sp)
    800034a8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800034aa:	00016517          	auipc	a0,0x16
    800034ae:	69e50513          	addi	a0,a0,1694 # 80019b48 <tickslock>
    800034b2:	80bfd0ef          	jal	80000cbc <release>
  return 0;
    800034b6:	4501                	li	a0,0
}
    800034b8:	70e2                	ld	ra,56(sp)
    800034ba:	7442                	ld	s0,48(sp)
    800034bc:	6121                	addi	sp,sp,64
    800034be:	8082                	ret
    n = 0;
    800034c0:	fc042623          	sw	zero,-52(s0)
    800034c4:	bf41                	j	80003454 <sys_pause+0x1a>
      release(&tickslock);
    800034c6:	00016517          	auipc	a0,0x16
    800034ca:	68250513          	addi	a0,a0,1666 # 80019b48 <tickslock>
    800034ce:	feefd0ef          	jal	80000cbc <release>
      return -1;
    800034d2:	557d                	li	a0,-1
    800034d4:	74a2                	ld	s1,40(sp)
    800034d6:	7902                	ld	s2,32(sp)
    800034d8:	69e2                	ld	s3,24(sp)
    800034da:	bff9                	j	800034b8 <sys_pause+0x7e>

00000000800034dc <sys_kill>:

uint64
sys_kill(void)
{
    800034dc:	1101                	addi	sp,sp,-32
    800034de:	ec06                	sd	ra,24(sp)
    800034e0:	e822                	sd	s0,16(sp)
    800034e2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800034e4:	fec40593          	addi	a1,s0,-20
    800034e8:	4501                	li	a0,0
    800034ea:	da5ff0ef          	jal	8000328e <argint>
  return kkill(pid);
    800034ee:	fec42503          	lw	a0,-20(s0)
    800034f2:	c3eff0ef          	jal	80002930 <kkill>
}
    800034f6:	60e2                	ld	ra,24(sp)
    800034f8:	6442                	ld	s0,16(sp)
    800034fa:	6105                	addi	sp,sp,32
    800034fc:	8082                	ret

00000000800034fe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034fe:	1101                	addi	sp,sp,-32
    80003500:	ec06                	sd	ra,24(sp)
    80003502:	e822                	sd	s0,16(sp)
    80003504:	e426                	sd	s1,8(sp)
    80003506:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003508:	00016517          	auipc	a0,0x16
    8000350c:	64050513          	addi	a0,a0,1600 # 80019b48 <tickslock>
    80003510:	f18fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80003514:	00008797          	auipc	a5,0x8
    80003518:	3847a783          	lw	a5,900(a5) # 8000b898 <ticks>
    8000351c:	84be                	mv	s1,a5
  release(&tickslock);
    8000351e:	00016517          	auipc	a0,0x16
    80003522:	62a50513          	addi	a0,a0,1578 # 80019b48 <tickslock>
    80003526:	f96fd0ef          	jal	80000cbc <release>
  return xticks;
}
    8000352a:	02049513          	slli	a0,s1,0x20
    8000352e:	9101                	srli	a0,a0,0x20
    80003530:	60e2                	ld	ra,24(sp)
    80003532:	6442                	ld	s0,16(sp)
    80003534:	64a2                	ld	s1,8(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret

000000008000353a <sys_kps>:

uint64
sys_kps(void)
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003542:	4611                	li	a2,4
    80003544:	fe840593          	addi	a1,s0,-24
    80003548:	4501                	li	a0,0
    8000354a:	d7dff0ef          	jal	800032c6 <argstr>
    8000354e:	87aa                	mv	a5,a0
    return -1;
    80003550:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003552:	0007c663          	bltz	a5,8000355e <sys_kps+0x24>

  return kps(buffer);
    80003556:	fe840513          	addi	a0,s0,-24
    8000355a:	ebaff0ef          	jal	80002c14 <kps>
    8000355e:	60e2                	ld	ra,24(sp)
    80003560:	6442                	ld	s0,16(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret

0000000080003566 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003566:	7179                	addi	sp,sp,-48
    80003568:	f406                	sd	ra,40(sp)
    8000356a:	f022                	sd	s0,32(sp)
    8000356c:	ec26                	sd	s1,24(sp)
    8000356e:	e84a                	sd	s2,16(sp)
    80003570:	e44e                	sd	s3,8(sp)
    80003572:	e052                	sd	s4,0(sp)
    80003574:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003576:	00005597          	auipc	a1,0x5
    8000357a:	2aa58593          	addi	a1,a1,682 # 80008820 <etext+0x820>
    8000357e:	00016517          	auipc	a0,0x16
    80003582:	5e250513          	addi	a0,a0,1506 # 80019b60 <bcache>
    80003586:	e18fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000358a:	0001e797          	auipc	a5,0x1e
    8000358e:	5d678793          	addi	a5,a5,1494 # 80021b60 <bcache+0x8000>
    80003592:	0001f717          	auipc	a4,0x1f
    80003596:	83670713          	addi	a4,a4,-1994 # 80021dc8 <bcache+0x8268>
    8000359a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000359e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035a2:	00016497          	auipc	s1,0x16
    800035a6:	5d648493          	addi	s1,s1,1494 # 80019b78 <bcache+0x18>
    b->next = bcache.head.next;
    800035aa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035ac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035ae:	00005a17          	auipc	s4,0x5
    800035b2:	27aa0a13          	addi	s4,s4,634 # 80008828 <etext+0x828>
    b->next = bcache.head.next;
    800035b6:	2b893783          	ld	a5,696(s2)
    800035ba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800035bc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800035c0:	85d2                	mv	a1,s4
    800035c2:	01048513          	addi	a0,s1,16
    800035c6:	328010ef          	jal	800048ee <initsleeplock>
    bcache.head.next->prev = b;
    800035ca:	2b893783          	ld	a5,696(s2)
    800035ce:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035d0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035d4:	45848493          	addi	s1,s1,1112
    800035d8:	fd349fe3          	bne	s1,s3,800035b6 <binit+0x50>
  }
}
    800035dc:	70a2                	ld	ra,40(sp)
    800035de:	7402                	ld	s0,32(sp)
    800035e0:	64e2                	ld	s1,24(sp)
    800035e2:	6942                	ld	s2,16(sp)
    800035e4:	69a2                	ld	s3,8(sp)
    800035e6:	6a02                	ld	s4,0(sp)
    800035e8:	6145                	addi	sp,sp,48
    800035ea:	8082                	ret

00000000800035ec <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035ec:	7179                	addi	sp,sp,-48
    800035ee:	f406                	sd	ra,40(sp)
    800035f0:	f022                	sd	s0,32(sp)
    800035f2:	ec26                	sd	s1,24(sp)
    800035f4:	e84a                	sd	s2,16(sp)
    800035f6:	e44e                	sd	s3,8(sp)
    800035f8:	1800                	addi	s0,sp,48
    800035fa:	892a                	mv	s2,a0
    800035fc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035fe:	00016517          	auipc	a0,0x16
    80003602:	56250513          	addi	a0,a0,1378 # 80019b60 <bcache>
    80003606:	e22fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000360a:	0001f497          	auipc	s1,0x1f
    8000360e:	80e4b483          	ld	s1,-2034(s1) # 80021e18 <bcache+0x82b8>
    80003612:	0001e797          	auipc	a5,0x1e
    80003616:	7b678793          	addi	a5,a5,1974 # 80021dc8 <bcache+0x8268>
    8000361a:	02f48b63          	beq	s1,a5,80003650 <bread+0x64>
    8000361e:	873e                	mv	a4,a5
    80003620:	a021                	j	80003628 <bread+0x3c>
    80003622:	68a4                	ld	s1,80(s1)
    80003624:	02e48663          	beq	s1,a4,80003650 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003628:	449c                	lw	a5,8(s1)
    8000362a:	ff279ce3          	bne	a5,s2,80003622 <bread+0x36>
    8000362e:	44dc                	lw	a5,12(s1)
    80003630:	ff3799e3          	bne	a5,s3,80003622 <bread+0x36>
      b->refcnt++;
    80003634:	40bc                	lw	a5,64(s1)
    80003636:	2785                	addiw	a5,a5,1
    80003638:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000363a:	00016517          	auipc	a0,0x16
    8000363e:	52650513          	addi	a0,a0,1318 # 80019b60 <bcache>
    80003642:	e7afd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80003646:	01048513          	addi	a0,s1,16
    8000364a:	2da010ef          	jal	80004924 <acquiresleep>
      return b;
    8000364e:	a889                	j	800036a0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003650:	0001e497          	auipc	s1,0x1e
    80003654:	7c04b483          	ld	s1,1984(s1) # 80021e10 <bcache+0x82b0>
    80003658:	0001e797          	auipc	a5,0x1e
    8000365c:	77078793          	addi	a5,a5,1904 # 80021dc8 <bcache+0x8268>
    80003660:	00f48863          	beq	s1,a5,80003670 <bread+0x84>
    80003664:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003666:	40bc                	lw	a5,64(s1)
    80003668:	cb91                	beqz	a5,8000367c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000366a:	64a4                	ld	s1,72(s1)
    8000366c:	fee49de3          	bne	s1,a4,80003666 <bread+0x7a>
  panic("bget: no buffers");
    80003670:	00005517          	auipc	a0,0x5
    80003674:	1c050513          	addi	a0,a0,448 # 80008830 <etext+0x830>
    80003678:	9acfd0ef          	jal	80000824 <panic>
      b->dev = dev;
    8000367c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003680:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003684:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003688:	4785                	li	a5,1
    8000368a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000368c:	00016517          	auipc	a0,0x16
    80003690:	4d450513          	addi	a0,a0,1236 # 80019b60 <bcache>
    80003694:	e28fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80003698:	01048513          	addi	a0,s1,16
    8000369c:	288010ef          	jal	80004924 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036a0:	409c                	lw	a5,0(s1)
    800036a2:	cb89                	beqz	a5,800036b4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800036a4:	8526                	mv	a0,s1
    800036a6:	70a2                	ld	ra,40(sp)
    800036a8:	7402                	ld	s0,32(sp)
    800036aa:	64e2                	ld	s1,24(sp)
    800036ac:	6942                	ld	s2,16(sp)
    800036ae:	69a2                	ld	s3,8(sp)
    800036b0:	6145                	addi	sp,sp,48
    800036b2:	8082                	ret
    virtio_disk_rw(b, 0);
    800036b4:	4581                	li	a1,0
    800036b6:	8526                	mv	a0,s1
    800036b8:	339020ef          	jal	800061f0 <virtio_disk_rw>
    b->valid = 1;
    800036bc:	4785                	li	a5,1
    800036be:	c09c                	sw	a5,0(s1)
  return b;
    800036c0:	b7d5                	j	800036a4 <bread+0xb8>

00000000800036c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	1000                	addi	s0,sp,32
    800036cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036ce:	0541                	addi	a0,a0,16
    800036d0:	2d2010ef          	jal	800049a2 <holdingsleep>
    800036d4:	c911                	beqz	a0,800036e8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036d6:	4585                	li	a1,1
    800036d8:	8526                	mv	a0,s1
    800036da:	317020ef          	jal	800061f0 <virtio_disk_rw>
}
    800036de:	60e2                	ld	ra,24(sp)
    800036e0:	6442                	ld	s0,16(sp)
    800036e2:	64a2                	ld	s1,8(sp)
    800036e4:	6105                	addi	sp,sp,32
    800036e6:	8082                	ret
    panic("bwrite");
    800036e8:	00005517          	auipc	a0,0x5
    800036ec:	16050513          	addi	a0,a0,352 # 80008848 <etext+0x848>
    800036f0:	934fd0ef          	jal	80000824 <panic>

00000000800036f4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036f4:	1101                	addi	sp,sp,-32
    800036f6:	ec06                	sd	ra,24(sp)
    800036f8:	e822                	sd	s0,16(sp)
    800036fa:	e426                	sd	s1,8(sp)
    800036fc:	e04a                	sd	s2,0(sp)
    800036fe:	1000                	addi	s0,sp,32
    80003700:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003702:	01050913          	addi	s2,a0,16
    80003706:	854a                	mv	a0,s2
    80003708:	29a010ef          	jal	800049a2 <holdingsleep>
    8000370c:	c125                	beqz	a0,8000376c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    8000370e:	854a                	mv	a0,s2
    80003710:	25a010ef          	jal	8000496a <releasesleep>

  acquire(&bcache.lock);
    80003714:	00016517          	auipc	a0,0x16
    80003718:	44c50513          	addi	a0,a0,1100 # 80019b60 <bcache>
    8000371c:	d0cfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003720:	40bc                	lw	a5,64(s1)
    80003722:	37fd                	addiw	a5,a5,-1
    80003724:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003726:	e79d                	bnez	a5,80003754 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003728:	68b8                	ld	a4,80(s1)
    8000372a:	64bc                	ld	a5,72(s1)
    8000372c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000372e:	68b8                	ld	a4,80(s1)
    80003730:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003732:	0001e797          	auipc	a5,0x1e
    80003736:	42e78793          	addi	a5,a5,1070 # 80021b60 <bcache+0x8000>
    8000373a:	2b87b703          	ld	a4,696(a5)
    8000373e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003740:	0001e717          	auipc	a4,0x1e
    80003744:	68870713          	addi	a4,a4,1672 # 80021dc8 <bcache+0x8268>
    80003748:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000374a:	2b87b703          	ld	a4,696(a5)
    8000374e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003750:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003754:	00016517          	auipc	a0,0x16
    80003758:	40c50513          	addi	a0,a0,1036 # 80019b60 <bcache>
    8000375c:	d60fd0ef          	jal	80000cbc <release>
}
    80003760:	60e2                	ld	ra,24(sp)
    80003762:	6442                	ld	s0,16(sp)
    80003764:	64a2                	ld	s1,8(sp)
    80003766:	6902                	ld	s2,0(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret
    panic("brelse");
    8000376c:	00005517          	auipc	a0,0x5
    80003770:	0e450513          	addi	a0,a0,228 # 80008850 <etext+0x850>
    80003774:	8b0fd0ef          	jal	80000824 <panic>

0000000080003778 <bpin>:

void
bpin(struct buf *b) {
    80003778:	1101                	addi	sp,sp,-32
    8000377a:	ec06                	sd	ra,24(sp)
    8000377c:	e822                	sd	s0,16(sp)
    8000377e:	e426                	sd	s1,8(sp)
    80003780:	1000                	addi	s0,sp,32
    80003782:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003784:	00016517          	auipc	a0,0x16
    80003788:	3dc50513          	addi	a0,a0,988 # 80019b60 <bcache>
    8000378c:	c9cfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003790:	40bc                	lw	a5,64(s1)
    80003792:	2785                	addiw	a5,a5,1
    80003794:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003796:	00016517          	auipc	a0,0x16
    8000379a:	3ca50513          	addi	a0,a0,970 # 80019b60 <bcache>
    8000379e:	d1efd0ef          	jal	80000cbc <release>
}
    800037a2:	60e2                	ld	ra,24(sp)
    800037a4:	6442                	ld	s0,16(sp)
    800037a6:	64a2                	ld	s1,8(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret

00000000800037ac <bunpin>:

void
bunpin(struct buf *b) {
    800037ac:	1101                	addi	sp,sp,-32
    800037ae:	ec06                	sd	ra,24(sp)
    800037b0:	e822                	sd	s0,16(sp)
    800037b2:	e426                	sd	s1,8(sp)
    800037b4:	1000                	addi	s0,sp,32
    800037b6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037b8:	00016517          	auipc	a0,0x16
    800037bc:	3a850513          	addi	a0,a0,936 # 80019b60 <bcache>
    800037c0:	c68fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800037c4:	40bc                	lw	a5,64(s1)
    800037c6:	37fd                	addiw	a5,a5,-1
    800037c8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037ca:	00016517          	auipc	a0,0x16
    800037ce:	39650513          	addi	a0,a0,918 # 80019b60 <bcache>
    800037d2:	ceafd0ef          	jal	80000cbc <release>
}
    800037d6:	60e2                	ld	ra,24(sp)
    800037d8:	6442                	ld	s0,16(sp)
    800037da:	64a2                	ld	s1,8(sp)
    800037dc:	6105                	addi	sp,sp,32
    800037de:	8082                	ret

00000000800037e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037e0:	1101                	addi	sp,sp,-32
    800037e2:	ec06                	sd	ra,24(sp)
    800037e4:	e822                	sd	s0,16(sp)
    800037e6:	e426                	sd	s1,8(sp)
    800037e8:	e04a                	sd	s2,0(sp)
    800037ea:	1000                	addi	s0,sp,32
    800037ec:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037ee:	00d5d79b          	srliw	a5,a1,0xd
    800037f2:	0001f597          	auipc	a1,0x1f
    800037f6:	a4a5a583          	lw	a1,-1462(a1) # 8002223c <sb+0x1c>
    800037fa:	9dbd                	addw	a1,a1,a5
    800037fc:	df1ff0ef          	jal	800035ec <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003800:	0074f713          	andi	a4,s1,7
    80003804:	4785                	li	a5,1
    80003806:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000380a:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000380c:	90d9                	srli	s1,s1,0x36
    8000380e:	00950733          	add	a4,a0,s1
    80003812:	05874703          	lbu	a4,88(a4)
    80003816:	00e7f6b3          	and	a3,a5,a4
    8000381a:	c29d                	beqz	a3,80003840 <bfree+0x60>
    8000381c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000381e:	94aa                	add	s1,s1,a0
    80003820:	fff7c793          	not	a5,a5
    80003824:	8f7d                	and	a4,a4,a5
    80003826:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000382a:	000010ef          	jal	8000482a <log_write>
  brelse(bp);
    8000382e:	854a                	mv	a0,s2
    80003830:	ec5ff0ef          	jal	800036f4 <brelse>
}
    80003834:	60e2                	ld	ra,24(sp)
    80003836:	6442                	ld	s0,16(sp)
    80003838:	64a2                	ld	s1,8(sp)
    8000383a:	6902                	ld	s2,0(sp)
    8000383c:	6105                	addi	sp,sp,32
    8000383e:	8082                	ret
    panic("freeing free block");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	01850513          	addi	a0,a0,24 # 80008858 <etext+0x858>
    80003848:	fddfc0ef          	jal	80000824 <panic>

000000008000384c <balloc>:
{
    8000384c:	715d                	addi	sp,sp,-80
    8000384e:	e486                	sd	ra,72(sp)
    80003850:	e0a2                	sd	s0,64(sp)
    80003852:	fc26                	sd	s1,56(sp)
    80003854:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003856:	0001f797          	auipc	a5,0x1f
    8000385a:	9ce7a783          	lw	a5,-1586(a5) # 80022224 <sb+0x4>
    8000385e:	0e078263          	beqz	a5,80003942 <balloc+0xf6>
    80003862:	f84a                	sd	s2,48(sp)
    80003864:	f44e                	sd	s3,40(sp)
    80003866:	f052                	sd	s4,32(sp)
    80003868:	ec56                	sd	s5,24(sp)
    8000386a:	e85a                	sd	s6,16(sp)
    8000386c:	e45e                	sd	s7,8(sp)
    8000386e:	e062                	sd	s8,0(sp)
    80003870:	8baa                	mv	s7,a0
    80003872:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003874:	0001fb17          	auipc	s6,0x1f
    80003878:	9acb0b13          	addi	s6,s6,-1620 # 80022220 <sb>
      m = 1 << (bi % 8);
    8000387c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000387e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003880:	6c09                	lui	s8,0x2
    80003882:	a09d                	j	800038e8 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003884:	97ca                	add	a5,a5,s2
    80003886:	8e55                	or	a2,a2,a3
    80003888:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	79d000ef          	jal	8000482a <log_write>
        brelse(bp);
    80003892:	854a                	mv	a0,s2
    80003894:	e61ff0ef          	jal	800036f4 <brelse>
  bp = bread(dev, bno);
    80003898:	85a6                	mv	a1,s1
    8000389a:	855e                	mv	a0,s7
    8000389c:	d51ff0ef          	jal	800035ec <bread>
    800038a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038a2:	40000613          	li	a2,1024
    800038a6:	4581                	li	a1,0
    800038a8:	05850513          	addi	a0,a0,88
    800038ac:	c4cfd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    800038b0:	854a                	mv	a0,s2
    800038b2:	779000ef          	jal	8000482a <log_write>
  brelse(bp);
    800038b6:	854a                	mv	a0,s2
    800038b8:	e3dff0ef          	jal	800036f4 <brelse>
}
    800038bc:	7942                	ld	s2,48(sp)
    800038be:	79a2                	ld	s3,40(sp)
    800038c0:	7a02                	ld	s4,32(sp)
    800038c2:	6ae2                	ld	s5,24(sp)
    800038c4:	6b42                	ld	s6,16(sp)
    800038c6:	6ba2                	ld	s7,8(sp)
    800038c8:	6c02                	ld	s8,0(sp)
}
    800038ca:	8526                	mv	a0,s1
    800038cc:	60a6                	ld	ra,72(sp)
    800038ce:	6406                	ld	s0,64(sp)
    800038d0:	74e2                	ld	s1,56(sp)
    800038d2:	6161                	addi	sp,sp,80
    800038d4:	8082                	ret
    brelse(bp);
    800038d6:	854a                	mv	a0,s2
    800038d8:	e1dff0ef          	jal	800036f4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038dc:	015c0abb          	addw	s5,s8,s5
    800038e0:	004b2783          	lw	a5,4(s6)
    800038e4:	04faf863          	bgeu	s5,a5,80003934 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800038e8:	40dad59b          	sraiw	a1,s5,0xd
    800038ec:	01cb2783          	lw	a5,28(s6)
    800038f0:	9dbd                	addw	a1,a1,a5
    800038f2:	855e                	mv	a0,s7
    800038f4:	cf9ff0ef          	jal	800035ec <bread>
    800038f8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038fa:	004b2503          	lw	a0,4(s6)
    800038fe:	84d6                	mv	s1,s5
    80003900:	4701                	li	a4,0
    80003902:	fca4fae3          	bgeu	s1,a0,800038d6 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003906:	00777693          	andi	a3,a4,7
    8000390a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000390e:	41f7579b          	sraiw	a5,a4,0x1f
    80003912:	01d7d79b          	srliw	a5,a5,0x1d
    80003916:	9fb9                	addw	a5,a5,a4
    80003918:	4037d79b          	sraiw	a5,a5,0x3
    8000391c:	00f90633          	add	a2,s2,a5
    80003920:	05864603          	lbu	a2,88(a2)
    80003924:	00c6f5b3          	and	a1,a3,a2
    80003928:	ddb1                	beqz	a1,80003884 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000392a:	2705                	addiw	a4,a4,1
    8000392c:	2485                	addiw	s1,s1,1
    8000392e:	fd471ae3          	bne	a4,s4,80003902 <balloc+0xb6>
    80003932:	b755                	j	800038d6 <balloc+0x8a>
    80003934:	7942                	ld	s2,48(sp)
    80003936:	79a2                	ld	s3,40(sp)
    80003938:	7a02                	ld	s4,32(sp)
    8000393a:	6ae2                	ld	s5,24(sp)
    8000393c:	6b42                	ld	s6,16(sp)
    8000393e:	6ba2                	ld	s7,8(sp)
    80003940:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003942:	00005517          	auipc	a0,0x5
    80003946:	f2e50513          	addi	a0,a0,-210 # 80008870 <etext+0x870>
    8000394a:	bb1fc0ef          	jal	800004fa <printf>
  return 0;
    8000394e:	4481                	li	s1,0
    80003950:	bfad                	j	800038ca <balloc+0x7e>

0000000080003952 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003952:	7179                	addi	sp,sp,-48
    80003954:	f406                	sd	ra,40(sp)
    80003956:	f022                	sd	s0,32(sp)
    80003958:	ec26                	sd	s1,24(sp)
    8000395a:	e84a                	sd	s2,16(sp)
    8000395c:	e44e                	sd	s3,8(sp)
    8000395e:	1800                	addi	s0,sp,48
    80003960:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003962:	47ad                	li	a5,11
    80003964:	02b7e363          	bltu	a5,a1,8000398a <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003968:	02059793          	slli	a5,a1,0x20
    8000396c:	01e7d593          	srli	a1,a5,0x1e
    80003970:	00b509b3          	add	s3,a0,a1
    80003974:	0509a483          	lw	s1,80(s3)
    80003978:	e0b5                	bnez	s1,800039dc <bmap+0x8a>
      addr = balloc(ip->dev);
    8000397a:	4108                	lw	a0,0(a0)
    8000397c:	ed1ff0ef          	jal	8000384c <balloc>
    80003980:	84aa                	mv	s1,a0
      if(addr == 0)
    80003982:	cd29                	beqz	a0,800039dc <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003984:	04a9a823          	sw	a0,80(s3)
    80003988:	a891                	j	800039dc <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000398a:	ff45879b          	addiw	a5,a1,-12
    8000398e:	873e                	mv	a4,a5
    80003990:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003992:	0ff00793          	li	a5,255
    80003996:	06e7e763          	bltu	a5,a4,80003a04 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000399a:	08052483          	lw	s1,128(a0)
    8000399e:	e891                	bnez	s1,800039b2 <bmap+0x60>
      addr = balloc(ip->dev);
    800039a0:	4108                	lw	a0,0(a0)
    800039a2:	eabff0ef          	jal	8000384c <balloc>
    800039a6:	84aa                	mv	s1,a0
      if(addr == 0)
    800039a8:	c915                	beqz	a0,800039dc <bmap+0x8a>
    800039aa:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800039ac:	08a92023          	sw	a0,128(s2)
    800039b0:	a011                	j	800039b4 <bmap+0x62>
    800039b2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800039b4:	85a6                	mv	a1,s1
    800039b6:	00092503          	lw	a0,0(s2)
    800039ba:	c33ff0ef          	jal	800035ec <bread>
    800039be:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039c0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800039c4:	02099713          	slli	a4,s3,0x20
    800039c8:	01e75593          	srli	a1,a4,0x1e
    800039cc:	97ae                	add	a5,a5,a1
    800039ce:	89be                	mv	s3,a5
    800039d0:	4384                	lw	s1,0(a5)
    800039d2:	cc89                	beqz	s1,800039ec <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800039d4:	8552                	mv	a0,s4
    800039d6:	d1fff0ef          	jal	800036f4 <brelse>
    return addr;
    800039da:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800039dc:	8526                	mv	a0,s1
    800039de:	70a2                	ld	ra,40(sp)
    800039e0:	7402                	ld	s0,32(sp)
    800039e2:	64e2                	ld	s1,24(sp)
    800039e4:	6942                	ld	s2,16(sp)
    800039e6:	69a2                	ld	s3,8(sp)
    800039e8:	6145                	addi	sp,sp,48
    800039ea:	8082                	ret
      addr = balloc(ip->dev);
    800039ec:	00092503          	lw	a0,0(s2)
    800039f0:	e5dff0ef          	jal	8000384c <balloc>
    800039f4:	84aa                	mv	s1,a0
      if(addr){
    800039f6:	dd79                	beqz	a0,800039d4 <bmap+0x82>
        a[bn] = addr;
    800039f8:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800039fc:	8552                	mv	a0,s4
    800039fe:	62d000ef          	jal	8000482a <log_write>
    80003a02:	bfc9                	j	800039d4 <bmap+0x82>
    80003a04:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003a06:	00005517          	auipc	a0,0x5
    80003a0a:	e8250513          	addi	a0,a0,-382 # 80008888 <etext+0x888>
    80003a0e:	e17fc0ef          	jal	80000824 <panic>

0000000080003a12 <iget>:
{
    80003a12:	7179                	addi	sp,sp,-48
    80003a14:	f406                	sd	ra,40(sp)
    80003a16:	f022                	sd	s0,32(sp)
    80003a18:	ec26                	sd	s1,24(sp)
    80003a1a:	e84a                	sd	s2,16(sp)
    80003a1c:	e44e                	sd	s3,8(sp)
    80003a1e:	e052                	sd	s4,0(sp)
    80003a20:	1800                	addi	s0,sp,48
    80003a22:	892a                	mv	s2,a0
    80003a24:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a26:	0001f517          	auipc	a0,0x1f
    80003a2a:	81a50513          	addi	a0,a0,-2022 # 80022240 <itable>
    80003a2e:	9fafd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003a32:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a34:	0001f497          	auipc	s1,0x1f
    80003a38:	82448493          	addi	s1,s1,-2012 # 80022258 <itable+0x18>
    80003a3c:	00020697          	auipc	a3,0x20
    80003a40:	2ac68693          	addi	a3,a3,684 # 80023ce8 <log>
    80003a44:	a809                	j	80003a56 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a46:	e781                	bnez	a5,80003a4e <iget+0x3c>
    80003a48:	00099363          	bnez	s3,80003a4e <iget+0x3c>
      empty = ip;
    80003a4c:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a4e:	08848493          	addi	s1,s1,136
    80003a52:	02d48563          	beq	s1,a3,80003a7c <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a56:	449c                	lw	a5,8(s1)
    80003a58:	fef057e3          	blez	a5,80003a46 <iget+0x34>
    80003a5c:	4098                	lw	a4,0(s1)
    80003a5e:	ff2718e3          	bne	a4,s2,80003a4e <iget+0x3c>
    80003a62:	40d8                	lw	a4,4(s1)
    80003a64:	ff4715e3          	bne	a4,s4,80003a4e <iget+0x3c>
      ip->ref++;
    80003a68:	2785                	addiw	a5,a5,1
    80003a6a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a6c:	0001e517          	auipc	a0,0x1e
    80003a70:	7d450513          	addi	a0,a0,2004 # 80022240 <itable>
    80003a74:	a48fd0ef          	jal	80000cbc <release>
      return ip;
    80003a78:	89a6                	mv	s3,s1
    80003a7a:	a015                	j	80003a9e <iget+0x8c>
  if(empty == 0)
    80003a7c:	02098a63          	beqz	s3,80003ab0 <iget+0x9e>
  ip->dev = dev;
    80003a80:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003a84:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003a88:	4785                	li	a5,1
    80003a8a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003a8e:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003a92:	0001e517          	auipc	a0,0x1e
    80003a96:	7ae50513          	addi	a0,a0,1966 # 80022240 <itable>
    80003a9a:	a22fd0ef          	jal	80000cbc <release>
}
    80003a9e:	854e                	mv	a0,s3
    80003aa0:	70a2                	ld	ra,40(sp)
    80003aa2:	7402                	ld	s0,32(sp)
    80003aa4:	64e2                	ld	s1,24(sp)
    80003aa6:	6942                	ld	s2,16(sp)
    80003aa8:	69a2                	ld	s3,8(sp)
    80003aaa:	6a02                	ld	s4,0(sp)
    80003aac:	6145                	addi	sp,sp,48
    80003aae:	8082                	ret
    panic("iget: no inodes");
    80003ab0:	00005517          	auipc	a0,0x5
    80003ab4:	df050513          	addi	a0,a0,-528 # 800088a0 <etext+0x8a0>
    80003ab8:	d6dfc0ef          	jal	80000824 <panic>

0000000080003abc <iinit>:
{
    80003abc:	7179                	addi	sp,sp,-48
    80003abe:	f406                	sd	ra,40(sp)
    80003ac0:	f022                	sd	s0,32(sp)
    80003ac2:	ec26                	sd	s1,24(sp)
    80003ac4:	e84a                	sd	s2,16(sp)
    80003ac6:	e44e                	sd	s3,8(sp)
    80003ac8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003aca:	00005597          	auipc	a1,0x5
    80003ace:	de658593          	addi	a1,a1,-538 # 800088b0 <etext+0x8b0>
    80003ad2:	0001e517          	auipc	a0,0x1e
    80003ad6:	76e50513          	addi	a0,a0,1902 # 80022240 <itable>
    80003ada:	8c4fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ade:	0001e497          	auipc	s1,0x1e
    80003ae2:	78a48493          	addi	s1,s1,1930 # 80022268 <itable+0x28>
    80003ae6:	00020997          	auipc	s3,0x20
    80003aea:	21298993          	addi	s3,s3,530 # 80023cf8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003aee:	00005917          	auipc	s2,0x5
    80003af2:	dca90913          	addi	s2,s2,-566 # 800088b8 <etext+0x8b8>
    80003af6:	85ca                	mv	a1,s2
    80003af8:	8526                	mv	a0,s1
    80003afa:	5f5000ef          	jal	800048ee <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003afe:	08848493          	addi	s1,s1,136
    80003b02:	ff349ae3          	bne	s1,s3,80003af6 <iinit+0x3a>
}
    80003b06:	70a2                	ld	ra,40(sp)
    80003b08:	7402                	ld	s0,32(sp)
    80003b0a:	64e2                	ld	s1,24(sp)
    80003b0c:	6942                	ld	s2,16(sp)
    80003b0e:	69a2                	ld	s3,8(sp)
    80003b10:	6145                	addi	sp,sp,48
    80003b12:	8082                	ret

0000000080003b14 <ialloc>:
{
    80003b14:	7139                	addi	sp,sp,-64
    80003b16:	fc06                	sd	ra,56(sp)
    80003b18:	f822                	sd	s0,48(sp)
    80003b1a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b1c:	0001e717          	auipc	a4,0x1e
    80003b20:	71072703          	lw	a4,1808(a4) # 8002222c <sb+0xc>
    80003b24:	4785                	li	a5,1
    80003b26:	06e7f063          	bgeu	a5,a4,80003b86 <ialloc+0x72>
    80003b2a:	f426                	sd	s1,40(sp)
    80003b2c:	f04a                	sd	s2,32(sp)
    80003b2e:	ec4e                	sd	s3,24(sp)
    80003b30:	e852                	sd	s4,16(sp)
    80003b32:	e456                	sd	s5,8(sp)
    80003b34:	e05a                	sd	s6,0(sp)
    80003b36:	8aaa                	mv	s5,a0
    80003b38:	8b2e                	mv	s6,a1
    80003b3a:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003b3c:	0001ea17          	auipc	s4,0x1e
    80003b40:	6e4a0a13          	addi	s4,s4,1764 # 80022220 <sb>
    80003b44:	00495593          	srli	a1,s2,0x4
    80003b48:	018a2783          	lw	a5,24(s4)
    80003b4c:	9dbd                	addw	a1,a1,a5
    80003b4e:	8556                	mv	a0,s5
    80003b50:	a9dff0ef          	jal	800035ec <bread>
    80003b54:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b56:	05850993          	addi	s3,a0,88
    80003b5a:	00f97793          	andi	a5,s2,15
    80003b5e:	079a                	slli	a5,a5,0x6
    80003b60:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b62:	00099783          	lh	a5,0(s3)
    80003b66:	cb9d                	beqz	a5,80003b9c <ialloc+0x88>
    brelse(bp);
    80003b68:	b8dff0ef          	jal	800036f4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b6c:	0905                	addi	s2,s2,1
    80003b6e:	00ca2703          	lw	a4,12(s4)
    80003b72:	0009079b          	sext.w	a5,s2
    80003b76:	fce7e7e3          	bltu	a5,a4,80003b44 <ialloc+0x30>
    80003b7a:	74a2                	ld	s1,40(sp)
    80003b7c:	7902                	ld	s2,32(sp)
    80003b7e:	69e2                	ld	s3,24(sp)
    80003b80:	6a42                	ld	s4,16(sp)
    80003b82:	6aa2                	ld	s5,8(sp)
    80003b84:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003b86:	00005517          	auipc	a0,0x5
    80003b8a:	d3a50513          	addi	a0,a0,-710 # 800088c0 <etext+0x8c0>
    80003b8e:	96dfc0ef          	jal	800004fa <printf>
  return 0;
    80003b92:	4501                	li	a0,0
}
    80003b94:	70e2                	ld	ra,56(sp)
    80003b96:	7442                	ld	s0,48(sp)
    80003b98:	6121                	addi	sp,sp,64
    80003b9a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b9c:	04000613          	li	a2,64
    80003ba0:	4581                	li	a1,0
    80003ba2:	854e                	mv	a0,s3
    80003ba4:	954fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003ba8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bac:	8526                	mv	a0,s1
    80003bae:	47d000ef          	jal	8000482a <log_write>
      brelse(bp);
    80003bb2:	8526                	mv	a0,s1
    80003bb4:	b41ff0ef          	jal	800036f4 <brelse>
      return iget(dev, inum);
    80003bb8:	0009059b          	sext.w	a1,s2
    80003bbc:	8556                	mv	a0,s5
    80003bbe:	e55ff0ef          	jal	80003a12 <iget>
    80003bc2:	74a2                	ld	s1,40(sp)
    80003bc4:	7902                	ld	s2,32(sp)
    80003bc6:	69e2                	ld	s3,24(sp)
    80003bc8:	6a42                	ld	s4,16(sp)
    80003bca:	6aa2                	ld	s5,8(sp)
    80003bcc:	6b02                	ld	s6,0(sp)
    80003bce:	b7d9                	j	80003b94 <ialloc+0x80>

0000000080003bd0 <iupdate>:
{
    80003bd0:	1101                	addi	sp,sp,-32
    80003bd2:	ec06                	sd	ra,24(sp)
    80003bd4:	e822                	sd	s0,16(sp)
    80003bd6:	e426                	sd	s1,8(sp)
    80003bd8:	e04a                	sd	s2,0(sp)
    80003bda:	1000                	addi	s0,sp,32
    80003bdc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bde:	415c                	lw	a5,4(a0)
    80003be0:	0047d79b          	srliw	a5,a5,0x4
    80003be4:	0001e597          	auipc	a1,0x1e
    80003be8:	6545a583          	lw	a1,1620(a1) # 80022238 <sb+0x18>
    80003bec:	9dbd                	addw	a1,a1,a5
    80003bee:	4108                	lw	a0,0(a0)
    80003bf0:	9fdff0ef          	jal	800035ec <bread>
    80003bf4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bf6:	05850793          	addi	a5,a0,88
    80003bfa:	40d8                	lw	a4,4(s1)
    80003bfc:	8b3d                	andi	a4,a4,15
    80003bfe:	071a                	slli	a4,a4,0x6
    80003c00:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003c02:	04449703          	lh	a4,68(s1)
    80003c06:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003c0a:	04649703          	lh	a4,70(s1)
    80003c0e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c12:	04849703          	lh	a4,72(s1)
    80003c16:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c1a:	04a49703          	lh	a4,74(s1)
    80003c1e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c22:	44f8                	lw	a4,76(s1)
    80003c24:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c26:	03400613          	li	a2,52
    80003c2a:	05048593          	addi	a1,s1,80
    80003c2e:	00c78513          	addi	a0,a5,12
    80003c32:	926fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003c36:	854a                	mv	a0,s2
    80003c38:	3f3000ef          	jal	8000482a <log_write>
  brelse(bp);
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	ab7ff0ef          	jal	800036f4 <brelse>
}
    80003c42:	60e2                	ld	ra,24(sp)
    80003c44:	6442                	ld	s0,16(sp)
    80003c46:	64a2                	ld	s1,8(sp)
    80003c48:	6902                	ld	s2,0(sp)
    80003c4a:	6105                	addi	sp,sp,32
    80003c4c:	8082                	ret

0000000080003c4e <idup>:
{
    80003c4e:	1101                	addi	sp,sp,-32
    80003c50:	ec06                	sd	ra,24(sp)
    80003c52:	e822                	sd	s0,16(sp)
    80003c54:	e426                	sd	s1,8(sp)
    80003c56:	1000                	addi	s0,sp,32
    80003c58:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c5a:	0001e517          	auipc	a0,0x1e
    80003c5e:	5e650513          	addi	a0,a0,1510 # 80022240 <itable>
    80003c62:	fc7fc0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003c66:	449c                	lw	a5,8(s1)
    80003c68:	2785                	addiw	a5,a5,1
    80003c6a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c6c:	0001e517          	auipc	a0,0x1e
    80003c70:	5d450513          	addi	a0,a0,1492 # 80022240 <itable>
    80003c74:	848fd0ef          	jal	80000cbc <release>
}
    80003c78:	8526                	mv	a0,s1
    80003c7a:	60e2                	ld	ra,24(sp)
    80003c7c:	6442                	ld	s0,16(sp)
    80003c7e:	64a2                	ld	s1,8(sp)
    80003c80:	6105                	addi	sp,sp,32
    80003c82:	8082                	ret

0000000080003c84 <ilock>:
{
    80003c84:	1101                	addi	sp,sp,-32
    80003c86:	ec06                	sd	ra,24(sp)
    80003c88:	e822                	sd	s0,16(sp)
    80003c8a:	e426                	sd	s1,8(sp)
    80003c8c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c8e:	cd19                	beqz	a0,80003cac <ilock+0x28>
    80003c90:	84aa                	mv	s1,a0
    80003c92:	451c                	lw	a5,8(a0)
    80003c94:	00f05c63          	blez	a5,80003cac <ilock+0x28>
  acquiresleep(&ip->lock);
    80003c98:	0541                	addi	a0,a0,16
    80003c9a:	48b000ef          	jal	80004924 <acquiresleep>
  if(ip->valid == 0){
    80003c9e:	40bc                	lw	a5,64(s1)
    80003ca0:	cf89                	beqz	a5,80003cba <ilock+0x36>
}
    80003ca2:	60e2                	ld	ra,24(sp)
    80003ca4:	6442                	ld	s0,16(sp)
    80003ca6:	64a2                	ld	s1,8(sp)
    80003ca8:	6105                	addi	sp,sp,32
    80003caa:	8082                	ret
    80003cac:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003cae:	00005517          	auipc	a0,0x5
    80003cb2:	c2a50513          	addi	a0,a0,-982 # 800088d8 <etext+0x8d8>
    80003cb6:	b6ffc0ef          	jal	80000824 <panic>
    80003cba:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cbc:	40dc                	lw	a5,4(s1)
    80003cbe:	0047d79b          	srliw	a5,a5,0x4
    80003cc2:	0001e597          	auipc	a1,0x1e
    80003cc6:	5765a583          	lw	a1,1398(a1) # 80022238 <sb+0x18>
    80003cca:	9dbd                	addw	a1,a1,a5
    80003ccc:	4088                	lw	a0,0(s1)
    80003cce:	91fff0ef          	jal	800035ec <bread>
    80003cd2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cd4:	05850593          	addi	a1,a0,88
    80003cd8:	40dc                	lw	a5,4(s1)
    80003cda:	8bbd                	andi	a5,a5,15
    80003cdc:	079a                	slli	a5,a5,0x6
    80003cde:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ce0:	00059783          	lh	a5,0(a1)
    80003ce4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ce8:	00259783          	lh	a5,2(a1)
    80003cec:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cf0:	00459783          	lh	a5,4(a1)
    80003cf4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cf8:	00659783          	lh	a5,6(a1)
    80003cfc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d00:	459c                	lw	a5,8(a1)
    80003d02:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d04:	03400613          	li	a2,52
    80003d08:	05b1                	addi	a1,a1,12
    80003d0a:	05048513          	addi	a0,s1,80
    80003d0e:	84afd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003d12:	854a                	mv	a0,s2
    80003d14:	9e1ff0ef          	jal	800036f4 <brelse>
    ip->valid = 1;
    80003d18:	4785                	li	a5,1
    80003d1a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d1c:	04449783          	lh	a5,68(s1)
    80003d20:	c399                	beqz	a5,80003d26 <ilock+0xa2>
    80003d22:	6902                	ld	s2,0(sp)
    80003d24:	bfbd                	j	80003ca2 <ilock+0x1e>
      panic("ilock: no type");
    80003d26:	00005517          	auipc	a0,0x5
    80003d2a:	bba50513          	addi	a0,a0,-1094 # 800088e0 <etext+0x8e0>
    80003d2e:	af7fc0ef          	jal	80000824 <panic>

0000000080003d32 <iunlock>:
{
    80003d32:	1101                	addi	sp,sp,-32
    80003d34:	ec06                	sd	ra,24(sp)
    80003d36:	e822                	sd	s0,16(sp)
    80003d38:	e426                	sd	s1,8(sp)
    80003d3a:	e04a                	sd	s2,0(sp)
    80003d3c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d3e:	c505                	beqz	a0,80003d66 <iunlock+0x34>
    80003d40:	84aa                	mv	s1,a0
    80003d42:	01050913          	addi	s2,a0,16
    80003d46:	854a                	mv	a0,s2
    80003d48:	45b000ef          	jal	800049a2 <holdingsleep>
    80003d4c:	cd09                	beqz	a0,80003d66 <iunlock+0x34>
    80003d4e:	449c                	lw	a5,8(s1)
    80003d50:	00f05b63          	blez	a5,80003d66 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003d54:	854a                	mv	a0,s2
    80003d56:	415000ef          	jal	8000496a <releasesleep>
}
    80003d5a:	60e2                	ld	ra,24(sp)
    80003d5c:	6442                	ld	s0,16(sp)
    80003d5e:	64a2                	ld	s1,8(sp)
    80003d60:	6902                	ld	s2,0(sp)
    80003d62:	6105                	addi	sp,sp,32
    80003d64:	8082                	ret
    panic("iunlock");
    80003d66:	00005517          	auipc	a0,0x5
    80003d6a:	b8a50513          	addi	a0,a0,-1142 # 800088f0 <etext+0x8f0>
    80003d6e:	ab7fc0ef          	jal	80000824 <panic>

0000000080003d72 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d72:	7179                	addi	sp,sp,-48
    80003d74:	f406                	sd	ra,40(sp)
    80003d76:	f022                	sd	s0,32(sp)
    80003d78:	ec26                	sd	s1,24(sp)
    80003d7a:	e84a                	sd	s2,16(sp)
    80003d7c:	e44e                	sd	s3,8(sp)
    80003d7e:	1800                	addi	s0,sp,48
    80003d80:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d82:	05050493          	addi	s1,a0,80
    80003d86:	08050913          	addi	s2,a0,128
    80003d8a:	a021                	j	80003d92 <itrunc+0x20>
    80003d8c:	0491                	addi	s1,s1,4
    80003d8e:	01248b63          	beq	s1,s2,80003da4 <itrunc+0x32>
    if(ip->addrs[i]){
    80003d92:	408c                	lw	a1,0(s1)
    80003d94:	dde5                	beqz	a1,80003d8c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003d96:	0009a503          	lw	a0,0(s3)
    80003d9a:	a47ff0ef          	jal	800037e0 <bfree>
      ip->addrs[i] = 0;
    80003d9e:	0004a023          	sw	zero,0(s1)
    80003da2:	b7ed                	j	80003d8c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003da4:	0809a583          	lw	a1,128(s3)
    80003da8:	ed89                	bnez	a1,80003dc2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003daa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dae:	854e                	mv	a0,s3
    80003db0:	e21ff0ef          	jal	80003bd0 <iupdate>
}
    80003db4:	70a2                	ld	ra,40(sp)
    80003db6:	7402                	ld	s0,32(sp)
    80003db8:	64e2                	ld	s1,24(sp)
    80003dba:	6942                	ld	s2,16(sp)
    80003dbc:	69a2                	ld	s3,8(sp)
    80003dbe:	6145                	addi	sp,sp,48
    80003dc0:	8082                	ret
    80003dc2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dc4:	0009a503          	lw	a0,0(s3)
    80003dc8:	825ff0ef          	jal	800035ec <bread>
    80003dcc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dce:	05850493          	addi	s1,a0,88
    80003dd2:	45850913          	addi	s2,a0,1112
    80003dd6:	a021                	j	80003dde <itrunc+0x6c>
    80003dd8:	0491                	addi	s1,s1,4
    80003dda:	01248963          	beq	s1,s2,80003dec <itrunc+0x7a>
      if(a[j])
    80003dde:	408c                	lw	a1,0(s1)
    80003de0:	dde5                	beqz	a1,80003dd8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003de2:	0009a503          	lw	a0,0(s3)
    80003de6:	9fbff0ef          	jal	800037e0 <bfree>
    80003dea:	b7fd                	j	80003dd8 <itrunc+0x66>
    brelse(bp);
    80003dec:	8552                	mv	a0,s4
    80003dee:	907ff0ef          	jal	800036f4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003df2:	0809a583          	lw	a1,128(s3)
    80003df6:	0009a503          	lw	a0,0(s3)
    80003dfa:	9e7ff0ef          	jal	800037e0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003dfe:	0809a023          	sw	zero,128(s3)
    80003e02:	6a02                	ld	s4,0(sp)
    80003e04:	b75d                	j	80003daa <itrunc+0x38>

0000000080003e06 <iput>:
{
    80003e06:	1101                	addi	sp,sp,-32
    80003e08:	ec06                	sd	ra,24(sp)
    80003e0a:	e822                	sd	s0,16(sp)
    80003e0c:	e426                	sd	s1,8(sp)
    80003e0e:	1000                	addi	s0,sp,32
    80003e10:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e12:	0001e517          	auipc	a0,0x1e
    80003e16:	42e50513          	addi	a0,a0,1070 # 80022240 <itable>
    80003e1a:	e0ffc0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e1e:	4498                	lw	a4,8(s1)
    80003e20:	4785                	li	a5,1
    80003e22:	02f70063          	beq	a4,a5,80003e42 <iput+0x3c>
  ip->ref--;
    80003e26:	449c                	lw	a5,8(s1)
    80003e28:	37fd                	addiw	a5,a5,-1
    80003e2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e2c:	0001e517          	auipc	a0,0x1e
    80003e30:	41450513          	addi	a0,a0,1044 # 80022240 <itable>
    80003e34:	e89fc0ef          	jal	80000cbc <release>
}
    80003e38:	60e2                	ld	ra,24(sp)
    80003e3a:	6442                	ld	s0,16(sp)
    80003e3c:	64a2                	ld	s1,8(sp)
    80003e3e:	6105                	addi	sp,sp,32
    80003e40:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e42:	40bc                	lw	a5,64(s1)
    80003e44:	d3ed                	beqz	a5,80003e26 <iput+0x20>
    80003e46:	04a49783          	lh	a5,74(s1)
    80003e4a:	fff1                	bnez	a5,80003e26 <iput+0x20>
    80003e4c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e4e:	01048793          	addi	a5,s1,16
    80003e52:	893e                	mv	s2,a5
    80003e54:	853e                	mv	a0,a5
    80003e56:	2cf000ef          	jal	80004924 <acquiresleep>
    release(&itable.lock);
    80003e5a:	0001e517          	auipc	a0,0x1e
    80003e5e:	3e650513          	addi	a0,a0,998 # 80022240 <itable>
    80003e62:	e5bfc0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003e66:	8526                	mv	a0,s1
    80003e68:	f0bff0ef          	jal	80003d72 <itrunc>
    ip->type = 0;
    80003e6c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e70:	8526                	mv	a0,s1
    80003e72:	d5fff0ef          	jal	80003bd0 <iupdate>
    ip->valid = 0;
    80003e76:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	2ef000ef          	jal	8000496a <releasesleep>
    acquire(&itable.lock);
    80003e80:	0001e517          	auipc	a0,0x1e
    80003e84:	3c050513          	addi	a0,a0,960 # 80022240 <itable>
    80003e88:	da1fc0ef          	jal	80000c28 <acquire>
    80003e8c:	6902                	ld	s2,0(sp)
    80003e8e:	bf61                	j	80003e26 <iput+0x20>

0000000080003e90 <iunlockput>:
{
    80003e90:	1101                	addi	sp,sp,-32
    80003e92:	ec06                	sd	ra,24(sp)
    80003e94:	e822                	sd	s0,16(sp)
    80003e96:	e426                	sd	s1,8(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e9c:	e97ff0ef          	jal	80003d32 <iunlock>
  iput(ip);
    80003ea0:	8526                	mv	a0,s1
    80003ea2:	f65ff0ef          	jal	80003e06 <iput>
}
    80003ea6:	60e2                	ld	ra,24(sp)
    80003ea8:	6442                	ld	s0,16(sp)
    80003eaa:	64a2                	ld	s1,8(sp)
    80003eac:	6105                	addi	sp,sp,32
    80003eae:	8082                	ret

0000000080003eb0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003eb0:	0001e717          	auipc	a4,0x1e
    80003eb4:	37c72703          	lw	a4,892(a4) # 8002222c <sb+0xc>
    80003eb8:	4785                	li	a5,1
    80003eba:	0ae7fe63          	bgeu	a5,a4,80003f76 <ireclaim+0xc6>
{
    80003ebe:	7139                	addi	sp,sp,-64
    80003ec0:	fc06                	sd	ra,56(sp)
    80003ec2:	f822                	sd	s0,48(sp)
    80003ec4:	f426                	sd	s1,40(sp)
    80003ec6:	f04a                	sd	s2,32(sp)
    80003ec8:	ec4e                	sd	s3,24(sp)
    80003eca:	e852                	sd	s4,16(sp)
    80003ecc:	e456                	sd	s5,8(sp)
    80003ece:	e05a                	sd	s6,0(sp)
    80003ed0:	0080                	addi	s0,sp,64
    80003ed2:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ed4:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ed6:	0001ea17          	auipc	s4,0x1e
    80003eda:	34aa0a13          	addi	s4,s4,842 # 80022220 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003ede:	00005b17          	auipc	s6,0x5
    80003ee2:	a1ab0b13          	addi	s6,s6,-1510 # 800088f8 <etext+0x8f8>
    80003ee6:	a099                	j	80003f2c <ireclaim+0x7c>
    80003ee8:	85ce                	mv	a1,s3
    80003eea:	855a                	mv	a0,s6
    80003eec:	e0efc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003ef0:	85ce                	mv	a1,s3
    80003ef2:	8556                	mv	a0,s5
    80003ef4:	b1fff0ef          	jal	80003a12 <iget>
    80003ef8:	89aa                	mv	s3,a0
    brelse(bp);
    80003efa:	854a                	mv	a0,s2
    80003efc:	ff8ff0ef          	jal	800036f4 <brelse>
    if (ip) {
    80003f00:	00098f63          	beqz	s3,80003f1e <ireclaim+0x6e>
      begin_op();
    80003f04:	78c000ef          	jal	80004690 <begin_op>
      ilock(ip);
    80003f08:	854e                	mv	a0,s3
    80003f0a:	d7bff0ef          	jal	80003c84 <ilock>
      iunlock(ip);
    80003f0e:	854e                	mv	a0,s3
    80003f10:	e23ff0ef          	jal	80003d32 <iunlock>
      iput(ip);
    80003f14:	854e                	mv	a0,s3
    80003f16:	ef1ff0ef          	jal	80003e06 <iput>
      end_op();
    80003f1a:	7e6000ef          	jal	80004700 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003f1e:	0485                	addi	s1,s1,1
    80003f20:	00ca2703          	lw	a4,12(s4)
    80003f24:	0004879b          	sext.w	a5,s1
    80003f28:	02e7fd63          	bgeu	a5,a4,80003f62 <ireclaim+0xb2>
    80003f2c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003f30:	0044d593          	srli	a1,s1,0x4
    80003f34:	018a2783          	lw	a5,24(s4)
    80003f38:	9dbd                	addw	a1,a1,a5
    80003f3a:	8556                	mv	a0,s5
    80003f3c:	eb0ff0ef          	jal	800035ec <bread>
    80003f40:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003f42:	05850793          	addi	a5,a0,88
    80003f46:	00f9f713          	andi	a4,s3,15
    80003f4a:	071a                	slli	a4,a4,0x6
    80003f4c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003f4e:	00079703          	lh	a4,0(a5)
    80003f52:	c701                	beqz	a4,80003f5a <ireclaim+0xaa>
    80003f54:	00679783          	lh	a5,6(a5)
    80003f58:	dbc1                	beqz	a5,80003ee8 <ireclaim+0x38>
    brelse(bp);
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	f98ff0ef          	jal	800036f4 <brelse>
    if (ip) {
    80003f60:	bf7d                	j	80003f1e <ireclaim+0x6e>
}
    80003f62:	70e2                	ld	ra,56(sp)
    80003f64:	7442                	ld	s0,48(sp)
    80003f66:	74a2                	ld	s1,40(sp)
    80003f68:	7902                	ld	s2,32(sp)
    80003f6a:	69e2                	ld	s3,24(sp)
    80003f6c:	6a42                	ld	s4,16(sp)
    80003f6e:	6aa2                	ld	s5,8(sp)
    80003f70:	6b02                	ld	s6,0(sp)
    80003f72:	6121                	addi	sp,sp,64
    80003f74:	8082                	ret
    80003f76:	8082                	ret

0000000080003f78 <fsinit>:
fsinit(int dev) {
    80003f78:	1101                	addi	sp,sp,-32
    80003f7a:	ec06                	sd	ra,24(sp)
    80003f7c:	e822                	sd	s0,16(sp)
    80003f7e:	e426                	sd	s1,8(sp)
    80003f80:	e04a                	sd	s2,0(sp)
    80003f82:	1000                	addi	s0,sp,32
    80003f84:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f86:	4585                	li	a1,1
    80003f88:	e64ff0ef          	jal	800035ec <bread>
    80003f8c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f8e:	02000613          	li	a2,32
    80003f92:	05850593          	addi	a1,a0,88
    80003f96:	0001e517          	auipc	a0,0x1e
    80003f9a:	28a50513          	addi	a0,a0,650 # 80022220 <sb>
    80003f9e:	dbbfc0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	f50ff0ef          	jal	800036f4 <brelse>
  if(sb.magic != FSMAGIC)
    80003fa8:	0001e717          	auipc	a4,0x1e
    80003fac:	27872703          	lw	a4,632(a4) # 80022220 <sb>
    80003fb0:	102037b7          	lui	a5,0x10203
    80003fb4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003fb8:	02f71263          	bne	a4,a5,80003fdc <fsinit+0x64>
  initlog(dev, &sb);
    80003fbc:	0001e597          	auipc	a1,0x1e
    80003fc0:	26458593          	addi	a1,a1,612 # 80022220 <sb>
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	648000ef          	jal	8000460e <initlog>
  ireclaim(dev);
    80003fca:	854a                	mv	a0,s2
    80003fcc:	ee5ff0ef          	jal	80003eb0 <ireclaim>
}
    80003fd0:	60e2                	ld	ra,24(sp)
    80003fd2:	6442                	ld	s0,16(sp)
    80003fd4:	64a2                	ld	s1,8(sp)
    80003fd6:	6902                	ld	s2,0(sp)
    80003fd8:	6105                	addi	sp,sp,32
    80003fda:	8082                	ret
    panic("invalid file system");
    80003fdc:	00005517          	auipc	a0,0x5
    80003fe0:	93c50513          	addi	a0,a0,-1732 # 80008918 <etext+0x918>
    80003fe4:	841fc0ef          	jal	80000824 <panic>

0000000080003fe8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fe8:	1141                	addi	sp,sp,-16
    80003fea:	e406                	sd	ra,8(sp)
    80003fec:	e022                	sd	s0,0(sp)
    80003fee:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ff0:	411c                	lw	a5,0(a0)
    80003ff2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ff4:	415c                	lw	a5,4(a0)
    80003ff6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ff8:	04451783          	lh	a5,68(a0)
    80003ffc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004000:	04a51783          	lh	a5,74(a0)
    80004004:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004008:	04c56783          	lwu	a5,76(a0)
    8000400c:	e99c                	sd	a5,16(a1)
}
    8000400e:	60a2                	ld	ra,8(sp)
    80004010:	6402                	ld	s0,0(sp)
    80004012:	0141                	addi	sp,sp,16
    80004014:	8082                	ret

0000000080004016 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004016:	457c                	lw	a5,76(a0)
    80004018:	0ed7e663          	bltu	a5,a3,80004104 <readi+0xee>
{
    8000401c:	7159                	addi	sp,sp,-112
    8000401e:	f486                	sd	ra,104(sp)
    80004020:	f0a2                	sd	s0,96(sp)
    80004022:	eca6                	sd	s1,88(sp)
    80004024:	e0d2                	sd	s4,64(sp)
    80004026:	fc56                	sd	s5,56(sp)
    80004028:	f85a                	sd	s6,48(sp)
    8000402a:	f45e                	sd	s7,40(sp)
    8000402c:	1880                	addi	s0,sp,112
    8000402e:	8b2a                	mv	s6,a0
    80004030:	8bae                	mv	s7,a1
    80004032:	8a32                	mv	s4,a2
    80004034:	84b6                	mv	s1,a3
    80004036:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004038:	9f35                	addw	a4,a4,a3
    return 0;
    8000403a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000403c:	0ad76b63          	bltu	a4,a3,800040f2 <readi+0xdc>
    80004040:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004042:	00e7f463          	bgeu	a5,a4,8000404a <readi+0x34>
    n = ip->size - off;
    80004046:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000404a:	080a8b63          	beqz	s5,800040e0 <readi+0xca>
    8000404e:	e8ca                	sd	s2,80(sp)
    80004050:	f062                	sd	s8,32(sp)
    80004052:	ec66                	sd	s9,24(sp)
    80004054:	e86a                	sd	s10,16(sp)
    80004056:	e46e                	sd	s11,8(sp)
    80004058:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000405e:	5c7d                	li	s8,-1
    80004060:	a80d                	j	80004092 <readi+0x7c>
    80004062:	020d1d93          	slli	s11,s10,0x20
    80004066:	020ddd93          	srli	s11,s11,0x20
    8000406a:	05890613          	addi	a2,s2,88
    8000406e:	86ee                	mv	a3,s11
    80004070:	963e                	add	a2,a2,a5
    80004072:	85d2                	mv	a1,s4
    80004074:	855e                	mv	a0,s7
    80004076:	a63fe0ef          	jal	80002ad8 <either_copyout>
    8000407a:	05850363          	beq	a0,s8,800040c0 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000407e:	854a                	mv	a0,s2
    80004080:	e74ff0ef          	jal	800036f4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004084:	013d09bb          	addw	s3,s10,s3
    80004088:	009d04bb          	addw	s1,s10,s1
    8000408c:	9a6e                	add	s4,s4,s11
    8000408e:	0559f363          	bgeu	s3,s5,800040d4 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004092:	00a4d59b          	srliw	a1,s1,0xa
    80004096:	855a                	mv	a0,s6
    80004098:	8bbff0ef          	jal	80003952 <bmap>
    8000409c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000409e:	c139                	beqz	a0,800040e4 <readi+0xce>
    bp = bread(ip->dev, addr);
    800040a0:	000b2503          	lw	a0,0(s6)
    800040a4:	d48ff0ef          	jal	800035ec <bread>
    800040a8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040aa:	3ff4f793          	andi	a5,s1,1023
    800040ae:	40fc873b          	subw	a4,s9,a5
    800040b2:	413a86bb          	subw	a3,s5,s3
    800040b6:	8d3a                	mv	s10,a4
    800040b8:	fae6f5e3          	bgeu	a3,a4,80004062 <readi+0x4c>
    800040bc:	8d36                	mv	s10,a3
    800040be:	b755                	j	80004062 <readi+0x4c>
      brelse(bp);
    800040c0:	854a                	mv	a0,s2
    800040c2:	e32ff0ef          	jal	800036f4 <brelse>
      tot = -1;
    800040c6:	59fd                	li	s3,-1
      break;
    800040c8:	6946                	ld	s2,80(sp)
    800040ca:	7c02                	ld	s8,32(sp)
    800040cc:	6ce2                	ld	s9,24(sp)
    800040ce:	6d42                	ld	s10,16(sp)
    800040d0:	6da2                	ld	s11,8(sp)
    800040d2:	a831                	j	800040ee <readi+0xd8>
    800040d4:	6946                	ld	s2,80(sp)
    800040d6:	7c02                	ld	s8,32(sp)
    800040d8:	6ce2                	ld	s9,24(sp)
    800040da:	6d42                	ld	s10,16(sp)
    800040dc:	6da2                	ld	s11,8(sp)
    800040de:	a801                	j	800040ee <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040e0:	89d6                	mv	s3,s5
    800040e2:	a031                	j	800040ee <readi+0xd8>
    800040e4:	6946                	ld	s2,80(sp)
    800040e6:	7c02                	ld	s8,32(sp)
    800040e8:	6ce2                	ld	s9,24(sp)
    800040ea:	6d42                	ld	s10,16(sp)
    800040ec:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800040ee:	854e                	mv	a0,s3
    800040f0:	69a6                	ld	s3,72(sp)
}
    800040f2:	70a6                	ld	ra,104(sp)
    800040f4:	7406                	ld	s0,96(sp)
    800040f6:	64e6                	ld	s1,88(sp)
    800040f8:	6a06                	ld	s4,64(sp)
    800040fa:	7ae2                	ld	s5,56(sp)
    800040fc:	7b42                	ld	s6,48(sp)
    800040fe:	7ba2                	ld	s7,40(sp)
    80004100:	6165                	addi	sp,sp,112
    80004102:	8082                	ret
    return 0;
    80004104:	4501                	li	a0,0
}
    80004106:	8082                	ret

0000000080004108 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004108:	457c                	lw	a5,76(a0)
    8000410a:	0ed7eb63          	bltu	a5,a3,80004200 <writei+0xf8>
{
    8000410e:	7159                	addi	sp,sp,-112
    80004110:	f486                	sd	ra,104(sp)
    80004112:	f0a2                	sd	s0,96(sp)
    80004114:	e8ca                	sd	s2,80(sp)
    80004116:	e0d2                	sd	s4,64(sp)
    80004118:	fc56                	sd	s5,56(sp)
    8000411a:	f85a                	sd	s6,48(sp)
    8000411c:	f45e                	sd	s7,40(sp)
    8000411e:	1880                	addi	s0,sp,112
    80004120:	8aaa                	mv	s5,a0
    80004122:	8bae                	mv	s7,a1
    80004124:	8a32                	mv	s4,a2
    80004126:	8936                	mv	s2,a3
    80004128:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000412a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000412e:	00043737          	lui	a4,0x43
    80004132:	0cf76963          	bltu	a4,a5,80004204 <writei+0xfc>
    80004136:	0cd7e763          	bltu	a5,a3,80004204 <writei+0xfc>
    8000413a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000413c:	0a0b0a63          	beqz	s6,800041f0 <writei+0xe8>
    80004140:	eca6                	sd	s1,88(sp)
    80004142:	f062                	sd	s8,32(sp)
    80004144:	ec66                	sd	s9,24(sp)
    80004146:	e86a                	sd	s10,16(sp)
    80004148:	e46e                	sd	s11,8(sp)
    8000414a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000414c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004150:	5c7d                	li	s8,-1
    80004152:	a825                	j	8000418a <writei+0x82>
    80004154:	020d1d93          	slli	s11,s10,0x20
    80004158:	020ddd93          	srli	s11,s11,0x20
    8000415c:	05848513          	addi	a0,s1,88
    80004160:	86ee                	mv	a3,s11
    80004162:	8652                	mv	a2,s4
    80004164:	85de                	mv	a1,s7
    80004166:	953e                	add	a0,a0,a5
    80004168:	9bbfe0ef          	jal	80002b22 <either_copyin>
    8000416c:	05850663          	beq	a0,s8,800041b8 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004170:	8526                	mv	a0,s1
    80004172:	6b8000ef          	jal	8000482a <log_write>
    brelse(bp);
    80004176:	8526                	mv	a0,s1
    80004178:	d7cff0ef          	jal	800036f4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000417c:	013d09bb          	addw	s3,s10,s3
    80004180:	012d093b          	addw	s2,s10,s2
    80004184:	9a6e                	add	s4,s4,s11
    80004186:	0369fc63          	bgeu	s3,s6,800041be <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    8000418a:	00a9559b          	srliw	a1,s2,0xa
    8000418e:	8556                	mv	a0,s5
    80004190:	fc2ff0ef          	jal	80003952 <bmap>
    80004194:	85aa                	mv	a1,a0
    if(addr == 0)
    80004196:	c505                	beqz	a0,800041be <writei+0xb6>
    bp = bread(ip->dev, addr);
    80004198:	000aa503          	lw	a0,0(s5)
    8000419c:	c50ff0ef          	jal	800035ec <bread>
    800041a0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041a2:	3ff97793          	andi	a5,s2,1023
    800041a6:	40fc873b          	subw	a4,s9,a5
    800041aa:	413b06bb          	subw	a3,s6,s3
    800041ae:	8d3a                	mv	s10,a4
    800041b0:	fae6f2e3          	bgeu	a3,a4,80004154 <writei+0x4c>
    800041b4:	8d36                	mv	s10,a3
    800041b6:	bf79                	j	80004154 <writei+0x4c>
      brelse(bp);
    800041b8:	8526                	mv	a0,s1
    800041ba:	d3aff0ef          	jal	800036f4 <brelse>
  }

  if(off > ip->size)
    800041be:	04caa783          	lw	a5,76(s5)
    800041c2:	0327f963          	bgeu	a5,s2,800041f4 <writei+0xec>
    ip->size = off;
    800041c6:	052aa623          	sw	s2,76(s5)
    800041ca:	64e6                	ld	s1,88(sp)
    800041cc:	7c02                	ld	s8,32(sp)
    800041ce:	6ce2                	ld	s9,24(sp)
    800041d0:	6d42                	ld	s10,16(sp)
    800041d2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041d4:	8556                	mv	a0,s5
    800041d6:	9fbff0ef          	jal	80003bd0 <iupdate>

  return tot;
    800041da:	854e                	mv	a0,s3
    800041dc:	69a6                	ld	s3,72(sp)
}
    800041de:	70a6                	ld	ra,104(sp)
    800041e0:	7406                	ld	s0,96(sp)
    800041e2:	6946                	ld	s2,80(sp)
    800041e4:	6a06                	ld	s4,64(sp)
    800041e6:	7ae2                	ld	s5,56(sp)
    800041e8:	7b42                	ld	s6,48(sp)
    800041ea:	7ba2                	ld	s7,40(sp)
    800041ec:	6165                	addi	sp,sp,112
    800041ee:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041f0:	89da                	mv	s3,s6
    800041f2:	b7cd                	j	800041d4 <writei+0xcc>
    800041f4:	64e6                	ld	s1,88(sp)
    800041f6:	7c02                	ld	s8,32(sp)
    800041f8:	6ce2                	ld	s9,24(sp)
    800041fa:	6d42                	ld	s10,16(sp)
    800041fc:	6da2                	ld	s11,8(sp)
    800041fe:	bfd9                	j	800041d4 <writei+0xcc>
    return -1;
    80004200:	557d                	li	a0,-1
}
    80004202:	8082                	ret
    return -1;
    80004204:	557d                	li	a0,-1
    80004206:	bfe1                	j	800041de <writei+0xd6>

0000000080004208 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004208:	1141                	addi	sp,sp,-16
    8000420a:	e406                	sd	ra,8(sp)
    8000420c:	e022                	sd	s0,0(sp)
    8000420e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004210:	4639                	li	a2,14
    80004212:	bbbfc0ef          	jal	80000dcc <strncmp>
}
    80004216:	60a2                	ld	ra,8(sp)
    80004218:	6402                	ld	s0,0(sp)
    8000421a:	0141                	addi	sp,sp,16
    8000421c:	8082                	ret

000000008000421e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000421e:	711d                	addi	sp,sp,-96
    80004220:	ec86                	sd	ra,88(sp)
    80004222:	e8a2                	sd	s0,80(sp)
    80004224:	e4a6                	sd	s1,72(sp)
    80004226:	e0ca                	sd	s2,64(sp)
    80004228:	fc4e                	sd	s3,56(sp)
    8000422a:	f852                	sd	s4,48(sp)
    8000422c:	f456                	sd	s5,40(sp)
    8000422e:	f05a                	sd	s6,32(sp)
    80004230:	ec5e                	sd	s7,24(sp)
    80004232:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004234:	04451703          	lh	a4,68(a0)
    80004238:	4785                	li	a5,1
    8000423a:	00f71f63          	bne	a4,a5,80004258 <dirlookup+0x3a>
    8000423e:	892a                	mv	s2,a0
    80004240:	8aae                	mv	s5,a1
    80004242:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004244:	457c                	lw	a5,76(a0)
    80004246:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004248:	fa040a13          	addi	s4,s0,-96
    8000424c:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000424e:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004252:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004254:	e39d                	bnez	a5,8000427a <dirlookup+0x5c>
    80004256:	a8b9                	j	800042b4 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80004258:	00004517          	auipc	a0,0x4
    8000425c:	6d850513          	addi	a0,a0,1752 # 80008930 <etext+0x930>
    80004260:	dc4fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80004264:	00004517          	auipc	a0,0x4
    80004268:	6e450513          	addi	a0,a0,1764 # 80008948 <etext+0x948>
    8000426c:	db8fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004270:	24c1                	addiw	s1,s1,16
    80004272:	04c92783          	lw	a5,76(s2)
    80004276:	02f4fe63          	bgeu	s1,a5,800042b2 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000427a:	874e                	mv	a4,s3
    8000427c:	86a6                	mv	a3,s1
    8000427e:	8652                	mv	a2,s4
    80004280:	4581                	li	a1,0
    80004282:	854a                	mv	a0,s2
    80004284:	d93ff0ef          	jal	80004016 <readi>
    80004288:	fd351ee3          	bne	a0,s3,80004264 <dirlookup+0x46>
    if(de.inum == 0)
    8000428c:	fa045783          	lhu	a5,-96(s0)
    80004290:	d3e5                	beqz	a5,80004270 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80004292:	85da                	mv	a1,s6
    80004294:	8556                	mv	a0,s5
    80004296:	f73ff0ef          	jal	80004208 <namecmp>
    8000429a:	f979                	bnez	a0,80004270 <dirlookup+0x52>
      if(poff)
    8000429c:	000b8463          	beqz	s7,800042a4 <dirlookup+0x86>
        *poff = off;
    800042a0:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800042a4:	fa045583          	lhu	a1,-96(s0)
    800042a8:	00092503          	lw	a0,0(s2)
    800042ac:	f66ff0ef          	jal	80003a12 <iget>
    800042b0:	a011                	j	800042b4 <dirlookup+0x96>
  return 0;
    800042b2:	4501                	li	a0,0
}
    800042b4:	60e6                	ld	ra,88(sp)
    800042b6:	6446                	ld	s0,80(sp)
    800042b8:	64a6                	ld	s1,72(sp)
    800042ba:	6906                	ld	s2,64(sp)
    800042bc:	79e2                	ld	s3,56(sp)
    800042be:	7a42                	ld	s4,48(sp)
    800042c0:	7aa2                	ld	s5,40(sp)
    800042c2:	7b02                	ld	s6,32(sp)
    800042c4:	6be2                	ld	s7,24(sp)
    800042c6:	6125                	addi	sp,sp,96
    800042c8:	8082                	ret

00000000800042ca <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042ca:	711d                	addi	sp,sp,-96
    800042cc:	ec86                	sd	ra,88(sp)
    800042ce:	e8a2                	sd	s0,80(sp)
    800042d0:	e4a6                	sd	s1,72(sp)
    800042d2:	e0ca                	sd	s2,64(sp)
    800042d4:	fc4e                	sd	s3,56(sp)
    800042d6:	f852                	sd	s4,48(sp)
    800042d8:	f456                	sd	s5,40(sp)
    800042da:	f05a                	sd	s6,32(sp)
    800042dc:	ec5e                	sd	s7,24(sp)
    800042de:	e862                	sd	s8,16(sp)
    800042e0:	e466                	sd	s9,8(sp)
    800042e2:	e06a                	sd	s10,0(sp)
    800042e4:	1080                	addi	s0,sp,96
    800042e6:	84aa                	mv	s1,a0
    800042e8:	8b2e                	mv	s6,a1
    800042ea:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042ec:	00054703          	lbu	a4,0(a0)
    800042f0:	02f00793          	li	a5,47
    800042f4:	00f70f63          	beq	a4,a5,80004312 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042f8:	fbefd0ef          	jal	80001ab6 <myproc>
    800042fc:	15853503          	ld	a0,344(a0)
    80004300:	94fff0ef          	jal	80003c4e <idup>
    80004304:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004306:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    8000430a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000430c:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000430e:	4b85                	li	s7,1
    80004310:	a879                	j	800043ae <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004312:	4585                	li	a1,1
    80004314:	852e                	mv	a0,a1
    80004316:	efcff0ef          	jal	80003a12 <iget>
    8000431a:	8a2a                	mv	s4,a0
    8000431c:	b7ed                	j	80004306 <namex+0x3c>
      iunlockput(ip);
    8000431e:	8552                	mv	a0,s4
    80004320:	b71ff0ef          	jal	80003e90 <iunlockput>
      return 0;
    80004324:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004326:	8552                	mv	a0,s4
    80004328:	60e6                	ld	ra,88(sp)
    8000432a:	6446                	ld	s0,80(sp)
    8000432c:	64a6                	ld	s1,72(sp)
    8000432e:	6906                	ld	s2,64(sp)
    80004330:	79e2                	ld	s3,56(sp)
    80004332:	7a42                	ld	s4,48(sp)
    80004334:	7aa2                	ld	s5,40(sp)
    80004336:	7b02                	ld	s6,32(sp)
    80004338:	6be2                	ld	s7,24(sp)
    8000433a:	6c42                	ld	s8,16(sp)
    8000433c:	6ca2                	ld	s9,8(sp)
    8000433e:	6d02                	ld	s10,0(sp)
    80004340:	6125                	addi	sp,sp,96
    80004342:	8082                	ret
      iunlock(ip);
    80004344:	8552                	mv	a0,s4
    80004346:	9edff0ef          	jal	80003d32 <iunlock>
      return ip;
    8000434a:	bff1                	j	80004326 <namex+0x5c>
      iunlockput(ip);
    8000434c:	8552                	mv	a0,s4
    8000434e:	b43ff0ef          	jal	80003e90 <iunlockput>
      return 0;
    80004352:	8a4a                	mv	s4,s2
    80004354:	bfc9                	j	80004326 <namex+0x5c>
  len = path - s;
    80004356:	40990633          	sub	a2,s2,s1
    8000435a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000435e:	09ac5463          	bge	s8,s10,800043e6 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80004362:	8666                	mv	a2,s9
    80004364:	85a6                	mv	a1,s1
    80004366:	8556                	mv	a0,s5
    80004368:	9f1fc0ef          	jal	80000d58 <memmove>
    8000436c:	84ca                	mv	s1,s2
  while(*path == '/')
    8000436e:	0004c783          	lbu	a5,0(s1)
    80004372:	01379763          	bne	a5,s3,80004380 <namex+0xb6>
    path++;
    80004376:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004378:	0004c783          	lbu	a5,0(s1)
    8000437c:	ff378de3          	beq	a5,s3,80004376 <namex+0xac>
    ilock(ip);
    80004380:	8552                	mv	a0,s4
    80004382:	903ff0ef          	jal	80003c84 <ilock>
    if(ip->type != T_DIR){
    80004386:	044a1783          	lh	a5,68(s4)
    8000438a:	f9779ae3          	bne	a5,s7,8000431e <namex+0x54>
    if(nameiparent && *path == '\0'){
    8000438e:	000b0563          	beqz	s6,80004398 <namex+0xce>
    80004392:	0004c783          	lbu	a5,0(s1)
    80004396:	d7dd                	beqz	a5,80004344 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004398:	4601                	li	a2,0
    8000439a:	85d6                	mv	a1,s5
    8000439c:	8552                	mv	a0,s4
    8000439e:	e81ff0ef          	jal	8000421e <dirlookup>
    800043a2:	892a                	mv	s2,a0
    800043a4:	d545                	beqz	a0,8000434c <namex+0x82>
    iunlockput(ip);
    800043a6:	8552                	mv	a0,s4
    800043a8:	ae9ff0ef          	jal	80003e90 <iunlockput>
    ip = next;
    800043ac:	8a4a                	mv	s4,s2
  while(*path == '/')
    800043ae:	0004c783          	lbu	a5,0(s1)
    800043b2:	01379763          	bne	a5,s3,800043c0 <namex+0xf6>
    path++;
    800043b6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043b8:	0004c783          	lbu	a5,0(s1)
    800043bc:	ff378de3          	beq	a5,s3,800043b6 <namex+0xec>
  if(*path == 0)
    800043c0:	cf8d                	beqz	a5,800043fa <namex+0x130>
  while(*path != '/' && *path != 0)
    800043c2:	0004c783          	lbu	a5,0(s1)
    800043c6:	fd178713          	addi	a4,a5,-47
    800043ca:	cb19                	beqz	a4,800043e0 <namex+0x116>
    800043cc:	cb91                	beqz	a5,800043e0 <namex+0x116>
    800043ce:	8926                	mv	s2,s1
    path++;
    800043d0:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    800043d2:	00094783          	lbu	a5,0(s2)
    800043d6:	fd178713          	addi	a4,a5,-47
    800043da:	df35                	beqz	a4,80004356 <namex+0x8c>
    800043dc:	fbf5                	bnez	a5,800043d0 <namex+0x106>
    800043de:	bfa5                	j	80004356 <namex+0x8c>
    800043e0:	8926                	mv	s2,s1
  len = path - s;
    800043e2:	4d01                	li	s10,0
    800043e4:	4601                	li	a2,0
    memmove(name, s, len);
    800043e6:	2601                	sext.w	a2,a2
    800043e8:	85a6                	mv	a1,s1
    800043ea:	8556                	mv	a0,s5
    800043ec:	96dfc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    800043f0:	9d56                	add	s10,s10,s5
    800043f2:	000d0023          	sb	zero,0(s10)
    800043f6:	84ca                	mv	s1,s2
    800043f8:	bf9d                	j	8000436e <namex+0xa4>
  if(nameiparent){
    800043fa:	f20b06e3          	beqz	s6,80004326 <namex+0x5c>
    iput(ip);
    800043fe:	8552                	mv	a0,s4
    80004400:	a07ff0ef          	jal	80003e06 <iput>
    return 0;
    80004404:	4a01                	li	s4,0
    80004406:	b705                	j	80004326 <namex+0x5c>

0000000080004408 <dirlink>:
{
    80004408:	715d                	addi	sp,sp,-80
    8000440a:	e486                	sd	ra,72(sp)
    8000440c:	e0a2                	sd	s0,64(sp)
    8000440e:	f84a                	sd	s2,48(sp)
    80004410:	ec56                	sd	s5,24(sp)
    80004412:	e85a                	sd	s6,16(sp)
    80004414:	0880                	addi	s0,sp,80
    80004416:	892a                	mv	s2,a0
    80004418:	8aae                	mv	s5,a1
    8000441a:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000441c:	4601                	li	a2,0
    8000441e:	e01ff0ef          	jal	8000421e <dirlookup>
    80004422:	ed1d                	bnez	a0,80004460 <dirlink+0x58>
    80004424:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004426:	04c92483          	lw	s1,76(s2)
    8000442a:	c4b9                	beqz	s1,80004478 <dirlink+0x70>
    8000442c:	f44e                	sd	s3,40(sp)
    8000442e:	f052                	sd	s4,32(sp)
    80004430:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004432:	fb040a13          	addi	s4,s0,-80
    80004436:	49c1                	li	s3,16
    80004438:	874e                	mv	a4,s3
    8000443a:	86a6                	mv	a3,s1
    8000443c:	8652                	mv	a2,s4
    8000443e:	4581                	li	a1,0
    80004440:	854a                	mv	a0,s2
    80004442:	bd5ff0ef          	jal	80004016 <readi>
    80004446:	03351163          	bne	a0,s3,80004468 <dirlink+0x60>
    if(de.inum == 0)
    8000444a:	fb045783          	lhu	a5,-80(s0)
    8000444e:	c39d                	beqz	a5,80004474 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004450:	24c1                	addiw	s1,s1,16
    80004452:	04c92783          	lw	a5,76(s2)
    80004456:	fef4e1e3          	bltu	s1,a5,80004438 <dirlink+0x30>
    8000445a:	79a2                	ld	s3,40(sp)
    8000445c:	7a02                	ld	s4,32(sp)
    8000445e:	a829                	j	80004478 <dirlink+0x70>
    iput(ip);
    80004460:	9a7ff0ef          	jal	80003e06 <iput>
    return -1;
    80004464:	557d                	li	a0,-1
    80004466:	a83d                	j	800044a4 <dirlink+0x9c>
      panic("dirlink read");
    80004468:	00004517          	auipc	a0,0x4
    8000446c:	4f050513          	addi	a0,a0,1264 # 80008958 <etext+0x958>
    80004470:	bb4fc0ef          	jal	80000824 <panic>
    80004474:	79a2                	ld	s3,40(sp)
    80004476:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004478:	4639                	li	a2,14
    8000447a:	85d6                	mv	a1,s5
    8000447c:	fb240513          	addi	a0,s0,-78
    80004480:	987fc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80004484:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004488:	4741                	li	a4,16
    8000448a:	86a6                	mv	a3,s1
    8000448c:	fb040613          	addi	a2,s0,-80
    80004490:	4581                	li	a1,0
    80004492:	854a                	mv	a0,s2
    80004494:	c75ff0ef          	jal	80004108 <writei>
    80004498:	1541                	addi	a0,a0,-16
    8000449a:	00a03533          	snez	a0,a0
    8000449e:	40a0053b          	negw	a0,a0
    800044a2:	74e2                	ld	s1,56(sp)
}
    800044a4:	60a6                	ld	ra,72(sp)
    800044a6:	6406                	ld	s0,64(sp)
    800044a8:	7942                	ld	s2,48(sp)
    800044aa:	6ae2                	ld	s5,24(sp)
    800044ac:	6b42                	ld	s6,16(sp)
    800044ae:	6161                	addi	sp,sp,80
    800044b0:	8082                	ret

00000000800044b2 <namei>:

struct inode*
namei(char *path)
{
    800044b2:	1101                	addi	sp,sp,-32
    800044b4:	ec06                	sd	ra,24(sp)
    800044b6:	e822                	sd	s0,16(sp)
    800044b8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044ba:	fe040613          	addi	a2,s0,-32
    800044be:	4581                	li	a1,0
    800044c0:	e0bff0ef          	jal	800042ca <namex>
}
    800044c4:	60e2                	ld	ra,24(sp)
    800044c6:	6442                	ld	s0,16(sp)
    800044c8:	6105                	addi	sp,sp,32
    800044ca:	8082                	ret

00000000800044cc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044cc:	1141                	addi	sp,sp,-16
    800044ce:	e406                	sd	ra,8(sp)
    800044d0:	e022                	sd	s0,0(sp)
    800044d2:	0800                	addi	s0,sp,16
    800044d4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044d6:	4585                	li	a1,1
    800044d8:	df3ff0ef          	jal	800042ca <namex>
}
    800044dc:	60a2                	ld	ra,8(sp)
    800044de:	6402                	ld	s0,0(sp)
    800044e0:	0141                	addi	sp,sp,16
    800044e2:	8082                	ret

00000000800044e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044e4:	1101                	addi	sp,sp,-32
    800044e6:	ec06                	sd	ra,24(sp)
    800044e8:	e822                	sd	s0,16(sp)
    800044ea:	e426                	sd	s1,8(sp)
    800044ec:	e04a                	sd	s2,0(sp)
    800044ee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044f0:	0001f917          	auipc	s2,0x1f
    800044f4:	7f890913          	addi	s2,s2,2040 # 80023ce8 <log>
    800044f8:	01892583          	lw	a1,24(s2)
    800044fc:	02492503          	lw	a0,36(s2)
    80004500:	8ecff0ef          	jal	800035ec <bread>
    80004504:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004506:	02892603          	lw	a2,40(s2)
    8000450a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000450c:	00c05f63          	blez	a2,8000452a <write_head+0x46>
    80004510:	00020717          	auipc	a4,0x20
    80004514:	80470713          	addi	a4,a4,-2044 # 80023d14 <log+0x2c>
    80004518:	87aa                	mv	a5,a0
    8000451a:	060a                	slli	a2,a2,0x2
    8000451c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000451e:	4314                	lw	a3,0(a4)
    80004520:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004522:	0711                	addi	a4,a4,4
    80004524:	0791                	addi	a5,a5,4
    80004526:	fec79ce3          	bne	a5,a2,8000451e <write_head+0x3a>
  }
  bwrite(buf);
    8000452a:	8526                	mv	a0,s1
    8000452c:	996ff0ef          	jal	800036c2 <bwrite>
  brelse(buf);
    80004530:	8526                	mv	a0,s1
    80004532:	9c2ff0ef          	jal	800036f4 <brelse>
}
    80004536:	60e2                	ld	ra,24(sp)
    80004538:	6442                	ld	s0,16(sp)
    8000453a:	64a2                	ld	s1,8(sp)
    8000453c:	6902                	ld	s2,0(sp)
    8000453e:	6105                	addi	sp,sp,32
    80004540:	8082                	ret

0000000080004542 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004542:	0001f797          	auipc	a5,0x1f
    80004546:	7ce7a783          	lw	a5,1998(a5) # 80023d10 <log+0x28>
    8000454a:	0cf05163          	blez	a5,8000460c <install_trans+0xca>
{
    8000454e:	715d                	addi	sp,sp,-80
    80004550:	e486                	sd	ra,72(sp)
    80004552:	e0a2                	sd	s0,64(sp)
    80004554:	fc26                	sd	s1,56(sp)
    80004556:	f84a                	sd	s2,48(sp)
    80004558:	f44e                	sd	s3,40(sp)
    8000455a:	f052                	sd	s4,32(sp)
    8000455c:	ec56                	sd	s5,24(sp)
    8000455e:	e85a                	sd	s6,16(sp)
    80004560:	e45e                	sd	s7,8(sp)
    80004562:	e062                	sd	s8,0(sp)
    80004564:	0880                	addi	s0,sp,80
    80004566:	8b2a                	mv	s6,a0
    80004568:	0001fa97          	auipc	s5,0x1f
    8000456c:	7aca8a93          	addi	s5,s5,1964 # 80023d14 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004570:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004572:	00004c17          	auipc	s8,0x4
    80004576:	3f6c0c13          	addi	s8,s8,1014 # 80008968 <etext+0x968>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000457a:	0001fa17          	auipc	s4,0x1f
    8000457e:	76ea0a13          	addi	s4,s4,1902 # 80023ce8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004582:	40000b93          	li	s7,1024
    80004586:	a025                	j	800045ae <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004588:	000aa603          	lw	a2,0(s5)
    8000458c:	85ce                	mv	a1,s3
    8000458e:	8562                	mv	a0,s8
    80004590:	f6bfb0ef          	jal	800004fa <printf>
    80004594:	a839                	j	800045b2 <install_trans+0x70>
    brelse(lbuf);
    80004596:	854a                	mv	a0,s2
    80004598:	95cff0ef          	jal	800036f4 <brelse>
    brelse(dbuf);
    8000459c:	8526                	mv	a0,s1
    8000459e:	956ff0ef          	jal	800036f4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045a2:	2985                	addiw	s3,s3,1
    800045a4:	0a91                	addi	s5,s5,4
    800045a6:	028a2783          	lw	a5,40(s4)
    800045aa:	04f9d563          	bge	s3,a5,800045f4 <install_trans+0xb2>
    if(recovering) {
    800045ae:	fc0b1de3          	bnez	s6,80004588 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045b2:	018a2583          	lw	a1,24(s4)
    800045b6:	013585bb          	addw	a1,a1,s3
    800045ba:	2585                	addiw	a1,a1,1
    800045bc:	024a2503          	lw	a0,36(s4)
    800045c0:	82cff0ef          	jal	800035ec <bread>
    800045c4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045c6:	000aa583          	lw	a1,0(s5)
    800045ca:	024a2503          	lw	a0,36(s4)
    800045ce:	81eff0ef          	jal	800035ec <bread>
    800045d2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045d4:	865e                	mv	a2,s7
    800045d6:	05890593          	addi	a1,s2,88
    800045da:	05850513          	addi	a0,a0,88
    800045de:	f7afc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    800045e2:	8526                	mv	a0,s1
    800045e4:	8deff0ef          	jal	800036c2 <bwrite>
    if(recovering == 0)
    800045e8:	fa0b17e3          	bnez	s6,80004596 <install_trans+0x54>
      bunpin(dbuf);
    800045ec:	8526                	mv	a0,s1
    800045ee:	9beff0ef          	jal	800037ac <bunpin>
    800045f2:	b755                	j	80004596 <install_trans+0x54>
}
    800045f4:	60a6                	ld	ra,72(sp)
    800045f6:	6406                	ld	s0,64(sp)
    800045f8:	74e2                	ld	s1,56(sp)
    800045fa:	7942                	ld	s2,48(sp)
    800045fc:	79a2                	ld	s3,40(sp)
    800045fe:	7a02                	ld	s4,32(sp)
    80004600:	6ae2                	ld	s5,24(sp)
    80004602:	6b42                	ld	s6,16(sp)
    80004604:	6ba2                	ld	s7,8(sp)
    80004606:	6c02                	ld	s8,0(sp)
    80004608:	6161                	addi	sp,sp,80
    8000460a:	8082                	ret
    8000460c:	8082                	ret

000000008000460e <initlog>:
{
    8000460e:	7179                	addi	sp,sp,-48
    80004610:	f406                	sd	ra,40(sp)
    80004612:	f022                	sd	s0,32(sp)
    80004614:	ec26                	sd	s1,24(sp)
    80004616:	e84a                	sd	s2,16(sp)
    80004618:	e44e                	sd	s3,8(sp)
    8000461a:	1800                	addi	s0,sp,48
    8000461c:	84aa                	mv	s1,a0
    8000461e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004620:	0001f917          	auipc	s2,0x1f
    80004624:	6c890913          	addi	s2,s2,1736 # 80023ce8 <log>
    80004628:	00004597          	auipc	a1,0x4
    8000462c:	36058593          	addi	a1,a1,864 # 80008988 <etext+0x988>
    80004630:	854a                	mv	a0,s2
    80004632:	d6cfc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80004636:	0149a583          	lw	a1,20(s3)
    8000463a:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    8000463e:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80004642:	8526                	mv	a0,s1
    80004644:	fa9fe0ef          	jal	800035ec <bread>
  log.lh.n = lh->n;
    80004648:	4d30                	lw	a2,88(a0)
    8000464a:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    8000464e:	00c05f63          	blez	a2,8000466c <initlog+0x5e>
    80004652:	87aa                	mv	a5,a0
    80004654:	0001f717          	auipc	a4,0x1f
    80004658:	6c070713          	addi	a4,a4,1728 # 80023d14 <log+0x2c>
    8000465c:	060a                	slli	a2,a2,0x2
    8000465e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004660:	4ff4                	lw	a3,92(a5)
    80004662:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004664:	0791                	addi	a5,a5,4
    80004666:	0711                	addi	a4,a4,4
    80004668:	fec79ce3          	bne	a5,a2,80004660 <initlog+0x52>
  brelse(buf);
    8000466c:	888ff0ef          	jal	800036f4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004670:	4505                	li	a0,1
    80004672:	ed1ff0ef          	jal	80004542 <install_trans>
  log.lh.n = 0;
    80004676:	0001f797          	auipc	a5,0x1f
    8000467a:	6807ad23          	sw	zero,1690(a5) # 80023d10 <log+0x28>
  write_head(); // clear the log
    8000467e:	e67ff0ef          	jal	800044e4 <write_head>
}
    80004682:	70a2                	ld	ra,40(sp)
    80004684:	7402                	ld	s0,32(sp)
    80004686:	64e2                	ld	s1,24(sp)
    80004688:	6942                	ld	s2,16(sp)
    8000468a:	69a2                	ld	s3,8(sp)
    8000468c:	6145                	addi	sp,sp,48
    8000468e:	8082                	ret

0000000080004690 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004690:	1101                	addi	sp,sp,-32
    80004692:	ec06                	sd	ra,24(sp)
    80004694:	e822                	sd	s0,16(sp)
    80004696:	e426                	sd	s1,8(sp)
    80004698:	e04a                	sd	s2,0(sp)
    8000469a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000469c:	0001f517          	auipc	a0,0x1f
    800046a0:	64c50513          	addi	a0,a0,1612 # 80023ce8 <log>
    800046a4:	d84fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    800046a8:	0001f497          	auipc	s1,0x1f
    800046ac:	64048493          	addi	s1,s1,1600 # 80023ce8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800046b0:	4979                	li	s2,30
    800046b2:	a029                	j	800046bc <begin_op+0x2c>
      sleep(&log, &log.lock);
    800046b4:	85a6                	mv	a1,s1
    800046b6:	8526                	mv	a0,s1
    800046b8:	8c6fe0ef          	jal	8000277e <sleep>
    if(log.committing){
    800046bc:	509c                	lw	a5,32(s1)
    800046be:	fbfd                	bnez	a5,800046b4 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800046c0:	4cd8                	lw	a4,28(s1)
    800046c2:	2705                	addiw	a4,a4,1
    800046c4:	0027179b          	slliw	a5,a4,0x2
    800046c8:	9fb9                	addw	a5,a5,a4
    800046ca:	0017979b          	slliw	a5,a5,0x1
    800046ce:	5494                	lw	a3,40(s1)
    800046d0:	9fb5                	addw	a5,a5,a3
    800046d2:	00f95763          	bge	s2,a5,800046e0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046d6:	85a6                	mv	a1,s1
    800046d8:	8526                	mv	a0,s1
    800046da:	8a4fe0ef          	jal	8000277e <sleep>
    800046de:	bff9                	j	800046bc <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800046e0:	0001f797          	auipc	a5,0x1f
    800046e4:	62e7a223          	sw	a4,1572(a5) # 80023d04 <log+0x1c>
      release(&log.lock);
    800046e8:	0001f517          	auipc	a0,0x1f
    800046ec:	60050513          	addi	a0,a0,1536 # 80023ce8 <log>
    800046f0:	dccfc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    800046f4:	60e2                	ld	ra,24(sp)
    800046f6:	6442                	ld	s0,16(sp)
    800046f8:	64a2                	ld	s1,8(sp)
    800046fa:	6902                	ld	s2,0(sp)
    800046fc:	6105                	addi	sp,sp,32
    800046fe:	8082                	ret

0000000080004700 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004700:	7139                	addi	sp,sp,-64
    80004702:	fc06                	sd	ra,56(sp)
    80004704:	f822                	sd	s0,48(sp)
    80004706:	f426                	sd	s1,40(sp)
    80004708:	f04a                	sd	s2,32(sp)
    8000470a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000470c:	0001f497          	auipc	s1,0x1f
    80004710:	5dc48493          	addi	s1,s1,1500 # 80023ce8 <log>
    80004714:	8526                	mv	a0,s1
    80004716:	d12fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    8000471a:	4cdc                	lw	a5,28(s1)
    8000471c:	37fd                	addiw	a5,a5,-1
    8000471e:	893e                	mv	s2,a5
    80004720:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004722:	509c                	lw	a5,32(s1)
    80004724:	e7b1                	bnez	a5,80004770 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004726:	04091e63          	bnez	s2,80004782 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    8000472a:	0001f497          	auipc	s1,0x1f
    8000472e:	5be48493          	addi	s1,s1,1470 # 80023ce8 <log>
    80004732:	4785                	li	a5,1
    80004734:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004736:	8526                	mv	a0,s1
    80004738:	d84fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000473c:	549c                	lw	a5,40(s1)
    8000473e:	06f04463          	bgtz	a5,800047a6 <end_op+0xa6>
    acquire(&log.lock);
    80004742:	0001f517          	auipc	a0,0x1f
    80004746:	5a650513          	addi	a0,a0,1446 # 80023ce8 <log>
    8000474a:	cdefc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    8000474e:	0001f797          	auipc	a5,0x1f
    80004752:	5a07ad23          	sw	zero,1466(a5) # 80023d08 <log+0x20>
    wakeup(&log);
    80004756:	0001f517          	auipc	a0,0x1f
    8000475a:	59250513          	addi	a0,a0,1426 # 80023ce8 <log>
    8000475e:	86cfe0ef          	jal	800027ca <wakeup>
    release(&log.lock);
    80004762:	0001f517          	auipc	a0,0x1f
    80004766:	58650513          	addi	a0,a0,1414 # 80023ce8 <log>
    8000476a:	d52fc0ef          	jal	80000cbc <release>
}
    8000476e:	a035                	j	8000479a <end_op+0x9a>
    80004770:	ec4e                	sd	s3,24(sp)
    80004772:	e852                	sd	s4,16(sp)
    80004774:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004776:	00004517          	auipc	a0,0x4
    8000477a:	21a50513          	addi	a0,a0,538 # 80008990 <etext+0x990>
    8000477e:	8a6fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80004782:	0001f517          	auipc	a0,0x1f
    80004786:	56650513          	addi	a0,a0,1382 # 80023ce8 <log>
    8000478a:	840fe0ef          	jal	800027ca <wakeup>
  release(&log.lock);
    8000478e:	0001f517          	auipc	a0,0x1f
    80004792:	55a50513          	addi	a0,a0,1370 # 80023ce8 <log>
    80004796:	d26fc0ef          	jal	80000cbc <release>
}
    8000479a:	70e2                	ld	ra,56(sp)
    8000479c:	7442                	ld	s0,48(sp)
    8000479e:	74a2                	ld	s1,40(sp)
    800047a0:	7902                	ld	s2,32(sp)
    800047a2:	6121                	addi	sp,sp,64
    800047a4:	8082                	ret
    800047a6:	ec4e                	sd	s3,24(sp)
    800047a8:	e852                	sd	s4,16(sp)
    800047aa:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ac:	0001fa97          	auipc	s5,0x1f
    800047b0:	568a8a93          	addi	s5,s5,1384 # 80023d14 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047b4:	0001fa17          	auipc	s4,0x1f
    800047b8:	534a0a13          	addi	s4,s4,1332 # 80023ce8 <log>
    800047bc:	018a2583          	lw	a1,24(s4)
    800047c0:	012585bb          	addw	a1,a1,s2
    800047c4:	2585                	addiw	a1,a1,1
    800047c6:	024a2503          	lw	a0,36(s4)
    800047ca:	e23fe0ef          	jal	800035ec <bread>
    800047ce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047d0:	000aa583          	lw	a1,0(s5)
    800047d4:	024a2503          	lw	a0,36(s4)
    800047d8:	e15fe0ef          	jal	800035ec <bread>
    800047dc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047de:	40000613          	li	a2,1024
    800047e2:	05850593          	addi	a1,a0,88
    800047e6:	05848513          	addi	a0,s1,88
    800047ea:	d6efc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    800047ee:	8526                	mv	a0,s1
    800047f0:	ed3fe0ef          	jal	800036c2 <bwrite>
    brelse(from);
    800047f4:	854e                	mv	a0,s3
    800047f6:	efffe0ef          	jal	800036f4 <brelse>
    brelse(to);
    800047fa:	8526                	mv	a0,s1
    800047fc:	ef9fe0ef          	jal	800036f4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004800:	2905                	addiw	s2,s2,1
    80004802:	0a91                	addi	s5,s5,4
    80004804:	028a2783          	lw	a5,40(s4)
    80004808:	faf94ae3          	blt	s2,a5,800047bc <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000480c:	cd9ff0ef          	jal	800044e4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004810:	4501                	li	a0,0
    80004812:	d31ff0ef          	jal	80004542 <install_trans>
    log.lh.n = 0;
    80004816:	0001f797          	auipc	a5,0x1f
    8000481a:	4e07ad23          	sw	zero,1274(a5) # 80023d10 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000481e:	cc7ff0ef          	jal	800044e4 <write_head>
    80004822:	69e2                	ld	s3,24(sp)
    80004824:	6a42                	ld	s4,16(sp)
    80004826:	6aa2                	ld	s5,8(sp)
    80004828:	bf29                	j	80004742 <end_op+0x42>

000000008000482a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000482a:	1101                	addi	sp,sp,-32
    8000482c:	ec06                	sd	ra,24(sp)
    8000482e:	e822                	sd	s0,16(sp)
    80004830:	e426                	sd	s1,8(sp)
    80004832:	1000                	addi	s0,sp,32
    80004834:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004836:	0001f517          	auipc	a0,0x1f
    8000483a:	4b250513          	addi	a0,a0,1202 # 80023ce8 <log>
    8000483e:	beafc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004842:	0001f617          	auipc	a2,0x1f
    80004846:	4ce62603          	lw	a2,1230(a2) # 80023d10 <log+0x28>
    8000484a:	47f5                	li	a5,29
    8000484c:	04c7cd63          	blt	a5,a2,800048a6 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004850:	0001f797          	auipc	a5,0x1f
    80004854:	4b47a783          	lw	a5,1204(a5) # 80023d04 <log+0x1c>
    80004858:	04f05d63          	blez	a5,800048b2 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000485c:	4781                	li	a5,0
    8000485e:	06c05063          	blez	a2,800048be <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004862:	44cc                	lw	a1,12(s1)
    80004864:	0001f717          	auipc	a4,0x1f
    80004868:	4b070713          	addi	a4,a4,1200 # 80023d14 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000486c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000486e:	4314                	lw	a3,0(a4)
    80004870:	04b68763          	beq	a3,a1,800048be <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004874:	2785                	addiw	a5,a5,1
    80004876:	0711                	addi	a4,a4,4
    80004878:	fef61be3          	bne	a2,a5,8000486e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000487c:	060a                	slli	a2,a2,0x2
    8000487e:	02060613          	addi	a2,a2,32
    80004882:	0001f797          	auipc	a5,0x1f
    80004886:	46678793          	addi	a5,a5,1126 # 80023ce8 <log>
    8000488a:	97b2                	add	a5,a5,a2
    8000488c:	44d8                	lw	a4,12(s1)
    8000488e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004890:	8526                	mv	a0,s1
    80004892:	ee7fe0ef          	jal	80003778 <bpin>
    log.lh.n++;
    80004896:	0001f717          	auipc	a4,0x1f
    8000489a:	45270713          	addi	a4,a4,1106 # 80023ce8 <log>
    8000489e:	571c                	lw	a5,40(a4)
    800048a0:	2785                	addiw	a5,a5,1
    800048a2:	d71c                	sw	a5,40(a4)
    800048a4:	a815                	j	800048d8 <log_write+0xae>
    panic("too big a transaction");
    800048a6:	00004517          	auipc	a0,0x4
    800048aa:	0fa50513          	addi	a0,a0,250 # 800089a0 <etext+0x9a0>
    800048ae:	f77fb0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    800048b2:	00004517          	auipc	a0,0x4
    800048b6:	10650513          	addi	a0,a0,262 # 800089b8 <etext+0x9b8>
    800048ba:	f6bfb0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800048be:	00279693          	slli	a3,a5,0x2
    800048c2:	02068693          	addi	a3,a3,32
    800048c6:	0001f717          	auipc	a4,0x1f
    800048ca:	42270713          	addi	a4,a4,1058 # 80023ce8 <log>
    800048ce:	9736                	add	a4,a4,a3
    800048d0:	44d4                	lw	a3,12(s1)
    800048d2:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048d4:	faf60ee3          	beq	a2,a5,80004890 <log_write+0x66>
  }
  release(&log.lock);
    800048d8:	0001f517          	auipc	a0,0x1f
    800048dc:	41050513          	addi	a0,a0,1040 # 80023ce8 <log>
    800048e0:	bdcfc0ef          	jal	80000cbc <release>
}
    800048e4:	60e2                	ld	ra,24(sp)
    800048e6:	6442                	ld	s0,16(sp)
    800048e8:	64a2                	ld	s1,8(sp)
    800048ea:	6105                	addi	sp,sp,32
    800048ec:	8082                	ret

00000000800048ee <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048ee:	1101                	addi	sp,sp,-32
    800048f0:	ec06                	sd	ra,24(sp)
    800048f2:	e822                	sd	s0,16(sp)
    800048f4:	e426                	sd	s1,8(sp)
    800048f6:	e04a                	sd	s2,0(sp)
    800048f8:	1000                	addi	s0,sp,32
    800048fa:	84aa                	mv	s1,a0
    800048fc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048fe:	00004597          	auipc	a1,0x4
    80004902:	0da58593          	addi	a1,a1,218 # 800089d8 <etext+0x9d8>
    80004906:	0521                	addi	a0,a0,8
    80004908:	a96fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    8000490c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004910:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004914:	0204a423          	sw	zero,40(s1)
}
    80004918:	60e2                	ld	ra,24(sp)
    8000491a:	6442                	ld	s0,16(sp)
    8000491c:	64a2                	ld	s1,8(sp)
    8000491e:	6902                	ld	s2,0(sp)
    80004920:	6105                	addi	sp,sp,32
    80004922:	8082                	ret

0000000080004924 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004924:	1101                	addi	sp,sp,-32
    80004926:	ec06                	sd	ra,24(sp)
    80004928:	e822                	sd	s0,16(sp)
    8000492a:	e426                	sd	s1,8(sp)
    8000492c:	e04a                	sd	s2,0(sp)
    8000492e:	1000                	addi	s0,sp,32
    80004930:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004932:	00850913          	addi	s2,a0,8
    80004936:	854a                	mv	a0,s2
    80004938:	af0fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000493c:	409c                	lw	a5,0(s1)
    8000493e:	c799                	beqz	a5,8000494c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004940:	85ca                	mv	a1,s2
    80004942:	8526                	mv	a0,s1
    80004944:	e3bfd0ef          	jal	8000277e <sleep>
  while (lk->locked) {
    80004948:	409c                	lw	a5,0(s1)
    8000494a:	fbfd                	bnez	a5,80004940 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000494c:	4785                	li	a5,1
    8000494e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004950:	966fd0ef          	jal	80001ab6 <myproc>
    80004954:	591c                	lw	a5,48(a0)
    80004956:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004958:	854a                	mv	a0,s2
    8000495a:	b62fc0ef          	jal	80000cbc <release>
}
    8000495e:	60e2                	ld	ra,24(sp)
    80004960:	6442                	ld	s0,16(sp)
    80004962:	64a2                	ld	s1,8(sp)
    80004964:	6902                	ld	s2,0(sp)
    80004966:	6105                	addi	sp,sp,32
    80004968:	8082                	ret

000000008000496a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000496a:	1101                	addi	sp,sp,-32
    8000496c:	ec06                	sd	ra,24(sp)
    8000496e:	e822                	sd	s0,16(sp)
    80004970:	e426                	sd	s1,8(sp)
    80004972:	e04a                	sd	s2,0(sp)
    80004974:	1000                	addi	s0,sp,32
    80004976:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004978:	00850913          	addi	s2,a0,8
    8000497c:	854a                	mv	a0,s2
    8000497e:	aaafc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004982:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004986:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000498a:	8526                	mv	a0,s1
    8000498c:	e3ffd0ef          	jal	800027ca <wakeup>
  release(&lk->lk);
    80004990:	854a                	mv	a0,s2
    80004992:	b2afc0ef          	jal	80000cbc <release>
}
    80004996:	60e2                	ld	ra,24(sp)
    80004998:	6442                	ld	s0,16(sp)
    8000499a:	64a2                	ld	s1,8(sp)
    8000499c:	6902                	ld	s2,0(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049a2:	7179                	addi	sp,sp,-48
    800049a4:	f406                	sd	ra,40(sp)
    800049a6:	f022                	sd	s0,32(sp)
    800049a8:	ec26                	sd	s1,24(sp)
    800049aa:	e84a                	sd	s2,16(sp)
    800049ac:	1800                	addi	s0,sp,48
    800049ae:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049b0:	00850913          	addi	s2,a0,8
    800049b4:	854a                	mv	a0,s2
    800049b6:	a72fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049ba:	409c                	lw	a5,0(s1)
    800049bc:	ef81                	bnez	a5,800049d4 <holdingsleep+0x32>
    800049be:	4481                	li	s1,0
  release(&lk->lk);
    800049c0:	854a                	mv	a0,s2
    800049c2:	afafc0ef          	jal	80000cbc <release>
  return r;
}
    800049c6:	8526                	mv	a0,s1
    800049c8:	70a2                	ld	ra,40(sp)
    800049ca:	7402                	ld	s0,32(sp)
    800049cc:	64e2                	ld	s1,24(sp)
    800049ce:	6942                	ld	s2,16(sp)
    800049d0:	6145                	addi	sp,sp,48
    800049d2:	8082                	ret
    800049d4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800049d6:	0284a983          	lw	s3,40(s1)
    800049da:	8dcfd0ef          	jal	80001ab6 <myproc>
    800049de:	5904                	lw	s1,48(a0)
    800049e0:	413484b3          	sub	s1,s1,s3
    800049e4:	0014b493          	seqz	s1,s1
    800049e8:	69a2                	ld	s3,8(sp)
    800049ea:	bfd9                	j	800049c0 <holdingsleep+0x1e>

00000000800049ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049ec:	1141                	addi	sp,sp,-16
    800049ee:	e406                	sd	ra,8(sp)
    800049f0:	e022                	sd	s0,0(sp)
    800049f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049f4:	00004597          	auipc	a1,0x4
    800049f8:	ff458593          	addi	a1,a1,-12 # 800089e8 <etext+0x9e8>
    800049fc:	0001f517          	auipc	a0,0x1f
    80004a00:	43450513          	addi	a0,a0,1076 # 80023e30 <ftable>
    80004a04:	99afc0ef          	jal	80000b9e <initlock>
}
    80004a08:	60a2                	ld	ra,8(sp)
    80004a0a:	6402                	ld	s0,0(sp)
    80004a0c:	0141                	addi	sp,sp,16
    80004a0e:	8082                	ret

0000000080004a10 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	e426                	sd	s1,8(sp)
    80004a18:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a1a:	0001f517          	auipc	a0,0x1f
    80004a1e:	41650513          	addi	a0,a0,1046 # 80023e30 <ftable>
    80004a22:	a06fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a26:	0001f497          	auipc	s1,0x1f
    80004a2a:	42248493          	addi	s1,s1,1058 # 80023e48 <ftable+0x18>
    80004a2e:	00020717          	auipc	a4,0x20
    80004a32:	3ba70713          	addi	a4,a4,954 # 80024de8 <disk>
    if(f->ref == 0){
    80004a36:	40dc                	lw	a5,4(s1)
    80004a38:	cf89                	beqz	a5,80004a52 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a3a:	02848493          	addi	s1,s1,40
    80004a3e:	fee49ce3          	bne	s1,a4,80004a36 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a42:	0001f517          	auipc	a0,0x1f
    80004a46:	3ee50513          	addi	a0,a0,1006 # 80023e30 <ftable>
    80004a4a:	a72fc0ef          	jal	80000cbc <release>
  return 0;
    80004a4e:	4481                	li	s1,0
    80004a50:	a809                	j	80004a62 <filealloc+0x52>
      f->ref = 1;
    80004a52:	4785                	li	a5,1
    80004a54:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a56:	0001f517          	auipc	a0,0x1f
    80004a5a:	3da50513          	addi	a0,a0,986 # 80023e30 <ftable>
    80004a5e:	a5efc0ef          	jal	80000cbc <release>
}
    80004a62:	8526                	mv	a0,s1
    80004a64:	60e2                	ld	ra,24(sp)
    80004a66:	6442                	ld	s0,16(sp)
    80004a68:	64a2                	ld	s1,8(sp)
    80004a6a:	6105                	addi	sp,sp,32
    80004a6c:	8082                	ret

0000000080004a6e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a6e:	1101                	addi	sp,sp,-32
    80004a70:	ec06                	sd	ra,24(sp)
    80004a72:	e822                	sd	s0,16(sp)
    80004a74:	e426                	sd	s1,8(sp)
    80004a76:	1000                	addi	s0,sp,32
    80004a78:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a7a:	0001f517          	auipc	a0,0x1f
    80004a7e:	3b650513          	addi	a0,a0,950 # 80023e30 <ftable>
    80004a82:	9a6fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004a86:	40dc                	lw	a5,4(s1)
    80004a88:	02f05063          	blez	a5,80004aa8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004a8c:	2785                	addiw	a5,a5,1
    80004a8e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a90:	0001f517          	auipc	a0,0x1f
    80004a94:	3a050513          	addi	a0,a0,928 # 80023e30 <ftable>
    80004a98:	a24fc0ef          	jal	80000cbc <release>
  return f;
}
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	60e2                	ld	ra,24(sp)
    80004aa0:	6442                	ld	s0,16(sp)
    80004aa2:	64a2                	ld	s1,8(sp)
    80004aa4:	6105                	addi	sp,sp,32
    80004aa6:	8082                	ret
    panic("filedup");
    80004aa8:	00004517          	auipc	a0,0x4
    80004aac:	f4850513          	addi	a0,a0,-184 # 800089f0 <etext+0x9f0>
    80004ab0:	d75fb0ef          	jal	80000824 <panic>

0000000080004ab4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ab4:	7139                	addi	sp,sp,-64
    80004ab6:	fc06                	sd	ra,56(sp)
    80004ab8:	f822                	sd	s0,48(sp)
    80004aba:	f426                	sd	s1,40(sp)
    80004abc:	0080                	addi	s0,sp,64
    80004abe:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ac0:	0001f517          	auipc	a0,0x1f
    80004ac4:	37050513          	addi	a0,a0,880 # 80023e30 <ftable>
    80004ac8:	960fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004acc:	40dc                	lw	a5,4(s1)
    80004ace:	04f05a63          	blez	a5,80004b22 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004ad2:	37fd                	addiw	a5,a5,-1
    80004ad4:	c0dc                	sw	a5,4(s1)
    80004ad6:	06f04063          	bgtz	a5,80004b36 <fileclose+0x82>
    80004ada:	f04a                	sd	s2,32(sp)
    80004adc:	ec4e                	sd	s3,24(sp)
    80004ade:	e852                	sd	s4,16(sp)
    80004ae0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ae2:	0004a903          	lw	s2,0(s1)
    80004ae6:	0094c783          	lbu	a5,9(s1)
    80004aea:	89be                	mv	s3,a5
    80004aec:	689c                	ld	a5,16(s1)
    80004aee:	8a3e                	mv	s4,a5
    80004af0:	6c9c                	ld	a5,24(s1)
    80004af2:	8abe                	mv	s5,a5
  f->ref = 0;
    80004af4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004af8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004afc:	0001f517          	auipc	a0,0x1f
    80004b00:	33450513          	addi	a0,a0,820 # 80023e30 <ftable>
    80004b04:	9b8fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004b08:	4785                	li	a5,1
    80004b0a:	04f90163          	beq	s2,a5,80004b4c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b0e:	ffe9079b          	addiw	a5,s2,-2
    80004b12:	4705                	li	a4,1
    80004b14:	04f77563          	bgeu	a4,a5,80004b5e <fileclose+0xaa>
    80004b18:	7902                	ld	s2,32(sp)
    80004b1a:	69e2                	ld	s3,24(sp)
    80004b1c:	6a42                	ld	s4,16(sp)
    80004b1e:	6aa2                	ld	s5,8(sp)
    80004b20:	a00d                	j	80004b42 <fileclose+0x8e>
    80004b22:	f04a                	sd	s2,32(sp)
    80004b24:	ec4e                	sd	s3,24(sp)
    80004b26:	e852                	sd	s4,16(sp)
    80004b28:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004b2a:	00004517          	auipc	a0,0x4
    80004b2e:	ece50513          	addi	a0,a0,-306 # 800089f8 <etext+0x9f8>
    80004b32:	cf3fb0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004b36:	0001f517          	auipc	a0,0x1f
    80004b3a:	2fa50513          	addi	a0,a0,762 # 80023e30 <ftable>
    80004b3e:	97efc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004b42:	70e2                	ld	ra,56(sp)
    80004b44:	7442                	ld	s0,48(sp)
    80004b46:	74a2                	ld	s1,40(sp)
    80004b48:	6121                	addi	sp,sp,64
    80004b4a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b4c:	85ce                	mv	a1,s3
    80004b4e:	8552                	mv	a0,s4
    80004b50:	380000ef          	jal	80004ed0 <pipeclose>
    80004b54:	7902                	ld	s2,32(sp)
    80004b56:	69e2                	ld	s3,24(sp)
    80004b58:	6a42                	ld	s4,16(sp)
    80004b5a:	6aa2                	ld	s5,8(sp)
    80004b5c:	b7dd                	j	80004b42 <fileclose+0x8e>
    begin_op();
    80004b5e:	b33ff0ef          	jal	80004690 <begin_op>
    iput(ff.ip);
    80004b62:	8556                	mv	a0,s5
    80004b64:	aa2ff0ef          	jal	80003e06 <iput>
    end_op();
    80004b68:	b99ff0ef          	jal	80004700 <end_op>
    80004b6c:	7902                	ld	s2,32(sp)
    80004b6e:	69e2                	ld	s3,24(sp)
    80004b70:	6a42                	ld	s4,16(sp)
    80004b72:	6aa2                	ld	s5,8(sp)
    80004b74:	b7f9                	j	80004b42 <fileclose+0x8e>

0000000080004b76 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b76:	715d                	addi	sp,sp,-80
    80004b78:	e486                	sd	ra,72(sp)
    80004b7a:	e0a2                	sd	s0,64(sp)
    80004b7c:	fc26                	sd	s1,56(sp)
    80004b7e:	f052                	sd	s4,32(sp)
    80004b80:	0880                	addi	s0,sp,80
    80004b82:	84aa                	mv	s1,a0
    80004b84:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004b86:	f31fc0ef          	jal	80001ab6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b8a:	409c                	lw	a5,0(s1)
    80004b8c:	37f9                	addiw	a5,a5,-2
    80004b8e:	4705                	li	a4,1
    80004b90:	04f76263          	bltu	a4,a5,80004bd4 <filestat+0x5e>
    80004b94:	f84a                	sd	s2,48(sp)
    80004b96:	f44e                	sd	s3,40(sp)
    80004b98:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004b9a:	6c88                	ld	a0,24(s1)
    80004b9c:	8e8ff0ef          	jal	80003c84 <ilock>
    stati(f->ip, &st);
    80004ba0:	fb840913          	addi	s2,s0,-72
    80004ba4:	85ca                	mv	a1,s2
    80004ba6:	6c88                	ld	a0,24(s1)
    80004ba8:	c40ff0ef          	jal	80003fe8 <stati>
    iunlock(f->ip);
    80004bac:	6c88                	ld	a0,24(s1)
    80004bae:	984ff0ef          	jal	80003d32 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bb2:	46e1                	li	a3,24
    80004bb4:	864a                	mv	a2,s2
    80004bb6:	85d2                	mv	a1,s4
    80004bb8:	0589b503          	ld	a0,88(s3)
    80004bbc:	a99fc0ef          	jal	80001654 <copyout>
    80004bc0:	41f5551b          	sraiw	a0,a0,0x1f
    80004bc4:	7942                	ld	s2,48(sp)
    80004bc6:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004bc8:	60a6                	ld	ra,72(sp)
    80004bca:	6406                	ld	s0,64(sp)
    80004bcc:	74e2                	ld	s1,56(sp)
    80004bce:	7a02                	ld	s4,32(sp)
    80004bd0:	6161                	addi	sp,sp,80
    80004bd2:	8082                	ret
  return -1;
    80004bd4:	557d                	li	a0,-1
    80004bd6:	bfcd                	j	80004bc8 <filestat+0x52>

0000000080004bd8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bd8:	7179                	addi	sp,sp,-48
    80004bda:	f406                	sd	ra,40(sp)
    80004bdc:	f022                	sd	s0,32(sp)
    80004bde:	e84a                	sd	s2,16(sp)
    80004be0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004be2:	00854783          	lbu	a5,8(a0)
    80004be6:	cfd1                	beqz	a5,80004c82 <fileread+0xaa>
    80004be8:	ec26                	sd	s1,24(sp)
    80004bea:	e44e                	sd	s3,8(sp)
    80004bec:	84aa                	mv	s1,a0
    80004bee:	892e                	mv	s2,a1
    80004bf0:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf2:	411c                	lw	a5,0(a0)
    80004bf4:	4705                	li	a4,1
    80004bf6:	04e78363          	beq	a5,a4,80004c3c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bfa:	470d                	li	a4,3
    80004bfc:	04e78763          	beq	a5,a4,80004c4a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c00:	4709                	li	a4,2
    80004c02:	06e79a63          	bne	a5,a4,80004c76 <fileread+0x9e>
    ilock(f->ip);
    80004c06:	6d08                	ld	a0,24(a0)
    80004c08:	87cff0ef          	jal	80003c84 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c0c:	874e                	mv	a4,s3
    80004c0e:	5094                	lw	a3,32(s1)
    80004c10:	864a                	mv	a2,s2
    80004c12:	4585                	li	a1,1
    80004c14:	6c88                	ld	a0,24(s1)
    80004c16:	c00ff0ef          	jal	80004016 <readi>
    80004c1a:	892a                	mv	s2,a0
    80004c1c:	00a05563          	blez	a0,80004c26 <fileread+0x4e>
      f->off += r;
    80004c20:	509c                	lw	a5,32(s1)
    80004c22:	9fa9                	addw	a5,a5,a0
    80004c24:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c26:	6c88                	ld	a0,24(s1)
    80004c28:	90aff0ef          	jal	80003d32 <iunlock>
    80004c2c:	64e2                	ld	s1,24(sp)
    80004c2e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004c30:	854a                	mv	a0,s2
    80004c32:	70a2                	ld	ra,40(sp)
    80004c34:	7402                	ld	s0,32(sp)
    80004c36:	6942                	ld	s2,16(sp)
    80004c38:	6145                	addi	sp,sp,48
    80004c3a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c3c:	6908                	ld	a0,16(a0)
    80004c3e:	3f8000ef          	jal	80005036 <piperead>
    80004c42:	892a                	mv	s2,a0
    80004c44:	64e2                	ld	s1,24(sp)
    80004c46:	69a2                	ld	s3,8(sp)
    80004c48:	b7e5                	j	80004c30 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c4a:	02451783          	lh	a5,36(a0)
    80004c4e:	03079693          	slli	a3,a5,0x30
    80004c52:	92c1                	srli	a3,a3,0x30
    80004c54:	4725                	li	a4,9
    80004c56:	02d76963          	bltu	a4,a3,80004c88 <fileread+0xb0>
    80004c5a:	0792                	slli	a5,a5,0x4
    80004c5c:	0001f717          	auipc	a4,0x1f
    80004c60:	13470713          	addi	a4,a4,308 # 80023d90 <devsw>
    80004c64:	97ba                	add	a5,a5,a4
    80004c66:	639c                	ld	a5,0(a5)
    80004c68:	c78d                	beqz	a5,80004c92 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004c6a:	4505                	li	a0,1
    80004c6c:	9782                	jalr	a5
    80004c6e:	892a                	mv	s2,a0
    80004c70:	64e2                	ld	s1,24(sp)
    80004c72:	69a2                	ld	s3,8(sp)
    80004c74:	bf75                	j	80004c30 <fileread+0x58>
    panic("fileread");
    80004c76:	00004517          	auipc	a0,0x4
    80004c7a:	d9250513          	addi	a0,a0,-622 # 80008a08 <etext+0xa08>
    80004c7e:	ba7fb0ef          	jal	80000824 <panic>
    return -1;
    80004c82:	57fd                	li	a5,-1
    80004c84:	893e                	mv	s2,a5
    80004c86:	b76d                	j	80004c30 <fileread+0x58>
      return -1;
    80004c88:	57fd                	li	a5,-1
    80004c8a:	893e                	mv	s2,a5
    80004c8c:	64e2                	ld	s1,24(sp)
    80004c8e:	69a2                	ld	s3,8(sp)
    80004c90:	b745                	j	80004c30 <fileread+0x58>
    80004c92:	57fd                	li	a5,-1
    80004c94:	893e                	mv	s2,a5
    80004c96:	64e2                	ld	s1,24(sp)
    80004c98:	69a2                	ld	s3,8(sp)
    80004c9a:	bf59                	j	80004c30 <fileread+0x58>

0000000080004c9c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c9c:	00954783          	lbu	a5,9(a0)
    80004ca0:	10078f63          	beqz	a5,80004dbe <filewrite+0x122>
{
    80004ca4:	711d                	addi	sp,sp,-96
    80004ca6:	ec86                	sd	ra,88(sp)
    80004ca8:	e8a2                	sd	s0,80(sp)
    80004caa:	e0ca                	sd	s2,64(sp)
    80004cac:	f456                	sd	s5,40(sp)
    80004cae:	f05a                	sd	s6,32(sp)
    80004cb0:	1080                	addi	s0,sp,96
    80004cb2:	892a                	mv	s2,a0
    80004cb4:	8b2e                	mv	s6,a1
    80004cb6:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cb8:	411c                	lw	a5,0(a0)
    80004cba:	4705                	li	a4,1
    80004cbc:	02e78a63          	beq	a5,a4,80004cf0 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cc0:	470d                	li	a4,3
    80004cc2:	02e78b63          	beq	a5,a4,80004cf8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cc6:	4709                	li	a4,2
    80004cc8:	0ce79f63          	bne	a5,a4,80004da6 <filewrite+0x10a>
    80004ccc:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cce:	0ac05a63          	blez	a2,80004d82 <filewrite+0xe6>
    80004cd2:	e4a6                	sd	s1,72(sp)
    80004cd4:	fc4e                	sd	s3,56(sp)
    80004cd6:	ec5e                	sd	s7,24(sp)
    80004cd8:	e862                	sd	s8,16(sp)
    80004cda:	e466                	sd	s9,8(sp)
    int i = 0;
    80004cdc:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004cde:	6b85                	lui	s7,0x1
    80004ce0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ce4:	6785                	lui	a5,0x1
    80004ce6:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004cea:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cec:	4c05                	li	s8,1
    80004cee:	a8ad                	j	80004d68 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004cf0:	6908                	ld	a0,16(a0)
    80004cf2:	252000ef          	jal	80004f44 <pipewrite>
    80004cf6:	a04d                	j	80004d98 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cf8:	02451783          	lh	a5,36(a0)
    80004cfc:	03079693          	slli	a3,a5,0x30
    80004d00:	92c1                	srli	a3,a3,0x30
    80004d02:	4725                	li	a4,9
    80004d04:	0ad76f63          	bltu	a4,a3,80004dc2 <filewrite+0x126>
    80004d08:	0792                	slli	a5,a5,0x4
    80004d0a:	0001f717          	auipc	a4,0x1f
    80004d0e:	08670713          	addi	a4,a4,134 # 80023d90 <devsw>
    80004d12:	97ba                	add	a5,a5,a4
    80004d14:	679c                	ld	a5,8(a5)
    80004d16:	cbc5                	beqz	a5,80004dc6 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004d18:	4505                	li	a0,1
    80004d1a:	9782                	jalr	a5
    80004d1c:	a8b5                	j	80004d98 <filewrite+0xfc>
      if(n1 > max)
    80004d1e:	2981                	sext.w	s3,s3
      begin_op();
    80004d20:	971ff0ef          	jal	80004690 <begin_op>
      ilock(f->ip);
    80004d24:	01893503          	ld	a0,24(s2)
    80004d28:	f5dfe0ef          	jal	80003c84 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d2c:	874e                	mv	a4,s3
    80004d2e:	02092683          	lw	a3,32(s2)
    80004d32:	016a0633          	add	a2,s4,s6
    80004d36:	85e2                	mv	a1,s8
    80004d38:	01893503          	ld	a0,24(s2)
    80004d3c:	bccff0ef          	jal	80004108 <writei>
    80004d40:	84aa                	mv	s1,a0
    80004d42:	00a05763          	blez	a0,80004d50 <filewrite+0xb4>
        f->off += r;
    80004d46:	02092783          	lw	a5,32(s2)
    80004d4a:	9fa9                	addw	a5,a5,a0
    80004d4c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d50:	01893503          	ld	a0,24(s2)
    80004d54:	fdffe0ef          	jal	80003d32 <iunlock>
      end_op();
    80004d58:	9a9ff0ef          	jal	80004700 <end_op>

      if(r != n1){
    80004d5c:	02999563          	bne	s3,s1,80004d86 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004d60:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004d64:	015a5963          	bge	s4,s5,80004d76 <filewrite+0xda>
      int n1 = n - i;
    80004d68:	414a87bb          	subw	a5,s5,s4
    80004d6c:	89be                	mv	s3,a5
      if(n1 > max)
    80004d6e:	fafbd8e3          	bge	s7,a5,80004d1e <filewrite+0x82>
    80004d72:	89e6                	mv	s3,s9
    80004d74:	b76d                	j	80004d1e <filewrite+0x82>
    80004d76:	64a6                	ld	s1,72(sp)
    80004d78:	79e2                	ld	s3,56(sp)
    80004d7a:	6be2                	ld	s7,24(sp)
    80004d7c:	6c42                	ld	s8,16(sp)
    80004d7e:	6ca2                	ld	s9,8(sp)
    80004d80:	a801                	j	80004d90 <filewrite+0xf4>
    int i = 0;
    80004d82:	4a01                	li	s4,0
    80004d84:	a031                	j	80004d90 <filewrite+0xf4>
    80004d86:	64a6                	ld	s1,72(sp)
    80004d88:	79e2                	ld	s3,56(sp)
    80004d8a:	6be2                	ld	s7,24(sp)
    80004d8c:	6c42                	ld	s8,16(sp)
    80004d8e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004d90:	034a9d63          	bne	s5,s4,80004dca <filewrite+0x12e>
    80004d94:	8556                	mv	a0,s5
    80004d96:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d98:	60e6                	ld	ra,88(sp)
    80004d9a:	6446                	ld	s0,80(sp)
    80004d9c:	6906                	ld	s2,64(sp)
    80004d9e:	7aa2                	ld	s5,40(sp)
    80004da0:	7b02                	ld	s6,32(sp)
    80004da2:	6125                	addi	sp,sp,96
    80004da4:	8082                	ret
    80004da6:	e4a6                	sd	s1,72(sp)
    80004da8:	fc4e                	sd	s3,56(sp)
    80004daa:	f852                	sd	s4,48(sp)
    80004dac:	ec5e                	sd	s7,24(sp)
    80004dae:	e862                	sd	s8,16(sp)
    80004db0:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004db2:	00004517          	auipc	a0,0x4
    80004db6:	c6650513          	addi	a0,a0,-922 # 80008a18 <etext+0xa18>
    80004dba:	a6bfb0ef          	jal	80000824 <panic>
    return -1;
    80004dbe:	557d                	li	a0,-1
}
    80004dc0:	8082                	ret
      return -1;
    80004dc2:	557d                	li	a0,-1
    80004dc4:	bfd1                	j	80004d98 <filewrite+0xfc>
    80004dc6:	557d                	li	a0,-1
    80004dc8:	bfc1                	j	80004d98 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004dca:	557d                	li	a0,-1
    80004dcc:	7a42                	ld	s4,48(sp)
    80004dce:	b7e9                	j	80004d98 <filewrite+0xfc>

0000000080004dd0 <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dd0:	1101                	addi	sp,sp,-32
    80004dd2:	ec06                	sd	ra,24(sp)
    80004dd4:	e822                	sd	s0,16(sp)
    80004dd6:	e426                	sd	s1,8(sp)
    80004dd8:	e04a                	sd	s2,0(sp)
    80004dda:	1000                	addi	s0,sp,32
    80004ddc:	84aa                	mv	s1,a0
    80004dde:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004de0:	0005b023          	sd	zero,0(a1)
    80004de4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004de8:	c29ff0ef          	jal	80004a10 <filealloc>
    80004dec:	e088                	sd	a0,0(s1)
    80004dee:	cd35                	beqz	a0,80004e6a <pipealloc+0x9a>
    80004df0:	c21ff0ef          	jal	80004a10 <filealloc>
    80004df4:	00a93023          	sd	a0,0(s2)
    80004df8:	c52d                	beqz	a0,80004e62 <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dfa:	d4bfb0ef          	jal	80000b44 <kalloc>
    80004dfe:	cd39                	beqz	a0,80004e5c <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    80004e00:	4785                	li	a5,1
    80004e02:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    80004e06:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    80004e0a:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    80004e0e:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    80004e12:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    80004e16:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    80004e1a:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004e1e:	6098                	ld	a4,0(s1)
    80004e20:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    80004e22:	6098                	ld	a4,0(s1)
    80004e24:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    80004e28:	6098                	ld	a4,0(s1)
    80004e2a:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004e2e:	6098                	ld	a4,0(s1)
    80004e30:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    80004e32:	00093703          	ld	a4,0(s2)
    80004e36:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    80004e38:	00093703          	ld	a4,0(s2)
    80004e3c:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    80004e40:	00093703          	ld	a4,0(s2)
    80004e44:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    80004e48:	00093783          	ld	a5,0(s2)
    80004e4c:	eb88                	sd	a0,16(a5)
  return 0;
    80004e4e:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    80004e50:	60e2                	ld	ra,24(sp)
    80004e52:	6442                	ld	s0,16(sp)
    80004e54:	64a2                	ld	s1,8(sp)
    80004e56:	6902                	ld	s2,0(sp)
    80004e58:	6105                	addi	sp,sp,32
    80004e5a:	8082                	ret
  if(*f0)
    80004e5c:	6088                	ld	a0,0(s1)
    80004e5e:	e501                	bnez	a0,80004e66 <pipealloc+0x96>
    80004e60:	a029                	j	80004e6a <pipealloc+0x9a>
    80004e62:	6088                	ld	a0,0(s1)
    80004e64:	cd01                	beqz	a0,80004e7c <pipealloc+0xac>
    fileclose(*f0);
    80004e66:	c4fff0ef          	jal	80004ab4 <fileclose>
  if(*f1)
    80004e6a:	00093783          	ld	a5,0(s2)
  return -1;
    80004e6e:	557d                	li	a0,-1
  if(*f1)
    80004e70:	d3e5                	beqz	a5,80004e50 <pipealloc+0x80>
    fileclose(*f1);
    80004e72:	853e                	mv	a0,a5
    80004e74:	c41ff0ef          	jal	80004ab4 <fileclose>
  return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	bfd9                	j	80004e50 <pipealloc+0x80>
    80004e7c:	557d                	li	a0,-1
    80004e7e:	bfc9                	j	80004e50 <pipealloc+0x80>

0000000080004e80 <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    80004e80:	1141                	addi	sp,sp,-16
    80004e82:	e406                	sd	ra,8(sp)
    80004e84:	e022                	sd	s0,0(sp)
    80004e86:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    80004e88:	4785                	li	a5,1
    80004e8a:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    80004e8c:	058a                	slli	a1,a1,0x2
    80004e8e:	21058593          	addi	a1,a1,528
    80004e92:	95aa                	add	a1,a1,a0
    80004e94:	4705                	li	a4,1
    80004e96:	c198                	sw	a4,0(a1)
  pi->turn = other;
    80004e98:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    80004e9c:	078a                	slli	a5,a5,0x2
    80004e9e:	21078793          	addi	a5,a5,528
    80004ea2:	953e                	add	a0,a0,a5
    80004ea4:	4118                	lw	a4,0(a0)
    80004ea6:	4785                	li	a5,1
    80004ea8:	00f70063          	beq	a4,a5,80004ea8 <peterson_enter+0x28>
}
    80004eac:	60a2                	ld	ra,8(sp)
    80004eae:	6402                	ld	s0,0(sp)
    80004eb0:	0141                	addi	sp,sp,16
    80004eb2:	8082                	ret

0000000080004eb4 <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    80004eb4:	1141                	addi	sp,sp,-16
    80004eb6:	e406                	sd	ra,8(sp)
    80004eb8:	e022                	sd	s0,0(sp)
    80004eba:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    80004ebc:	058a                	slli	a1,a1,0x2
    80004ebe:	21058593          	addi	a1,a1,528
    80004ec2:	952e                	add	a0,a0,a1
    80004ec4:	00052023          	sw	zero,0(a0)
}
    80004ec8:	60a2                	ld	ra,8(sp)
    80004eca:	6402                	ld	s0,0(sp)
    80004ecc:	0141                	addi	sp,sp,16
    80004ece:	8082                	ret

0000000080004ed0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ed0:	7179                	addi	sp,sp,-48
    80004ed2:	f406                	sd	ra,40(sp)
    80004ed4:	f022                	sd	s0,32(sp)
    80004ed6:	ec26                	sd	s1,24(sp)
    80004ed8:	e84a                	sd	s2,16(sp)
    80004eda:	e44e                	sd	s3,8(sp)
    80004edc:	1800                	addi	s0,sp,48
    80004ede:	84aa                	mv	s1,a0
    80004ee0:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    80004ee2:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    80004ee6:	85ca                	mv	a1,s2
    80004ee8:	f99ff0ef          	jal	80004e80 <peterson_enter>
  if(writable){
    80004eec:	02098b63          	beqz	s3,80004f22 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ef0:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    80004ef4:	20048513          	addi	a0,s1,512
    80004ef8:	8d3fd0ef          	jal	800027ca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004efc:	2084a783          	lw	a5,520(s1)
    80004f00:	e781                	bnez	a5,80004f08 <pipeclose+0x38>
    80004f02:	20c4a783          	lw	a5,524(s1)
    80004f06:	c78d                	beqz	a5,80004f30 <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    80004f08:	090a                	slli	s2,s2,0x2
    80004f0a:	21090913          	addi	s2,s2,528
    80004f0e:	94ca                	add	s1,s1,s2
    80004f10:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    80004f14:	70a2                	ld	ra,40(sp)
    80004f16:	7402                	ld	s0,32(sp)
    80004f18:	64e2                	ld	s1,24(sp)
    80004f1a:	6942                	ld	s2,16(sp)
    80004f1c:	69a2                	ld	s3,8(sp)
    80004f1e:	6145                	addi	sp,sp,48
    80004f20:	8082                	ret
    pi->readopen = 0;
    80004f22:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    80004f26:	20448513          	addi	a0,s1,516
    80004f2a:	8a1fd0ef          	jal	800027ca <wakeup>
    80004f2e:	b7f9                	j	80004efc <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    80004f30:	090a                	slli	s2,s2,0x2
    80004f32:	21090913          	addi	s2,s2,528
    80004f36:	9926                	add	s2,s2,s1
    80004f38:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	b1ffb0ef          	jal	80000a5c <kfree>
    80004f42:	bfc9                	j	80004f14 <pipeclose+0x44>

0000000080004f44 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f44:	7159                	addi	sp,sp,-112
    80004f46:	f486                	sd	ra,104(sp)
    80004f48:	f0a2                	sd	s0,96(sp)
    80004f4a:	eca6                	sd	s1,88(sp)
    80004f4c:	e8ca                	sd	s2,80(sp)
    80004f4e:	e4ce                	sd	s3,72(sp)
    80004f50:	e0d2                	sd	s4,64(sp)
    80004f52:	fc56                	sd	s5,56(sp)
    80004f54:	1880                	addi	s0,sp,112
    80004f56:	84aa                	mv	s1,a0
    80004f58:	8aae                	mv	s5,a1
    80004f5a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f5c:	b5bfc0ef          	jal	80001ab6 <myproc>
    80004f60:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    80004f62:	4581                	li	a1,0
    80004f64:	8526                	mv	a0,s1
    80004f66:	f1bff0ef          	jal	80004e80 <peterson_enter>
  while(i < n){
    80004f6a:	0b405e63          	blez	s4,80005026 <pipewrite+0xe2>
    80004f6e:	f85a                	sd	s6,48(sp)
    80004f70:	f45e                	sd	s7,40(sp)
    80004f72:	f062                	sd	s8,32(sp)
    80004f74:	ec66                	sd	s9,24(sp)
    80004f76:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004f78:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f7a:	f9f40c13          	addi	s8,s0,-97
    80004f7e:	4b85                	li	s7,1
    80004f80:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f82:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    80004f86:	20448c93          	addi	s9,s1,516
    80004f8a:	a825                	j	80004fc2 <pipewrite+0x7e>
      return -1;
    80004f8c:	597d                	li	s2,-1
}
    80004f8e:	7b42                	ld	s6,48(sp)
    80004f90:	7ba2                	ld	s7,40(sp)
    80004f92:	7c02                	ld	s8,32(sp)
    80004f94:	6ce2                	ld	s9,24(sp)
    80004f96:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    80004f98:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004f9c:	854a                	mv	a0,s2
    80004f9e:	70a6                	ld	ra,104(sp)
    80004fa0:	7406                	ld	s0,96(sp)
    80004fa2:	64e6                	ld	s1,88(sp)
    80004fa4:	6946                	ld	s2,80(sp)
    80004fa6:	69a6                	ld	s3,72(sp)
    80004fa8:	6a06                	ld	s4,64(sp)
    80004faa:	7ae2                	ld	s5,56(sp)
    80004fac:	6165                	addi	sp,sp,112
    80004fae:	8082                	ret
      wakeup(&pi->nread);
    80004fb0:	856a                	mv	a0,s10
    80004fb2:	819fd0ef          	jal	800027ca <wakeup>
      sleep(&pi->nwrite, 0);
    80004fb6:	4581                	li	a1,0
    80004fb8:	8566                	mv	a0,s9
    80004fba:	fc4fd0ef          	jal	8000277e <sleep>
  while(i < n){
    80004fbe:	05495a63          	bge	s2,s4,80005012 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004fc2:	2084a783          	lw	a5,520(s1)
    80004fc6:	d3f9                	beqz	a5,80004f8c <pipewrite+0x48>
    80004fc8:	854e                	mv	a0,s3
    80004fca:	9f1fd0ef          	jal	800029ba <killed>
    80004fce:	fd5d                	bnez	a0,80004f8c <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fd0:	2004a783          	lw	a5,512(s1)
    80004fd4:	2044a703          	lw	a4,516(s1)
    80004fd8:	2007879b          	addiw	a5,a5,512
    80004fdc:	fcf70ae3          	beq	a4,a5,80004fb0 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fe0:	86de                	mv	a3,s7
    80004fe2:	01590633          	add	a2,s2,s5
    80004fe6:	85e2                	mv	a1,s8
    80004fe8:	0589b503          	ld	a0,88(s3)
    80004fec:	f26fc0ef          	jal	80001712 <copyin>
    80004ff0:	03650d63          	beq	a0,s6,8000502a <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ff4:	2044a783          	lw	a5,516(s1)
    80004ff8:	0017871b          	addiw	a4,a5,1
    80004ffc:	20e4a223          	sw	a4,516(s1)
    80005000:	1ff7f793          	andi	a5,a5,511
    80005004:	97a6                	add	a5,a5,s1
    80005006:	f9f44703          	lbu	a4,-97(s0)
    8000500a:	00e78023          	sb	a4,0(a5)
      i++;
    8000500e:	2905                	addiw	s2,s2,1
    80005010:	b77d                	j	80004fbe <pipewrite+0x7a>
    80005012:	7b42                	ld	s6,48(sp)
    80005014:	7ba2                	ld	s7,40(sp)
    80005016:	7c02                	ld	s8,32(sp)
    80005018:	6ce2                	ld	s9,24(sp)
    8000501a:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000501c:	20048513          	addi	a0,s1,512
    80005020:	faafd0ef          	jal	800027ca <wakeup>
}
    80005024:	bf95                	j	80004f98 <pipewrite+0x54>
  int i = 0;
    80005026:	4901                	li	s2,0
    80005028:	bfd5                	j	8000501c <pipewrite+0xd8>
    8000502a:	7b42                	ld	s6,48(sp)
    8000502c:	7ba2                	ld	s7,40(sp)
    8000502e:	7c02                	ld	s8,32(sp)
    80005030:	6ce2                	ld	s9,24(sp)
    80005032:	6d42                	ld	s10,16(sp)
    80005034:	b7e5                	j	8000501c <pipewrite+0xd8>

0000000080005036 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005036:	711d                	addi	sp,sp,-96
    80005038:	ec86                	sd	ra,88(sp)
    8000503a:	e8a2                	sd	s0,80(sp)
    8000503c:	e4a6                	sd	s1,72(sp)
    8000503e:	e0ca                	sd	s2,64(sp)
    80005040:	fc4e                	sd	s3,56(sp)
    80005042:	f852                	sd	s4,48(sp)
    80005044:	f456                	sd	s5,40(sp)
    80005046:	1080                	addi	s0,sp,96
    80005048:	84aa                	mv	s1,a0
    8000504a:	892e                	mv	s2,a1
    8000504c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000504e:	a69fc0ef          	jal	80001ab6 <myproc>
    80005052:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    80005054:	4585                	li	a1,1
    80005056:	8526                	mv	a0,s1
    80005058:	e29ff0ef          	jal	80004e80 <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000505c:	2004a703          	lw	a4,512(s1)
    80005060:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80005064:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005068:	02f71763          	bne	a4,a5,80005096 <piperead+0x60>
    8000506c:	20c4a783          	lw	a5,524(s1)
    80005070:	c79d                	beqz	a5,8000509e <piperead+0x68>
    if(killed(pr)){
    80005072:	8552                	mv	a0,s4
    80005074:	947fd0ef          	jal	800029ba <killed>
    80005078:	e15d                	bnez	a0,8000511e <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    8000507a:	4581                	li	a1,0
    8000507c:	854e                	mv	a0,s3
    8000507e:	f00fd0ef          	jal	8000277e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005082:	2004a703          	lw	a4,512(s1)
    80005086:	2044a783          	lw	a5,516(s1)
    8000508a:	fef701e3          	beq	a4,a5,8000506c <piperead+0x36>
    8000508e:	f05a                	sd	s6,32(sp)
    80005090:	ec5e                	sd	s7,24(sp)
    80005092:	e862                	sd	s8,16(sp)
    80005094:	a801                	j	800050a4 <piperead+0x6e>
    80005096:	f05a                	sd	s6,32(sp)
    80005098:	ec5e                	sd	s7,24(sp)
    8000509a:	e862                	sd	s8,16(sp)
    8000509c:	a021                	j	800050a4 <piperead+0x6e>
    8000509e:	f05a                	sd	s6,32(sp)
    800050a0:	ec5e                	sd	s7,24(sp)
    800050a2:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050a6:	faf40c13          	addi	s8,s0,-81
    800050aa:	4b85                	li	s7,1
    800050ac:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050ae:	05505163          	blez	s5,800050f0 <piperead+0xba>
    if(pi->nread == pi->nwrite)
    800050b2:	2004a783          	lw	a5,512(s1)
    800050b6:	2044a703          	lw	a4,516(s1)
    800050ba:	02f70b63          	beq	a4,a5,800050f0 <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    800050be:	1ff7f793          	andi	a5,a5,511
    800050c2:	97a6                	add	a5,a5,s1
    800050c4:	0007c783          	lbu	a5,0(a5)
    800050c8:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050cc:	86de                	mv	a3,s7
    800050ce:	8662                	mv	a2,s8
    800050d0:	85ca                	mv	a1,s2
    800050d2:	058a3503          	ld	a0,88(s4)
    800050d6:	d7efc0ef          	jal	80001654 <copyout>
    800050da:	03650e63          	beq	a0,s6,80005116 <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800050de:	2004a783          	lw	a5,512(s1)
    800050e2:	2785                	addiw	a5,a5,1
    800050e4:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050e8:	2985                	addiw	s3,s3,1
    800050ea:	0905                	addi	s2,s2,1
    800050ec:	fd3a93e3          	bne	s5,s3,800050b2 <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050f0:	20448513          	addi	a0,s1,516
    800050f4:	ed6fd0ef          	jal	800027ca <wakeup>
}
    800050f8:	7b02                	ld	s6,32(sp)
    800050fa:	6be2                	ld	s7,24(sp)
    800050fc:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    800050fe:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    80005102:	854e                	mv	a0,s3
    80005104:	60e6                	ld	ra,88(sp)
    80005106:	6446                	ld	s0,80(sp)
    80005108:	64a6                	ld	s1,72(sp)
    8000510a:	6906                	ld	s2,64(sp)
    8000510c:	79e2                	ld	s3,56(sp)
    8000510e:	7a42                	ld	s4,48(sp)
    80005110:	7aa2                	ld	s5,40(sp)
    80005112:	6125                	addi	sp,sp,96
    80005114:	8082                	ret
      if(i == 0)
    80005116:	fc099de3          	bnez	s3,800050f0 <piperead+0xba>
        i = -1;
    8000511a:	89aa                	mv	s3,a0
    8000511c:	bfd1                	j	800050f0 <piperead+0xba>
      return -1;
    8000511e:	59fd                	li	s3,-1
    80005120:	bff9                	j	800050fe <piperead+0xc8>

0000000080005122 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005122:	1141                	addi	sp,sp,-16
    80005124:	e406                	sd	ra,8(sp)
    80005126:	e022                	sd	s0,0(sp)
    80005128:	0800                	addi	s0,sp,16
    8000512a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000512c:	0035151b          	slliw	a0,a0,0x3
    80005130:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80005132:	8b89                	andi	a5,a5,2
    80005134:	c399                	beqz	a5,8000513a <flags2perm+0x18>
      perm |= PTE_W;
    80005136:	00456513          	ori	a0,a0,4
    return perm;
}
    8000513a:	60a2                	ld	ra,8(sp)
    8000513c:	6402                	ld	s0,0(sp)
    8000513e:	0141                	addi	sp,sp,16
    80005140:	8082                	ret

0000000080005142 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005142:	de010113          	addi	sp,sp,-544
    80005146:	20113c23          	sd	ra,536(sp)
    8000514a:	20813823          	sd	s0,528(sp)
    8000514e:	20913423          	sd	s1,520(sp)
    80005152:	21213023          	sd	s2,512(sp)
    80005156:	1400                	addi	s0,sp,544
    80005158:	892a                	mv	s2,a0
    8000515a:	dea43823          	sd	a0,-528(s0)
    8000515e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005162:	955fc0ef          	jal	80001ab6 <myproc>
    80005166:	84aa                	mv	s1,a0

  begin_op();
    80005168:	d28ff0ef          	jal	80004690 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000516c:	854a                	mv	a0,s2
    8000516e:	b44ff0ef          	jal	800044b2 <namei>
    80005172:	cd21                	beqz	a0,800051ca <kexec+0x88>
    80005174:	fbd2                	sd	s4,496(sp)
    80005176:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005178:	b0dfe0ef          	jal	80003c84 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000517c:	04000713          	li	a4,64
    80005180:	4681                	li	a3,0
    80005182:	e5040613          	addi	a2,s0,-432
    80005186:	4581                	li	a1,0
    80005188:	8552                	mv	a0,s4
    8000518a:	e8dfe0ef          	jal	80004016 <readi>
    8000518e:	04000793          	li	a5,64
    80005192:	00f51a63          	bne	a0,a5,800051a6 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005196:	e5042703          	lw	a4,-432(s0)
    8000519a:	464c47b7          	lui	a5,0x464c4
    8000519e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051a2:	02f70863          	beq	a4,a5,800051d2 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051a6:	8552                	mv	a0,s4
    800051a8:	ce9fe0ef          	jal	80003e90 <iunlockput>
    end_op();
    800051ac:	d54ff0ef          	jal	80004700 <end_op>
  }
  return -1;
    800051b0:	557d                	li	a0,-1
    800051b2:	7a5e                	ld	s4,496(sp)
}
    800051b4:	21813083          	ld	ra,536(sp)
    800051b8:	21013403          	ld	s0,528(sp)
    800051bc:	20813483          	ld	s1,520(sp)
    800051c0:	20013903          	ld	s2,512(sp)
    800051c4:	22010113          	addi	sp,sp,544
    800051c8:	8082                	ret
    end_op();
    800051ca:	d36ff0ef          	jal	80004700 <end_op>
    return -1;
    800051ce:	557d                	li	a0,-1
    800051d0:	b7d5                	j	800051b4 <kexec+0x72>
    800051d2:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800051d4:	8526                	mv	a0,s1
    800051d6:	9edfc0ef          	jal	80001bc2 <proc_pagetable>
    800051da:	8b2a                	mv	s6,a0
    800051dc:	26050f63          	beqz	a0,8000545a <kexec+0x318>
    800051e0:	ffce                	sd	s3,504(sp)
    800051e2:	f7d6                	sd	s5,488(sp)
    800051e4:	efde                	sd	s7,472(sp)
    800051e6:	ebe2                	sd	s8,464(sp)
    800051e8:	e7e6                	sd	s9,456(sp)
    800051ea:	e3ea                	sd	s10,448(sp)
    800051ec:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ee:	e8845783          	lhu	a5,-376(s0)
    800051f2:	0e078963          	beqz	a5,800052e4 <kexec+0x1a2>
    800051f6:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051fa:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051fc:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051fe:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80005202:	6c85                	lui	s9,0x1
    80005204:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005208:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000520c:	6a85                	lui	s5,0x1
    8000520e:	a085                	j	8000526e <kexec+0x12c>
      panic("loadseg: address should exist");
    80005210:	00004517          	auipc	a0,0x4
    80005214:	81850513          	addi	a0,a0,-2024 # 80008a28 <etext+0xa28>
    80005218:	e0cfb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    8000521c:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000521e:	874a                	mv	a4,s2
    80005220:	009b86bb          	addw	a3,s7,s1
    80005224:	4581                	li	a1,0
    80005226:	8552                	mv	a0,s4
    80005228:	deffe0ef          	jal	80004016 <readi>
    8000522c:	22a91b63          	bne	s2,a0,80005462 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80005230:	009a84bb          	addw	s1,s5,s1
    80005234:	0334f263          	bgeu	s1,s3,80005258 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80005238:	02049593          	slli	a1,s1,0x20
    8000523c:	9181                	srli	a1,a1,0x20
    8000523e:	95e2                	add	a1,a1,s8
    80005240:	855a                	mv	a0,s6
    80005242:	de5fb0ef          	jal	80001026 <walkaddr>
    80005246:	862a                	mv	a2,a0
    if(pa == 0)
    80005248:	d561                	beqz	a0,80005210 <kexec+0xce>
    if(sz - i < PGSIZE)
    8000524a:	409987bb          	subw	a5,s3,s1
    8000524e:	893e                	mv	s2,a5
    80005250:	fcfcf6e3          	bgeu	s9,a5,8000521c <kexec+0xda>
    80005254:	8956                	mv	s2,s5
    80005256:	b7d9                	j	8000521c <kexec+0xda>
    sz = sz1;
    80005258:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000525c:	2d05                	addiw	s10,s10,1
    8000525e:	e0843783          	ld	a5,-504(s0)
    80005262:	0387869b          	addiw	a3,a5,56
    80005266:	e8845783          	lhu	a5,-376(s0)
    8000526a:	06fd5e63          	bge	s10,a5,800052e6 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000526e:	e0d43423          	sd	a3,-504(s0)
    80005272:	876e                	mv	a4,s11
    80005274:	e1840613          	addi	a2,s0,-488
    80005278:	4581                	li	a1,0
    8000527a:	8552                	mv	a0,s4
    8000527c:	d9bfe0ef          	jal	80004016 <readi>
    80005280:	1db51f63          	bne	a0,s11,8000545e <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80005284:	e1842783          	lw	a5,-488(s0)
    80005288:	4705                	li	a4,1
    8000528a:	fce799e3          	bne	a5,a4,8000525c <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    8000528e:	e4043483          	ld	s1,-448(s0)
    80005292:	e3843783          	ld	a5,-456(s0)
    80005296:	1ef4e463          	bltu	s1,a5,8000547e <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000529a:	e2843783          	ld	a5,-472(s0)
    8000529e:	94be                	add	s1,s1,a5
    800052a0:	1ef4e263          	bltu	s1,a5,80005484 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    800052a4:	de843703          	ld	a4,-536(s0)
    800052a8:	8ff9                	and	a5,a5,a4
    800052aa:	1e079063          	bnez	a5,8000548a <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052ae:	e1c42503          	lw	a0,-484(s0)
    800052b2:	e71ff0ef          	jal	80005122 <flags2perm>
    800052b6:	86aa                	mv	a3,a0
    800052b8:	8626                	mv	a2,s1
    800052ba:	85ca                	mv	a1,s2
    800052bc:	855a                	mv	a0,s6
    800052be:	83efc0ef          	jal	800012fc <uvmalloc>
    800052c2:	dea43c23          	sd	a0,-520(s0)
    800052c6:	1c050563          	beqz	a0,80005490 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052ca:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052ce:	00098863          	beqz	s3,800052de <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052d2:	e2843c03          	ld	s8,-472(s0)
    800052d6:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052da:	4481                	li	s1,0
    800052dc:	bfb1                	j	80005238 <kexec+0xf6>
    sz = sz1;
    800052de:	df843903          	ld	s2,-520(s0)
    800052e2:	bfad                	j	8000525c <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052e4:	4901                	li	s2,0
  iunlockput(ip);
    800052e6:	8552                	mv	a0,s4
    800052e8:	ba9fe0ef          	jal	80003e90 <iunlockput>
  end_op();
    800052ec:	c14ff0ef          	jal	80004700 <end_op>
  p = myproc();
    800052f0:	fc6fc0ef          	jal	80001ab6 <myproc>
    800052f4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800052f6:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800052fa:	6985                	lui	s3,0x1
    800052fc:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800052fe:	99ca                	add	s3,s3,s2
    80005300:	77fd                	lui	a5,0xfffff
    80005302:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005306:	4691                	li	a3,4
    80005308:	6609                	lui	a2,0x2
    8000530a:	964e                	add	a2,a2,s3
    8000530c:	85ce                	mv	a1,s3
    8000530e:	855a                	mv	a0,s6
    80005310:	fedfb0ef          	jal	800012fc <uvmalloc>
    80005314:	8a2a                	mv	s4,a0
    80005316:	e105                	bnez	a0,80005336 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80005318:	85ce                	mv	a1,s3
    8000531a:	855a                	mv	a0,s6
    8000531c:	92bfc0ef          	jal	80001c46 <proc_freepagetable>
  return -1;
    80005320:	557d                	li	a0,-1
    80005322:	79fe                	ld	s3,504(sp)
    80005324:	7a5e                	ld	s4,496(sp)
    80005326:	7abe                	ld	s5,488(sp)
    80005328:	7b1e                	ld	s6,480(sp)
    8000532a:	6bfe                	ld	s7,472(sp)
    8000532c:	6c5e                	ld	s8,464(sp)
    8000532e:	6cbe                	ld	s9,456(sp)
    80005330:	6d1e                	ld	s10,448(sp)
    80005332:	7dfa                	ld	s11,440(sp)
    80005334:	b541                	j	800051b4 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005336:	75f9                	lui	a1,0xffffe
    80005338:	95aa                	add	a1,a1,a0
    8000533a:	855a                	mv	a0,s6
    8000533c:	992fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005340:	800a0b93          	addi	s7,s4,-2048
    80005344:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80005348:	e0043783          	ld	a5,-512(s0)
    8000534c:	6388                	ld	a0,0(a5)
  sp = sz;
    8000534e:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005350:	4481                	li	s1,0
    ustack[argc] = sp;
    80005352:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005356:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000535a:	cd21                	beqz	a0,800053b2 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    8000535c:	b27fb0ef          	jal	80000e82 <strlen>
    80005360:	0015079b          	addiw	a5,a0,1
    80005364:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005368:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000536c:	13796563          	bltu	s2,s7,80005496 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005370:	e0043d83          	ld	s11,-512(s0)
    80005374:	000db983          	ld	s3,0(s11)
    80005378:	854e                	mv	a0,s3
    8000537a:	b09fb0ef          	jal	80000e82 <strlen>
    8000537e:	0015069b          	addiw	a3,a0,1
    80005382:	864e                	mv	a2,s3
    80005384:	85ca                	mv	a1,s2
    80005386:	855a                	mv	a0,s6
    80005388:	accfc0ef          	jal	80001654 <copyout>
    8000538c:	10054763          	bltz	a0,8000549a <kexec+0x358>
    ustack[argc] = sp;
    80005390:	00349793          	slli	a5,s1,0x3
    80005394:	97e6                	add	a5,a5,s9
    80005396:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffda0d8>
  for(argc = 0; argv[argc]; argc++) {
    8000539a:	0485                	addi	s1,s1,1
    8000539c:	008d8793          	addi	a5,s11,8
    800053a0:	e0f43023          	sd	a5,-512(s0)
    800053a4:	008db503          	ld	a0,8(s11)
    800053a8:	c509                	beqz	a0,800053b2 <kexec+0x270>
    if(argc >= MAXARG)
    800053aa:	fb8499e3          	bne	s1,s8,8000535c <kexec+0x21a>
  sz = sz1;
    800053ae:	89d2                	mv	s3,s4
    800053b0:	b7a5                	j	80005318 <kexec+0x1d6>
  ustack[argc] = 0;
    800053b2:	00349793          	slli	a5,s1,0x3
    800053b6:	f9078793          	addi	a5,a5,-112
    800053ba:	97a2                	add	a5,a5,s0
    800053bc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800053c0:	00349693          	slli	a3,s1,0x3
    800053c4:	06a1                	addi	a3,a3,8
    800053c6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053ca:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800053ce:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800053d0:	f57964e3          	bltu	s2,s7,80005318 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053d4:	e9040613          	addi	a2,s0,-368
    800053d8:	85ca                	mv	a1,s2
    800053da:	855a                	mv	a0,s6
    800053dc:	a78fc0ef          	jal	80001654 <copyout>
    800053e0:	f2054ce3          	bltz	a0,80005318 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    800053e4:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    800053e8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053ec:	df043783          	ld	a5,-528(s0)
    800053f0:	0007c703          	lbu	a4,0(a5)
    800053f4:	cf11                	beqz	a4,80005410 <kexec+0x2ce>
    800053f6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053f8:	02f00693          	li	a3,47
    800053fc:	a029                	j	80005406 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800053fe:	0785                	addi	a5,a5,1
    80005400:	fff7c703          	lbu	a4,-1(a5)
    80005404:	c711                	beqz	a4,80005410 <kexec+0x2ce>
    if(*s == '/')
    80005406:	fed71ce3          	bne	a4,a3,800053fe <kexec+0x2bc>
      last = s+1;
    8000540a:	def43823          	sd	a5,-528(s0)
    8000540e:	bfc5                	j	800053fe <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80005410:	4641                	li	a2,16
    80005412:	df043583          	ld	a1,-528(s0)
    80005416:	160a8513          	addi	a0,s5,352
    8000541a:	a33fb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    8000541e:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005422:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80005426:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000542a:	060ab783          	ld	a5,96(s5)
    8000542e:	e6843703          	ld	a4,-408(s0)
    80005432:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005434:	060ab783          	ld	a5,96(s5)
    80005438:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000543c:	85ea                	mv	a1,s10
    8000543e:	809fc0ef          	jal	80001c46 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005442:	0004851b          	sext.w	a0,s1
    80005446:	79fe                	ld	s3,504(sp)
    80005448:	7a5e                	ld	s4,496(sp)
    8000544a:	7abe                	ld	s5,488(sp)
    8000544c:	7b1e                	ld	s6,480(sp)
    8000544e:	6bfe                	ld	s7,472(sp)
    80005450:	6c5e                	ld	s8,464(sp)
    80005452:	6cbe                	ld	s9,456(sp)
    80005454:	6d1e                	ld	s10,448(sp)
    80005456:	7dfa                	ld	s11,440(sp)
    80005458:	bbb1                	j	800051b4 <kexec+0x72>
    8000545a:	7b1e                	ld	s6,480(sp)
    8000545c:	b3a9                	j	800051a6 <kexec+0x64>
    8000545e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005462:	df843583          	ld	a1,-520(s0)
    80005466:	855a                	mv	a0,s6
    80005468:	fdefc0ef          	jal	80001c46 <proc_freepagetable>
  if(ip){
    8000546c:	79fe                	ld	s3,504(sp)
    8000546e:	7abe                	ld	s5,488(sp)
    80005470:	7b1e                	ld	s6,480(sp)
    80005472:	6bfe                	ld	s7,472(sp)
    80005474:	6c5e                	ld	s8,464(sp)
    80005476:	6cbe                	ld	s9,456(sp)
    80005478:	6d1e                	ld	s10,448(sp)
    8000547a:	7dfa                	ld	s11,440(sp)
    8000547c:	b32d                	j	800051a6 <kexec+0x64>
    8000547e:	df243c23          	sd	s2,-520(s0)
    80005482:	b7c5                	j	80005462 <kexec+0x320>
    80005484:	df243c23          	sd	s2,-520(s0)
    80005488:	bfe9                	j	80005462 <kexec+0x320>
    8000548a:	df243c23          	sd	s2,-520(s0)
    8000548e:	bfd1                	j	80005462 <kexec+0x320>
    80005490:	df243c23          	sd	s2,-520(s0)
    80005494:	b7f9                	j	80005462 <kexec+0x320>
  sz = sz1;
    80005496:	89d2                	mv	s3,s4
    80005498:	b541                	j	80005318 <kexec+0x1d6>
    8000549a:	89d2                	mv	s3,s4
    8000549c:	bdb5                	j	80005318 <kexec+0x1d6>

000000008000549e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000549e:	7179                	addi	sp,sp,-48
    800054a0:	f406                	sd	ra,40(sp)
    800054a2:	f022                	sd	s0,32(sp)
    800054a4:	ec26                	sd	s1,24(sp)
    800054a6:	e84a                	sd	s2,16(sp)
    800054a8:	1800                	addi	s0,sp,48
    800054aa:	892e                	mv	s2,a1
    800054ac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054ae:	fdc40593          	addi	a1,s0,-36
    800054b2:	dddfd0ef          	jal	8000328e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054b6:	fdc42703          	lw	a4,-36(s0)
    800054ba:	47bd                	li	a5,15
    800054bc:	02e7ea63          	bltu	a5,a4,800054f0 <argfd+0x52>
    800054c0:	df6fc0ef          	jal	80001ab6 <myproc>
    800054c4:	fdc42703          	lw	a4,-36(s0)
    800054c8:	00371793          	slli	a5,a4,0x3
    800054cc:	0d078793          	addi	a5,a5,208
    800054d0:	953e                	add	a0,a0,a5
    800054d2:	651c                	ld	a5,8(a0)
    800054d4:	c385                	beqz	a5,800054f4 <argfd+0x56>
    return -1;
  if(pfd)
    800054d6:	00090463          	beqz	s2,800054de <argfd+0x40>
    *pfd = fd;
    800054da:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054de:	4501                	li	a0,0
  if(pf)
    800054e0:	c091                	beqz	s1,800054e4 <argfd+0x46>
    *pf = f;
    800054e2:	e09c                	sd	a5,0(s1)
}
    800054e4:	70a2                	ld	ra,40(sp)
    800054e6:	7402                	ld	s0,32(sp)
    800054e8:	64e2                	ld	s1,24(sp)
    800054ea:	6942                	ld	s2,16(sp)
    800054ec:	6145                	addi	sp,sp,48
    800054ee:	8082                	ret
    return -1;
    800054f0:	557d                	li	a0,-1
    800054f2:	bfcd                	j	800054e4 <argfd+0x46>
    800054f4:	557d                	li	a0,-1
    800054f6:	b7fd                	j	800054e4 <argfd+0x46>

00000000800054f8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054f8:	1101                	addi	sp,sp,-32
    800054fa:	ec06                	sd	ra,24(sp)
    800054fc:	e822                	sd	s0,16(sp)
    800054fe:	e426                	sd	s1,8(sp)
    80005500:	1000                	addi	s0,sp,32
    80005502:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005504:	db2fc0ef          	jal	80001ab6 <myproc>
    80005508:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000550a:	0d850793          	addi	a5,a0,216
    8000550e:	4501                	li	a0,0
    80005510:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005512:	6398                	ld	a4,0(a5)
    80005514:	cb19                	beqz	a4,8000552a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005516:	2505                	addiw	a0,a0,1
    80005518:	07a1                	addi	a5,a5,8
    8000551a:	fed51ce3          	bne	a0,a3,80005512 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000551e:	557d                	li	a0,-1
}
    80005520:	60e2                	ld	ra,24(sp)
    80005522:	6442                	ld	s0,16(sp)
    80005524:	64a2                	ld	s1,8(sp)
    80005526:	6105                	addi	sp,sp,32
    80005528:	8082                	ret
      p->ofile[fd] = f;
    8000552a:	00351793          	slli	a5,a0,0x3
    8000552e:	0d078793          	addi	a5,a5,208
    80005532:	963e                	add	a2,a2,a5
    80005534:	e604                	sd	s1,8(a2)
      return fd;
    80005536:	b7ed                	j	80005520 <fdalloc+0x28>

0000000080005538 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005538:	715d                	addi	sp,sp,-80
    8000553a:	e486                	sd	ra,72(sp)
    8000553c:	e0a2                	sd	s0,64(sp)
    8000553e:	fc26                	sd	s1,56(sp)
    80005540:	f84a                	sd	s2,48(sp)
    80005542:	f44e                	sd	s3,40(sp)
    80005544:	f052                	sd	s4,32(sp)
    80005546:	ec56                	sd	s5,24(sp)
    80005548:	e85a                	sd	s6,16(sp)
    8000554a:	0880                	addi	s0,sp,80
    8000554c:	892e                	mv	s2,a1
    8000554e:	8a2e                	mv	s4,a1
    80005550:	8ab2                	mv	s5,a2
    80005552:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005554:	fb040593          	addi	a1,s0,-80
    80005558:	f75fe0ef          	jal	800044cc <nameiparent>
    8000555c:	84aa                	mv	s1,a0
    8000555e:	10050763          	beqz	a0,8000566c <create+0x134>
    return 0;

  ilock(dp);
    80005562:	f22fe0ef          	jal	80003c84 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005566:	4601                	li	a2,0
    80005568:	fb040593          	addi	a1,s0,-80
    8000556c:	8526                	mv	a0,s1
    8000556e:	cb1fe0ef          	jal	8000421e <dirlookup>
    80005572:	89aa                	mv	s3,a0
    80005574:	c131                	beqz	a0,800055b8 <create+0x80>
    iunlockput(dp);
    80005576:	8526                	mv	a0,s1
    80005578:	919fe0ef          	jal	80003e90 <iunlockput>
    ilock(ip);
    8000557c:	854e                	mv	a0,s3
    8000557e:	f06fe0ef          	jal	80003c84 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005582:	4789                	li	a5,2
    80005584:	02f91563          	bne	s2,a5,800055ae <create+0x76>
    80005588:	0449d783          	lhu	a5,68(s3)
    8000558c:	37f9                	addiw	a5,a5,-2
    8000558e:	17c2                	slli	a5,a5,0x30
    80005590:	93c1                	srli	a5,a5,0x30
    80005592:	4705                	li	a4,1
    80005594:	00f76d63          	bltu	a4,a5,800055ae <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005598:	854e                	mv	a0,s3
    8000559a:	60a6                	ld	ra,72(sp)
    8000559c:	6406                	ld	s0,64(sp)
    8000559e:	74e2                	ld	s1,56(sp)
    800055a0:	7942                	ld	s2,48(sp)
    800055a2:	79a2                	ld	s3,40(sp)
    800055a4:	7a02                	ld	s4,32(sp)
    800055a6:	6ae2                	ld	s5,24(sp)
    800055a8:	6b42                	ld	s6,16(sp)
    800055aa:	6161                	addi	sp,sp,80
    800055ac:	8082                	ret
    iunlockput(ip);
    800055ae:	854e                	mv	a0,s3
    800055b0:	8e1fe0ef          	jal	80003e90 <iunlockput>
    return 0;
    800055b4:	4981                	li	s3,0
    800055b6:	b7cd                	j	80005598 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055b8:	85ca                	mv	a1,s2
    800055ba:	4088                	lw	a0,0(s1)
    800055bc:	d58fe0ef          	jal	80003b14 <ialloc>
    800055c0:	892a                	mv	s2,a0
    800055c2:	cd15                	beqz	a0,800055fe <create+0xc6>
  ilock(ip);
    800055c4:	ec0fe0ef          	jal	80003c84 <ilock>
  ip->major = major;
    800055c8:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    800055cc:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    800055d0:	4785                	li	a5,1
    800055d2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055d6:	854a                	mv	a0,s2
    800055d8:	df8fe0ef          	jal	80003bd0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055dc:	4705                	li	a4,1
    800055de:	02ea0463          	beq	s4,a4,80005606 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800055e2:	00492603          	lw	a2,4(s2)
    800055e6:	fb040593          	addi	a1,s0,-80
    800055ea:	8526                	mv	a0,s1
    800055ec:	e1dfe0ef          	jal	80004408 <dirlink>
    800055f0:	06054263          	bltz	a0,80005654 <create+0x11c>
  iunlockput(dp);
    800055f4:	8526                	mv	a0,s1
    800055f6:	89bfe0ef          	jal	80003e90 <iunlockput>
  return ip;
    800055fa:	89ca                	mv	s3,s2
    800055fc:	bf71                	j	80005598 <create+0x60>
    iunlockput(dp);
    800055fe:	8526                	mv	a0,s1
    80005600:	891fe0ef          	jal	80003e90 <iunlockput>
    return 0;
    80005604:	bf51                	j	80005598 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005606:	00492603          	lw	a2,4(s2)
    8000560a:	00003597          	auipc	a1,0x3
    8000560e:	43e58593          	addi	a1,a1,1086 # 80008a48 <etext+0xa48>
    80005612:	854a                	mv	a0,s2
    80005614:	df5fe0ef          	jal	80004408 <dirlink>
    80005618:	02054e63          	bltz	a0,80005654 <create+0x11c>
    8000561c:	40d0                	lw	a2,4(s1)
    8000561e:	00003597          	auipc	a1,0x3
    80005622:	43258593          	addi	a1,a1,1074 # 80008a50 <etext+0xa50>
    80005626:	854a                	mv	a0,s2
    80005628:	de1fe0ef          	jal	80004408 <dirlink>
    8000562c:	02054463          	bltz	a0,80005654 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005630:	00492603          	lw	a2,4(s2)
    80005634:	fb040593          	addi	a1,s0,-80
    80005638:	8526                	mv	a0,s1
    8000563a:	dcffe0ef          	jal	80004408 <dirlink>
    8000563e:	00054b63          	bltz	a0,80005654 <create+0x11c>
    dp->nlink++;  // for ".."
    80005642:	04a4d783          	lhu	a5,74(s1)
    80005646:	2785                	addiw	a5,a5,1
    80005648:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000564c:	8526                	mv	a0,s1
    8000564e:	d82fe0ef          	jal	80003bd0 <iupdate>
    80005652:	b74d                	j	800055f4 <create+0xbc>
  ip->nlink = 0;
    80005654:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005658:	854a                	mv	a0,s2
    8000565a:	d76fe0ef          	jal	80003bd0 <iupdate>
  iunlockput(ip);
    8000565e:	854a                	mv	a0,s2
    80005660:	831fe0ef          	jal	80003e90 <iunlockput>
  iunlockput(dp);
    80005664:	8526                	mv	a0,s1
    80005666:	82bfe0ef          	jal	80003e90 <iunlockput>
  return 0;
    8000566a:	b73d                	j	80005598 <create+0x60>
    return 0;
    8000566c:	89aa                	mv	s3,a0
    8000566e:	b72d                	j	80005598 <create+0x60>

0000000080005670 <sys_dup>:
{
    80005670:	7179                	addi	sp,sp,-48
    80005672:	f406                	sd	ra,40(sp)
    80005674:	f022                	sd	s0,32(sp)
    80005676:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005678:	fd840613          	addi	a2,s0,-40
    8000567c:	4581                	li	a1,0
    8000567e:	4501                	li	a0,0
    80005680:	e1fff0ef          	jal	8000549e <argfd>
    return -1;
    80005684:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005686:	02054363          	bltz	a0,800056ac <sys_dup+0x3c>
    8000568a:	ec26                	sd	s1,24(sp)
    8000568c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000568e:	fd843483          	ld	s1,-40(s0)
    80005692:	8526                	mv	a0,s1
    80005694:	e65ff0ef          	jal	800054f8 <fdalloc>
    80005698:	892a                	mv	s2,a0
    return -1;
    8000569a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000569c:	00054d63          	bltz	a0,800056b6 <sys_dup+0x46>
  filedup(f);
    800056a0:	8526                	mv	a0,s1
    800056a2:	bccff0ef          	jal	80004a6e <filedup>
  return fd;
    800056a6:	87ca                	mv	a5,s2
    800056a8:	64e2                	ld	s1,24(sp)
    800056aa:	6942                	ld	s2,16(sp)
}
    800056ac:	853e                	mv	a0,a5
    800056ae:	70a2                	ld	ra,40(sp)
    800056b0:	7402                	ld	s0,32(sp)
    800056b2:	6145                	addi	sp,sp,48
    800056b4:	8082                	ret
    800056b6:	64e2                	ld	s1,24(sp)
    800056b8:	6942                	ld	s2,16(sp)
    800056ba:	bfcd                	j	800056ac <sys_dup+0x3c>

00000000800056bc <sys_read>:
{
    800056bc:	7179                	addi	sp,sp,-48
    800056be:	f406                	sd	ra,40(sp)
    800056c0:	f022                	sd	s0,32(sp)
    800056c2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056c4:	fd840593          	addi	a1,s0,-40
    800056c8:	4505                	li	a0,1
    800056ca:	be1fd0ef          	jal	800032aa <argaddr>
  argint(2, &n);
    800056ce:	fe440593          	addi	a1,s0,-28
    800056d2:	4509                	li	a0,2
    800056d4:	bbbfd0ef          	jal	8000328e <argint>
  if(argfd(0, 0, &f) < 0)
    800056d8:	fe840613          	addi	a2,s0,-24
    800056dc:	4581                	li	a1,0
    800056de:	4501                	li	a0,0
    800056e0:	dbfff0ef          	jal	8000549e <argfd>
    800056e4:	87aa                	mv	a5,a0
    return -1;
    800056e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056e8:	0007ca63          	bltz	a5,800056fc <sys_read+0x40>
  return fileread(f, p, n);
    800056ec:	fe442603          	lw	a2,-28(s0)
    800056f0:	fd843583          	ld	a1,-40(s0)
    800056f4:	fe843503          	ld	a0,-24(s0)
    800056f8:	ce0ff0ef          	jal	80004bd8 <fileread>
}
    800056fc:	70a2                	ld	ra,40(sp)
    800056fe:	7402                	ld	s0,32(sp)
    80005700:	6145                	addi	sp,sp,48
    80005702:	8082                	ret

0000000080005704 <sys_write>:
{
    80005704:	7179                	addi	sp,sp,-48
    80005706:	f406                	sd	ra,40(sp)
    80005708:	f022                	sd	s0,32(sp)
    8000570a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000570c:	fd840593          	addi	a1,s0,-40
    80005710:	4505                	li	a0,1
    80005712:	b99fd0ef          	jal	800032aa <argaddr>
  argint(2, &n);
    80005716:	fe440593          	addi	a1,s0,-28
    8000571a:	4509                	li	a0,2
    8000571c:	b73fd0ef          	jal	8000328e <argint>
  if(argfd(0, 0, &f) < 0)
    80005720:	fe840613          	addi	a2,s0,-24
    80005724:	4581                	li	a1,0
    80005726:	4501                	li	a0,0
    80005728:	d77ff0ef          	jal	8000549e <argfd>
    8000572c:	87aa                	mv	a5,a0
    return -1;
    8000572e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005730:	0007ca63          	bltz	a5,80005744 <sys_write+0x40>
  return filewrite(f, p, n);
    80005734:	fe442603          	lw	a2,-28(s0)
    80005738:	fd843583          	ld	a1,-40(s0)
    8000573c:	fe843503          	ld	a0,-24(s0)
    80005740:	d5cff0ef          	jal	80004c9c <filewrite>
}
    80005744:	70a2                	ld	ra,40(sp)
    80005746:	7402                	ld	s0,32(sp)
    80005748:	6145                	addi	sp,sp,48
    8000574a:	8082                	ret

000000008000574c <sys_close>:
{
    8000574c:	1101                	addi	sp,sp,-32
    8000574e:	ec06                	sd	ra,24(sp)
    80005750:	e822                	sd	s0,16(sp)
    80005752:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005754:	fe040613          	addi	a2,s0,-32
    80005758:	fec40593          	addi	a1,s0,-20
    8000575c:	4501                	li	a0,0
    8000575e:	d41ff0ef          	jal	8000549e <argfd>
    return -1;
    80005762:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005764:	02054163          	bltz	a0,80005786 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005768:	b4efc0ef          	jal	80001ab6 <myproc>
    8000576c:	fec42783          	lw	a5,-20(s0)
    80005770:	078e                	slli	a5,a5,0x3
    80005772:	0d078793          	addi	a5,a5,208
    80005776:	953e                	add	a0,a0,a5
    80005778:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000577c:	fe043503          	ld	a0,-32(s0)
    80005780:	b34ff0ef          	jal	80004ab4 <fileclose>
  return 0;
    80005784:	4781                	li	a5,0
}
    80005786:	853e                	mv	a0,a5
    80005788:	60e2                	ld	ra,24(sp)
    8000578a:	6442                	ld	s0,16(sp)
    8000578c:	6105                	addi	sp,sp,32
    8000578e:	8082                	ret

0000000080005790 <sys_fstat>:
{
    80005790:	1101                	addi	sp,sp,-32
    80005792:	ec06                	sd	ra,24(sp)
    80005794:	e822                	sd	s0,16(sp)
    80005796:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005798:	fe040593          	addi	a1,s0,-32
    8000579c:	4505                	li	a0,1
    8000579e:	b0dfd0ef          	jal	800032aa <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057a2:	fe840613          	addi	a2,s0,-24
    800057a6:	4581                	li	a1,0
    800057a8:	4501                	li	a0,0
    800057aa:	cf5ff0ef          	jal	8000549e <argfd>
    800057ae:	87aa                	mv	a5,a0
    return -1;
    800057b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057b2:	0007c863          	bltz	a5,800057c2 <sys_fstat+0x32>
  return filestat(f, st);
    800057b6:	fe043583          	ld	a1,-32(s0)
    800057ba:	fe843503          	ld	a0,-24(s0)
    800057be:	bb8ff0ef          	jal	80004b76 <filestat>
}
    800057c2:	60e2                	ld	ra,24(sp)
    800057c4:	6442                	ld	s0,16(sp)
    800057c6:	6105                	addi	sp,sp,32
    800057c8:	8082                	ret

00000000800057ca <sys_link>:
{
    800057ca:	7169                	addi	sp,sp,-304
    800057cc:	f606                	sd	ra,296(sp)
    800057ce:	f222                	sd	s0,288(sp)
    800057d0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057d2:	08000613          	li	a2,128
    800057d6:	ed040593          	addi	a1,s0,-304
    800057da:	4501                	li	a0,0
    800057dc:	aebfd0ef          	jal	800032c6 <argstr>
    return -1;
    800057e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057e2:	0c054e63          	bltz	a0,800058be <sys_link+0xf4>
    800057e6:	08000613          	li	a2,128
    800057ea:	f5040593          	addi	a1,s0,-176
    800057ee:	4505                	li	a0,1
    800057f0:	ad7fd0ef          	jal	800032c6 <argstr>
    return -1;
    800057f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057f6:	0c054463          	bltz	a0,800058be <sys_link+0xf4>
    800057fa:	ee26                	sd	s1,280(sp)
  begin_op();
    800057fc:	e95fe0ef          	jal	80004690 <begin_op>
  if((ip = namei(old)) == 0){
    80005800:	ed040513          	addi	a0,s0,-304
    80005804:	caffe0ef          	jal	800044b2 <namei>
    80005808:	84aa                	mv	s1,a0
    8000580a:	c53d                	beqz	a0,80005878 <sys_link+0xae>
  ilock(ip);
    8000580c:	c78fe0ef          	jal	80003c84 <ilock>
  if(ip->type == T_DIR){
    80005810:	04449703          	lh	a4,68(s1)
    80005814:	4785                	li	a5,1
    80005816:	06f70663          	beq	a4,a5,80005882 <sys_link+0xb8>
    8000581a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000581c:	04a4d783          	lhu	a5,74(s1)
    80005820:	2785                	addiw	a5,a5,1
    80005822:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005826:	8526                	mv	a0,s1
    80005828:	ba8fe0ef          	jal	80003bd0 <iupdate>
  iunlock(ip);
    8000582c:	8526                	mv	a0,s1
    8000582e:	d04fe0ef          	jal	80003d32 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005832:	fd040593          	addi	a1,s0,-48
    80005836:	f5040513          	addi	a0,s0,-176
    8000583a:	c93fe0ef          	jal	800044cc <nameiparent>
    8000583e:	892a                	mv	s2,a0
    80005840:	cd21                	beqz	a0,80005898 <sys_link+0xce>
  ilock(dp);
    80005842:	c42fe0ef          	jal	80003c84 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005846:	854a                	mv	a0,s2
    80005848:	00092703          	lw	a4,0(s2)
    8000584c:	409c                	lw	a5,0(s1)
    8000584e:	04f71263          	bne	a4,a5,80005892 <sys_link+0xc8>
    80005852:	40d0                	lw	a2,4(s1)
    80005854:	fd040593          	addi	a1,s0,-48
    80005858:	bb1fe0ef          	jal	80004408 <dirlink>
    8000585c:	02054b63          	bltz	a0,80005892 <sys_link+0xc8>
  iunlockput(dp);
    80005860:	854a                	mv	a0,s2
    80005862:	e2efe0ef          	jal	80003e90 <iunlockput>
  iput(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	d9efe0ef          	jal	80003e06 <iput>
  end_op();
    8000586c:	e95fe0ef          	jal	80004700 <end_op>
  return 0;
    80005870:	4781                	li	a5,0
    80005872:	64f2                	ld	s1,280(sp)
    80005874:	6952                	ld	s2,272(sp)
    80005876:	a0a1                	j	800058be <sys_link+0xf4>
    end_op();
    80005878:	e89fe0ef          	jal	80004700 <end_op>
    return -1;
    8000587c:	57fd                	li	a5,-1
    8000587e:	64f2                	ld	s1,280(sp)
    80005880:	a83d                	j	800058be <sys_link+0xf4>
    iunlockput(ip);
    80005882:	8526                	mv	a0,s1
    80005884:	e0cfe0ef          	jal	80003e90 <iunlockput>
    end_op();
    80005888:	e79fe0ef          	jal	80004700 <end_op>
    return -1;
    8000588c:	57fd                	li	a5,-1
    8000588e:	64f2                	ld	s1,280(sp)
    80005890:	a03d                	j	800058be <sys_link+0xf4>
    iunlockput(dp);
    80005892:	854a                	mv	a0,s2
    80005894:	dfcfe0ef          	jal	80003e90 <iunlockput>
  ilock(ip);
    80005898:	8526                	mv	a0,s1
    8000589a:	beafe0ef          	jal	80003c84 <ilock>
  ip->nlink--;
    8000589e:	04a4d783          	lhu	a5,74(s1)
    800058a2:	37fd                	addiw	a5,a5,-1
    800058a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	b26fe0ef          	jal	80003bd0 <iupdate>
  iunlockput(ip);
    800058ae:	8526                	mv	a0,s1
    800058b0:	de0fe0ef          	jal	80003e90 <iunlockput>
  end_op();
    800058b4:	e4dfe0ef          	jal	80004700 <end_op>
  return -1;
    800058b8:	57fd                	li	a5,-1
    800058ba:	64f2                	ld	s1,280(sp)
    800058bc:	6952                	ld	s2,272(sp)
}
    800058be:	853e                	mv	a0,a5
    800058c0:	70b2                	ld	ra,296(sp)
    800058c2:	7412                	ld	s0,288(sp)
    800058c4:	6155                	addi	sp,sp,304
    800058c6:	8082                	ret

00000000800058c8 <sys_unlink>:
{
    800058c8:	7151                	addi	sp,sp,-240
    800058ca:	f586                	sd	ra,232(sp)
    800058cc:	f1a2                	sd	s0,224(sp)
    800058ce:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058d0:	08000613          	li	a2,128
    800058d4:	f3040593          	addi	a1,s0,-208
    800058d8:	4501                	li	a0,0
    800058da:	9edfd0ef          	jal	800032c6 <argstr>
    800058de:	14054d63          	bltz	a0,80005a38 <sys_unlink+0x170>
    800058e2:	eda6                	sd	s1,216(sp)
  begin_op();
    800058e4:	dadfe0ef          	jal	80004690 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058e8:	fb040593          	addi	a1,s0,-80
    800058ec:	f3040513          	addi	a0,s0,-208
    800058f0:	bddfe0ef          	jal	800044cc <nameiparent>
    800058f4:	84aa                	mv	s1,a0
    800058f6:	c955                	beqz	a0,800059aa <sys_unlink+0xe2>
  ilock(dp);
    800058f8:	b8cfe0ef          	jal	80003c84 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058fc:	00003597          	auipc	a1,0x3
    80005900:	14c58593          	addi	a1,a1,332 # 80008a48 <etext+0xa48>
    80005904:	fb040513          	addi	a0,s0,-80
    80005908:	901fe0ef          	jal	80004208 <namecmp>
    8000590c:	10050b63          	beqz	a0,80005a22 <sys_unlink+0x15a>
    80005910:	00003597          	auipc	a1,0x3
    80005914:	14058593          	addi	a1,a1,320 # 80008a50 <etext+0xa50>
    80005918:	fb040513          	addi	a0,s0,-80
    8000591c:	8edfe0ef          	jal	80004208 <namecmp>
    80005920:	10050163          	beqz	a0,80005a22 <sys_unlink+0x15a>
    80005924:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005926:	f2c40613          	addi	a2,s0,-212
    8000592a:	fb040593          	addi	a1,s0,-80
    8000592e:	8526                	mv	a0,s1
    80005930:	8effe0ef          	jal	8000421e <dirlookup>
    80005934:	892a                	mv	s2,a0
    80005936:	0e050563          	beqz	a0,80005a20 <sys_unlink+0x158>
    8000593a:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000593c:	b48fe0ef          	jal	80003c84 <ilock>
  if(ip->nlink < 1)
    80005940:	04a91783          	lh	a5,74(s2)
    80005944:	06f05863          	blez	a5,800059b4 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005948:	04491703          	lh	a4,68(s2)
    8000594c:	4785                	li	a5,1
    8000594e:	06f70963          	beq	a4,a5,800059c0 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005952:	fc040993          	addi	s3,s0,-64
    80005956:	4641                	li	a2,16
    80005958:	4581                	li	a1,0
    8000595a:	854e                	mv	a0,s3
    8000595c:	b9cfb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005960:	4741                	li	a4,16
    80005962:	f2c42683          	lw	a3,-212(s0)
    80005966:	864e                	mv	a2,s3
    80005968:	4581                	li	a1,0
    8000596a:	8526                	mv	a0,s1
    8000596c:	f9cfe0ef          	jal	80004108 <writei>
    80005970:	47c1                	li	a5,16
    80005972:	08f51863          	bne	a0,a5,80005a02 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005976:	04491703          	lh	a4,68(s2)
    8000597a:	4785                	li	a5,1
    8000597c:	08f70963          	beq	a4,a5,80005a0e <sys_unlink+0x146>
  iunlockput(dp);
    80005980:	8526                	mv	a0,s1
    80005982:	d0efe0ef          	jal	80003e90 <iunlockput>
  ip->nlink--;
    80005986:	04a95783          	lhu	a5,74(s2)
    8000598a:	37fd                	addiw	a5,a5,-1
    8000598c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005990:	854a                	mv	a0,s2
    80005992:	a3efe0ef          	jal	80003bd0 <iupdate>
  iunlockput(ip);
    80005996:	854a                	mv	a0,s2
    80005998:	cf8fe0ef          	jal	80003e90 <iunlockput>
  end_op();
    8000599c:	d65fe0ef          	jal	80004700 <end_op>
  return 0;
    800059a0:	4501                	li	a0,0
    800059a2:	64ee                	ld	s1,216(sp)
    800059a4:	694e                	ld	s2,208(sp)
    800059a6:	69ae                	ld	s3,200(sp)
    800059a8:	a061                	j	80005a30 <sys_unlink+0x168>
    end_op();
    800059aa:	d57fe0ef          	jal	80004700 <end_op>
    return -1;
    800059ae:	557d                	li	a0,-1
    800059b0:	64ee                	ld	s1,216(sp)
    800059b2:	a8bd                	j	80005a30 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800059b4:	00003517          	auipc	a0,0x3
    800059b8:	0a450513          	addi	a0,a0,164 # 80008a58 <etext+0xa58>
    800059bc:	e69fa0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c0:	04c92703          	lw	a4,76(s2)
    800059c4:	02000793          	li	a5,32
    800059c8:	f8e7f5e3          	bgeu	a5,a4,80005952 <sys_unlink+0x8a>
    800059cc:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059ce:	4741                	li	a4,16
    800059d0:	86ce                	mv	a3,s3
    800059d2:	f1840613          	addi	a2,s0,-232
    800059d6:	4581                	li	a1,0
    800059d8:	854a                	mv	a0,s2
    800059da:	e3cfe0ef          	jal	80004016 <readi>
    800059de:	47c1                	li	a5,16
    800059e0:	00f51b63          	bne	a0,a5,800059f6 <sys_unlink+0x12e>
    if(de.inum != 0)
    800059e4:	f1845783          	lhu	a5,-232(s0)
    800059e8:	ebb1                	bnez	a5,80005a3c <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059ea:	29c1                	addiw	s3,s3,16
    800059ec:	04c92783          	lw	a5,76(s2)
    800059f0:	fcf9efe3          	bltu	s3,a5,800059ce <sys_unlink+0x106>
    800059f4:	bfb9                	j	80005952 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800059f6:	00003517          	auipc	a0,0x3
    800059fa:	07a50513          	addi	a0,a0,122 # 80008a70 <etext+0xa70>
    800059fe:	e27fa0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005a02:	00003517          	auipc	a0,0x3
    80005a06:	08650513          	addi	a0,a0,134 # 80008a88 <etext+0xa88>
    80005a0a:	e1bfa0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005a0e:	04a4d783          	lhu	a5,74(s1)
    80005a12:	37fd                	addiw	a5,a5,-1
    80005a14:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a18:	8526                	mv	a0,s1
    80005a1a:	9b6fe0ef          	jal	80003bd0 <iupdate>
    80005a1e:	b78d                	j	80005980 <sys_unlink+0xb8>
    80005a20:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005a22:	8526                	mv	a0,s1
    80005a24:	c6cfe0ef          	jal	80003e90 <iunlockput>
  end_op();
    80005a28:	cd9fe0ef          	jal	80004700 <end_op>
  return -1;
    80005a2c:	557d                	li	a0,-1
    80005a2e:	64ee                	ld	s1,216(sp)
}
    80005a30:	70ae                	ld	ra,232(sp)
    80005a32:	740e                	ld	s0,224(sp)
    80005a34:	616d                	addi	sp,sp,240
    80005a36:	8082                	ret
    return -1;
    80005a38:	557d                	li	a0,-1
    80005a3a:	bfdd                	j	80005a30 <sys_unlink+0x168>
    iunlockput(ip);
    80005a3c:	854a                	mv	a0,s2
    80005a3e:	c52fe0ef          	jal	80003e90 <iunlockput>
    goto bad;
    80005a42:	694e                	ld	s2,208(sp)
    80005a44:	69ae                	ld	s3,200(sp)
    80005a46:	bff1                	j	80005a22 <sys_unlink+0x15a>

0000000080005a48 <sys_open>:

uint64
sys_open(void)
{
    80005a48:	7131                	addi	sp,sp,-192
    80005a4a:	fd06                	sd	ra,184(sp)
    80005a4c:	f922                	sd	s0,176(sp)
    80005a4e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a50:	f4c40593          	addi	a1,s0,-180
    80005a54:	4505                	li	a0,1
    80005a56:	839fd0ef          	jal	8000328e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a5a:	08000613          	li	a2,128
    80005a5e:	f5040593          	addi	a1,s0,-176
    80005a62:	4501                	li	a0,0
    80005a64:	863fd0ef          	jal	800032c6 <argstr>
    80005a68:	87aa                	mv	a5,a0
    return -1;
    80005a6a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a6c:	0a07c363          	bltz	a5,80005b12 <sys_open+0xca>
    80005a70:	f526                	sd	s1,168(sp)

  begin_op();
    80005a72:	c1ffe0ef          	jal	80004690 <begin_op>

  if(omode & O_CREATE){
    80005a76:	f4c42783          	lw	a5,-180(s0)
    80005a7a:	2007f793          	andi	a5,a5,512
    80005a7e:	c3dd                	beqz	a5,80005b24 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005a80:	4681                	li	a3,0
    80005a82:	4601                	li	a2,0
    80005a84:	4589                	li	a1,2
    80005a86:	f5040513          	addi	a0,s0,-176
    80005a8a:	aafff0ef          	jal	80005538 <create>
    80005a8e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a90:	c549                	beqz	a0,80005b1a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a92:	04449703          	lh	a4,68(s1)
    80005a96:	478d                	li	a5,3
    80005a98:	00f71763          	bne	a4,a5,80005aa6 <sys_open+0x5e>
    80005a9c:	0464d703          	lhu	a4,70(s1)
    80005aa0:	47a5                	li	a5,9
    80005aa2:	0ae7ee63          	bltu	a5,a4,80005b5e <sys_open+0x116>
    80005aa6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005aa8:	f69fe0ef          	jal	80004a10 <filealloc>
    80005aac:	892a                	mv	s2,a0
    80005aae:	c561                	beqz	a0,80005b76 <sys_open+0x12e>
    80005ab0:	ed4e                	sd	s3,152(sp)
    80005ab2:	a47ff0ef          	jal	800054f8 <fdalloc>
    80005ab6:	89aa                	mv	s3,a0
    80005ab8:	0a054b63          	bltz	a0,80005b6e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005abc:	04449703          	lh	a4,68(s1)
    80005ac0:	478d                	li	a5,3
    80005ac2:	0cf70363          	beq	a4,a5,80005b88 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ac6:	4789                	li	a5,2
    80005ac8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005acc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005ad0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ad4:	f4c42783          	lw	a5,-180(s0)
    80005ad8:	0017f713          	andi	a4,a5,1
    80005adc:	00174713          	xori	a4,a4,1
    80005ae0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ae4:	0037f713          	andi	a4,a5,3
    80005ae8:	00e03733          	snez	a4,a4
    80005aec:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005af0:	4007f793          	andi	a5,a5,1024
    80005af4:	c791                	beqz	a5,80005b00 <sys_open+0xb8>
    80005af6:	04449703          	lh	a4,68(s1)
    80005afa:	4789                	li	a5,2
    80005afc:	08f70d63          	beq	a4,a5,80005b96 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005b00:	8526                	mv	a0,s1
    80005b02:	a30fe0ef          	jal	80003d32 <iunlock>
  end_op();
    80005b06:	bfbfe0ef          	jal	80004700 <end_op>

  return fd;
    80005b0a:	854e                	mv	a0,s3
    80005b0c:	74aa                	ld	s1,168(sp)
    80005b0e:	790a                	ld	s2,160(sp)
    80005b10:	69ea                	ld	s3,152(sp)
}
    80005b12:	70ea                	ld	ra,184(sp)
    80005b14:	744a                	ld	s0,176(sp)
    80005b16:	6129                	addi	sp,sp,192
    80005b18:	8082                	ret
      end_op();
    80005b1a:	be7fe0ef          	jal	80004700 <end_op>
      return -1;
    80005b1e:	557d                	li	a0,-1
    80005b20:	74aa                	ld	s1,168(sp)
    80005b22:	bfc5                	j	80005b12 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005b24:	f5040513          	addi	a0,s0,-176
    80005b28:	98bfe0ef          	jal	800044b2 <namei>
    80005b2c:	84aa                	mv	s1,a0
    80005b2e:	c11d                	beqz	a0,80005b54 <sys_open+0x10c>
    ilock(ip);
    80005b30:	954fe0ef          	jal	80003c84 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b34:	04449703          	lh	a4,68(s1)
    80005b38:	4785                	li	a5,1
    80005b3a:	f4f71ce3          	bne	a4,a5,80005a92 <sys_open+0x4a>
    80005b3e:	f4c42783          	lw	a5,-180(s0)
    80005b42:	d3b5                	beqz	a5,80005aa6 <sys_open+0x5e>
      iunlockput(ip);
    80005b44:	8526                	mv	a0,s1
    80005b46:	b4afe0ef          	jal	80003e90 <iunlockput>
      end_op();
    80005b4a:	bb7fe0ef          	jal	80004700 <end_op>
      return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	74aa                	ld	s1,168(sp)
    80005b52:	b7c1                	j	80005b12 <sys_open+0xca>
      end_op();
    80005b54:	badfe0ef          	jal	80004700 <end_op>
      return -1;
    80005b58:	557d                	li	a0,-1
    80005b5a:	74aa                	ld	s1,168(sp)
    80005b5c:	bf5d                	j	80005b12 <sys_open+0xca>
    iunlockput(ip);
    80005b5e:	8526                	mv	a0,s1
    80005b60:	b30fe0ef          	jal	80003e90 <iunlockput>
    end_op();
    80005b64:	b9dfe0ef          	jal	80004700 <end_op>
    return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	74aa                	ld	s1,168(sp)
    80005b6c:	b75d                	j	80005b12 <sys_open+0xca>
      fileclose(f);
    80005b6e:	854a                	mv	a0,s2
    80005b70:	f45fe0ef          	jal	80004ab4 <fileclose>
    80005b74:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005b76:	8526                	mv	a0,s1
    80005b78:	b18fe0ef          	jal	80003e90 <iunlockput>
    end_op();
    80005b7c:	b85fe0ef          	jal	80004700 <end_op>
    return -1;
    80005b80:	557d                	li	a0,-1
    80005b82:	74aa                	ld	s1,168(sp)
    80005b84:	790a                	ld	s2,160(sp)
    80005b86:	b771                	j	80005b12 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005b88:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005b8c:	04649783          	lh	a5,70(s1)
    80005b90:	02f91223          	sh	a5,36(s2)
    80005b94:	bf35                	j	80005ad0 <sys_open+0x88>
    itrunc(ip);
    80005b96:	8526                	mv	a0,s1
    80005b98:	9dafe0ef          	jal	80003d72 <itrunc>
    80005b9c:	b795                	j	80005b00 <sys_open+0xb8>

0000000080005b9e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b9e:	7175                	addi	sp,sp,-144
    80005ba0:	e506                	sd	ra,136(sp)
    80005ba2:	e122                	sd	s0,128(sp)
    80005ba4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ba6:	aebfe0ef          	jal	80004690 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005baa:	08000613          	li	a2,128
    80005bae:	f7040593          	addi	a1,s0,-144
    80005bb2:	4501                	li	a0,0
    80005bb4:	f12fd0ef          	jal	800032c6 <argstr>
    80005bb8:	02054363          	bltz	a0,80005bde <sys_mkdir+0x40>
    80005bbc:	4681                	li	a3,0
    80005bbe:	4601                	li	a2,0
    80005bc0:	4585                	li	a1,1
    80005bc2:	f7040513          	addi	a0,s0,-144
    80005bc6:	973ff0ef          	jal	80005538 <create>
    80005bca:	c911                	beqz	a0,80005bde <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bcc:	ac4fe0ef          	jal	80003e90 <iunlockput>
  end_op();
    80005bd0:	b31fe0ef          	jal	80004700 <end_op>
  return 0;
    80005bd4:	4501                	li	a0,0
}
    80005bd6:	60aa                	ld	ra,136(sp)
    80005bd8:	640a                	ld	s0,128(sp)
    80005bda:	6149                	addi	sp,sp,144
    80005bdc:	8082                	ret
    end_op();
    80005bde:	b23fe0ef          	jal	80004700 <end_op>
    return -1;
    80005be2:	557d                	li	a0,-1
    80005be4:	bfcd                	j	80005bd6 <sys_mkdir+0x38>

0000000080005be6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005be6:	7135                	addi	sp,sp,-160
    80005be8:	ed06                	sd	ra,152(sp)
    80005bea:	e922                	sd	s0,144(sp)
    80005bec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bee:	aa3fe0ef          	jal	80004690 <begin_op>
  argint(1, &major);
    80005bf2:	f6c40593          	addi	a1,s0,-148
    80005bf6:	4505                	li	a0,1
    80005bf8:	e96fd0ef          	jal	8000328e <argint>
  argint(2, &minor);
    80005bfc:	f6840593          	addi	a1,s0,-152
    80005c00:	4509                	li	a0,2
    80005c02:	e8cfd0ef          	jal	8000328e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c06:	08000613          	li	a2,128
    80005c0a:	f7040593          	addi	a1,s0,-144
    80005c0e:	4501                	li	a0,0
    80005c10:	eb6fd0ef          	jal	800032c6 <argstr>
    80005c14:	02054563          	bltz	a0,80005c3e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c18:	f6841683          	lh	a3,-152(s0)
    80005c1c:	f6c41603          	lh	a2,-148(s0)
    80005c20:	458d                	li	a1,3
    80005c22:	f7040513          	addi	a0,s0,-144
    80005c26:	913ff0ef          	jal	80005538 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c2a:	c911                	beqz	a0,80005c3e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c2c:	a64fe0ef          	jal	80003e90 <iunlockput>
  end_op();
    80005c30:	ad1fe0ef          	jal	80004700 <end_op>
  return 0;
    80005c34:	4501                	li	a0,0
}
    80005c36:	60ea                	ld	ra,152(sp)
    80005c38:	644a                	ld	s0,144(sp)
    80005c3a:	610d                	addi	sp,sp,160
    80005c3c:	8082                	ret
    end_op();
    80005c3e:	ac3fe0ef          	jal	80004700 <end_op>
    return -1;
    80005c42:	557d                	li	a0,-1
    80005c44:	bfcd                	j	80005c36 <sys_mknod+0x50>

0000000080005c46 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c46:	7135                	addi	sp,sp,-160
    80005c48:	ed06                	sd	ra,152(sp)
    80005c4a:	e922                	sd	s0,144(sp)
    80005c4c:	e14a                	sd	s2,128(sp)
    80005c4e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c50:	e67fb0ef          	jal	80001ab6 <myproc>
    80005c54:	892a                	mv	s2,a0
  
  begin_op();
    80005c56:	a3bfe0ef          	jal	80004690 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c5a:	08000613          	li	a2,128
    80005c5e:	f6040593          	addi	a1,s0,-160
    80005c62:	4501                	li	a0,0
    80005c64:	e62fd0ef          	jal	800032c6 <argstr>
    80005c68:	04054363          	bltz	a0,80005cae <sys_chdir+0x68>
    80005c6c:	e526                	sd	s1,136(sp)
    80005c6e:	f6040513          	addi	a0,s0,-160
    80005c72:	841fe0ef          	jal	800044b2 <namei>
    80005c76:	84aa                	mv	s1,a0
    80005c78:	c915                	beqz	a0,80005cac <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c7a:	80afe0ef          	jal	80003c84 <ilock>
  if(ip->type != T_DIR){
    80005c7e:	04449703          	lh	a4,68(s1)
    80005c82:	4785                	li	a5,1
    80005c84:	02f71963          	bne	a4,a5,80005cb6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c88:	8526                	mv	a0,s1
    80005c8a:	8a8fe0ef          	jal	80003d32 <iunlock>
  iput(p->cwd);
    80005c8e:	15893503          	ld	a0,344(s2)
    80005c92:	974fe0ef          	jal	80003e06 <iput>
  end_op();
    80005c96:	a6bfe0ef          	jal	80004700 <end_op>
  p->cwd = ip;
    80005c9a:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c9e:	4501                	li	a0,0
    80005ca0:	64aa                	ld	s1,136(sp)
}
    80005ca2:	60ea                	ld	ra,152(sp)
    80005ca4:	644a                	ld	s0,144(sp)
    80005ca6:	690a                	ld	s2,128(sp)
    80005ca8:	610d                	addi	sp,sp,160
    80005caa:	8082                	ret
    80005cac:	64aa                	ld	s1,136(sp)
    end_op();
    80005cae:	a53fe0ef          	jal	80004700 <end_op>
    return -1;
    80005cb2:	557d                	li	a0,-1
    80005cb4:	b7fd                	j	80005ca2 <sys_chdir+0x5c>
    iunlockput(ip);
    80005cb6:	8526                	mv	a0,s1
    80005cb8:	9d8fe0ef          	jal	80003e90 <iunlockput>
    end_op();
    80005cbc:	a45fe0ef          	jal	80004700 <end_op>
    return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	64aa                	ld	s1,136(sp)
    80005cc4:	bff9                	j	80005ca2 <sys_chdir+0x5c>

0000000080005cc6 <sys_exec>:

uint64
sys_exec(void)
{
    80005cc6:	7105                	addi	sp,sp,-480
    80005cc8:	ef86                	sd	ra,472(sp)
    80005cca:	eba2                	sd	s0,464(sp)
    80005ccc:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cce:	e2840593          	addi	a1,s0,-472
    80005cd2:	4505                	li	a0,1
    80005cd4:	dd6fd0ef          	jal	800032aa <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cd8:	08000613          	li	a2,128
    80005cdc:	f3040593          	addi	a1,s0,-208
    80005ce0:	4501                	li	a0,0
    80005ce2:	de4fd0ef          	jal	800032c6 <argstr>
    80005ce6:	87aa                	mv	a5,a0
    return -1;
    80005ce8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cea:	0e07c063          	bltz	a5,80005dca <sys_exec+0x104>
    80005cee:	e7a6                	sd	s1,456(sp)
    80005cf0:	e3ca                	sd	s2,448(sp)
    80005cf2:	ff4e                	sd	s3,440(sp)
    80005cf4:	fb52                	sd	s4,432(sp)
    80005cf6:	f756                	sd	s5,424(sp)
    80005cf8:	f35a                	sd	s6,416(sp)
    80005cfa:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005cfc:	e3040a13          	addi	s4,s0,-464
    80005d00:	10000613          	li	a2,256
    80005d04:	4581                	li	a1,0
    80005d06:	8552                	mv	a0,s4
    80005d08:	ff1fa0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d0c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005d0e:	89d2                	mv	s3,s4
    80005d10:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d12:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d16:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005d18:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d1c:	00391513          	slli	a0,s2,0x3
    80005d20:	85d6                	mv	a1,s5
    80005d22:	e2843783          	ld	a5,-472(s0)
    80005d26:	953e                	add	a0,a0,a5
    80005d28:	cdcfd0ef          	jal	80003204 <fetchaddr>
    80005d2c:	02054663          	bltz	a0,80005d58 <sys_exec+0x92>
    if(uarg == 0){
    80005d30:	e2043783          	ld	a5,-480(s0)
    80005d34:	c7a1                	beqz	a5,80005d7c <sys_exec+0xb6>
    argv[i] = kalloc();
    80005d36:	e0ffa0ef          	jal	80000b44 <kalloc>
    80005d3a:	85aa                	mv	a1,a0
    80005d3c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d40:	cd01                	beqz	a0,80005d58 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d42:	865a                	mv	a2,s6
    80005d44:	e2043503          	ld	a0,-480(s0)
    80005d48:	d06fd0ef          	jal	8000324e <fetchstr>
    80005d4c:	00054663          	bltz	a0,80005d58 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005d50:	0905                	addi	s2,s2,1
    80005d52:	09a1                	addi	s3,s3,8
    80005d54:	fd7914e3          	bne	s2,s7,80005d1c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d58:	100a0a13          	addi	s4,s4,256
    80005d5c:	6088                	ld	a0,0(s1)
    80005d5e:	cd31                	beqz	a0,80005dba <sys_exec+0xf4>
    kfree(argv[i]);
    80005d60:	cfdfa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d64:	04a1                	addi	s1,s1,8
    80005d66:	ff449be3          	bne	s1,s4,80005d5c <sys_exec+0x96>
  return -1;
    80005d6a:	557d                	li	a0,-1
    80005d6c:	64be                	ld	s1,456(sp)
    80005d6e:	691e                	ld	s2,448(sp)
    80005d70:	79fa                	ld	s3,440(sp)
    80005d72:	7a5a                	ld	s4,432(sp)
    80005d74:	7aba                	ld	s5,424(sp)
    80005d76:	7b1a                	ld	s6,416(sp)
    80005d78:	6bfa                	ld	s7,408(sp)
    80005d7a:	a881                	j	80005dca <sys_exec+0x104>
      argv[i] = 0;
    80005d7c:	0009079b          	sext.w	a5,s2
    80005d80:	e3040593          	addi	a1,s0,-464
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97ae                	add	a5,a5,a1
    80005d88:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005d8c:	f3040513          	addi	a0,s0,-208
    80005d90:	bb2ff0ef          	jal	80005142 <kexec>
    80005d94:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d96:	100a0a13          	addi	s4,s4,256
    80005d9a:	6088                	ld	a0,0(s1)
    80005d9c:	c511                	beqz	a0,80005da8 <sys_exec+0xe2>
    kfree(argv[i]);
    80005d9e:	cbffa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da2:	04a1                	addi	s1,s1,8
    80005da4:	ff449be3          	bne	s1,s4,80005d9a <sys_exec+0xd4>
  return ret;
    80005da8:	854a                	mv	a0,s2
    80005daa:	64be                	ld	s1,456(sp)
    80005dac:	691e                	ld	s2,448(sp)
    80005dae:	79fa                	ld	s3,440(sp)
    80005db0:	7a5a                	ld	s4,432(sp)
    80005db2:	7aba                	ld	s5,424(sp)
    80005db4:	7b1a                	ld	s6,416(sp)
    80005db6:	6bfa                	ld	s7,408(sp)
    80005db8:	a809                	j	80005dca <sys_exec+0x104>
  return -1;
    80005dba:	557d                	li	a0,-1
    80005dbc:	64be                	ld	s1,456(sp)
    80005dbe:	691e                	ld	s2,448(sp)
    80005dc0:	79fa                	ld	s3,440(sp)
    80005dc2:	7a5a                	ld	s4,432(sp)
    80005dc4:	7aba                	ld	s5,424(sp)
    80005dc6:	7b1a                	ld	s6,416(sp)
    80005dc8:	6bfa                	ld	s7,408(sp)
}
    80005dca:	60fe                	ld	ra,472(sp)
    80005dcc:	645e                	ld	s0,464(sp)
    80005dce:	613d                	addi	sp,sp,480
    80005dd0:	8082                	ret

0000000080005dd2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dd2:	7139                	addi	sp,sp,-64
    80005dd4:	fc06                	sd	ra,56(sp)
    80005dd6:	f822                	sd	s0,48(sp)
    80005dd8:	f426                	sd	s1,40(sp)
    80005dda:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ddc:	cdbfb0ef          	jal	80001ab6 <myproc>
    80005de0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005de2:	fd840593          	addi	a1,s0,-40
    80005de6:	4501                	li	a0,0
    80005de8:	cc2fd0ef          	jal	800032aa <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005dec:	fc840593          	addi	a1,s0,-56
    80005df0:	fd040513          	addi	a0,s0,-48
    80005df4:	fddfe0ef          	jal	80004dd0 <pipealloc>
    return -1;
    80005df8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dfa:	0a054763          	bltz	a0,80005ea8 <sys_pipe+0xd6>
  fd0 = -1;
    80005dfe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e02:	fd043503          	ld	a0,-48(s0)
    80005e06:	ef2ff0ef          	jal	800054f8 <fdalloc>
    80005e0a:	fca42223          	sw	a0,-60(s0)
    80005e0e:	08054463          	bltz	a0,80005e96 <sys_pipe+0xc4>
    80005e12:	fc843503          	ld	a0,-56(s0)
    80005e16:	ee2ff0ef          	jal	800054f8 <fdalloc>
    80005e1a:	fca42023          	sw	a0,-64(s0)
    80005e1e:	06054263          	bltz	a0,80005e82 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e22:	4691                	li	a3,4
    80005e24:	fc440613          	addi	a2,s0,-60
    80005e28:	fd843583          	ld	a1,-40(s0)
    80005e2c:	6ca8                	ld	a0,88(s1)
    80005e2e:	827fb0ef          	jal	80001654 <copyout>
    80005e32:	00054e63          	bltz	a0,80005e4e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e36:	4691                	li	a3,4
    80005e38:	fc040613          	addi	a2,s0,-64
    80005e3c:	fd843583          	ld	a1,-40(s0)
    80005e40:	95b6                	add	a1,a1,a3
    80005e42:	6ca8                	ld	a0,88(s1)
    80005e44:	811fb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e48:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e4a:	04055f63          	bgez	a0,80005ea8 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005e4e:	fc442783          	lw	a5,-60(s0)
    80005e52:	078e                	slli	a5,a5,0x3
    80005e54:	0d078793          	addi	a5,a5,208
    80005e58:	97a6                	add	a5,a5,s1
    80005e5a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e5e:	fc042783          	lw	a5,-64(s0)
    80005e62:	078e                	slli	a5,a5,0x3
    80005e64:	0d078793          	addi	a5,a5,208
    80005e68:	97a6                	add	a5,a5,s1
    80005e6a:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e6e:	fd043503          	ld	a0,-48(s0)
    80005e72:	c43fe0ef          	jal	80004ab4 <fileclose>
    fileclose(wf);
    80005e76:	fc843503          	ld	a0,-56(s0)
    80005e7a:	c3bfe0ef          	jal	80004ab4 <fileclose>
    return -1;
    80005e7e:	57fd                	li	a5,-1
    80005e80:	a025                	j	80005ea8 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005e82:	fc442783          	lw	a5,-60(s0)
    80005e86:	0007c863          	bltz	a5,80005e96 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005e8a:	078e                	slli	a5,a5,0x3
    80005e8c:	0d078793          	addi	a5,a5,208
    80005e90:	97a6                	add	a5,a5,s1
    80005e92:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e96:	fd043503          	ld	a0,-48(s0)
    80005e9a:	c1bfe0ef          	jal	80004ab4 <fileclose>
    fileclose(wf);
    80005e9e:	fc843503          	ld	a0,-56(s0)
    80005ea2:	c13fe0ef          	jal	80004ab4 <fileclose>
    return -1;
    80005ea6:	57fd                	li	a5,-1
}
    80005ea8:	853e                	mv	a0,a5
    80005eaa:	70e2                	ld	ra,56(sp)
    80005eac:	7442                	ld	s0,48(sp)
    80005eae:	74a2                	ld	s1,40(sp)
    80005eb0:	6121                	addi	sp,sp,64
    80005eb2:	8082                	ret
	...

0000000080005ec0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005ec0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005ec2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005ec4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005ec6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005ec8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005eca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005ecc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005ece:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005ed0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005ed2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005ed4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005ed6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005ed8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005eda:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005edc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005ede:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ee0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ee2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ee4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ee6:	a2cfd0ef          	jal	80003112 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005eea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005eec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005eee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ef0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ef2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005ef4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ef6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ef8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005efa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005efc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005efe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005f00:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005f02:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005f04:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005f06:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005f08:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005f0a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005f0c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005f0e:	10200073          	sret
    80005f12:	00000013          	nop
    80005f16:	00000013          	nop
    80005f1a:	00000013          	nop

0000000080005f1e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f1e:	1141                	addi	sp,sp,-16
    80005f20:	e406                	sd	ra,8(sp)
    80005f22:	e022                	sd	s0,0(sp)
    80005f24:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f26:	0c000737          	lui	a4,0xc000
    80005f2a:	4785                	li	a5,1
    80005f2c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f2e:	c35c                	sw	a5,4(a4)
}
    80005f30:	60a2                	ld	ra,8(sp)
    80005f32:	6402                	ld	s0,0(sp)
    80005f34:	0141                	addi	sp,sp,16
    80005f36:	8082                	ret

0000000080005f38 <plicinithart>:

void
plicinithart(void)
{
    80005f38:	1141                	addi	sp,sp,-16
    80005f3a:	e406                	sd	ra,8(sp)
    80005f3c:	e022                	sd	s0,0(sp)
    80005f3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f40:	b43fb0ef          	jal	80001a82 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f44:	0085171b          	slliw	a4,a0,0x8
    80005f48:	0c0027b7          	lui	a5,0xc002
    80005f4c:	97ba                	add	a5,a5,a4
    80005f4e:	40200713          	li	a4,1026
    80005f52:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f56:	00d5151b          	slliw	a0,a0,0xd
    80005f5a:	0c2017b7          	lui	a5,0xc201
    80005f5e:	97aa                	add	a5,a5,a0
    80005f60:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f64:	60a2                	ld	ra,8(sp)
    80005f66:	6402                	ld	s0,0(sp)
    80005f68:	0141                	addi	sp,sp,16
    80005f6a:	8082                	ret

0000000080005f6c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f6c:	1141                	addi	sp,sp,-16
    80005f6e:	e406                	sd	ra,8(sp)
    80005f70:	e022                	sd	s0,0(sp)
    80005f72:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f74:	b0ffb0ef          	jal	80001a82 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f78:	00d5151b          	slliw	a0,a0,0xd
    80005f7c:	0c2017b7          	lui	a5,0xc201
    80005f80:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f82:	43c8                	lw	a0,4(a5)
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f8c:	1101                	addi	sp,sp,-32
    80005f8e:	ec06                	sd	ra,24(sp)
    80005f90:	e822                	sd	s0,16(sp)
    80005f92:	e426                	sd	s1,8(sp)
    80005f94:	1000                	addi	s0,sp,32
    80005f96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f98:	aebfb0ef          	jal	80001a82 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f9c:	00d5179b          	slliw	a5,a0,0xd
    80005fa0:	0c201737          	lui	a4,0xc201
    80005fa4:	97ba                	add	a5,a5,a4
    80005fa6:	c3c4                	sw	s1,4(a5)
}
    80005fa8:	60e2                	ld	ra,24(sp)
    80005faa:	6442                	ld	s0,16(sp)
    80005fac:	64a2                	ld	s1,8(sp)
    80005fae:	6105                	addi	sp,sp,32
    80005fb0:	8082                	ret

0000000080005fb2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fb2:	1141                	addi	sp,sp,-16
    80005fb4:	e406                	sd	ra,8(sp)
    80005fb6:	e022                	sd	s0,0(sp)
    80005fb8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fba:	479d                	li	a5,7
    80005fbc:	04a7ca63          	blt	a5,a0,80006010 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005fc0:	0001f797          	auipc	a5,0x1f
    80005fc4:	e2878793          	addi	a5,a5,-472 # 80024de8 <disk>
    80005fc8:	97aa                	add	a5,a5,a0
    80005fca:	0187c783          	lbu	a5,24(a5)
    80005fce:	e7b9                	bnez	a5,8000601c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fd0:	00451693          	slli	a3,a0,0x4
    80005fd4:	0001f797          	auipc	a5,0x1f
    80005fd8:	e1478793          	addi	a5,a5,-492 # 80024de8 <disk>
    80005fdc:	6398                	ld	a4,0(a5)
    80005fde:	9736                	add	a4,a4,a3
    80005fe0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005fe4:	6398                	ld	a4,0(a5)
    80005fe6:	9736                	add	a4,a4,a3
    80005fe8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ff0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ff4:	97aa                	add	a5,a5,a0
    80005ff6:	4705                	li	a4,1
    80005ff8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005ffc:	0001f517          	auipc	a0,0x1f
    80006000:	e0450513          	addi	a0,a0,-508 # 80024e00 <disk+0x18>
    80006004:	fc6fc0ef          	jal	800027ca <wakeup>
}
    80006008:	60a2                	ld	ra,8(sp)
    8000600a:	6402                	ld	s0,0(sp)
    8000600c:	0141                	addi	sp,sp,16
    8000600e:	8082                	ret
    panic("free_desc 1");
    80006010:	00003517          	auipc	a0,0x3
    80006014:	a8850513          	addi	a0,a0,-1400 # 80008a98 <etext+0xa98>
    80006018:	80dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000601c:	00003517          	auipc	a0,0x3
    80006020:	a8c50513          	addi	a0,a0,-1396 # 80008aa8 <etext+0xaa8>
    80006024:	801fa0ef          	jal	80000824 <panic>

0000000080006028 <virtio_disk_init>:
{
    80006028:	1101                	addi	sp,sp,-32
    8000602a:	ec06                	sd	ra,24(sp)
    8000602c:	e822                	sd	s0,16(sp)
    8000602e:	e426                	sd	s1,8(sp)
    80006030:	e04a                	sd	s2,0(sp)
    80006032:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006034:	00003597          	auipc	a1,0x3
    80006038:	a8458593          	addi	a1,a1,-1404 # 80008ab8 <etext+0xab8>
    8000603c:	0001f517          	auipc	a0,0x1f
    80006040:	ed450513          	addi	a0,a0,-300 # 80024f10 <disk+0x128>
    80006044:	b5bfa0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006048:	100017b7          	lui	a5,0x10001
    8000604c:	4398                	lw	a4,0(a5)
    8000604e:	2701                	sext.w	a4,a4
    80006050:	747277b7          	lui	a5,0x74727
    80006054:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006058:	14f71863          	bne	a4,a5,800061a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000605c:	100017b7          	lui	a5,0x10001
    80006060:	43dc                	lw	a5,4(a5)
    80006062:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006064:	4709                	li	a4,2
    80006066:	14e79163          	bne	a5,a4,800061a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	479c                	lw	a5,8(a5)
    80006070:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006072:	12e79b63          	bne	a5,a4,800061a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006076:	100017b7          	lui	a5,0x10001
    8000607a:	47d8                	lw	a4,12(a5)
    8000607c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000607e:	554d47b7          	lui	a5,0x554d4
    80006082:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006086:	12f71163          	bne	a4,a5,800061a8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000608a:	100017b7          	lui	a5,0x10001
    8000608e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006092:	4705                	li	a4,1
    80006094:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006096:	470d                	li	a4,3
    80006098:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000609a:	10001737          	lui	a4,0x10001
    8000609e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800060a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9837>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060a8:	8f75                	and	a4,a4,a3
    800060aa:	100016b7          	lui	a3,0x10001
    800060ae:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b0:	472d                	li	a4,11
    800060b2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800060b8:	439c                	lw	a5,0(a5)
    800060ba:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060be:	8ba1                	andi	a5,a5,8
    800060c0:	0e078a63          	beqz	a5,800061b4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060c4:	100017b7          	lui	a5,0x10001
    800060c8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060cc:	43fc                	lw	a5,68(a5)
    800060ce:	2781                	sext.w	a5,a5
    800060d0:	0e079863          	bnez	a5,800061c0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060d4:	100017b7          	lui	a5,0x10001
    800060d8:	5bdc                	lw	a5,52(a5)
    800060da:	2781                	sext.w	a5,a5
  if(max == 0)
    800060dc:	0e078863          	beqz	a5,800061cc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800060e0:	471d                	li	a4,7
    800060e2:	0ef77b63          	bgeu	a4,a5,800061d8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800060e6:	a5ffa0ef          	jal	80000b44 <kalloc>
    800060ea:	0001f497          	auipc	s1,0x1f
    800060ee:	cfe48493          	addi	s1,s1,-770 # 80024de8 <disk>
    800060f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060f4:	a51fa0ef          	jal	80000b44 <kalloc>
    800060f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060fa:	a4bfa0ef          	jal	80000b44 <kalloc>
    800060fe:	87aa                	mv	a5,a0
    80006100:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006102:	6088                	ld	a0,0(s1)
    80006104:	0e050063          	beqz	a0,800061e4 <virtio_disk_init+0x1bc>
    80006108:	0001f717          	auipc	a4,0x1f
    8000610c:	ce873703          	ld	a4,-792(a4) # 80024df0 <disk+0x8>
    80006110:	cb71                	beqz	a4,800061e4 <virtio_disk_init+0x1bc>
    80006112:	cbe9                	beqz	a5,800061e4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80006114:	6605                	lui	a2,0x1
    80006116:	4581                	li	a1,0
    80006118:	be1fa0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000611c:	0001f497          	auipc	s1,0x1f
    80006120:	ccc48493          	addi	s1,s1,-820 # 80024de8 <disk>
    80006124:	6605                	lui	a2,0x1
    80006126:	4581                	li	a1,0
    80006128:	6488                	ld	a0,8(s1)
    8000612a:	bcffa0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000612e:	6605                	lui	a2,0x1
    80006130:	4581                	li	a1,0
    80006132:	6888                	ld	a0,16(s1)
    80006134:	bc5fa0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006138:	100017b7          	lui	a5,0x10001
    8000613c:	4721                	li	a4,8
    8000613e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006140:	4098                	lw	a4,0(s1)
    80006142:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006146:	40d8                	lw	a4,4(s1)
    80006148:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000614c:	649c                	ld	a5,8(s1)
    8000614e:	0007869b          	sext.w	a3,a5
    80006152:	10001737          	lui	a4,0x10001
    80006156:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000615a:	9781                	srai	a5,a5,0x20
    8000615c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006160:	689c                	ld	a5,16(s1)
    80006162:	0007869b          	sext.w	a3,a5
    80006166:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000616a:	9781                	srai	a5,a5,0x20
    8000616c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006170:	4785                	li	a5,1
    80006172:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006174:	00f48c23          	sb	a5,24(s1)
    80006178:	00f48ca3          	sb	a5,25(s1)
    8000617c:	00f48d23          	sb	a5,26(s1)
    80006180:	00f48da3          	sb	a5,27(s1)
    80006184:	00f48e23          	sb	a5,28(s1)
    80006188:	00f48ea3          	sb	a5,29(s1)
    8000618c:	00f48f23          	sb	a5,30(s1)
    80006190:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006194:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006198:	07272823          	sw	s2,112(a4)
}
    8000619c:	60e2                	ld	ra,24(sp)
    8000619e:	6442                	ld	s0,16(sp)
    800061a0:	64a2                	ld	s1,8(sp)
    800061a2:	6902                	ld	s2,0(sp)
    800061a4:	6105                	addi	sp,sp,32
    800061a6:	8082                	ret
    panic("could not find virtio disk");
    800061a8:	00003517          	auipc	a0,0x3
    800061ac:	92050513          	addi	a0,a0,-1760 # 80008ac8 <etext+0xac8>
    800061b0:	e74fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061b4:	00003517          	auipc	a0,0x3
    800061b8:	93450513          	addi	a0,a0,-1740 # 80008ae8 <etext+0xae8>
    800061bc:	e68fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    800061c0:	00003517          	auipc	a0,0x3
    800061c4:	94850513          	addi	a0,a0,-1720 # 80008b08 <etext+0xb08>
    800061c8:	e5cfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    800061cc:	00003517          	auipc	a0,0x3
    800061d0:	95c50513          	addi	a0,a0,-1700 # 80008b28 <etext+0xb28>
    800061d4:	e50fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    800061d8:	00003517          	auipc	a0,0x3
    800061dc:	97050513          	addi	a0,a0,-1680 # 80008b48 <etext+0xb48>
    800061e0:	e44fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    800061e4:	00003517          	auipc	a0,0x3
    800061e8:	98450513          	addi	a0,a0,-1660 # 80008b68 <etext+0xb68>
    800061ec:	e38fa0ef          	jal	80000824 <panic>

00000000800061f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061f0:	711d                	addi	sp,sp,-96
    800061f2:	ec86                	sd	ra,88(sp)
    800061f4:	e8a2                	sd	s0,80(sp)
    800061f6:	e4a6                	sd	s1,72(sp)
    800061f8:	e0ca                	sd	s2,64(sp)
    800061fa:	fc4e                	sd	s3,56(sp)
    800061fc:	f852                	sd	s4,48(sp)
    800061fe:	f456                	sd	s5,40(sp)
    80006200:	f05a                	sd	s6,32(sp)
    80006202:	ec5e                	sd	s7,24(sp)
    80006204:	e862                	sd	s8,16(sp)
    80006206:	1080                	addi	s0,sp,96
    80006208:	89aa                	mv	s3,a0
    8000620a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000620c:	00c52b83          	lw	s7,12(a0)
    80006210:	001b9b9b          	slliw	s7,s7,0x1
    80006214:	1b82                	slli	s7,s7,0x20
    80006216:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000621a:	0001f517          	auipc	a0,0x1f
    8000621e:	cf650513          	addi	a0,a0,-778 # 80024f10 <disk+0x128>
    80006222:	a07fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80006226:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006228:	0001fa97          	auipc	s5,0x1f
    8000622c:	bc0a8a93          	addi	s5,s5,-1088 # 80024de8 <disk>
  for(int i = 0; i < 3; i++){
    80006230:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80006232:	5c7d                	li	s8,-1
    80006234:	a095                	j	80006298 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80006236:	00fa8733          	add	a4,s5,a5
    8000623a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000623e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006240:	0207c563          	bltz	a5,8000626a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80006244:	2905                	addiw	s2,s2,1
    80006246:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006248:	05490c63          	beq	s2,s4,800062a0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000624c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000624e:	0001f717          	auipc	a4,0x1f
    80006252:	b9a70713          	addi	a4,a4,-1126 # 80024de8 <disk>
    80006256:	4781                	li	a5,0
    if(disk.free[i]){
    80006258:	01874683          	lbu	a3,24(a4)
    8000625c:	fee9                	bnez	a3,80006236 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000625e:	2785                	addiw	a5,a5,1
    80006260:	0705                	addi	a4,a4,1
    80006262:	fe979be3          	bne	a5,s1,80006258 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80006266:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000626a:	01205d63          	blez	s2,80006284 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000626e:	fa042503          	lw	a0,-96(s0)
    80006272:	d41ff0ef          	jal	80005fb2 <free_desc>
      for(int j = 0; j < i; j++)
    80006276:	4785                	li	a5,1
    80006278:	0127d663          	bge	a5,s2,80006284 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000627c:	fa442503          	lw	a0,-92(s0)
    80006280:	d33ff0ef          	jal	80005fb2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006284:	0001f597          	auipc	a1,0x1f
    80006288:	c8c58593          	addi	a1,a1,-884 # 80024f10 <disk+0x128>
    8000628c:	0001f517          	auipc	a0,0x1f
    80006290:	b7450513          	addi	a0,a0,-1164 # 80024e00 <disk+0x18>
    80006294:	ceafc0ef          	jal	8000277e <sleep>
  for(int i = 0; i < 3; i++){
    80006298:	fa040613          	addi	a2,s0,-96
    8000629c:	4901                	li	s2,0
    8000629e:	b77d                	j	8000624c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062a0:	fa042503          	lw	a0,-96(s0)
    800062a4:	00451693          	slli	a3,a0,0x4

  if(write)
    800062a8:	0001f797          	auipc	a5,0x1f
    800062ac:	b4078793          	addi	a5,a5,-1216 # 80024de8 <disk>
    800062b0:	00451713          	slli	a4,a0,0x4
    800062b4:	0a070713          	addi	a4,a4,160
    800062b8:	973e                	add	a4,a4,a5
    800062ba:	01603633          	snez	a2,s6
    800062be:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062c0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062c4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062c8:	6398                	ld	a4,0(a5)
    800062ca:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062cc:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800062d0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062d2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062d4:	6390                	ld	a2,0(a5)
    800062d6:	00d60833          	add	a6,a2,a3
    800062da:	4741                	li	a4,16
    800062dc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062e0:	4585                	li	a1,1
    800062e2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800062e6:	fa442703          	lw	a4,-92(s0)
    800062ea:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062ee:	0712                	slli	a4,a4,0x4
    800062f0:	963a                	add	a2,a2,a4
    800062f2:	05898813          	addi	a6,s3,88
    800062f6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800062fa:	0007b883          	ld	a7,0(a5)
    800062fe:	9746                	add	a4,a4,a7
    80006300:	40000613          	li	a2,1024
    80006304:	c710                	sw	a2,8(a4)
  if(write)
    80006306:	001b3613          	seqz	a2,s6
    8000630a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000630e:	8e4d                	or	a2,a2,a1
    80006310:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006314:	fa842603          	lw	a2,-88(s0)
    80006318:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000631c:	00451813          	slli	a6,a0,0x4
    80006320:	02080813          	addi	a6,a6,32
    80006324:	983e                	add	a6,a6,a5
    80006326:	577d                	li	a4,-1
    80006328:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000632c:	0612                	slli	a2,a2,0x4
    8000632e:	98b2                	add	a7,a7,a2
    80006330:	03068713          	addi	a4,a3,48
    80006334:	973e                	add	a4,a4,a5
    80006336:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    8000633a:	6398                	ld	a4,0(a5)
    8000633c:	9732                	add	a4,a4,a2
    8000633e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006340:	4689                	li	a3,2
    80006342:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006346:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000634a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000634e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006352:	6794                	ld	a3,8(a5)
    80006354:	0026d703          	lhu	a4,2(a3)
    80006358:	8b1d                	andi	a4,a4,7
    8000635a:	0706                	slli	a4,a4,0x1
    8000635c:	96ba                	add	a3,a3,a4
    8000635e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006362:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006366:	6798                	ld	a4,8(a5)
    80006368:	00275783          	lhu	a5,2(a4)
    8000636c:	2785                	addiw	a5,a5,1
    8000636e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006372:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006376:	100017b7          	lui	a5,0x10001
    8000637a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000637e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006382:	0001f917          	auipc	s2,0x1f
    80006386:	b8e90913          	addi	s2,s2,-1138 # 80024f10 <disk+0x128>
  while(b->disk == 1) {
    8000638a:	84ae                	mv	s1,a1
    8000638c:	00b79a63          	bne	a5,a1,800063a0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006390:	85ca                	mv	a1,s2
    80006392:	854e                	mv	a0,s3
    80006394:	beafc0ef          	jal	8000277e <sleep>
  while(b->disk == 1) {
    80006398:	0049a783          	lw	a5,4(s3)
    8000639c:	fe978ae3          	beq	a5,s1,80006390 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800063a0:	fa042903          	lw	s2,-96(s0)
    800063a4:	00491713          	slli	a4,s2,0x4
    800063a8:	02070713          	addi	a4,a4,32
    800063ac:	0001f797          	auipc	a5,0x1f
    800063b0:	a3c78793          	addi	a5,a5,-1476 # 80024de8 <disk>
    800063b4:	97ba                	add	a5,a5,a4
    800063b6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063ba:	0001f997          	auipc	s3,0x1f
    800063be:	a2e98993          	addi	s3,s3,-1490 # 80024de8 <disk>
    800063c2:	00491713          	slli	a4,s2,0x4
    800063c6:	0009b783          	ld	a5,0(s3)
    800063ca:	97ba                	add	a5,a5,a4
    800063cc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063d0:	854a                	mv	a0,s2
    800063d2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063d6:	bddff0ef          	jal	80005fb2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063da:	8885                	andi	s1,s1,1
    800063dc:	f0fd                	bnez	s1,800063c2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063de:	0001f517          	auipc	a0,0x1f
    800063e2:	b3250513          	addi	a0,a0,-1230 # 80024f10 <disk+0x128>
    800063e6:	8d7fa0ef          	jal	80000cbc <release>
}
    800063ea:	60e6                	ld	ra,88(sp)
    800063ec:	6446                	ld	s0,80(sp)
    800063ee:	64a6                	ld	s1,72(sp)
    800063f0:	6906                	ld	s2,64(sp)
    800063f2:	79e2                	ld	s3,56(sp)
    800063f4:	7a42                	ld	s4,48(sp)
    800063f6:	7aa2                	ld	s5,40(sp)
    800063f8:	7b02                	ld	s6,32(sp)
    800063fa:	6be2                	ld	s7,24(sp)
    800063fc:	6c42                	ld	s8,16(sp)
    800063fe:	6125                	addi	sp,sp,96
    80006400:	8082                	ret

0000000080006402 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006402:	1101                	addi	sp,sp,-32
    80006404:	ec06                	sd	ra,24(sp)
    80006406:	e822                	sd	s0,16(sp)
    80006408:	e426                	sd	s1,8(sp)
    8000640a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000640c:	0001f497          	auipc	s1,0x1f
    80006410:	9dc48493          	addi	s1,s1,-1572 # 80024de8 <disk>
    80006414:	0001f517          	auipc	a0,0x1f
    80006418:	afc50513          	addi	a0,a0,-1284 # 80024f10 <disk+0x128>
    8000641c:	80dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006420:	100017b7          	lui	a5,0x10001
    80006424:	53bc                	lw	a5,96(a5)
    80006426:	8b8d                	andi	a5,a5,3
    80006428:	10001737          	lui	a4,0x10001
    8000642c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000642e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006432:	689c                	ld	a5,16(s1)
    80006434:	0204d703          	lhu	a4,32(s1)
    80006438:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000643c:	04f70863          	beq	a4,a5,8000648c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006440:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006444:	6898                	ld	a4,16(s1)
    80006446:	0204d783          	lhu	a5,32(s1)
    8000644a:	8b9d                	andi	a5,a5,7
    8000644c:	078e                	slli	a5,a5,0x3
    8000644e:	97ba                	add	a5,a5,a4
    80006450:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006452:	00479713          	slli	a4,a5,0x4
    80006456:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    8000645a:	9726                	add	a4,a4,s1
    8000645c:	01074703          	lbu	a4,16(a4)
    80006460:	e329                	bnez	a4,800064a2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006462:	0792                	slli	a5,a5,0x4
    80006464:	02078793          	addi	a5,a5,32
    80006468:	97a6                	add	a5,a5,s1
    8000646a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000646c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006470:	b5afc0ef          	jal	800027ca <wakeup>

    disk.used_idx += 1;
    80006474:	0204d783          	lhu	a5,32(s1)
    80006478:	2785                	addiw	a5,a5,1
    8000647a:	17c2                	slli	a5,a5,0x30
    8000647c:	93c1                	srli	a5,a5,0x30
    8000647e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006482:	6898                	ld	a4,16(s1)
    80006484:	00275703          	lhu	a4,2(a4)
    80006488:	faf71ce3          	bne	a4,a5,80006440 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000648c:	0001f517          	auipc	a0,0x1f
    80006490:	a8450513          	addi	a0,a0,-1404 # 80024f10 <disk+0x128>
    80006494:	829fa0ef          	jal	80000cbc <release>
}
    80006498:	60e2                	ld	ra,24(sp)
    8000649a:	6442                	ld	s0,16(sp)
    8000649c:	64a2                	ld	s1,8(sp)
    8000649e:	6105                	addi	sp,sp,32
    800064a0:	8082                	ret
      panic("virtio_disk_intr status");
    800064a2:	00002517          	auipc	a0,0x2
    800064a6:	6de50513          	addi	a0,a0,1758 # 80008b80 <etext+0xb80>
    800064aa:	b7afa0ef          	jal	80000824 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
