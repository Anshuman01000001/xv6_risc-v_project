
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	53813103          	ld	sp,1336(sp) # 8000a538 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdad67>
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
    8000011a:	4ea020ef          	jal	80002604 <either_copyin>
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
    80000192:	00012517          	auipc	a0,0x12
    80000196:	3fe50513          	addi	a0,a0,1022 # 80012590 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00012497          	auipc	s1,0x12
    800001a2:	3f248493          	addi	s1,s1,1010 # 80012590 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00012917          	auipc	s2,0x12
    800001aa:	48290913          	addi	s2,s2,1154 # 80012628 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	7ee010ef          	jal	800019ac <myproc>
    800001c2:	2da020ef          	jal	8000249c <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	094020ef          	jal	80002260 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00012717          	auipc	a4,0x12
    800001e2:	3b270713          	addi	a4,a4,946 # 80012590 <cons>
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
    80000210:	3aa020ef          	jal	800025ba <either_copyout>
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
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	36850513          	addi	a0,a0,872 # 80012590 <cons>
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
    8000024e:	00012717          	auipc	a4,0x12
    80000252:	3cf72d23          	sw	a5,986(a4) # 80012628 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00012517          	auipc	a0,0x12
    80000268:	32c50513          	addi	a0,a0,812 # 80012590 <cons>
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
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	2d850513          	addi	a0,a0,728 # 80012590 <cons>
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
    800002da:	374020ef          	jal	8000264e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00012517          	auipc	a0,0x12
    800002e2:	2b250513          	addi	a0,a0,690 # 80012590 <cons>
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
    800002fc:	00012717          	auipc	a4,0x12
    80000300:	29470713          	addi	a4,a4,660 # 80012590 <cons>
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
    80000322:	00012717          	auipc	a4,0x12
    80000326:	26e70713          	addi	a4,a4,622 # 80012590 <cons>
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
    8000034c:	00012717          	auipc	a4,0x12
    80000350:	2dc72703          	lw	a4,732(a4) # 80012628 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00012717          	auipc	a4,0x12
    80000366:	22e70713          	addi	a4,a4,558 # 80012590 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00012497          	auipc	s1,0x12
    80000376:	21e48493          	addi	s1,s1,542 # 80012590 <cons>
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
    800003b4:	00012717          	auipc	a4,0x12
    800003b8:	1dc70713          	addi	a4,a4,476 # 80012590 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00012717          	auipc	a4,0x12
    800003ce:	26f72323          	sw	a5,614(a4) # 80012630 <cons+0xa0>
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
    800003e8:	00012797          	auipc	a5,0x12
    800003ec:	1a878793          	addi	a5,a5,424 # 80012590 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	22c7a123          	sw	a2,546(a5) # 8001262c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00012517          	auipc	a0,0x12
    80000416:	21650513          	addi	a0,a0,534 # 80012628 <cons+0x98>
    8000041a:	693010ef          	jal	800022ac <wakeup>
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
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	00012517          	auipc	a0,0x12
    80000434:	16050513          	addi	a0,a0,352 # 80012590 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	4c078793          	addi	a5,a5,1216 # 80022900 <devsw>
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
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	4aa80813          	addi	a6,a6,1194 # 80007928 <digits>
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
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	03c7a783          	lw	a5,60(a5) # 8000a554 <panicking>
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
    8000055e:	00012517          	auipc	a0,0x12
    80000562:	0da50513          	addi	a0,a0,218 # 80012638 <pr>
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
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	256c8c93          	addi	s9,s9,598 # 80007928 <digits>
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
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
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
    8000075a:	0000a797          	auipc	a5,0xa
    8000075e:	dfa7a783          	lw	a5,-518(a5) # 8000a554 <panicking>
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
    80000784:	00012517          	auipc	a0,0x12
    80000788:	eb450513          	addi	a0,a0,-332 # 80012638 <pr>
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
    80000834:	0000a797          	auipc	a5,0xa
    80000838:	d297a023          	sw	s1,-736(a5) # 8000a554 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000a797          	auipc	a5,0xa
    8000085a:	ce97ad23          	sw	s1,-774(a5) # 8000a550 <panicked>
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
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	00012517          	auipc	a0,0x12
    80000874:	dc850513          	addi	a0,a0,-568 # 80012638 <pr>
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
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	00012517          	auipc	a0,0x12
    800008ca:	d8a50513          	addi	a0,a0,-630 # 80012650 <tx_lock>
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
    800008ea:	00012517          	auipc	a0,0x12
    800008ee:	d6650513          	addi	a0,a0,-666 # 80012650 <tx_lock>
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
    80000908:	0000a497          	auipc	s1,0xa
    8000090c:	c5448493          	addi	s1,s1,-940 # 8000a55c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00012997          	auipc	s3,0x12
    80000914:	d4098993          	addi	s3,s3,-704 # 80012650 <tx_lock>
    80000918:	0000a917          	auipc	s2,0xa
    8000091c:	c4090913          	addi	s2,s2,-960 # 8000a558 <tx_chan>
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
    8000092c:	135010ef          	jal	80002260 <sleep>
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
    80000956:	00012517          	auipc	a0,0x12
    8000095a:	cfa50513          	addi	a0,a0,-774 # 80012650 <tx_lock>
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
    8000097a:	0000a797          	auipc	a5,0xa
    8000097e:	bda7a783          	lw	a5,-1062(a5) # 8000a554 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000a797          	auipc	a5,0xa
    80000988:	bcc7a783          	lw	a5,-1076(a5) # 8000a550 <panicked>
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
    800009aa:	0000a797          	auipc	a5,0xa
    800009ae:	baa7a783          	lw	a5,-1110(a5) # 8000a554 <panicking>
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
    80000a06:	00012517          	auipc	a0,0x12
    80000a0a:	c4a50513          	addi	a0,a0,-950 # 80012650 <tx_lock>
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
    80000a20:	00012517          	auipc	a0,0x12
    80000a24:	c3050513          	addi	a0,a0,-976 # 80012650 <tx_lock>
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
    80000a3c:	0000a797          	auipc	a5,0xa
    80000a40:	b207a023          	sw	zero,-1248(a5) # 8000a55c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000a517          	auipc	a0,0xa
    80000a48:	b1450513          	addi	a0,a0,-1260 # 8000a558 <tx_chan>
    80000a4c:	061010ef          	jal	800022ac <wakeup>
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
    80000a68:	00023797          	auipc	a5,0x23
    80000a6c:	03078793          	addi	a5,a5,48 # 80023a98 <end>
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
    80000a92:	00012917          	auipc	s2,0x12
    80000a96:	bd690913          	addi	s2,s2,-1066 # 80012668 <kmem>
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
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
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
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	00012517          	auipc	a0,0x12
    80000b24:	b4850513          	addi	a0,a0,-1208 # 80012668 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00023517          	auipc	a0,0x23
    80000b34:	f6850513          	addi	a0,a0,-152 # 80023a98 <end>
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
    80000b4e:	00012517          	auipc	a0,0x12
    80000b52:	b1a50513          	addi	a0,a0,-1254 # 80012668 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00012497          	auipc	s1,0x12
    80000b5e:	b264b483          	ld	s1,-1242(s1) # 80012680 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00012717          	auipc	a4,0x12
    80000b6a:	b0f73d23          	sd	a5,-1254(a4) # 80012680 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00012517          	auipc	a0,0x12
    80000b72:	afa50513          	addi	a0,a0,-1286 # 80012668 <kmem>
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
    80000b90:	00012517          	auipc	a0,0x12
    80000b94:	ad850513          	addi	a0,a0,-1320 # 80012668 <kmem>
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
    80000bce:	5bf000ef          	jal	8000198c <mycpu>
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
    80000bfe:	58f000ef          	jal	8000198c <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	587000ef          	jal	8000198c <mycpu>
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
    80000c1a:	573000ef          	jal	8000198c <mycpu>
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
    80000c50:	53d000ef          	jal	8000198c <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
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
    80000c74:	519000ef          	jal	8000198c <mycpu>
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
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
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
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
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
    80000eb6:	2c3000ef          	jal	80001978 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00009717          	auipc	a4,0x9
    80000ebe:	6a670713          	addi	a4,a4,1702 # 8000a560 <started>
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
    80000ece:	2ab000ef          	jal	80001978 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	281010ef          	jal	80002964 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	331040ef          	jal	80005a18 <plicinithart>
  }

  scheduler();        
    80000eec:	743000ef          	jal	80001e2e <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	19b000ef          	jal	800018c2 <procinit>
    trapinit();      // trap vectors
    80000f2c:	215010ef          	jal	80002940 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	235010ef          	jal	80002964 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	2cb040ef          	jal	800059fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	2e1040ef          	jal	80005a18 <plicinithart>
    binit();         // buffer cache
    80000f3c:	10c020ef          	jal	80003048 <binit>
    iinit();         // inode table
    80000f40:	65e020ef          	jal	8000359e <iinit>
    fileinit();      // file table
    80000f44:	58a030ef          	jal	800044ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	3c1040ef          	jal	80005b08 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	537000ef          	jal	80001c82 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00009717          	auipc	a4,0x9
    80000f5a:	60f72523          	sw	a5,1546(a4) # 8000a560 <started>
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
    80000f6c:	00009797          	auipc	a5,0x9
    80000f70:	5fc7b783          	ld	a5,1532(a5) # 8000a568 <kernel_pagetable>
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
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
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
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
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
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
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
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	642000ef          	jal	8000181e <proc_mapstacks>
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
    800011f8:	00009797          	auipc	a5,0x9
    800011fc:	36a7b823          	sd	a0,880(a5) # 8000a568 <kernel_pagetable>
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
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
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
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
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
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
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
    800015e0:	3cc000ef          	jal	800019ac <myproc>
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

00000000800017a0 <update_cpu_temp>:
extern char trampoline[]; // trampoline.S

// Update CPU temperature dynamically.
// process_heat > 0  →  a process with that heat level is running (heating)
// process_heat == 0 →  CPU is idle (cooling)
void update_cpu_temp(int process_heat) {
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  if (process_heat > 0) {
    800017a8:	04a05263          	blez	a0,800017ec <update_cpu_temp+0x4c>
    // Heating proportional to process heat: hotter processes raise temp faster
    int heat_factor = 1 + process_heat / 30;  // 1‒4
    800017ac:	888897b7          	lui	a5,0x88889
    800017b0:	88978793          	addi	a5,a5,-1911 # ffffffff88888889 <end+0xffffffff08864df1>
    800017b4:	02f507b3          	mul	a5,a0,a5
    800017b8:	9381                	srli	a5,a5,0x20
    800017ba:	9fa9                	addw	a5,a5,a0
    800017bc:	4047d79b          	sraiw	a5,a5,0x4
    800017c0:	41f5551b          	sraiw	a0,a0,0x1f
    800017c4:	9f89                	subw	a5,a5,a0
    800017c6:	2785                	addiw	a5,a5,1
    cpu_temp += heat_factor;
    800017c8:	00009717          	auipc	a4,0x9
    800017cc:	d5c72703          	lw	a4,-676(a4) # 8000a524 <cpu_temp>
    800017d0:	9fb9                	addw	a5,a5,a4
    // Cooling when idle
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
  }

  // Clamp to [20, 100]
  if(cpu_temp > 100)
    800017d2:	06400713          	li	a4,100
    800017d6:	02f75663          	bge	a4,a5,80001802 <update_cpu_temp+0x62>
    cpu_temp = 100;
    800017da:	87ba                	mv	a5,a4
    800017dc:	00009717          	auipc	a4,0x9
    800017e0:	d4f72423          	sw	a5,-696(a4) # 8000a524 <cpu_temp>
  else if(cpu_temp < 20)
    cpu_temp = 20;
}
    800017e4:	60a2                	ld	ra,8(sp)
    800017e6:	6402                	ld	s0,0(sp)
    800017e8:	0141                	addi	sp,sp,16
    800017ea:	8082                	ret
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
    800017ec:	00009797          	auipc	a5,0x9
    800017f0:	d387a783          	lw	a5,-712(a5) # 8000a524 <cpu_temp>
    800017f4:	03200713          	li	a4,50
    800017f8:	00f72733          	slt	a4,a4,a5
    800017fc:	0705                	addi	a4,a4,1
    800017fe:	9f99                	subw	a5,a5,a4
    80001800:	bfc9                	j	800017d2 <update_cpu_temp+0x32>
  else if(cpu_temp < 20)
    80001802:	474d                	li	a4,19
    80001804:	00f75763          	bge	a4,a5,80001812 <update_cpu_temp+0x72>
    cpu_temp += heat_factor;
    80001808:	00009717          	auipc	a4,0x9
    8000180c:	d0f72e23          	sw	a5,-740(a4) # 8000a524 <cpu_temp>
    80001810:	bfd1                	j	800017e4 <update_cpu_temp+0x44>
    cpu_temp = 20;
    80001812:	47d1                	li	a5,20
    80001814:	00009717          	auipc	a4,0x9
    80001818:	d0f72823          	sw	a5,-752(a4) # 8000a524 <cpu_temp>
}
    8000181c:	b7e1                	j	800017e4 <update_cpu_temp+0x44>

000000008000181e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000181e:	715d                	addi	sp,sp,-80
    80001820:	e486                	sd	ra,72(sp)
    80001822:	e0a2                	sd	s0,64(sp)
    80001824:	fc26                	sd	s1,56(sp)
    80001826:	f84a                	sd	s2,48(sp)
    80001828:	f44e                	sd	s3,40(sp)
    8000182a:	f052                	sd	s4,32(sp)
    8000182c:	ec56                	sd	s5,24(sp)
    8000182e:	e85a                	sd	s6,16(sp)
    80001830:	e45e                	sd	s7,8(sp)
    80001832:	e062                	sd	s8,0(sp)
    80001834:	0880                	addi	s0,sp,80
    80001836:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001838:	00011497          	auipc	s1,0x11
    8000183c:	28048493          	addi	s1,s1,640 # 80012ab8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001840:	8c26                	mv	s8,s1
    80001842:	ff4df937          	lui	s2,0xff4df
    80001846:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baf25>
    8000184a:	0936                	slli	s2,s2,0xd
    8000184c:	6f590913          	addi	s2,s2,1781
    80001850:	0936                	slli	s2,s2,0xd
    80001852:	bd390913          	addi	s2,s2,-1069
    80001856:	0932                	slli	s2,s2,0xc
    80001858:	7a790913          	addi	s2,s2,1959
    8000185c:	040009b7          	lui	s3,0x4000
    80001860:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001862:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4b99                	li	s7,6
    80001866:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001868:	00017a97          	auipc	s5,0x17
    8000186c:	e50a8a93          	addi	s5,s5,-432 # 800186b8 <tickslock>
    char *pa = kalloc();
    80001870:	ad4ff0ef          	jal	80000b44 <kalloc>
    80001874:	862a                	mv	a2,a0
    if(pa == 0)
    80001876:	c121                	beqz	a0,800018b6 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    80001878:	418485b3          	sub	a1,s1,s8
    8000187c:	8591                	srai	a1,a1,0x4
    8000187e:	032585b3          	mul	a1,a1,s2
    80001882:	05b6                	slli	a1,a1,0xd
    80001884:	6789                	lui	a5,0x2
    80001886:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	875e                	mv	a4,s7
    8000188a:	86da                	mv	a3,s6
    8000188c:	40b985b3          	sub	a1,s3,a1
    80001890:	8552                	mv	a0,s4
    80001892:	885ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001896:	17048493          	addi	s1,s1,368
    8000189a:	fd549be3          	bne	s1,s5,80001870 <proc_mapstacks+0x52>
  }
}
    8000189e:	60a6                	ld	ra,72(sp)
    800018a0:	6406                	ld	s0,64(sp)
    800018a2:	74e2                	ld	s1,56(sp)
    800018a4:	7942                	ld	s2,48(sp)
    800018a6:	79a2                	ld	s3,40(sp)
    800018a8:	7a02                	ld	s4,32(sp)
    800018aa:	6ae2                	ld	s5,24(sp)
    800018ac:	6b42                	ld	s6,16(sp)
    800018ae:	6ba2                	ld	s7,8(sp)
    800018b0:	6c02                	ld	s8,0(sp)
    800018b2:	6161                	addi	sp,sp,80
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00006517          	auipc	a0,0x6
    800018ba:	8a250513          	addi	a0,a0,-1886 # 80007158 <etext+0x158>
    800018be:	f67fe0ef          	jal	80000824 <panic>

00000000800018c2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c2:	7139                	addi	sp,sp,-64
    800018c4:	fc06                	sd	ra,56(sp)
    800018c6:	f822                	sd	s0,48(sp)
    800018c8:	f426                	sd	s1,40(sp)
    800018ca:	f04a                	sd	s2,32(sp)
    800018cc:	ec4e                	sd	s3,24(sp)
    800018ce:	e852                	sd	s4,16(sp)
    800018d0:	e456                	sd	s5,8(sp)
    800018d2:	e05a                	sd	s6,0(sp)
    800018d4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018d6:	00006597          	auipc	a1,0x6
    800018da:	88a58593          	addi	a1,a1,-1910 # 80007160 <etext+0x160>
    800018de:	00011517          	auipc	a0,0x11
    800018e2:	daa50513          	addi	a0,a0,-598 # 80012688 <pid_lock>
    800018e6:	ab8ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ea:	00006597          	auipc	a1,0x6
    800018ee:	87e58593          	addi	a1,a1,-1922 # 80007168 <etext+0x168>
    800018f2:	00011517          	auipc	a0,0x11
    800018f6:	dae50513          	addi	a0,a0,-594 # 800126a0 <wait_lock>
    800018fa:	aa4ff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00011497          	auipc	s1,0x11
    80001902:	1ba48493          	addi	s1,s1,442 # 80012ab8 <proc>
      initlock(&p->lock, "proc");
    80001906:	00006b17          	auipc	s6,0x6
    8000190a:	872b0b13          	addi	s6,s6,-1934 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	ff4df937          	lui	s2,0xff4df
    80001914:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baf25>
    80001918:	0936                	slli	s2,s2,0xd
    8000191a:	6f590913          	addi	s2,s2,1781
    8000191e:	0936                	slli	s2,s2,0xd
    80001920:	bd390913          	addi	s2,s2,-1069
    80001924:	0932                	slli	s2,s2,0xc
    80001926:	7a790913          	addi	s2,s2,1959
    8000192a:	040009b7          	lui	s3,0x4000
    8000192e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00017a17          	auipc	s4,0x17
    80001936:	d86a0a13          	addi	s4,s4,-634 # 800186b8 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	a60ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    80001942:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001946:	415487b3          	sub	a5,s1,s5
    8000194a:	8791                	srai	a5,a5,0x4
    8000194c:	032787b3          	mul	a5,a5,s2
    80001950:	07b6                	slli	a5,a5,0xd
    80001952:	6709                	lui	a4,0x2
    80001954:	9fb9                	addw	a5,a5,a4
    80001956:	40f987b3          	sub	a5,s3,a5
    8000195a:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195c:	17048493          	addi	s1,s1,368
    80001960:	fd449de3          	bne	s1,s4,8000193a <procinit+0x78>
  }
}
    80001964:	70e2                	ld	ra,56(sp)
    80001966:	7442                	ld	s0,48(sp)
    80001968:	74a2                	ld	s1,40(sp)
    8000196a:	7902                	ld	s2,32(sp)
    8000196c:	69e2                	ld	s3,24(sp)
    8000196e:	6a42                	ld	s4,16(sp)
    80001970:	6aa2                	ld	s5,8(sp)
    80001972:	6b02                	ld	s6,0(sp)
    80001974:	6121                	addi	sp,sp,64
    80001976:	8082                	ret

0000000080001978 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001978:	1141                	addi	sp,sp,-16
    8000197a:	e406                	sd	ra,8(sp)
    8000197c:	e022                	sd	s0,0(sp)
    8000197e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	60a2                	ld	ra,8(sp)
    80001986:	6402                	ld	s0,0(sp)
    80001988:	0141                	addi	sp,sp,16
    8000198a:	8082                	ret

000000008000198c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198c:	1141                	addi	sp,sp,-16
    8000198e:	e406                	sd	ra,8(sp)
    80001990:	e022                	sd	s0,0(sp)
    80001992:	0800                	addi	s0,sp,16
    80001994:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001996:	2781                	sext.w	a5,a5
    80001998:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199a:	00011517          	auipc	a0,0x11
    8000199e:	d1e50513          	addi	a0,a0,-738 # 800126b8 <cpus>
    800019a2:	953e                	add	a0,a0,a5
    800019a4:	60a2                	ld	ra,8(sp)
    800019a6:	6402                	ld	s0,0(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	a2eff0ef          	jal	80000be4 <push_off>
    800019ba:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019bc:	2781                	sext.w	a5,a5
    800019be:	079e                	slli	a5,a5,0x7
    800019c0:	00011717          	auipc	a4,0x11
    800019c4:	cc870713          	addi	a4,a4,-824 # 80012688 <pid_lock>
    800019c8:	97ba                	add	a5,a5,a4
    800019ca:	7b9c                	ld	a5,48(a5)
    800019cc:	84be                	mv	s1,a5
  pop_off();
    800019ce:	a9eff0ef          	jal	80000c6c <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	7179                	addi	sp,sp,-48
    800019e0:	f406                	sd	ra,40(sp)
    800019e2:	f022                	sd	s0,32(sp)
    800019e4:	ec26                	sd	s1,24(sp)
    800019e6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019e8:	fc5ff0ef          	jal	800019ac <myproc>
    800019ec:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019ee:	aceff0ef          	jal	80000cbc <release>

  if (first) {
    800019f2:	00009797          	auipc	a5,0x9
    800019f6:	b2e7a783          	lw	a5,-1234(a5) # 8000a520 <first.2>
    800019fa:	cf95                	beqz	a5,80001a36 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019fc:	4505                	li	a0,1
    800019fe:	05c020ef          	jal	80003a5a <fsinit>

    first = 0;
    80001a02:	00009797          	auipc	a5,0x9
    80001a06:	b007af23          	sw	zero,-1250(a5) # 8000a520 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001a0a:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001a0e:	00005797          	auipc	a5,0x5
    80001a12:	77278793          	addi	a5,a5,1906 # 80007180 <etext+0x180>
    80001a16:	fcf43823          	sd	a5,-48(s0)
    80001a1a:	fc043c23          	sd	zero,-40(s0)
    80001a1e:	fd040593          	addi	a1,s0,-48
    80001a22:	853e                	mv	a0,a5
    80001a24:	200030ef          	jal	80004c24 <kexec>
    80001a28:	70bc                	ld	a5,96(s1)
    80001a2a:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a2c:	70bc                	ld	a5,96(s1)
    80001a2e:	7bb8                	ld	a4,112(a5)
    80001a30:	57fd                	li	a5,-1
    80001a32:	02f70d63          	beq	a4,a5,80001a6c <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a36:	74b000ef          	jal	80002980 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a3a:	6ca8                	ld	a0,88(s1)
    80001a3c:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a3e:	04000737          	lui	a4,0x4000
    80001a42:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	0732                	slli	a4,a4,0xc
    80001a46:	00004797          	auipc	a5,0x4
    80001a4a:	65678793          	addi	a5,a5,1622 # 8000609c <userret>
    80001a4e:	00004697          	auipc	a3,0x4
    80001a52:	5b268693          	addi	a3,a3,1458 # 80006000 <_trampoline>
    80001a56:	8f95                	sub	a5,a5,a3
    80001a58:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a5a:	577d                	li	a4,-1
    80001a5c:	177e                	slli	a4,a4,0x3f
    80001a5e:	8d59                	or	a0,a0,a4
    80001a60:	9782                	jalr	a5
}
    80001a62:	70a2                	ld	ra,40(sp)
    80001a64:	7402                	ld	s0,32(sp)
    80001a66:	64e2                	ld	s1,24(sp)
    80001a68:	6145                	addi	sp,sp,48
    80001a6a:	8082                	ret
      panic("exec");
    80001a6c:	00005517          	auipc	a0,0x5
    80001a70:	71c50513          	addi	a0,a0,1820 # 80007188 <etext+0x188>
    80001a74:	db1fe0ef          	jal	80000824 <panic>

0000000080001a78 <allocpid>:
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a82:	00011517          	auipc	a0,0x11
    80001a86:	c0650513          	addi	a0,a0,-1018 # 80012688 <pid_lock>
    80001a8a:	99eff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a8e:	00009797          	auipc	a5,0x9
    80001a92:	a9a78793          	addi	a5,a5,-1382 # 8000a528 <nextpid>
    80001a96:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a98:	0014871b          	addiw	a4,s1,1
    80001a9c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9e:	00011517          	auipc	a0,0x11
    80001aa2:	bea50513          	addi	a0,a0,-1046 # 80012688 <pid_lock>
    80001aa6:	a16ff0ef          	jal	80000cbc <release>
}
    80001aaa:	8526                	mv	a0,s1
    80001aac:	60e2                	ld	ra,24(sp)
    80001aae:	6442                	ld	s0,16(sp)
    80001ab0:	64a2                	ld	s1,8(sp)
    80001ab2:	6105                	addi	sp,sp,32
    80001ab4:	8082                	ret

0000000080001ab6 <proc_pagetable>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac4:	f44ff0ef          	jal	80001208 <uvmcreate>
    80001ac8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aca:	cd05                	beqz	a0,80001b02 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001acc:	4729                	li	a4,10
    80001ace:	00004697          	auipc	a3,0x4
    80001ad2:	53268693          	addi	a3,a3,1330 # 80006000 <_trampoline>
    80001ad6:	6605                	lui	a2,0x1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	d80ff0ef          	jal	80001060 <mappages>
    80001ae4:	02054663          	bltz	a0,80001b10 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae8:	4719                	li	a4,6
    80001aea:	06093683          	ld	a3,96(s2)
    80001aee:	6605                	lui	a2,0x1
    80001af0:	020005b7          	lui	a1,0x2000
    80001af4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001af6:	05b6                	slli	a1,a1,0xd
    80001af8:	8526                	mv	a0,s1
    80001afa:	d66ff0ef          	jal	80001060 <mappages>
    80001afe:	00054f63          	bltz	a0,80001b1c <proc_pagetable+0x66>
}
    80001b02:	8526                	mv	a0,s1
    80001b04:	60e2                	ld	ra,24(sp)
    80001b06:	6442                	ld	s0,16(sp)
    80001b08:	64a2                	ld	s1,8(sp)
    80001b0a:	6902                	ld	s2,0(sp)
    80001b0c:	6105                	addi	sp,sp,32
    80001b0e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b10:	4581                	li	a1,0
    80001b12:	8526                	mv	a0,s1
    80001b14:	8efff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	b7e5                	j	80001b02 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f04ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2e:	4581                	li	a1,0
    80001b30:	8526                	mv	a0,s1
    80001b32:	8d1ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b36:	4481                	li	s1,0
    80001b38:	b7e9                	j	80001b02 <proc_pagetable+0x4c>

0000000080001b3a <proc_freepagetable>:
{
    80001b3a:	1101                	addi	sp,sp,-32
    80001b3c:	ec06                	sd	ra,24(sp)
    80001b3e:	e822                	sd	s0,16(sp)
    80001b40:	e426                	sd	s1,8(sp)
    80001b42:	e04a                	sd	s2,0(sp)
    80001b44:	1000                	addi	s0,sp,32
    80001b46:	84aa                	mv	s1,a0
    80001b48:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	040005b7          	lui	a1,0x4000
    80001b52:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b54:	05b2                	slli	a1,a1,0xc
    80001b56:	ed8ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b5a:	4681                	li	a3,0
    80001b5c:	4605                	li	a2,1
    80001b5e:	020005b7          	lui	a1,0x2000
    80001b62:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b64:	05b6                	slli	a1,a1,0xd
    80001b66:	8526                	mv	a0,s1
    80001b68:	ec6ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b6c:	85ca                	mv	a1,s2
    80001b6e:	8526                	mv	a0,s1
    80001b70:	893ff0ef          	jal	80001402 <uvmfree>
}
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <freeproc>:
{
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	1000                	addi	s0,sp,32
    80001b8a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b8c:	7128                	ld	a0,96(a0)
    80001b8e:	c119                	beqz	a0,80001b94 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b90:	ecdfe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b94:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001b98:	6ca8                	ld	a0,88(s1)
    80001b9a:	c501                	beqz	a0,80001ba2 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9c:	68ac                	ld	a1,80(s1)
    80001b9e:	f9dff0ef          	jal	80001b3a <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001ba6:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bb2:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->heat = 0;
    80001bc2:	0204ac23          	sw	zero,56(s1)
  p->state = UNUSED;
    80001bc6:	0004ac23          	sw	zero,24(s1)
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <allocproc>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	e04a                	sd	s2,0(sp)
    80001bde:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be0:	00011497          	auipc	s1,0x11
    80001be4:	ed848493          	addi	s1,s1,-296 # 80012ab8 <proc>
    80001be8:	00017917          	auipc	s2,0x17
    80001bec:	ad090913          	addi	s2,s2,-1328 # 800186b8 <tickslock>
    acquire(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	836ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cb91                	beqz	a5,80001c0c <allocproc+0x38>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	8c0ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c00:	17048493          	addi	s1,s1,368
    80001c04:	ff2496e3          	bne	s1,s2,80001bf0 <allocproc+0x1c>
  return 0;
    80001c08:	4481                	li	s1,0
    80001c0a:	a0a9                	j	80001c54 <allocproc+0x80>
  p->pid = allocpid();
    80001c0c:	e6dff0ef          	jal	80001a78 <allocpid>
    80001c10:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c12:	4785                	li	a5,1
    80001c14:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001c16:	0204aa23          	sw	zero,52(s1)
  p->heat = 0;              // new process starts cool
    80001c1a:	0204ac23          	sw	zero,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1e:	f27fe0ef          	jal	80000b44 <kalloc>
    80001c22:	892a                	mv	s2,a0
    80001c24:	f0a8                	sd	a0,96(s1)
    80001c26:	cd15                	beqz	a0,80001c62 <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001c28:	8526                	mv	a0,s1
    80001c2a:	e8dff0ef          	jal	80001ab6 <proc_pagetable>
    80001c2e:	892a                	mv	s2,a0
    80001c30:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c32:	c121                	beqz	a0,80001c72 <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001c34:	07000613          	li	a2,112
    80001c38:	4581                	li	a1,0
    80001c3a:	06848513          	addi	a0,s1,104
    80001c3e:	8baff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001c42:	00000797          	auipc	a5,0x0
    80001c46:	d9c78793          	addi	a5,a5,-612 # 800019de <forkret>
    80001c4a:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4c:	64bc                	ld	a5,72(s1)
    80001c4e:	6705                	lui	a4,0x1
    80001c50:	97ba                	add	a5,a5,a4
    80001c52:	f8bc                	sd	a5,112(s1)
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret
    freeproc(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	f1dff0ef          	jal	80001b80 <freeproc>
    release(&p->lock);
    80001c68:	8526                	mv	a0,s1
    80001c6a:	852ff0ef          	jal	80000cbc <release>
    return 0;
    80001c6e:	84ca                	mv	s1,s2
    80001c70:	b7d5                	j	80001c54 <allocproc+0x80>
    freeproc(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	f0dff0ef          	jal	80001b80 <freeproc>
    release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	842ff0ef          	jal	80000cbc <release>
    return 0;
    80001c7e:	84ca                	mv	s1,s2
    80001c80:	bfd1                	j	80001c54 <allocproc+0x80>

0000000080001c82 <userinit>:
{
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8c:	f49ff0ef          	jal	80001bd4 <allocproc>
    80001c90:	84aa                	mv	s1,a0
  initproc = p;
    80001c92:	00009797          	auipc	a5,0x9
    80001c96:	8ea7b323          	sd	a0,-1818(a5) # 8000a578 <initproc>
  p->cwd = namei("/");
    80001c9a:	00005517          	auipc	a0,0x5
    80001c9e:	4f650513          	addi	a0,a0,1270 # 80007190 <etext+0x190>
    80001ca2:	2f2020ef          	jal	80003f94 <namei>
    80001ca6:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001caa:	478d                	li	a5,3
    80001cac:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	80cff0ef          	jal	80000cbc <release>
}
    80001cb4:	60e2                	ld	ra,24(sp)
    80001cb6:	6442                	ld	s0,16(sp)
    80001cb8:	64a2                	ld	s1,8(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret

0000000080001cbe <growproc>:
{
    80001cbe:	1101                	addi	sp,sp,-32
    80001cc0:	ec06                	sd	ra,24(sp)
    80001cc2:	e822                	sd	s0,16(sp)
    80001cc4:	e426                	sd	s1,8(sp)
    80001cc6:	e04a                	sd	s2,0(sp)
    80001cc8:	1000                	addi	s0,sp,32
    80001cca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ccc:	ce1ff0ef          	jal	800019ac <myproc>
    80001cd0:	892a                	mv	s2,a0
  sz = p->sz;
    80001cd2:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001cd4:	02905963          	blez	s1,80001d06 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001cd8:	00b48633          	add	a2,s1,a1
    80001cdc:	020007b7          	lui	a5,0x2000
    80001ce0:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001ce2:	07b6                	slli	a5,a5,0xd
    80001ce4:	02c7ea63          	bltu	a5,a2,80001d18 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ce8:	4691                	li	a3,4
    80001cea:	6d28                	ld	a0,88(a0)
    80001cec:	e10ff0ef          	jal	800012fc <uvmalloc>
    80001cf0:	85aa                	mv	a1,a0
    80001cf2:	c50d                	beqz	a0,80001d1c <growproc+0x5e>
  p->sz = sz;
    80001cf4:	04b93823          	sd	a1,80(s2)
  return 0;
    80001cf8:	4501                	li	a0,0
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6902                	ld	s2,0(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret
  } else if(n < 0){
    80001d06:	fe04d7e3          	bgez	s1,80001cf4 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d0a:	00b48633          	add	a2,s1,a1
    80001d0e:	6d28                	ld	a0,88(a0)
    80001d10:	da8ff0ef          	jal	800012b8 <uvmdealloc>
    80001d14:	85aa                	mv	a1,a0
    80001d16:	bff9                	j	80001cf4 <growproc+0x36>
      return -1;
    80001d18:	557d                	li	a0,-1
    80001d1a:	b7c5                	j	80001cfa <growproc+0x3c>
      return -1;
    80001d1c:	557d                	li	a0,-1
    80001d1e:	bff1                	j	80001cfa <growproc+0x3c>

0000000080001d20 <kfork>:
{
    80001d20:	7139                	addi	sp,sp,-64
    80001d22:	fc06                	sd	ra,56(sp)
    80001d24:	f822                	sd	s0,48(sp)
    80001d26:	f426                	sd	s1,40(sp)
    80001d28:	e456                	sd	s5,8(sp)
    80001d2a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d2c:	c81ff0ef          	jal	800019ac <myproc>
    80001d30:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d32:	ea3ff0ef          	jal	80001bd4 <allocproc>
    80001d36:	0e050a63          	beqz	a0,80001e2a <kfork+0x10a>
    80001d3a:	e852                	sd	s4,16(sp)
    80001d3c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d3e:	050ab603          	ld	a2,80(s5)
    80001d42:	6d2c                	ld	a1,88(a0)
    80001d44:	058ab503          	ld	a0,88(s5)
    80001d48:	eecff0ef          	jal	80001434 <uvmcopy>
    80001d4c:	04054863          	bltz	a0,80001d9c <kfork+0x7c>
    80001d50:	f04a                	sd	s2,32(sp)
    80001d52:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d54:	050ab783          	ld	a5,80(s5)
    80001d58:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d5c:	060ab683          	ld	a3,96(s5)
    80001d60:	87b6                	mv	a5,a3
    80001d62:	060a3703          	ld	a4,96(s4)
    80001d66:	12068693          	addi	a3,a3,288
    80001d6a:	6388                	ld	a0,0(a5)
    80001d6c:	678c                	ld	a1,8(a5)
    80001d6e:	6b90                	ld	a2,16(a5)
    80001d70:	e308                	sd	a0,0(a4)
    80001d72:	e70c                	sd	a1,8(a4)
    80001d74:	eb10                	sd	a2,16(a4)
    80001d76:	6f90                	ld	a2,24(a5)
    80001d78:	ef10                	sd	a2,24(a4)
    80001d7a:	02078793          	addi	a5,a5,32
    80001d7e:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d82:	fed794e3          	bne	a5,a3,80001d6a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d86:	060a3783          	ld	a5,96(s4)
    80001d8a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d8e:	0d8a8493          	addi	s1,s5,216
    80001d92:	0d8a0913          	addi	s2,s4,216
    80001d96:	158a8993          	addi	s3,s5,344
    80001d9a:	a831                	j	80001db6 <kfork+0x96>
    freeproc(np);
    80001d9c:	8552                	mv	a0,s4
    80001d9e:	de3ff0ef          	jal	80001b80 <freeproc>
    release(&np->lock);
    80001da2:	8552                	mv	a0,s4
    80001da4:	f19fe0ef          	jal	80000cbc <release>
    return -1;
    80001da8:	54fd                	li	s1,-1
    80001daa:	6a42                	ld	s4,16(sp)
    80001dac:	a885                	j	80001e1c <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001dae:	04a1                	addi	s1,s1,8
    80001db0:	0921                	addi	s2,s2,8
    80001db2:	01348963          	beq	s1,s3,80001dc4 <kfork+0xa4>
    if(p->ofile[i])
    80001db6:	6088                	ld	a0,0(s1)
    80001db8:	d97d                	beqz	a0,80001dae <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dba:	796020ef          	jal	80004550 <filedup>
    80001dbe:	00a93023          	sd	a0,0(s2)
    80001dc2:	b7f5                	j	80001dae <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001dc4:	158ab503          	ld	a0,344(s5)
    80001dc8:	169010ef          	jal	80003730 <idup>
    80001dcc:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dd0:	4641                	li	a2,16
    80001dd2:	160a8593          	addi	a1,s5,352
    80001dd6:	160a0513          	addi	a0,s4,352
    80001dda:	872ff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001dde:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001de2:	8552                	mv	a0,s4
    80001de4:	ed9fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001de8:	00011517          	auipc	a0,0x11
    80001dec:	8b850513          	addi	a0,a0,-1864 # 800126a0 <wait_lock>
    80001df0:	e39fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001df4:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001df8:	00011517          	auipc	a0,0x11
    80001dfc:	8a850513          	addi	a0,a0,-1880 # 800126a0 <wait_lock>
    80001e00:	ebdfe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001e04:	8552                	mv	a0,s4
    80001e06:	e23fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e0a:	478d                	li	a5,3
    80001e0c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e10:	8552                	mv	a0,s4
    80001e12:	eabfe0ef          	jal	80000cbc <release>
  return pid;
    80001e16:	7902                	ld	s2,32(sp)
    80001e18:	69e2                	ld	s3,24(sp)
    80001e1a:	6a42                	ld	s4,16(sp)
}
    80001e1c:	8526                	mv	a0,s1
    80001e1e:	70e2                	ld	ra,56(sp)
    80001e20:	7442                	ld	s0,48(sp)
    80001e22:	74a2                	ld	s1,40(sp)
    80001e24:	6aa2                	ld	s5,8(sp)
    80001e26:	6121                	addi	sp,sp,64
    80001e28:	8082                	ret
    return -1;
    80001e2a:	54fd                	li	s1,-1
    80001e2c:	bfc5                	j	80001e1c <kfork+0xfc>

0000000080001e2e <scheduler>:
{
    80001e2e:	7159                	addi	sp,sp,-112
    80001e30:	f486                	sd	ra,104(sp)
    80001e32:	f0a2                	sd	s0,96(sp)
    80001e34:	eca6                	sd	s1,88(sp)
    80001e36:	e8ca                	sd	s2,80(sp)
    80001e38:	e4ce                	sd	s3,72(sp)
    80001e3a:	e0d2                	sd	s4,64(sp)
    80001e3c:	fc56                	sd	s5,56(sp)
    80001e3e:	f85a                	sd	s6,48(sp)
    80001e40:	f45e                	sd	s7,40(sp)
    80001e42:	f062                	sd	s8,32(sp)
    80001e44:	ec66                	sd	s9,24(sp)
    80001e46:	e86a                	sd	s10,16(sp)
    80001e48:	e46e                	sd	s11,8(sp)
    80001e4a:	1880                	addi	s0,sp,112
    80001e4c:	8792                	mv	a5,tp
  int id = r_tp();
    80001e4e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e50:	00779693          	slli	a3,a5,0x7
    80001e54:	00011717          	auipc	a4,0x11
    80001e58:	83470713          	addi	a4,a4,-1996 # 80012688 <pid_lock>
    80001e5c:	9736                	add	a4,a4,a3
    80001e5e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &chosen->context);
    80001e62:	00011717          	auipc	a4,0x11
    80001e66:	85e70713          	addi	a4,a4,-1954 # 800126c0 <cpus+0x8>
    80001e6a:	9736                	add	a4,a4,a3
    80001e6c:	8dba                	mv	s11,a4
    if(cpu_temp >= THROTTLE_TEMP){
    80001e6e:	00008917          	auipc	s2,0x8
    80001e72:	6b690913          	addi	s2,s2,1718 # 8000a524 <cpu_temp>
        if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
    80001e76:	04f00993          	li	s3,79
        c->proc = chosen;
    80001e7a:	00011a17          	auipc	s4,0x11
    80001e7e:	80ea0a13          	addi	s4,s4,-2034 # 80012688 <pid_lock>
    80001e82:	9a36                	add	s4,s4,a3
    80001e84:	a88d                	j	80001ef6 <scheduler+0xc8>
          if(p->heat < 0) p->heat = 0;
    80001e86:	0204ac23          	sw	zero,56(s1)
      release(&p->lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	e31fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001e90:	17048493          	addi	s1,s1,368
    80001e94:	03548163          	beq	s1,s5,80001eb6 <scheduler+0x88>
      acquire(&p->lock);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	d8ffe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    80001e9e:	4c9c                	lw	a5,24(s1)
    80001ea0:	37f9                	addiw	a5,a5,-2
    80001ea2:	fefb64e3          	bltu	s6,a5,80001e8a <scheduler+0x5c>
        if(p->heat > 0){
    80001ea6:	5c9c                	lw	a5,56(s1)
    80001ea8:	fef051e3          	blez	a5,80001e8a <scheduler+0x5c>
          p->heat -= HEAT_DECAY;
    80001eac:	37f9                	addiw	a5,a5,-2
          if(p->heat < 0) p->heat = 0;
    80001eae:	fc07cce3          	bltz	a5,80001e86 <scheduler+0x58>
          p->heat -= HEAT_DECAY;
    80001eb2:	dc9c                	sw	a5,56(s1)
    80001eb4:	bfd9                	j	80001e8a <scheduler+0x5c>
    if(cpu_temp >= THROTTLE_TEMP){
    80001eb6:	00092583          	lw	a1,0(s2)
    80001eba:	05900793          	li	a5,89
    80001ebe:	08b7d163          	bge	a5,a1,80001f40 <scheduler+0x112>
      if(sched_round % THERMAL_LOG_INTERVAL == 0)
    80001ec2:	00008717          	auipc	a4,0x8
    80001ec6:	6ae72703          	lw	a4,1710(a4) # 8000a570 <sched_round.3>
    80001eca:	666667b7          	lui	a5,0x66666
    80001ece:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    80001ed2:	02f707b3          	mul	a5,a4,a5
    80001ed6:	9789                	srai	a5,a5,0x22
    80001ed8:	41f7569b          	sraiw	a3,a4,0x1f
    80001edc:	9f95                	subw	a5,a5,a3
    80001ede:	0027969b          	slliw	a3,a5,0x2
    80001ee2:	9fb5                	addw	a5,a5,a3
    80001ee4:	0017979b          	slliw	a5,a5,0x1
    80001ee8:	9f1d                	subw	a4,a4,a5
    80001eea:	c331                	beqz	a4,80001f2e <scheduler+0x100>
      update_cpu_temp(0);  // idle cooling
    80001eec:	4501                	li	a0,0
    80001eee:	8b3ff0ef          	jal	800017a0 <update_cpu_temp>
      asm volatile("wfi");
    80001ef2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efe:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f02:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f06:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f08:	10079073          	csrw	sstatus,a5
    sched_round++;
    80001f0c:	00008717          	auipc	a4,0x8
    80001f10:	66470713          	addi	a4,a4,1636 # 8000a570 <sched_round.3>
    80001f14:	431c                	lw	a5,0(a4)
    80001f16:	2785                	addiw	a5,a5,1
    80001f18:	c31c                	sw	a5,0(a4)
    for(p = proc; p < &proc[NPROC]; p++){
    80001f1a:	00011497          	auipc	s1,0x11
    80001f1e:	b9e48493          	addi	s1,s1,-1122 # 80012ab8 <proc>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    80001f22:	4b05                	li	s6,1
    for(p = proc; p < &proc[NPROC]; p++){
    80001f24:	00016a97          	auipc	s5,0x16
    80001f28:	794a8a93          	addi	s5,s5,1940 # 800186b8 <tickslock>
    80001f2c:	b7b5                	j	80001e98 <scheduler+0x6a>
        printf("  [COOLING] Temp: %d/%d  | Throttling -- idle cycle to cool down\n", cpu_temp, THROTTLE_TEMP);
    80001f2e:	05a00613          	li	a2,90
    80001f32:	00005517          	auipc	a0,0x5
    80001f36:	27e50513          	addi	a0,a0,638 # 800071b0 <etext+0x1b0>
    80001f3a:	dc0fe0ef          	jal	800004fa <printf>
    80001f3e:	b77d                	j	80001eec <scheduler+0xbe>
    chosen = 0;
    80001f40:	4b01                	li	s6,0
    for(p = proc; p < &proc[NPROC]; p++){
    80001f42:	00011497          	auipc	s1,0x11
    80001f46:	b7648493          	addi	s1,s1,-1162 # 80012ab8 <proc>
      if(p->state == RUNNABLE){
    80001f4a:	4a8d                	li	s5,3
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001f4c:	4d25                	li	s10,9
    80001f4e:	00005c97          	auipc	s9,0x5
    80001f52:	2aac8c93          	addi	s9,s9,682 # 800071f8 <etext+0x1f8>
        if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    80001f56:	03b00b93          	li	s7,59
        if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
    80001f5a:	4c75                	li	s8,29
    80001f5c:	a835                	j	80001f98 <scheduler+0x16a>
        if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    80001f5e:	04fbce63          	blt	s7,a5,80001fba <scheduler+0x18c>
        if(p->parent != 0 &&
    80001f62:	60a8                	ld	a0,64(s1)
    80001f64:	cd19                	beqz	a0,80001f82 <scheduler+0x154>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001f66:	866a                	mv	a2,s10
    80001f68:	85e6                	mv	a1,s9
    80001f6a:	16050513          	addi	a0,a0,352
    80001f6e:	e5ffe0ef          	jal	80000dcc <strncmp>
        if(p->parent != 0 &&
    80001f72:	e901                	bnez	a0,80001f82 <scheduler+0x154>
          if(chosen == 0 || p->pid < chosen->pid)
    80001f74:	040b0a63          	beqz	s6,80001fc8 <scheduler+0x19a>
    80001f78:	5898                	lw	a4,48(s1)
    80001f7a:	030b2783          	lw	a5,48(s6)
    80001f7e:	04f74763          	blt	a4,a5,80001fcc <scheduler+0x19e>
      release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	d39fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f88:	17048493          	addi	s1,s1,368
    80001f8c:	00016797          	auipc	a5,0x16
    80001f90:	72c78793          	addi	a5,a5,1836 # 800186b8 <tickslock>
    80001f94:	02f48e63          	beq	s1,a5,80001fd0 <scheduler+0x1a2>
      acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	c8ffe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE){
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff5791e3          	bne	a5,s5,80001f82 <scheduler+0x154>
        if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
    80001fa4:	00092783          	lw	a5,0(s2)
    80001fa8:	faf9dbe3          	bge	s3,a5,80001f5e <scheduler+0x130>
    80001fac:	5c9c                	lw	a5,56(s1)
    80001fae:	fafc5ae3          	bge	s8,a5,80001f62 <scheduler+0x134>
          release(&p->lock);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	d09fe0ef          	jal	80000cbc <release>
          continue;   // CPU hot → skip hot processes
    80001fb8:	bfc1                	j	80001f88 <scheduler+0x15a>
        if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    80001fba:	5c9c                	lw	a5,56(s1)
    80001fbc:	fafbd3e3          	bge	s7,a5,80001f62 <scheduler+0x134>
          release(&p->lock);
    80001fc0:	8526                	mv	a0,s1
    80001fc2:	cfbfe0ef          	jal	80000cbc <release>
          continue;   // CPU warm → skip very hot processes
    80001fc6:	b7c9                	j	80001f88 <scheduler+0x15a>
            chosen = p;
    80001fc8:	8b26                	mv	s6,s1
    80001fca:	bf65                	j	80001f82 <scheduler+0x154>
    80001fcc:	8b26                	mv	s6,s1
    80001fce:	bf55                	j	80001f82 <scheduler+0x154>
    if(chosen == 0){
    80001fd0:	000b0b63          	beqz	s6,80001fe6 <scheduler+0x1b8>
    for(p = proc; p < &proc[NPROC]; p++){
    80001fd4:	00011497          	auipc	s1,0x11
    80001fd8:	ae448493          	addi	s1,s1,-1308 # 80012ab8 <proc>
    80001fdc:	00016a97          	auipc	s5,0x16
    80001fe0:	6dca8a93          	addi	s5,s5,1756 # 800186b8 <tickslock>
    80001fe4:	a845                	j	80002094 <scheduler+0x266>
      int lowest_heat = MAX_HEAT + 1;
    80001fe6:	06500c13          	li	s8,101
      for(p = proc; p < &proc[NPROC]; p++){
    80001fea:	00011497          	auipc	s1,0x11
    80001fee:	ace48493          	addi	s1,s1,-1330 # 80012ab8 <proc>
        if(p->state == RUNNABLE){
    80001ff2:	4b8d                	li	s7,3
          if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    80001ff4:	03b00c93          	li	s9,59
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
    80001ff8:	4d75                	li	s10,29
      for(p = proc; p < &proc[NPROC]; p++){
    80001ffa:	8abe                	mv	s5,a5
    80001ffc:	a839                	j	8000201a <scheduler+0x1ec>
          if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    80001ffe:	02fccf63          	blt	s9,a5,8000203c <scheduler+0x20e>
          if(p->heat < lowest_heat){
    80002002:	5c9c                	lw	a5,56(s1)
    80002004:	0187d463          	bge	a5,s8,8000200c <scheduler+0x1de>
            lowest_heat = p->heat;
    80002008:	8c3e                	mv	s8,a5
            chosen = p;
    8000200a:	8b26                	mv	s6,s1
        release(&p->lock);
    8000200c:	8526                	mv	a0,s1
    8000200e:	caffe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80002012:	17048493          	addi	s1,s1,368
    80002016:	03548a63          	beq	s1,s5,8000204a <scheduler+0x21c>
        acquire(&p->lock);
    8000201a:	8526                	mv	a0,s1
    8000201c:	c0dfe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    80002020:	4c9c                	lw	a5,24(s1)
    80002022:	ff7795e3          	bne	a5,s7,8000200c <scheduler+0x1de>
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH){
    80002026:	00092783          	lw	a5,0(s2)
    8000202a:	fcf9dae3          	bge	s3,a5,80001ffe <scheduler+0x1d0>
    8000202e:	5c9c                	lw	a5,56(s1)
    80002030:	fcfd59e3          	bge	s10,a5,80002002 <scheduler+0x1d4>
            release(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	c87fe0ef          	jal	80000cbc <release>
            continue;
    8000203a:	bfe1                	j	80002012 <scheduler+0x1e4>
          if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH){
    8000203c:	5c9c                	lw	a5,56(s1)
    8000203e:	fcfcd2e3          	bge	s9,a5,80002002 <scheduler+0x1d4>
            release(&p->lock);
    80002042:	8526                	mv	a0,s1
    80002044:	c79fe0ef          	jal	80000cbc <release>
            continue;
    80002048:	b7e9                	j	80002012 <scheduler+0x1e4>
    if(chosen == 0){
    8000204a:	f80b15e3          	bnez	s6,80001fd4 <scheduler+0x1a6>
      for(p = proc; p < &proc[NPROC]; p++){
    8000204e:	00011497          	auipc	s1,0x11
    80002052:	a6a48493          	addi	s1,s1,-1430 # 80012ab8 <proc>
        if(p->state == RUNNABLE){
    80002056:	4b8d                	li	s7,3
      for(p = proc; p < &proc[NPROC]; p++){
    80002058:	00016a97          	auipc	s5,0x16
    8000205c:	660a8a93          	addi	s5,s5,1632 # 800186b8 <tickslock>
        acquire(&p->lock);
    80002060:	8526                	mv	a0,s1
    80002062:	bc7fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    80002066:	4c9c                	lw	a5,24(s1)
    80002068:	01778a63          	beq	a5,s7,8000207c <scheduler+0x24e>
        release(&p->lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	c4ffe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80002072:	17048493          	addi	s1,s1,368
    80002076:	ff5495e3          	bne	s1,s5,80002060 <scheduler+0x232>
    8000207a:	bfa9                	j	80001fd4 <scheduler+0x1a6>
          release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	c3ffe0ef          	jal	80000cbc <release>
          chosen = p;
    80002082:	8b26                	mv	s6,s1
          break;
    80002084:	bf81                	j	80001fd4 <scheduler+0x1a6>
      release(&p->lock);
    80002086:	8526                	mv	a0,s1
    80002088:	c35fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    8000208c:	17048493          	addi	s1,s1,368
    80002090:	01548e63          	beq	s1,s5,800020ac <scheduler+0x27e>
      acquire(&p->lock);
    80002094:	8526                	mv	a0,s1
    80002096:	b93fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen){
    8000209a:	4c9c                	lw	a5,24(s1)
    8000209c:	17f5                	addi	a5,a5,-3
    8000209e:	f7e5                	bnez	a5,80002086 <scheduler+0x258>
    800020a0:	fe9b03e3          	beq	s6,s1,80002086 <scheduler+0x258>
        p->waiting_tick++;
    800020a4:	58dc                	lw	a5,52(s1)
    800020a6:	2785                	addiw	a5,a5,1
    800020a8:	d8dc                	sw	a5,52(s1)
    800020aa:	bff1                	j	80002086 <scheduler+0x258>
    if(chosen == 0){
    800020ac:	000b0f63          	beqz	s6,800020ca <scheduler+0x29c>
      acquire(&chosen->lock);
    800020b0:	84da                	mv	s1,s6
    800020b2:	855a                	mv	a0,s6
    800020b4:	b75fe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    800020b8:	018b2703          	lw	a4,24(s6)
    800020bc:	478d                	li	a5,3
    800020be:	00f70c63          	beq	a4,a5,800020d6 <scheduler+0x2a8>
      release(&chosen->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	bf9fe0ef          	jal	80000cbc <release>
    800020c8:	b53d                	j	80001ef6 <scheduler+0xc8>
      update_cpu_temp(0);  // idle cooling
    800020ca:	4501                	li	a0,0
    800020cc:	ed4ff0ef          	jal	800017a0 <update_cpu_temp>
      asm volatile("wfi");
    800020d0:	10500073          	wfi
    800020d4:	b50d                	j	80001ef6 <scheduler+0xc8>
        if(sched_round % THERMAL_LOG_INTERVAL == 0){
    800020d6:	00008717          	auipc	a4,0x8
    800020da:	49a72703          	lw	a4,1178(a4) # 8000a570 <sched_round.3>
    800020de:	666667b7          	lui	a5,0x66666
    800020e2:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    800020e6:	02f707b3          	mul	a5,a4,a5
    800020ea:	9789                	srai	a5,a5,0x22
    800020ec:	41f7569b          	sraiw	a3,a4,0x1f
    800020f0:	9f95                	subw	a5,a5,a3
    800020f2:	0027969b          	slliw	a3,a5,0x2
    800020f6:	9fb5                	addw	a5,a5,a3
    800020f8:	0017979b          	slliw	a5,a5,0x1
    800020fc:	9f1d                	subw	a4,a4,a5
    800020fe:	e329                	bnez	a4,80002140 <scheduler+0x312>
          if(cpu_temp >= 80) zone = "HOT ";
    80002100:	00092583          	lw	a1,0(s2)
    80002104:	00005617          	auipc	a2,0x5
    80002108:	09460613          	addi	a2,a2,148 # 80007198 <etext+0x198>
    8000210c:	00b9ce63          	blt	s3,a1,80002128 <scheduler+0x2fa>
          else if(cpu_temp >= 60) zone = "WARM";
    80002110:	03b00793          	li	a5,59
    80002114:	00005617          	auipc	a2,0x5
    80002118:	09460613          	addi	a2,a2,148 # 800071a8 <etext+0x1a8>
    8000211c:	00b7c663          	blt	a5,a1,80002128 <scheduler+0x2fa>
          char *zone = "COOL";
    80002120:	00005617          	auipc	a2,0x5
    80002124:	08060613          	addi	a2,a2,128 # 800071a0 <etext+0x1a0>
          printf("  [THERMAL] Temp: %d [%s] | PID: %d | Heat: %d | %s\n",
    80002128:	160b0793          	addi	a5,s6,352
    8000212c:	038b2703          	lw	a4,56(s6)
    80002130:	030b2683          	lw	a3,48(s6)
    80002134:	00005517          	auipc	a0,0x5
    80002138:	0d450513          	addi	a0,a0,212 # 80007208 <etext+0x208>
    8000213c:	bbefe0ef          	jal	800004fa <printf>
        chosen->state = RUNNING;
    80002140:	4791                	li	a5,4
    80002142:	00fb2c23          	sw	a5,24(s6)
        c->proc = chosen;
    80002146:	036a3823          	sd	s6,48(s4)
        chosen->heat += HEAT_INCREMENT;
    8000214a:	038b2783          	lw	a5,56(s6)
    8000214e:	27a9                	addiw	a5,a5,10
    80002150:	853e                	mv	a0,a5
        if(chosen->heat > MAX_HEAT)
    80002152:	06400713          	li	a4,100
    80002156:	00f75463          	bge	a4,a5,8000215e <scheduler+0x330>
    8000215a:	06400513          	li	a0,100
    8000215e:	02ab2c23          	sw	a0,56(s6)
        update_cpu_temp(chosen->heat);
    80002162:	2501                	sext.w	a0,a0
    80002164:	e3cff0ef          	jal	800017a0 <update_cpu_temp>
        swtch(&c->context, &chosen->context);
    80002168:	068b0593          	addi	a1,s6,104
    8000216c:	856e                	mv	a0,s11
    8000216e:	768000ef          	jal	800028d6 <swtch>
        c->proc = 0;
    80002172:	020a3823          	sd	zero,48(s4)
    80002176:	b7b1                	j	800020c2 <scheduler+0x294>

0000000080002178 <sched>:
{
    80002178:	7179                	addi	sp,sp,-48
    8000217a:	f406                	sd	ra,40(sp)
    8000217c:	f022                	sd	s0,32(sp)
    8000217e:	ec26                	sd	s1,24(sp)
    80002180:	e84a                	sd	s2,16(sp)
    80002182:	e44e                	sd	s3,8(sp)
    80002184:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002186:	827ff0ef          	jal	800019ac <myproc>
    8000218a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000218c:	a2dfe0ef          	jal	80000bb8 <holding>
    80002190:	c935                	beqz	a0,80002204 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002192:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002194:	2781                	sext.w	a5,a5
    80002196:	079e                	slli	a5,a5,0x7
    80002198:	00010717          	auipc	a4,0x10
    8000219c:	4f070713          	addi	a4,a4,1264 # 80012688 <pid_lock>
    800021a0:	97ba                	add	a5,a5,a4
    800021a2:	0a87a703          	lw	a4,168(a5)
    800021a6:	4785                	li	a5,1
    800021a8:	06f71463          	bne	a4,a5,80002210 <sched+0x98>
  if(p->state == RUNNING)
    800021ac:	4c98                	lw	a4,24(s1)
    800021ae:	4791                	li	a5,4
    800021b0:	06f70663          	beq	a4,a5,8000221c <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021b4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021b8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021ba:	e7bd                	bnez	a5,80002228 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021bc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021be:	00010917          	auipc	s2,0x10
    800021c2:	4ca90913          	addi	s2,s2,1226 # 80012688 <pid_lock>
    800021c6:	2781                	sext.w	a5,a5
    800021c8:	079e                	slli	a5,a5,0x7
    800021ca:	97ca                	add	a5,a5,s2
    800021cc:	0ac7a983          	lw	s3,172(a5)
    800021d0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021d2:	2781                	sext.w	a5,a5
    800021d4:	079e                	slli	a5,a5,0x7
    800021d6:	07a1                	addi	a5,a5,8
    800021d8:	00010597          	auipc	a1,0x10
    800021dc:	4e058593          	addi	a1,a1,1248 # 800126b8 <cpus>
    800021e0:	95be                	add	a1,a1,a5
    800021e2:	06848513          	addi	a0,s1,104
    800021e6:	6f0000ef          	jal	800028d6 <swtch>
    800021ea:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ec:	2781                	sext.w	a5,a5
    800021ee:	079e                	slli	a5,a5,0x7
    800021f0:	993e                	add	s2,s2,a5
    800021f2:	0b392623          	sw	s3,172(s2)
}
    800021f6:	70a2                	ld	ra,40(sp)
    800021f8:	7402                	ld	s0,32(sp)
    800021fa:	64e2                	ld	s1,24(sp)
    800021fc:	6942                	ld	s2,16(sp)
    800021fe:	69a2                	ld	s3,8(sp)
    80002200:	6145                	addi	sp,sp,48
    80002202:	8082                	ret
    panic("sched p->lock");
    80002204:	00005517          	auipc	a0,0x5
    80002208:	03c50513          	addi	a0,a0,60 # 80007240 <etext+0x240>
    8000220c:	e18fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80002210:	00005517          	auipc	a0,0x5
    80002214:	04050513          	addi	a0,a0,64 # 80007250 <etext+0x250>
    80002218:	e0cfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    8000221c:	00005517          	auipc	a0,0x5
    80002220:	04450513          	addi	a0,a0,68 # 80007260 <etext+0x260>
    80002224:	e00fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80002228:	00005517          	auipc	a0,0x5
    8000222c:	04850513          	addi	a0,a0,72 # 80007270 <etext+0x270>
    80002230:	df4fe0ef          	jal	80000824 <panic>

0000000080002234 <yield>:
{
    80002234:	1101                	addi	sp,sp,-32
    80002236:	ec06                	sd	ra,24(sp)
    80002238:	e822                	sd	s0,16(sp)
    8000223a:	e426                	sd	s1,8(sp)
    8000223c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000223e:	f6eff0ef          	jal	800019ac <myproc>
    80002242:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002244:	9e5fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002248:	478d                	li	a5,3
    8000224a:	cc9c                	sw	a5,24(s1)
  sched();
    8000224c:	f2dff0ef          	jal	80002178 <sched>
  release(&p->lock);
    80002250:	8526                	mv	a0,s1
    80002252:	a6bfe0ef          	jal	80000cbc <release>
}
    80002256:	60e2                	ld	ra,24(sp)
    80002258:	6442                	ld	s0,16(sp)
    8000225a:	64a2                	ld	s1,8(sp)
    8000225c:	6105                	addi	sp,sp,32
    8000225e:	8082                	ret

0000000080002260 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	1800                	addi	s0,sp,48
    8000226e:	89aa                	mv	s3,a0
    80002270:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002272:	f3aff0ef          	jal	800019ac <myproc>
    80002276:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002278:	9b1fe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000227c:	854a                	mv	a0,s2
    8000227e:	a3ffe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80002282:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002286:	4789                	li	a5,2
    80002288:	cc9c                	sw	a5,24(s1)

  sched();
    8000228a:	eefff0ef          	jal	80002178 <sched>

  // Tidy up.
  p->chan = 0;
    8000228e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	a29fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80002298:	854a                	mv	a0,s2
    8000229a:	98ffe0ef          	jal	80000c28 <acquire>
}
    8000229e:	70a2                	ld	ra,40(sp)
    800022a0:	7402                	ld	s0,32(sp)
    800022a2:	64e2                	ld	s1,24(sp)
    800022a4:	6942                	ld	s2,16(sp)
    800022a6:	69a2                	ld	s3,8(sp)
    800022a8:	6145                	addi	sp,sp,48
    800022aa:	8082                	ret

00000000800022ac <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800022ac:	7139                	addi	sp,sp,-64
    800022ae:	fc06                	sd	ra,56(sp)
    800022b0:	f822                	sd	s0,48(sp)
    800022b2:	f426                	sd	s1,40(sp)
    800022b4:	f04a                	sd	s2,32(sp)
    800022b6:	ec4e                	sd	s3,24(sp)
    800022b8:	e852                	sd	s4,16(sp)
    800022ba:	e456                	sd	s5,8(sp)
    800022bc:	0080                	addi	s0,sp,64
    800022be:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022c0:	00010497          	auipc	s1,0x10
    800022c4:	7f848493          	addi	s1,s1,2040 # 80012ab8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022c8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022ca:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022cc:	00016917          	auipc	s2,0x16
    800022d0:	3ec90913          	addi	s2,s2,1004 # 800186b8 <tickslock>
    800022d4:	a801                	j	800022e4 <wakeup+0x38>
      }
      release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	9e5fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022dc:	17048493          	addi	s1,s1,368
    800022e0:	03248263          	beq	s1,s2,80002304 <wakeup+0x58>
    if(p != myproc()){
    800022e4:	ec8ff0ef          	jal	800019ac <myproc>
    800022e8:	fe950ae3          	beq	a0,s1,800022dc <wakeup+0x30>
      acquire(&p->lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	93bfe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022f2:	4c9c                	lw	a5,24(s1)
    800022f4:	ff3791e3          	bne	a5,s3,800022d6 <wakeup+0x2a>
    800022f8:	709c                	ld	a5,32(s1)
    800022fa:	fd479ee3          	bne	a5,s4,800022d6 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022fe:	0154ac23          	sw	s5,24(s1)
    80002302:	bfd1                	j	800022d6 <wakeup+0x2a>
    }
  }
}
    80002304:	70e2                	ld	ra,56(sp)
    80002306:	7442                	ld	s0,48(sp)
    80002308:	74a2                	ld	s1,40(sp)
    8000230a:	7902                	ld	s2,32(sp)
    8000230c:	69e2                	ld	s3,24(sp)
    8000230e:	6a42                	ld	s4,16(sp)
    80002310:	6aa2                	ld	s5,8(sp)
    80002312:	6121                	addi	sp,sp,64
    80002314:	8082                	ret

0000000080002316 <reparent>:
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	e052                	sd	s4,0(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002328:	00010497          	auipc	s1,0x10
    8000232c:	79048493          	addi	s1,s1,1936 # 80012ab8 <proc>
      pp->parent = initproc;
    80002330:	00008a17          	auipc	s4,0x8
    80002334:	248a0a13          	addi	s4,s4,584 # 8000a578 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002338:	00016997          	auipc	s3,0x16
    8000233c:	38098993          	addi	s3,s3,896 # 800186b8 <tickslock>
    80002340:	a029                	j	8000234a <reparent+0x34>
    80002342:	17048493          	addi	s1,s1,368
    80002346:	01348b63          	beq	s1,s3,8000235c <reparent+0x46>
    if(pp->parent == p){
    8000234a:	60bc                	ld	a5,64(s1)
    8000234c:	ff279be3          	bne	a5,s2,80002342 <reparent+0x2c>
      pp->parent = initproc;
    80002350:	000a3503          	ld	a0,0(s4)
    80002354:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002356:	f57ff0ef          	jal	800022ac <wakeup>
    8000235a:	b7e5                	j	80002342 <reparent+0x2c>
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6a02                	ld	s4,0(sp)
    80002368:	6145                	addi	sp,sp,48
    8000236a:	8082                	ret

000000008000236c <kexit>:
{
    8000236c:	7179                	addi	sp,sp,-48
    8000236e:	f406                	sd	ra,40(sp)
    80002370:	f022                	sd	s0,32(sp)
    80002372:	ec26                	sd	s1,24(sp)
    80002374:	e84a                	sd	s2,16(sp)
    80002376:	e44e                	sd	s3,8(sp)
    80002378:	e052                	sd	s4,0(sp)
    8000237a:	1800                	addi	s0,sp,48
    8000237c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000237e:	e2eff0ef          	jal	800019ac <myproc>
    80002382:	89aa                	mv	s3,a0
  if(p == initproc)
    80002384:	00008797          	auipc	a5,0x8
    80002388:	1f47b783          	ld	a5,500(a5) # 8000a578 <initproc>
    8000238c:	0d850493          	addi	s1,a0,216
    80002390:	15850913          	addi	s2,a0,344
    80002394:	00a79b63          	bne	a5,a0,800023aa <kexit+0x3e>
    panic("init exiting");
    80002398:	00005517          	auipc	a0,0x5
    8000239c:	ef050513          	addi	a0,a0,-272 # 80007288 <etext+0x288>
    800023a0:	c84fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800023a4:	04a1                	addi	s1,s1,8
    800023a6:	01248963          	beq	s1,s2,800023b8 <kexit+0x4c>
    if(p->ofile[fd]){
    800023aa:	6088                	ld	a0,0(s1)
    800023ac:	dd65                	beqz	a0,800023a4 <kexit+0x38>
      fileclose(f);
    800023ae:	1e8020ef          	jal	80004596 <fileclose>
      p->ofile[fd] = 0;
    800023b2:	0004b023          	sd	zero,0(s1)
    800023b6:	b7fd                	j	800023a4 <kexit+0x38>
  begin_op();
    800023b8:	5bb010ef          	jal	80004172 <begin_op>
  iput(p->cwd);
    800023bc:	1589b503          	ld	a0,344(s3)
    800023c0:	528010ef          	jal	800038e8 <iput>
  end_op();
    800023c4:	61f010ef          	jal	800041e2 <end_op>
  p->cwd = 0;
    800023c8:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800023cc:	00010517          	auipc	a0,0x10
    800023d0:	2d450513          	addi	a0,a0,724 # 800126a0 <wait_lock>
    800023d4:	855fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800023d8:	854e                	mv	a0,s3
    800023da:	f3dff0ef          	jal	80002316 <reparent>
  wakeup(p->parent);
    800023de:	0409b503          	ld	a0,64(s3)
    800023e2:	ecbff0ef          	jal	800022ac <wakeup>
  acquire(&p->lock);
    800023e6:	854e                	mv	a0,s3
    800023e8:	841fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800023ec:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023f0:	4795                	li	a5,5
    800023f2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023f6:	00010517          	auipc	a0,0x10
    800023fa:	2aa50513          	addi	a0,a0,682 # 800126a0 <wait_lock>
    800023fe:	8bffe0ef          	jal	80000cbc <release>
  sched();
    80002402:	d77ff0ef          	jal	80002178 <sched>
  panic("zombie exit");
    80002406:	00005517          	auipc	a0,0x5
    8000240a:	e9250513          	addi	a0,a0,-366 # 80007298 <etext+0x298>
    8000240e:	c16fe0ef          	jal	80000824 <panic>

0000000080002412 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002412:	7179                	addi	sp,sp,-48
    80002414:	f406                	sd	ra,40(sp)
    80002416:	f022                	sd	s0,32(sp)
    80002418:	ec26                	sd	s1,24(sp)
    8000241a:	e84a                	sd	s2,16(sp)
    8000241c:	e44e                	sd	s3,8(sp)
    8000241e:	1800                	addi	s0,sp,48
    80002420:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002422:	00010497          	auipc	s1,0x10
    80002426:	69648493          	addi	s1,s1,1686 # 80012ab8 <proc>
    8000242a:	00016997          	auipc	s3,0x16
    8000242e:	28e98993          	addi	s3,s3,654 # 800186b8 <tickslock>
    acquire(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	ff4fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002438:	589c                	lw	a5,48(s1)
    8000243a:	01278b63          	beq	a5,s2,80002450 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	87dfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002444:	17048493          	addi	s1,s1,368
    80002448:	ff3495e3          	bne	s1,s3,80002432 <kkill+0x20>
  }
  return -1;
    8000244c:	557d                	li	a0,-1
    8000244e:	a819                	j	80002464 <kkill+0x52>
      p->killed = 1;
    80002450:	4785                	li	a5,1
    80002452:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002454:	4c98                	lw	a4,24(s1)
    80002456:	4789                	li	a5,2
    80002458:	00f70d63          	beq	a4,a5,80002472 <kkill+0x60>
      release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	85ffe0ef          	jal	80000cbc <release>
      return 0;
    80002462:	4501                	li	a0,0
}
    80002464:	70a2                	ld	ra,40(sp)
    80002466:	7402                	ld	s0,32(sp)
    80002468:	64e2                	ld	s1,24(sp)
    8000246a:	6942                	ld	s2,16(sp)
    8000246c:	69a2                	ld	s3,8(sp)
    8000246e:	6145                	addi	sp,sp,48
    80002470:	8082                	ret
        p->state = RUNNABLE;
    80002472:	478d                	li	a5,3
    80002474:	cc9c                	sw	a5,24(s1)
    80002476:	b7dd                	j	8000245c <kkill+0x4a>

0000000080002478 <setkilled>:

void
setkilled(struct proc *p)
{
    80002478:	1101                	addi	sp,sp,-32
    8000247a:	ec06                	sd	ra,24(sp)
    8000247c:	e822                	sd	s0,16(sp)
    8000247e:	e426                	sd	s1,8(sp)
    80002480:	1000                	addi	s0,sp,32
    80002482:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002484:	fa4fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002488:	4785                	li	a5,1
    8000248a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000248c:	8526                	mv	a0,s1
    8000248e:	82ffe0ef          	jal	80000cbc <release>
}
    80002492:	60e2                	ld	ra,24(sp)
    80002494:	6442                	ld	s0,16(sp)
    80002496:	64a2                	ld	s1,8(sp)
    80002498:	6105                	addi	sp,sp,32
    8000249a:	8082                	ret

000000008000249c <killed>:

int
killed(struct proc *p)
{
    8000249c:	1101                	addi	sp,sp,-32
    8000249e:	ec06                	sd	ra,24(sp)
    800024a0:	e822                	sd	s0,16(sp)
    800024a2:	e426                	sd	s1,8(sp)
    800024a4:	e04a                	sd	s2,0(sp)
    800024a6:	1000                	addi	s0,sp,32
    800024a8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800024aa:	f7efe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800024ae:	549c                	lw	a5,40(s1)
    800024b0:	893e                	mv	s2,a5
  release(&p->lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	809fe0ef          	jal	80000cbc <release>
  return k;
}
    800024b8:	854a                	mv	a0,s2
    800024ba:	60e2                	ld	ra,24(sp)
    800024bc:	6442                	ld	s0,16(sp)
    800024be:	64a2                	ld	s1,8(sp)
    800024c0:	6902                	ld	s2,0(sp)
    800024c2:	6105                	addi	sp,sp,32
    800024c4:	8082                	ret

00000000800024c6 <kwait>:
{
    800024c6:	715d                	addi	sp,sp,-80
    800024c8:	e486                	sd	ra,72(sp)
    800024ca:	e0a2                	sd	s0,64(sp)
    800024cc:	fc26                	sd	s1,56(sp)
    800024ce:	f84a                	sd	s2,48(sp)
    800024d0:	f44e                	sd	s3,40(sp)
    800024d2:	f052                	sd	s4,32(sp)
    800024d4:	ec56                	sd	s5,24(sp)
    800024d6:	e85a                	sd	s6,16(sp)
    800024d8:	e45e                	sd	s7,8(sp)
    800024da:	0880                	addi	s0,sp,80
    800024dc:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800024de:	cceff0ef          	jal	800019ac <myproc>
    800024e2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024e4:	00010517          	auipc	a0,0x10
    800024e8:	1bc50513          	addi	a0,a0,444 # 800126a0 <wait_lock>
    800024ec:	f3cfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800024f0:	4a15                	li	s4,5
        havekids = 1;
    800024f2:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024f4:	00016997          	auipc	s3,0x16
    800024f8:	1c498993          	addi	s3,s3,452 # 800186b8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024fc:	00010b17          	auipc	s6,0x10
    80002500:	1a4b0b13          	addi	s6,s6,420 # 800126a0 <wait_lock>
    80002504:	a869                	j	8000259e <kwait+0xd8>
          pid = pp->pid;
    80002506:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000250a:	000b8c63          	beqz	s7,80002522 <kwait+0x5c>
    8000250e:	4691                	li	a3,4
    80002510:	02c48613          	addi	a2,s1,44
    80002514:	85de                	mv	a1,s7
    80002516:	05893503          	ld	a0,88(s2)
    8000251a:	93aff0ef          	jal	80001654 <copyout>
    8000251e:	02054a63          	bltz	a0,80002552 <kwait+0x8c>
          freeproc(pp);
    80002522:	8526                	mv	a0,s1
    80002524:	e5cff0ef          	jal	80001b80 <freeproc>
          release(&pp->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	f92fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    8000252e:	00010517          	auipc	a0,0x10
    80002532:	17250513          	addi	a0,a0,370 # 800126a0 <wait_lock>
    80002536:	f86fe0ef          	jal	80000cbc <release>
}
    8000253a:	854e                	mv	a0,s3
    8000253c:	60a6                	ld	ra,72(sp)
    8000253e:	6406                	ld	s0,64(sp)
    80002540:	74e2                	ld	s1,56(sp)
    80002542:	7942                	ld	s2,48(sp)
    80002544:	79a2                	ld	s3,40(sp)
    80002546:	7a02                	ld	s4,32(sp)
    80002548:	6ae2                	ld	s5,24(sp)
    8000254a:	6b42                	ld	s6,16(sp)
    8000254c:	6ba2                	ld	s7,8(sp)
    8000254e:	6161                	addi	sp,sp,80
    80002550:	8082                	ret
            release(&pp->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	f68fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002558:	00010517          	auipc	a0,0x10
    8000255c:	14850513          	addi	a0,a0,328 # 800126a0 <wait_lock>
    80002560:	f5cfe0ef          	jal	80000cbc <release>
            return -1;
    80002564:	59fd                	li	s3,-1
    80002566:	bfd1                	j	8000253a <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002568:	17048493          	addi	s1,s1,368
    8000256c:	03348063          	beq	s1,s3,8000258c <kwait+0xc6>
      if(pp->parent == p){
    80002570:	60bc                	ld	a5,64(s1)
    80002572:	ff279be3          	bne	a5,s2,80002568 <kwait+0xa2>
        acquire(&pp->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	eb0fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000257c:	4c9c                	lw	a5,24(s1)
    8000257e:	f94784e3          	beq	a5,s4,80002506 <kwait+0x40>
        release(&pp->lock);
    80002582:	8526                	mv	a0,s1
    80002584:	f38fe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002588:	8756                	mv	a4,s5
    8000258a:	bff9                	j	80002568 <kwait+0xa2>
    if(!havekids || killed(p)){
    8000258c:	cf19                	beqz	a4,800025aa <kwait+0xe4>
    8000258e:	854a                	mv	a0,s2
    80002590:	f0dff0ef          	jal	8000249c <killed>
    80002594:	e919                	bnez	a0,800025aa <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002596:	85da                	mv	a1,s6
    80002598:	854a                	mv	a0,s2
    8000259a:	cc7ff0ef          	jal	80002260 <sleep>
    havekids = 0;
    8000259e:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025a0:	00010497          	auipc	s1,0x10
    800025a4:	51848493          	addi	s1,s1,1304 # 80012ab8 <proc>
    800025a8:	b7e1                	j	80002570 <kwait+0xaa>
      release(&wait_lock);
    800025aa:	00010517          	auipc	a0,0x10
    800025ae:	0f650513          	addi	a0,a0,246 # 800126a0 <wait_lock>
    800025b2:	f0afe0ef          	jal	80000cbc <release>
      return -1;
    800025b6:	59fd                	li	s3,-1
    800025b8:	b749                	j	8000253a <kwait+0x74>

00000000800025ba <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025ba:	7179                	addi	sp,sp,-48
    800025bc:	f406                	sd	ra,40(sp)
    800025be:	f022                	sd	s0,32(sp)
    800025c0:	ec26                	sd	s1,24(sp)
    800025c2:	e84a                	sd	s2,16(sp)
    800025c4:	e44e                	sd	s3,8(sp)
    800025c6:	e052                	sd	s4,0(sp)
    800025c8:	1800                	addi	s0,sp,48
    800025ca:	84aa                	mv	s1,a0
    800025cc:	8a2e                	mv	s4,a1
    800025ce:	89b2                	mv	s3,a2
    800025d0:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800025d2:	bdaff0ef          	jal	800019ac <myproc>
  if(user_dst){
    800025d6:	cc99                	beqz	s1,800025f4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800025d8:	86ca                	mv	a3,s2
    800025da:	864e                	mv	a2,s3
    800025dc:	85d2                	mv	a1,s4
    800025de:	6d28                	ld	a0,88(a0)
    800025e0:	874ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025e4:	70a2                	ld	ra,40(sp)
    800025e6:	7402                	ld	s0,32(sp)
    800025e8:	64e2                	ld	s1,24(sp)
    800025ea:	6942                	ld	s2,16(sp)
    800025ec:	69a2                	ld	s3,8(sp)
    800025ee:	6a02                	ld	s4,0(sp)
    800025f0:	6145                	addi	sp,sp,48
    800025f2:	8082                	ret
    memmove((char *)dst, src, len);
    800025f4:	0009061b          	sext.w	a2,s2
    800025f8:	85ce                	mv	a1,s3
    800025fa:	8552                	mv	a0,s4
    800025fc:	f5cfe0ef          	jal	80000d58 <memmove>
    return 0;
    80002600:	8526                	mv	a0,s1
    80002602:	b7cd                	j	800025e4 <either_copyout+0x2a>

0000000080002604 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002604:	7179                	addi	sp,sp,-48
    80002606:	f406                	sd	ra,40(sp)
    80002608:	f022                	sd	s0,32(sp)
    8000260a:	ec26                	sd	s1,24(sp)
    8000260c:	e84a                	sd	s2,16(sp)
    8000260e:	e44e                	sd	s3,8(sp)
    80002610:	e052                	sd	s4,0(sp)
    80002612:	1800                	addi	s0,sp,48
    80002614:	8a2a                	mv	s4,a0
    80002616:	84ae                	mv	s1,a1
    80002618:	89b2                	mv	s3,a2
    8000261a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000261c:	b90ff0ef          	jal	800019ac <myproc>
  if(user_src){
    80002620:	cc99                	beqz	s1,8000263e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002622:	86ca                	mv	a3,s2
    80002624:	864e                	mv	a2,s3
    80002626:	85d2                	mv	a1,s4
    80002628:	6d28                	ld	a0,88(a0)
    8000262a:	8e8ff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000262e:	70a2                	ld	ra,40(sp)
    80002630:	7402                	ld	s0,32(sp)
    80002632:	64e2                	ld	s1,24(sp)
    80002634:	6942                	ld	s2,16(sp)
    80002636:	69a2                	ld	s3,8(sp)
    80002638:	6a02                	ld	s4,0(sp)
    8000263a:	6145                	addi	sp,sp,48
    8000263c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000263e:	0009061b          	sext.w	a2,s2
    80002642:	85ce                	mv	a1,s3
    80002644:	8552                	mv	a0,s4
    80002646:	f12fe0ef          	jal	80000d58 <memmove>
    return 0;
    8000264a:	8526                	mv	a0,s1
    8000264c:	b7cd                	j	8000262e <either_copyin+0x2a>

000000008000264e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000264e:	715d                	addi	sp,sp,-80
    80002650:	e486                	sd	ra,72(sp)
    80002652:	e0a2                	sd	s0,64(sp)
    80002654:	fc26                	sd	s1,56(sp)
    80002656:	f84a                	sd	s2,48(sp)
    80002658:	f44e                	sd	s3,40(sp)
    8000265a:	f052                	sd	s4,32(sp)
    8000265c:	ec56                	sd	s5,24(sp)
    8000265e:	e85a                	sd	s6,16(sp)
    80002660:	e45e                	sd	s7,8(sp)
    80002662:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002664:	00005517          	auipc	a0,0x5
    80002668:	a1450513          	addi	a0,a0,-1516 # 80007078 <etext+0x78>
    8000266c:	e8ffd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002670:	00010497          	auipc	s1,0x10
    80002674:	5a848493          	addi	s1,s1,1448 # 80012c18 <proc+0x160>
    80002678:	00016917          	auipc	s2,0x16
    8000267c:	1a090913          	addi	s2,s2,416 # 80018818 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002680:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002682:	00005997          	auipc	s3,0x5
    80002686:	c2698993          	addi	s3,s3,-986 # 800072a8 <etext+0x2a8>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    8000268a:	00005a97          	auipc	s5,0x5
    8000268e:	c26a8a93          	addi	s5,s5,-986 # 800072b0 <etext+0x2b0>
    printf("\n");
    80002692:	00005a17          	auipc	s4,0x5
    80002696:	9e6a0a13          	addi	s4,s4,-1562 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269a:	00005b97          	auipc	s7,0x5
    8000269e:	2a6b8b93          	addi	s7,s7,678 # 80007940 <states.1>
    800026a2:	a839                	j	800026c0 <procdump+0x72>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    800026a4:	ed86a703          	lw	a4,-296(a3)
    800026a8:	ed06a583          	lw	a1,-304(a3)
    800026ac:	8556                	mv	a0,s5
    800026ae:	e4dfd0ef          	jal	800004fa <printf>
    printf("\n");
    800026b2:	8552                	mv	a0,s4
    800026b4:	e47fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026b8:	17048493          	addi	s1,s1,368
    800026bc:	03248263          	beq	s1,s2,800026e0 <procdump+0x92>
    if(p->state == UNUSED)
    800026c0:	86a6                	mv	a3,s1
    800026c2:	eb84a783          	lw	a5,-328(s1)
    800026c6:	dbed                	beqz	a5,800026b8 <procdump+0x6a>
      state = "???";
    800026c8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ca:	fcfb6de3          	bltu	s6,a5,800026a4 <procdump+0x56>
    800026ce:	02079713          	slli	a4,a5,0x20
    800026d2:	01d75793          	srli	a5,a4,0x1d
    800026d6:	97de                	add	a5,a5,s7
    800026d8:	6390                	ld	a2,0(a5)
    800026da:	f669                	bnez	a2,800026a4 <procdump+0x56>
      state = "???";
    800026dc:	864e                	mv	a2,s3
    800026de:	b7d9                	j	800026a4 <procdump+0x56>
  }
}
    800026e0:	60a6                	ld	ra,72(sp)
    800026e2:	6406                	ld	s0,64(sp)
    800026e4:	74e2                	ld	s1,56(sp)
    800026e6:	7942                	ld	s2,48(sp)
    800026e8:	79a2                	ld	s3,40(sp)
    800026ea:	7a02                	ld	s4,32(sp)
    800026ec:	6ae2                	ld	s5,24(sp)
    800026ee:	6b42                	ld	s6,16(sp)
    800026f0:	6ba2                	ld	s7,8(sp)
    800026f2:	6161                	addi	sp,sp,80
    800026f4:	8082                	ret

00000000800026f6 <kps>:


int
kps(char *arguments)
{
    800026f6:	7179                	addi	sp,sp,-48
    800026f8:	f406                	sd	ra,40(sp)
    800026fa:	f022                	sd	s0,32(sp)
    800026fc:	ec26                	sd	s1,24(sp)
    800026fe:	1800                	addi	s0,sp,48
    80002700:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    80002702:	4609                	li	a2,2
    80002704:	00005597          	auipc	a1,0x5
    80002708:	bc458593          	addi	a1,a1,-1084 # 800072c8 <etext+0x2c8>
    8000270c:	ec0fe0ef          	jal	80000dcc <strncmp>
    80002710:	e931                	bnez	a0,80002764 <kps+0x6e>
    80002712:	e84a                	sd	s2,16(sp)
    80002714:	e44e                	sd	s3,8(sp)
    80002716:	00010497          	auipc	s1,0x10
    8000271a:	50248493          	addi	s1,s1,1282 # 80012c18 <proc+0x160>
    8000271e:	00016917          	auipc	s2,0x16
    80002722:	0fa90913          	addi	s2,s2,250 # 80018818 <bcache+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    80002726:	00005997          	auipc	s3,0x5
    8000272a:	baa98993          	addi	s3,s3,-1110 # 800072d0 <etext+0x2d0>
    8000272e:	a029                	j	80002738 <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    80002730:	17048493          	addi	s1,s1,368
    80002734:	01248a63          	beq	s1,s2,80002748 <kps+0x52>
      if (p->state != UNUSED){
    80002738:	eb84a783          	lw	a5,-328(s1)
    8000273c:	dbf5                	beqz	a5,80002730 <kps+0x3a>
        printf("%s ", p->name);
    8000273e:	85a6                	mv	a1,s1
    80002740:	854e                	mv	a0,s3
    80002742:	db9fd0ef          	jal	800004fa <printf>
    80002746:	b7ed                	j	80002730 <kps+0x3a>
      }
    }
    printf("\n");
    80002748:	00005517          	auipc	a0,0x5
    8000274c:	93050513          	addi	a0,a0,-1744 # 80007078 <etext+0x78>
    80002750:	dabfd0ef          	jal	800004fa <printf>
    80002754:	6942                	ld	s2,16(sp)
    80002756:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l | -t]\n");
  }

  return 0;

    80002758:	4501                	li	a0,0
    8000275a:	70a2                	ld	ra,40(sp)
    8000275c:	7402                	ld	s0,32(sp)
    8000275e:	64e2                	ld	s1,24(sp)
    80002760:	6145                	addi	sp,sp,48
    80002762:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    80002764:	4609                	li	a2,2
    80002766:	00005597          	auipc	a1,0x5
    8000276a:	b7258593          	addi	a1,a1,-1166 # 800072d8 <etext+0x2d8>
    8000276e:	8526                	mv	a0,s1
    80002770:	e5cfe0ef          	jal	80000dcc <strncmp>
    80002774:	e92d                	bnez	a0,800027e6 <kps+0xf0>
    80002776:	e84a                	sd	s2,16(sp)
    80002778:	e44e                	sd	s3,8(sp)
    8000277a:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    8000277c:	00005517          	auipc	a0,0x5
    80002780:	b6450513          	addi	a0,a0,-1180 # 800072e0 <etext+0x2e0>
    80002784:	d77fd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    80002788:	00005517          	auipc	a0,0x5
    8000278c:	c1850513          	addi	a0,a0,-1000 # 800073a0 <etext+0x3a0>
    80002790:	d6bfd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002794:	00010497          	auipc	s1,0x10
    80002798:	48448493          	addi	s1,s1,1156 # 80012c18 <proc+0x160>
    8000279c:	00016917          	auipc	s2,0x16
    800027a0:	07c90913          	addi	s2,s2,124 # 80018818 <bcache+0x148>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    800027a4:	00005a17          	auipc	s4,0x5
    800027a8:	19ca0a13          	addi	s4,s4,412 # 80007940 <states.1>
    800027ac:	00005997          	auipc	s3,0x5
    800027b0:	b4c98993          	addi	s3,s3,-1204 # 800072f8 <etext+0x2f8>
    800027b4:	a029                	j	800027be <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    800027b6:	17048493          	addi	s1,s1,368
    800027ba:	03248263          	beq	s1,s2,800027de <kps+0xe8>
      if (p->state != UNUSED){
    800027be:	eb84a783          	lw	a5,-328(s1)
    800027c2:	dbf5                	beqz	a5,800027b6 <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    800027c4:	02079713          	slli	a4,a5,0x20
    800027c8:	01d75793          	srli	a5,a4,0x1d
    800027cc:	97d2                	add	a5,a5,s4
    800027ce:	86a6                	mv	a3,s1
    800027d0:	7b90                	ld	a2,48(a5)
    800027d2:	ed04a583          	lw	a1,-304(s1)
    800027d6:	854e                	mv	a0,s3
    800027d8:	d23fd0ef          	jal	800004fa <printf>
    800027dc:	bfe9                	j	800027b6 <kps+0xc0>
    800027de:	6942                	ld	s2,16(sp)
    800027e0:	69a2                	ld	s3,8(sp)
    800027e2:	6a02                	ld	s4,0(sp)
    800027e4:	bf95                	j	80002758 <kps+0x62>
  }else if(strncmp(arguments, "-t", 2)==0){
    800027e6:	4609                	li	a2,2
    800027e8:	00005597          	auipc	a1,0x5
    800027ec:	b2058593          	addi	a1,a1,-1248 # 80007308 <etext+0x308>
    800027f0:	8526                	mv	a0,s1
    800027f2:	ddafe0ef          	jal	80000dcc <strncmp>
    800027f6:	e969                	bnez	a0,800028c8 <kps+0x1d2>
    800027f8:	e84a                	sd	s2,16(sp)
    800027fa:	e44e                	sd	s3,8(sp)
    800027fc:	e052                	sd	s4,0(sp)
    printf("===== Thermal Monitor =====\n");
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	b1250513          	addi	a0,a0,-1262 # 80007310 <etext+0x310>
    80002806:	cf5fd0ef          	jal	800004fa <printf>
    printf("CPU Temperature: %d / 100", cpu_temp);
    8000280a:	00008497          	auipc	s1,0x8
    8000280e:	d1a48493          	addi	s1,s1,-742 # 8000a524 <cpu_temp>
    80002812:	408c                	lw	a1,0(s1)
    80002814:	00005517          	auipc	a0,0x5
    80002818:	b1c50513          	addi	a0,a0,-1252 # 80007330 <etext+0x330>
    8000281c:	cdffd0ef          	jal	800004fa <printf>
    if(cpu_temp >= 80)
    80002820:	409c                	lw	a5,0(s1)
    80002822:	04f00713          	li	a4,79
    80002826:	04f74963          	blt	a4,a5,80002878 <kps+0x182>
    else if(cpu_temp >= 60)
    8000282a:	03b00713          	li	a4,59
    8000282e:	04f75c63          	bge	a4,a5,80002886 <kps+0x190>
      printf("  [WARM]\n");
    80002832:	00005517          	auipc	a0,0x5
    80002836:	b2e50513          	addi	a0,a0,-1234 # 80007360 <etext+0x360>
    8000283a:	cc1fd0ef          	jal	800004fa <printf>
    printf("\nPID\tSTATE\t\tHEAT\tNAME\n");
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	b4250513          	addi	a0,a0,-1214 # 80007380 <etext+0x380>
    80002846:	cb5fd0ef          	jal	800004fa <printf>
    printf("---------------------------------------\n");
    8000284a:	00005517          	auipc	a0,0x5
    8000284e:	b4e50513          	addi	a0,a0,-1202 # 80007398 <etext+0x398>
    80002852:	ca9fd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002856:	00010497          	auipc	s1,0x10
    8000285a:	3c248493          	addi	s1,s1,962 # 80012c18 <proc+0x160>
    8000285e:	00016917          	auipc	s2,0x16
    80002862:	fba90913          	addi	s2,s2,-70 # 80018818 <bcache+0x148>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002866:	00005a17          	auipc	s4,0x5
    8000286a:	0daa0a13          	addi	s4,s4,218 # 80007940 <states.1>
    8000286e:	00005997          	auipc	s3,0x5
    80002872:	b5a98993          	addi	s3,s3,-1190 # 800073c8 <etext+0x3c8>
    80002876:	a01d                	j	8000289c <kps+0x1a6>
      printf("  [HOT]\n");
    80002878:	00005517          	auipc	a0,0x5
    8000287c:	ad850513          	addi	a0,a0,-1320 # 80007350 <etext+0x350>
    80002880:	c7bfd0ef          	jal	800004fa <printf>
    80002884:	bf6d                	j	8000283e <kps+0x148>
      printf("  [COOL]\n");
    80002886:	00005517          	auipc	a0,0x5
    8000288a:	aea50513          	addi	a0,a0,-1302 # 80007370 <etext+0x370>
    8000288e:	c6dfd0ef          	jal	800004fa <printf>
    80002892:	b775                	j	8000283e <kps+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
    80002894:	17048493          	addi	s1,s1,368
    80002898:	03248463          	beq	s1,s2,800028c0 <kps+0x1ca>
      if (p->state != UNUSED){
    8000289c:	eb84a783          	lw	a5,-328(s1)
    800028a0:	dbf5                	beqz	a5,80002894 <kps+0x19e>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    800028a2:	02079713          	slli	a4,a5,0x20
    800028a6:	01d75793          	srli	a5,a4,0x1d
    800028aa:	97d2                	add	a5,a5,s4
    800028ac:	8726                	mv	a4,s1
    800028ae:	ed84a683          	lw	a3,-296(s1)
    800028b2:	7b90                	ld	a2,48(a5)
    800028b4:	ed04a583          	lw	a1,-304(s1)
    800028b8:	854e                	mv	a0,s3
    800028ba:	c41fd0ef          	jal	800004fa <printf>
    800028be:	bfd9                	j	80002894 <kps+0x19e>
    800028c0:	6942                	ld	s2,16(sp)
    800028c2:	69a2                	ld	s3,8(sp)
    800028c4:	6a02                	ld	s4,0(sp)
    800028c6:	bd49                	j	80002758 <kps+0x62>
    printf("Usage: ps [-o | -l | -t]\n");
    800028c8:	00005517          	auipc	a0,0x5
    800028cc:	b1050513          	addi	a0,a0,-1264 # 800073d8 <etext+0x3d8>
    800028d0:	c2bfd0ef          	jal	800004fa <printf>
    800028d4:	b551                	j	80002758 <kps+0x62>

00000000800028d6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800028d6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800028da:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800028de:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800028e0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800028e2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800028e6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800028ea:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800028ee:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800028f2:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800028f6:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800028fa:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800028fe:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002902:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002906:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000290a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000290e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002912:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002914:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002916:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000291a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000291e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002922:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002926:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000292a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000292e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002932:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002936:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000293a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000293e:	8082                	ret

0000000080002940 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002940:	1141                	addi	sp,sp,-16
    80002942:	e406                	sd	ra,8(sp)
    80002944:	e022                	sd	s0,0(sp)
    80002946:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002948:	00005597          	auipc	a1,0x5
    8000294c:	b2058593          	addi	a1,a1,-1248 # 80007468 <etext+0x468>
    80002950:	00016517          	auipc	a0,0x16
    80002954:	d6850513          	addi	a0,a0,-664 # 800186b8 <tickslock>
    80002958:	a46fe0ef          	jal	80000b9e <initlock>
}
    8000295c:	60a2                	ld	ra,8(sp)
    8000295e:	6402                	ld	s0,0(sp)
    80002960:	0141                	addi	sp,sp,16
    80002962:	8082                	ret

0000000080002964 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002964:	1141                	addi	sp,sp,-16
    80002966:	e406                	sd	ra,8(sp)
    80002968:	e022                	sd	s0,0(sp)
    8000296a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000296c:	00003797          	auipc	a5,0x3
    80002970:	03478793          	addi	a5,a5,52 # 800059a0 <kernelvec>
    80002974:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002978:	60a2                	ld	ra,8(sp)
    8000297a:	6402                	ld	s0,0(sp)
    8000297c:	0141                	addi	sp,sp,16
    8000297e:	8082                	ret

0000000080002980 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002980:	1141                	addi	sp,sp,-16
    80002982:	e406                	sd	ra,8(sp)
    80002984:	e022                	sd	s0,0(sp)
    80002986:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002988:	824ff0ef          	jal	800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000298c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002990:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002992:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002996:	04000737          	lui	a4,0x4000
    8000299a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000299c:	0732                	slli	a4,a4,0xc
    8000299e:	00003797          	auipc	a5,0x3
    800029a2:	66278793          	addi	a5,a5,1634 # 80006000 <_trampoline>
    800029a6:	00003697          	auipc	a3,0x3
    800029aa:	65a68693          	addi	a3,a3,1626 # 80006000 <_trampoline>
    800029ae:	8f95                	sub	a5,a5,a3
    800029b0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029b2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029b6:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029b8:	18002773          	csrr	a4,satp
    800029bc:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029be:	7138                	ld	a4,96(a0)
    800029c0:	653c                	ld	a5,72(a0)
    800029c2:	6685                	lui	a3,0x1
    800029c4:	97b6                	add	a5,a5,a3
    800029c6:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029c8:	713c                	ld	a5,96(a0)
    800029ca:	00000717          	auipc	a4,0x0
    800029ce:	11c70713          	addi	a4,a4,284 # 80002ae6 <usertrap>
    800029d2:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029d4:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029d6:	8712                	mv	a4,tp
    800029d8:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029da:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029de:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029e2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e6:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029ea:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ec:	6f9c                	ld	a5,24(a5)
    800029ee:	14179073          	csrw	sepc,a5
}
    800029f2:	60a2                	ld	ra,8(sp)
    800029f4:	6402                	ld	s0,0(sp)
    800029f6:	0141                	addi	sp,sp,16
    800029f8:	8082                	ret

00000000800029fa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029fa:	1141                	addi	sp,sp,-16
    800029fc:	e406                	sd	ra,8(sp)
    800029fe:	e022                	sd	s0,0(sp)
    80002a00:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002a02:	f77fe0ef          	jal	80001978 <cpuid>
    80002a06:	c915                	beqz	a0,80002a3a <clockintr+0x40>
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  if (myproc() != 0 && myproc()->state == RUNNING) {
    80002a08:	fa5fe0ef          	jal	800019ac <myproc>
    80002a0c:	c519                	beqz	a0,80002a1a <clockintr+0x20>
    80002a0e:	f9ffe0ef          	jal	800019ac <myproc>
    80002a12:	4d18                	lw	a4,24(a0)
    80002a14:	4791                	li	a5,4
    80002a16:	04f70963          	beq	a4,a5,80002a68 <clockintr+0x6e>
    update_cpu_temp(1);   // CPU is active
  } else {
    update_cpu_temp(0);   // CPU is idle
    80002a1a:	4501                	li	a0,0
    80002a1c:	d85fe0ef          	jal	800017a0 <update_cpu_temp>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a20:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a24:	000f4737          	lui	a4,0xf4
    80002a28:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a2c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a2e:	14d79073          	csrw	stimecmp,a5
}
    80002a32:	60a2                	ld	ra,8(sp)
    80002a34:	6402                	ld	s0,0(sp)
    80002a36:	0141                	addi	sp,sp,16
    80002a38:	8082                	ret
    acquire(&tickslock);
    80002a3a:	00016517          	auipc	a0,0x16
    80002a3e:	c7e50513          	addi	a0,a0,-898 # 800186b8 <tickslock>
    80002a42:	9e6fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002a46:	00008717          	auipc	a4,0x8
    80002a4a:	b3a70713          	addi	a4,a4,-1222 # 8000a580 <ticks>
    80002a4e:	431c                	lw	a5,0(a4)
    80002a50:	2785                	addiw	a5,a5,1
    80002a52:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002a54:	853a                	mv	a0,a4
    80002a56:	857ff0ef          	jal	800022ac <wakeup>
    release(&tickslock);
    80002a5a:	00016517          	auipc	a0,0x16
    80002a5e:	c5e50513          	addi	a0,a0,-930 # 800186b8 <tickslock>
    80002a62:	a5afe0ef          	jal	80000cbc <release>
    80002a66:	b74d                	j	80002a08 <clockintr+0xe>
    update_cpu_temp(1);   // CPU is active
    80002a68:	4505                	li	a0,1
    80002a6a:	d37fe0ef          	jal	800017a0 <update_cpu_temp>
    80002a6e:	bf4d                	j	80002a20 <clockintr+0x26>

0000000080002a70 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a70:	1101                	addi	sp,sp,-32
    80002a72:	ec06                	sd	ra,24(sp)
    80002a74:	e822                	sd	s0,16(sp)
    80002a76:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a78:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a7c:	57fd                	li	a5,-1
    80002a7e:	17fe                	slli	a5,a5,0x3f
    80002a80:	07a5                	addi	a5,a5,9
    80002a82:	00f70c63          	beq	a4,a5,80002a9a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a86:	57fd                	li	a5,-1
    80002a88:	17fe                	slli	a5,a5,0x3f
    80002a8a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a8c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a8e:	04f70863          	beq	a4,a5,80002ade <devintr+0x6e>
  }
}
    80002a92:	60e2                	ld	ra,24(sp)
    80002a94:	6442                	ld	s0,16(sp)
    80002a96:	6105                	addi	sp,sp,32
    80002a98:	8082                	ret
    80002a9a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a9c:	7b1020ef          	jal	80005a4c <plic_claim>
    80002aa0:	872a                	mv	a4,a0
    80002aa2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aa4:	47a9                	li	a5,10
    80002aa6:	00f50963          	beq	a0,a5,80002ab8 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002aaa:	4785                	li	a5,1
    80002aac:	00f50963          	beq	a0,a5,80002abe <devintr+0x4e>
    return 1;
    80002ab0:	4505                	li	a0,1
    } else if(irq){
    80002ab2:	eb09                	bnez	a4,80002ac4 <devintr+0x54>
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	bff1                	j	80002a92 <devintr+0x22>
      uartintr();
    80002ab8:	f3dfd0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002abc:	a819                	j	80002ad2 <devintr+0x62>
      virtio_disk_intr();
    80002abe:	424030ef          	jal	80005ee2 <virtio_disk_intr>
    if(irq)
    80002ac2:	a801                	j	80002ad2 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ac4:	85ba                	mv	a1,a4
    80002ac6:	00005517          	auipc	a0,0x5
    80002aca:	9aa50513          	addi	a0,a0,-1622 # 80007470 <etext+0x470>
    80002ace:	a2dfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002ad2:	8526                	mv	a0,s1
    80002ad4:	799020ef          	jal	80005a6c <plic_complete>
    return 1;
    80002ad8:	4505                	li	a0,1
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	bf5d                	j	80002a92 <devintr+0x22>
    clockintr();
    80002ade:	f1dff0ef          	jal	800029fa <clockintr>
    return 2;
    80002ae2:	4509                	li	a0,2
    80002ae4:	b77d                	j	80002a92 <devintr+0x22>

0000000080002ae6 <usertrap>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002af6:	1007f793          	andi	a5,a5,256
    80002afa:	eba5                	bnez	a5,80002b6a <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002afc:	00003797          	auipc	a5,0x3
    80002b00:	ea478793          	addi	a5,a5,-348 # 800059a0 <kernelvec>
    80002b04:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b08:	ea5fe0ef          	jal	800019ac <myproc>
    80002b0c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b0e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b10:	14102773          	csrr	a4,sepc
    80002b14:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b16:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b1a:	47a1                	li	a5,8
    80002b1c:	04f70d63          	beq	a4,a5,80002b76 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002b20:	f51ff0ef          	jal	80002a70 <devintr>
    80002b24:	892a                	mv	s2,a0
    80002b26:	e945                	bnez	a0,80002bd6 <usertrap+0xf0>
    80002b28:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b2c:	47bd                	li	a5,15
    80002b2e:	08f70863          	beq	a4,a5,80002bbe <usertrap+0xd8>
    80002b32:	14202773          	csrr	a4,scause
    80002b36:	47b5                	li	a5,13
    80002b38:	08f70363          	beq	a4,a5,80002bbe <usertrap+0xd8>
    80002b3c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b40:	5890                	lw	a2,48(s1)
    80002b42:	00005517          	auipc	a0,0x5
    80002b46:	96e50513          	addi	a0,a0,-1682 # 800074b0 <etext+0x4b0>
    80002b4a:	9b1fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b52:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b56:	00005517          	auipc	a0,0x5
    80002b5a:	98a50513          	addi	a0,a0,-1654 # 800074e0 <etext+0x4e0>
    80002b5e:	99dfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002b62:	8526                	mv	a0,s1
    80002b64:	915ff0ef          	jal	80002478 <setkilled>
    80002b68:	a035                	j	80002b94 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002b6a:	00005517          	auipc	a0,0x5
    80002b6e:	92650513          	addi	a0,a0,-1754 # 80007490 <etext+0x490>
    80002b72:	cb3fd0ef          	jal	80000824 <panic>
    if(killed(p))
    80002b76:	927ff0ef          	jal	8000249c <killed>
    80002b7a:	ed15                	bnez	a0,80002bb6 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b7c:	70b8                	ld	a4,96(s1)
    80002b7e:	6f1c                	ld	a5,24(a4)
    80002b80:	0791                	addi	a5,a5,4
    80002b82:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b8c:	10079073          	csrw	sstatus,a5
    syscall();
    80002b90:	240000ef          	jal	80002dd0 <syscall>
  if(killed(p))
    80002b94:	8526                	mv	a0,s1
    80002b96:	907ff0ef          	jal	8000249c <killed>
    80002b9a:	e139                	bnez	a0,80002be0 <usertrap+0xfa>
  prepare_return();
    80002b9c:	de5ff0ef          	jal	80002980 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ba0:	6ca8                	ld	a0,88(s1)
    80002ba2:	8131                	srli	a0,a0,0xc
    80002ba4:	57fd                	li	a5,-1
    80002ba6:	17fe                	slli	a5,a5,0x3f
    80002ba8:	8d5d                	or	a0,a0,a5
}
    80002baa:	60e2                	ld	ra,24(sp)
    80002bac:	6442                	ld	s0,16(sp)
    80002bae:	64a2                	ld	s1,8(sp)
    80002bb0:	6902                	ld	s2,0(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret
      kexit(-1);
    80002bb6:	557d                	li	a0,-1
    80002bb8:	fb4ff0ef          	jal	8000236c <kexit>
    80002bbc:	b7c1                	j	80002b7c <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bbe:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc2:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002bc6:	164d                	addi	a2,a2,-13
    80002bc8:	00163613          	seqz	a2,a2
    80002bcc:	6ca8                	ld	a0,88(s1)
    80002bce:	a03fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002bd2:	f169                	bnez	a0,80002b94 <usertrap+0xae>
    80002bd4:	b7a5                	j	80002b3c <usertrap+0x56>
  if(killed(p))
    80002bd6:	8526                	mv	a0,s1
    80002bd8:	8c5ff0ef          	jal	8000249c <killed>
    80002bdc:	c511                	beqz	a0,80002be8 <usertrap+0x102>
    80002bde:	a011                	j	80002be2 <usertrap+0xfc>
    80002be0:	4901                	li	s2,0
    kexit(-1);
    80002be2:	557d                	li	a0,-1
    80002be4:	f88ff0ef          	jal	8000236c <kexit>
  if(which_dev == 2)
    80002be8:	4789                	li	a5,2
    80002bea:	faf919e3          	bne	s2,a5,80002b9c <usertrap+0xb6>
    yield();
    80002bee:	e46ff0ef          	jal	80002234 <yield>
    80002bf2:	b76d                	j	80002b9c <usertrap+0xb6>

0000000080002bf4 <kerneltrap>:
{
    80002bf4:	7179                	addi	sp,sp,-48
    80002bf6:	f406                	sd	ra,40(sp)
    80002bf8:	f022                	sd	s0,32(sp)
    80002bfa:	ec26                	sd	s1,24(sp)
    80002bfc:	e84a                	sd	s2,16(sp)
    80002bfe:	e44e                	sd	s3,8(sp)
    80002c00:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c02:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c06:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0a:	142027f3          	csrr	a5,scause
    80002c0e:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002c10:	1004f793          	andi	a5,s1,256
    80002c14:	c795                	beqz	a5,80002c40 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c1a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c1c:	eb85                	bnez	a5,80002c4c <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c1e:	e53ff0ef          	jal	80002a70 <devintr>
    80002c22:	c91d                	beqz	a0,80002c58 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002c24:	4789                	li	a5,2
    80002c26:	04f50a63          	beq	a0,a5,80002c7a <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c2a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c2e:	10049073          	csrw	sstatus,s1
}
    80002c32:	70a2                	ld	ra,40(sp)
    80002c34:	7402                	ld	s0,32(sp)
    80002c36:	64e2                	ld	s1,24(sp)
    80002c38:	6942                	ld	s2,16(sp)
    80002c3a:	69a2                	ld	s3,8(sp)
    80002c3c:	6145                	addi	sp,sp,48
    80002c3e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c40:	00005517          	auipc	a0,0x5
    80002c44:	8c850513          	addi	a0,a0,-1848 # 80007508 <etext+0x508>
    80002c48:	bddfd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c4c:	00005517          	auipc	a0,0x5
    80002c50:	8e450513          	addi	a0,a0,-1820 # 80007530 <etext+0x530>
    80002c54:	bd1fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c58:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c60:	85ce                	mv	a1,s3
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	8ee50513          	addi	a0,a0,-1810 # 80007550 <etext+0x550>
    80002c6a:	891fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002c6e:	00005517          	auipc	a0,0x5
    80002c72:	90a50513          	addi	a0,a0,-1782 # 80007578 <etext+0x578>
    80002c76:	baffd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c7a:	d33fe0ef          	jal	800019ac <myproc>
    80002c7e:	d555                	beqz	a0,80002c2a <kerneltrap+0x36>
    yield();
    80002c80:	db4ff0ef          	jal	80002234 <yield>
    80002c84:	b75d                	j	80002c2a <kerneltrap+0x36>

0000000080002c86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c86:	1101                	addi	sp,sp,-32
    80002c88:	ec06                	sd	ra,24(sp)
    80002c8a:	e822                	sd	s0,16(sp)
    80002c8c:	e426                	sd	s1,8(sp)
    80002c8e:	1000                	addi	s0,sp,32
    80002c90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c92:	d1bfe0ef          	jal	800019ac <myproc>
  switch (n) {
    80002c96:	4795                	li	a5,5
    80002c98:	0497e163          	bltu	a5,s1,80002cda <argraw+0x54>
    80002c9c:	048a                	slli	s1,s1,0x2
    80002c9e:	00005717          	auipc	a4,0x5
    80002ca2:	d0270713          	addi	a4,a4,-766 # 800079a0 <states.0+0x30>
    80002ca6:	94ba                	add	s1,s1,a4
    80002ca8:	409c                	lw	a5,0(s1)
    80002caa:	97ba                	add	a5,a5,a4
    80002cac:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cae:	713c                	ld	a5,96(a0)
    80002cb0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cb2:	60e2                	ld	ra,24(sp)
    80002cb4:	6442                	ld	s0,16(sp)
    80002cb6:	64a2                	ld	s1,8(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret
    return p->trapframe->a1;
    80002cbc:	713c                	ld	a5,96(a0)
    80002cbe:	7fa8                	ld	a0,120(a5)
    80002cc0:	bfcd                	j	80002cb2 <argraw+0x2c>
    return p->trapframe->a2;
    80002cc2:	713c                	ld	a5,96(a0)
    80002cc4:	63c8                	ld	a0,128(a5)
    80002cc6:	b7f5                	j	80002cb2 <argraw+0x2c>
    return p->trapframe->a3;
    80002cc8:	713c                	ld	a5,96(a0)
    80002cca:	67c8                	ld	a0,136(a5)
    80002ccc:	b7dd                	j	80002cb2 <argraw+0x2c>
    return p->trapframe->a4;
    80002cce:	713c                	ld	a5,96(a0)
    80002cd0:	6bc8                	ld	a0,144(a5)
    80002cd2:	b7c5                	j	80002cb2 <argraw+0x2c>
    return p->trapframe->a5;
    80002cd4:	713c                	ld	a5,96(a0)
    80002cd6:	6fc8                	ld	a0,152(a5)
    80002cd8:	bfe9                	j	80002cb2 <argraw+0x2c>
  panic("argraw");
    80002cda:	00005517          	auipc	a0,0x5
    80002cde:	8ae50513          	addi	a0,a0,-1874 # 80007588 <etext+0x588>
    80002ce2:	b43fd0ef          	jal	80000824 <panic>

0000000080002ce6 <fetchaddr>:
{
    80002ce6:	1101                	addi	sp,sp,-32
    80002ce8:	ec06                	sd	ra,24(sp)
    80002cea:	e822                	sd	s0,16(sp)
    80002cec:	e426                	sd	s1,8(sp)
    80002cee:	e04a                	sd	s2,0(sp)
    80002cf0:	1000                	addi	s0,sp,32
    80002cf2:	84aa                	mv	s1,a0
    80002cf4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cf6:	cb7fe0ef          	jal	800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cfa:	693c                	ld	a5,80(a0)
    80002cfc:	02f4f663          	bgeu	s1,a5,80002d28 <fetchaddr+0x42>
    80002d00:	00848713          	addi	a4,s1,8
    80002d04:	02e7e463          	bltu	a5,a4,80002d2c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d08:	46a1                	li	a3,8
    80002d0a:	8626                	mv	a2,s1
    80002d0c:	85ca                	mv	a1,s2
    80002d0e:	6d28                	ld	a0,88(a0)
    80002d10:	a03fe0ef          	jal	80001712 <copyin>
    80002d14:	00a03533          	snez	a0,a0
    80002d18:	40a0053b          	negw	a0,a0
}
    80002d1c:	60e2                	ld	ra,24(sp)
    80002d1e:	6442                	ld	s0,16(sp)
    80002d20:	64a2                	ld	s1,8(sp)
    80002d22:	6902                	ld	s2,0(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret
    return -1;
    80002d28:	557d                	li	a0,-1
    80002d2a:	bfcd                	j	80002d1c <fetchaddr+0x36>
    80002d2c:	557d                	li	a0,-1
    80002d2e:	b7fd                	j	80002d1c <fetchaddr+0x36>

0000000080002d30 <fetchstr>:
{
    80002d30:	7179                	addi	sp,sp,-48
    80002d32:	f406                	sd	ra,40(sp)
    80002d34:	f022                	sd	s0,32(sp)
    80002d36:	ec26                	sd	s1,24(sp)
    80002d38:	e84a                	sd	s2,16(sp)
    80002d3a:	e44e                	sd	s3,8(sp)
    80002d3c:	1800                	addi	s0,sp,48
    80002d3e:	89aa                	mv	s3,a0
    80002d40:	84ae                	mv	s1,a1
    80002d42:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d44:	c69fe0ef          	jal	800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d48:	86ca                	mv	a3,s2
    80002d4a:	864e                	mv	a2,s3
    80002d4c:	85a6                	mv	a1,s1
    80002d4e:	6d28                	ld	a0,88(a0)
    80002d50:	fa8fe0ef          	jal	800014f8 <copyinstr>
    80002d54:	00054c63          	bltz	a0,80002d6c <fetchstr+0x3c>
  return strlen(buf);
    80002d58:	8526                	mv	a0,s1
    80002d5a:	928fe0ef          	jal	80000e82 <strlen>
}
    80002d5e:	70a2                	ld	ra,40(sp)
    80002d60:	7402                	ld	s0,32(sp)
    80002d62:	64e2                	ld	s1,24(sp)
    80002d64:	6942                	ld	s2,16(sp)
    80002d66:	69a2                	ld	s3,8(sp)
    80002d68:	6145                	addi	sp,sp,48
    80002d6a:	8082                	ret
    return -1;
    80002d6c:	557d                	li	a0,-1
    80002d6e:	bfc5                	j	80002d5e <fetchstr+0x2e>

0000000080002d70 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d70:	1101                	addi	sp,sp,-32
    80002d72:	ec06                	sd	ra,24(sp)
    80002d74:	e822                	sd	s0,16(sp)
    80002d76:	e426                	sd	s1,8(sp)
    80002d78:	1000                	addi	s0,sp,32
    80002d7a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d7c:	f0bff0ef          	jal	80002c86 <argraw>
    80002d80:	c088                	sw	a0,0(s1)
}
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d98:	eefff0ef          	jal	80002c86 <argraw>
    80002d9c:	e088                	sd	a0,0(s1)
}
    80002d9e:	60e2                	ld	ra,24(sp)
    80002da0:	6442                	ld	s0,16(sp)
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	e426                	sd	s1,8(sp)
    80002db0:	e04a                	sd	s2,0(sp)
    80002db2:	1000                	addi	s0,sp,32
    80002db4:	892e                	mv	s2,a1
    80002db6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002db8:	ecfff0ef          	jal	80002c86 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002dbc:	8626                	mv	a2,s1
    80002dbe:	85ca                	mv	a1,s2
    80002dc0:	f71ff0ef          	jal	80002d30 <fetchstr>
}
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	64a2                	ld	s1,8(sp)
    80002dca:	6902                	ld	s2,0(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ddc:	bd1fe0ef          	jal	800019ac <myproc>
    80002de0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002de2:	06053903          	ld	s2,96(a0)
    80002de6:	0a893783          	ld	a5,168(s2)
    80002dea:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dee:	37fd                	addiw	a5,a5,-1
    80002df0:	4755                	li	a4,21
    80002df2:	00f76f63          	bltu	a4,a5,80002e10 <syscall+0x40>
    80002df6:	00369713          	slli	a4,a3,0x3
    80002dfa:	00005797          	auipc	a5,0x5
    80002dfe:	bbe78793          	addi	a5,a5,-1090 # 800079b8 <syscalls>
    80002e02:	97ba                	add	a5,a5,a4
    80002e04:	639c                	ld	a5,0(a5)
    80002e06:	c789                	beqz	a5,80002e10 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e08:	9782                	jalr	a5
    80002e0a:	06a93823          	sd	a0,112(s2)
    80002e0e:	a829                	j	80002e28 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e10:	16048613          	addi	a2,s1,352
    80002e14:	588c                	lw	a1,48(s1)
    80002e16:	00004517          	auipc	a0,0x4
    80002e1a:	77a50513          	addi	a0,a0,1914 # 80007590 <etext+0x590>
    80002e1e:	edcfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e22:	70bc                	ld	a5,96(s1)
    80002e24:	577d                	li	a4,-1
    80002e26:	fbb8                	sd	a4,112(a5)
  }
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	64a2                	ld	s1,8(sp)
    80002e2e:	6902                	ld	s2,0(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret

0000000080002e34 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e3c:	fec40593          	addi	a1,s0,-20
    80002e40:	4501                	li	a0,0
    80002e42:	f2fff0ef          	jal	80002d70 <argint>
  kexit(n);
    80002e46:	fec42503          	lw	a0,-20(s0)
    80002e4a:	d22ff0ef          	jal	8000236c <kexit>
  return 0;  // not reached
}
    80002e4e:	4501                	li	a0,0
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e58:	1141                	addi	sp,sp,-16
    80002e5a:	e406                	sd	ra,8(sp)
    80002e5c:	e022                	sd	s0,0(sp)
    80002e5e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e60:	b4dfe0ef          	jal	800019ac <myproc>
}
    80002e64:	5908                	lw	a0,48(a0)
    80002e66:	60a2                	ld	ra,8(sp)
    80002e68:	6402                	ld	s0,0(sp)
    80002e6a:	0141                	addi	sp,sp,16
    80002e6c:	8082                	ret

0000000080002e6e <sys_fork>:

uint64
sys_fork(void)
{
    80002e6e:	1141                	addi	sp,sp,-16
    80002e70:	e406                	sd	ra,8(sp)
    80002e72:	e022                	sd	s0,0(sp)
    80002e74:	0800                	addi	s0,sp,16
  return kfork();
    80002e76:	eabfe0ef          	jal	80001d20 <kfork>
}
    80002e7a:	60a2                	ld	ra,8(sp)
    80002e7c:	6402                	ld	s0,0(sp)
    80002e7e:	0141                	addi	sp,sp,16
    80002e80:	8082                	ret

0000000080002e82 <sys_wait>:

uint64
sys_wait(void)
{
    80002e82:	1101                	addi	sp,sp,-32
    80002e84:	ec06                	sd	ra,24(sp)
    80002e86:	e822                	sd	s0,16(sp)
    80002e88:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e8a:	fe840593          	addi	a1,s0,-24
    80002e8e:	4501                	li	a0,0
    80002e90:	efdff0ef          	jal	80002d8c <argaddr>
  return kwait(p);
    80002e94:	fe843503          	ld	a0,-24(s0)
    80002e98:	e2eff0ef          	jal	800024c6 <kwait>
}
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	6105                	addi	sp,sp,32
    80002ea2:	8082                	ret

0000000080002ea4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ea4:	7179                	addi	sp,sp,-48
    80002ea6:	f406                	sd	ra,40(sp)
    80002ea8:	f022                	sd	s0,32(sp)
    80002eaa:	ec26                	sd	s1,24(sp)
    80002eac:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002eae:	fd840593          	addi	a1,s0,-40
    80002eb2:	4501                	li	a0,0
    80002eb4:	ebdff0ef          	jal	80002d70 <argint>
  argint(1, &t);
    80002eb8:	fdc40593          	addi	a1,s0,-36
    80002ebc:	4505                	li	a0,1
    80002ebe:	eb3ff0ef          	jal	80002d70 <argint>
  addr = myproc()->sz;
    80002ec2:	aebfe0ef          	jal	800019ac <myproc>
    80002ec6:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ec8:	fdc42703          	lw	a4,-36(s0)
    80002ecc:	4785                	li	a5,1
    80002ece:	02f70763          	beq	a4,a5,80002efc <sys_sbrk+0x58>
    80002ed2:	fd842783          	lw	a5,-40(s0)
    80002ed6:	0207c363          	bltz	a5,80002efc <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002eda:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002edc:	02000737          	lui	a4,0x2000
    80002ee0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ee2:	0736                	slli	a4,a4,0xd
    80002ee4:	02f76a63          	bltu	a4,a5,80002f18 <sys_sbrk+0x74>
    80002ee8:	0297e863          	bltu	a5,s1,80002f18 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002eec:	ac1fe0ef          	jal	800019ac <myproc>
    80002ef0:	fd842703          	lw	a4,-40(s0)
    80002ef4:	693c                	ld	a5,80(a0)
    80002ef6:	97ba                	add	a5,a5,a4
    80002ef8:	e93c                	sd	a5,80(a0)
    80002efa:	a039                	j	80002f08 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002efc:	fd842503          	lw	a0,-40(s0)
    80002f00:	dbffe0ef          	jal	80001cbe <growproc>
    80002f04:	00054863          	bltz	a0,80002f14 <sys_sbrk+0x70>
  }
  return addr;
}
    80002f08:	8526                	mv	a0,s1
    80002f0a:	70a2                	ld	ra,40(sp)
    80002f0c:	7402                	ld	s0,32(sp)
    80002f0e:	64e2                	ld	s1,24(sp)
    80002f10:	6145                	addi	sp,sp,48
    80002f12:	8082                	ret
      return -1;
    80002f14:	54fd                	li	s1,-1
    80002f16:	bfcd                	j	80002f08 <sys_sbrk+0x64>
      return -1;
    80002f18:	54fd                	li	s1,-1
    80002f1a:	b7fd                	j	80002f08 <sys_sbrk+0x64>

0000000080002f1c <sys_pause>:

uint64
sys_pause(void)
{
    80002f1c:	7139                	addi	sp,sp,-64
    80002f1e:	fc06                	sd	ra,56(sp)
    80002f20:	f822                	sd	s0,48(sp)
    80002f22:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f24:	fcc40593          	addi	a1,s0,-52
    80002f28:	4501                	li	a0,0
    80002f2a:	e47ff0ef          	jal	80002d70 <argint>
  if(n < 0)
    80002f2e:	fcc42783          	lw	a5,-52(s0)
    80002f32:	0607c863          	bltz	a5,80002fa2 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f36:	00015517          	auipc	a0,0x15
    80002f3a:	78250513          	addi	a0,a0,1922 # 800186b8 <tickslock>
    80002f3e:	cebfd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002f42:	fcc42783          	lw	a5,-52(s0)
    80002f46:	c3b9                	beqz	a5,80002f8c <sys_pause+0x70>
    80002f48:	f426                	sd	s1,40(sp)
    80002f4a:	f04a                	sd	s2,32(sp)
    80002f4c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002f4e:	00007997          	auipc	s3,0x7
    80002f52:	6329a983          	lw	s3,1586(s3) # 8000a580 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f56:	00015917          	auipc	s2,0x15
    80002f5a:	76290913          	addi	s2,s2,1890 # 800186b8 <tickslock>
    80002f5e:	00007497          	auipc	s1,0x7
    80002f62:	62248493          	addi	s1,s1,1570 # 8000a580 <ticks>
    if(killed(myproc())){
    80002f66:	a47fe0ef          	jal	800019ac <myproc>
    80002f6a:	d32ff0ef          	jal	8000249c <killed>
    80002f6e:	ed0d                	bnez	a0,80002fa8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f70:	85ca                	mv	a1,s2
    80002f72:	8526                	mv	a0,s1
    80002f74:	aecff0ef          	jal	80002260 <sleep>
  while(ticks - ticks0 < n){
    80002f78:	409c                	lw	a5,0(s1)
    80002f7a:	413787bb          	subw	a5,a5,s3
    80002f7e:	fcc42703          	lw	a4,-52(s0)
    80002f82:	fee7e2e3          	bltu	a5,a4,80002f66 <sys_pause+0x4a>
    80002f86:	74a2                	ld	s1,40(sp)
    80002f88:	7902                	ld	s2,32(sp)
    80002f8a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f8c:	00015517          	auipc	a0,0x15
    80002f90:	72c50513          	addi	a0,a0,1836 # 800186b8 <tickslock>
    80002f94:	d29fd0ef          	jal	80000cbc <release>
  return 0;
    80002f98:	4501                	li	a0,0
}
    80002f9a:	70e2                	ld	ra,56(sp)
    80002f9c:	7442                	ld	s0,48(sp)
    80002f9e:	6121                	addi	sp,sp,64
    80002fa0:	8082                	ret
    n = 0;
    80002fa2:	fc042623          	sw	zero,-52(s0)
    80002fa6:	bf41                	j	80002f36 <sys_pause+0x1a>
      release(&tickslock);
    80002fa8:	00015517          	auipc	a0,0x15
    80002fac:	71050513          	addi	a0,a0,1808 # 800186b8 <tickslock>
    80002fb0:	d0dfd0ef          	jal	80000cbc <release>
      return -1;
    80002fb4:	557d                	li	a0,-1
    80002fb6:	74a2                	ld	s1,40(sp)
    80002fb8:	7902                	ld	s2,32(sp)
    80002fba:	69e2                	ld	s3,24(sp)
    80002fbc:	bff9                	j	80002f9a <sys_pause+0x7e>

0000000080002fbe <sys_kill>:

uint64
sys_kill(void)
{
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fc6:	fec40593          	addi	a1,s0,-20
    80002fca:	4501                	li	a0,0
    80002fcc:	da5ff0ef          	jal	80002d70 <argint>
  return kkill(pid);
    80002fd0:	fec42503          	lw	a0,-20(s0)
    80002fd4:	c3eff0ef          	jal	80002412 <kkill>
}
    80002fd8:	60e2                	ld	ra,24(sp)
    80002fda:	6442                	ld	s0,16(sp)
    80002fdc:	6105                	addi	sp,sp,32
    80002fde:	8082                	ret

0000000080002fe0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	e426                	sd	s1,8(sp)
    80002fe8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fea:	00015517          	auipc	a0,0x15
    80002fee:	6ce50513          	addi	a0,a0,1742 # 800186b8 <tickslock>
    80002ff2:	c37fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002ff6:	00007797          	auipc	a5,0x7
    80002ffa:	58a7a783          	lw	a5,1418(a5) # 8000a580 <ticks>
    80002ffe:	84be                	mv	s1,a5
  release(&tickslock);
    80003000:	00015517          	auipc	a0,0x15
    80003004:	6b850513          	addi	a0,a0,1720 # 800186b8 <tickslock>
    80003008:	cb5fd0ef          	jal	80000cbc <release>
  return xticks;
}
    8000300c:	02049513          	slli	a0,s1,0x20
    80003010:	9101                	srli	a0,a0,0x20
    80003012:	60e2                	ld	ra,24(sp)
    80003014:	6442                	ld	s0,16(sp)
    80003016:	64a2                	ld	s1,8(sp)
    80003018:	6105                	addi	sp,sp,32
    8000301a:	8082                	ret

000000008000301c <sys_kps>:

uint64
sys_kps(void)
{
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003024:	4611                	li	a2,4
    80003026:	fe840593          	addi	a1,s0,-24
    8000302a:	4501                	li	a0,0
    8000302c:	d7dff0ef          	jal	80002da8 <argstr>
    80003030:	87aa                	mv	a5,a0
    return -1;
    80003032:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003034:	0007c663          	bltz	a5,80003040 <sys_kps+0x24>

  return kps(buffer);
    80003038:	fe840513          	addi	a0,s0,-24
    8000303c:	ebaff0ef          	jal	800026f6 <kps>
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003048:	7179                	addi	sp,sp,-48
    8000304a:	f406                	sd	ra,40(sp)
    8000304c:	f022                	sd	s0,32(sp)
    8000304e:	ec26                	sd	s1,24(sp)
    80003050:	e84a                	sd	s2,16(sp)
    80003052:	e44e                	sd	s3,8(sp)
    80003054:	e052                	sd	s4,0(sp)
    80003056:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003058:	00004597          	auipc	a1,0x4
    8000305c:	55858593          	addi	a1,a1,1368 # 800075b0 <etext+0x5b0>
    80003060:	00015517          	auipc	a0,0x15
    80003064:	67050513          	addi	a0,a0,1648 # 800186d0 <bcache>
    80003068:	b37fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000306c:	0001d797          	auipc	a5,0x1d
    80003070:	66478793          	addi	a5,a5,1636 # 800206d0 <bcache+0x8000>
    80003074:	0001e717          	auipc	a4,0x1e
    80003078:	8c470713          	addi	a4,a4,-1852 # 80020938 <bcache+0x8268>
    8000307c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003080:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003084:	00015497          	auipc	s1,0x15
    80003088:	66448493          	addi	s1,s1,1636 # 800186e8 <bcache+0x18>
    b->next = bcache.head.next;
    8000308c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000308e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003090:	00004a17          	auipc	s4,0x4
    80003094:	528a0a13          	addi	s4,s4,1320 # 800075b8 <etext+0x5b8>
    b->next = bcache.head.next;
    80003098:	2b893783          	ld	a5,696(s2)
    8000309c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000309e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030a2:	85d2                	mv	a1,s4
    800030a4:	01048513          	addi	a0,s1,16
    800030a8:	328010ef          	jal	800043d0 <initsleeplock>
    bcache.head.next->prev = b;
    800030ac:	2b893783          	ld	a5,696(s2)
    800030b0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030b2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b6:	45848493          	addi	s1,s1,1112
    800030ba:	fd349fe3          	bne	s1,s3,80003098 <binit+0x50>
  }
}
    800030be:	70a2                	ld	ra,40(sp)
    800030c0:	7402                	ld	s0,32(sp)
    800030c2:	64e2                	ld	s1,24(sp)
    800030c4:	6942                	ld	s2,16(sp)
    800030c6:	69a2                	ld	s3,8(sp)
    800030c8:	6a02                	ld	s4,0(sp)
    800030ca:	6145                	addi	sp,sp,48
    800030cc:	8082                	ret

00000000800030ce <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030ce:	7179                	addi	sp,sp,-48
    800030d0:	f406                	sd	ra,40(sp)
    800030d2:	f022                	sd	s0,32(sp)
    800030d4:	ec26                	sd	s1,24(sp)
    800030d6:	e84a                	sd	s2,16(sp)
    800030d8:	e44e                	sd	s3,8(sp)
    800030da:	1800                	addi	s0,sp,48
    800030dc:	892a                	mv	s2,a0
    800030de:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030e0:	00015517          	auipc	a0,0x15
    800030e4:	5f050513          	addi	a0,a0,1520 # 800186d0 <bcache>
    800030e8:	b41fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030ec:	0001e497          	auipc	s1,0x1e
    800030f0:	89c4b483          	ld	s1,-1892(s1) # 80020988 <bcache+0x82b8>
    800030f4:	0001e797          	auipc	a5,0x1e
    800030f8:	84478793          	addi	a5,a5,-1980 # 80020938 <bcache+0x8268>
    800030fc:	02f48b63          	beq	s1,a5,80003132 <bread+0x64>
    80003100:	873e                	mv	a4,a5
    80003102:	a021                	j	8000310a <bread+0x3c>
    80003104:	68a4                	ld	s1,80(s1)
    80003106:	02e48663          	beq	s1,a4,80003132 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000310a:	449c                	lw	a5,8(s1)
    8000310c:	ff279ce3          	bne	a5,s2,80003104 <bread+0x36>
    80003110:	44dc                	lw	a5,12(s1)
    80003112:	ff3799e3          	bne	a5,s3,80003104 <bread+0x36>
      b->refcnt++;
    80003116:	40bc                	lw	a5,64(s1)
    80003118:	2785                	addiw	a5,a5,1
    8000311a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000311c:	00015517          	auipc	a0,0x15
    80003120:	5b450513          	addi	a0,a0,1460 # 800186d0 <bcache>
    80003124:	b99fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80003128:	01048513          	addi	a0,s1,16
    8000312c:	2da010ef          	jal	80004406 <acquiresleep>
      return b;
    80003130:	a889                	j	80003182 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003132:	0001e497          	auipc	s1,0x1e
    80003136:	84e4b483          	ld	s1,-1970(s1) # 80020980 <bcache+0x82b0>
    8000313a:	0001d797          	auipc	a5,0x1d
    8000313e:	7fe78793          	addi	a5,a5,2046 # 80020938 <bcache+0x8268>
    80003142:	00f48863          	beq	s1,a5,80003152 <bread+0x84>
    80003146:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003148:	40bc                	lw	a5,64(s1)
    8000314a:	cb91                	beqz	a5,8000315e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000314c:	64a4                	ld	s1,72(s1)
    8000314e:	fee49de3          	bne	s1,a4,80003148 <bread+0x7a>
  panic("bget: no buffers");
    80003152:	00004517          	auipc	a0,0x4
    80003156:	46e50513          	addi	a0,a0,1134 # 800075c0 <etext+0x5c0>
    8000315a:	ecafd0ef          	jal	80000824 <panic>
      b->dev = dev;
    8000315e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003162:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003166:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000316a:	4785                	li	a5,1
    8000316c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000316e:	00015517          	auipc	a0,0x15
    80003172:	56250513          	addi	a0,a0,1378 # 800186d0 <bcache>
    80003176:	b47fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    8000317a:	01048513          	addi	a0,s1,16
    8000317e:	288010ef          	jal	80004406 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003182:	409c                	lw	a5,0(s1)
    80003184:	cb89                	beqz	a5,80003196 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003186:	8526                	mv	a0,s1
    80003188:	70a2                	ld	ra,40(sp)
    8000318a:	7402                	ld	s0,32(sp)
    8000318c:	64e2                	ld	s1,24(sp)
    8000318e:	6942                	ld	s2,16(sp)
    80003190:	69a2                	ld	s3,8(sp)
    80003192:	6145                	addi	sp,sp,48
    80003194:	8082                	ret
    virtio_disk_rw(b, 0);
    80003196:	4581                	li	a1,0
    80003198:	8526                	mv	a0,s1
    8000319a:	337020ef          	jal	80005cd0 <virtio_disk_rw>
    b->valid = 1;
    8000319e:	4785                	li	a5,1
    800031a0:	c09c                	sw	a5,0(s1)
  return b;
    800031a2:	b7d5                	j	80003186 <bread+0xb8>

00000000800031a4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	e426                	sd	s1,8(sp)
    800031ac:	1000                	addi	s0,sp,32
    800031ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b0:	0541                	addi	a0,a0,16
    800031b2:	2d2010ef          	jal	80004484 <holdingsleep>
    800031b6:	c911                	beqz	a0,800031ca <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031b8:	4585                	li	a1,1
    800031ba:	8526                	mv	a0,s1
    800031bc:	315020ef          	jal	80005cd0 <virtio_disk_rw>
}
    800031c0:	60e2                	ld	ra,24(sp)
    800031c2:	6442                	ld	s0,16(sp)
    800031c4:	64a2                	ld	s1,8(sp)
    800031c6:	6105                	addi	sp,sp,32
    800031c8:	8082                	ret
    panic("bwrite");
    800031ca:	00004517          	auipc	a0,0x4
    800031ce:	40e50513          	addi	a0,a0,1038 # 800075d8 <etext+0x5d8>
    800031d2:	e52fd0ef          	jal	80000824 <panic>

00000000800031d6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	e426                	sd	s1,8(sp)
    800031de:	e04a                	sd	s2,0(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031e4:	01050913          	addi	s2,a0,16
    800031e8:	854a                	mv	a0,s2
    800031ea:	29a010ef          	jal	80004484 <holdingsleep>
    800031ee:	c125                	beqz	a0,8000324e <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    800031f0:	854a                	mv	a0,s2
    800031f2:	25a010ef          	jal	8000444c <releasesleep>

  acquire(&bcache.lock);
    800031f6:	00015517          	auipc	a0,0x15
    800031fa:	4da50513          	addi	a0,a0,1242 # 800186d0 <bcache>
    800031fe:	a2bfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003202:	40bc                	lw	a5,64(s1)
    80003204:	37fd                	addiw	a5,a5,-1
    80003206:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003208:	e79d                	bnez	a5,80003236 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000320a:	68b8                	ld	a4,80(s1)
    8000320c:	64bc                	ld	a5,72(s1)
    8000320e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003210:	68b8                	ld	a4,80(s1)
    80003212:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003214:	0001d797          	auipc	a5,0x1d
    80003218:	4bc78793          	addi	a5,a5,1212 # 800206d0 <bcache+0x8000>
    8000321c:	2b87b703          	ld	a4,696(a5)
    80003220:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003222:	0001d717          	auipc	a4,0x1d
    80003226:	71670713          	addi	a4,a4,1814 # 80020938 <bcache+0x8268>
    8000322a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000322c:	2b87b703          	ld	a4,696(a5)
    80003230:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003232:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003236:	00015517          	auipc	a0,0x15
    8000323a:	49a50513          	addi	a0,a0,1178 # 800186d0 <bcache>
    8000323e:	a7ffd0ef          	jal	80000cbc <release>
}
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	64a2                	ld	s1,8(sp)
    80003248:	6902                	ld	s2,0(sp)
    8000324a:	6105                	addi	sp,sp,32
    8000324c:	8082                	ret
    panic("brelse");
    8000324e:	00004517          	auipc	a0,0x4
    80003252:	39250513          	addi	a0,a0,914 # 800075e0 <etext+0x5e0>
    80003256:	dcefd0ef          	jal	80000824 <panic>

000000008000325a <bpin>:

void
bpin(struct buf *b) {
    8000325a:	1101                	addi	sp,sp,-32
    8000325c:	ec06                	sd	ra,24(sp)
    8000325e:	e822                	sd	s0,16(sp)
    80003260:	e426                	sd	s1,8(sp)
    80003262:	1000                	addi	s0,sp,32
    80003264:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003266:	00015517          	auipc	a0,0x15
    8000326a:	46a50513          	addi	a0,a0,1130 # 800186d0 <bcache>
    8000326e:	9bbfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003272:	40bc                	lw	a5,64(s1)
    80003274:	2785                	addiw	a5,a5,1
    80003276:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003278:	00015517          	auipc	a0,0x15
    8000327c:	45850513          	addi	a0,a0,1112 # 800186d0 <bcache>
    80003280:	a3dfd0ef          	jal	80000cbc <release>
}
    80003284:	60e2                	ld	ra,24(sp)
    80003286:	6442                	ld	s0,16(sp)
    80003288:	64a2                	ld	s1,8(sp)
    8000328a:	6105                	addi	sp,sp,32
    8000328c:	8082                	ret

000000008000328e <bunpin>:

void
bunpin(struct buf *b) {
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	1000                	addi	s0,sp,32
    80003298:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000329a:	00015517          	auipc	a0,0x15
    8000329e:	43650513          	addi	a0,a0,1078 # 800186d0 <bcache>
    800032a2:	987fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800032a6:	40bc                	lw	a5,64(s1)
    800032a8:	37fd                	addiw	a5,a5,-1
    800032aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032ac:	00015517          	auipc	a0,0x15
    800032b0:	42450513          	addi	a0,a0,1060 # 800186d0 <bcache>
    800032b4:	a09fd0ef          	jal	80000cbc <release>
}
    800032b8:	60e2                	ld	ra,24(sp)
    800032ba:	6442                	ld	s0,16(sp)
    800032bc:	64a2                	ld	s1,8(sp)
    800032be:	6105                	addi	sp,sp,32
    800032c0:	8082                	ret

00000000800032c2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	e426                	sd	s1,8(sp)
    800032ca:	e04a                	sd	s2,0(sp)
    800032cc:	1000                	addi	s0,sp,32
    800032ce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032d0:	00d5d79b          	srliw	a5,a1,0xd
    800032d4:	0001e597          	auipc	a1,0x1e
    800032d8:	ad85a583          	lw	a1,-1320(a1) # 80020dac <sb+0x1c>
    800032dc:	9dbd                	addw	a1,a1,a5
    800032de:	df1ff0ef          	jal	800030ce <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032e2:	0074f713          	andi	a4,s1,7
    800032e6:	4785                	li	a5,1
    800032e8:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800032ec:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800032ee:	90d9                	srli	s1,s1,0x36
    800032f0:	00950733          	add	a4,a0,s1
    800032f4:	05874703          	lbu	a4,88(a4)
    800032f8:	00e7f6b3          	and	a3,a5,a4
    800032fc:	c29d                	beqz	a3,80003322 <bfree+0x60>
    800032fe:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003300:	94aa                	add	s1,s1,a0
    80003302:	fff7c793          	not	a5,a5
    80003306:	8f7d                	and	a4,a4,a5
    80003308:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000330c:	000010ef          	jal	8000430c <log_write>
  brelse(bp);
    80003310:	854a                	mv	a0,s2
    80003312:	ec5ff0ef          	jal	800031d6 <brelse>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret
    panic("freeing free block");
    80003322:	00004517          	auipc	a0,0x4
    80003326:	2c650513          	addi	a0,a0,710 # 800075e8 <etext+0x5e8>
    8000332a:	cfafd0ef          	jal	80000824 <panic>

000000008000332e <balloc>:
{
    8000332e:	715d                	addi	sp,sp,-80
    80003330:	e486                	sd	ra,72(sp)
    80003332:	e0a2                	sd	s0,64(sp)
    80003334:	fc26                	sd	s1,56(sp)
    80003336:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003338:	0001e797          	auipc	a5,0x1e
    8000333c:	a5c7a783          	lw	a5,-1444(a5) # 80020d94 <sb+0x4>
    80003340:	0e078263          	beqz	a5,80003424 <balloc+0xf6>
    80003344:	f84a                	sd	s2,48(sp)
    80003346:	f44e                	sd	s3,40(sp)
    80003348:	f052                	sd	s4,32(sp)
    8000334a:	ec56                	sd	s5,24(sp)
    8000334c:	e85a                	sd	s6,16(sp)
    8000334e:	e45e                	sd	s7,8(sp)
    80003350:	e062                	sd	s8,0(sp)
    80003352:	8baa                	mv	s7,a0
    80003354:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003356:	0001eb17          	auipc	s6,0x1e
    8000335a:	a3ab0b13          	addi	s6,s6,-1478 # 80020d90 <sb>
      m = 1 << (bi % 8);
    8000335e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003360:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003362:	6c09                	lui	s8,0x2
    80003364:	a09d                	j	800033ca <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003366:	97ca                	add	a5,a5,s2
    80003368:	8e55                	or	a2,a2,a3
    8000336a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000336e:	854a                	mv	a0,s2
    80003370:	79d000ef          	jal	8000430c <log_write>
        brelse(bp);
    80003374:	854a                	mv	a0,s2
    80003376:	e61ff0ef          	jal	800031d6 <brelse>
  bp = bread(dev, bno);
    8000337a:	85a6                	mv	a1,s1
    8000337c:	855e                	mv	a0,s7
    8000337e:	d51ff0ef          	jal	800030ce <bread>
    80003382:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003384:	40000613          	li	a2,1024
    80003388:	4581                	li	a1,0
    8000338a:	05850513          	addi	a0,a0,88
    8000338e:	96bfd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80003392:	854a                	mv	a0,s2
    80003394:	779000ef          	jal	8000430c <log_write>
  brelse(bp);
    80003398:	854a                	mv	a0,s2
    8000339a:	e3dff0ef          	jal	800031d6 <brelse>
}
    8000339e:	7942                	ld	s2,48(sp)
    800033a0:	79a2                	ld	s3,40(sp)
    800033a2:	7a02                	ld	s4,32(sp)
    800033a4:	6ae2                	ld	s5,24(sp)
    800033a6:	6b42                	ld	s6,16(sp)
    800033a8:	6ba2                	ld	s7,8(sp)
    800033aa:	6c02                	ld	s8,0(sp)
}
    800033ac:	8526                	mv	a0,s1
    800033ae:	60a6                	ld	ra,72(sp)
    800033b0:	6406                	ld	s0,64(sp)
    800033b2:	74e2                	ld	s1,56(sp)
    800033b4:	6161                	addi	sp,sp,80
    800033b6:	8082                	ret
    brelse(bp);
    800033b8:	854a                	mv	a0,s2
    800033ba:	e1dff0ef          	jal	800031d6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033be:	015c0abb          	addw	s5,s8,s5
    800033c2:	004b2783          	lw	a5,4(s6)
    800033c6:	04faf863          	bgeu	s5,a5,80003416 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800033ca:	40dad59b          	sraiw	a1,s5,0xd
    800033ce:	01cb2783          	lw	a5,28(s6)
    800033d2:	9dbd                	addw	a1,a1,a5
    800033d4:	855e                	mv	a0,s7
    800033d6:	cf9ff0ef          	jal	800030ce <bread>
    800033da:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033dc:	004b2503          	lw	a0,4(s6)
    800033e0:	84d6                	mv	s1,s5
    800033e2:	4701                	li	a4,0
    800033e4:	fca4fae3          	bgeu	s1,a0,800033b8 <balloc+0x8a>
      m = 1 << (bi % 8);
    800033e8:	00777693          	andi	a3,a4,7
    800033ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033f0:	41f7579b          	sraiw	a5,a4,0x1f
    800033f4:	01d7d79b          	srliw	a5,a5,0x1d
    800033f8:	9fb9                	addw	a5,a5,a4
    800033fa:	4037d79b          	sraiw	a5,a5,0x3
    800033fe:	00f90633          	add	a2,s2,a5
    80003402:	05864603          	lbu	a2,88(a2)
    80003406:	00c6f5b3          	and	a1,a3,a2
    8000340a:	ddb1                	beqz	a1,80003366 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340c:	2705                	addiw	a4,a4,1
    8000340e:	2485                	addiw	s1,s1,1
    80003410:	fd471ae3          	bne	a4,s4,800033e4 <balloc+0xb6>
    80003414:	b755                	j	800033b8 <balloc+0x8a>
    80003416:	7942                	ld	s2,48(sp)
    80003418:	79a2                	ld	s3,40(sp)
    8000341a:	7a02                	ld	s4,32(sp)
    8000341c:	6ae2                	ld	s5,24(sp)
    8000341e:	6b42                	ld	s6,16(sp)
    80003420:	6ba2                	ld	s7,8(sp)
    80003422:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003424:	00004517          	auipc	a0,0x4
    80003428:	1dc50513          	addi	a0,a0,476 # 80007600 <etext+0x600>
    8000342c:	8cefd0ef          	jal	800004fa <printf>
  return 0;
    80003430:	4481                	li	s1,0
    80003432:	bfad                	j	800033ac <balloc+0x7e>

0000000080003434 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003434:	7179                	addi	sp,sp,-48
    80003436:	f406                	sd	ra,40(sp)
    80003438:	f022                	sd	s0,32(sp)
    8000343a:	ec26                	sd	s1,24(sp)
    8000343c:	e84a                	sd	s2,16(sp)
    8000343e:	e44e                	sd	s3,8(sp)
    80003440:	1800                	addi	s0,sp,48
    80003442:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003444:	47ad                	li	a5,11
    80003446:	02b7e363          	bltu	a5,a1,8000346c <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000344a:	02059793          	slli	a5,a1,0x20
    8000344e:	01e7d593          	srli	a1,a5,0x1e
    80003452:	00b509b3          	add	s3,a0,a1
    80003456:	0509a483          	lw	s1,80(s3)
    8000345a:	e0b5                	bnez	s1,800034be <bmap+0x8a>
      addr = balloc(ip->dev);
    8000345c:	4108                	lw	a0,0(a0)
    8000345e:	ed1ff0ef          	jal	8000332e <balloc>
    80003462:	84aa                	mv	s1,a0
      if(addr == 0)
    80003464:	cd29                	beqz	a0,800034be <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003466:	04a9a823          	sw	a0,80(s3)
    8000346a:	a891                	j	800034be <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000346c:	ff45879b          	addiw	a5,a1,-12
    80003470:	873e                	mv	a4,a5
    80003472:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003474:	0ff00793          	li	a5,255
    80003478:	06e7e763          	bltu	a5,a4,800034e6 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000347c:	08052483          	lw	s1,128(a0)
    80003480:	e891                	bnez	s1,80003494 <bmap+0x60>
      addr = balloc(ip->dev);
    80003482:	4108                	lw	a0,0(a0)
    80003484:	eabff0ef          	jal	8000332e <balloc>
    80003488:	84aa                	mv	s1,a0
      if(addr == 0)
    8000348a:	c915                	beqz	a0,800034be <bmap+0x8a>
    8000348c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000348e:	08a92023          	sw	a0,128(s2)
    80003492:	a011                	j	80003496 <bmap+0x62>
    80003494:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003496:	85a6                	mv	a1,s1
    80003498:	00092503          	lw	a0,0(s2)
    8000349c:	c33ff0ef          	jal	800030ce <bread>
    800034a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034a2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034a6:	02099713          	slli	a4,s3,0x20
    800034aa:	01e75593          	srli	a1,a4,0x1e
    800034ae:	97ae                	add	a5,a5,a1
    800034b0:	89be                	mv	s3,a5
    800034b2:	4384                	lw	s1,0(a5)
    800034b4:	cc89                	beqz	s1,800034ce <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800034b6:	8552                	mv	a0,s4
    800034b8:	d1fff0ef          	jal	800031d6 <brelse>
    return addr;
    800034bc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034be:	8526                	mv	a0,s1
    800034c0:	70a2                	ld	ra,40(sp)
    800034c2:	7402                	ld	s0,32(sp)
    800034c4:	64e2                	ld	s1,24(sp)
    800034c6:	6942                	ld	s2,16(sp)
    800034c8:	69a2                	ld	s3,8(sp)
    800034ca:	6145                	addi	sp,sp,48
    800034cc:	8082                	ret
      addr = balloc(ip->dev);
    800034ce:	00092503          	lw	a0,0(s2)
    800034d2:	e5dff0ef          	jal	8000332e <balloc>
    800034d6:	84aa                	mv	s1,a0
      if(addr){
    800034d8:	dd79                	beqz	a0,800034b6 <bmap+0x82>
        a[bn] = addr;
    800034da:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800034de:	8552                	mv	a0,s4
    800034e0:	62d000ef          	jal	8000430c <log_write>
    800034e4:	bfc9                	j	800034b6 <bmap+0x82>
    800034e6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800034e8:	00004517          	auipc	a0,0x4
    800034ec:	13050513          	addi	a0,a0,304 # 80007618 <etext+0x618>
    800034f0:	b34fd0ef          	jal	80000824 <panic>

00000000800034f4 <iget>:
{
    800034f4:	7179                	addi	sp,sp,-48
    800034f6:	f406                	sd	ra,40(sp)
    800034f8:	f022                	sd	s0,32(sp)
    800034fa:	ec26                	sd	s1,24(sp)
    800034fc:	e84a                	sd	s2,16(sp)
    800034fe:	e44e                	sd	s3,8(sp)
    80003500:	e052                	sd	s4,0(sp)
    80003502:	1800                	addi	s0,sp,48
    80003504:	892a                	mv	s2,a0
    80003506:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003508:	0001e517          	auipc	a0,0x1e
    8000350c:	8a850513          	addi	a0,a0,-1880 # 80020db0 <itable>
    80003510:	f18fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003514:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003516:	0001e497          	auipc	s1,0x1e
    8000351a:	8b248493          	addi	s1,s1,-1870 # 80020dc8 <itable+0x18>
    8000351e:	0001f697          	auipc	a3,0x1f
    80003522:	33a68693          	addi	a3,a3,826 # 80022858 <log>
    80003526:	a809                	j	80003538 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003528:	e781                	bnez	a5,80003530 <iget+0x3c>
    8000352a:	00099363          	bnez	s3,80003530 <iget+0x3c>
      empty = ip;
    8000352e:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003530:	08848493          	addi	s1,s1,136
    80003534:	02d48563          	beq	s1,a3,8000355e <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003538:	449c                	lw	a5,8(s1)
    8000353a:	fef057e3          	blez	a5,80003528 <iget+0x34>
    8000353e:	4098                	lw	a4,0(s1)
    80003540:	ff2718e3          	bne	a4,s2,80003530 <iget+0x3c>
    80003544:	40d8                	lw	a4,4(s1)
    80003546:	ff4715e3          	bne	a4,s4,80003530 <iget+0x3c>
      ip->ref++;
    8000354a:	2785                	addiw	a5,a5,1
    8000354c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000354e:	0001e517          	auipc	a0,0x1e
    80003552:	86250513          	addi	a0,a0,-1950 # 80020db0 <itable>
    80003556:	f66fd0ef          	jal	80000cbc <release>
      return ip;
    8000355a:	89a6                	mv	s3,s1
    8000355c:	a015                	j	80003580 <iget+0x8c>
  if(empty == 0)
    8000355e:	02098a63          	beqz	s3,80003592 <iget+0x9e>
  ip->dev = dev;
    80003562:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003566:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000356a:	4785                	li	a5,1
    8000356c:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003570:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003574:	0001e517          	auipc	a0,0x1e
    80003578:	83c50513          	addi	a0,a0,-1988 # 80020db0 <itable>
    8000357c:	f40fd0ef          	jal	80000cbc <release>
}
    80003580:	854e                	mv	a0,s3
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6942                	ld	s2,16(sp)
    8000358a:	69a2                	ld	s3,8(sp)
    8000358c:	6a02                	ld	s4,0(sp)
    8000358e:	6145                	addi	sp,sp,48
    80003590:	8082                	ret
    panic("iget: no inodes");
    80003592:	00004517          	auipc	a0,0x4
    80003596:	09e50513          	addi	a0,a0,158 # 80007630 <etext+0x630>
    8000359a:	a8afd0ef          	jal	80000824 <panic>

000000008000359e <iinit>:
{
    8000359e:	7179                	addi	sp,sp,-48
    800035a0:	f406                	sd	ra,40(sp)
    800035a2:	f022                	sd	s0,32(sp)
    800035a4:	ec26                	sd	s1,24(sp)
    800035a6:	e84a                	sd	s2,16(sp)
    800035a8:	e44e                	sd	s3,8(sp)
    800035aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035ac:	00004597          	auipc	a1,0x4
    800035b0:	09458593          	addi	a1,a1,148 # 80007640 <etext+0x640>
    800035b4:	0001d517          	auipc	a0,0x1d
    800035b8:	7fc50513          	addi	a0,a0,2044 # 80020db0 <itable>
    800035bc:	de2fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800035c0:	0001e497          	auipc	s1,0x1e
    800035c4:	81848493          	addi	s1,s1,-2024 # 80020dd8 <itable+0x28>
    800035c8:	0001f997          	auipc	s3,0x1f
    800035cc:	2a098993          	addi	s3,s3,672 # 80022868 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035d0:	00004917          	auipc	s2,0x4
    800035d4:	07890913          	addi	s2,s2,120 # 80007648 <etext+0x648>
    800035d8:	85ca                	mv	a1,s2
    800035da:	8526                	mv	a0,s1
    800035dc:	5f5000ef          	jal	800043d0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035e0:	08848493          	addi	s1,s1,136
    800035e4:	ff349ae3          	bne	s1,s3,800035d8 <iinit+0x3a>
}
    800035e8:	70a2                	ld	ra,40(sp)
    800035ea:	7402                	ld	s0,32(sp)
    800035ec:	64e2                	ld	s1,24(sp)
    800035ee:	6942                	ld	s2,16(sp)
    800035f0:	69a2                	ld	s3,8(sp)
    800035f2:	6145                	addi	sp,sp,48
    800035f4:	8082                	ret

00000000800035f6 <ialloc>:
{
    800035f6:	7139                	addi	sp,sp,-64
    800035f8:	fc06                	sd	ra,56(sp)
    800035fa:	f822                	sd	s0,48(sp)
    800035fc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035fe:	0001d717          	auipc	a4,0x1d
    80003602:	79e72703          	lw	a4,1950(a4) # 80020d9c <sb+0xc>
    80003606:	4785                	li	a5,1
    80003608:	06e7f063          	bgeu	a5,a4,80003668 <ialloc+0x72>
    8000360c:	f426                	sd	s1,40(sp)
    8000360e:	f04a                	sd	s2,32(sp)
    80003610:	ec4e                	sd	s3,24(sp)
    80003612:	e852                	sd	s4,16(sp)
    80003614:	e456                	sd	s5,8(sp)
    80003616:	e05a                	sd	s6,0(sp)
    80003618:	8aaa                	mv	s5,a0
    8000361a:	8b2e                	mv	s6,a1
    8000361c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000361e:	0001da17          	auipc	s4,0x1d
    80003622:	772a0a13          	addi	s4,s4,1906 # 80020d90 <sb>
    80003626:	00495593          	srli	a1,s2,0x4
    8000362a:	018a2783          	lw	a5,24(s4)
    8000362e:	9dbd                	addw	a1,a1,a5
    80003630:	8556                	mv	a0,s5
    80003632:	a9dff0ef          	jal	800030ce <bread>
    80003636:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003638:	05850993          	addi	s3,a0,88
    8000363c:	00f97793          	andi	a5,s2,15
    80003640:	079a                	slli	a5,a5,0x6
    80003642:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003644:	00099783          	lh	a5,0(s3)
    80003648:	cb9d                	beqz	a5,8000367e <ialloc+0x88>
    brelse(bp);
    8000364a:	b8dff0ef          	jal	800031d6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000364e:	0905                	addi	s2,s2,1
    80003650:	00ca2703          	lw	a4,12(s4)
    80003654:	0009079b          	sext.w	a5,s2
    80003658:	fce7e7e3          	bltu	a5,a4,80003626 <ialloc+0x30>
    8000365c:	74a2                	ld	s1,40(sp)
    8000365e:	7902                	ld	s2,32(sp)
    80003660:	69e2                	ld	s3,24(sp)
    80003662:	6a42                	ld	s4,16(sp)
    80003664:	6aa2                	ld	s5,8(sp)
    80003666:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003668:	00004517          	auipc	a0,0x4
    8000366c:	fe850513          	addi	a0,a0,-24 # 80007650 <etext+0x650>
    80003670:	e8bfc0ef          	jal	800004fa <printf>
  return 0;
    80003674:	4501                	li	a0,0
}
    80003676:	70e2                	ld	ra,56(sp)
    80003678:	7442                	ld	s0,48(sp)
    8000367a:	6121                	addi	sp,sp,64
    8000367c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000367e:	04000613          	li	a2,64
    80003682:	4581                	li	a1,0
    80003684:	854e                	mv	a0,s3
    80003686:	e72fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    8000368a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000368e:	8526                	mv	a0,s1
    80003690:	47d000ef          	jal	8000430c <log_write>
      brelse(bp);
    80003694:	8526                	mv	a0,s1
    80003696:	b41ff0ef          	jal	800031d6 <brelse>
      return iget(dev, inum);
    8000369a:	0009059b          	sext.w	a1,s2
    8000369e:	8556                	mv	a0,s5
    800036a0:	e55ff0ef          	jal	800034f4 <iget>
    800036a4:	74a2                	ld	s1,40(sp)
    800036a6:	7902                	ld	s2,32(sp)
    800036a8:	69e2                	ld	s3,24(sp)
    800036aa:	6a42                	ld	s4,16(sp)
    800036ac:	6aa2                	ld	s5,8(sp)
    800036ae:	6b02                	ld	s6,0(sp)
    800036b0:	b7d9                	j	80003676 <ialloc+0x80>

00000000800036b2 <iupdate>:
{
    800036b2:	1101                	addi	sp,sp,-32
    800036b4:	ec06                	sd	ra,24(sp)
    800036b6:	e822                	sd	s0,16(sp)
    800036b8:	e426                	sd	s1,8(sp)
    800036ba:	e04a                	sd	s2,0(sp)
    800036bc:	1000                	addi	s0,sp,32
    800036be:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c0:	415c                	lw	a5,4(a0)
    800036c2:	0047d79b          	srliw	a5,a5,0x4
    800036c6:	0001d597          	auipc	a1,0x1d
    800036ca:	6e25a583          	lw	a1,1762(a1) # 80020da8 <sb+0x18>
    800036ce:	9dbd                	addw	a1,a1,a5
    800036d0:	4108                	lw	a0,0(a0)
    800036d2:	9fdff0ef          	jal	800030ce <bread>
    800036d6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036d8:	05850793          	addi	a5,a0,88
    800036dc:	40d8                	lw	a4,4(s1)
    800036de:	8b3d                	andi	a4,a4,15
    800036e0:	071a                	slli	a4,a4,0x6
    800036e2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036e4:	04449703          	lh	a4,68(s1)
    800036e8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ec:	04649703          	lh	a4,70(s1)
    800036f0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036f4:	04849703          	lh	a4,72(s1)
    800036f8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036fc:	04a49703          	lh	a4,74(s1)
    80003700:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003704:	44f8                	lw	a4,76(s1)
    80003706:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003708:	03400613          	li	a2,52
    8000370c:	05048593          	addi	a1,s1,80
    80003710:	00c78513          	addi	a0,a5,12
    80003714:	e44fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003718:	854a                	mv	a0,s2
    8000371a:	3f3000ef          	jal	8000430c <log_write>
  brelse(bp);
    8000371e:	854a                	mv	a0,s2
    80003720:	ab7ff0ef          	jal	800031d6 <brelse>
}
    80003724:	60e2                	ld	ra,24(sp)
    80003726:	6442                	ld	s0,16(sp)
    80003728:	64a2                	ld	s1,8(sp)
    8000372a:	6902                	ld	s2,0(sp)
    8000372c:	6105                	addi	sp,sp,32
    8000372e:	8082                	ret

0000000080003730 <idup>:
{
    80003730:	1101                	addi	sp,sp,-32
    80003732:	ec06                	sd	ra,24(sp)
    80003734:	e822                	sd	s0,16(sp)
    80003736:	e426                	sd	s1,8(sp)
    80003738:	1000                	addi	s0,sp,32
    8000373a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000373c:	0001d517          	auipc	a0,0x1d
    80003740:	67450513          	addi	a0,a0,1652 # 80020db0 <itable>
    80003744:	ce4fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003748:	449c                	lw	a5,8(s1)
    8000374a:	2785                	addiw	a5,a5,1
    8000374c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000374e:	0001d517          	auipc	a0,0x1d
    80003752:	66250513          	addi	a0,a0,1634 # 80020db0 <itable>
    80003756:	d66fd0ef          	jal	80000cbc <release>
}
    8000375a:	8526                	mv	a0,s1
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6105                	addi	sp,sp,32
    80003764:	8082                	ret

0000000080003766 <ilock>:
{
    80003766:	1101                	addi	sp,sp,-32
    80003768:	ec06                	sd	ra,24(sp)
    8000376a:	e822                	sd	s0,16(sp)
    8000376c:	e426                	sd	s1,8(sp)
    8000376e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003770:	cd19                	beqz	a0,8000378e <ilock+0x28>
    80003772:	84aa                	mv	s1,a0
    80003774:	451c                	lw	a5,8(a0)
    80003776:	00f05c63          	blez	a5,8000378e <ilock+0x28>
  acquiresleep(&ip->lock);
    8000377a:	0541                	addi	a0,a0,16
    8000377c:	48b000ef          	jal	80004406 <acquiresleep>
  if(ip->valid == 0){
    80003780:	40bc                	lw	a5,64(s1)
    80003782:	cf89                	beqz	a5,8000379c <ilock+0x36>
}
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret
    8000378e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003790:	00004517          	auipc	a0,0x4
    80003794:	ed850513          	addi	a0,a0,-296 # 80007668 <etext+0x668>
    80003798:	88cfd0ef          	jal	80000824 <panic>
    8000379c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000379e:	40dc                	lw	a5,4(s1)
    800037a0:	0047d79b          	srliw	a5,a5,0x4
    800037a4:	0001d597          	auipc	a1,0x1d
    800037a8:	6045a583          	lw	a1,1540(a1) # 80020da8 <sb+0x18>
    800037ac:	9dbd                	addw	a1,a1,a5
    800037ae:	4088                	lw	a0,0(s1)
    800037b0:	91fff0ef          	jal	800030ce <bread>
    800037b4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037b6:	05850593          	addi	a1,a0,88
    800037ba:	40dc                	lw	a5,4(s1)
    800037bc:	8bbd                	andi	a5,a5,15
    800037be:	079a                	slli	a5,a5,0x6
    800037c0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037c2:	00059783          	lh	a5,0(a1)
    800037c6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037ca:	00259783          	lh	a5,2(a1)
    800037ce:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037d2:	00459783          	lh	a5,4(a1)
    800037d6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037da:	00659783          	lh	a5,6(a1)
    800037de:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037e2:	459c                	lw	a5,8(a1)
    800037e4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037e6:	03400613          	li	a2,52
    800037ea:	05b1                	addi	a1,a1,12
    800037ec:	05048513          	addi	a0,s1,80
    800037f0:	d68fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	9e1ff0ef          	jal	800031d6 <brelse>
    ip->valid = 1;
    800037fa:	4785                	li	a5,1
    800037fc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037fe:	04449783          	lh	a5,68(s1)
    80003802:	c399                	beqz	a5,80003808 <ilock+0xa2>
    80003804:	6902                	ld	s2,0(sp)
    80003806:	bfbd                	j	80003784 <ilock+0x1e>
      panic("ilock: no type");
    80003808:	00004517          	auipc	a0,0x4
    8000380c:	e6850513          	addi	a0,a0,-408 # 80007670 <etext+0x670>
    80003810:	814fd0ef          	jal	80000824 <panic>

0000000080003814 <iunlock>:
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	e04a                	sd	s2,0(sp)
    8000381e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003820:	c505                	beqz	a0,80003848 <iunlock+0x34>
    80003822:	84aa                	mv	s1,a0
    80003824:	01050913          	addi	s2,a0,16
    80003828:	854a                	mv	a0,s2
    8000382a:	45b000ef          	jal	80004484 <holdingsleep>
    8000382e:	cd09                	beqz	a0,80003848 <iunlock+0x34>
    80003830:	449c                	lw	a5,8(s1)
    80003832:	00f05b63          	blez	a5,80003848 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003836:	854a                	mv	a0,s2
    80003838:	415000ef          	jal	8000444c <releasesleep>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6902                	ld	s2,0(sp)
    80003844:	6105                	addi	sp,sp,32
    80003846:	8082                	ret
    panic("iunlock");
    80003848:	00004517          	auipc	a0,0x4
    8000384c:	e3850513          	addi	a0,a0,-456 # 80007680 <etext+0x680>
    80003850:	fd5fc0ef          	jal	80000824 <panic>

0000000080003854 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003854:	7179                	addi	sp,sp,-48
    80003856:	f406                	sd	ra,40(sp)
    80003858:	f022                	sd	s0,32(sp)
    8000385a:	ec26                	sd	s1,24(sp)
    8000385c:	e84a                	sd	s2,16(sp)
    8000385e:	e44e                	sd	s3,8(sp)
    80003860:	1800                	addi	s0,sp,48
    80003862:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003864:	05050493          	addi	s1,a0,80
    80003868:	08050913          	addi	s2,a0,128
    8000386c:	a021                	j	80003874 <itrunc+0x20>
    8000386e:	0491                	addi	s1,s1,4
    80003870:	01248b63          	beq	s1,s2,80003886 <itrunc+0x32>
    if(ip->addrs[i]){
    80003874:	408c                	lw	a1,0(s1)
    80003876:	dde5                	beqz	a1,8000386e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003878:	0009a503          	lw	a0,0(s3)
    8000387c:	a47ff0ef          	jal	800032c2 <bfree>
      ip->addrs[i] = 0;
    80003880:	0004a023          	sw	zero,0(s1)
    80003884:	b7ed                	j	8000386e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003886:	0809a583          	lw	a1,128(s3)
    8000388a:	ed89                	bnez	a1,800038a4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000388c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003890:	854e                	mv	a0,s3
    80003892:	e21ff0ef          	jal	800036b2 <iupdate>
}
    80003896:	70a2                	ld	ra,40(sp)
    80003898:	7402                	ld	s0,32(sp)
    8000389a:	64e2                	ld	s1,24(sp)
    8000389c:	6942                	ld	s2,16(sp)
    8000389e:	69a2                	ld	s3,8(sp)
    800038a0:	6145                	addi	sp,sp,48
    800038a2:	8082                	ret
    800038a4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038a6:	0009a503          	lw	a0,0(s3)
    800038aa:	825ff0ef          	jal	800030ce <bread>
    800038ae:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038b0:	05850493          	addi	s1,a0,88
    800038b4:	45850913          	addi	s2,a0,1112
    800038b8:	a021                	j	800038c0 <itrunc+0x6c>
    800038ba:	0491                	addi	s1,s1,4
    800038bc:	01248963          	beq	s1,s2,800038ce <itrunc+0x7a>
      if(a[j])
    800038c0:	408c                	lw	a1,0(s1)
    800038c2:	dde5                	beqz	a1,800038ba <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800038c4:	0009a503          	lw	a0,0(s3)
    800038c8:	9fbff0ef          	jal	800032c2 <bfree>
    800038cc:	b7fd                	j	800038ba <itrunc+0x66>
    brelse(bp);
    800038ce:	8552                	mv	a0,s4
    800038d0:	907ff0ef          	jal	800031d6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038d4:	0809a583          	lw	a1,128(s3)
    800038d8:	0009a503          	lw	a0,0(s3)
    800038dc:	9e7ff0ef          	jal	800032c2 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038e0:	0809a023          	sw	zero,128(s3)
    800038e4:	6a02                	ld	s4,0(sp)
    800038e6:	b75d                	j	8000388c <itrunc+0x38>

00000000800038e8 <iput>:
{
    800038e8:	1101                	addi	sp,sp,-32
    800038ea:	ec06                	sd	ra,24(sp)
    800038ec:	e822                	sd	s0,16(sp)
    800038ee:	e426                	sd	s1,8(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038f4:	0001d517          	auipc	a0,0x1d
    800038f8:	4bc50513          	addi	a0,a0,1212 # 80020db0 <itable>
    800038fc:	b2cfd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003900:	4498                	lw	a4,8(s1)
    80003902:	4785                	li	a5,1
    80003904:	02f70063          	beq	a4,a5,80003924 <iput+0x3c>
  ip->ref--;
    80003908:	449c                	lw	a5,8(s1)
    8000390a:	37fd                	addiw	a5,a5,-1
    8000390c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000390e:	0001d517          	auipc	a0,0x1d
    80003912:	4a250513          	addi	a0,a0,1186 # 80020db0 <itable>
    80003916:	ba6fd0ef          	jal	80000cbc <release>
}
    8000391a:	60e2                	ld	ra,24(sp)
    8000391c:	6442                	ld	s0,16(sp)
    8000391e:	64a2                	ld	s1,8(sp)
    80003920:	6105                	addi	sp,sp,32
    80003922:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003924:	40bc                	lw	a5,64(s1)
    80003926:	d3ed                	beqz	a5,80003908 <iput+0x20>
    80003928:	04a49783          	lh	a5,74(s1)
    8000392c:	fff1                	bnez	a5,80003908 <iput+0x20>
    8000392e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003930:	01048793          	addi	a5,s1,16
    80003934:	893e                	mv	s2,a5
    80003936:	853e                	mv	a0,a5
    80003938:	2cf000ef          	jal	80004406 <acquiresleep>
    release(&itable.lock);
    8000393c:	0001d517          	auipc	a0,0x1d
    80003940:	47450513          	addi	a0,a0,1140 # 80020db0 <itable>
    80003944:	b78fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003948:	8526                	mv	a0,s1
    8000394a:	f0bff0ef          	jal	80003854 <itrunc>
    ip->type = 0;
    8000394e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003952:	8526                	mv	a0,s1
    80003954:	d5fff0ef          	jal	800036b2 <iupdate>
    ip->valid = 0;
    80003958:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000395c:	854a                	mv	a0,s2
    8000395e:	2ef000ef          	jal	8000444c <releasesleep>
    acquire(&itable.lock);
    80003962:	0001d517          	auipc	a0,0x1d
    80003966:	44e50513          	addi	a0,a0,1102 # 80020db0 <itable>
    8000396a:	abefd0ef          	jal	80000c28 <acquire>
    8000396e:	6902                	ld	s2,0(sp)
    80003970:	bf61                	j	80003908 <iput+0x20>

0000000080003972 <iunlockput>:
{
    80003972:	1101                	addi	sp,sp,-32
    80003974:	ec06                	sd	ra,24(sp)
    80003976:	e822                	sd	s0,16(sp)
    80003978:	e426                	sd	s1,8(sp)
    8000397a:	1000                	addi	s0,sp,32
    8000397c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000397e:	e97ff0ef          	jal	80003814 <iunlock>
  iput(ip);
    80003982:	8526                	mv	a0,s1
    80003984:	f65ff0ef          	jal	800038e8 <iput>
}
    80003988:	60e2                	ld	ra,24(sp)
    8000398a:	6442                	ld	s0,16(sp)
    8000398c:	64a2                	ld	s1,8(sp)
    8000398e:	6105                	addi	sp,sp,32
    80003990:	8082                	ret

0000000080003992 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003992:	0001d717          	auipc	a4,0x1d
    80003996:	40a72703          	lw	a4,1034(a4) # 80020d9c <sb+0xc>
    8000399a:	4785                	li	a5,1
    8000399c:	0ae7fe63          	bgeu	a5,a4,80003a58 <ireclaim+0xc6>
{
    800039a0:	7139                	addi	sp,sp,-64
    800039a2:	fc06                	sd	ra,56(sp)
    800039a4:	f822                	sd	s0,48(sp)
    800039a6:	f426                	sd	s1,40(sp)
    800039a8:	f04a                	sd	s2,32(sp)
    800039aa:	ec4e                	sd	s3,24(sp)
    800039ac:	e852                	sd	s4,16(sp)
    800039ae:	e456                	sd	s5,8(sp)
    800039b0:	e05a                	sd	s6,0(sp)
    800039b2:	0080                	addi	s0,sp,64
    800039b4:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039b6:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800039b8:	0001da17          	auipc	s4,0x1d
    800039bc:	3d8a0a13          	addi	s4,s4,984 # 80020d90 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800039c0:	00004b17          	auipc	s6,0x4
    800039c4:	cc8b0b13          	addi	s6,s6,-824 # 80007688 <etext+0x688>
    800039c8:	a099                	j	80003a0e <ireclaim+0x7c>
    800039ca:	85ce                	mv	a1,s3
    800039cc:	855a                	mv	a0,s6
    800039ce:	b2dfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800039d2:	85ce                	mv	a1,s3
    800039d4:	8556                	mv	a0,s5
    800039d6:	b1fff0ef          	jal	800034f4 <iget>
    800039da:	89aa                	mv	s3,a0
    brelse(bp);
    800039dc:	854a                	mv	a0,s2
    800039de:	ff8ff0ef          	jal	800031d6 <brelse>
    if (ip) {
    800039e2:	00098f63          	beqz	s3,80003a00 <ireclaim+0x6e>
      begin_op();
    800039e6:	78c000ef          	jal	80004172 <begin_op>
      ilock(ip);
    800039ea:	854e                	mv	a0,s3
    800039ec:	d7bff0ef          	jal	80003766 <ilock>
      iunlock(ip);
    800039f0:	854e                	mv	a0,s3
    800039f2:	e23ff0ef          	jal	80003814 <iunlock>
      iput(ip);
    800039f6:	854e                	mv	a0,s3
    800039f8:	ef1ff0ef          	jal	800038e8 <iput>
      end_op();
    800039fc:	7e6000ef          	jal	800041e2 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a00:	0485                	addi	s1,s1,1
    80003a02:	00ca2703          	lw	a4,12(s4)
    80003a06:	0004879b          	sext.w	a5,s1
    80003a0a:	02e7fd63          	bgeu	a5,a4,80003a44 <ireclaim+0xb2>
    80003a0e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a12:	0044d593          	srli	a1,s1,0x4
    80003a16:	018a2783          	lw	a5,24(s4)
    80003a1a:	9dbd                	addw	a1,a1,a5
    80003a1c:	8556                	mv	a0,s5
    80003a1e:	eb0ff0ef          	jal	800030ce <bread>
    80003a22:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003a24:	05850793          	addi	a5,a0,88
    80003a28:	00f9f713          	andi	a4,s3,15
    80003a2c:	071a                	slli	a4,a4,0x6
    80003a2e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003a30:	00079703          	lh	a4,0(a5)
    80003a34:	c701                	beqz	a4,80003a3c <ireclaim+0xaa>
    80003a36:	00679783          	lh	a5,6(a5)
    80003a3a:	dbc1                	beqz	a5,800039ca <ireclaim+0x38>
    brelse(bp);
    80003a3c:	854a                	mv	a0,s2
    80003a3e:	f98ff0ef          	jal	800031d6 <brelse>
    if (ip) {
    80003a42:	bf7d                	j	80003a00 <ireclaim+0x6e>
}
    80003a44:	70e2                	ld	ra,56(sp)
    80003a46:	7442                	ld	s0,48(sp)
    80003a48:	74a2                	ld	s1,40(sp)
    80003a4a:	7902                	ld	s2,32(sp)
    80003a4c:	69e2                	ld	s3,24(sp)
    80003a4e:	6a42                	ld	s4,16(sp)
    80003a50:	6aa2                	ld	s5,8(sp)
    80003a52:	6b02                	ld	s6,0(sp)
    80003a54:	6121                	addi	sp,sp,64
    80003a56:	8082                	ret
    80003a58:	8082                	ret

0000000080003a5a <fsinit>:
fsinit(int dev) {
    80003a5a:	1101                	addi	sp,sp,-32
    80003a5c:	ec06                	sd	ra,24(sp)
    80003a5e:	e822                	sd	s0,16(sp)
    80003a60:	e426                	sd	s1,8(sp)
    80003a62:	e04a                	sd	s2,0(sp)
    80003a64:	1000                	addi	s0,sp,32
    80003a66:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a68:	4585                	li	a1,1
    80003a6a:	e64ff0ef          	jal	800030ce <bread>
    80003a6e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a70:	02000613          	li	a2,32
    80003a74:	05850593          	addi	a1,a0,88
    80003a78:	0001d517          	auipc	a0,0x1d
    80003a7c:	31850513          	addi	a0,a0,792 # 80020d90 <sb>
    80003a80:	ad8fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003a84:	8526                	mv	a0,s1
    80003a86:	f50ff0ef          	jal	800031d6 <brelse>
  if(sb.magic != FSMAGIC)
    80003a8a:	0001d717          	auipc	a4,0x1d
    80003a8e:	30672703          	lw	a4,774(a4) # 80020d90 <sb>
    80003a92:	102037b7          	lui	a5,0x10203
    80003a96:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a9a:	02f71263          	bne	a4,a5,80003abe <fsinit+0x64>
  initlog(dev, &sb);
    80003a9e:	0001d597          	auipc	a1,0x1d
    80003aa2:	2f258593          	addi	a1,a1,754 # 80020d90 <sb>
    80003aa6:	854a                	mv	a0,s2
    80003aa8:	648000ef          	jal	800040f0 <initlog>
  ireclaim(dev);
    80003aac:	854a                	mv	a0,s2
    80003aae:	ee5ff0ef          	jal	80003992 <ireclaim>
}
    80003ab2:	60e2                	ld	ra,24(sp)
    80003ab4:	6442                	ld	s0,16(sp)
    80003ab6:	64a2                	ld	s1,8(sp)
    80003ab8:	6902                	ld	s2,0(sp)
    80003aba:	6105                	addi	sp,sp,32
    80003abc:	8082                	ret
    panic("invalid file system");
    80003abe:	00004517          	auipc	a0,0x4
    80003ac2:	bea50513          	addi	a0,a0,-1046 # 800076a8 <etext+0x6a8>
    80003ac6:	d5ffc0ef          	jal	80000824 <panic>

0000000080003aca <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003aca:	1141                	addi	sp,sp,-16
    80003acc:	e406                	sd	ra,8(sp)
    80003ace:	e022                	sd	s0,0(sp)
    80003ad0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ad2:	411c                	lw	a5,0(a0)
    80003ad4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ad6:	415c                	lw	a5,4(a0)
    80003ad8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ada:	04451783          	lh	a5,68(a0)
    80003ade:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ae2:	04a51783          	lh	a5,74(a0)
    80003ae6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003aea:	04c56783          	lwu	a5,76(a0)
    80003aee:	e99c                	sd	a5,16(a1)
}
    80003af0:	60a2                	ld	ra,8(sp)
    80003af2:	6402                	ld	s0,0(sp)
    80003af4:	0141                	addi	sp,sp,16
    80003af6:	8082                	ret

0000000080003af8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003af8:	457c                	lw	a5,76(a0)
    80003afa:	0ed7e663          	bltu	a5,a3,80003be6 <readi+0xee>
{
    80003afe:	7159                	addi	sp,sp,-112
    80003b00:	f486                	sd	ra,104(sp)
    80003b02:	f0a2                	sd	s0,96(sp)
    80003b04:	eca6                	sd	s1,88(sp)
    80003b06:	e0d2                	sd	s4,64(sp)
    80003b08:	fc56                	sd	s5,56(sp)
    80003b0a:	f85a                	sd	s6,48(sp)
    80003b0c:	f45e                	sd	s7,40(sp)
    80003b0e:	1880                	addi	s0,sp,112
    80003b10:	8b2a                	mv	s6,a0
    80003b12:	8bae                	mv	s7,a1
    80003b14:	8a32                	mv	s4,a2
    80003b16:	84b6                	mv	s1,a3
    80003b18:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b1a:	9f35                	addw	a4,a4,a3
    return 0;
    80003b1c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b1e:	0ad76b63          	bltu	a4,a3,80003bd4 <readi+0xdc>
    80003b22:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b24:	00e7f463          	bgeu	a5,a4,80003b2c <readi+0x34>
    n = ip->size - off;
    80003b28:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b2c:	080a8b63          	beqz	s5,80003bc2 <readi+0xca>
    80003b30:	e8ca                	sd	s2,80(sp)
    80003b32:	f062                	sd	s8,32(sp)
    80003b34:	ec66                	sd	s9,24(sp)
    80003b36:	e86a                	sd	s10,16(sp)
    80003b38:	e46e                	sd	s11,8(sp)
    80003b3a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b3c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b40:	5c7d                	li	s8,-1
    80003b42:	a80d                	j	80003b74 <readi+0x7c>
    80003b44:	020d1d93          	slli	s11,s10,0x20
    80003b48:	020ddd93          	srli	s11,s11,0x20
    80003b4c:	05890613          	addi	a2,s2,88
    80003b50:	86ee                	mv	a3,s11
    80003b52:	963e                	add	a2,a2,a5
    80003b54:	85d2                	mv	a1,s4
    80003b56:	855e                	mv	a0,s7
    80003b58:	a63fe0ef          	jal	800025ba <either_copyout>
    80003b5c:	05850363          	beq	a0,s8,80003ba2 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b60:	854a                	mv	a0,s2
    80003b62:	e74ff0ef          	jal	800031d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b66:	013d09bb          	addw	s3,s10,s3
    80003b6a:	009d04bb          	addw	s1,s10,s1
    80003b6e:	9a6e                	add	s4,s4,s11
    80003b70:	0559f363          	bgeu	s3,s5,80003bb6 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b74:	00a4d59b          	srliw	a1,s1,0xa
    80003b78:	855a                	mv	a0,s6
    80003b7a:	8bbff0ef          	jal	80003434 <bmap>
    80003b7e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003b80:	c139                	beqz	a0,80003bc6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003b82:	000b2503          	lw	a0,0(s6)
    80003b86:	d48ff0ef          	jal	800030ce <bread>
    80003b8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b8c:	3ff4f793          	andi	a5,s1,1023
    80003b90:	40fc873b          	subw	a4,s9,a5
    80003b94:	413a86bb          	subw	a3,s5,s3
    80003b98:	8d3a                	mv	s10,a4
    80003b9a:	fae6f5e3          	bgeu	a3,a4,80003b44 <readi+0x4c>
    80003b9e:	8d36                	mv	s10,a3
    80003ba0:	b755                	j	80003b44 <readi+0x4c>
      brelse(bp);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	e32ff0ef          	jal	800031d6 <brelse>
      tot = -1;
    80003ba8:	59fd                	li	s3,-1
      break;
    80003baa:	6946                	ld	s2,80(sp)
    80003bac:	7c02                	ld	s8,32(sp)
    80003bae:	6ce2                	ld	s9,24(sp)
    80003bb0:	6d42                	ld	s10,16(sp)
    80003bb2:	6da2                	ld	s11,8(sp)
    80003bb4:	a831                	j	80003bd0 <readi+0xd8>
    80003bb6:	6946                	ld	s2,80(sp)
    80003bb8:	7c02                	ld	s8,32(sp)
    80003bba:	6ce2                	ld	s9,24(sp)
    80003bbc:	6d42                	ld	s10,16(sp)
    80003bbe:	6da2                	ld	s11,8(sp)
    80003bc0:	a801                	j	80003bd0 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc2:	89d6                	mv	s3,s5
    80003bc4:	a031                	j	80003bd0 <readi+0xd8>
    80003bc6:	6946                	ld	s2,80(sp)
    80003bc8:	7c02                	ld	s8,32(sp)
    80003bca:	6ce2                	ld	s9,24(sp)
    80003bcc:	6d42                	ld	s10,16(sp)
    80003bce:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003bd0:	854e                	mv	a0,s3
    80003bd2:	69a6                	ld	s3,72(sp)
}
    80003bd4:	70a6                	ld	ra,104(sp)
    80003bd6:	7406                	ld	s0,96(sp)
    80003bd8:	64e6                	ld	s1,88(sp)
    80003bda:	6a06                	ld	s4,64(sp)
    80003bdc:	7ae2                	ld	s5,56(sp)
    80003bde:	7b42                	ld	s6,48(sp)
    80003be0:	7ba2                	ld	s7,40(sp)
    80003be2:	6165                	addi	sp,sp,112
    80003be4:	8082                	ret
    return 0;
    80003be6:	4501                	li	a0,0
}
    80003be8:	8082                	ret

0000000080003bea <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bea:	457c                	lw	a5,76(a0)
    80003bec:	0ed7eb63          	bltu	a5,a3,80003ce2 <writei+0xf8>
{
    80003bf0:	7159                	addi	sp,sp,-112
    80003bf2:	f486                	sd	ra,104(sp)
    80003bf4:	f0a2                	sd	s0,96(sp)
    80003bf6:	e8ca                	sd	s2,80(sp)
    80003bf8:	e0d2                	sd	s4,64(sp)
    80003bfa:	fc56                	sd	s5,56(sp)
    80003bfc:	f85a                	sd	s6,48(sp)
    80003bfe:	f45e                	sd	s7,40(sp)
    80003c00:	1880                	addi	s0,sp,112
    80003c02:	8aaa                	mv	s5,a0
    80003c04:	8bae                	mv	s7,a1
    80003c06:	8a32                	mv	s4,a2
    80003c08:	8936                	mv	s2,a3
    80003c0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c0c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c10:	00043737          	lui	a4,0x43
    80003c14:	0cf76963          	bltu	a4,a5,80003ce6 <writei+0xfc>
    80003c18:	0cd7e763          	bltu	a5,a3,80003ce6 <writei+0xfc>
    80003c1c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c1e:	0a0b0a63          	beqz	s6,80003cd2 <writei+0xe8>
    80003c22:	eca6                	sd	s1,88(sp)
    80003c24:	f062                	sd	s8,32(sp)
    80003c26:	ec66                	sd	s9,24(sp)
    80003c28:	e86a                	sd	s10,16(sp)
    80003c2a:	e46e                	sd	s11,8(sp)
    80003c2c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c32:	5c7d                	li	s8,-1
    80003c34:	a825                	j	80003c6c <writei+0x82>
    80003c36:	020d1d93          	slli	s11,s10,0x20
    80003c3a:	020ddd93          	srli	s11,s11,0x20
    80003c3e:	05848513          	addi	a0,s1,88
    80003c42:	86ee                	mv	a3,s11
    80003c44:	8652                	mv	a2,s4
    80003c46:	85de                	mv	a1,s7
    80003c48:	953e                	add	a0,a0,a5
    80003c4a:	9bbfe0ef          	jal	80002604 <either_copyin>
    80003c4e:	05850663          	beq	a0,s8,80003c9a <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c52:	8526                	mv	a0,s1
    80003c54:	6b8000ef          	jal	8000430c <log_write>
    brelse(bp);
    80003c58:	8526                	mv	a0,s1
    80003c5a:	d7cff0ef          	jal	800031d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c5e:	013d09bb          	addw	s3,s10,s3
    80003c62:	012d093b          	addw	s2,s10,s2
    80003c66:	9a6e                	add	s4,s4,s11
    80003c68:	0369fc63          	bgeu	s3,s6,80003ca0 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003c6c:	00a9559b          	srliw	a1,s2,0xa
    80003c70:	8556                	mv	a0,s5
    80003c72:	fc2ff0ef          	jal	80003434 <bmap>
    80003c76:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c78:	c505                	beqz	a0,80003ca0 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003c7a:	000aa503          	lw	a0,0(s5)
    80003c7e:	c50ff0ef          	jal	800030ce <bread>
    80003c82:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c84:	3ff97793          	andi	a5,s2,1023
    80003c88:	40fc873b          	subw	a4,s9,a5
    80003c8c:	413b06bb          	subw	a3,s6,s3
    80003c90:	8d3a                	mv	s10,a4
    80003c92:	fae6f2e3          	bgeu	a3,a4,80003c36 <writei+0x4c>
    80003c96:	8d36                	mv	s10,a3
    80003c98:	bf79                	j	80003c36 <writei+0x4c>
      brelse(bp);
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	d3aff0ef          	jal	800031d6 <brelse>
  }

  if(off > ip->size)
    80003ca0:	04caa783          	lw	a5,76(s5)
    80003ca4:	0327f963          	bgeu	a5,s2,80003cd6 <writei+0xec>
    ip->size = off;
    80003ca8:	052aa623          	sw	s2,76(s5)
    80003cac:	64e6                	ld	s1,88(sp)
    80003cae:	7c02                	ld	s8,32(sp)
    80003cb0:	6ce2                	ld	s9,24(sp)
    80003cb2:	6d42                	ld	s10,16(sp)
    80003cb4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cb6:	8556                	mv	a0,s5
    80003cb8:	9fbff0ef          	jal	800036b2 <iupdate>

  return tot;
    80003cbc:	854e                	mv	a0,s3
    80003cbe:	69a6                	ld	s3,72(sp)
}
    80003cc0:	70a6                	ld	ra,104(sp)
    80003cc2:	7406                	ld	s0,96(sp)
    80003cc4:	6946                	ld	s2,80(sp)
    80003cc6:	6a06                	ld	s4,64(sp)
    80003cc8:	7ae2                	ld	s5,56(sp)
    80003cca:	7b42                	ld	s6,48(sp)
    80003ccc:	7ba2                	ld	s7,40(sp)
    80003cce:	6165                	addi	sp,sp,112
    80003cd0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd2:	89da                	mv	s3,s6
    80003cd4:	b7cd                	j	80003cb6 <writei+0xcc>
    80003cd6:	64e6                	ld	s1,88(sp)
    80003cd8:	7c02                	ld	s8,32(sp)
    80003cda:	6ce2                	ld	s9,24(sp)
    80003cdc:	6d42                	ld	s10,16(sp)
    80003cde:	6da2                	ld	s11,8(sp)
    80003ce0:	bfd9                	j	80003cb6 <writei+0xcc>
    return -1;
    80003ce2:	557d                	li	a0,-1
}
    80003ce4:	8082                	ret
    return -1;
    80003ce6:	557d                	li	a0,-1
    80003ce8:	bfe1                	j	80003cc0 <writei+0xd6>

0000000080003cea <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cea:	1141                	addi	sp,sp,-16
    80003cec:	e406                	sd	ra,8(sp)
    80003cee:	e022                	sd	s0,0(sp)
    80003cf0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cf2:	4639                	li	a2,14
    80003cf4:	8d8fd0ef          	jal	80000dcc <strncmp>
}
    80003cf8:	60a2                	ld	ra,8(sp)
    80003cfa:	6402                	ld	s0,0(sp)
    80003cfc:	0141                	addi	sp,sp,16
    80003cfe:	8082                	ret

0000000080003d00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d00:	711d                	addi	sp,sp,-96
    80003d02:	ec86                	sd	ra,88(sp)
    80003d04:	e8a2                	sd	s0,80(sp)
    80003d06:	e4a6                	sd	s1,72(sp)
    80003d08:	e0ca                	sd	s2,64(sp)
    80003d0a:	fc4e                	sd	s3,56(sp)
    80003d0c:	f852                	sd	s4,48(sp)
    80003d0e:	f456                	sd	s5,40(sp)
    80003d10:	f05a                	sd	s6,32(sp)
    80003d12:	ec5e                	sd	s7,24(sp)
    80003d14:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d16:	04451703          	lh	a4,68(a0)
    80003d1a:	4785                	li	a5,1
    80003d1c:	00f71f63          	bne	a4,a5,80003d3a <dirlookup+0x3a>
    80003d20:	892a                	mv	s2,a0
    80003d22:	8aae                	mv	s5,a1
    80003d24:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d26:	457c                	lw	a5,76(a0)
    80003d28:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d2a:	fa040a13          	addi	s4,s0,-96
    80003d2e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003d30:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d34:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d36:	e39d                	bnez	a5,80003d5c <dirlookup+0x5c>
    80003d38:	a8b9                	j	80003d96 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003d3a:	00004517          	auipc	a0,0x4
    80003d3e:	98650513          	addi	a0,a0,-1658 # 800076c0 <etext+0x6c0>
    80003d42:	ae3fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003d46:	00004517          	auipc	a0,0x4
    80003d4a:	99250513          	addi	a0,a0,-1646 # 800076d8 <etext+0x6d8>
    80003d4e:	ad7fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d52:	24c1                	addiw	s1,s1,16
    80003d54:	04c92783          	lw	a5,76(s2)
    80003d58:	02f4fe63          	bgeu	s1,a5,80003d94 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d5c:	874e                	mv	a4,s3
    80003d5e:	86a6                	mv	a3,s1
    80003d60:	8652                	mv	a2,s4
    80003d62:	4581                	li	a1,0
    80003d64:	854a                	mv	a0,s2
    80003d66:	d93ff0ef          	jal	80003af8 <readi>
    80003d6a:	fd351ee3          	bne	a0,s3,80003d46 <dirlookup+0x46>
    if(de.inum == 0)
    80003d6e:	fa045783          	lhu	a5,-96(s0)
    80003d72:	d3e5                	beqz	a5,80003d52 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003d74:	85da                	mv	a1,s6
    80003d76:	8556                	mv	a0,s5
    80003d78:	f73ff0ef          	jal	80003cea <namecmp>
    80003d7c:	f979                	bnez	a0,80003d52 <dirlookup+0x52>
      if(poff)
    80003d7e:	000b8463          	beqz	s7,80003d86 <dirlookup+0x86>
        *poff = off;
    80003d82:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003d86:	fa045583          	lhu	a1,-96(s0)
    80003d8a:	00092503          	lw	a0,0(s2)
    80003d8e:	f66ff0ef          	jal	800034f4 <iget>
    80003d92:	a011                	j	80003d96 <dirlookup+0x96>
  return 0;
    80003d94:	4501                	li	a0,0
}
    80003d96:	60e6                	ld	ra,88(sp)
    80003d98:	6446                	ld	s0,80(sp)
    80003d9a:	64a6                	ld	s1,72(sp)
    80003d9c:	6906                	ld	s2,64(sp)
    80003d9e:	79e2                	ld	s3,56(sp)
    80003da0:	7a42                	ld	s4,48(sp)
    80003da2:	7aa2                	ld	s5,40(sp)
    80003da4:	7b02                	ld	s6,32(sp)
    80003da6:	6be2                	ld	s7,24(sp)
    80003da8:	6125                	addi	sp,sp,96
    80003daa:	8082                	ret

0000000080003dac <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003dac:	711d                	addi	sp,sp,-96
    80003dae:	ec86                	sd	ra,88(sp)
    80003db0:	e8a2                	sd	s0,80(sp)
    80003db2:	e4a6                	sd	s1,72(sp)
    80003db4:	e0ca                	sd	s2,64(sp)
    80003db6:	fc4e                	sd	s3,56(sp)
    80003db8:	f852                	sd	s4,48(sp)
    80003dba:	f456                	sd	s5,40(sp)
    80003dbc:	f05a                	sd	s6,32(sp)
    80003dbe:	ec5e                	sd	s7,24(sp)
    80003dc0:	e862                	sd	s8,16(sp)
    80003dc2:	e466                	sd	s9,8(sp)
    80003dc4:	e06a                	sd	s10,0(sp)
    80003dc6:	1080                	addi	s0,sp,96
    80003dc8:	84aa                	mv	s1,a0
    80003dca:	8b2e                	mv	s6,a1
    80003dcc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003dce:	00054703          	lbu	a4,0(a0)
    80003dd2:	02f00793          	li	a5,47
    80003dd6:	00f70f63          	beq	a4,a5,80003df4 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003dda:	bd3fd0ef          	jal	800019ac <myproc>
    80003dde:	15853503          	ld	a0,344(a0)
    80003de2:	94fff0ef          	jal	80003730 <idup>
    80003de6:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003de8:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003dec:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003dee:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003df0:	4b85                	li	s7,1
    80003df2:	a879                	j	80003e90 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003df4:	4585                	li	a1,1
    80003df6:	852e                	mv	a0,a1
    80003df8:	efcff0ef          	jal	800034f4 <iget>
    80003dfc:	8a2a                	mv	s4,a0
    80003dfe:	b7ed                	j	80003de8 <namex+0x3c>
      iunlockput(ip);
    80003e00:	8552                	mv	a0,s4
    80003e02:	b71ff0ef          	jal	80003972 <iunlockput>
      return 0;
    80003e06:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e08:	8552                	mv	a0,s4
    80003e0a:	60e6                	ld	ra,88(sp)
    80003e0c:	6446                	ld	s0,80(sp)
    80003e0e:	64a6                	ld	s1,72(sp)
    80003e10:	6906                	ld	s2,64(sp)
    80003e12:	79e2                	ld	s3,56(sp)
    80003e14:	7a42                	ld	s4,48(sp)
    80003e16:	7aa2                	ld	s5,40(sp)
    80003e18:	7b02                	ld	s6,32(sp)
    80003e1a:	6be2                	ld	s7,24(sp)
    80003e1c:	6c42                	ld	s8,16(sp)
    80003e1e:	6ca2                	ld	s9,8(sp)
    80003e20:	6d02                	ld	s10,0(sp)
    80003e22:	6125                	addi	sp,sp,96
    80003e24:	8082                	ret
      iunlock(ip);
    80003e26:	8552                	mv	a0,s4
    80003e28:	9edff0ef          	jal	80003814 <iunlock>
      return ip;
    80003e2c:	bff1                	j	80003e08 <namex+0x5c>
      iunlockput(ip);
    80003e2e:	8552                	mv	a0,s4
    80003e30:	b43ff0ef          	jal	80003972 <iunlockput>
      return 0;
    80003e34:	8a4a                	mv	s4,s2
    80003e36:	bfc9                	j	80003e08 <namex+0x5c>
  len = path - s;
    80003e38:	40990633          	sub	a2,s2,s1
    80003e3c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003e40:	09ac5463          	bge	s8,s10,80003ec8 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003e44:	8666                	mv	a2,s9
    80003e46:	85a6                	mv	a1,s1
    80003e48:	8556                	mv	a0,s5
    80003e4a:	f0ffc0ef          	jal	80000d58 <memmove>
    80003e4e:	84ca                	mv	s1,s2
  while(*path == '/')
    80003e50:	0004c783          	lbu	a5,0(s1)
    80003e54:	01379763          	bne	a5,s3,80003e62 <namex+0xb6>
    path++;
    80003e58:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e5a:	0004c783          	lbu	a5,0(s1)
    80003e5e:	ff378de3          	beq	a5,s3,80003e58 <namex+0xac>
    ilock(ip);
    80003e62:	8552                	mv	a0,s4
    80003e64:	903ff0ef          	jal	80003766 <ilock>
    if(ip->type != T_DIR){
    80003e68:	044a1783          	lh	a5,68(s4)
    80003e6c:	f9779ae3          	bne	a5,s7,80003e00 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003e70:	000b0563          	beqz	s6,80003e7a <namex+0xce>
    80003e74:	0004c783          	lbu	a5,0(s1)
    80003e78:	d7dd                	beqz	a5,80003e26 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e7a:	4601                	li	a2,0
    80003e7c:	85d6                	mv	a1,s5
    80003e7e:	8552                	mv	a0,s4
    80003e80:	e81ff0ef          	jal	80003d00 <dirlookup>
    80003e84:	892a                	mv	s2,a0
    80003e86:	d545                	beqz	a0,80003e2e <namex+0x82>
    iunlockput(ip);
    80003e88:	8552                	mv	a0,s4
    80003e8a:	ae9ff0ef          	jal	80003972 <iunlockput>
    ip = next;
    80003e8e:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003e90:	0004c783          	lbu	a5,0(s1)
    80003e94:	01379763          	bne	a5,s3,80003ea2 <namex+0xf6>
    path++;
    80003e98:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e9a:	0004c783          	lbu	a5,0(s1)
    80003e9e:	ff378de3          	beq	a5,s3,80003e98 <namex+0xec>
  if(*path == 0)
    80003ea2:	cf8d                	beqz	a5,80003edc <namex+0x130>
  while(*path != '/' && *path != 0)
    80003ea4:	0004c783          	lbu	a5,0(s1)
    80003ea8:	fd178713          	addi	a4,a5,-47
    80003eac:	cb19                	beqz	a4,80003ec2 <namex+0x116>
    80003eae:	cb91                	beqz	a5,80003ec2 <namex+0x116>
    80003eb0:	8926                	mv	s2,s1
    path++;
    80003eb2:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003eb4:	00094783          	lbu	a5,0(s2)
    80003eb8:	fd178713          	addi	a4,a5,-47
    80003ebc:	df35                	beqz	a4,80003e38 <namex+0x8c>
    80003ebe:	fbf5                	bnez	a5,80003eb2 <namex+0x106>
    80003ec0:	bfa5                	j	80003e38 <namex+0x8c>
    80003ec2:	8926                	mv	s2,s1
  len = path - s;
    80003ec4:	4d01                	li	s10,0
    80003ec6:	4601                	li	a2,0
    memmove(name, s, len);
    80003ec8:	2601                	sext.w	a2,a2
    80003eca:	85a6                	mv	a1,s1
    80003ecc:	8556                	mv	a0,s5
    80003ece:	e8bfc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003ed2:	9d56                	add	s10,s10,s5
    80003ed4:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb568>
    80003ed8:	84ca                	mv	s1,s2
    80003eda:	bf9d                	j	80003e50 <namex+0xa4>
  if(nameiparent){
    80003edc:	f20b06e3          	beqz	s6,80003e08 <namex+0x5c>
    iput(ip);
    80003ee0:	8552                	mv	a0,s4
    80003ee2:	a07ff0ef          	jal	800038e8 <iput>
    return 0;
    80003ee6:	4a01                	li	s4,0
    80003ee8:	b705                	j	80003e08 <namex+0x5c>

0000000080003eea <dirlink>:
{
    80003eea:	715d                	addi	sp,sp,-80
    80003eec:	e486                	sd	ra,72(sp)
    80003eee:	e0a2                	sd	s0,64(sp)
    80003ef0:	f84a                	sd	s2,48(sp)
    80003ef2:	ec56                	sd	s5,24(sp)
    80003ef4:	e85a                	sd	s6,16(sp)
    80003ef6:	0880                	addi	s0,sp,80
    80003ef8:	892a                	mv	s2,a0
    80003efa:	8aae                	mv	s5,a1
    80003efc:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003efe:	4601                	li	a2,0
    80003f00:	e01ff0ef          	jal	80003d00 <dirlookup>
    80003f04:	ed1d                	bnez	a0,80003f42 <dirlink+0x58>
    80003f06:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f08:	04c92483          	lw	s1,76(s2)
    80003f0c:	c4b9                	beqz	s1,80003f5a <dirlink+0x70>
    80003f0e:	f44e                	sd	s3,40(sp)
    80003f10:	f052                	sd	s4,32(sp)
    80003f12:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f14:	fb040a13          	addi	s4,s0,-80
    80003f18:	49c1                	li	s3,16
    80003f1a:	874e                	mv	a4,s3
    80003f1c:	86a6                	mv	a3,s1
    80003f1e:	8652                	mv	a2,s4
    80003f20:	4581                	li	a1,0
    80003f22:	854a                	mv	a0,s2
    80003f24:	bd5ff0ef          	jal	80003af8 <readi>
    80003f28:	03351163          	bne	a0,s3,80003f4a <dirlink+0x60>
    if(de.inum == 0)
    80003f2c:	fb045783          	lhu	a5,-80(s0)
    80003f30:	c39d                	beqz	a5,80003f56 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f32:	24c1                	addiw	s1,s1,16
    80003f34:	04c92783          	lw	a5,76(s2)
    80003f38:	fef4e1e3          	bltu	s1,a5,80003f1a <dirlink+0x30>
    80003f3c:	79a2                	ld	s3,40(sp)
    80003f3e:	7a02                	ld	s4,32(sp)
    80003f40:	a829                	j	80003f5a <dirlink+0x70>
    iput(ip);
    80003f42:	9a7ff0ef          	jal	800038e8 <iput>
    return -1;
    80003f46:	557d                	li	a0,-1
    80003f48:	a83d                	j	80003f86 <dirlink+0x9c>
      panic("dirlink read");
    80003f4a:	00003517          	auipc	a0,0x3
    80003f4e:	79e50513          	addi	a0,a0,1950 # 800076e8 <etext+0x6e8>
    80003f52:	8d3fc0ef          	jal	80000824 <panic>
    80003f56:	79a2                	ld	s3,40(sp)
    80003f58:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003f5a:	4639                	li	a2,14
    80003f5c:	85d6                	mv	a1,s5
    80003f5e:	fb240513          	addi	a0,s0,-78
    80003f62:	ea5fc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003f66:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f6a:	4741                	li	a4,16
    80003f6c:	86a6                	mv	a3,s1
    80003f6e:	fb040613          	addi	a2,s0,-80
    80003f72:	4581                	li	a1,0
    80003f74:	854a                	mv	a0,s2
    80003f76:	c75ff0ef          	jal	80003bea <writei>
    80003f7a:	1541                	addi	a0,a0,-16
    80003f7c:	00a03533          	snez	a0,a0
    80003f80:	40a0053b          	negw	a0,a0
    80003f84:	74e2                	ld	s1,56(sp)
}
    80003f86:	60a6                	ld	ra,72(sp)
    80003f88:	6406                	ld	s0,64(sp)
    80003f8a:	7942                	ld	s2,48(sp)
    80003f8c:	6ae2                	ld	s5,24(sp)
    80003f8e:	6b42                	ld	s6,16(sp)
    80003f90:	6161                	addi	sp,sp,80
    80003f92:	8082                	ret

0000000080003f94 <namei>:

struct inode*
namei(char *path)
{
    80003f94:	1101                	addi	sp,sp,-32
    80003f96:	ec06                	sd	ra,24(sp)
    80003f98:	e822                	sd	s0,16(sp)
    80003f9a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f9c:	fe040613          	addi	a2,s0,-32
    80003fa0:	4581                	li	a1,0
    80003fa2:	e0bff0ef          	jal	80003dac <namex>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	6105                	addi	sp,sp,32
    80003fac:	8082                	ret

0000000080003fae <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fae:	1141                	addi	sp,sp,-16
    80003fb0:	e406                	sd	ra,8(sp)
    80003fb2:	e022                	sd	s0,0(sp)
    80003fb4:	0800                	addi	s0,sp,16
    80003fb6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fb8:	4585                	li	a1,1
    80003fba:	df3ff0ef          	jal	80003dac <namex>
}
    80003fbe:	60a2                	ld	ra,8(sp)
    80003fc0:	6402                	ld	s0,0(sp)
    80003fc2:	0141                	addi	sp,sp,16
    80003fc4:	8082                	ret

0000000080003fc6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fc6:	1101                	addi	sp,sp,-32
    80003fc8:	ec06                	sd	ra,24(sp)
    80003fca:	e822                	sd	s0,16(sp)
    80003fcc:	e426                	sd	s1,8(sp)
    80003fce:	e04a                	sd	s2,0(sp)
    80003fd0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fd2:	0001f917          	auipc	s2,0x1f
    80003fd6:	88690913          	addi	s2,s2,-1914 # 80022858 <log>
    80003fda:	01892583          	lw	a1,24(s2)
    80003fde:	02492503          	lw	a0,36(s2)
    80003fe2:	8ecff0ef          	jal	800030ce <bread>
    80003fe6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fe8:	02892603          	lw	a2,40(s2)
    80003fec:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fee:	00c05f63          	blez	a2,8000400c <write_head+0x46>
    80003ff2:	0001f717          	auipc	a4,0x1f
    80003ff6:	89270713          	addi	a4,a4,-1902 # 80022884 <log+0x2c>
    80003ffa:	87aa                	mv	a5,a0
    80003ffc:	060a                	slli	a2,a2,0x2
    80003ffe:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004000:	4314                	lw	a3,0(a4)
    80004002:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004004:	0711                	addi	a4,a4,4
    80004006:	0791                	addi	a5,a5,4
    80004008:	fec79ce3          	bne	a5,a2,80004000 <write_head+0x3a>
  }
  bwrite(buf);
    8000400c:	8526                	mv	a0,s1
    8000400e:	996ff0ef          	jal	800031a4 <bwrite>
  brelse(buf);
    80004012:	8526                	mv	a0,s1
    80004014:	9c2ff0ef          	jal	800031d6 <brelse>
}
    80004018:	60e2                	ld	ra,24(sp)
    8000401a:	6442                	ld	s0,16(sp)
    8000401c:	64a2                	ld	s1,8(sp)
    8000401e:	6902                	ld	s2,0(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004024:	0001f797          	auipc	a5,0x1f
    80004028:	85c7a783          	lw	a5,-1956(a5) # 80022880 <log+0x28>
    8000402c:	0cf05163          	blez	a5,800040ee <install_trans+0xca>
{
    80004030:	715d                	addi	sp,sp,-80
    80004032:	e486                	sd	ra,72(sp)
    80004034:	e0a2                	sd	s0,64(sp)
    80004036:	fc26                	sd	s1,56(sp)
    80004038:	f84a                	sd	s2,48(sp)
    8000403a:	f44e                	sd	s3,40(sp)
    8000403c:	f052                	sd	s4,32(sp)
    8000403e:	ec56                	sd	s5,24(sp)
    80004040:	e85a                	sd	s6,16(sp)
    80004042:	e45e                	sd	s7,8(sp)
    80004044:	e062                	sd	s8,0(sp)
    80004046:	0880                	addi	s0,sp,80
    80004048:	8b2a                	mv	s6,a0
    8000404a:	0001fa97          	auipc	s5,0x1f
    8000404e:	83aa8a93          	addi	s5,s5,-1990 # 80022884 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004052:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004054:	00003c17          	auipc	s8,0x3
    80004058:	6a4c0c13          	addi	s8,s8,1700 # 800076f8 <etext+0x6f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000405c:	0001ea17          	auipc	s4,0x1e
    80004060:	7fca0a13          	addi	s4,s4,2044 # 80022858 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004064:	40000b93          	li	s7,1024
    80004068:	a025                	j	80004090 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000406a:	000aa603          	lw	a2,0(s5)
    8000406e:	85ce                	mv	a1,s3
    80004070:	8562                	mv	a0,s8
    80004072:	c88fc0ef          	jal	800004fa <printf>
    80004076:	a839                	j	80004094 <install_trans+0x70>
    brelse(lbuf);
    80004078:	854a                	mv	a0,s2
    8000407a:	95cff0ef          	jal	800031d6 <brelse>
    brelse(dbuf);
    8000407e:	8526                	mv	a0,s1
    80004080:	956ff0ef          	jal	800031d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004084:	2985                	addiw	s3,s3,1
    80004086:	0a91                	addi	s5,s5,4
    80004088:	028a2783          	lw	a5,40(s4)
    8000408c:	04f9d563          	bge	s3,a5,800040d6 <install_trans+0xb2>
    if(recovering) {
    80004090:	fc0b1de3          	bnez	s6,8000406a <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004094:	018a2583          	lw	a1,24(s4)
    80004098:	013585bb          	addw	a1,a1,s3
    8000409c:	2585                	addiw	a1,a1,1
    8000409e:	024a2503          	lw	a0,36(s4)
    800040a2:	82cff0ef          	jal	800030ce <bread>
    800040a6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040a8:	000aa583          	lw	a1,0(s5)
    800040ac:	024a2503          	lw	a0,36(s4)
    800040b0:	81eff0ef          	jal	800030ce <bread>
    800040b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040b6:	865e                	mv	a2,s7
    800040b8:	05890593          	addi	a1,s2,88
    800040bc:	05850513          	addi	a0,a0,88
    800040c0:	c99fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040c4:	8526                	mv	a0,s1
    800040c6:	8deff0ef          	jal	800031a4 <bwrite>
    if(recovering == 0)
    800040ca:	fa0b17e3          	bnez	s6,80004078 <install_trans+0x54>
      bunpin(dbuf);
    800040ce:	8526                	mv	a0,s1
    800040d0:	9beff0ef          	jal	8000328e <bunpin>
    800040d4:	b755                	j	80004078 <install_trans+0x54>
}
    800040d6:	60a6                	ld	ra,72(sp)
    800040d8:	6406                	ld	s0,64(sp)
    800040da:	74e2                	ld	s1,56(sp)
    800040dc:	7942                	ld	s2,48(sp)
    800040de:	79a2                	ld	s3,40(sp)
    800040e0:	7a02                	ld	s4,32(sp)
    800040e2:	6ae2                	ld	s5,24(sp)
    800040e4:	6b42                	ld	s6,16(sp)
    800040e6:	6ba2                	ld	s7,8(sp)
    800040e8:	6c02                	ld	s8,0(sp)
    800040ea:	6161                	addi	sp,sp,80
    800040ec:	8082                	ret
    800040ee:	8082                	ret

00000000800040f0 <initlog>:
{
    800040f0:	7179                	addi	sp,sp,-48
    800040f2:	f406                	sd	ra,40(sp)
    800040f4:	f022                	sd	s0,32(sp)
    800040f6:	ec26                	sd	s1,24(sp)
    800040f8:	e84a                	sd	s2,16(sp)
    800040fa:	e44e                	sd	s3,8(sp)
    800040fc:	1800                	addi	s0,sp,48
    800040fe:	84aa                	mv	s1,a0
    80004100:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004102:	0001e917          	auipc	s2,0x1e
    80004106:	75690913          	addi	s2,s2,1878 # 80022858 <log>
    8000410a:	00003597          	auipc	a1,0x3
    8000410e:	60e58593          	addi	a1,a1,1550 # 80007718 <etext+0x718>
    80004112:	854a                	mv	a0,s2
    80004114:	a8bfc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80004118:	0149a583          	lw	a1,20(s3)
    8000411c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80004120:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80004124:	8526                	mv	a0,s1
    80004126:	fa9fe0ef          	jal	800030ce <bread>
  log.lh.n = lh->n;
    8000412a:	4d30                	lw	a2,88(a0)
    8000412c:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80004130:	00c05f63          	blez	a2,8000414e <initlog+0x5e>
    80004134:	87aa                	mv	a5,a0
    80004136:	0001e717          	auipc	a4,0x1e
    8000413a:	74e70713          	addi	a4,a4,1870 # 80022884 <log+0x2c>
    8000413e:	060a                	slli	a2,a2,0x2
    80004140:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004142:	4ff4                	lw	a3,92(a5)
    80004144:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004146:	0791                	addi	a5,a5,4
    80004148:	0711                	addi	a4,a4,4
    8000414a:	fec79ce3          	bne	a5,a2,80004142 <initlog+0x52>
  brelse(buf);
    8000414e:	888ff0ef          	jal	800031d6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004152:	4505                	li	a0,1
    80004154:	ed1ff0ef          	jal	80004024 <install_trans>
  log.lh.n = 0;
    80004158:	0001e797          	auipc	a5,0x1e
    8000415c:	7207a423          	sw	zero,1832(a5) # 80022880 <log+0x28>
  write_head(); // clear the log
    80004160:	e67ff0ef          	jal	80003fc6 <write_head>
}
    80004164:	70a2                	ld	ra,40(sp)
    80004166:	7402                	ld	s0,32(sp)
    80004168:	64e2                	ld	s1,24(sp)
    8000416a:	6942                	ld	s2,16(sp)
    8000416c:	69a2                	ld	s3,8(sp)
    8000416e:	6145                	addi	sp,sp,48
    80004170:	8082                	ret

0000000080004172 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004172:	1101                	addi	sp,sp,-32
    80004174:	ec06                	sd	ra,24(sp)
    80004176:	e822                	sd	s0,16(sp)
    80004178:	e426                	sd	s1,8(sp)
    8000417a:	e04a                	sd	s2,0(sp)
    8000417c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000417e:	0001e517          	auipc	a0,0x1e
    80004182:	6da50513          	addi	a0,a0,1754 # 80022858 <log>
    80004186:	aa3fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    8000418a:	0001e497          	auipc	s1,0x1e
    8000418e:	6ce48493          	addi	s1,s1,1742 # 80022858 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004192:	4979                	li	s2,30
    80004194:	a029                	j	8000419e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004196:	85a6                	mv	a1,s1
    80004198:	8526                	mv	a0,s1
    8000419a:	8c6fe0ef          	jal	80002260 <sleep>
    if(log.committing){
    8000419e:	509c                	lw	a5,32(s1)
    800041a0:	fbfd                	bnez	a5,80004196 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800041a2:	4cd8                	lw	a4,28(s1)
    800041a4:	2705                	addiw	a4,a4,1
    800041a6:	0027179b          	slliw	a5,a4,0x2
    800041aa:	9fb9                	addw	a5,a5,a4
    800041ac:	0017979b          	slliw	a5,a5,0x1
    800041b0:	5494                	lw	a3,40(s1)
    800041b2:	9fb5                	addw	a5,a5,a3
    800041b4:	00f95763          	bge	s2,a5,800041c2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041b8:	85a6                	mv	a1,s1
    800041ba:	8526                	mv	a0,s1
    800041bc:	8a4fe0ef          	jal	80002260 <sleep>
    800041c0:	bff9                	j	8000419e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800041c2:	0001e797          	auipc	a5,0x1e
    800041c6:	6ae7a923          	sw	a4,1714(a5) # 80022874 <log+0x1c>
      release(&log.lock);
    800041ca:	0001e517          	auipc	a0,0x1e
    800041ce:	68e50513          	addi	a0,a0,1678 # 80022858 <log>
    800041d2:	aebfc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    800041d6:	60e2                	ld	ra,24(sp)
    800041d8:	6442                	ld	s0,16(sp)
    800041da:	64a2                	ld	s1,8(sp)
    800041dc:	6902                	ld	s2,0(sp)
    800041de:	6105                	addi	sp,sp,32
    800041e0:	8082                	ret

00000000800041e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041e2:	7139                	addi	sp,sp,-64
    800041e4:	fc06                	sd	ra,56(sp)
    800041e6:	f822                	sd	s0,48(sp)
    800041e8:	f426                	sd	s1,40(sp)
    800041ea:	f04a                	sd	s2,32(sp)
    800041ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041ee:	0001e497          	auipc	s1,0x1e
    800041f2:	66a48493          	addi	s1,s1,1642 # 80022858 <log>
    800041f6:	8526                	mv	a0,s1
    800041f8:	a31fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    800041fc:	4cdc                	lw	a5,28(s1)
    800041fe:	37fd                	addiw	a5,a5,-1
    80004200:	893e                	mv	s2,a5
    80004202:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004204:	509c                	lw	a5,32(s1)
    80004206:	e7b1                	bnez	a5,80004252 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004208:	04091e63          	bnez	s2,80004264 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    8000420c:	0001e497          	auipc	s1,0x1e
    80004210:	64c48493          	addi	s1,s1,1612 # 80022858 <log>
    80004214:	4785                	li	a5,1
    80004216:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004218:	8526                	mv	a0,s1
    8000421a:	aa3fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000421e:	549c                	lw	a5,40(s1)
    80004220:	06f04463          	bgtz	a5,80004288 <end_op+0xa6>
    acquire(&log.lock);
    80004224:	0001e517          	auipc	a0,0x1e
    80004228:	63450513          	addi	a0,a0,1588 # 80022858 <log>
    8000422c:	9fdfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004230:	0001e797          	auipc	a5,0x1e
    80004234:	6407a423          	sw	zero,1608(a5) # 80022878 <log+0x20>
    wakeup(&log);
    80004238:	0001e517          	auipc	a0,0x1e
    8000423c:	62050513          	addi	a0,a0,1568 # 80022858 <log>
    80004240:	86cfe0ef          	jal	800022ac <wakeup>
    release(&log.lock);
    80004244:	0001e517          	auipc	a0,0x1e
    80004248:	61450513          	addi	a0,a0,1556 # 80022858 <log>
    8000424c:	a71fc0ef          	jal	80000cbc <release>
}
    80004250:	a035                	j	8000427c <end_op+0x9a>
    80004252:	ec4e                	sd	s3,24(sp)
    80004254:	e852                	sd	s4,16(sp)
    80004256:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004258:	00003517          	auipc	a0,0x3
    8000425c:	4c850513          	addi	a0,a0,1224 # 80007720 <etext+0x720>
    80004260:	dc4fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80004264:	0001e517          	auipc	a0,0x1e
    80004268:	5f450513          	addi	a0,a0,1524 # 80022858 <log>
    8000426c:	840fe0ef          	jal	800022ac <wakeup>
  release(&log.lock);
    80004270:	0001e517          	auipc	a0,0x1e
    80004274:	5e850513          	addi	a0,a0,1512 # 80022858 <log>
    80004278:	a45fc0ef          	jal	80000cbc <release>
}
    8000427c:	70e2                	ld	ra,56(sp)
    8000427e:	7442                	ld	s0,48(sp)
    80004280:	74a2                	ld	s1,40(sp)
    80004282:	7902                	ld	s2,32(sp)
    80004284:	6121                	addi	sp,sp,64
    80004286:	8082                	ret
    80004288:	ec4e                	sd	s3,24(sp)
    8000428a:	e852                	sd	s4,16(sp)
    8000428c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000428e:	0001ea97          	auipc	s5,0x1e
    80004292:	5f6a8a93          	addi	s5,s5,1526 # 80022884 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004296:	0001ea17          	auipc	s4,0x1e
    8000429a:	5c2a0a13          	addi	s4,s4,1474 # 80022858 <log>
    8000429e:	018a2583          	lw	a1,24(s4)
    800042a2:	012585bb          	addw	a1,a1,s2
    800042a6:	2585                	addiw	a1,a1,1
    800042a8:	024a2503          	lw	a0,36(s4)
    800042ac:	e23fe0ef          	jal	800030ce <bread>
    800042b0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042b2:	000aa583          	lw	a1,0(s5)
    800042b6:	024a2503          	lw	a0,36(s4)
    800042ba:	e15fe0ef          	jal	800030ce <bread>
    800042be:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042c0:	40000613          	li	a2,1024
    800042c4:	05850593          	addi	a1,a0,88
    800042c8:	05848513          	addi	a0,s1,88
    800042cc:	a8dfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    800042d0:	8526                	mv	a0,s1
    800042d2:	ed3fe0ef          	jal	800031a4 <bwrite>
    brelse(from);
    800042d6:	854e                	mv	a0,s3
    800042d8:	efffe0ef          	jal	800031d6 <brelse>
    brelse(to);
    800042dc:	8526                	mv	a0,s1
    800042de:	ef9fe0ef          	jal	800031d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e2:	2905                	addiw	s2,s2,1
    800042e4:	0a91                	addi	s5,s5,4
    800042e6:	028a2783          	lw	a5,40(s4)
    800042ea:	faf94ae3          	blt	s2,a5,8000429e <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042ee:	cd9ff0ef          	jal	80003fc6 <write_head>
    install_trans(0); // Now install writes to home locations
    800042f2:	4501                	li	a0,0
    800042f4:	d31ff0ef          	jal	80004024 <install_trans>
    log.lh.n = 0;
    800042f8:	0001e797          	auipc	a5,0x1e
    800042fc:	5807a423          	sw	zero,1416(a5) # 80022880 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004300:	cc7ff0ef          	jal	80003fc6 <write_head>
    80004304:	69e2                	ld	s3,24(sp)
    80004306:	6a42                	ld	s4,16(sp)
    80004308:	6aa2                	ld	s5,8(sp)
    8000430a:	bf29                	j	80004224 <end_op+0x42>

000000008000430c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000430c:	1101                	addi	sp,sp,-32
    8000430e:	ec06                	sd	ra,24(sp)
    80004310:	e822                	sd	s0,16(sp)
    80004312:	e426                	sd	s1,8(sp)
    80004314:	1000                	addi	s0,sp,32
    80004316:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004318:	0001e517          	auipc	a0,0x1e
    8000431c:	54050513          	addi	a0,a0,1344 # 80022858 <log>
    80004320:	909fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004324:	0001e617          	auipc	a2,0x1e
    80004328:	55c62603          	lw	a2,1372(a2) # 80022880 <log+0x28>
    8000432c:	47f5                	li	a5,29
    8000432e:	04c7cd63          	blt	a5,a2,80004388 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004332:	0001e797          	auipc	a5,0x1e
    80004336:	5427a783          	lw	a5,1346(a5) # 80022874 <log+0x1c>
    8000433a:	04f05d63          	blez	a5,80004394 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000433e:	4781                	li	a5,0
    80004340:	06c05063          	blez	a2,800043a0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004344:	44cc                	lw	a1,12(s1)
    80004346:	0001e717          	auipc	a4,0x1e
    8000434a:	53e70713          	addi	a4,a4,1342 # 80022884 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000434e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004350:	4314                	lw	a3,0(a4)
    80004352:	04b68763          	beq	a3,a1,800043a0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004356:	2785                	addiw	a5,a5,1
    80004358:	0711                	addi	a4,a4,4
    8000435a:	fef61be3          	bne	a2,a5,80004350 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000435e:	060a                	slli	a2,a2,0x2
    80004360:	02060613          	addi	a2,a2,32
    80004364:	0001e797          	auipc	a5,0x1e
    80004368:	4f478793          	addi	a5,a5,1268 # 80022858 <log>
    8000436c:	97b2                	add	a5,a5,a2
    8000436e:	44d8                	lw	a4,12(s1)
    80004370:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004372:	8526                	mv	a0,s1
    80004374:	ee7fe0ef          	jal	8000325a <bpin>
    log.lh.n++;
    80004378:	0001e717          	auipc	a4,0x1e
    8000437c:	4e070713          	addi	a4,a4,1248 # 80022858 <log>
    80004380:	571c                	lw	a5,40(a4)
    80004382:	2785                	addiw	a5,a5,1
    80004384:	d71c                	sw	a5,40(a4)
    80004386:	a815                	j	800043ba <log_write+0xae>
    panic("too big a transaction");
    80004388:	00003517          	auipc	a0,0x3
    8000438c:	3a850513          	addi	a0,a0,936 # 80007730 <etext+0x730>
    80004390:	c94fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80004394:	00003517          	auipc	a0,0x3
    80004398:	3b450513          	addi	a0,a0,948 # 80007748 <etext+0x748>
    8000439c:	c88fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800043a0:	00279693          	slli	a3,a5,0x2
    800043a4:	02068693          	addi	a3,a3,32
    800043a8:	0001e717          	auipc	a4,0x1e
    800043ac:	4b070713          	addi	a4,a4,1200 # 80022858 <log>
    800043b0:	9736                	add	a4,a4,a3
    800043b2:	44d4                	lw	a3,12(s1)
    800043b4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043b6:	faf60ee3          	beq	a2,a5,80004372 <log_write+0x66>
  }
  release(&log.lock);
    800043ba:	0001e517          	auipc	a0,0x1e
    800043be:	49e50513          	addi	a0,a0,1182 # 80022858 <log>
    800043c2:	8fbfc0ef          	jal	80000cbc <release>
}
    800043c6:	60e2                	ld	ra,24(sp)
    800043c8:	6442                	ld	s0,16(sp)
    800043ca:	64a2                	ld	s1,8(sp)
    800043cc:	6105                	addi	sp,sp,32
    800043ce:	8082                	ret

00000000800043d0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043d0:	1101                	addi	sp,sp,-32
    800043d2:	ec06                	sd	ra,24(sp)
    800043d4:	e822                	sd	s0,16(sp)
    800043d6:	e426                	sd	s1,8(sp)
    800043d8:	e04a                	sd	s2,0(sp)
    800043da:	1000                	addi	s0,sp,32
    800043dc:	84aa                	mv	s1,a0
    800043de:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043e0:	00003597          	auipc	a1,0x3
    800043e4:	38858593          	addi	a1,a1,904 # 80007768 <etext+0x768>
    800043e8:	0521                	addi	a0,a0,8
    800043ea:	fb4fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    800043ee:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043f2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043f6:	0204a423          	sw	zero,40(s1)
}
    800043fa:	60e2                	ld	ra,24(sp)
    800043fc:	6442                	ld	s0,16(sp)
    800043fe:	64a2                	ld	s1,8(sp)
    80004400:	6902                	ld	s2,0(sp)
    80004402:	6105                	addi	sp,sp,32
    80004404:	8082                	ret

0000000080004406 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004406:	1101                	addi	sp,sp,-32
    80004408:	ec06                	sd	ra,24(sp)
    8000440a:	e822                	sd	s0,16(sp)
    8000440c:	e426                	sd	s1,8(sp)
    8000440e:	e04a                	sd	s2,0(sp)
    80004410:	1000                	addi	s0,sp,32
    80004412:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004414:	00850913          	addi	s2,a0,8
    80004418:	854a                	mv	a0,s2
    8000441a:	80ffc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000441e:	409c                	lw	a5,0(s1)
    80004420:	c799                	beqz	a5,8000442e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004422:	85ca                	mv	a1,s2
    80004424:	8526                	mv	a0,s1
    80004426:	e3bfd0ef          	jal	80002260 <sleep>
  while (lk->locked) {
    8000442a:	409c                	lw	a5,0(s1)
    8000442c:	fbfd                	bnez	a5,80004422 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000442e:	4785                	li	a5,1
    80004430:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004432:	d7afd0ef          	jal	800019ac <myproc>
    80004436:	591c                	lw	a5,48(a0)
    80004438:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000443a:	854a                	mv	a0,s2
    8000443c:	881fc0ef          	jal	80000cbc <release>
}
    80004440:	60e2                	ld	ra,24(sp)
    80004442:	6442                	ld	s0,16(sp)
    80004444:	64a2                	ld	s1,8(sp)
    80004446:	6902                	ld	s2,0(sp)
    80004448:	6105                	addi	sp,sp,32
    8000444a:	8082                	ret

000000008000444c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000444c:	1101                	addi	sp,sp,-32
    8000444e:	ec06                	sd	ra,24(sp)
    80004450:	e822                	sd	s0,16(sp)
    80004452:	e426                	sd	s1,8(sp)
    80004454:	e04a                	sd	s2,0(sp)
    80004456:	1000                	addi	s0,sp,32
    80004458:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000445a:	00850913          	addi	s2,a0,8
    8000445e:	854a                	mv	a0,s2
    80004460:	fc8fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004464:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004468:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000446c:	8526                	mv	a0,s1
    8000446e:	e3ffd0ef          	jal	800022ac <wakeup>
  release(&lk->lk);
    80004472:	854a                	mv	a0,s2
    80004474:	849fc0ef          	jal	80000cbc <release>
}
    80004478:	60e2                	ld	ra,24(sp)
    8000447a:	6442                	ld	s0,16(sp)
    8000447c:	64a2                	ld	s1,8(sp)
    8000447e:	6902                	ld	s2,0(sp)
    80004480:	6105                	addi	sp,sp,32
    80004482:	8082                	ret

0000000080004484 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004484:	7179                	addi	sp,sp,-48
    80004486:	f406                	sd	ra,40(sp)
    80004488:	f022                	sd	s0,32(sp)
    8000448a:	ec26                	sd	s1,24(sp)
    8000448c:	e84a                	sd	s2,16(sp)
    8000448e:	1800                	addi	s0,sp,48
    80004490:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004492:	00850913          	addi	s2,a0,8
    80004496:	854a                	mv	a0,s2
    80004498:	f90fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000449c:	409c                	lw	a5,0(s1)
    8000449e:	ef81                	bnez	a5,800044b6 <holdingsleep+0x32>
    800044a0:	4481                	li	s1,0
  release(&lk->lk);
    800044a2:	854a                	mv	a0,s2
    800044a4:	819fc0ef          	jal	80000cbc <release>
  return r;
}
    800044a8:	8526                	mv	a0,s1
    800044aa:	70a2                	ld	ra,40(sp)
    800044ac:	7402                	ld	s0,32(sp)
    800044ae:	64e2                	ld	s1,24(sp)
    800044b0:	6942                	ld	s2,16(sp)
    800044b2:	6145                	addi	sp,sp,48
    800044b4:	8082                	ret
    800044b6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800044b8:	0284a983          	lw	s3,40(s1)
    800044bc:	cf0fd0ef          	jal	800019ac <myproc>
    800044c0:	5904                	lw	s1,48(a0)
    800044c2:	413484b3          	sub	s1,s1,s3
    800044c6:	0014b493          	seqz	s1,s1
    800044ca:	69a2                	ld	s3,8(sp)
    800044cc:	bfd9                	j	800044a2 <holdingsleep+0x1e>

00000000800044ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044ce:	1141                	addi	sp,sp,-16
    800044d0:	e406                	sd	ra,8(sp)
    800044d2:	e022                	sd	s0,0(sp)
    800044d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044d6:	00003597          	auipc	a1,0x3
    800044da:	2a258593          	addi	a1,a1,674 # 80007778 <etext+0x778>
    800044de:	0001e517          	auipc	a0,0x1e
    800044e2:	4c250513          	addi	a0,a0,1218 # 800229a0 <ftable>
    800044e6:	eb8fc0ef          	jal	80000b9e <initlock>
}
    800044ea:	60a2                	ld	ra,8(sp)
    800044ec:	6402                	ld	s0,0(sp)
    800044ee:	0141                	addi	sp,sp,16
    800044f0:	8082                	ret

00000000800044f2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044f2:	1101                	addi	sp,sp,-32
    800044f4:	ec06                	sd	ra,24(sp)
    800044f6:	e822                	sd	s0,16(sp)
    800044f8:	e426                	sd	s1,8(sp)
    800044fa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044fc:	0001e517          	auipc	a0,0x1e
    80004500:	4a450513          	addi	a0,a0,1188 # 800229a0 <ftable>
    80004504:	f24fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004508:	0001e497          	auipc	s1,0x1e
    8000450c:	4b048493          	addi	s1,s1,1200 # 800229b8 <ftable+0x18>
    80004510:	0001f717          	auipc	a4,0x1f
    80004514:	44870713          	addi	a4,a4,1096 # 80023958 <disk>
    if(f->ref == 0){
    80004518:	40dc                	lw	a5,4(s1)
    8000451a:	cf89                	beqz	a5,80004534 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000451c:	02848493          	addi	s1,s1,40
    80004520:	fee49ce3          	bne	s1,a4,80004518 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004524:	0001e517          	auipc	a0,0x1e
    80004528:	47c50513          	addi	a0,a0,1148 # 800229a0 <ftable>
    8000452c:	f90fc0ef          	jal	80000cbc <release>
  return 0;
    80004530:	4481                	li	s1,0
    80004532:	a809                	j	80004544 <filealloc+0x52>
      f->ref = 1;
    80004534:	4785                	li	a5,1
    80004536:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004538:	0001e517          	auipc	a0,0x1e
    8000453c:	46850513          	addi	a0,a0,1128 # 800229a0 <ftable>
    80004540:	f7cfc0ef          	jal	80000cbc <release>
}
    80004544:	8526                	mv	a0,s1
    80004546:	60e2                	ld	ra,24(sp)
    80004548:	6442                	ld	s0,16(sp)
    8000454a:	64a2                	ld	s1,8(sp)
    8000454c:	6105                	addi	sp,sp,32
    8000454e:	8082                	ret

0000000080004550 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004550:	1101                	addi	sp,sp,-32
    80004552:	ec06                	sd	ra,24(sp)
    80004554:	e822                	sd	s0,16(sp)
    80004556:	e426                	sd	s1,8(sp)
    80004558:	1000                	addi	s0,sp,32
    8000455a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000455c:	0001e517          	auipc	a0,0x1e
    80004560:	44450513          	addi	a0,a0,1092 # 800229a0 <ftable>
    80004564:	ec4fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004568:	40dc                	lw	a5,4(s1)
    8000456a:	02f05063          	blez	a5,8000458a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000456e:	2785                	addiw	a5,a5,1
    80004570:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004572:	0001e517          	auipc	a0,0x1e
    80004576:	42e50513          	addi	a0,a0,1070 # 800229a0 <ftable>
    8000457a:	f42fc0ef          	jal	80000cbc <release>
  return f;
}
    8000457e:	8526                	mv	a0,s1
    80004580:	60e2                	ld	ra,24(sp)
    80004582:	6442                	ld	s0,16(sp)
    80004584:	64a2                	ld	s1,8(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret
    panic("filedup");
    8000458a:	00003517          	auipc	a0,0x3
    8000458e:	1f650513          	addi	a0,a0,502 # 80007780 <etext+0x780>
    80004592:	a92fc0ef          	jal	80000824 <panic>

0000000080004596 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004596:	7139                	addi	sp,sp,-64
    80004598:	fc06                	sd	ra,56(sp)
    8000459a:	f822                	sd	s0,48(sp)
    8000459c:	f426                	sd	s1,40(sp)
    8000459e:	0080                	addi	s0,sp,64
    800045a0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045a2:	0001e517          	auipc	a0,0x1e
    800045a6:	3fe50513          	addi	a0,a0,1022 # 800229a0 <ftable>
    800045aa:	e7efc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800045ae:	40dc                	lw	a5,4(s1)
    800045b0:	04f05a63          	blez	a5,80004604 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800045b4:	37fd                	addiw	a5,a5,-1
    800045b6:	c0dc                	sw	a5,4(s1)
    800045b8:	06f04063          	bgtz	a5,80004618 <fileclose+0x82>
    800045bc:	f04a                	sd	s2,32(sp)
    800045be:	ec4e                	sd	s3,24(sp)
    800045c0:	e852                	sd	s4,16(sp)
    800045c2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045c4:	0004a903          	lw	s2,0(s1)
    800045c8:	0094c783          	lbu	a5,9(s1)
    800045cc:	89be                	mv	s3,a5
    800045ce:	689c                	ld	a5,16(s1)
    800045d0:	8a3e                	mv	s4,a5
    800045d2:	6c9c                	ld	a5,24(s1)
    800045d4:	8abe                	mv	s5,a5
  f->ref = 0;
    800045d6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045da:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045de:	0001e517          	auipc	a0,0x1e
    800045e2:	3c250513          	addi	a0,a0,962 # 800229a0 <ftable>
    800045e6:	ed6fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    800045ea:	4785                	li	a5,1
    800045ec:	04f90163          	beq	s2,a5,8000462e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045f0:	ffe9079b          	addiw	a5,s2,-2
    800045f4:	4705                	li	a4,1
    800045f6:	04f77563          	bgeu	a4,a5,80004640 <fileclose+0xaa>
    800045fa:	7902                	ld	s2,32(sp)
    800045fc:	69e2                	ld	s3,24(sp)
    800045fe:	6a42                	ld	s4,16(sp)
    80004600:	6aa2                	ld	s5,8(sp)
    80004602:	a00d                	j	80004624 <fileclose+0x8e>
    80004604:	f04a                	sd	s2,32(sp)
    80004606:	ec4e                	sd	s3,24(sp)
    80004608:	e852                	sd	s4,16(sp)
    8000460a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000460c:	00003517          	auipc	a0,0x3
    80004610:	17c50513          	addi	a0,a0,380 # 80007788 <etext+0x788>
    80004614:	a10fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004618:	0001e517          	auipc	a0,0x1e
    8000461c:	38850513          	addi	a0,a0,904 # 800229a0 <ftable>
    80004620:	e9cfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004624:	70e2                	ld	ra,56(sp)
    80004626:	7442                	ld	s0,48(sp)
    80004628:	74a2                	ld	s1,40(sp)
    8000462a:	6121                	addi	sp,sp,64
    8000462c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000462e:	85ce                	mv	a1,s3
    80004630:	8552                	mv	a0,s4
    80004632:	380000ef          	jal	800049b2 <pipeclose>
    80004636:	7902                	ld	s2,32(sp)
    80004638:	69e2                	ld	s3,24(sp)
    8000463a:	6a42                	ld	s4,16(sp)
    8000463c:	6aa2                	ld	s5,8(sp)
    8000463e:	b7dd                	j	80004624 <fileclose+0x8e>
    begin_op();
    80004640:	b33ff0ef          	jal	80004172 <begin_op>
    iput(ff.ip);
    80004644:	8556                	mv	a0,s5
    80004646:	aa2ff0ef          	jal	800038e8 <iput>
    end_op();
    8000464a:	b99ff0ef          	jal	800041e2 <end_op>
    8000464e:	7902                	ld	s2,32(sp)
    80004650:	69e2                	ld	s3,24(sp)
    80004652:	6a42                	ld	s4,16(sp)
    80004654:	6aa2                	ld	s5,8(sp)
    80004656:	b7f9                	j	80004624 <fileclose+0x8e>

0000000080004658 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004658:	715d                	addi	sp,sp,-80
    8000465a:	e486                	sd	ra,72(sp)
    8000465c:	e0a2                	sd	s0,64(sp)
    8000465e:	fc26                	sd	s1,56(sp)
    80004660:	f052                	sd	s4,32(sp)
    80004662:	0880                	addi	s0,sp,80
    80004664:	84aa                	mv	s1,a0
    80004666:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004668:	b44fd0ef          	jal	800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	37f9                	addiw	a5,a5,-2
    80004670:	4705                	li	a4,1
    80004672:	04f76263          	bltu	a4,a5,800046b6 <filestat+0x5e>
    80004676:	f84a                	sd	s2,48(sp)
    80004678:	f44e                	sd	s3,40(sp)
    8000467a:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000467c:	6c88                	ld	a0,24(s1)
    8000467e:	8e8ff0ef          	jal	80003766 <ilock>
    stati(f->ip, &st);
    80004682:	fb840913          	addi	s2,s0,-72
    80004686:	85ca                	mv	a1,s2
    80004688:	6c88                	ld	a0,24(s1)
    8000468a:	c40ff0ef          	jal	80003aca <stati>
    iunlock(f->ip);
    8000468e:	6c88                	ld	a0,24(s1)
    80004690:	984ff0ef          	jal	80003814 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004694:	46e1                	li	a3,24
    80004696:	864a                	mv	a2,s2
    80004698:	85d2                	mv	a1,s4
    8000469a:	0589b503          	ld	a0,88(s3)
    8000469e:	fb7fc0ef          	jal	80001654 <copyout>
    800046a2:	41f5551b          	sraiw	a0,a0,0x1f
    800046a6:	7942                	ld	s2,48(sp)
    800046a8:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800046aa:	60a6                	ld	ra,72(sp)
    800046ac:	6406                	ld	s0,64(sp)
    800046ae:	74e2                	ld	s1,56(sp)
    800046b0:	7a02                	ld	s4,32(sp)
    800046b2:	6161                	addi	sp,sp,80
    800046b4:	8082                	ret
  return -1;
    800046b6:	557d                	li	a0,-1
    800046b8:	bfcd                	j	800046aa <filestat+0x52>

00000000800046ba <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046ba:	7179                	addi	sp,sp,-48
    800046bc:	f406                	sd	ra,40(sp)
    800046be:	f022                	sd	s0,32(sp)
    800046c0:	e84a                	sd	s2,16(sp)
    800046c2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046c4:	00854783          	lbu	a5,8(a0)
    800046c8:	cfd1                	beqz	a5,80004764 <fileread+0xaa>
    800046ca:	ec26                	sd	s1,24(sp)
    800046cc:	e44e                	sd	s3,8(sp)
    800046ce:	84aa                	mv	s1,a0
    800046d0:	892e                	mv	s2,a1
    800046d2:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800046d4:	411c                	lw	a5,0(a0)
    800046d6:	4705                	li	a4,1
    800046d8:	04e78363          	beq	a5,a4,8000471e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046dc:	470d                	li	a4,3
    800046de:	04e78763          	beq	a5,a4,8000472c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046e2:	4709                	li	a4,2
    800046e4:	06e79a63          	bne	a5,a4,80004758 <fileread+0x9e>
    ilock(f->ip);
    800046e8:	6d08                	ld	a0,24(a0)
    800046ea:	87cff0ef          	jal	80003766 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046ee:	874e                	mv	a4,s3
    800046f0:	5094                	lw	a3,32(s1)
    800046f2:	864a                	mv	a2,s2
    800046f4:	4585                	li	a1,1
    800046f6:	6c88                	ld	a0,24(s1)
    800046f8:	c00ff0ef          	jal	80003af8 <readi>
    800046fc:	892a                	mv	s2,a0
    800046fe:	00a05563          	blez	a0,80004708 <fileread+0x4e>
      f->off += r;
    80004702:	509c                	lw	a5,32(s1)
    80004704:	9fa9                	addw	a5,a5,a0
    80004706:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004708:	6c88                	ld	a0,24(s1)
    8000470a:	90aff0ef          	jal	80003814 <iunlock>
    8000470e:	64e2                	ld	s1,24(sp)
    80004710:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004712:	854a                	mv	a0,s2
    80004714:	70a2                	ld	ra,40(sp)
    80004716:	7402                	ld	s0,32(sp)
    80004718:	6942                	ld	s2,16(sp)
    8000471a:	6145                	addi	sp,sp,48
    8000471c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000471e:	6908                	ld	a0,16(a0)
    80004720:	3f8000ef          	jal	80004b18 <piperead>
    80004724:	892a                	mv	s2,a0
    80004726:	64e2                	ld	s1,24(sp)
    80004728:	69a2                	ld	s3,8(sp)
    8000472a:	b7e5                	j	80004712 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000472c:	02451783          	lh	a5,36(a0)
    80004730:	03079693          	slli	a3,a5,0x30
    80004734:	92c1                	srli	a3,a3,0x30
    80004736:	4725                	li	a4,9
    80004738:	02d76963          	bltu	a4,a3,8000476a <fileread+0xb0>
    8000473c:	0792                	slli	a5,a5,0x4
    8000473e:	0001e717          	auipc	a4,0x1e
    80004742:	1c270713          	addi	a4,a4,450 # 80022900 <devsw>
    80004746:	97ba                	add	a5,a5,a4
    80004748:	639c                	ld	a5,0(a5)
    8000474a:	c78d                	beqz	a5,80004774 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    8000474c:	4505                	li	a0,1
    8000474e:	9782                	jalr	a5
    80004750:	892a                	mv	s2,a0
    80004752:	64e2                	ld	s1,24(sp)
    80004754:	69a2                	ld	s3,8(sp)
    80004756:	bf75                	j	80004712 <fileread+0x58>
    panic("fileread");
    80004758:	00003517          	auipc	a0,0x3
    8000475c:	04050513          	addi	a0,a0,64 # 80007798 <etext+0x798>
    80004760:	8c4fc0ef          	jal	80000824 <panic>
    return -1;
    80004764:	57fd                	li	a5,-1
    80004766:	893e                	mv	s2,a5
    80004768:	b76d                	j	80004712 <fileread+0x58>
      return -1;
    8000476a:	57fd                	li	a5,-1
    8000476c:	893e                	mv	s2,a5
    8000476e:	64e2                	ld	s1,24(sp)
    80004770:	69a2                	ld	s3,8(sp)
    80004772:	b745                	j	80004712 <fileread+0x58>
    80004774:	57fd                	li	a5,-1
    80004776:	893e                	mv	s2,a5
    80004778:	64e2                	ld	s1,24(sp)
    8000477a:	69a2                	ld	s3,8(sp)
    8000477c:	bf59                	j	80004712 <fileread+0x58>

000000008000477e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000477e:	00954783          	lbu	a5,9(a0)
    80004782:	10078f63          	beqz	a5,800048a0 <filewrite+0x122>
{
    80004786:	711d                	addi	sp,sp,-96
    80004788:	ec86                	sd	ra,88(sp)
    8000478a:	e8a2                	sd	s0,80(sp)
    8000478c:	e0ca                	sd	s2,64(sp)
    8000478e:	f456                	sd	s5,40(sp)
    80004790:	f05a                	sd	s6,32(sp)
    80004792:	1080                	addi	s0,sp,96
    80004794:	892a                	mv	s2,a0
    80004796:	8b2e                	mv	s6,a1
    80004798:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000479a:	411c                	lw	a5,0(a0)
    8000479c:	4705                	li	a4,1
    8000479e:	02e78a63          	beq	a5,a4,800047d2 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047a2:	470d                	li	a4,3
    800047a4:	02e78b63          	beq	a5,a4,800047da <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047a8:	4709                	li	a4,2
    800047aa:	0ce79f63          	bne	a5,a4,80004888 <filewrite+0x10a>
    800047ae:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047b0:	0ac05a63          	blez	a2,80004864 <filewrite+0xe6>
    800047b4:	e4a6                	sd	s1,72(sp)
    800047b6:	fc4e                	sd	s3,56(sp)
    800047b8:	ec5e                	sd	s7,24(sp)
    800047ba:	e862                	sd	s8,16(sp)
    800047bc:	e466                	sd	s9,8(sp)
    int i = 0;
    800047be:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800047c0:	6b85                	lui	s7,0x1
    800047c2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047c6:	6785                	lui	a5,0x1
    800047c8:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800047cc:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047ce:	4c05                	li	s8,1
    800047d0:	a8ad                	j	8000484a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800047d2:	6908                	ld	a0,16(a0)
    800047d4:	252000ef          	jal	80004a26 <pipewrite>
    800047d8:	a04d                	j	8000487a <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047da:	02451783          	lh	a5,36(a0)
    800047de:	03079693          	slli	a3,a5,0x30
    800047e2:	92c1                	srli	a3,a3,0x30
    800047e4:	4725                	li	a4,9
    800047e6:	0ad76f63          	bltu	a4,a3,800048a4 <filewrite+0x126>
    800047ea:	0792                	slli	a5,a5,0x4
    800047ec:	0001e717          	auipc	a4,0x1e
    800047f0:	11470713          	addi	a4,a4,276 # 80022900 <devsw>
    800047f4:	97ba                	add	a5,a5,a4
    800047f6:	679c                	ld	a5,8(a5)
    800047f8:	cbc5                	beqz	a5,800048a8 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800047fa:	4505                	li	a0,1
    800047fc:	9782                	jalr	a5
    800047fe:	a8b5                	j	8000487a <filewrite+0xfc>
      if(n1 > max)
    80004800:	2981                	sext.w	s3,s3
      begin_op();
    80004802:	971ff0ef          	jal	80004172 <begin_op>
      ilock(f->ip);
    80004806:	01893503          	ld	a0,24(s2)
    8000480a:	f5dfe0ef          	jal	80003766 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000480e:	874e                	mv	a4,s3
    80004810:	02092683          	lw	a3,32(s2)
    80004814:	016a0633          	add	a2,s4,s6
    80004818:	85e2                	mv	a1,s8
    8000481a:	01893503          	ld	a0,24(s2)
    8000481e:	bccff0ef          	jal	80003bea <writei>
    80004822:	84aa                	mv	s1,a0
    80004824:	00a05763          	blez	a0,80004832 <filewrite+0xb4>
        f->off += r;
    80004828:	02092783          	lw	a5,32(s2)
    8000482c:	9fa9                	addw	a5,a5,a0
    8000482e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004832:	01893503          	ld	a0,24(s2)
    80004836:	fdffe0ef          	jal	80003814 <iunlock>
      end_op();
    8000483a:	9a9ff0ef          	jal	800041e2 <end_op>

      if(r != n1){
    8000483e:	02999563          	bne	s3,s1,80004868 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004842:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004846:	015a5963          	bge	s4,s5,80004858 <filewrite+0xda>
      int n1 = n - i;
    8000484a:	414a87bb          	subw	a5,s5,s4
    8000484e:	89be                	mv	s3,a5
      if(n1 > max)
    80004850:	fafbd8e3          	bge	s7,a5,80004800 <filewrite+0x82>
    80004854:	89e6                	mv	s3,s9
    80004856:	b76d                	j	80004800 <filewrite+0x82>
    80004858:	64a6                	ld	s1,72(sp)
    8000485a:	79e2                	ld	s3,56(sp)
    8000485c:	6be2                	ld	s7,24(sp)
    8000485e:	6c42                	ld	s8,16(sp)
    80004860:	6ca2                	ld	s9,8(sp)
    80004862:	a801                	j	80004872 <filewrite+0xf4>
    int i = 0;
    80004864:	4a01                	li	s4,0
    80004866:	a031                	j	80004872 <filewrite+0xf4>
    80004868:	64a6                	ld	s1,72(sp)
    8000486a:	79e2                	ld	s3,56(sp)
    8000486c:	6be2                	ld	s7,24(sp)
    8000486e:	6c42                	ld	s8,16(sp)
    80004870:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004872:	034a9d63          	bne	s5,s4,800048ac <filewrite+0x12e>
    80004876:	8556                	mv	a0,s5
    80004878:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000487a:	60e6                	ld	ra,88(sp)
    8000487c:	6446                	ld	s0,80(sp)
    8000487e:	6906                	ld	s2,64(sp)
    80004880:	7aa2                	ld	s5,40(sp)
    80004882:	7b02                	ld	s6,32(sp)
    80004884:	6125                	addi	sp,sp,96
    80004886:	8082                	ret
    80004888:	e4a6                	sd	s1,72(sp)
    8000488a:	fc4e                	sd	s3,56(sp)
    8000488c:	f852                	sd	s4,48(sp)
    8000488e:	ec5e                	sd	s7,24(sp)
    80004890:	e862                	sd	s8,16(sp)
    80004892:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004894:	00003517          	auipc	a0,0x3
    80004898:	f1450513          	addi	a0,a0,-236 # 800077a8 <etext+0x7a8>
    8000489c:	f89fb0ef          	jal	80000824 <panic>
    return -1;
    800048a0:	557d                	li	a0,-1
}
    800048a2:	8082                	ret
      return -1;
    800048a4:	557d                	li	a0,-1
    800048a6:	bfd1                	j	8000487a <filewrite+0xfc>
    800048a8:	557d                	li	a0,-1
    800048aa:	bfc1                	j	8000487a <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800048ac:	557d                	li	a0,-1
    800048ae:	7a42                	ld	s4,48(sp)
    800048b0:	b7e9                	j	8000487a <filewrite+0xfc>

00000000800048b2 <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048b2:	1101                	addi	sp,sp,-32
    800048b4:	ec06                	sd	ra,24(sp)
    800048b6:	e822                	sd	s0,16(sp)
    800048b8:	e426                	sd	s1,8(sp)
    800048ba:	e04a                	sd	s2,0(sp)
    800048bc:	1000                	addi	s0,sp,32
    800048be:	84aa                	mv	s1,a0
    800048c0:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048c2:	0005b023          	sd	zero,0(a1)
    800048c6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048ca:	c29ff0ef          	jal	800044f2 <filealloc>
    800048ce:	e088                	sd	a0,0(s1)
    800048d0:	cd35                	beqz	a0,8000494c <pipealloc+0x9a>
    800048d2:	c21ff0ef          	jal	800044f2 <filealloc>
    800048d6:	00a93023          	sd	a0,0(s2)
    800048da:	c52d                	beqz	a0,80004944 <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048dc:	a68fc0ef          	jal	80000b44 <kalloc>
    800048e0:	cd39                	beqz	a0,8000493e <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    800048e2:	4785                	li	a5,1
    800048e4:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    800048e8:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    800048ec:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    800048f0:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    800048f4:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    800048f8:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    800048fc:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004900:	6098                	ld	a4,0(s1)
    80004902:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    80004904:	6098                	ld	a4,0(s1)
    80004906:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    8000490a:	6098                	ld	a4,0(s1)
    8000490c:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004910:	6098                	ld	a4,0(s1)
    80004912:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    80004914:	00093703          	ld	a4,0(s2)
    80004918:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    8000491a:	00093703          	ld	a4,0(s2)
    8000491e:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    80004922:	00093703          	ld	a4,0(s2)
    80004926:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    8000492a:	00093783          	ld	a5,0(s2)
    8000492e:	eb88                	sd	a0,16(a5)
  return 0;
    80004930:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret
  if(*f0)
    8000493e:	6088                	ld	a0,0(s1)
    80004940:	e501                	bnez	a0,80004948 <pipealloc+0x96>
    80004942:	a029                	j	8000494c <pipealloc+0x9a>
    80004944:	6088                	ld	a0,0(s1)
    80004946:	cd01                	beqz	a0,8000495e <pipealloc+0xac>
    fileclose(*f0);
    80004948:	c4fff0ef          	jal	80004596 <fileclose>
  if(*f1)
    8000494c:	00093783          	ld	a5,0(s2)
  return -1;
    80004950:	557d                	li	a0,-1
  if(*f1)
    80004952:	d3e5                	beqz	a5,80004932 <pipealloc+0x80>
    fileclose(*f1);
    80004954:	853e                	mv	a0,a5
    80004956:	c41ff0ef          	jal	80004596 <fileclose>
  return -1;
    8000495a:	557d                	li	a0,-1
    8000495c:	bfd9                	j	80004932 <pipealloc+0x80>
    8000495e:	557d                	li	a0,-1
    80004960:	bfc9                	j	80004932 <pipealloc+0x80>

0000000080004962 <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    80004962:	1141                	addi	sp,sp,-16
    80004964:	e406                	sd	ra,8(sp)
    80004966:	e022                	sd	s0,0(sp)
    80004968:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    8000496a:	4785                	li	a5,1
    8000496c:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    8000496e:	058a                	slli	a1,a1,0x2
    80004970:	21058593          	addi	a1,a1,528
    80004974:	95aa                	add	a1,a1,a0
    80004976:	4705                	li	a4,1
    80004978:	c198                	sw	a4,0(a1)
  pi->turn = other;
    8000497a:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    8000497e:	078a                	slli	a5,a5,0x2
    80004980:	21078793          	addi	a5,a5,528
    80004984:	953e                	add	a0,a0,a5
    80004986:	4118                	lw	a4,0(a0)
    80004988:	4785                	li	a5,1
    8000498a:	00f70063          	beq	a4,a5,8000498a <peterson_enter+0x28>
}
    8000498e:	60a2                	ld	ra,8(sp)
    80004990:	6402                	ld	s0,0(sp)
    80004992:	0141                	addi	sp,sp,16
    80004994:	8082                	ret

0000000080004996 <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    80004996:	1141                	addi	sp,sp,-16
    80004998:	e406                	sd	ra,8(sp)
    8000499a:	e022                	sd	s0,0(sp)
    8000499c:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    8000499e:	058a                	slli	a1,a1,0x2
    800049a0:	21058593          	addi	a1,a1,528
    800049a4:	952e                	add	a0,a0,a1
    800049a6:	00052023          	sw	zero,0(a0)
}
    800049aa:	60a2                	ld	ra,8(sp)
    800049ac:	6402                	ld	s0,0(sp)
    800049ae:	0141                	addi	sp,sp,16
    800049b0:	8082                	ret

00000000800049b2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049b2:	7179                	addi	sp,sp,-48
    800049b4:	f406                	sd	ra,40(sp)
    800049b6:	f022                	sd	s0,32(sp)
    800049b8:	ec26                	sd	s1,24(sp)
    800049ba:	e84a                	sd	s2,16(sp)
    800049bc:	e44e                	sd	s3,8(sp)
    800049be:	1800                	addi	s0,sp,48
    800049c0:	84aa                	mv	s1,a0
    800049c2:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    800049c4:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    800049c8:	85ca                	mv	a1,s2
    800049ca:	f99ff0ef          	jal	80004962 <peterson_enter>
  if(writable){
    800049ce:	02098b63          	beqz	s3,80004a04 <pipeclose+0x52>
    pi->writeopen = 0;
    800049d2:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    800049d6:	20048513          	addi	a0,s1,512
    800049da:	8d3fd0ef          	jal	800022ac <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049de:	2084a783          	lw	a5,520(s1)
    800049e2:	e781                	bnez	a5,800049ea <pipeclose+0x38>
    800049e4:	20c4a783          	lw	a5,524(s1)
    800049e8:	c78d                	beqz	a5,80004a12 <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    800049ea:	090a                	slli	s2,s2,0x2
    800049ec:	21090913          	addi	s2,s2,528
    800049f0:	94ca                	add	s1,s1,s2
    800049f2:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    800049f6:	70a2                	ld	ra,40(sp)
    800049f8:	7402                	ld	s0,32(sp)
    800049fa:	64e2                	ld	s1,24(sp)
    800049fc:	6942                	ld	s2,16(sp)
    800049fe:	69a2                	ld	s3,8(sp)
    80004a00:	6145                	addi	sp,sp,48
    80004a02:	8082                	ret
    pi->readopen = 0;
    80004a04:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    80004a08:	20448513          	addi	a0,s1,516
    80004a0c:	8a1fd0ef          	jal	800022ac <wakeup>
    80004a10:	b7f9                	j	800049de <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    80004a12:	090a                	slli	s2,s2,0x2
    80004a14:	21090913          	addi	s2,s2,528
    80004a18:	9926                	add	s2,s2,s1
    80004a1a:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	83cfc0ef          	jal	80000a5c <kfree>
    80004a24:	bfc9                	j	800049f6 <pipeclose+0x44>

0000000080004a26 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a26:	7159                	addi	sp,sp,-112
    80004a28:	f486                	sd	ra,104(sp)
    80004a2a:	f0a2                	sd	s0,96(sp)
    80004a2c:	eca6                	sd	s1,88(sp)
    80004a2e:	e8ca                	sd	s2,80(sp)
    80004a30:	e4ce                	sd	s3,72(sp)
    80004a32:	e0d2                	sd	s4,64(sp)
    80004a34:	fc56                	sd	s5,56(sp)
    80004a36:	1880                	addi	s0,sp,112
    80004a38:	84aa                	mv	s1,a0
    80004a3a:	8aae                	mv	s5,a1
    80004a3c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a3e:	f6ffc0ef          	jal	800019ac <myproc>
    80004a42:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    80004a44:	4581                	li	a1,0
    80004a46:	8526                	mv	a0,s1
    80004a48:	f1bff0ef          	jal	80004962 <peterson_enter>
  while(i < n){
    80004a4c:	0b405e63          	blez	s4,80004b08 <pipewrite+0xe2>
    80004a50:	f85a                	sd	s6,48(sp)
    80004a52:	f45e                	sd	s7,40(sp)
    80004a54:	f062                	sd	s8,32(sp)
    80004a56:	ec66                	sd	s9,24(sp)
    80004a58:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004a5a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a5c:	f9f40c13          	addi	s8,s0,-97
    80004a60:	4b85                	li	s7,1
    80004a62:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a64:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    80004a68:	20448c93          	addi	s9,s1,516
    80004a6c:	a825                	j	80004aa4 <pipewrite+0x7e>
      return -1;
    80004a6e:	597d                	li	s2,-1
}
    80004a70:	7b42                	ld	s6,48(sp)
    80004a72:	7ba2                	ld	s7,40(sp)
    80004a74:	7c02                	ld	s8,32(sp)
    80004a76:	6ce2                	ld	s9,24(sp)
    80004a78:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    80004a7a:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004a7e:	854a                	mv	a0,s2
    80004a80:	70a6                	ld	ra,104(sp)
    80004a82:	7406                	ld	s0,96(sp)
    80004a84:	64e6                	ld	s1,88(sp)
    80004a86:	6946                	ld	s2,80(sp)
    80004a88:	69a6                	ld	s3,72(sp)
    80004a8a:	6a06                	ld	s4,64(sp)
    80004a8c:	7ae2                	ld	s5,56(sp)
    80004a8e:	6165                	addi	sp,sp,112
    80004a90:	8082                	ret
      wakeup(&pi->nread);
    80004a92:	856a                	mv	a0,s10
    80004a94:	819fd0ef          	jal	800022ac <wakeup>
      sleep(&pi->nwrite, 0);
    80004a98:	4581                	li	a1,0
    80004a9a:	8566                	mv	a0,s9
    80004a9c:	fc4fd0ef          	jal	80002260 <sleep>
  while(i < n){
    80004aa0:	05495a63          	bge	s2,s4,80004af4 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004aa4:	2084a783          	lw	a5,520(s1)
    80004aa8:	d3f9                	beqz	a5,80004a6e <pipewrite+0x48>
    80004aaa:	854e                	mv	a0,s3
    80004aac:	9f1fd0ef          	jal	8000249c <killed>
    80004ab0:	fd5d                	bnez	a0,80004a6e <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ab2:	2004a783          	lw	a5,512(s1)
    80004ab6:	2044a703          	lw	a4,516(s1)
    80004aba:	2007879b          	addiw	a5,a5,512
    80004abe:	fcf70ae3          	beq	a4,a5,80004a92 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ac2:	86de                	mv	a3,s7
    80004ac4:	01590633          	add	a2,s2,s5
    80004ac8:	85e2                	mv	a1,s8
    80004aca:	0589b503          	ld	a0,88(s3)
    80004ace:	c45fc0ef          	jal	80001712 <copyin>
    80004ad2:	03650d63          	beq	a0,s6,80004b0c <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ad6:	2044a783          	lw	a5,516(s1)
    80004ada:	0017871b          	addiw	a4,a5,1
    80004ade:	20e4a223          	sw	a4,516(s1)
    80004ae2:	1ff7f793          	andi	a5,a5,511
    80004ae6:	97a6                	add	a5,a5,s1
    80004ae8:	f9f44703          	lbu	a4,-97(s0)
    80004aec:	00e78023          	sb	a4,0(a5)
      i++;
    80004af0:	2905                	addiw	s2,s2,1
    80004af2:	b77d                	j	80004aa0 <pipewrite+0x7a>
    80004af4:	7b42                	ld	s6,48(sp)
    80004af6:	7ba2                	ld	s7,40(sp)
    80004af8:	7c02                	ld	s8,32(sp)
    80004afa:	6ce2                	ld	s9,24(sp)
    80004afc:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004afe:	20048513          	addi	a0,s1,512
    80004b02:	faafd0ef          	jal	800022ac <wakeup>
}
    80004b06:	bf95                	j	80004a7a <pipewrite+0x54>
  int i = 0;
    80004b08:	4901                	li	s2,0
    80004b0a:	bfd5                	j	80004afe <pipewrite+0xd8>
    80004b0c:	7b42                	ld	s6,48(sp)
    80004b0e:	7ba2                	ld	s7,40(sp)
    80004b10:	7c02                	ld	s8,32(sp)
    80004b12:	6ce2                	ld	s9,24(sp)
    80004b14:	6d42                	ld	s10,16(sp)
    80004b16:	b7e5                	j	80004afe <pipewrite+0xd8>

0000000080004b18 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b18:	711d                	addi	sp,sp,-96
    80004b1a:	ec86                	sd	ra,88(sp)
    80004b1c:	e8a2                	sd	s0,80(sp)
    80004b1e:	e4a6                	sd	s1,72(sp)
    80004b20:	e0ca                	sd	s2,64(sp)
    80004b22:	fc4e                	sd	s3,56(sp)
    80004b24:	f852                	sd	s4,48(sp)
    80004b26:	f456                	sd	s5,40(sp)
    80004b28:	1080                	addi	s0,sp,96
    80004b2a:	84aa                	mv	s1,a0
    80004b2c:	892e                	mv	s2,a1
    80004b2e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b30:	e7dfc0ef          	jal	800019ac <myproc>
    80004b34:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    80004b36:	4585                	li	a1,1
    80004b38:	8526                	mv	a0,s1
    80004b3a:	e29ff0ef          	jal	80004962 <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b3e:	2004a703          	lw	a4,512(s1)
    80004b42:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80004b46:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4a:	02f71763          	bne	a4,a5,80004b78 <piperead+0x60>
    80004b4e:	20c4a783          	lw	a5,524(s1)
    80004b52:	c79d                	beqz	a5,80004b80 <piperead+0x68>
    if(killed(pr)){
    80004b54:	8552                	mv	a0,s4
    80004b56:	947fd0ef          	jal	8000249c <killed>
    80004b5a:	e15d                	bnez	a0,80004c00 <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80004b5c:	4581                	li	a1,0
    80004b5e:	854e                	mv	a0,s3
    80004b60:	f00fd0ef          	jal	80002260 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b64:	2004a703          	lw	a4,512(s1)
    80004b68:	2044a783          	lw	a5,516(s1)
    80004b6c:	fef701e3          	beq	a4,a5,80004b4e <piperead+0x36>
    80004b70:	f05a                	sd	s6,32(sp)
    80004b72:	ec5e                	sd	s7,24(sp)
    80004b74:	e862                	sd	s8,16(sp)
    80004b76:	a801                	j	80004b86 <piperead+0x6e>
    80004b78:	f05a                	sd	s6,32(sp)
    80004b7a:	ec5e                	sd	s7,24(sp)
    80004b7c:	e862                	sd	s8,16(sp)
    80004b7e:	a021                	j	80004b86 <piperead+0x6e>
    80004b80:	f05a                	sd	s6,32(sp)
    80004b82:	ec5e                	sd	s7,24(sp)
    80004b84:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b86:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b88:	faf40c13          	addi	s8,s0,-81
    80004b8c:	4b85                	li	s7,1
    80004b8e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b90:	05505163          	blez	s5,80004bd2 <piperead+0xba>
    if(pi->nread == pi->nwrite)
    80004b94:	2004a783          	lw	a5,512(s1)
    80004b98:	2044a703          	lw	a4,516(s1)
    80004b9c:	02f70b63          	beq	a4,a5,80004bd2 <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    80004ba0:	1ff7f793          	andi	a5,a5,511
    80004ba4:	97a6                	add	a5,a5,s1
    80004ba6:	0007c783          	lbu	a5,0(a5)
    80004baa:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004bae:	86de                	mv	a3,s7
    80004bb0:	8662                	mv	a2,s8
    80004bb2:	85ca                	mv	a1,s2
    80004bb4:	058a3503          	ld	a0,88(s4)
    80004bb8:	a9dfc0ef          	jal	80001654 <copyout>
    80004bbc:	03650e63          	beq	a0,s6,80004bf8 <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004bc0:	2004a783          	lw	a5,512(s1)
    80004bc4:	2785                	addiw	a5,a5,1
    80004bc6:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bca:	2985                	addiw	s3,s3,1
    80004bcc:	0905                	addi	s2,s2,1
    80004bce:	fd3a93e3          	bne	s5,s3,80004b94 <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bd2:	20448513          	addi	a0,s1,516
    80004bd6:	ed6fd0ef          	jal	800022ac <wakeup>
}
    80004bda:	7b02                	ld	s6,32(sp)
    80004bdc:	6be2                	ld	s7,24(sp)
    80004bde:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    80004be0:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    80004be4:	854e                	mv	a0,s3
    80004be6:	60e6                	ld	ra,88(sp)
    80004be8:	6446                	ld	s0,80(sp)
    80004bea:	64a6                	ld	s1,72(sp)
    80004bec:	6906                	ld	s2,64(sp)
    80004bee:	79e2                	ld	s3,56(sp)
    80004bf0:	7a42                	ld	s4,48(sp)
    80004bf2:	7aa2                	ld	s5,40(sp)
    80004bf4:	6125                	addi	sp,sp,96
    80004bf6:	8082                	ret
      if(i == 0)
    80004bf8:	fc099de3          	bnez	s3,80004bd2 <piperead+0xba>
        i = -1;
    80004bfc:	89aa                	mv	s3,a0
    80004bfe:	bfd1                	j	80004bd2 <piperead+0xba>
      return -1;
    80004c00:	59fd                	li	s3,-1
    80004c02:	bff9                	j	80004be0 <piperead+0xc8>

0000000080004c04 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004c04:	1141                	addi	sp,sp,-16
    80004c06:	e406                	sd	ra,8(sp)
    80004c08:	e022                	sd	s0,0(sp)
    80004c0a:	0800                	addi	s0,sp,16
    80004c0c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c0e:	0035151b          	slliw	a0,a0,0x3
    80004c12:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004c14:	8b89                	andi	a5,a5,2
    80004c16:	c399                	beqz	a5,80004c1c <flags2perm+0x18>
      perm |= PTE_W;
    80004c18:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c1c:	60a2                	ld	ra,8(sp)
    80004c1e:	6402                	ld	s0,0(sp)
    80004c20:	0141                	addi	sp,sp,16
    80004c22:	8082                	ret

0000000080004c24 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c24:	de010113          	addi	sp,sp,-544
    80004c28:	20113c23          	sd	ra,536(sp)
    80004c2c:	20813823          	sd	s0,528(sp)
    80004c30:	20913423          	sd	s1,520(sp)
    80004c34:	21213023          	sd	s2,512(sp)
    80004c38:	1400                	addi	s0,sp,544
    80004c3a:	892a                	mv	s2,a0
    80004c3c:	dea43823          	sd	a0,-528(s0)
    80004c40:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c44:	d69fc0ef          	jal	800019ac <myproc>
    80004c48:	84aa                	mv	s1,a0

  begin_op();
    80004c4a:	d28ff0ef          	jal	80004172 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004c4e:	854a                	mv	a0,s2
    80004c50:	b44ff0ef          	jal	80003f94 <namei>
    80004c54:	cd21                	beqz	a0,80004cac <kexec+0x88>
    80004c56:	fbd2                	sd	s4,496(sp)
    80004c58:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c5a:	b0dfe0ef          	jal	80003766 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c5e:	04000713          	li	a4,64
    80004c62:	4681                	li	a3,0
    80004c64:	e5040613          	addi	a2,s0,-432
    80004c68:	4581                	li	a1,0
    80004c6a:	8552                	mv	a0,s4
    80004c6c:	e8dfe0ef          	jal	80003af8 <readi>
    80004c70:	04000793          	li	a5,64
    80004c74:	00f51a63          	bne	a0,a5,80004c88 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004c78:	e5042703          	lw	a4,-432(s0)
    80004c7c:	464c47b7          	lui	a5,0x464c4
    80004c80:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c84:	02f70863          	beq	a4,a5,80004cb4 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c88:	8552                	mv	a0,s4
    80004c8a:	ce9fe0ef          	jal	80003972 <iunlockput>
    end_op();
    80004c8e:	d54ff0ef          	jal	800041e2 <end_op>
  }
  return -1;
    80004c92:	557d                	li	a0,-1
    80004c94:	7a5e                	ld	s4,496(sp)
}
    80004c96:	21813083          	ld	ra,536(sp)
    80004c9a:	21013403          	ld	s0,528(sp)
    80004c9e:	20813483          	ld	s1,520(sp)
    80004ca2:	20013903          	ld	s2,512(sp)
    80004ca6:	22010113          	addi	sp,sp,544
    80004caa:	8082                	ret
    end_op();
    80004cac:	d36ff0ef          	jal	800041e2 <end_op>
    return -1;
    80004cb0:	557d                	li	a0,-1
    80004cb2:	b7d5                	j	80004c96 <kexec+0x72>
    80004cb4:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004cb6:	8526                	mv	a0,s1
    80004cb8:	dfffc0ef          	jal	80001ab6 <proc_pagetable>
    80004cbc:	8b2a                	mv	s6,a0
    80004cbe:	26050f63          	beqz	a0,80004f3c <kexec+0x318>
    80004cc2:	ffce                	sd	s3,504(sp)
    80004cc4:	f7d6                	sd	s5,488(sp)
    80004cc6:	efde                	sd	s7,472(sp)
    80004cc8:	ebe2                	sd	s8,464(sp)
    80004cca:	e7e6                	sd	s9,456(sp)
    80004ccc:	e3ea                	sd	s10,448(sp)
    80004cce:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cd0:	e8845783          	lhu	a5,-376(s0)
    80004cd4:	0e078963          	beqz	a5,80004dc6 <kexec+0x1a2>
    80004cd8:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cdc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cde:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ce0:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004ce4:	6c85                	lui	s9,0x1
    80004ce6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004cea:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cee:	6a85                	lui	s5,0x1
    80004cf0:	a085                	j	80004d50 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004cf2:	00003517          	auipc	a0,0x3
    80004cf6:	ac650513          	addi	a0,a0,-1338 # 800077b8 <etext+0x7b8>
    80004cfa:	b2bfb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004cfe:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d00:	874a                	mv	a4,s2
    80004d02:	009b86bb          	addw	a3,s7,s1
    80004d06:	4581                	li	a1,0
    80004d08:	8552                	mv	a0,s4
    80004d0a:	deffe0ef          	jal	80003af8 <readi>
    80004d0e:	22a91b63          	bne	s2,a0,80004f44 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004d12:	009a84bb          	addw	s1,s5,s1
    80004d16:	0334f263          	bgeu	s1,s3,80004d3a <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004d1a:	02049593          	slli	a1,s1,0x20
    80004d1e:	9181                	srli	a1,a1,0x20
    80004d20:	95e2                	add	a1,a1,s8
    80004d22:	855a                	mv	a0,s6
    80004d24:	b02fc0ef          	jal	80001026 <walkaddr>
    80004d28:	862a                	mv	a2,a0
    if(pa == 0)
    80004d2a:	d561                	beqz	a0,80004cf2 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004d2c:	409987bb          	subw	a5,s3,s1
    80004d30:	893e                	mv	s2,a5
    80004d32:	fcfcf6e3          	bgeu	s9,a5,80004cfe <kexec+0xda>
    80004d36:	8956                	mv	s2,s5
    80004d38:	b7d9                	j	80004cfe <kexec+0xda>
    sz = sz1;
    80004d3a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d3e:	2d05                	addiw	s10,s10,1
    80004d40:	e0843783          	ld	a5,-504(s0)
    80004d44:	0387869b          	addiw	a3,a5,56
    80004d48:	e8845783          	lhu	a5,-376(s0)
    80004d4c:	06fd5e63          	bge	s10,a5,80004dc8 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d50:	e0d43423          	sd	a3,-504(s0)
    80004d54:	876e                	mv	a4,s11
    80004d56:	e1840613          	addi	a2,s0,-488
    80004d5a:	4581                	li	a1,0
    80004d5c:	8552                	mv	a0,s4
    80004d5e:	d9bfe0ef          	jal	80003af8 <readi>
    80004d62:	1db51f63          	bne	a0,s11,80004f40 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004d66:	e1842783          	lw	a5,-488(s0)
    80004d6a:	4705                	li	a4,1
    80004d6c:	fce799e3          	bne	a5,a4,80004d3e <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004d70:	e4043483          	ld	s1,-448(s0)
    80004d74:	e3843783          	ld	a5,-456(s0)
    80004d78:	1ef4e463          	bltu	s1,a5,80004f60 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d7c:	e2843783          	ld	a5,-472(s0)
    80004d80:	94be                	add	s1,s1,a5
    80004d82:	1ef4e263          	bltu	s1,a5,80004f66 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004d86:	de843703          	ld	a4,-536(s0)
    80004d8a:	8ff9                	and	a5,a5,a4
    80004d8c:	1e079063          	bnez	a5,80004f6c <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d90:	e1c42503          	lw	a0,-484(s0)
    80004d94:	e71ff0ef          	jal	80004c04 <flags2perm>
    80004d98:	86aa                	mv	a3,a0
    80004d9a:	8626                	mv	a2,s1
    80004d9c:	85ca                	mv	a1,s2
    80004d9e:	855a                	mv	a0,s6
    80004da0:	d5cfc0ef          	jal	800012fc <uvmalloc>
    80004da4:	dea43c23          	sd	a0,-520(s0)
    80004da8:	1c050563          	beqz	a0,80004f72 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004dac:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004db0:	00098863          	beqz	s3,80004dc0 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004db4:	e2843c03          	ld	s8,-472(s0)
    80004db8:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004dbc:	4481                	li	s1,0
    80004dbe:	bfb1                	j	80004d1a <kexec+0xf6>
    sz = sz1;
    80004dc0:	df843903          	ld	s2,-520(s0)
    80004dc4:	bfad                	j	80004d3e <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dc6:	4901                	li	s2,0
  iunlockput(ip);
    80004dc8:	8552                	mv	a0,s4
    80004dca:	ba9fe0ef          	jal	80003972 <iunlockput>
  end_op();
    80004dce:	c14ff0ef          	jal	800041e2 <end_op>
  p = myproc();
    80004dd2:	bdbfc0ef          	jal	800019ac <myproc>
    80004dd6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004dd8:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004ddc:	6985                	lui	s3,0x1
    80004dde:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004de0:	99ca                	add	s3,s3,s2
    80004de2:	77fd                	lui	a5,0xfffff
    80004de4:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004de8:	4691                	li	a3,4
    80004dea:	6609                	lui	a2,0x2
    80004dec:	964e                	add	a2,a2,s3
    80004dee:	85ce                	mv	a1,s3
    80004df0:	855a                	mv	a0,s6
    80004df2:	d0afc0ef          	jal	800012fc <uvmalloc>
    80004df6:	8a2a                	mv	s4,a0
    80004df8:	e105                	bnez	a0,80004e18 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004dfa:	85ce                	mv	a1,s3
    80004dfc:	855a                	mv	a0,s6
    80004dfe:	d3dfc0ef          	jal	80001b3a <proc_freepagetable>
  return -1;
    80004e02:	557d                	li	a0,-1
    80004e04:	79fe                	ld	s3,504(sp)
    80004e06:	7a5e                	ld	s4,496(sp)
    80004e08:	7abe                	ld	s5,488(sp)
    80004e0a:	7b1e                	ld	s6,480(sp)
    80004e0c:	6bfe                	ld	s7,472(sp)
    80004e0e:	6c5e                	ld	s8,464(sp)
    80004e10:	6cbe                	ld	s9,456(sp)
    80004e12:	6d1e                	ld	s10,448(sp)
    80004e14:	7dfa                	ld	s11,440(sp)
    80004e16:	b541                	j	80004c96 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004e18:	75f9                	lui	a1,0xffffe
    80004e1a:	95aa                	add	a1,a1,a0
    80004e1c:	855a                	mv	a0,s6
    80004e1e:	eb0fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004e22:	800a0b93          	addi	s7,s4,-2048
    80004e26:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004e2a:	e0043783          	ld	a5,-512(s0)
    80004e2e:	6388                	ld	a0,0(a5)
  sp = sz;
    80004e30:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004e32:	4481                	li	s1,0
    ustack[argc] = sp;
    80004e34:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004e38:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004e3c:	cd21                	beqz	a0,80004e94 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004e3e:	844fc0ef          	jal	80000e82 <strlen>
    80004e42:	0015079b          	addiw	a5,a0,1
    80004e46:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e4a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004e4e:	13796563          	bltu	s2,s7,80004f78 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e52:	e0043d83          	ld	s11,-512(s0)
    80004e56:	000db983          	ld	s3,0(s11)
    80004e5a:	854e                	mv	a0,s3
    80004e5c:	826fc0ef          	jal	80000e82 <strlen>
    80004e60:	0015069b          	addiw	a3,a0,1
    80004e64:	864e                	mv	a2,s3
    80004e66:	85ca                	mv	a1,s2
    80004e68:	855a                	mv	a0,s6
    80004e6a:	feafc0ef          	jal	80001654 <copyout>
    80004e6e:	10054763          	bltz	a0,80004f7c <kexec+0x358>
    ustack[argc] = sp;
    80004e72:	00349793          	slli	a5,s1,0x3
    80004e76:	97e6                	add	a5,a5,s9
    80004e78:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb568>
  for(argc = 0; argv[argc]; argc++) {
    80004e7c:	0485                	addi	s1,s1,1
    80004e7e:	008d8793          	addi	a5,s11,8
    80004e82:	e0f43023          	sd	a5,-512(s0)
    80004e86:	008db503          	ld	a0,8(s11)
    80004e8a:	c509                	beqz	a0,80004e94 <kexec+0x270>
    if(argc >= MAXARG)
    80004e8c:	fb8499e3          	bne	s1,s8,80004e3e <kexec+0x21a>
  sz = sz1;
    80004e90:	89d2                	mv	s3,s4
    80004e92:	b7a5                	j	80004dfa <kexec+0x1d6>
  ustack[argc] = 0;
    80004e94:	00349793          	slli	a5,s1,0x3
    80004e98:	f9078793          	addi	a5,a5,-112
    80004e9c:	97a2                	add	a5,a5,s0
    80004e9e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ea2:	00349693          	slli	a3,s1,0x3
    80004ea6:	06a1                	addi	a3,a3,8
    80004ea8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004eac:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004eb0:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004eb2:	f57964e3          	bltu	s2,s7,80004dfa <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004eb6:	e9040613          	addi	a2,s0,-368
    80004eba:	85ca                	mv	a1,s2
    80004ebc:	855a                	mv	a0,s6
    80004ebe:	f96fc0ef          	jal	80001654 <copyout>
    80004ec2:	f2054ce3          	bltz	a0,80004dfa <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004ec6:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80004eca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ece:	df043783          	ld	a5,-528(s0)
    80004ed2:	0007c703          	lbu	a4,0(a5)
    80004ed6:	cf11                	beqz	a4,80004ef2 <kexec+0x2ce>
    80004ed8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eda:	02f00693          	li	a3,47
    80004ede:	a029                	j	80004ee8 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004ee0:	0785                	addi	a5,a5,1
    80004ee2:	fff7c703          	lbu	a4,-1(a5)
    80004ee6:	c711                	beqz	a4,80004ef2 <kexec+0x2ce>
    if(*s == '/')
    80004ee8:	fed71ce3          	bne	a4,a3,80004ee0 <kexec+0x2bc>
      last = s+1;
    80004eec:	def43823          	sd	a5,-528(s0)
    80004ef0:	bfc5                	j	80004ee0 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ef2:	4641                	li	a2,16
    80004ef4:	df043583          	ld	a1,-528(s0)
    80004ef8:	160a8513          	addi	a0,s5,352
    80004efc:	f51fb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004f00:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004f04:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80004f08:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004f0c:	060ab783          	ld	a5,96(s5)
    80004f10:	e6843703          	ld	a4,-408(s0)
    80004f14:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f16:	060ab783          	ld	a5,96(s5)
    80004f1a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f1e:	85ea                	mv	a1,s10
    80004f20:	c1bfc0ef          	jal	80001b3a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f24:	0004851b          	sext.w	a0,s1
    80004f28:	79fe                	ld	s3,504(sp)
    80004f2a:	7a5e                	ld	s4,496(sp)
    80004f2c:	7abe                	ld	s5,488(sp)
    80004f2e:	7b1e                	ld	s6,480(sp)
    80004f30:	6bfe                	ld	s7,472(sp)
    80004f32:	6c5e                	ld	s8,464(sp)
    80004f34:	6cbe                	ld	s9,456(sp)
    80004f36:	6d1e                	ld	s10,448(sp)
    80004f38:	7dfa                	ld	s11,440(sp)
    80004f3a:	bbb1                	j	80004c96 <kexec+0x72>
    80004f3c:	7b1e                	ld	s6,480(sp)
    80004f3e:	b3a9                	j	80004c88 <kexec+0x64>
    80004f40:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f44:	df843583          	ld	a1,-520(s0)
    80004f48:	855a                	mv	a0,s6
    80004f4a:	bf1fc0ef          	jal	80001b3a <proc_freepagetable>
  if(ip){
    80004f4e:	79fe                	ld	s3,504(sp)
    80004f50:	7abe                	ld	s5,488(sp)
    80004f52:	7b1e                	ld	s6,480(sp)
    80004f54:	6bfe                	ld	s7,472(sp)
    80004f56:	6c5e                	ld	s8,464(sp)
    80004f58:	6cbe                	ld	s9,456(sp)
    80004f5a:	6d1e                	ld	s10,448(sp)
    80004f5c:	7dfa                	ld	s11,440(sp)
    80004f5e:	b32d                	j	80004c88 <kexec+0x64>
    80004f60:	df243c23          	sd	s2,-520(s0)
    80004f64:	b7c5                	j	80004f44 <kexec+0x320>
    80004f66:	df243c23          	sd	s2,-520(s0)
    80004f6a:	bfe9                	j	80004f44 <kexec+0x320>
    80004f6c:	df243c23          	sd	s2,-520(s0)
    80004f70:	bfd1                	j	80004f44 <kexec+0x320>
    80004f72:	df243c23          	sd	s2,-520(s0)
    80004f76:	b7f9                	j	80004f44 <kexec+0x320>
  sz = sz1;
    80004f78:	89d2                	mv	s3,s4
    80004f7a:	b541                	j	80004dfa <kexec+0x1d6>
    80004f7c:	89d2                	mv	s3,s4
    80004f7e:	bdb5                	j	80004dfa <kexec+0x1d6>

0000000080004f80 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f80:	7179                	addi	sp,sp,-48
    80004f82:	f406                	sd	ra,40(sp)
    80004f84:	f022                	sd	s0,32(sp)
    80004f86:	ec26                	sd	s1,24(sp)
    80004f88:	e84a                	sd	s2,16(sp)
    80004f8a:	1800                	addi	s0,sp,48
    80004f8c:	892e                	mv	s2,a1
    80004f8e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f90:	fdc40593          	addi	a1,s0,-36
    80004f94:	dddfd0ef          	jal	80002d70 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f98:	fdc42703          	lw	a4,-36(s0)
    80004f9c:	47bd                	li	a5,15
    80004f9e:	02e7ea63          	bltu	a5,a4,80004fd2 <argfd+0x52>
    80004fa2:	a0bfc0ef          	jal	800019ac <myproc>
    80004fa6:	fdc42703          	lw	a4,-36(s0)
    80004faa:	00371793          	slli	a5,a4,0x3
    80004fae:	0d078793          	addi	a5,a5,208
    80004fb2:	953e                	add	a0,a0,a5
    80004fb4:	651c                	ld	a5,8(a0)
    80004fb6:	c385                	beqz	a5,80004fd6 <argfd+0x56>
    return -1;
  if(pfd)
    80004fb8:	00090463          	beqz	s2,80004fc0 <argfd+0x40>
    *pfd = fd;
    80004fbc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fc0:	4501                	li	a0,0
  if(pf)
    80004fc2:	c091                	beqz	s1,80004fc6 <argfd+0x46>
    *pf = f;
    80004fc4:	e09c                	sd	a5,0(s1)
}
    80004fc6:	70a2                	ld	ra,40(sp)
    80004fc8:	7402                	ld	s0,32(sp)
    80004fca:	64e2                	ld	s1,24(sp)
    80004fcc:	6942                	ld	s2,16(sp)
    80004fce:	6145                	addi	sp,sp,48
    80004fd0:	8082                	ret
    return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	bfcd                	j	80004fc6 <argfd+0x46>
    80004fd6:	557d                	li	a0,-1
    80004fd8:	b7fd                	j	80004fc6 <argfd+0x46>

0000000080004fda <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fda:	1101                	addi	sp,sp,-32
    80004fdc:	ec06                	sd	ra,24(sp)
    80004fde:	e822                	sd	s0,16(sp)
    80004fe0:	e426                	sd	s1,8(sp)
    80004fe2:	1000                	addi	s0,sp,32
    80004fe4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fe6:	9c7fc0ef          	jal	800019ac <myproc>
    80004fea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fec:	0d850793          	addi	a5,a0,216
    80004ff0:	4501                	li	a0,0
    80004ff2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ff4:	6398                	ld	a4,0(a5)
    80004ff6:	cb19                	beqz	a4,8000500c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ff8:	2505                	addiw	a0,a0,1
    80004ffa:	07a1                	addi	a5,a5,8
    80004ffc:	fed51ce3          	bne	a0,a3,80004ff4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005000:	557d                	li	a0,-1
}
    80005002:	60e2                	ld	ra,24(sp)
    80005004:	6442                	ld	s0,16(sp)
    80005006:	64a2                	ld	s1,8(sp)
    80005008:	6105                	addi	sp,sp,32
    8000500a:	8082                	ret
      p->ofile[fd] = f;
    8000500c:	00351793          	slli	a5,a0,0x3
    80005010:	0d078793          	addi	a5,a5,208
    80005014:	963e                	add	a2,a2,a5
    80005016:	e604                	sd	s1,8(a2)
      return fd;
    80005018:	b7ed                	j	80005002 <fdalloc+0x28>

000000008000501a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000501a:	715d                	addi	sp,sp,-80
    8000501c:	e486                	sd	ra,72(sp)
    8000501e:	e0a2                	sd	s0,64(sp)
    80005020:	fc26                	sd	s1,56(sp)
    80005022:	f84a                	sd	s2,48(sp)
    80005024:	f44e                	sd	s3,40(sp)
    80005026:	f052                	sd	s4,32(sp)
    80005028:	ec56                	sd	s5,24(sp)
    8000502a:	e85a                	sd	s6,16(sp)
    8000502c:	0880                	addi	s0,sp,80
    8000502e:	892e                	mv	s2,a1
    80005030:	8a2e                	mv	s4,a1
    80005032:	8ab2                	mv	s5,a2
    80005034:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005036:	fb040593          	addi	a1,s0,-80
    8000503a:	f75fe0ef          	jal	80003fae <nameiparent>
    8000503e:	84aa                	mv	s1,a0
    80005040:	10050763          	beqz	a0,8000514e <create+0x134>
    return 0;

  ilock(dp);
    80005044:	f22fe0ef          	jal	80003766 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005048:	4601                	li	a2,0
    8000504a:	fb040593          	addi	a1,s0,-80
    8000504e:	8526                	mv	a0,s1
    80005050:	cb1fe0ef          	jal	80003d00 <dirlookup>
    80005054:	89aa                	mv	s3,a0
    80005056:	c131                	beqz	a0,8000509a <create+0x80>
    iunlockput(dp);
    80005058:	8526                	mv	a0,s1
    8000505a:	919fe0ef          	jal	80003972 <iunlockput>
    ilock(ip);
    8000505e:	854e                	mv	a0,s3
    80005060:	f06fe0ef          	jal	80003766 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005064:	4789                	li	a5,2
    80005066:	02f91563          	bne	s2,a5,80005090 <create+0x76>
    8000506a:	0449d783          	lhu	a5,68(s3)
    8000506e:	37f9                	addiw	a5,a5,-2
    80005070:	17c2                	slli	a5,a5,0x30
    80005072:	93c1                	srli	a5,a5,0x30
    80005074:	4705                	li	a4,1
    80005076:	00f76d63          	bltu	a4,a5,80005090 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000507a:	854e                	mv	a0,s3
    8000507c:	60a6                	ld	ra,72(sp)
    8000507e:	6406                	ld	s0,64(sp)
    80005080:	74e2                	ld	s1,56(sp)
    80005082:	7942                	ld	s2,48(sp)
    80005084:	79a2                	ld	s3,40(sp)
    80005086:	7a02                	ld	s4,32(sp)
    80005088:	6ae2                	ld	s5,24(sp)
    8000508a:	6b42                	ld	s6,16(sp)
    8000508c:	6161                	addi	sp,sp,80
    8000508e:	8082                	ret
    iunlockput(ip);
    80005090:	854e                	mv	a0,s3
    80005092:	8e1fe0ef          	jal	80003972 <iunlockput>
    return 0;
    80005096:	4981                	li	s3,0
    80005098:	b7cd                	j	8000507a <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000509a:	85ca                	mv	a1,s2
    8000509c:	4088                	lw	a0,0(s1)
    8000509e:	d58fe0ef          	jal	800035f6 <ialloc>
    800050a2:	892a                	mv	s2,a0
    800050a4:	cd15                	beqz	a0,800050e0 <create+0xc6>
  ilock(ip);
    800050a6:	ec0fe0ef          	jal	80003766 <ilock>
  ip->major = major;
    800050aa:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    800050ae:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    800050b2:	4785                	li	a5,1
    800050b4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050b8:	854a                	mv	a0,s2
    800050ba:	df8fe0ef          	jal	800036b2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050be:	4705                	li	a4,1
    800050c0:	02ea0463          	beq	s4,a4,800050e8 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800050c4:	00492603          	lw	a2,4(s2)
    800050c8:	fb040593          	addi	a1,s0,-80
    800050cc:	8526                	mv	a0,s1
    800050ce:	e1dfe0ef          	jal	80003eea <dirlink>
    800050d2:	06054263          	bltz	a0,80005136 <create+0x11c>
  iunlockput(dp);
    800050d6:	8526                	mv	a0,s1
    800050d8:	89bfe0ef          	jal	80003972 <iunlockput>
  return ip;
    800050dc:	89ca                	mv	s3,s2
    800050de:	bf71                	j	8000507a <create+0x60>
    iunlockput(dp);
    800050e0:	8526                	mv	a0,s1
    800050e2:	891fe0ef          	jal	80003972 <iunlockput>
    return 0;
    800050e6:	bf51                	j	8000507a <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050e8:	00492603          	lw	a2,4(s2)
    800050ec:	00002597          	auipc	a1,0x2
    800050f0:	6ec58593          	addi	a1,a1,1772 # 800077d8 <etext+0x7d8>
    800050f4:	854a                	mv	a0,s2
    800050f6:	df5fe0ef          	jal	80003eea <dirlink>
    800050fa:	02054e63          	bltz	a0,80005136 <create+0x11c>
    800050fe:	40d0                	lw	a2,4(s1)
    80005100:	00002597          	auipc	a1,0x2
    80005104:	6e058593          	addi	a1,a1,1760 # 800077e0 <etext+0x7e0>
    80005108:	854a                	mv	a0,s2
    8000510a:	de1fe0ef          	jal	80003eea <dirlink>
    8000510e:	02054463          	bltz	a0,80005136 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005112:	00492603          	lw	a2,4(s2)
    80005116:	fb040593          	addi	a1,s0,-80
    8000511a:	8526                	mv	a0,s1
    8000511c:	dcffe0ef          	jal	80003eea <dirlink>
    80005120:	00054b63          	bltz	a0,80005136 <create+0x11c>
    dp->nlink++;  // for ".."
    80005124:	04a4d783          	lhu	a5,74(s1)
    80005128:	2785                	addiw	a5,a5,1
    8000512a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000512e:	8526                	mv	a0,s1
    80005130:	d82fe0ef          	jal	800036b2 <iupdate>
    80005134:	b74d                	j	800050d6 <create+0xbc>
  ip->nlink = 0;
    80005136:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    8000513a:	854a                	mv	a0,s2
    8000513c:	d76fe0ef          	jal	800036b2 <iupdate>
  iunlockput(ip);
    80005140:	854a                	mv	a0,s2
    80005142:	831fe0ef          	jal	80003972 <iunlockput>
  iunlockput(dp);
    80005146:	8526                	mv	a0,s1
    80005148:	82bfe0ef          	jal	80003972 <iunlockput>
  return 0;
    8000514c:	b73d                	j	8000507a <create+0x60>
    return 0;
    8000514e:	89aa                	mv	s3,a0
    80005150:	b72d                	j	8000507a <create+0x60>

0000000080005152 <sys_dup>:
{
    80005152:	7179                	addi	sp,sp,-48
    80005154:	f406                	sd	ra,40(sp)
    80005156:	f022                	sd	s0,32(sp)
    80005158:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000515a:	fd840613          	addi	a2,s0,-40
    8000515e:	4581                	li	a1,0
    80005160:	4501                	li	a0,0
    80005162:	e1fff0ef          	jal	80004f80 <argfd>
    return -1;
    80005166:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005168:	02054363          	bltz	a0,8000518e <sys_dup+0x3c>
    8000516c:	ec26                	sd	s1,24(sp)
    8000516e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005170:	fd843483          	ld	s1,-40(s0)
    80005174:	8526                	mv	a0,s1
    80005176:	e65ff0ef          	jal	80004fda <fdalloc>
    8000517a:	892a                	mv	s2,a0
    return -1;
    8000517c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000517e:	00054d63          	bltz	a0,80005198 <sys_dup+0x46>
  filedup(f);
    80005182:	8526                	mv	a0,s1
    80005184:	bccff0ef          	jal	80004550 <filedup>
  return fd;
    80005188:	87ca                	mv	a5,s2
    8000518a:	64e2                	ld	s1,24(sp)
    8000518c:	6942                	ld	s2,16(sp)
}
    8000518e:	853e                	mv	a0,a5
    80005190:	70a2                	ld	ra,40(sp)
    80005192:	7402                	ld	s0,32(sp)
    80005194:	6145                	addi	sp,sp,48
    80005196:	8082                	ret
    80005198:	64e2                	ld	s1,24(sp)
    8000519a:	6942                	ld	s2,16(sp)
    8000519c:	bfcd                	j	8000518e <sys_dup+0x3c>

000000008000519e <sys_read>:
{
    8000519e:	7179                	addi	sp,sp,-48
    800051a0:	f406                	sd	ra,40(sp)
    800051a2:	f022                	sd	s0,32(sp)
    800051a4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051a6:	fd840593          	addi	a1,s0,-40
    800051aa:	4505                	li	a0,1
    800051ac:	be1fd0ef          	jal	80002d8c <argaddr>
  argint(2, &n);
    800051b0:	fe440593          	addi	a1,s0,-28
    800051b4:	4509                	li	a0,2
    800051b6:	bbbfd0ef          	jal	80002d70 <argint>
  if(argfd(0, 0, &f) < 0)
    800051ba:	fe840613          	addi	a2,s0,-24
    800051be:	4581                	li	a1,0
    800051c0:	4501                	li	a0,0
    800051c2:	dbfff0ef          	jal	80004f80 <argfd>
    800051c6:	87aa                	mv	a5,a0
    return -1;
    800051c8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051ca:	0007ca63          	bltz	a5,800051de <sys_read+0x40>
  return fileread(f, p, n);
    800051ce:	fe442603          	lw	a2,-28(s0)
    800051d2:	fd843583          	ld	a1,-40(s0)
    800051d6:	fe843503          	ld	a0,-24(s0)
    800051da:	ce0ff0ef          	jal	800046ba <fileread>
}
    800051de:	70a2                	ld	ra,40(sp)
    800051e0:	7402                	ld	s0,32(sp)
    800051e2:	6145                	addi	sp,sp,48
    800051e4:	8082                	ret

00000000800051e6 <sys_write>:
{
    800051e6:	7179                	addi	sp,sp,-48
    800051e8:	f406                	sd	ra,40(sp)
    800051ea:	f022                	sd	s0,32(sp)
    800051ec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ee:	fd840593          	addi	a1,s0,-40
    800051f2:	4505                	li	a0,1
    800051f4:	b99fd0ef          	jal	80002d8c <argaddr>
  argint(2, &n);
    800051f8:	fe440593          	addi	a1,s0,-28
    800051fc:	4509                	li	a0,2
    800051fe:	b73fd0ef          	jal	80002d70 <argint>
  if(argfd(0, 0, &f) < 0)
    80005202:	fe840613          	addi	a2,s0,-24
    80005206:	4581                	li	a1,0
    80005208:	4501                	li	a0,0
    8000520a:	d77ff0ef          	jal	80004f80 <argfd>
    8000520e:	87aa                	mv	a5,a0
    return -1;
    80005210:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005212:	0007ca63          	bltz	a5,80005226 <sys_write+0x40>
  return filewrite(f, p, n);
    80005216:	fe442603          	lw	a2,-28(s0)
    8000521a:	fd843583          	ld	a1,-40(s0)
    8000521e:	fe843503          	ld	a0,-24(s0)
    80005222:	d5cff0ef          	jal	8000477e <filewrite>
}
    80005226:	70a2                	ld	ra,40(sp)
    80005228:	7402                	ld	s0,32(sp)
    8000522a:	6145                	addi	sp,sp,48
    8000522c:	8082                	ret

000000008000522e <sys_close>:
{
    8000522e:	1101                	addi	sp,sp,-32
    80005230:	ec06                	sd	ra,24(sp)
    80005232:	e822                	sd	s0,16(sp)
    80005234:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005236:	fe040613          	addi	a2,s0,-32
    8000523a:	fec40593          	addi	a1,s0,-20
    8000523e:	4501                	li	a0,0
    80005240:	d41ff0ef          	jal	80004f80 <argfd>
    return -1;
    80005244:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005246:	02054163          	bltz	a0,80005268 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000524a:	f62fc0ef          	jal	800019ac <myproc>
    8000524e:	fec42783          	lw	a5,-20(s0)
    80005252:	078e                	slli	a5,a5,0x3
    80005254:	0d078793          	addi	a5,a5,208
    80005258:	953e                	add	a0,a0,a5
    8000525a:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000525e:	fe043503          	ld	a0,-32(s0)
    80005262:	b34ff0ef          	jal	80004596 <fileclose>
  return 0;
    80005266:	4781                	li	a5,0
}
    80005268:	853e                	mv	a0,a5
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	6105                	addi	sp,sp,32
    80005270:	8082                	ret

0000000080005272 <sys_fstat>:
{
    80005272:	1101                	addi	sp,sp,-32
    80005274:	ec06                	sd	ra,24(sp)
    80005276:	e822                	sd	s0,16(sp)
    80005278:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000527a:	fe040593          	addi	a1,s0,-32
    8000527e:	4505                	li	a0,1
    80005280:	b0dfd0ef          	jal	80002d8c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005284:	fe840613          	addi	a2,s0,-24
    80005288:	4581                	li	a1,0
    8000528a:	4501                	li	a0,0
    8000528c:	cf5ff0ef          	jal	80004f80 <argfd>
    80005290:	87aa                	mv	a5,a0
    return -1;
    80005292:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005294:	0007c863          	bltz	a5,800052a4 <sys_fstat+0x32>
  return filestat(f, st);
    80005298:	fe043583          	ld	a1,-32(s0)
    8000529c:	fe843503          	ld	a0,-24(s0)
    800052a0:	bb8ff0ef          	jal	80004658 <filestat>
}
    800052a4:	60e2                	ld	ra,24(sp)
    800052a6:	6442                	ld	s0,16(sp)
    800052a8:	6105                	addi	sp,sp,32
    800052aa:	8082                	ret

00000000800052ac <sys_link>:
{
    800052ac:	7169                	addi	sp,sp,-304
    800052ae:	f606                	sd	ra,296(sp)
    800052b0:	f222                	sd	s0,288(sp)
    800052b2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052b4:	08000613          	li	a2,128
    800052b8:	ed040593          	addi	a1,s0,-304
    800052bc:	4501                	li	a0,0
    800052be:	aebfd0ef          	jal	80002da8 <argstr>
    return -1;
    800052c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052c4:	0c054e63          	bltz	a0,800053a0 <sys_link+0xf4>
    800052c8:	08000613          	li	a2,128
    800052cc:	f5040593          	addi	a1,s0,-176
    800052d0:	4505                	li	a0,1
    800052d2:	ad7fd0ef          	jal	80002da8 <argstr>
    return -1;
    800052d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052d8:	0c054463          	bltz	a0,800053a0 <sys_link+0xf4>
    800052dc:	ee26                	sd	s1,280(sp)
  begin_op();
    800052de:	e95fe0ef          	jal	80004172 <begin_op>
  if((ip = namei(old)) == 0){
    800052e2:	ed040513          	addi	a0,s0,-304
    800052e6:	caffe0ef          	jal	80003f94 <namei>
    800052ea:	84aa                	mv	s1,a0
    800052ec:	c53d                	beqz	a0,8000535a <sys_link+0xae>
  ilock(ip);
    800052ee:	c78fe0ef          	jal	80003766 <ilock>
  if(ip->type == T_DIR){
    800052f2:	04449703          	lh	a4,68(s1)
    800052f6:	4785                	li	a5,1
    800052f8:	06f70663          	beq	a4,a5,80005364 <sys_link+0xb8>
    800052fc:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052fe:	04a4d783          	lhu	a5,74(s1)
    80005302:	2785                	addiw	a5,a5,1
    80005304:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005308:	8526                	mv	a0,s1
    8000530a:	ba8fe0ef          	jal	800036b2 <iupdate>
  iunlock(ip);
    8000530e:	8526                	mv	a0,s1
    80005310:	d04fe0ef          	jal	80003814 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005314:	fd040593          	addi	a1,s0,-48
    80005318:	f5040513          	addi	a0,s0,-176
    8000531c:	c93fe0ef          	jal	80003fae <nameiparent>
    80005320:	892a                	mv	s2,a0
    80005322:	cd21                	beqz	a0,8000537a <sys_link+0xce>
  ilock(dp);
    80005324:	c42fe0ef          	jal	80003766 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005328:	854a                	mv	a0,s2
    8000532a:	00092703          	lw	a4,0(s2)
    8000532e:	409c                	lw	a5,0(s1)
    80005330:	04f71263          	bne	a4,a5,80005374 <sys_link+0xc8>
    80005334:	40d0                	lw	a2,4(s1)
    80005336:	fd040593          	addi	a1,s0,-48
    8000533a:	bb1fe0ef          	jal	80003eea <dirlink>
    8000533e:	02054b63          	bltz	a0,80005374 <sys_link+0xc8>
  iunlockput(dp);
    80005342:	854a                	mv	a0,s2
    80005344:	e2efe0ef          	jal	80003972 <iunlockput>
  iput(ip);
    80005348:	8526                	mv	a0,s1
    8000534a:	d9efe0ef          	jal	800038e8 <iput>
  end_op();
    8000534e:	e95fe0ef          	jal	800041e2 <end_op>
  return 0;
    80005352:	4781                	li	a5,0
    80005354:	64f2                	ld	s1,280(sp)
    80005356:	6952                	ld	s2,272(sp)
    80005358:	a0a1                	j	800053a0 <sys_link+0xf4>
    end_op();
    8000535a:	e89fe0ef          	jal	800041e2 <end_op>
    return -1;
    8000535e:	57fd                	li	a5,-1
    80005360:	64f2                	ld	s1,280(sp)
    80005362:	a83d                	j	800053a0 <sys_link+0xf4>
    iunlockput(ip);
    80005364:	8526                	mv	a0,s1
    80005366:	e0cfe0ef          	jal	80003972 <iunlockput>
    end_op();
    8000536a:	e79fe0ef          	jal	800041e2 <end_op>
    return -1;
    8000536e:	57fd                	li	a5,-1
    80005370:	64f2                	ld	s1,280(sp)
    80005372:	a03d                	j	800053a0 <sys_link+0xf4>
    iunlockput(dp);
    80005374:	854a                	mv	a0,s2
    80005376:	dfcfe0ef          	jal	80003972 <iunlockput>
  ilock(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	beafe0ef          	jal	80003766 <ilock>
  ip->nlink--;
    80005380:	04a4d783          	lhu	a5,74(s1)
    80005384:	37fd                	addiw	a5,a5,-1
    80005386:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	b26fe0ef          	jal	800036b2 <iupdate>
  iunlockput(ip);
    80005390:	8526                	mv	a0,s1
    80005392:	de0fe0ef          	jal	80003972 <iunlockput>
  end_op();
    80005396:	e4dfe0ef          	jal	800041e2 <end_op>
  return -1;
    8000539a:	57fd                	li	a5,-1
    8000539c:	64f2                	ld	s1,280(sp)
    8000539e:	6952                	ld	s2,272(sp)
}
    800053a0:	853e                	mv	a0,a5
    800053a2:	70b2                	ld	ra,296(sp)
    800053a4:	7412                	ld	s0,288(sp)
    800053a6:	6155                	addi	sp,sp,304
    800053a8:	8082                	ret

00000000800053aa <sys_unlink>:
{
    800053aa:	7151                	addi	sp,sp,-240
    800053ac:	f586                	sd	ra,232(sp)
    800053ae:	f1a2                	sd	s0,224(sp)
    800053b0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053b2:	08000613          	li	a2,128
    800053b6:	f3040593          	addi	a1,s0,-208
    800053ba:	4501                	li	a0,0
    800053bc:	9edfd0ef          	jal	80002da8 <argstr>
    800053c0:	14054d63          	bltz	a0,8000551a <sys_unlink+0x170>
    800053c4:	eda6                	sd	s1,216(sp)
  begin_op();
    800053c6:	dadfe0ef          	jal	80004172 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053ca:	fb040593          	addi	a1,s0,-80
    800053ce:	f3040513          	addi	a0,s0,-208
    800053d2:	bddfe0ef          	jal	80003fae <nameiparent>
    800053d6:	84aa                	mv	s1,a0
    800053d8:	c955                	beqz	a0,8000548c <sys_unlink+0xe2>
  ilock(dp);
    800053da:	b8cfe0ef          	jal	80003766 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053de:	00002597          	auipc	a1,0x2
    800053e2:	3fa58593          	addi	a1,a1,1018 # 800077d8 <etext+0x7d8>
    800053e6:	fb040513          	addi	a0,s0,-80
    800053ea:	901fe0ef          	jal	80003cea <namecmp>
    800053ee:	10050b63          	beqz	a0,80005504 <sys_unlink+0x15a>
    800053f2:	00002597          	auipc	a1,0x2
    800053f6:	3ee58593          	addi	a1,a1,1006 # 800077e0 <etext+0x7e0>
    800053fa:	fb040513          	addi	a0,s0,-80
    800053fe:	8edfe0ef          	jal	80003cea <namecmp>
    80005402:	10050163          	beqz	a0,80005504 <sys_unlink+0x15a>
    80005406:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005408:	f2c40613          	addi	a2,s0,-212
    8000540c:	fb040593          	addi	a1,s0,-80
    80005410:	8526                	mv	a0,s1
    80005412:	8effe0ef          	jal	80003d00 <dirlookup>
    80005416:	892a                	mv	s2,a0
    80005418:	0e050563          	beqz	a0,80005502 <sys_unlink+0x158>
    8000541c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000541e:	b48fe0ef          	jal	80003766 <ilock>
  if(ip->nlink < 1)
    80005422:	04a91783          	lh	a5,74(s2)
    80005426:	06f05863          	blez	a5,80005496 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000542a:	04491703          	lh	a4,68(s2)
    8000542e:	4785                	li	a5,1
    80005430:	06f70963          	beq	a4,a5,800054a2 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005434:	fc040993          	addi	s3,s0,-64
    80005438:	4641                	li	a2,16
    8000543a:	4581                	li	a1,0
    8000543c:	854e                	mv	a0,s3
    8000543e:	8bbfb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005442:	4741                	li	a4,16
    80005444:	f2c42683          	lw	a3,-212(s0)
    80005448:	864e                	mv	a2,s3
    8000544a:	4581                	li	a1,0
    8000544c:	8526                	mv	a0,s1
    8000544e:	f9cfe0ef          	jal	80003bea <writei>
    80005452:	47c1                	li	a5,16
    80005454:	08f51863          	bne	a0,a5,800054e4 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005458:	04491703          	lh	a4,68(s2)
    8000545c:	4785                	li	a5,1
    8000545e:	08f70963          	beq	a4,a5,800054f0 <sys_unlink+0x146>
  iunlockput(dp);
    80005462:	8526                	mv	a0,s1
    80005464:	d0efe0ef          	jal	80003972 <iunlockput>
  ip->nlink--;
    80005468:	04a95783          	lhu	a5,74(s2)
    8000546c:	37fd                	addiw	a5,a5,-1
    8000546e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005472:	854a                	mv	a0,s2
    80005474:	a3efe0ef          	jal	800036b2 <iupdate>
  iunlockput(ip);
    80005478:	854a                	mv	a0,s2
    8000547a:	cf8fe0ef          	jal	80003972 <iunlockput>
  end_op();
    8000547e:	d65fe0ef          	jal	800041e2 <end_op>
  return 0;
    80005482:	4501                	li	a0,0
    80005484:	64ee                	ld	s1,216(sp)
    80005486:	694e                	ld	s2,208(sp)
    80005488:	69ae                	ld	s3,200(sp)
    8000548a:	a061                	j	80005512 <sys_unlink+0x168>
    end_op();
    8000548c:	d57fe0ef          	jal	800041e2 <end_op>
    return -1;
    80005490:	557d                	li	a0,-1
    80005492:	64ee                	ld	s1,216(sp)
    80005494:	a8bd                	j	80005512 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005496:	00002517          	auipc	a0,0x2
    8000549a:	35250513          	addi	a0,a0,850 # 800077e8 <etext+0x7e8>
    8000549e:	b86fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054a2:	04c92703          	lw	a4,76(s2)
    800054a6:	02000793          	li	a5,32
    800054aa:	f8e7f5e3          	bgeu	a5,a4,80005434 <sys_unlink+0x8a>
    800054ae:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054b0:	4741                	li	a4,16
    800054b2:	86ce                	mv	a3,s3
    800054b4:	f1840613          	addi	a2,s0,-232
    800054b8:	4581                	li	a1,0
    800054ba:	854a                	mv	a0,s2
    800054bc:	e3cfe0ef          	jal	80003af8 <readi>
    800054c0:	47c1                	li	a5,16
    800054c2:	00f51b63          	bne	a0,a5,800054d8 <sys_unlink+0x12e>
    if(de.inum != 0)
    800054c6:	f1845783          	lhu	a5,-232(s0)
    800054ca:	ebb1                	bnez	a5,8000551e <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054cc:	29c1                	addiw	s3,s3,16
    800054ce:	04c92783          	lw	a5,76(s2)
    800054d2:	fcf9efe3          	bltu	s3,a5,800054b0 <sys_unlink+0x106>
    800054d6:	bfb9                	j	80005434 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800054d8:	00002517          	auipc	a0,0x2
    800054dc:	32850513          	addi	a0,a0,808 # 80007800 <etext+0x800>
    800054e0:	b44fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800054e4:	00002517          	auipc	a0,0x2
    800054e8:	33450513          	addi	a0,a0,820 # 80007818 <etext+0x818>
    800054ec:	b38fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    800054f0:	04a4d783          	lhu	a5,74(s1)
    800054f4:	37fd                	addiw	a5,a5,-1
    800054f6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054fa:	8526                	mv	a0,s1
    800054fc:	9b6fe0ef          	jal	800036b2 <iupdate>
    80005500:	b78d                	j	80005462 <sys_unlink+0xb8>
    80005502:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005504:	8526                	mv	a0,s1
    80005506:	c6cfe0ef          	jal	80003972 <iunlockput>
  end_op();
    8000550a:	cd9fe0ef          	jal	800041e2 <end_op>
  return -1;
    8000550e:	557d                	li	a0,-1
    80005510:	64ee                	ld	s1,216(sp)
}
    80005512:	70ae                	ld	ra,232(sp)
    80005514:	740e                	ld	s0,224(sp)
    80005516:	616d                	addi	sp,sp,240
    80005518:	8082                	ret
    return -1;
    8000551a:	557d                	li	a0,-1
    8000551c:	bfdd                	j	80005512 <sys_unlink+0x168>
    iunlockput(ip);
    8000551e:	854a                	mv	a0,s2
    80005520:	c52fe0ef          	jal	80003972 <iunlockput>
    goto bad;
    80005524:	694e                	ld	s2,208(sp)
    80005526:	69ae                	ld	s3,200(sp)
    80005528:	bff1                	j	80005504 <sys_unlink+0x15a>

000000008000552a <sys_open>:

uint64
sys_open(void)
{
    8000552a:	7131                	addi	sp,sp,-192
    8000552c:	fd06                	sd	ra,184(sp)
    8000552e:	f922                	sd	s0,176(sp)
    80005530:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005532:	f4c40593          	addi	a1,s0,-180
    80005536:	4505                	li	a0,1
    80005538:	839fd0ef          	jal	80002d70 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000553c:	08000613          	li	a2,128
    80005540:	f5040593          	addi	a1,s0,-176
    80005544:	4501                	li	a0,0
    80005546:	863fd0ef          	jal	80002da8 <argstr>
    8000554a:	87aa                	mv	a5,a0
    return -1;
    8000554c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000554e:	0a07c363          	bltz	a5,800055f4 <sys_open+0xca>
    80005552:	f526                	sd	s1,168(sp)

  begin_op();
    80005554:	c1ffe0ef          	jal	80004172 <begin_op>

  if(omode & O_CREATE){
    80005558:	f4c42783          	lw	a5,-180(s0)
    8000555c:	2007f793          	andi	a5,a5,512
    80005560:	c3dd                	beqz	a5,80005606 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005562:	4681                	li	a3,0
    80005564:	4601                	li	a2,0
    80005566:	4589                	li	a1,2
    80005568:	f5040513          	addi	a0,s0,-176
    8000556c:	aafff0ef          	jal	8000501a <create>
    80005570:	84aa                	mv	s1,a0
    if(ip == 0){
    80005572:	c549                	beqz	a0,800055fc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005574:	04449703          	lh	a4,68(s1)
    80005578:	478d                	li	a5,3
    8000557a:	00f71763          	bne	a4,a5,80005588 <sys_open+0x5e>
    8000557e:	0464d703          	lhu	a4,70(s1)
    80005582:	47a5                	li	a5,9
    80005584:	0ae7ee63          	bltu	a5,a4,80005640 <sys_open+0x116>
    80005588:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000558a:	f69fe0ef          	jal	800044f2 <filealloc>
    8000558e:	892a                	mv	s2,a0
    80005590:	c561                	beqz	a0,80005658 <sys_open+0x12e>
    80005592:	ed4e                	sd	s3,152(sp)
    80005594:	a47ff0ef          	jal	80004fda <fdalloc>
    80005598:	89aa                	mv	s3,a0
    8000559a:	0a054b63          	bltz	a0,80005650 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000559e:	04449703          	lh	a4,68(s1)
    800055a2:	478d                	li	a5,3
    800055a4:	0cf70363          	beq	a4,a5,8000566a <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055a8:	4789                	li	a5,2
    800055aa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800055ae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800055b2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800055b6:	f4c42783          	lw	a5,-180(s0)
    800055ba:	0017f713          	andi	a4,a5,1
    800055be:	00174713          	xori	a4,a4,1
    800055c2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055c6:	0037f713          	andi	a4,a5,3
    800055ca:	00e03733          	snez	a4,a4
    800055ce:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800055d2:	4007f793          	andi	a5,a5,1024
    800055d6:	c791                	beqz	a5,800055e2 <sys_open+0xb8>
    800055d8:	04449703          	lh	a4,68(s1)
    800055dc:	4789                	li	a5,2
    800055de:	08f70d63          	beq	a4,a5,80005678 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800055e2:	8526                	mv	a0,s1
    800055e4:	a30fe0ef          	jal	80003814 <iunlock>
  end_op();
    800055e8:	bfbfe0ef          	jal	800041e2 <end_op>

  return fd;
    800055ec:	854e                	mv	a0,s3
    800055ee:	74aa                	ld	s1,168(sp)
    800055f0:	790a                	ld	s2,160(sp)
    800055f2:	69ea                	ld	s3,152(sp)
}
    800055f4:	70ea                	ld	ra,184(sp)
    800055f6:	744a                	ld	s0,176(sp)
    800055f8:	6129                	addi	sp,sp,192
    800055fa:	8082                	ret
      end_op();
    800055fc:	be7fe0ef          	jal	800041e2 <end_op>
      return -1;
    80005600:	557d                	li	a0,-1
    80005602:	74aa                	ld	s1,168(sp)
    80005604:	bfc5                	j	800055f4 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005606:	f5040513          	addi	a0,s0,-176
    8000560a:	98bfe0ef          	jal	80003f94 <namei>
    8000560e:	84aa                	mv	s1,a0
    80005610:	c11d                	beqz	a0,80005636 <sys_open+0x10c>
    ilock(ip);
    80005612:	954fe0ef          	jal	80003766 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005616:	04449703          	lh	a4,68(s1)
    8000561a:	4785                	li	a5,1
    8000561c:	f4f71ce3          	bne	a4,a5,80005574 <sys_open+0x4a>
    80005620:	f4c42783          	lw	a5,-180(s0)
    80005624:	d3b5                	beqz	a5,80005588 <sys_open+0x5e>
      iunlockput(ip);
    80005626:	8526                	mv	a0,s1
    80005628:	b4afe0ef          	jal	80003972 <iunlockput>
      end_op();
    8000562c:	bb7fe0ef          	jal	800041e2 <end_op>
      return -1;
    80005630:	557d                	li	a0,-1
    80005632:	74aa                	ld	s1,168(sp)
    80005634:	b7c1                	j	800055f4 <sys_open+0xca>
      end_op();
    80005636:	badfe0ef          	jal	800041e2 <end_op>
      return -1;
    8000563a:	557d                	li	a0,-1
    8000563c:	74aa                	ld	s1,168(sp)
    8000563e:	bf5d                	j	800055f4 <sys_open+0xca>
    iunlockput(ip);
    80005640:	8526                	mv	a0,s1
    80005642:	b30fe0ef          	jal	80003972 <iunlockput>
    end_op();
    80005646:	b9dfe0ef          	jal	800041e2 <end_op>
    return -1;
    8000564a:	557d                	li	a0,-1
    8000564c:	74aa                	ld	s1,168(sp)
    8000564e:	b75d                	j	800055f4 <sys_open+0xca>
      fileclose(f);
    80005650:	854a                	mv	a0,s2
    80005652:	f45fe0ef          	jal	80004596 <fileclose>
    80005656:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005658:	8526                	mv	a0,s1
    8000565a:	b18fe0ef          	jal	80003972 <iunlockput>
    end_op();
    8000565e:	b85fe0ef          	jal	800041e2 <end_op>
    return -1;
    80005662:	557d                	li	a0,-1
    80005664:	74aa                	ld	s1,168(sp)
    80005666:	790a                	ld	s2,160(sp)
    80005668:	b771                	j	800055f4 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000566a:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000566e:	04649783          	lh	a5,70(s1)
    80005672:	02f91223          	sh	a5,36(s2)
    80005676:	bf35                	j	800055b2 <sys_open+0x88>
    itrunc(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	9dafe0ef          	jal	80003854 <itrunc>
    8000567e:	b795                	j	800055e2 <sys_open+0xb8>

0000000080005680 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005680:	7175                	addi	sp,sp,-144
    80005682:	e506                	sd	ra,136(sp)
    80005684:	e122                	sd	s0,128(sp)
    80005686:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005688:	aebfe0ef          	jal	80004172 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000568c:	08000613          	li	a2,128
    80005690:	f7040593          	addi	a1,s0,-144
    80005694:	4501                	li	a0,0
    80005696:	f12fd0ef          	jal	80002da8 <argstr>
    8000569a:	02054363          	bltz	a0,800056c0 <sys_mkdir+0x40>
    8000569e:	4681                	li	a3,0
    800056a0:	4601                	li	a2,0
    800056a2:	4585                	li	a1,1
    800056a4:	f7040513          	addi	a0,s0,-144
    800056a8:	973ff0ef          	jal	8000501a <create>
    800056ac:	c911                	beqz	a0,800056c0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056ae:	ac4fe0ef          	jal	80003972 <iunlockput>
  end_op();
    800056b2:	b31fe0ef          	jal	800041e2 <end_op>
  return 0;
    800056b6:	4501                	li	a0,0
}
    800056b8:	60aa                	ld	ra,136(sp)
    800056ba:	640a                	ld	s0,128(sp)
    800056bc:	6149                	addi	sp,sp,144
    800056be:	8082                	ret
    end_op();
    800056c0:	b23fe0ef          	jal	800041e2 <end_op>
    return -1;
    800056c4:	557d                	li	a0,-1
    800056c6:	bfcd                	j	800056b8 <sys_mkdir+0x38>

00000000800056c8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800056c8:	7135                	addi	sp,sp,-160
    800056ca:	ed06                	sd	ra,152(sp)
    800056cc:	e922                	sd	s0,144(sp)
    800056ce:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800056d0:	aa3fe0ef          	jal	80004172 <begin_op>
  argint(1, &major);
    800056d4:	f6c40593          	addi	a1,s0,-148
    800056d8:	4505                	li	a0,1
    800056da:	e96fd0ef          	jal	80002d70 <argint>
  argint(2, &minor);
    800056de:	f6840593          	addi	a1,s0,-152
    800056e2:	4509                	li	a0,2
    800056e4:	e8cfd0ef          	jal	80002d70 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056e8:	08000613          	li	a2,128
    800056ec:	f7040593          	addi	a1,s0,-144
    800056f0:	4501                	li	a0,0
    800056f2:	eb6fd0ef          	jal	80002da8 <argstr>
    800056f6:	02054563          	bltz	a0,80005720 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800056fa:	f6841683          	lh	a3,-152(s0)
    800056fe:	f6c41603          	lh	a2,-148(s0)
    80005702:	458d                	li	a1,3
    80005704:	f7040513          	addi	a0,s0,-144
    80005708:	913ff0ef          	jal	8000501a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000570c:	c911                	beqz	a0,80005720 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000570e:	a64fe0ef          	jal	80003972 <iunlockput>
  end_op();
    80005712:	ad1fe0ef          	jal	800041e2 <end_op>
  return 0;
    80005716:	4501                	li	a0,0
}
    80005718:	60ea                	ld	ra,152(sp)
    8000571a:	644a                	ld	s0,144(sp)
    8000571c:	610d                	addi	sp,sp,160
    8000571e:	8082                	ret
    end_op();
    80005720:	ac3fe0ef          	jal	800041e2 <end_op>
    return -1;
    80005724:	557d                	li	a0,-1
    80005726:	bfcd                	j	80005718 <sys_mknod+0x50>

0000000080005728 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005728:	7135                	addi	sp,sp,-160
    8000572a:	ed06                	sd	ra,152(sp)
    8000572c:	e922                	sd	s0,144(sp)
    8000572e:	e14a                	sd	s2,128(sp)
    80005730:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005732:	a7afc0ef          	jal	800019ac <myproc>
    80005736:	892a                	mv	s2,a0
  
  begin_op();
    80005738:	a3bfe0ef          	jal	80004172 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000573c:	08000613          	li	a2,128
    80005740:	f6040593          	addi	a1,s0,-160
    80005744:	4501                	li	a0,0
    80005746:	e62fd0ef          	jal	80002da8 <argstr>
    8000574a:	04054363          	bltz	a0,80005790 <sys_chdir+0x68>
    8000574e:	e526                	sd	s1,136(sp)
    80005750:	f6040513          	addi	a0,s0,-160
    80005754:	841fe0ef          	jal	80003f94 <namei>
    80005758:	84aa                	mv	s1,a0
    8000575a:	c915                	beqz	a0,8000578e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000575c:	80afe0ef          	jal	80003766 <ilock>
  if(ip->type != T_DIR){
    80005760:	04449703          	lh	a4,68(s1)
    80005764:	4785                	li	a5,1
    80005766:	02f71963          	bne	a4,a5,80005798 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	8a8fe0ef          	jal	80003814 <iunlock>
  iput(p->cwd);
    80005770:	15893503          	ld	a0,344(s2)
    80005774:	974fe0ef          	jal	800038e8 <iput>
  end_op();
    80005778:	a6bfe0ef          	jal	800041e2 <end_op>
  p->cwd = ip;
    8000577c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005780:	4501                	li	a0,0
    80005782:	64aa                	ld	s1,136(sp)
}
    80005784:	60ea                	ld	ra,152(sp)
    80005786:	644a                	ld	s0,144(sp)
    80005788:	690a                	ld	s2,128(sp)
    8000578a:	610d                	addi	sp,sp,160
    8000578c:	8082                	ret
    8000578e:	64aa                	ld	s1,136(sp)
    end_op();
    80005790:	a53fe0ef          	jal	800041e2 <end_op>
    return -1;
    80005794:	557d                	li	a0,-1
    80005796:	b7fd                	j	80005784 <sys_chdir+0x5c>
    iunlockput(ip);
    80005798:	8526                	mv	a0,s1
    8000579a:	9d8fe0ef          	jal	80003972 <iunlockput>
    end_op();
    8000579e:	a45fe0ef          	jal	800041e2 <end_op>
    return -1;
    800057a2:	557d                	li	a0,-1
    800057a4:	64aa                	ld	s1,136(sp)
    800057a6:	bff9                	j	80005784 <sys_chdir+0x5c>

00000000800057a8 <sys_exec>:

uint64
sys_exec(void)
{
    800057a8:	7105                	addi	sp,sp,-480
    800057aa:	ef86                	sd	ra,472(sp)
    800057ac:	eba2                	sd	s0,464(sp)
    800057ae:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800057b0:	e2840593          	addi	a1,s0,-472
    800057b4:	4505                	li	a0,1
    800057b6:	dd6fd0ef          	jal	80002d8c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800057ba:	08000613          	li	a2,128
    800057be:	f3040593          	addi	a1,s0,-208
    800057c2:	4501                	li	a0,0
    800057c4:	de4fd0ef          	jal	80002da8 <argstr>
    800057c8:	87aa                	mv	a5,a0
    return -1;
    800057ca:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800057cc:	0e07c063          	bltz	a5,800058ac <sys_exec+0x104>
    800057d0:	e7a6                	sd	s1,456(sp)
    800057d2:	e3ca                	sd	s2,448(sp)
    800057d4:	ff4e                	sd	s3,440(sp)
    800057d6:	fb52                	sd	s4,432(sp)
    800057d8:	f756                	sd	s5,424(sp)
    800057da:	f35a                	sd	s6,416(sp)
    800057dc:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800057de:	e3040a13          	addi	s4,s0,-464
    800057e2:	10000613          	li	a2,256
    800057e6:	4581                	li	a1,0
    800057e8:	8552                	mv	a0,s4
    800057ea:	d0efb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800057ee:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800057f0:	89d2                	mv	s3,s4
    800057f2:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057f4:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057f8:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800057fa:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057fe:	00391513          	slli	a0,s2,0x3
    80005802:	85d6                	mv	a1,s5
    80005804:	e2843783          	ld	a5,-472(s0)
    80005808:	953e                	add	a0,a0,a5
    8000580a:	cdcfd0ef          	jal	80002ce6 <fetchaddr>
    8000580e:	02054663          	bltz	a0,8000583a <sys_exec+0x92>
    if(uarg == 0){
    80005812:	e2043783          	ld	a5,-480(s0)
    80005816:	c7a1                	beqz	a5,8000585e <sys_exec+0xb6>
    argv[i] = kalloc();
    80005818:	b2cfb0ef          	jal	80000b44 <kalloc>
    8000581c:	85aa                	mv	a1,a0
    8000581e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005822:	cd01                	beqz	a0,8000583a <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005824:	865a                	mv	a2,s6
    80005826:	e2043503          	ld	a0,-480(s0)
    8000582a:	d06fd0ef          	jal	80002d30 <fetchstr>
    8000582e:	00054663          	bltz	a0,8000583a <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005832:	0905                	addi	s2,s2,1
    80005834:	09a1                	addi	s3,s3,8
    80005836:	fd7914e3          	bne	s2,s7,800057fe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000583a:	100a0a13          	addi	s4,s4,256
    8000583e:	6088                	ld	a0,0(s1)
    80005840:	cd31                	beqz	a0,8000589c <sys_exec+0xf4>
    kfree(argv[i]);
    80005842:	a1afb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005846:	04a1                	addi	s1,s1,8
    80005848:	ff449be3          	bne	s1,s4,8000583e <sys_exec+0x96>
  return -1;
    8000584c:	557d                	li	a0,-1
    8000584e:	64be                	ld	s1,456(sp)
    80005850:	691e                	ld	s2,448(sp)
    80005852:	79fa                	ld	s3,440(sp)
    80005854:	7a5a                	ld	s4,432(sp)
    80005856:	7aba                	ld	s5,424(sp)
    80005858:	7b1a                	ld	s6,416(sp)
    8000585a:	6bfa                	ld	s7,408(sp)
    8000585c:	a881                	j	800058ac <sys_exec+0x104>
      argv[i] = 0;
    8000585e:	0009079b          	sext.w	a5,s2
    80005862:	e3040593          	addi	a1,s0,-464
    80005866:	078e                	slli	a5,a5,0x3
    80005868:	97ae                	add	a5,a5,a1
    8000586a:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000586e:	f3040513          	addi	a0,s0,-208
    80005872:	bb2ff0ef          	jal	80004c24 <kexec>
    80005876:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005878:	100a0a13          	addi	s4,s4,256
    8000587c:	6088                	ld	a0,0(s1)
    8000587e:	c511                	beqz	a0,8000588a <sys_exec+0xe2>
    kfree(argv[i]);
    80005880:	9dcfb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005884:	04a1                	addi	s1,s1,8
    80005886:	ff449be3          	bne	s1,s4,8000587c <sys_exec+0xd4>
  return ret;
    8000588a:	854a                	mv	a0,s2
    8000588c:	64be                	ld	s1,456(sp)
    8000588e:	691e                	ld	s2,448(sp)
    80005890:	79fa                	ld	s3,440(sp)
    80005892:	7a5a                	ld	s4,432(sp)
    80005894:	7aba                	ld	s5,424(sp)
    80005896:	7b1a                	ld	s6,416(sp)
    80005898:	6bfa                	ld	s7,408(sp)
    8000589a:	a809                	j	800058ac <sys_exec+0x104>
  return -1;
    8000589c:	557d                	li	a0,-1
    8000589e:	64be                	ld	s1,456(sp)
    800058a0:	691e                	ld	s2,448(sp)
    800058a2:	79fa                	ld	s3,440(sp)
    800058a4:	7a5a                	ld	s4,432(sp)
    800058a6:	7aba                	ld	s5,424(sp)
    800058a8:	7b1a                	ld	s6,416(sp)
    800058aa:	6bfa                	ld	s7,408(sp)
}
    800058ac:	60fe                	ld	ra,472(sp)
    800058ae:	645e                	ld	s0,464(sp)
    800058b0:	613d                	addi	sp,sp,480
    800058b2:	8082                	ret

00000000800058b4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800058b4:	7139                	addi	sp,sp,-64
    800058b6:	fc06                	sd	ra,56(sp)
    800058b8:	f822                	sd	s0,48(sp)
    800058ba:	f426                	sd	s1,40(sp)
    800058bc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800058be:	8eefc0ef          	jal	800019ac <myproc>
    800058c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800058c4:	fd840593          	addi	a1,s0,-40
    800058c8:	4501                	li	a0,0
    800058ca:	cc2fd0ef          	jal	80002d8c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800058ce:	fc840593          	addi	a1,s0,-56
    800058d2:	fd040513          	addi	a0,s0,-48
    800058d6:	fddfe0ef          	jal	800048b2 <pipealloc>
    return -1;
    800058da:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800058dc:	0a054763          	bltz	a0,8000598a <sys_pipe+0xd6>
  fd0 = -1;
    800058e0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800058e4:	fd043503          	ld	a0,-48(s0)
    800058e8:	ef2ff0ef          	jal	80004fda <fdalloc>
    800058ec:	fca42223          	sw	a0,-60(s0)
    800058f0:	08054463          	bltz	a0,80005978 <sys_pipe+0xc4>
    800058f4:	fc843503          	ld	a0,-56(s0)
    800058f8:	ee2ff0ef          	jal	80004fda <fdalloc>
    800058fc:	fca42023          	sw	a0,-64(s0)
    80005900:	06054263          	bltz	a0,80005964 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005904:	4691                	li	a3,4
    80005906:	fc440613          	addi	a2,s0,-60
    8000590a:	fd843583          	ld	a1,-40(s0)
    8000590e:	6ca8                	ld	a0,88(s1)
    80005910:	d45fb0ef          	jal	80001654 <copyout>
    80005914:	00054e63          	bltz	a0,80005930 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005918:	4691                	li	a3,4
    8000591a:	fc040613          	addi	a2,s0,-64
    8000591e:	fd843583          	ld	a1,-40(s0)
    80005922:	95b6                	add	a1,a1,a3
    80005924:	6ca8                	ld	a0,88(s1)
    80005926:	d2ffb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000592a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000592c:	04055f63          	bgez	a0,8000598a <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005930:	fc442783          	lw	a5,-60(s0)
    80005934:	078e                	slli	a5,a5,0x3
    80005936:	0d078793          	addi	a5,a5,208
    8000593a:	97a6                	add	a5,a5,s1
    8000593c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005940:	fc042783          	lw	a5,-64(s0)
    80005944:	078e                	slli	a5,a5,0x3
    80005946:	0d078793          	addi	a5,a5,208
    8000594a:	97a6                	add	a5,a5,s1
    8000594c:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005950:	fd043503          	ld	a0,-48(s0)
    80005954:	c43fe0ef          	jal	80004596 <fileclose>
    fileclose(wf);
    80005958:	fc843503          	ld	a0,-56(s0)
    8000595c:	c3bfe0ef          	jal	80004596 <fileclose>
    return -1;
    80005960:	57fd                	li	a5,-1
    80005962:	a025                	j	8000598a <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005964:	fc442783          	lw	a5,-60(s0)
    80005968:	0007c863          	bltz	a5,80005978 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000596c:	078e                	slli	a5,a5,0x3
    8000596e:	0d078793          	addi	a5,a5,208
    80005972:	97a6                	add	a5,a5,s1
    80005974:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005978:	fd043503          	ld	a0,-48(s0)
    8000597c:	c1bfe0ef          	jal	80004596 <fileclose>
    fileclose(wf);
    80005980:	fc843503          	ld	a0,-56(s0)
    80005984:	c13fe0ef          	jal	80004596 <fileclose>
    return -1;
    80005988:	57fd                	li	a5,-1
}
    8000598a:	853e                	mv	a0,a5
    8000598c:	70e2                	ld	ra,56(sp)
    8000598e:	7442                	ld	s0,48(sp)
    80005990:	74a2                	ld	s1,40(sp)
    80005992:	6121                	addi	sp,sp,64
    80005994:	8082                	ret
	...

00000000800059a0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800059a0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800059a2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800059a4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800059a6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800059a8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800059aa:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800059ac:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800059ae:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800059b0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800059b2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800059b4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800059b6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800059b8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800059ba:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800059bc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800059be:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800059c0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800059c2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800059c4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800059c6:	a2efd0ef          	jal	80002bf4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800059ca:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800059cc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800059ce:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059d0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059d2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059d4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059d6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059d8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059da:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059dc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059de:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059e0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059e2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059e4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059e6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059e8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059ea:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059ec:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059ee:	10200073          	sret
    800059f2:	00000013          	nop
    800059f6:	00000013          	nop
    800059fa:	00000013          	nop

00000000800059fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059fe:	1141                	addi	sp,sp,-16
    80005a00:	e406                	sd	ra,8(sp)
    80005a02:	e022                	sd	s0,0(sp)
    80005a04:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005a06:	0c000737          	lui	a4,0xc000
    80005a0a:	4785                	li	a5,1
    80005a0c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005a0e:	c35c                	sw	a5,4(a4)
}
    80005a10:	60a2                	ld	ra,8(sp)
    80005a12:	6402                	ld	s0,0(sp)
    80005a14:	0141                	addi	sp,sp,16
    80005a16:	8082                	ret

0000000080005a18 <plicinithart>:

void
plicinithart(void)
{
    80005a18:	1141                	addi	sp,sp,-16
    80005a1a:	e406                	sd	ra,8(sp)
    80005a1c:	e022                	sd	s0,0(sp)
    80005a1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a20:	f59fb0ef          	jal	80001978 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005a24:	0085171b          	slliw	a4,a0,0x8
    80005a28:	0c0027b7          	lui	a5,0xc002
    80005a2c:	97ba                	add	a5,a5,a4
    80005a2e:	40200713          	li	a4,1026
    80005a32:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a36:	00d5151b          	slliw	a0,a0,0xd
    80005a3a:	0c2017b7          	lui	a5,0xc201
    80005a3e:	97aa                	add	a5,a5,a0
    80005a40:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a44:	60a2                	ld	ra,8(sp)
    80005a46:	6402                	ld	s0,0(sp)
    80005a48:	0141                	addi	sp,sp,16
    80005a4a:	8082                	ret

0000000080005a4c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a4c:	1141                	addi	sp,sp,-16
    80005a4e:	e406                	sd	ra,8(sp)
    80005a50:	e022                	sd	s0,0(sp)
    80005a52:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a54:	f25fb0ef          	jal	80001978 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a58:	00d5151b          	slliw	a0,a0,0xd
    80005a5c:	0c2017b7          	lui	a5,0xc201
    80005a60:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a62:	43c8                	lw	a0,4(a5)
    80005a64:	60a2                	ld	ra,8(sp)
    80005a66:	6402                	ld	s0,0(sp)
    80005a68:	0141                	addi	sp,sp,16
    80005a6a:	8082                	ret

0000000080005a6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a6c:	1101                	addi	sp,sp,-32
    80005a6e:	ec06                	sd	ra,24(sp)
    80005a70:	e822                	sd	s0,16(sp)
    80005a72:	e426                	sd	s1,8(sp)
    80005a74:	1000                	addi	s0,sp,32
    80005a76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a78:	f01fb0ef          	jal	80001978 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005a7c:	00d5179b          	slliw	a5,a0,0xd
    80005a80:	0c201737          	lui	a4,0xc201
    80005a84:	97ba                	add	a5,a5,a4
    80005a86:	c3c4                	sw	s1,4(a5)
}
    80005a88:	60e2                	ld	ra,24(sp)
    80005a8a:	6442                	ld	s0,16(sp)
    80005a8c:	64a2                	ld	s1,8(sp)
    80005a8e:	6105                	addi	sp,sp,32
    80005a90:	8082                	ret

0000000080005a92 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a92:	1141                	addi	sp,sp,-16
    80005a94:	e406                	sd	ra,8(sp)
    80005a96:	e022                	sd	s0,0(sp)
    80005a98:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a9a:	479d                	li	a5,7
    80005a9c:	04a7ca63          	blt	a5,a0,80005af0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005aa0:	0001e797          	auipc	a5,0x1e
    80005aa4:	eb878793          	addi	a5,a5,-328 # 80023958 <disk>
    80005aa8:	97aa                	add	a5,a5,a0
    80005aaa:	0187c783          	lbu	a5,24(a5)
    80005aae:	e7b9                	bnez	a5,80005afc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ab0:	00451693          	slli	a3,a0,0x4
    80005ab4:	0001e797          	auipc	a5,0x1e
    80005ab8:	ea478793          	addi	a5,a5,-348 # 80023958 <disk>
    80005abc:	6398                	ld	a4,0(a5)
    80005abe:	9736                	add	a4,a4,a3
    80005ac0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005ac4:	6398                	ld	a4,0(a5)
    80005ac6:	9736                	add	a4,a4,a3
    80005ac8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005acc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ad0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ad4:	97aa                	add	a5,a5,a0
    80005ad6:	4705                	li	a4,1
    80005ad8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005adc:	0001e517          	auipc	a0,0x1e
    80005ae0:	e9450513          	addi	a0,a0,-364 # 80023970 <disk+0x18>
    80005ae4:	fc8fc0ef          	jal	800022ac <wakeup>
}
    80005ae8:	60a2                	ld	ra,8(sp)
    80005aea:	6402                	ld	s0,0(sp)
    80005aec:	0141                	addi	sp,sp,16
    80005aee:	8082                	ret
    panic("free_desc 1");
    80005af0:	00002517          	auipc	a0,0x2
    80005af4:	d3850513          	addi	a0,a0,-712 # 80007828 <etext+0x828>
    80005af8:	d2dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    80005afc:	00002517          	auipc	a0,0x2
    80005b00:	d3c50513          	addi	a0,a0,-708 # 80007838 <etext+0x838>
    80005b04:	d21fa0ef          	jal	80000824 <panic>

0000000080005b08 <virtio_disk_init>:
{
    80005b08:	1101                	addi	sp,sp,-32
    80005b0a:	ec06                	sd	ra,24(sp)
    80005b0c:	e822                	sd	s0,16(sp)
    80005b0e:	e426                	sd	s1,8(sp)
    80005b10:	e04a                	sd	s2,0(sp)
    80005b12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005b14:	00002597          	auipc	a1,0x2
    80005b18:	d3458593          	addi	a1,a1,-716 # 80007848 <etext+0x848>
    80005b1c:	0001e517          	auipc	a0,0x1e
    80005b20:	f6450513          	addi	a0,a0,-156 # 80023a80 <disk+0x128>
    80005b24:	87afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b28:	100017b7          	lui	a5,0x10001
    80005b2c:	4398                	lw	a4,0(a5)
    80005b2e:	2701                	sext.w	a4,a4
    80005b30:	747277b7          	lui	a5,0x74727
    80005b34:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b38:	14f71863          	bne	a4,a5,80005c88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b3c:	100017b7          	lui	a5,0x10001
    80005b40:	43dc                	lw	a5,4(a5)
    80005b42:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b44:	4709                	li	a4,2
    80005b46:	14e79163          	bne	a5,a4,80005c88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b4a:	100017b7          	lui	a5,0x10001
    80005b4e:	479c                	lw	a5,8(a5)
    80005b50:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b52:	12e79b63          	bne	a5,a4,80005c88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b56:	100017b7          	lui	a5,0x10001
    80005b5a:	47d8                	lw	a4,12(a5)
    80005b5c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b5e:	554d47b7          	lui	a5,0x554d4
    80005b62:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b66:	12f71163          	bne	a4,a5,80005c88 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b6a:	100017b7          	lui	a5,0x10001
    80005b6e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b72:	4705                	li	a4,1
    80005b74:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b76:	470d                	li	a4,3
    80005b78:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b7a:	10001737          	lui	a4,0x10001
    80005b7e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b80:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b84:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdacc7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b88:	8f75                	and	a4,a4,a3
    80005b8a:	100016b7          	lui	a3,0x10001
    80005b8e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b90:	472d                	li	a4,11
    80005b92:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b94:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b98:	439c                	lw	a5,0(a5)
    80005b9a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b9e:	8ba1                	andi	a5,a5,8
    80005ba0:	0e078a63          	beqz	a5,80005c94 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ba4:	100017b7          	lui	a5,0x10001
    80005ba8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005bac:	43fc                	lw	a5,68(a5)
    80005bae:	2781                	sext.w	a5,a5
    80005bb0:	0e079863          	bnez	a5,80005ca0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005bb4:	100017b7          	lui	a5,0x10001
    80005bb8:	5bdc                	lw	a5,52(a5)
    80005bba:	2781                	sext.w	a5,a5
  if(max == 0)
    80005bbc:	0e078863          	beqz	a5,80005cac <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005bc0:	471d                	li	a4,7
    80005bc2:	0ef77b63          	bgeu	a4,a5,80005cb8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005bc6:	f7ffa0ef          	jal	80000b44 <kalloc>
    80005bca:	0001e497          	auipc	s1,0x1e
    80005bce:	d8e48493          	addi	s1,s1,-626 # 80023958 <disk>
    80005bd2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005bd4:	f71fa0ef          	jal	80000b44 <kalloc>
    80005bd8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bda:	f6bfa0ef          	jal	80000b44 <kalloc>
    80005bde:	87aa                	mv	a5,a0
    80005be0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005be2:	6088                	ld	a0,0(s1)
    80005be4:	0e050063          	beqz	a0,80005cc4 <virtio_disk_init+0x1bc>
    80005be8:	0001e717          	auipc	a4,0x1e
    80005bec:	d7873703          	ld	a4,-648(a4) # 80023960 <disk+0x8>
    80005bf0:	cb71                	beqz	a4,80005cc4 <virtio_disk_init+0x1bc>
    80005bf2:	cbe9                	beqz	a5,80005cc4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005bf4:	6605                	lui	a2,0x1
    80005bf6:	4581                	li	a1,0
    80005bf8:	900fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005bfc:	0001e497          	auipc	s1,0x1e
    80005c00:	d5c48493          	addi	s1,s1,-676 # 80023958 <disk>
    80005c04:	6605                	lui	a2,0x1
    80005c06:	4581                	li	a1,0
    80005c08:	6488                	ld	a0,8(s1)
    80005c0a:	8eefb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005c0e:	6605                	lui	a2,0x1
    80005c10:	4581                	li	a1,0
    80005c12:	6888                	ld	a0,16(s1)
    80005c14:	8e4fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005c18:	100017b7          	lui	a5,0x10001
    80005c1c:	4721                	li	a4,8
    80005c1e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c20:	4098                	lw	a4,0(s1)
    80005c22:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c26:	40d8                	lw	a4,4(s1)
    80005c28:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c2c:	649c                	ld	a5,8(s1)
    80005c2e:	0007869b          	sext.w	a3,a5
    80005c32:	10001737          	lui	a4,0x10001
    80005c36:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c3a:	9781                	srai	a5,a5,0x20
    80005c3c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c40:	689c                	ld	a5,16(s1)
    80005c42:	0007869b          	sext.w	a3,a5
    80005c46:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c4a:	9781                	srai	a5,a5,0x20
    80005c4c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c50:	4785                	li	a5,1
    80005c52:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c54:	00f48c23          	sb	a5,24(s1)
    80005c58:	00f48ca3          	sb	a5,25(s1)
    80005c5c:	00f48d23          	sb	a5,26(s1)
    80005c60:	00f48da3          	sb	a5,27(s1)
    80005c64:	00f48e23          	sb	a5,28(s1)
    80005c68:	00f48ea3          	sb	a5,29(s1)
    80005c6c:	00f48f23          	sb	a5,30(s1)
    80005c70:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c74:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c78:	07272823          	sw	s2,112(a4)
}
    80005c7c:	60e2                	ld	ra,24(sp)
    80005c7e:	6442                	ld	s0,16(sp)
    80005c80:	64a2                	ld	s1,8(sp)
    80005c82:	6902                	ld	s2,0(sp)
    80005c84:	6105                	addi	sp,sp,32
    80005c86:	8082                	ret
    panic("could not find virtio disk");
    80005c88:	00002517          	auipc	a0,0x2
    80005c8c:	bd050513          	addi	a0,a0,-1072 # 80007858 <etext+0x858>
    80005c90:	b95fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c94:	00002517          	auipc	a0,0x2
    80005c98:	be450513          	addi	a0,a0,-1052 # 80007878 <etext+0x878>
    80005c9c:	b89fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005ca0:	00002517          	auipc	a0,0x2
    80005ca4:	bf850513          	addi	a0,a0,-1032 # 80007898 <etext+0x898>
    80005ca8:	b7dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005cac:	00002517          	auipc	a0,0x2
    80005cb0:	c0c50513          	addi	a0,a0,-1012 # 800078b8 <etext+0x8b8>
    80005cb4:	b71fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005cb8:	00002517          	auipc	a0,0x2
    80005cbc:	c2050513          	addi	a0,a0,-992 # 800078d8 <etext+0x8d8>
    80005cc0:	b65fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005cc4:	00002517          	auipc	a0,0x2
    80005cc8:	c3450513          	addi	a0,a0,-972 # 800078f8 <etext+0x8f8>
    80005ccc:	b59fa0ef          	jal	80000824 <panic>

0000000080005cd0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005cd0:	711d                	addi	sp,sp,-96
    80005cd2:	ec86                	sd	ra,88(sp)
    80005cd4:	e8a2                	sd	s0,80(sp)
    80005cd6:	e4a6                	sd	s1,72(sp)
    80005cd8:	e0ca                	sd	s2,64(sp)
    80005cda:	fc4e                	sd	s3,56(sp)
    80005cdc:	f852                	sd	s4,48(sp)
    80005cde:	f456                	sd	s5,40(sp)
    80005ce0:	f05a                	sd	s6,32(sp)
    80005ce2:	ec5e                	sd	s7,24(sp)
    80005ce4:	e862                	sd	s8,16(sp)
    80005ce6:	1080                	addi	s0,sp,96
    80005ce8:	89aa                	mv	s3,a0
    80005cea:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cec:	00c52b83          	lw	s7,12(a0)
    80005cf0:	001b9b9b          	slliw	s7,s7,0x1
    80005cf4:	1b82                	slli	s7,s7,0x20
    80005cf6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005cfa:	0001e517          	auipc	a0,0x1e
    80005cfe:	d8650513          	addi	a0,a0,-634 # 80023a80 <disk+0x128>
    80005d02:	f27fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005d06:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005d08:	0001ea97          	auipc	s5,0x1e
    80005d0c:	c50a8a93          	addi	s5,s5,-944 # 80023958 <disk>
  for(int i = 0; i < 3; i++){
    80005d10:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005d12:	5c7d                	li	s8,-1
    80005d14:	a095                	j	80005d78 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005d16:	00fa8733          	add	a4,s5,a5
    80005d1a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005d1e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005d20:	0207c563          	bltz	a5,80005d4a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005d24:	2905                	addiw	s2,s2,1
    80005d26:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d28:	05490c63          	beq	s2,s4,80005d80 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005d2c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d2e:	0001e717          	auipc	a4,0x1e
    80005d32:	c2a70713          	addi	a4,a4,-982 # 80023958 <disk>
    80005d36:	4781                	li	a5,0
    if(disk.free[i]){
    80005d38:	01874683          	lbu	a3,24(a4)
    80005d3c:	fee9                	bnez	a3,80005d16 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005d3e:	2785                	addiw	a5,a5,1
    80005d40:	0705                	addi	a4,a4,1
    80005d42:	fe979be3          	bne	a5,s1,80005d38 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005d46:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005d4a:	01205d63          	blez	s2,80005d64 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d4e:	fa042503          	lw	a0,-96(s0)
    80005d52:	d41ff0ef          	jal	80005a92 <free_desc>
      for(int j = 0; j < i; j++)
    80005d56:	4785                	li	a5,1
    80005d58:	0127d663          	bge	a5,s2,80005d64 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d5c:	fa442503          	lw	a0,-92(s0)
    80005d60:	d33ff0ef          	jal	80005a92 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d64:	0001e597          	auipc	a1,0x1e
    80005d68:	d1c58593          	addi	a1,a1,-740 # 80023a80 <disk+0x128>
    80005d6c:	0001e517          	auipc	a0,0x1e
    80005d70:	c0450513          	addi	a0,a0,-1020 # 80023970 <disk+0x18>
    80005d74:	cecfc0ef          	jal	80002260 <sleep>
  for(int i = 0; i < 3; i++){
    80005d78:	fa040613          	addi	a2,s0,-96
    80005d7c:	4901                	li	s2,0
    80005d7e:	b77d                	j	80005d2c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d80:	fa042503          	lw	a0,-96(s0)
    80005d84:	00451693          	slli	a3,a0,0x4

  if(write)
    80005d88:	0001e797          	auipc	a5,0x1e
    80005d8c:	bd078793          	addi	a5,a5,-1072 # 80023958 <disk>
    80005d90:	00451713          	slli	a4,a0,0x4
    80005d94:	0a070713          	addi	a4,a4,160
    80005d98:	973e                	add	a4,a4,a5
    80005d9a:	01603633          	snez	a2,s6
    80005d9e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005da0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005da4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005da8:	6398                	ld	a4,0(a5)
    80005daa:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005dac:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005db0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005db2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005db4:	6390                	ld	a2,0(a5)
    80005db6:	00d60833          	add	a6,a2,a3
    80005dba:	4741                	li	a4,16
    80005dbc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005dc0:	4585                	li	a1,1
    80005dc2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005dc6:	fa442703          	lw	a4,-92(s0)
    80005dca:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005dce:	0712                	slli	a4,a4,0x4
    80005dd0:	963a                	add	a2,a2,a4
    80005dd2:	05898813          	addi	a6,s3,88
    80005dd6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dda:	0007b883          	ld	a7,0(a5)
    80005dde:	9746                	add	a4,a4,a7
    80005de0:	40000613          	li	a2,1024
    80005de4:	c710                	sw	a2,8(a4)
  if(write)
    80005de6:	001b3613          	seqz	a2,s6
    80005dea:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dee:	8e4d                	or	a2,a2,a1
    80005df0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005df4:	fa842603          	lw	a2,-88(s0)
    80005df8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005dfc:	00451813          	slli	a6,a0,0x4
    80005e00:	02080813          	addi	a6,a6,32
    80005e04:	983e                	add	a6,a6,a5
    80005e06:	577d                	li	a4,-1
    80005e08:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005e0c:	0612                	slli	a2,a2,0x4
    80005e0e:	98b2                	add	a7,a7,a2
    80005e10:	03068713          	addi	a4,a3,48
    80005e14:	973e                	add	a4,a4,a5
    80005e16:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e1a:	6398                	ld	a4,0(a5)
    80005e1c:	9732                	add	a4,a4,a2
    80005e1e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e20:	4689                	li	a3,2
    80005e22:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e26:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e2a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005e2e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e32:	6794                	ld	a3,8(a5)
    80005e34:	0026d703          	lhu	a4,2(a3)
    80005e38:	8b1d                	andi	a4,a4,7
    80005e3a:	0706                	slli	a4,a4,0x1
    80005e3c:	96ba                	add	a3,a3,a4
    80005e3e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e42:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e46:	6798                	ld	a4,8(a5)
    80005e48:	00275783          	lhu	a5,2(a4)
    80005e4c:	2785                	addiw	a5,a5,1
    80005e4e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e52:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e5e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005e62:	0001e917          	auipc	s2,0x1e
    80005e66:	c1e90913          	addi	s2,s2,-994 # 80023a80 <disk+0x128>
  while(b->disk == 1) {
    80005e6a:	84ae                	mv	s1,a1
    80005e6c:	00b79a63          	bne	a5,a1,80005e80 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005e70:	85ca                	mv	a1,s2
    80005e72:	854e                	mv	a0,s3
    80005e74:	becfc0ef          	jal	80002260 <sleep>
  while(b->disk == 1) {
    80005e78:	0049a783          	lw	a5,4(s3)
    80005e7c:	fe978ae3          	beq	a5,s1,80005e70 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005e80:	fa042903          	lw	s2,-96(s0)
    80005e84:	00491713          	slli	a4,s2,0x4
    80005e88:	02070713          	addi	a4,a4,32
    80005e8c:	0001e797          	auipc	a5,0x1e
    80005e90:	acc78793          	addi	a5,a5,-1332 # 80023958 <disk>
    80005e94:	97ba                	add	a5,a5,a4
    80005e96:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e9a:	0001e997          	auipc	s3,0x1e
    80005e9e:	abe98993          	addi	s3,s3,-1346 # 80023958 <disk>
    80005ea2:	00491713          	slli	a4,s2,0x4
    80005ea6:	0009b783          	ld	a5,0(s3)
    80005eaa:	97ba                	add	a5,a5,a4
    80005eac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005eb0:	854a                	mv	a0,s2
    80005eb2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005eb6:	bddff0ef          	jal	80005a92 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005eba:	8885                	andi	s1,s1,1
    80005ebc:	f0fd                	bnez	s1,80005ea2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ebe:	0001e517          	auipc	a0,0x1e
    80005ec2:	bc250513          	addi	a0,a0,-1086 # 80023a80 <disk+0x128>
    80005ec6:	df7fa0ef          	jal	80000cbc <release>
}
    80005eca:	60e6                	ld	ra,88(sp)
    80005ecc:	6446                	ld	s0,80(sp)
    80005ece:	64a6                	ld	s1,72(sp)
    80005ed0:	6906                	ld	s2,64(sp)
    80005ed2:	79e2                	ld	s3,56(sp)
    80005ed4:	7a42                	ld	s4,48(sp)
    80005ed6:	7aa2                	ld	s5,40(sp)
    80005ed8:	7b02                	ld	s6,32(sp)
    80005eda:	6be2                	ld	s7,24(sp)
    80005edc:	6c42                	ld	s8,16(sp)
    80005ede:	6125                	addi	sp,sp,96
    80005ee0:	8082                	ret

0000000080005ee2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ee2:	1101                	addi	sp,sp,-32
    80005ee4:	ec06                	sd	ra,24(sp)
    80005ee6:	e822                	sd	s0,16(sp)
    80005ee8:	e426                	sd	s1,8(sp)
    80005eea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005eec:	0001e497          	auipc	s1,0x1e
    80005ef0:	a6c48493          	addi	s1,s1,-1428 # 80023958 <disk>
    80005ef4:	0001e517          	auipc	a0,0x1e
    80005ef8:	b8c50513          	addi	a0,a0,-1140 # 80023a80 <disk+0x128>
    80005efc:	d2dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f00:	100017b7          	lui	a5,0x10001
    80005f04:	53bc                	lw	a5,96(a5)
    80005f06:	8b8d                	andi	a5,a5,3
    80005f08:	10001737          	lui	a4,0x10001
    80005f0c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005f0e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005f12:	689c                	ld	a5,16(s1)
    80005f14:	0204d703          	lhu	a4,32(s1)
    80005f18:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f1c:	04f70863          	beq	a4,a5,80005f6c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005f20:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f24:	6898                	ld	a4,16(s1)
    80005f26:	0204d783          	lhu	a5,32(s1)
    80005f2a:	8b9d                	andi	a5,a5,7
    80005f2c:	078e                	slli	a5,a5,0x3
    80005f2e:	97ba                	add	a5,a5,a4
    80005f30:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f32:	00479713          	slli	a4,a5,0x4
    80005f36:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005f3a:	9726                	add	a4,a4,s1
    80005f3c:	01074703          	lbu	a4,16(a4)
    80005f40:	e329                	bnez	a4,80005f82 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f42:	0792                	slli	a5,a5,0x4
    80005f44:	02078793          	addi	a5,a5,32
    80005f48:	97a6                	add	a5,a5,s1
    80005f4a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f4c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f50:	b5cfc0ef          	jal	800022ac <wakeup>

    disk.used_idx += 1;
    80005f54:	0204d783          	lhu	a5,32(s1)
    80005f58:	2785                	addiw	a5,a5,1
    80005f5a:	17c2                	slli	a5,a5,0x30
    80005f5c:	93c1                	srli	a5,a5,0x30
    80005f5e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f62:	6898                	ld	a4,16(s1)
    80005f64:	00275703          	lhu	a4,2(a4)
    80005f68:	faf71ce3          	bne	a4,a5,80005f20 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f6c:	0001e517          	auipc	a0,0x1e
    80005f70:	b1450513          	addi	a0,a0,-1260 # 80023a80 <disk+0x128>
    80005f74:	d49fa0ef          	jal	80000cbc <release>
}
    80005f78:	60e2                	ld	ra,24(sp)
    80005f7a:	6442                	ld	s0,16(sp)
    80005f7c:	64a2                	ld	s1,8(sp)
    80005f7e:	6105                	addi	sp,sp,32
    80005f80:	8082                	ret
      panic("virtio_disk_intr status");
    80005f82:	00002517          	auipc	a0,0x2
    80005f86:	98e50513          	addi	a0,a0,-1650 # 80007910 <etext+0x910>
    80005f8a:	89bfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
