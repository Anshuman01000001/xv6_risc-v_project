
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
    80000004:	87813103          	ld	sp,-1928(sp) # 8000b878 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9897>
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
    8000011a:	22b020ef          	jal	80002b44 <either_copyin>
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
    80000196:	74e50513          	addi	a0,a0,1870 # 800138e0 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00013497          	auipc	s1,0x13
    800001a2:	74248493          	addi	s1,s1,1858 # 800138e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00013917          	auipc	s2,0x13
    800001aa:	7d290913          	addi	s2,s2,2002 # 80013978 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	137010ef          	jal	80001af4 <myproc>
    800001c2:	01b020ef          	jal	800029dc <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	5d4020ef          	jal	800027a0 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00013717          	auipc	a4,0x13
    800001e2:	70270713          	addi	a4,a4,1794 # 800138e0 <cons>
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
    80000210:	0eb020ef          	jal	80002afa <either_copyout>
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
    8000022c:	6b850513          	addi	a0,a0,1720 # 800138e0 <cons>
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
    80000252:	72f72523          	sw	a5,1834(a4) # 80013978 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00013517          	auipc	a0,0x13
    80000268:	67c50513          	addi	a0,a0,1660 # 800138e0 <cons>
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
    800002bc:	62850513          	addi	a0,a0,1576 # 800138e0 <cons>
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
    800002da:	0b5020ef          	jal	80002b8e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00013517          	auipc	a0,0x13
    800002e2:	60250513          	addi	a0,a0,1538 # 800138e0 <cons>
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
    80000300:	5e470713          	addi	a4,a4,1508 # 800138e0 <cons>
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
    80000326:	5be70713          	addi	a4,a4,1470 # 800138e0 <cons>
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
    80000350:	62c72703          	lw	a4,1580(a4) # 80013978 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00013717          	auipc	a4,0x13
    80000366:	57e70713          	addi	a4,a4,1406 # 800138e0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00013497          	auipc	s1,0x13
    80000376:	56e48493          	addi	s1,s1,1390 # 800138e0 <cons>
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
    800003b8:	52c70713          	addi	a4,a4,1324 # 800138e0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00013717          	auipc	a4,0x13
    800003ce:	5af72b23          	sw	a5,1462(a4) # 80013980 <cons+0xa0>
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
    800003ec:	4f878793          	addi	a5,a5,1272 # 800138e0 <cons>
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
    8000040e:	56c7a923          	sw	a2,1394(a5) # 8001397c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00013517          	auipc	a0,0x13
    80000416:	56650513          	addi	a0,a0,1382 # 80013978 <cons+0x98>
    8000041a:	3d2020ef          	jal	800027ec <wakeup>
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
    80000434:	4b050513          	addi	a0,a0,1200 # 800138e0 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00024797          	auipc	a5,0x24
    80000444:	99078793          	addi	a5,a5,-1648 # 80023dd0 <devsw>
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
    80000482:	72280813          	addi	a6,a6,1826 # 80008ba0 <digits>
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
    8000051c:	37c7a783          	lw	a5,892(a5) # 8000b894 <panicking>
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
    80000562:	42a50513          	addi	a0,a0,1066 # 80013988 <pr>
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
    800006d6:	4cec8c93          	addi	s9,s9,1230 # 80008ba0 <digits>
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
    8000075e:	13a7a783          	lw	a5,314(a5) # 8000b894 <panicking>
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
    80000788:	20450513          	addi	a0,a0,516 # 80013988 <pr>
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
    80000838:	0697a023          	sw	s1,96(a5) # 8000b894 <panicking>
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
    8000085a:	0297ad23          	sw	s1,58(a5) # 8000b890 <panicked>
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
    80000874:	11850513          	addi	a0,a0,280 # 80013988 <pr>
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
    800008ca:	0da50513          	addi	a0,a0,218 # 800139a0 <tx_lock>
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
    800008ee:	0b650513          	addi	a0,a0,182 # 800139a0 <tx_lock>
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
    8000090c:	f9448493          	addi	s1,s1,-108 # 8000b89c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00013997          	auipc	s3,0x13
    80000914:	09098993          	addi	s3,s3,144 # 800139a0 <tx_lock>
    80000918:	0000b917          	auipc	s2,0xb
    8000091c:	f8090913          	addi	s2,s2,-128 # 8000b898 <tx_chan>
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
    8000092c:	675010ef          	jal	800027a0 <sleep>
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
    8000095a:	04a50513          	addi	a0,a0,74 # 800139a0 <tx_lock>
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
    8000097e:	f1a7a783          	lw	a5,-230(a5) # 8000b894 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000b797          	auipc	a5,0xb
    80000988:	f0c7a783          	lw	a5,-244(a5) # 8000b890 <panicked>
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
    800009ae:	eea7a783          	lw	a5,-278(a5) # 8000b894 <panicking>
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
    80000a0a:	f9a50513          	addi	a0,a0,-102 # 800139a0 <tx_lock>
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
    80000a24:	f8050513          	addi	a0,a0,-128 # 800139a0 <tx_lock>
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
    80000a40:	e607a023          	sw	zero,-416(a5) # 8000b89c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000b517          	auipc	a0,0xb
    80000a48:	e5450513          	addi	a0,a0,-428 # 8000b898 <tx_chan>
    80000a4c:	5a1010ef          	jal	800027ec <wakeup>
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
    80000a6c:	50078793          	addi	a5,a5,1280 # 80024f68 <end>
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
    80000a96:	f2690913          	addi	s2,s2,-218 # 800139b8 <kmem>
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
    80000b24:	e9850513          	addi	a0,a0,-360 # 800139b8 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00024517          	auipc	a0,0x24
    80000b34:	43850513          	addi	a0,a0,1080 # 80024f68 <end>
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
    80000b52:	e6a50513          	addi	a0,a0,-406 # 800139b8 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00013497          	auipc	s1,0x13
    80000b5e:	e764b483          	ld	s1,-394(s1) # 800139d0 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00013717          	auipc	a4,0x13
    80000b6a:	e6f73523          	sd	a5,-406(a4) # 800139d0 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00013517          	auipc	a0,0x13
    80000b72:	e4a50513          	addi	a0,a0,-438 # 800139b8 <kmem>
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
    80000b94:	e2850513          	addi	a0,a0,-472 # 800139b8 <kmem>
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
    80000bce:	707000ef          	jal	80001ad4 <mycpu>
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
    80000bfe:	6d7000ef          	jal	80001ad4 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	6cf000ef          	jal	80001ad4 <mycpu>
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
    80000c1a:	6bb000ef          	jal	80001ad4 <mycpu>
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
    80000c50:	685000ef          	jal	80001ad4 <mycpu>
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
    80000c74:	661000ef          	jal	80001ad4 <mycpu>
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
    80000eb6:	40b000ef          	jal	80001ac0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	0000b717          	auipc	a4,0xb
    80000ebe:	9e670713          	addi	a4,a4,-1562 # 8000b8a0 <started>
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
    80000ece:	3f3000ef          	jal	80001ac0 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00007517          	auipc	a0,0x7
    80000ed8:	1c450513          	addi	a0,a0,452 # 80008098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	7c1010ef          	jal	80002ea4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	070050ef          	jal	80005f58 <plicinithart>
  }

  scheduler();        
    80000eec:	08c010ef          	jal	80001f78 <scheduler>
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
    80000f28:	2e3000ef          	jal	80001a0a <procinit>
    trapinit();      // trap vectors
    80000f2c:	755010ef          	jal	80002e80 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	775010ef          	jal	80002ea4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	00a050ef          	jal	80005f3e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	020050ef          	jal	80005f58 <plicinithart>
    binit();         // buffer cache
    80000f3c:	64c020ef          	jal	80003588 <binit>
    iinit();         // inode table
    80000f40:	39f020ef          	jal	80003ade <iinit>
    fileinit();      // file table
    80000f44:	2cb030ef          	jal	80004a0e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	100050ef          	jal	80006048 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	681000ef          	jal	80001dcc <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	0000b717          	auipc	a4,0xb
    80000f5a:	94f72523          	sw	a5,-1718(a4) # 8000b8a0 <started>
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
    80000f70:	93c7b783          	ld	a5,-1732(a5) # 8000b8a8 <kernel_pagetable>
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
    800011dc:	78a000ef          	jal	80001966 <proc_mapstacks>
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
    800011fc:	6aa7b823          	sd	a0,1712(a5) # 8000b8a8 <kernel_pagetable>
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
    800015e0:	514000ef          	jal	80001af4 <myproc>
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
    800017ac:	23060613          	addi	a2,a2,560 # 800139d8 <tm>
{
    800017b0:	8732                	mv	a4,a2
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017b2:	4781                	li	a5,0
    800017b4:	45c1                	li	a1,16
    if(tm[i].pid == pid) return &tm[i];
    800017b6:	4314                	lw	a3,0(a4)
    800017b8:	02a68063          	beq	a3,a0,800017d8 <tm_find+0x38>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017bc:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda099>
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
    800017e4:	1f850513          	addi	a0,a0,504 # 800139d8 <tm>
    800017e8:	953e                	add	a0,a0,a5
}
    800017ea:	60a2                	ld	ra,8(sp)
    800017ec:	6402                	ld	s0,0(sp)
    800017ee:	0141                	addi	sp,sp,16
    800017f0:	8082                	ret
      tm[i].pid = pid;
    800017f2:	00012717          	auipc	a4,0x12
    800017f6:	1e670713          	addi	a4,a4,486 # 800139d8 <tm>
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
    80001854:	2685                	addiw	a3,a3,1 # fffffffffffff001 <end+0xffffffff7ffda099>
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

00000000800018aa <is_thermal_test>:
{
    800018aa:	1101                	addi	sp,sp,-32
    800018ac:	ec06                	sd	ra,24(sp)
    800018ae:	e822                	sd	s0,16(sp)
    800018b0:	e426                	sd	s1,8(sp)
    800018b2:	1000                	addi	s0,sp,32
    800018b4:	84aa                	mv	s1,a0
  return strncmp(name, "schedtest", 9) == 0 ||
    800018b6:	4625                	li	a2,9
    800018b8:	00007597          	auipc	a1,0x7
    800018bc:	8b058593          	addi	a1,a1,-1872 # 80008168 <etext+0x168>
    800018c0:	d0cff0ef          	jal	80000dcc <strncmp>
    800018c4:	e519                	bnez	a0,800018d2 <is_thermal_test+0x28>
    800018c6:	4505                	li	a0,1
}
    800018c8:	60e2                	ld	ra,24(sp)
    800018ca:	6442                	ld	s0,16(sp)
    800018cc:	64a2                	ld	s1,8(sp)
    800018ce:	6105                	addi	sp,sp,32
    800018d0:	8082                	ret
         strncmp(name, "matrix", 6) == 0;
    800018d2:	4619                	li	a2,6
    800018d4:	00007597          	auipc	a1,0x7
    800018d8:	8a458593          	addi	a1,a1,-1884 # 80008178 <etext+0x178>
    800018dc:	8526                	mv	a0,s1
    800018de:	ceeff0ef          	jal	80000dcc <strncmp>
  return strncmp(name, "schedtest", 9) == 0 ||
    800018e2:	00153513          	seqz	a0,a0
    800018e6:	b7cd                	j	800018c8 <is_thermal_test+0x1e>

00000000800018e8 <update_cpu_temp>:
void update_cpu_temp(int process_heat) {
    800018e8:	1141                	addi	sp,sp,-16
    800018ea:	e406                	sd	ra,8(sp)
    800018ec:	e022                	sd	s0,0(sp)
    800018ee:	0800                	addi	s0,sp,16
  if (process_heat > 0) {
    800018f0:	04a05263          	blez	a0,80001934 <update_cpu_temp+0x4c>
    int heat_factor = 1 + process_heat / 30;  // 1‒4
    800018f4:	888897b7          	lui	a5,0x88889
    800018f8:	88978793          	addi	a5,a5,-1911 # ffffffff88888889 <end+0xffffffff08863921>
    800018fc:	02f507b3          	mul	a5,a0,a5
    80001900:	9381                	srli	a5,a5,0x20
    80001902:	9fa9                	addw	a5,a5,a0
    80001904:	4047d79b          	sraiw	a5,a5,0x4
    80001908:	41f5551b          	sraiw	a0,a0,0x1f
    8000190c:	9f89                	subw	a5,a5,a0
    8000190e:	2785                	addiw	a5,a5,1
    cpu_temp += heat_factor;
    80001910:	0000a717          	auipc	a4,0xa
    80001914:	f5872703          	lw	a4,-168(a4) # 8000b868 <cpu_temp>
    80001918:	9fb9                	addw	a5,a5,a4
  if(cpu_temp > 100)
    8000191a:	06400713          	li	a4,100
    8000191e:	02f75663          	bge	a4,a5,8000194a <update_cpu_temp+0x62>
    cpu_temp = 100;
    80001922:	87ba                	mv	a5,a4
    80001924:	0000a717          	auipc	a4,0xa
    80001928:	f4f72223          	sw	a5,-188(a4) # 8000b868 <cpu_temp>
}
    8000192c:	60a2                	ld	ra,8(sp)
    8000192e:	6402                	ld	s0,0(sp)
    80001930:	0141                	addi	sp,sp,16
    80001932:	8082                	ret
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
    80001934:	0000a797          	auipc	a5,0xa
    80001938:	f347a783          	lw	a5,-204(a5) # 8000b868 <cpu_temp>
    8000193c:	03200713          	li	a4,50
    80001940:	00f72733          	slt	a4,a4,a5
    80001944:	0705                	addi	a4,a4,1
    80001946:	9f99                	subw	a5,a5,a4
    80001948:	bfc9                	j	8000191a <update_cpu_temp+0x32>
  else if(cpu_temp < 20)
    8000194a:	474d                	li	a4,19
    8000194c:	00f75763          	bge	a4,a5,8000195a <update_cpu_temp+0x72>
    cpu_temp += heat_factor;
    80001950:	0000a717          	auipc	a4,0xa
    80001954:	f0f72c23          	sw	a5,-232(a4) # 8000b868 <cpu_temp>
    80001958:	bfd1                	j	8000192c <update_cpu_temp+0x44>
    cpu_temp = 20;
    8000195a:	47d1                	li	a5,20
    8000195c:	0000a717          	auipc	a4,0xa
    80001960:	f0f72623          	sw	a5,-244(a4) # 8000b868 <cpu_temp>
}
    80001964:	b7e1                	j	8000192c <update_cpu_temp+0x44>

0000000080001966 <proc_mapstacks>:
{
    80001966:	715d                	addi	sp,sp,-80
    80001968:	e486                	sd	ra,72(sp)
    8000196a:	e0a2                	sd	s0,64(sp)
    8000196c:	fc26                	sd	s1,56(sp)
    8000196e:	f84a                	sd	s2,48(sp)
    80001970:	f44e                	sd	s3,40(sp)
    80001972:	f052                	sd	s4,32(sp)
    80001974:	ec56                	sd	s5,24(sp)
    80001976:	e85a                	sd	s6,16(sp)
    80001978:	e45e                	sd	s7,8(sp)
    8000197a:	e062                	sd	s8,0(sp)
    8000197c:	0880                	addi	s0,sp,80
    8000197e:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001980:	00012497          	auipc	s1,0x12
    80001984:	60848493          	addi	s1,s1,1544 # 80013f88 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001988:	8c26                	mv	s8,s1
    8000198a:	ff4df937          	lui	s2,0xff4df
    8000198e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a55>
    80001992:	0936                	slli	s2,s2,0xd
    80001994:	6f590913          	addi	s2,s2,1781
    80001998:	0936                	slli	s2,s2,0xd
    8000199a:	bd390913          	addi	s2,s2,-1069
    8000199e:	0932                	slli	s2,s2,0xc
    800019a0:	7a790913          	addi	s2,s2,1959
    800019a4:	040009b7          	lui	s3,0x4000
    800019a8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019aa:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ac:	4b99                	li	s7,6
    800019ae:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b0:	00018a97          	auipc	s5,0x18
    800019b4:	1d8a8a93          	addi	s5,s5,472 # 80019b88 <tickslock>
    char *pa = kalloc();
    800019b8:	98cff0ef          	jal	80000b44 <kalloc>
    800019bc:	862a                	mv	a2,a0
    if(pa == 0)
    800019be:	c121                	beqz	a0,800019fe <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    800019c0:	418485b3          	sub	a1,s1,s8
    800019c4:	8591                	srai	a1,a1,0x4
    800019c6:	032585b3          	mul	a1,a1,s2
    800019ca:	05b6                	slli	a1,a1,0xd
    800019cc:	6789                	lui	a5,0x2
    800019ce:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019d0:	875e                	mv	a4,s7
    800019d2:	86da                	mv	a3,s6
    800019d4:	40b985b3          	sub	a1,s3,a1
    800019d8:	8552                	mv	a0,s4
    800019da:	f3cff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019de:	17048493          	addi	s1,s1,368
    800019e2:	fd549be3          	bne	s1,s5,800019b8 <proc_mapstacks+0x52>
}
    800019e6:	60a6                	ld	ra,72(sp)
    800019e8:	6406                	ld	s0,64(sp)
    800019ea:	74e2                	ld	s1,56(sp)
    800019ec:	7942                	ld	s2,48(sp)
    800019ee:	79a2                	ld	s3,40(sp)
    800019f0:	7a02                	ld	s4,32(sp)
    800019f2:	6ae2                	ld	s5,24(sp)
    800019f4:	6b42                	ld	s6,16(sp)
    800019f6:	6ba2                	ld	s7,8(sp)
    800019f8:	6c02                	ld	s8,0(sp)
    800019fa:	6161                	addi	sp,sp,80
    800019fc:	8082                	ret
      panic("kalloc");
    800019fe:	00006517          	auipc	a0,0x6
    80001a02:	78250513          	addi	a0,a0,1922 # 80008180 <etext+0x180>
    80001a06:	e1ffe0ef          	jal	80000824 <panic>

0000000080001a0a <procinit>:
{
    80001a0a:	7139                	addi	sp,sp,-64
    80001a0c:	fc06                	sd	ra,56(sp)
    80001a0e:	f822                	sd	s0,48(sp)
    80001a10:	f426                	sd	s1,40(sp)
    80001a12:	f04a                	sd	s2,32(sp)
    80001a14:	ec4e                	sd	s3,24(sp)
    80001a16:	e852                	sd	s4,16(sp)
    80001a18:	e456                	sd	s5,8(sp)
    80001a1a:	e05a                	sd	s6,0(sp)
    80001a1c:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001a1e:	00006597          	auipc	a1,0x6
    80001a22:	76a58593          	addi	a1,a1,1898 # 80008188 <etext+0x188>
    80001a26:	00012517          	auipc	a0,0x12
    80001a2a:	13250513          	addi	a0,a0,306 # 80013b58 <pid_lock>
    80001a2e:	970ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a32:	00006597          	auipc	a1,0x6
    80001a36:	75e58593          	addi	a1,a1,1886 # 80008190 <etext+0x190>
    80001a3a:	00012517          	auipc	a0,0x12
    80001a3e:	13650513          	addi	a0,a0,310 # 80013b70 <wait_lock>
    80001a42:	95cff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a46:	00012497          	auipc	s1,0x12
    80001a4a:	54248493          	addi	s1,s1,1346 # 80013f88 <proc>
      initlock(&p->lock, "proc");
    80001a4e:	00006b17          	auipc	s6,0x6
    80001a52:	752b0b13          	addi	s6,s6,1874 # 800081a0 <etext+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    80001a56:	8aa6                	mv	s5,s1
    80001a58:	ff4df937          	lui	s2,0xff4df
    80001a5c:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a55>
    80001a60:	0936                	slli	s2,s2,0xd
    80001a62:	6f590913          	addi	s2,s2,1781
    80001a66:	0936                	slli	s2,s2,0xd
    80001a68:	bd390913          	addi	s2,s2,-1069
    80001a6c:	0932                	slli	s2,s2,0xc
    80001a6e:	7a790913          	addi	s2,s2,1959
    80001a72:	040009b7          	lui	s3,0x4000
    80001a76:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a78:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a7a:	00018a17          	auipc	s4,0x18
    80001a7e:	10ea0a13          	addi	s4,s4,270 # 80019b88 <tickslock>
      initlock(&p->lock, "proc");
    80001a82:	85da                	mv	a1,s6
    80001a84:	8526                	mv	a0,s1
    80001a86:	918ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    80001a8a:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a8e:	415487b3          	sub	a5,s1,s5
    80001a92:	8791                	srai	a5,a5,0x4
    80001a94:	032787b3          	mul	a5,a5,s2
    80001a98:	07b6                	slli	a5,a5,0xd
    80001a9a:	6709                	lui	a4,0x2
    80001a9c:	9fb9                	addw	a5,a5,a4
    80001a9e:	40f987b3          	sub	a5,s3,a5
    80001aa2:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa4:	17048493          	addi	s1,s1,368
    80001aa8:	fd449de3          	bne	s1,s4,80001a82 <procinit+0x78>
}
    80001aac:	70e2                	ld	ra,56(sp)
    80001aae:	7442                	ld	s0,48(sp)
    80001ab0:	74a2                	ld	s1,40(sp)
    80001ab2:	7902                	ld	s2,32(sp)
    80001ab4:	69e2                	ld	s3,24(sp)
    80001ab6:	6a42                	ld	s4,16(sp)
    80001ab8:	6aa2                	ld	s5,8(sp)
    80001aba:	6b02                	ld	s6,0(sp)
    80001abc:	6121                	addi	sp,sp,64
    80001abe:	8082                	ret

0000000080001ac0 <cpuid>:
{
    80001ac0:	1141                	addi	sp,sp,-16
    80001ac2:	e406                	sd	ra,8(sp)
    80001ac4:	e022                	sd	s0,0(sp)
    80001ac6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ac8:	8512                	mv	a0,tp
}
    80001aca:	2501                	sext.w	a0,a0
    80001acc:	60a2                	ld	ra,8(sp)
    80001ace:	6402                	ld	s0,0(sp)
    80001ad0:	0141                	addi	sp,sp,16
    80001ad2:	8082                	ret

0000000080001ad4 <mycpu>:
{
    80001ad4:	1141                	addi	sp,sp,-16
    80001ad6:	e406                	sd	ra,8(sp)
    80001ad8:	e022                	sd	s0,0(sp)
    80001ada:	0800                	addi	s0,sp,16
    80001adc:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001ade:	2781                	sext.w	a5,a5
    80001ae0:	079e                	slli	a5,a5,0x7
}
    80001ae2:	00012517          	auipc	a0,0x12
    80001ae6:	0a650513          	addi	a0,a0,166 # 80013b88 <cpus>
    80001aea:	953e                	add	a0,a0,a5
    80001aec:	60a2                	ld	ra,8(sp)
    80001aee:	6402                	ld	s0,0(sp)
    80001af0:	0141                	addi	sp,sp,16
    80001af2:	8082                	ret

0000000080001af4 <myproc>:
{
    80001af4:	1101                	addi	sp,sp,-32
    80001af6:	ec06                	sd	ra,24(sp)
    80001af8:	e822                	sd	s0,16(sp)
    80001afa:	e426                	sd	s1,8(sp)
    80001afc:	1000                	addi	s0,sp,32
  push_off();
    80001afe:	8e6ff0ef          	jal	80000be4 <push_off>
    80001b02:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b04:	2781                	sext.w	a5,a5
    80001b06:	079e                	slli	a5,a5,0x7
    80001b08:	00012717          	auipc	a4,0x12
    80001b0c:	ed070713          	addi	a4,a4,-304 # 800139d8 <tm>
    80001b10:	97ba                	add	a5,a5,a4
    80001b12:	1b07b783          	ld	a5,432(a5) # 21b0 <_entry-0x7fffde50>
    80001b16:	84be                	mv	s1,a5
  pop_off();
    80001b18:	954ff0ef          	jal	80000c6c <pop_off>
}
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret

0000000080001b28 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b28:	7179                	addi	sp,sp,-48
    80001b2a:	f406                	sd	ra,40(sp)
    80001b2c:	f022                	sd	s0,32(sp)
    80001b2e:	ec26                	sd	s1,24(sp)
    80001b30:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b32:	fc3ff0ef          	jal	80001af4 <myproc>
    80001b36:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b38:	984ff0ef          	jal	80000cbc <release>

  if (first) {
    80001b3c:	0000a797          	auipc	a5,0xa
    80001b40:	d247a783          	lw	a5,-732(a5) # 8000b860 <first.2>
    80001b44:	cf95                	beqz	a5,80001b80 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b46:	4505                	li	a0,1
    80001b48:	452020ef          	jal	80003f9a <fsinit>

    first = 0;
    80001b4c:	0000a797          	auipc	a5,0xa
    80001b50:	d007aa23          	sw	zero,-748(a5) # 8000b860 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b54:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b58:	00006797          	auipc	a5,0x6
    80001b5c:	65078793          	addi	a5,a5,1616 # 800081a8 <etext+0x1a8>
    80001b60:	fcf43823          	sd	a5,-48(s0)
    80001b64:	fc043c23          	sd	zero,-40(s0)
    80001b68:	fd040593          	addi	a1,s0,-48
    80001b6c:	853e                	mv	a0,a5
    80001b6e:	5f6030ef          	jal	80005164 <kexec>
    80001b72:	70bc                	ld	a5,96(s1)
    80001b74:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b76:	70bc                	ld	a5,96(s1)
    80001b78:	7bb8                	ld	a4,112(a5)
    80001b7a:	57fd                	li	a5,-1
    80001b7c:	02f70d63          	beq	a4,a5,80001bb6 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b80:	340010ef          	jal	80002ec0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b84:	6ca8                	ld	a0,88(s1)
    80001b86:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b88:	04000737          	lui	a4,0x4000
    80001b8c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	0732                	slli	a4,a4,0xc
    80001b90:	00005797          	auipc	a5,0x5
    80001b94:	50c78793          	addi	a5,a5,1292 # 8000709c <userret>
    80001b98:	00005697          	auipc	a3,0x5
    80001b9c:	46868693          	addi	a3,a3,1128 # 80007000 <_trampoline>
    80001ba0:	8f95                	sub	a5,a5,a3
    80001ba2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ba4:	577d                	li	a4,-1
    80001ba6:	177e                	slli	a4,a4,0x3f
    80001ba8:	8d59                	or	a0,a0,a4
    80001baa:	9782                	jalr	a5
}
    80001bac:	70a2                	ld	ra,40(sp)
    80001bae:	7402                	ld	s0,32(sp)
    80001bb0:	64e2                	ld	s1,24(sp)
    80001bb2:	6145                	addi	sp,sp,48
    80001bb4:	8082                	ret
      panic("exec");
    80001bb6:	00006517          	auipc	a0,0x6
    80001bba:	5fa50513          	addi	a0,a0,1530 # 800081b0 <etext+0x1b0>
    80001bbe:	c67fe0ef          	jal	80000824 <panic>

0000000080001bc2 <allocpid>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bcc:	00012517          	auipc	a0,0x12
    80001bd0:	f8c50513          	addi	a0,a0,-116 # 80013b58 <pid_lock>
    80001bd4:	854ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001bd8:	0000a797          	auipc	a5,0xa
    80001bdc:	c9478793          	addi	a5,a5,-876 # 8000b86c <nextpid>
    80001be0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001be2:	0014871b          	addiw	a4,s1,1
    80001be6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001be8:	00012517          	auipc	a0,0x12
    80001bec:	f7050513          	addi	a0,a0,-144 # 80013b58 <pid_lock>
    80001bf0:	8ccff0ef          	jal	80000cbc <release>
}
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6105                	addi	sp,sp,32
    80001bfe:	8082                	ret

0000000080001c00 <proc_pagetable>:
{
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	e04a                	sd	s2,0(sp)
    80001c0a:	1000                	addi	s0,sp,32
    80001c0c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c0e:	dfaff0ef          	jal	80001208 <uvmcreate>
    80001c12:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c14:	cd05                	beqz	a0,80001c4c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c16:	4729                	li	a4,10
    80001c18:	00005697          	auipc	a3,0x5
    80001c1c:	3e868693          	addi	a3,a3,1000 # 80007000 <_trampoline>
    80001c20:	6605                	lui	a2,0x1
    80001c22:	040005b7          	lui	a1,0x4000
    80001c26:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c28:	05b2                	slli	a1,a1,0xc
    80001c2a:	c36ff0ef          	jal	80001060 <mappages>
    80001c2e:	02054663          	bltz	a0,80001c5a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c32:	4719                	li	a4,6
    80001c34:	06093683          	ld	a3,96(s2)
    80001c38:	6605                	lui	a2,0x1
    80001c3a:	020005b7          	lui	a1,0x2000
    80001c3e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c40:	05b6                	slli	a1,a1,0xd
    80001c42:	8526                	mv	a0,s1
    80001c44:	c1cff0ef          	jal	80001060 <mappages>
    80001c48:	00054f63          	bltz	a0,80001c66 <proc_pagetable+0x66>
}
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	60e2                	ld	ra,24(sp)
    80001c50:	6442                	ld	s0,16(sp)
    80001c52:	64a2                	ld	s1,8(sp)
    80001c54:	6902                	ld	s2,0(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret
    uvmfree(pagetable, 0);
    80001c5a:	4581                	li	a1,0
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fa4ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c62:	4481                	li	s1,0
    80001c64:	b7e5                	j	80001c4c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c66:	4681                	li	a3,0
    80001c68:	4605                	li	a2,1
    80001c6a:	040005b7          	lui	a1,0x4000
    80001c6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c70:	05b2                	slli	a1,a1,0xc
    80001c72:	8526                	mv	a0,s1
    80001c74:	dbaff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001c78:	4581                	li	a1,0
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	f86ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c80:	4481                	li	s1,0
    80001c82:	b7e9                	j	80001c4c <proc_pagetable+0x4c>

0000000080001c84 <proc_freepagetable>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	e04a                	sd	s2,0(sp)
    80001c8e:	1000                	addi	s0,sp,32
    80001c90:	84aa                	mv	s1,a0
    80001c92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c94:	4681                	li	a3,0
    80001c96:	4605                	li	a2,1
    80001c98:	040005b7          	lui	a1,0x4000
    80001c9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c9e:	05b2                	slli	a1,a1,0xc
    80001ca0:	d8eff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ca4:	4681                	li	a3,0
    80001ca6:	4605                	li	a2,1
    80001ca8:	020005b7          	lui	a1,0x2000
    80001cac:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cae:	05b6                	slli	a1,a1,0xd
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	d7cff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001cb6:	85ca                	mv	a1,s2
    80001cb8:	8526                	mv	a0,s1
    80001cba:	f48ff0ef          	jal	80001402 <uvmfree>
}
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret

0000000080001cca <freeproc>:
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	1000                	addi	s0,sp,32
    80001cd4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cd6:	7128                	ld	a0,96(a0)
    80001cd8:	c119                	beqz	a0,80001cde <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001cda:	d83fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001cde:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ce2:	6ca8                	ld	a0,88(s1)
    80001ce4:	c501                	beqz	a0,80001cec <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce6:	68ac                	ld	a1,80(s1)
    80001ce8:	f9dff0ef          	jal	80001c84 <proc_freepagetable>
  p->pagetable = 0;
    80001cec:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cf0:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cf4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cf8:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001cfc:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001d00:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d04:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d08:	0204a623          	sw	zero,44(s1)
  p->heat = 0;
    80001d0c:	0204ac23          	sw	zero,56(s1)
  p->state = UNUSED;
    80001d10:	0004ac23          	sw	zero,24(s1)
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret

0000000080001d1e <allocproc>:
{
    80001d1e:	1101                	addi	sp,sp,-32
    80001d20:	ec06                	sd	ra,24(sp)
    80001d22:	e822                	sd	s0,16(sp)
    80001d24:	e426                	sd	s1,8(sp)
    80001d26:	e04a                	sd	s2,0(sp)
    80001d28:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d2a:	00012497          	auipc	s1,0x12
    80001d2e:	25e48493          	addi	s1,s1,606 # 80013f88 <proc>
    80001d32:	00018917          	auipc	s2,0x18
    80001d36:	e5690913          	addi	s2,s2,-426 # 80019b88 <tickslock>
    acquire(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	eedfe0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001d40:	4c9c                	lw	a5,24(s1)
    80001d42:	cb91                	beqz	a5,80001d56 <allocproc+0x38>
      release(&p->lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	f77fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d4a:	17048493          	addi	s1,s1,368
    80001d4e:	ff2496e3          	bne	s1,s2,80001d3a <allocproc+0x1c>
  return 0;
    80001d52:	4481                	li	s1,0
    80001d54:	a0a9                	j	80001d9e <allocproc+0x80>
  p->pid = allocpid();
    80001d56:	e6dff0ef          	jal	80001bc2 <allocpid>
    80001d5a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d5c:	4785                	li	a5,1
    80001d5e:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001d60:	0204aa23          	sw	zero,52(s1)
  p->heat = 0;              // new process starts cool
    80001d64:	0204ac23          	sw	zero,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d68:	dddfe0ef          	jal	80000b44 <kalloc>
    80001d6c:	892a                	mv	s2,a0
    80001d6e:	f0a8                	sd	a0,96(s1)
    80001d70:	cd15                	beqz	a0,80001dac <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001d72:	8526                	mv	a0,s1
    80001d74:	e8dff0ef          	jal	80001c00 <proc_pagetable>
    80001d78:	892a                	mv	s2,a0
    80001d7a:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001d7c:	c121                	beqz	a0,80001dbc <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001d7e:	07000613          	li	a2,112
    80001d82:	4581                	li	a1,0
    80001d84:	06848513          	addi	a0,s1,104
    80001d88:	f71fe0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001d8c:	00000797          	auipc	a5,0x0
    80001d90:	d9c78793          	addi	a5,a5,-612 # 80001b28 <forkret>
    80001d94:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d96:	64bc                	ld	a5,72(s1)
    80001d98:	6705                	lui	a4,0x1
    80001d9a:	97ba                	add	a5,a5,a4
    80001d9c:	f8bc                	sd	a5,112(s1)
}
    80001d9e:	8526                	mv	a0,s1
    80001da0:	60e2                	ld	ra,24(sp)
    80001da2:	6442                	ld	s0,16(sp)
    80001da4:	64a2                	ld	s1,8(sp)
    80001da6:	6902                	ld	s2,0(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret
    freeproc(p);
    80001dac:	8526                	mv	a0,s1
    80001dae:	f1dff0ef          	jal	80001cca <freeproc>
    release(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	f09fe0ef          	jal	80000cbc <release>
    return 0;
    80001db8:	84ca                	mv	s1,s2
    80001dba:	b7d5                	j	80001d9e <allocproc+0x80>
    freeproc(p);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	f0dff0ef          	jal	80001cca <freeproc>
    release(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	ef9fe0ef          	jal	80000cbc <release>
    return 0;
    80001dc8:	84ca                	mv	s1,s2
    80001dca:	bfd1                	j	80001d9e <allocproc+0x80>

0000000080001dcc <userinit>:
{
    80001dcc:	1101                	addi	sp,sp,-32
    80001dce:	ec06                	sd	ra,24(sp)
    80001dd0:	e822                	sd	s0,16(sp)
    80001dd2:	e426                	sd	s1,8(sp)
    80001dd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dd6:	f49ff0ef          	jal	80001d1e <allocproc>
    80001dda:	84aa                	mv	s1,a0
  initproc = p;
    80001ddc:	0000a797          	auipc	a5,0xa
    80001de0:	aea7ba23          	sd	a0,-1292(a5) # 8000b8d0 <initproc>
  p->cwd = namei("/");
    80001de4:	00006517          	auipc	a0,0x6
    80001de8:	3d450513          	addi	a0,a0,980 # 800081b8 <etext+0x1b8>
    80001dec:	6e8020ef          	jal	800044d4 <namei>
    80001df0:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001df4:	478d                	li	a5,3
    80001df6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001df8:	8526                	mv	a0,s1
    80001dfa:	ec3fe0ef          	jal	80000cbc <release>
}
    80001dfe:	60e2                	ld	ra,24(sp)
    80001e00:	6442                	ld	s0,16(sp)
    80001e02:	64a2                	ld	s1,8(sp)
    80001e04:	6105                	addi	sp,sp,32
    80001e06:	8082                	ret

0000000080001e08 <growproc>:
{
    80001e08:	1101                	addi	sp,sp,-32
    80001e0a:	ec06                	sd	ra,24(sp)
    80001e0c:	e822                	sd	s0,16(sp)
    80001e0e:	e426                	sd	s1,8(sp)
    80001e10:	e04a                	sd	s2,0(sp)
    80001e12:	1000                	addi	s0,sp,32
    80001e14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e16:	cdfff0ef          	jal	80001af4 <myproc>
    80001e1a:	892a                	mv	s2,a0
  sz = p->sz;
    80001e1c:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001e1e:	02905963          	blez	s1,80001e50 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001e22:	00b48633          	add	a2,s1,a1
    80001e26:	020007b7          	lui	a5,0x2000
    80001e2a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001e2c:	07b6                	slli	a5,a5,0xd
    80001e2e:	02c7ea63          	bltu	a5,a2,80001e62 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e32:	4691                	li	a3,4
    80001e34:	6d28                	ld	a0,88(a0)
    80001e36:	cc6ff0ef          	jal	800012fc <uvmalloc>
    80001e3a:	85aa                	mv	a1,a0
    80001e3c:	c50d                	beqz	a0,80001e66 <growproc+0x5e>
  p->sz = sz;
    80001e3e:	04b93823          	sd	a1,80(s2)
  return 0;
    80001e42:	4501                	li	a0,0
}
    80001e44:	60e2                	ld	ra,24(sp)
    80001e46:	6442                	ld	s0,16(sp)
    80001e48:	64a2                	ld	s1,8(sp)
    80001e4a:	6902                	ld	s2,0(sp)
    80001e4c:	6105                	addi	sp,sp,32
    80001e4e:	8082                	ret
  } else if(n < 0){
    80001e50:	fe04d7e3          	bgez	s1,80001e3e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e54:	00b48633          	add	a2,s1,a1
    80001e58:	6d28                	ld	a0,88(a0)
    80001e5a:	c5eff0ef          	jal	800012b8 <uvmdealloc>
    80001e5e:	85aa                	mv	a1,a0
    80001e60:	bff9                	j	80001e3e <growproc+0x36>
      return -1;
    80001e62:	557d                	li	a0,-1
    80001e64:	b7c5                	j	80001e44 <growproc+0x3c>
      return -1;
    80001e66:	557d                	li	a0,-1
    80001e68:	bff1                	j	80001e44 <growproc+0x3c>

0000000080001e6a <kfork>:
{
    80001e6a:	7139                	addi	sp,sp,-64
    80001e6c:	fc06                	sd	ra,56(sp)
    80001e6e:	f822                	sd	s0,48(sp)
    80001e70:	f426                	sd	s1,40(sp)
    80001e72:	e456                	sd	s5,8(sp)
    80001e74:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e76:	c7fff0ef          	jal	80001af4 <myproc>
    80001e7a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e7c:	ea3ff0ef          	jal	80001d1e <allocproc>
    80001e80:	0e050a63          	beqz	a0,80001f74 <kfork+0x10a>
    80001e84:	e852                	sd	s4,16(sp)
    80001e86:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e88:	050ab603          	ld	a2,80(s5)
    80001e8c:	6d2c                	ld	a1,88(a0)
    80001e8e:	058ab503          	ld	a0,88(s5)
    80001e92:	da2ff0ef          	jal	80001434 <uvmcopy>
    80001e96:	04054863          	bltz	a0,80001ee6 <kfork+0x7c>
    80001e9a:	f04a                	sd	s2,32(sp)
    80001e9c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e9e:	050ab783          	ld	a5,80(s5)
    80001ea2:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ea6:	060ab683          	ld	a3,96(s5)
    80001eaa:	87b6                	mv	a5,a3
    80001eac:	060a3703          	ld	a4,96(s4)
    80001eb0:	12068693          	addi	a3,a3,288
    80001eb4:	6388                	ld	a0,0(a5)
    80001eb6:	678c                	ld	a1,8(a5)
    80001eb8:	6b90                	ld	a2,16(a5)
    80001eba:	e308                	sd	a0,0(a4)
    80001ebc:	e70c                	sd	a1,8(a4)
    80001ebe:	eb10                	sd	a2,16(a4)
    80001ec0:	6f90                	ld	a2,24(a5)
    80001ec2:	ef10                	sd	a2,24(a4)
    80001ec4:	02078793          	addi	a5,a5,32
    80001ec8:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001ecc:	fed794e3          	bne	a5,a3,80001eb4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ed0:	060a3783          	ld	a5,96(s4)
    80001ed4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ed8:	0d8a8493          	addi	s1,s5,216
    80001edc:	0d8a0913          	addi	s2,s4,216
    80001ee0:	158a8993          	addi	s3,s5,344
    80001ee4:	a831                	j	80001f00 <kfork+0x96>
    freeproc(np);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	de3ff0ef          	jal	80001cca <freeproc>
    release(&np->lock);
    80001eec:	8552                	mv	a0,s4
    80001eee:	dcffe0ef          	jal	80000cbc <release>
    return -1;
    80001ef2:	54fd                	li	s1,-1
    80001ef4:	6a42                	ld	s4,16(sp)
    80001ef6:	a885                	j	80001f66 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ef8:	04a1                	addi	s1,s1,8
    80001efa:	0921                	addi	s2,s2,8
    80001efc:	01348963          	beq	s1,s3,80001f0e <kfork+0xa4>
    if(p->ofile[i])
    80001f00:	6088                	ld	a0,0(s1)
    80001f02:	d97d                	beqz	a0,80001ef8 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f04:	38d020ef          	jal	80004a90 <filedup>
    80001f08:	00a93023          	sd	a0,0(s2)
    80001f0c:	b7f5                	j	80001ef8 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001f0e:	158ab503          	ld	a0,344(s5)
    80001f12:	55f010ef          	jal	80003c70 <idup>
    80001f16:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f1a:	4641                	li	a2,16
    80001f1c:	160a8593          	addi	a1,s5,352
    80001f20:	160a0513          	addi	a0,s4,352
    80001f24:	f29fe0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001f28:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001f2c:	8552                	mv	a0,s4
    80001f2e:	d8ffe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001f32:	00012517          	auipc	a0,0x12
    80001f36:	c3e50513          	addi	a0,a0,-962 # 80013b70 <wait_lock>
    80001f3a:	ceffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f3e:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f42:	00012517          	auipc	a0,0x12
    80001f46:	c2e50513          	addi	a0,a0,-978 # 80013b70 <wait_lock>
    80001f4a:	d73fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001f4e:	8552                	mv	a0,s4
    80001f50:	cd9fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f54:	478d                	li	a5,3
    80001f56:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f5a:	8552                	mv	a0,s4
    80001f5c:	d61fe0ef          	jal	80000cbc <release>
  return pid;
    80001f60:	7902                	ld	s2,32(sp)
    80001f62:	69e2                	ld	s3,24(sp)
    80001f64:	6a42                	ld	s4,16(sp)
}
    80001f66:	8526                	mv	a0,s1
    80001f68:	70e2                	ld	ra,56(sp)
    80001f6a:	7442                	ld	s0,48(sp)
    80001f6c:	74a2                	ld	s1,40(sp)
    80001f6e:	6aa2                	ld	s5,8(sp)
    80001f70:	6121                	addi	sp,sp,64
    80001f72:	8082                	ret
    return -1;
    80001f74:	54fd                	li	s1,-1
    80001f76:	bfc5                	j	80001f66 <kfork+0xfc>

0000000080001f78 <scheduler>:
{
    80001f78:	7119                	addi	sp,sp,-128
    80001f7a:	fc86                	sd	ra,120(sp)
    80001f7c:	f8a2                	sd	s0,112(sp)
    80001f7e:	f4a6                	sd	s1,104(sp)
    80001f80:	f0ca                	sd	s2,96(sp)
    80001f82:	ecce                	sd	s3,88(sp)
    80001f84:	e8d2                	sd	s4,80(sp)
    80001f86:	e4d6                	sd	s5,72(sp)
    80001f88:	e0da                	sd	s6,64(sp)
    80001f8a:	fc5e                	sd	s7,56(sp)
    80001f8c:	f862                	sd	s8,48(sp)
    80001f8e:	f466                	sd	s9,40(sp)
    80001f90:	f06a                	sd	s10,32(sp)
    80001f92:	ec6e                	sd	s11,24(sp)
    80001f94:	0100                	addi	s0,sp,128
    80001f96:	8792                	mv	a5,tp
  int id = r_tp();
    80001f98:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f9a:	00779693          	slli	a3,a5,0x7
    80001f9e:	00012717          	auipc	a4,0x12
    80001fa2:	a3a70713          	addi	a4,a4,-1478 # 800139d8 <tm>
    80001fa6:	9736                	add	a4,a4,a3
    80001fa8:	1a073823          	sd	zero,432(a4)
        swtch(&c->context, &chosen->context);
    80001fac:	00012717          	auipc	a4,0x12
    80001fb0:	be470713          	addi	a4,a4,-1052 # 80013b90 <cpus+0x8>
    80001fb4:	9736                	add	a4,a4,a3
    80001fb6:	f8e43023          	sd	a4,-128(s0)
      for(p = proc; p < &proc[NPROC]; p++){
    80001fba:	00018497          	auipc	s1,0x18
    80001fbe:	bce48493          	addi	s1,s1,-1074 # 80019b88 <tickslock>
        summary_printed = 1;   // set BEFORE printing to block other CPUs
    80001fc2:	4905                	li	s2,1
        c->proc = chosen;
    80001fc4:	00012717          	auipc	a4,0x12
    80001fc8:	a1470713          	addi	a4,a4,-1516 # 800139d8 <tm>
    80001fcc:	00d707b3          	add	a5,a4,a3
    80001fd0:	f8f43423          	sd	a5,-120(s0)
    80001fd4:	a609                	j	800022d6 <scheduler+0x35e>
      for(p = proc; p < &proc[NPROC]; p++){
    80001fd6:	00012997          	auipc	s3,0x12
    80001fda:	fb298993          	addi	s3,s3,-78 # 80013f88 <proc>
    80001fde:	a801                	j	80001fee <scheduler+0x76>
        release(&p->lock);
    80001fe0:	854e                	mv	a0,s3
    80001fe2:	cdbfe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80001fe6:	17098993          	addi	s3,s3,368
    80001fea:	02998663          	beq	s3,s1,80002016 <scheduler+0x9e>
        acquire(&p->lock);
    80001fee:	854e                	mv	a0,s3
    80001ff0:	c39fe0ef          	jal	80000c28 <acquire>
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80001ff4:	0189a783          	lw	a5,24(s3)
    80001ff8:	d7e5                	beqz	a5,80001fe0 <scheduler+0x68>
    80001ffa:	17ed                	addi	a5,a5,-5
    80001ffc:	d3f5                	beqz	a5,80001fe0 <scheduler+0x68>
           p->parent != 0 &&
    80001ffe:	0409b503          	ld	a0,64(s3)
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80002002:	dd79                	beqz	a0,80001fe0 <scheduler+0x68>
           is_thermal_test(p->parent->name)){
    80002004:	16050513          	addi	a0,a0,352
    80002008:	8a3ff0ef          	jal	800018aa <is_thermal_test>
           p->parent != 0 &&
    8000200c:	d971                	beqz	a0,80001fe0 <scheduler+0x68>
          release(&p->lock);
    8000200e:	854e                	mv	a0,s3
    80002010:	cadfe0ef          	jal	80000cbc <release>
      if(!still_active){
    80002014:	acf5                	j	80002310 <scheduler+0x398>
        summary_printed = 1;   // set BEFORE printing to block other CPUs
    80002016:	0000a797          	auipc	a5,0xa
    8000201a:	8927ad23          	sw	s2,-1894(a5) # 8000b8b0 <summary_printed.3>
  printf("\n");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	05a50513          	addi	a0,a0,90 # 80008078 <etext+0x78>
    80002026:	cd4fe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    8000202a:	00006517          	auipc	a0,0x6
    8000202e:	1ae50513          	addi	a0,a0,430 # 800081d8 <etext+0x1d8>
    80002032:	cc8fe0ef          	jal	800004fa <printf>
  printf("  ===          THERMAL SCHEDULING SUMMARY                  ===\n");
    80002036:	00006517          	auipc	a0,0x6
    8000203a:	1e250513          	addi	a0,a0,482 # 80008218 <etext+0x218>
    8000203e:	cbcfe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    80002042:	00006517          	auipc	a0,0x6
    80002046:	19650513          	addi	a0,a0,406 # 800081d8 <etext+0x1d8>
    8000204a:	cb0fe0ef          	jal	800004fa <printf>
  printf("\n");
    8000204e:	00006517          	auipc	a0,0x6
    80002052:	02a50513          	addi	a0,a0,42 # 80008078 <etext+0x78>
    80002056:	ca4fe0ef          	jal	800004fa <printf>
  int avg_temp = tm_temp_count > 0 ? tm_temp_sum / tm_temp_count : 0;
    8000205a:	0000a797          	auipc	a5,0xa
    8000205e:	86a7a783          	lw	a5,-1942(a5) # 8000b8c4 <tm_temp_count>
    80002062:	89ee                	mv	s3,s11
    80002064:	00f05863          	blez	a5,80002074 <scheduler+0xfc>
    80002068:	0000a997          	auipc	s3,0xa
    8000206c:	8609a983          	lw	s3,-1952(s3) # 8000b8c8 <tm_temp_sum>
    80002070:	02f9c9bb          	divw	s3,s3,a5
  printf("  CPU Temperature\n");
    80002074:	00006517          	auipc	a0,0x6
    80002078:	1e450513          	addi	a0,a0,484 # 80008258 <etext+0x258>
    8000207c:	c7efe0ef          	jal	800004fa <printf>
  printf("  -----------------------------------------------------------\n");
    80002080:	00006517          	auipc	a0,0x6
    80002084:	1f050513          	addi	a0,a0,496 # 80008270 <etext+0x270>
    80002088:	c72fe0ef          	jal	800004fa <printf>
  printf("    Average : %d    Min : %d    Max : %d\n", avg_temp, tm_temp_min, tm_temp_max);
    8000208c:	0000a697          	auipc	a3,0xa
    80002090:	8346a683          	lw	a3,-1996(a3) # 8000b8c0 <tm_temp_max>
    80002094:	00009617          	auipc	a2,0x9
    80002098:	7d062603          	lw	a2,2000(a2) # 8000b864 <tm_temp_min>
    8000209c:	85ce                	mv	a1,s3
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	21250513          	addi	a0,a0,530 # 800082b0 <etext+0x2b0>
    800020a6:	c54fe0ef          	jal	800004fa <printf>
  printf("    Cooling cycles (throttled) : %d\n", tm_cooling_cycles);
    800020aa:	0000a597          	auipc	a1,0xa
    800020ae:	8125a583          	lw	a1,-2030(a1) # 8000b8bc <tm_cooling_cycles>
    800020b2:	00006517          	auipc	a0,0x6
    800020b6:	22e50513          	addi	a0,a0,558 # 800082e0 <etext+0x2e0>
    800020ba:	c40fe0ef          	jal	800004fa <printf>
  printf("    Total schedule events      : %d\n", tm_temp_count);
    800020be:	0000a597          	auipc	a1,0xa
    800020c2:	8065a583          	lw	a1,-2042(a1) # 8000b8c4 <tm_temp_count>
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	24250513          	addi	a0,a0,578 # 80008308 <etext+0x308>
    800020ce:	c2cfe0ef          	jal	800004fa <printf>
  printf("\n");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	fa650513          	addi	a0,a0,-90 # 80008078 <etext+0x78>
    800020da:	c20fe0ef          	jal	800004fa <printf>
  printf("  Per-Process Heat Metrics\n");
    800020de:	00006517          	auipc	a0,0x6
    800020e2:	25250513          	addi	a0,a0,594 # 80008330 <etext+0x330>
    800020e6:	c14fe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    800020ea:	00006517          	auipc	a0,0x6
    800020ee:	26650513          	addi	a0,a0,614 # 80008350 <etext+0x350>
    800020f2:	c08fe0ef          	jal	800004fa <printf>
  printf("  PID  | Scheduled | Skipped | Avg Heat | Min Heat | Max Heat\n");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	2a250513          	addi	a0,a0,674 # 80008398 <etext+0x398>
    800020fe:	bfcfe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    80002102:	00006517          	auipc	a0,0x6
    80002106:	24e50513          	addi	a0,a0,590 # 80008350 <etext+0x350>
    8000210a:	bf0fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    8000210e:	00012997          	auipc	s3,0x12
    80002112:	8ca98993          	addi	s3,s3,-1846 # 800139d8 <tm>
    80002116:	00012d17          	auipc	s10,0x12
    8000211a:	a42d0d13          	addi	s10,s10,-1470 # 80013b58 <pid_lock>
  printf("  ---------------------------------------------------------------\n");
    8000211e:	8a4e                	mv	s4,s3
    printf(" |");
    80002120:	00006b97          	auipc	s7,0x6
    80002124:	2c8b8b93          	addi	s7,s7,712 # 800083e8 <etext+0x3e8>
    80002128:	a059                	j	800021ae <scheduler+0x236>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    8000212a:	014aa783          	lw	a5,20(s5)
    8000212e:	8b3e                	mv	s6,a5
    80002130:	0a07c463          	bltz	a5,800021d8 <scheduler+0x260>
    80002134:	2b01                	sext.w	s6,s6
    printf("  ");
    80002136:	00006517          	auipc	a0,0x6
    8000213a:	2a250513          	addi	a0,a0,674 # 800083d8 <etext+0x3d8>
    8000213e:	bbcfe0ef          	jal	800004fa <printf>
    printpad(tm[i].pid, 4);
    80002142:	4591                	li	a1,4
    80002144:	000aa503          	lw	a0,0(s5)
    80002148:	eeaff0ef          	jal	80001832 <printpad>
    printf("  |");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	29450513          	addi	a0,a0,660 # 800083e0 <etext+0x3e0>
    80002154:	ba6fe0ef          	jal	800004fa <printf>
    printpad(tm[i].sched_count, 10);
    80002158:	45a9                	li	a1,10
    8000215a:	004aa503          	lw	a0,4(s5)
    8000215e:	ed4ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002162:	855e                	mv	a0,s7
    80002164:	b96fe0ef          	jal	800004fa <printf>
    printpad(tm[i].skip_count, 8);
    80002168:	45a1                	li	a1,8
    8000216a:	008aa503          	lw	a0,8(s5)
    8000216e:	ec4ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002172:	855e                	mv	a0,s7
    80002174:	b86fe0ef          	jal	800004fa <printf>
    printpad(avg_heat, 9);
    80002178:	45a5                	li	a1,9
    8000217a:	8562                	mv	a0,s8
    8000217c:	eb6ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002180:	855e                	mv	a0,s7
    80002182:	b78fe0ef          	jal	800004fa <printf>
    printpad(mn, 9);
    80002186:	45a5                	li	a1,9
    80002188:	8566                	mv	a0,s9
    8000218a:	ea8ff0ef          	jal	80001832 <printpad>
    printf(" |");
    8000218e:	855e                	mv	a0,s7
    80002190:	b6afe0ef          	jal	800004fa <printf>
    printpad(mx, 9);
    80002194:	45a5                	li	a1,9
    80002196:	855a                	mv	a0,s6
    80002198:	e9aff0ef          	jal	80001832 <printpad>
    printf("\n");
    8000219c:	00006517          	auipc	a0,0x6
    800021a0:	edc50513          	addi	a0,a0,-292 # 80008078 <etext+0x78>
    800021a4:	b56fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800021a8:	0a61                	addi	s4,s4,24
    800021aa:	03aa0963          	beq	s4,s10,800021dc <scheduler+0x264>
    if(tm[i].pid == 0) continue;
    800021ae:	8ad2                	mv	s5,s4
    800021b0:	000a2783          	lw	a5,0(s4)
    800021b4:	dbf5                	beqz	a5,800021a8 <scheduler+0x230>
    int avg_heat = tm[i].sched_count > 0
    800021b6:	004a2783          	lw	a5,4(s4)
    800021ba:	8c6e                	mv	s8,s11
                   ? tm[i].heat_sum / tm[i].sched_count : 0;
    800021bc:	00f05663          	blez	a5,800021c8 <scheduler+0x250>
    int avg_heat = tm[i].sched_count > 0
    800021c0:	00ca2c03          	lw	s8,12(s4)
    800021c4:	02fc4c3b          	divw	s8,s8,a5
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    800021c8:	010aac83          	lw	s9,16(s5)
    800021cc:	06400793          	li	a5,100
    800021d0:	f597dde3          	bge	a5,s9,8000212a <scheduler+0x1b2>
    800021d4:	8cee                	mv	s9,s11
    800021d6:	bf91                	j	8000212a <scheduler+0x1b2>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    800021d8:	4b01                	li	s6,0
    800021da:	bfa9                	j	80002134 <scheduler+0x1bc>
  printf("  ---------------------------------------------------------------\n");
    800021dc:	00006517          	auipc	a0,0x6
    800021e0:	17450513          	addi	a0,a0,372 # 80008350 <etext+0x350>
    800021e4:	b16fe0ef          	jal	800004fa <printf>
  printf("\n");
    800021e8:	00006517          	auipc	a0,0x6
    800021ec:	e9050513          	addi	a0,a0,-368 # 80008078 <etext+0x78>
    800021f0:	b0afe0ef          	jal	800004fa <printf>
    tm[i].heat_min = MAX_HEAT + 1;
    800021f4:	06500713          	li	a4,101
    tm[i].heat_max = -1;
    800021f8:	57fd                	li	a5,-1
    tm[i].pid = 0;
    800021fa:	0009a023          	sw	zero,0(s3)
    tm[i].sched_count = 0;
    800021fe:	0009a223          	sw	zero,4(s3)
    tm[i].skip_count = 0;
    80002202:	0009a423          	sw	zero,8(s3)
    tm[i].heat_sum = 0;
    80002206:	0009a623          	sw	zero,12(s3)
    tm[i].heat_min = MAX_HEAT + 1;
    8000220a:	00e9a823          	sw	a4,16(s3)
    tm[i].heat_max = -1;
    8000220e:	00f9aa23          	sw	a5,20(s3)
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    80002212:	09e1                	addi	s3,s3,24
    80002214:	ffa993e3          	bne	s3,s10,800021fa <scheduler+0x282>
  tm_temp_sum = 0;
    80002218:	00009797          	auipc	a5,0x9
    8000221c:	6a07a823          	sw	zero,1712(a5) # 8000b8c8 <tm_temp_sum>
  tm_temp_count = 0;
    80002220:	00009797          	auipc	a5,0x9
    80002224:	6a07a223          	sw	zero,1700(a5) # 8000b8c4 <tm_temp_count>
  tm_temp_min = 100;
    80002228:	06400793          	li	a5,100
    8000222c:	00009717          	auipc	a4,0x9
    80002230:	62f72c23          	sw	a5,1592(a4) # 8000b864 <tm_temp_min>
  tm_temp_max = 0;
    80002234:	00009797          	auipc	a5,0x9
    80002238:	6807a623          	sw	zero,1676(a5) # 8000b8c0 <tm_temp_max>
  tm_cooling_cycles = 0;
    8000223c:	00009797          	auipc	a5,0x9
    80002240:	6807a023          	sw	zero,1664(a5) # 8000b8bc <tm_cooling_cycles>
  tm_had_children = 0;
    80002244:	00009797          	auipc	a5,0x9
    80002248:	6607aa23          	sw	zero,1652(a5) # 8000b8b8 <tm_had_children>
}
    8000224c:	a0d1                	j	80002310 <scheduler+0x398>
          if(p->heat < 0) p->heat = 0;
    8000224e:	0209ac23          	sw	zero,56(s3)
      release(&p->lock);
    80002252:	854e                	mv	a0,s3
    80002254:	a69fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002258:	17098993          	addi	s3,s3,368
    8000225c:	02998463          	beq	s3,s1,80002284 <scheduler+0x30c>
      acquire(&p->lock);
    80002260:	854e                	mv	a0,s3
    80002262:	9c7fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    80002266:	0189a783          	lw	a5,24(s3)
    8000226a:	37f9                	addiw	a5,a5,-2
    8000226c:	fef963e3          	bltu	s2,a5,80002252 <scheduler+0x2da>
        if(p->heat > 0){
    80002270:	0389a783          	lw	a5,56(s3)
    80002274:	fcf05fe3          	blez	a5,80002252 <scheduler+0x2da>
          p->heat -= HEAT_DECAY;
    80002278:	37f9                	addiw	a5,a5,-2
          if(p->heat < 0) p->heat = 0;
    8000227a:	fc07cae3          	bltz	a5,8000224e <scheduler+0x2d6>
          p->heat -= HEAT_DECAY;
    8000227e:	02f9ac23          	sw	a5,56(s3)
    80002282:	bfc1                	j	80002252 <scheduler+0x2da>
    if(cpu_temp >= THROTTLE_TEMP){
    80002284:	00009597          	auipc	a1,0x9
    80002288:	5e45a583          	lw	a1,1508(a1) # 8000b868 <cpu_temp>
    8000228c:	05900793          	li	a5,89
    80002290:	08b7de63          	bge	a5,a1,8000232c <scheduler+0x3b4>
      tm_cooling_cycles++;
    80002294:	00009717          	auipc	a4,0x9
    80002298:	62870713          	addi	a4,a4,1576 # 8000b8bc <tm_cooling_cycles>
    8000229c:	431c                	lw	a5,0(a4)
    8000229e:	2785                	addiw	a5,a5,1
    800022a0:	c31c                	sw	a5,0(a4)
      if(sched_round % THERMAL_LOG_INTERVAL == 0)
    800022a2:	00009717          	auipc	a4,0x9
    800022a6:	61272703          	lw	a4,1554(a4) # 8000b8b4 <sched_round.4>
    800022aa:	666667b7          	lui	a5,0x66666
    800022ae:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    800022b2:	02f707b3          	mul	a5,a4,a5
    800022b6:	9789                	srai	a5,a5,0x22
    800022b8:	41f7569b          	sraiw	a3,a4,0x1f
    800022bc:	9f95                	subw	a5,a5,a3
    800022be:	0027969b          	slliw	a3,a5,0x2
    800022c2:	9fb5                	addw	a5,a5,a3
    800022c4:	0017979b          	slliw	a5,a5,0x1
    800022c8:	9f1d                	subw	a4,a4,a5
    800022ca:	cb21                	beqz	a4,8000231a <scheduler+0x3a2>
      update_cpu_temp(0);  // idle cooling
    800022cc:	4501                	li	a0,0
    800022ce:	e1aff0ef          	jal	800018e8 <update_cpu_temp>
      asm volatile("wfi");
    800022d2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022de:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800022e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022e8:	10079073          	csrw	sstatus,a5
    sched_round++;
    800022ec:	00009717          	auipc	a4,0x9
    800022f0:	5c870713          	addi	a4,a4,1480 # 8000b8b4 <sched_round.4>
    800022f4:	431c                	lw	a5,0(a4)
    800022f6:	2785                	addiw	a5,a5,1
    800022f8:	c31c                	sw	a5,0(a4)
    if(tm_had_children && !summary_printed){
    800022fa:	00009797          	auipc	a5,0x9
    800022fe:	5be7a783          	lw	a5,1470(a5) # 8000b8b8 <tm_had_children>
    80002302:	c799                	beqz	a5,80002310 <scheduler+0x398>
    80002304:	00009d97          	auipc	s11,0x9
    80002308:	5acdad83          	lw	s11,1452(s11) # 8000b8b0 <summary_printed.3>
    8000230c:	cc0d85e3          	beqz	s11,80001fd6 <scheduler+0x5e>
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    80002310:	00012997          	auipc	s3,0x12
    80002314:	c7898993          	addi	s3,s3,-904 # 80013f88 <proc>
    80002318:	b7a1                	j	80002260 <scheduler+0x2e8>
        printf("  [COOLING] Temp: %d/%d  | Throttling -- idle cycle to cool down\n", cpu_temp, THROTTLE_TEMP);
    8000231a:	05a00613          	li	a2,90
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	0d250513          	addi	a0,a0,210 # 800083f0 <etext+0x3f0>
    80002326:	9d4fe0ef          	jal	800004fa <printf>
    8000232a:	b74d                	j	800022cc <scheduler+0x354>
    skipped = 0;
    8000232c:	4a81                	li	s5,0
    chosen = 0;
    8000232e:	4981                	li	s3,0
    for(p = proc; p < &proc[NPROC]; p++){
    80002330:	00012a17          	auipc	s4,0x12
    80002334:	c58a0a13          	addi	s4,s4,-936 # 80013f88 <proc>
      if(p->state == RUNNABLE){
    80002338:	4b0d                	li	s6,3
        if(p->waiting_tick < STARVE_TICKS){
    8000233a:	0c700b93          	li	s7,199
          if(!tm_had_children){
    8000233e:	00009d17          	auipc	s10,0x9
    80002342:	57ad0d13          	addi	s10,s10,1402 # 8000b8b8 <tm_had_children>
            summary_printed = 0;  // reset guard only on 0→1 transition (new run)
    80002346:	00009d97          	auipc	s11,0x9
    8000234a:	56ad8d93          	addi	s11,s11,1386 # 8000b8b0 <summary_printed.3>
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    8000234e:	00009c17          	auipc	s8,0x9
    80002352:	51ac0c13          	addi	s8,s8,1306 # 8000b868 <cpu_temp>
    80002356:	04f00c93          	li	s9,79
    8000235a:	a099                	j	800023a0 <scheduler+0x428>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    8000235c:	03b00713          	li	a4,59
    80002360:	0af74263          	blt	a4,a5,80002404 <scheduler+0x48c>
        if(p->parent != 0 &&
    80002364:	040a3503          	ld	a0,64(s4)
    80002368:	c50d                	beqz	a0,80002392 <scheduler+0x41a>
           is_thermal_test(p->parent->name)){
    8000236a:	16050513          	addi	a0,a0,352
    8000236e:	d3cff0ef          	jal	800018aa <is_thermal_test>
        if(p->parent != 0 &&
    80002372:	c105                	beqz	a0,80002392 <scheduler+0x41a>
          if(!tm_had_children){
    80002374:	000d2783          	lw	a5,0(s10)
    80002378:	e399                	bnez	a5,8000237e <scheduler+0x406>
            summary_printed = 0;  // reset guard only on 0→1 transition (new run)
    8000237a:	000da023          	sw	zero,0(s11)
          tm_had_children = 1;
    8000237e:	012d2023          	sw	s2,0(s10)
          if(chosen == 0 || p->pid < chosen->pid)
    80002382:	0a098763          	beqz	s3,80002430 <scheduler+0x4b8>
    80002386:	030a2703          	lw	a4,48(s4)
    8000238a:	0309a783          	lw	a5,48(s3)
    8000238e:	0af74363          	blt	a4,a5,80002434 <scheduler+0x4bc>
      release(&p->lock);
    80002392:	8552                	mv	a0,s4
    80002394:	929fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002398:	170a0a13          	addi	s4,s4,368
    8000239c:	089a0e63          	beq	s4,s1,80002438 <scheduler+0x4c0>
      acquire(&p->lock);
    800023a0:	8552                	mv	a0,s4
    800023a2:	887fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE){
    800023a6:	018a2783          	lw	a5,24(s4)
    800023aa:	ff6794e3          	bne	a5,s6,80002392 <scheduler+0x41a>
        if(p->waiting_tick < STARVE_TICKS){
    800023ae:	034a2783          	lw	a5,52(s4)
    800023b2:	fafbc9e3          	blt	s7,a5,80002364 <scheduler+0x3ec>
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    800023b6:	000c2783          	lw	a5,0(s8)
    800023ba:	fafcd1e3          	bge	s9,a5,8000235c <scheduler+0x3e4>
    800023be:	038a2703          	lw	a4,56(s4)
    800023c2:	47f5                	li	a5,29
    800023c4:	fae7d0e3          	bge	a5,a4,80002364 <scheduler+0x3ec>
          skipped++;
    800023c8:	2a85                	addiw	s5,s5,1
          tm_record_skip(p->pid);
    800023ca:	030a2503          	lw	a0,48(s4)
    800023ce:	c48ff0ef          	jal	80001816 <tm_record_skip>
          if(sched_round % THERMAL_LOG_INTERVAL == 0)
    800023d2:	00009717          	auipc	a4,0x9
    800023d6:	4e272703          	lw	a4,1250(a4) # 8000b8b4 <sched_round.4>
    800023da:	666667b7          	lui	a5,0x66666
    800023de:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    800023e2:	02f707b3          	mul	a5,a4,a5
    800023e6:	9789                	srai	a5,a5,0x22
    800023e8:	41f7569b          	sraiw	a3,a4,0x1f
    800023ec:	9f95                	subw	a5,a5,a3
    800023ee:	0027969b          	slliw	a3,a5,0x2
    800023f2:	9fb5                	addw	a5,a5,a3
    800023f4:	0017979b          	slliw	a5,a5,0x1
    800023f8:	9f1d                	subw	a4,a4,a5
    800023fa:	cf01                	beqz	a4,80002412 <scheduler+0x49a>
          release(&p->lock);
    800023fc:	8552                	mv	a0,s4
    800023fe:	8bffe0ef          	jal	80000cbc <release>
          continue;
    80002402:	bf59                	j	80002398 <scheduler+0x420>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002404:	038a2703          	lw	a4,56(s4)
    80002408:	03b00793          	li	a5,59
    8000240c:	fae7cee3          	blt	a5,a4,800023c8 <scheduler+0x450>
    80002410:	bf91                	j	80002364 <scheduler+0x3ec>
            printf("  [SKIPPED] PID: %d | Heat: %d | Waited: %d | Temp: %d\n",
    80002412:	000c2703          	lw	a4,0(s8)
    80002416:	034a2683          	lw	a3,52(s4)
    8000241a:	038a2603          	lw	a2,56(s4)
    8000241e:	030a2583          	lw	a1,48(s4)
    80002422:	00006517          	auipc	a0,0x6
    80002426:	01650513          	addi	a0,a0,22 # 80008438 <etext+0x438>
    8000242a:	8d0fe0ef          	jal	800004fa <printf>
    8000242e:	b7f9                	j	800023fc <scheduler+0x484>
            chosen = p;
    80002430:	89d2                	mv	s3,s4
    80002432:	b785                	j	80002392 <scheduler+0x41a>
    80002434:	89d2                	mv	s3,s4
    80002436:	bfb1                	j	80002392 <scheduler+0x41a>
    if(chosen == 0){
    80002438:	00098763          	beqz	s3,80002446 <scheduler+0x4ce>
    for(p = proc; p < &proc[NPROC]; p++){
    8000243c:	00012a17          	auipc	s4,0x12
    80002440:	b4ca0a13          	addi	s4,s4,-1204 # 80013f88 <proc>
    80002444:	a8d1                	j	80002518 <scheduler+0x5a0>
      int lowest_heat = MAX_HEAT + 1;
    80002446:	06500b93          	li	s7,101
      for(p = proc; p < &proc[NPROC]; p++){
    8000244a:	00012a17          	auipc	s4,0x12
    8000244e:	b3ea0a13          	addi	s4,s4,-1218 # 80013f88 <proc>
        if(p->state == RUNNABLE){
    80002452:	4b0d                	li	s6,3
          if(p->waiting_tick < STARVE_TICKS){
    80002454:	0c700c13          	li	s8,199
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002458:	00009d17          	auipc	s10,0x9
    8000245c:	410d0d13          	addi	s10,s10,1040 # 8000b868 <cpu_temp>
    80002460:	04f00c93          	li	s9,79
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002464:	03b00d93          	li	s11,59
    80002468:	a005                	j	80002488 <scheduler+0x510>
    8000246a:	04fdcc63          	blt	s11,a5,800024c2 <scheduler+0x54a>
          if(p->heat < lowest_heat){
    8000246e:	038a2783          	lw	a5,56(s4)
    80002472:	0177d463          	bge	a5,s7,8000247a <scheduler+0x502>
            lowest_heat = p->heat;
    80002476:	8bbe                	mv	s7,a5
            chosen = p;
    80002478:	89d2                	mv	s3,s4
        release(&p->lock);
    8000247a:	8552                	mv	a0,s4
    8000247c:	841fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80002480:	170a0a13          	addi	s4,s4,368
    80002484:	049a0463          	beq	s4,s1,800024cc <scheduler+0x554>
        acquire(&p->lock);
    80002488:	8552                	mv	a0,s4
    8000248a:	f9efe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    8000248e:	018a2783          	lw	a5,24(s4)
    80002492:	ff6794e3          	bne	a5,s6,8000247a <scheduler+0x502>
          if(p->waiting_tick < STARVE_TICKS){
    80002496:	034a2783          	lw	a5,52(s4)
    8000249a:	fcfc4ae3          	blt	s8,a5,8000246e <scheduler+0x4f6>
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    8000249e:	000d2783          	lw	a5,0(s10)
    800024a2:	fcfcd4e3          	bge	s9,a5,8000246a <scheduler+0x4f2>
    800024a6:	038a2783          	lw	a5,56(s4)
    800024aa:	4775                	li	a4,29
    800024ac:	fcf751e3          	bge	a4,a5,8000246e <scheduler+0x4f6>
            skipped++;
    800024b0:	2a85                	addiw	s5,s5,1
            tm_record_skip(p->pid);
    800024b2:	030a2503          	lw	a0,48(s4)
    800024b6:	b60ff0ef          	jal	80001816 <tm_record_skip>
            release(&p->lock);
    800024ba:	8552                	mv	a0,s4
    800024bc:	801fe0ef          	jal	80000cbc <release>
            continue;
    800024c0:	b7c1                	j	80002480 <scheduler+0x508>
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    800024c2:	038a2783          	lw	a5,56(s4)
    800024c6:	fefdc5e3          	blt	s11,a5,800024b0 <scheduler+0x538>
    800024ca:	b755                	j	8000246e <scheduler+0x4f6>
    if(chosen == 0){
    800024cc:	f60998e3          	bnez	s3,8000243c <scheduler+0x4c4>
      for(p = proc; p < &proc[NPROC]; p++){
    800024d0:	00012a17          	auipc	s4,0x12
    800024d4:	ab8a0a13          	addi	s4,s4,-1352 # 80013f88 <proc>
        if(p->state == RUNNABLE){
    800024d8:	4b8d                	li	s7,3
      for(p = proc; p < &proc[NPROC]; p++){
    800024da:	00017b17          	auipc	s6,0x17
    800024de:	6aeb0b13          	addi	s6,s6,1710 # 80019b88 <tickslock>
        acquire(&p->lock);
    800024e2:	8552                	mv	a0,s4
    800024e4:	f44fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    800024e8:	018a2783          	lw	a5,24(s4)
    800024ec:	01778a63          	beq	a5,s7,80002500 <scheduler+0x588>
        release(&p->lock);
    800024f0:	8552                	mv	a0,s4
    800024f2:	fcafe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    800024f6:	170a0a13          	addi	s4,s4,368
    800024fa:	ff6a14e3          	bne	s4,s6,800024e2 <scheduler+0x56a>
    800024fe:	bf3d                	j	8000243c <scheduler+0x4c4>
          release(&p->lock);
    80002500:	8552                	mv	a0,s4
    80002502:	fbafe0ef          	jal	80000cbc <release>
          chosen = p;
    80002506:	89d2                	mv	s3,s4
          break;
    80002508:	bf15                	j	8000243c <scheduler+0x4c4>
      release(&p->lock);
    8000250a:	8552                	mv	a0,s4
    8000250c:	fb0fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002510:	170a0a13          	addi	s4,s4,368
    80002514:	029a0163          	beq	s4,s1,80002536 <scheduler+0x5be>
      acquire(&p->lock);
    80002518:	8552                	mv	a0,s4
    8000251a:	f0efe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen){
    8000251e:	018a2783          	lw	a5,24(s4)
    80002522:	17f5                	addi	a5,a5,-3
    80002524:	f3fd                	bnez	a5,8000250a <scheduler+0x592>
    80002526:	ff4982e3          	beq	s3,s4,8000250a <scheduler+0x592>
        p->waiting_tick++;
    8000252a:	034a2783          	lw	a5,52(s4)
    8000252e:	2785                	addiw	a5,a5,1
    80002530:	02fa2a23          	sw	a5,52(s4)
    80002534:	bfd9                	j	8000250a <scheduler+0x592>
    if(chosen == 0){
    80002536:	00098f63          	beqz	s3,80002554 <scheduler+0x5dc>
      acquire(&chosen->lock);
    8000253a:	8a4e                	mv	s4,s3
    8000253c:	854e                	mv	a0,s3
    8000253e:	eeafe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    80002542:	0189a703          	lw	a4,24(s3)
    80002546:	478d                	li	a5,3
    80002548:	00f70c63          	beq	a4,a5,80002560 <scheduler+0x5e8>
      release(&chosen->lock);
    8000254c:	8552                	mv	a0,s4
    8000254e:	f6efe0ef          	jal	80000cbc <release>
    80002552:	b351                	j	800022d6 <scheduler+0x35e>
      update_cpu_temp(0);  // idle cooling
    80002554:	4501                	li	a0,0
    80002556:	b92ff0ef          	jal	800018e8 <update_cpu_temp>
      asm volatile("wfi");
    8000255a:	10500073          	wfi
    8000255e:	bba5                	j	800022d6 <scheduler+0x35e>
        if(cpu_temp >= HOT_TEMP)       zone = "HOT ";
    80002560:	00009597          	auipc	a1,0x9
    80002564:	3085a583          	lw	a1,776(a1) # 8000b868 <cpu_temp>
    80002568:	04f00793          	li	a5,79
    8000256c:	00006617          	auipc	a2,0x6
    80002570:	c5460613          	addi	a2,a2,-940 # 800081c0 <etext+0x1c0>
    80002574:	00b7ce63          	blt	a5,a1,80002590 <scheduler+0x618>
        else if(cpu_temp >= WARM_TEMP) zone = "WARM";
    80002578:	03b00793          	li	a5,59
    8000257c:	00006617          	auipc	a2,0x6
    80002580:	c5460613          	addi	a2,a2,-940 # 800081d0 <etext+0x1d0>
    80002584:	00b7c663          	blt	a5,a1,80002590 <scheduler+0x618>
        char *zone = "COOL";
    80002588:	00006617          	auipc	a2,0x6
    8000258c:	c4060613          	addi	a2,a2,-960 # 800081c8 <etext+0x1c8>
        if(sched_round % THERMAL_LOG_INTERVAL == 0){
    80002590:	00009717          	auipc	a4,0x9
    80002594:	32472703          	lw	a4,804(a4) # 8000b8b4 <sched_round.4>
    80002598:	666667b7          	lui	a5,0x66666
    8000259c:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    800025a0:	02f707b3          	mul	a5,a4,a5
    800025a4:	9789                	srai	a5,a5,0x22
    800025a6:	41f7569b          	sraiw	a3,a4,0x1f
    800025aa:	9f95                	subw	a5,a5,a3
    800025ac:	0027969b          	slliw	a3,a5,0x2
    800025b0:	9fb5                	addw	a5,a5,a3
    800025b2:	0017979b          	slliw	a5,a5,0x1
    800025b6:	9f1d                	subw	a4,a4,a5
    800025b8:	c379                	beqz	a4,8000267e <scheduler+0x706>
        chosen->state = RUNNING;
    800025ba:	4791                	li	a5,4
    800025bc:	00f9ac23          	sw	a5,24(s3)
        c->proc = chosen;
    800025c0:	f8843783          	ld	a5,-120(s0)
    800025c4:	1b37b823          	sd	s3,432(a5)
        tm_record_schedule(chosen->pid, chosen->heat);
    800025c8:	0389aa83          	lw	s5,56(s3)
  struct thermal_metrics *m = tm_find(pid);
    800025cc:	0309a503          	lw	a0,48(s3)
    800025d0:	9d0ff0ef          	jal	800017a0 <tm_find>
    800025d4:	87aa                	mv	a5,a0
  if(!m) return;
    800025d6:	c925                	beqz	a0,80002646 <scheduler+0x6ce>
  m->sched_count++;
    800025d8:	4158                	lw	a4,4(a0)
    800025da:	2705                	addiw	a4,a4,1
    800025dc:	c158                	sw	a4,4(a0)
  m->heat_sum += heat;
    800025de:	4558                	lw	a4,12(a0)
    800025e0:	0157073b          	addw	a4,a4,s5
    800025e4:	c558                	sw	a4,12(a0)
  if(heat < m->heat_min) m->heat_min = heat;
    800025e6:	4918                	lw	a4,16(a0)
    800025e8:	00ead463          	bge	s5,a4,800025f0 <scheduler+0x678>
    800025ec:	01552823          	sw	s5,16(a0)
  if(heat > m->heat_max) m->heat_max = heat;
    800025f0:	4bd8                	lw	a4,20(a5)
    800025f2:	01575463          	bge	a4,s5,800025fa <scheduler+0x682>
    800025f6:	0157aa23          	sw	s5,20(a5)
  tm_temp_sum += cpu_temp;
    800025fa:	00009797          	auipc	a5,0x9
    800025fe:	26e7a783          	lw	a5,622(a5) # 8000b868 <cpu_temp>
    80002602:	00009697          	auipc	a3,0x9
    80002606:	2c668693          	addi	a3,a3,710 # 8000b8c8 <tm_temp_sum>
    8000260a:	4298                	lw	a4,0(a3)
    8000260c:	9f3d                	addw	a4,a4,a5
    8000260e:	c298                	sw	a4,0(a3)
  tm_temp_count++;
    80002610:	00009697          	auipc	a3,0x9
    80002614:	2b468693          	addi	a3,a3,692 # 8000b8c4 <tm_temp_count>
    80002618:	4298                	lw	a4,0(a3)
    8000261a:	2705                	addiw	a4,a4,1
    8000261c:	c298                	sw	a4,0(a3)
  if(cpu_temp < tm_temp_min) tm_temp_min = cpu_temp;
    8000261e:	00009717          	auipc	a4,0x9
    80002622:	24672703          	lw	a4,582(a4) # 8000b864 <tm_temp_min>
    80002626:	00e7d663          	bge	a5,a4,80002632 <scheduler+0x6ba>
    8000262a:	00009717          	auipc	a4,0x9
    8000262e:	22f72d23          	sw	a5,570(a4) # 8000b864 <tm_temp_min>
  if(cpu_temp > tm_temp_max) tm_temp_max = cpu_temp;
    80002632:	00009717          	auipc	a4,0x9
    80002636:	28e72703          	lw	a4,654(a4) # 8000b8c0 <tm_temp_max>
    8000263a:	00f75663          	bge	a4,a5,80002646 <scheduler+0x6ce>
    8000263e:	00009717          	auipc	a4,0x9
    80002642:	28f72123          	sw	a5,642(a4) # 8000b8c0 <tm_temp_max>
        chosen->waiting_tick = 0;
    80002646:	0209aa23          	sw	zero,52(s3)
        chosen->heat += HEAT_INCREMENT;
    8000264a:	0389a783          	lw	a5,56(s3)
    8000264e:	27a9                	addiw	a5,a5,10
    80002650:	853e                	mv	a0,a5
        if(chosen->heat > MAX_HEAT)
    80002652:	06400713          	li	a4,100
    80002656:	00f75463          	bge	a4,a5,8000265e <scheduler+0x6e6>
    8000265a:	06400513          	li	a0,100
    8000265e:	02a9ac23          	sw	a0,56(s3)
        update_cpu_temp(chosen->heat);
    80002662:	2501                	sext.w	a0,a0
    80002664:	a84ff0ef          	jal	800018e8 <update_cpu_temp>
        swtch(&c->context, &chosen->context);
    80002668:	06898593          	addi	a1,s3,104
    8000266c:	f8043503          	ld	a0,-128(s0)
    80002670:	7a6000ef          	jal	80002e16 <swtch>
        c->proc = 0;
    80002674:	f8843783          	ld	a5,-120(s0)
    80002678:	1a07b823          	sd	zero,432(a5)
    8000267c:	bdc1                	j	8000254c <scheduler+0x5d4>
          printf("  [THERMAL] Temp: %d [%s] | PID: %d | Heat: %d | %s",
    8000267e:	16098793          	addi	a5,s3,352
    80002682:	0389a703          	lw	a4,56(s3)
    80002686:	0309a683          	lw	a3,48(s3)
    8000268a:	00006517          	auipc	a0,0x6
    8000268e:	de650513          	addi	a0,a0,-538 # 80008470 <etext+0x470>
    80002692:	e69fd0ef          	jal	800004fa <printf>
          if(skipped > 0)
    80002696:	01504963          	bgtz	s5,800026a8 <scheduler+0x730>
          printf("\n");
    8000269a:	00006517          	auipc	a0,0x6
    8000269e:	9de50513          	addi	a0,a0,-1570 # 80008078 <etext+0x78>
    800026a2:	e59fd0ef          	jal	800004fa <printf>
    800026a6:	bf11                	j	800025ba <scheduler+0x642>
            printf(" | %d skipped", skipped);
    800026a8:	85d6                	mv	a1,s5
    800026aa:	00006517          	auipc	a0,0x6
    800026ae:	dfe50513          	addi	a0,a0,-514 # 800084a8 <etext+0x4a8>
    800026b2:	e49fd0ef          	jal	800004fa <printf>
    800026b6:	b7d5                	j	8000269a <scheduler+0x722>

00000000800026b8 <sched>:
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800026c6:	c2eff0ef          	jal	80001af4 <myproc>
    800026ca:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800026cc:	cecfe0ef          	jal	80000bb8 <holding>
    800026d0:	c935                	beqz	a0,80002744 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800026d4:	2781                	sext.w	a5,a5
    800026d6:	079e                	slli	a5,a5,0x7
    800026d8:	00011717          	auipc	a4,0x11
    800026dc:	30070713          	addi	a4,a4,768 # 800139d8 <tm>
    800026e0:	97ba                	add	a5,a5,a4
    800026e2:	2287a703          	lw	a4,552(a5)
    800026e6:	4785                	li	a5,1
    800026e8:	06f71463          	bne	a4,a5,80002750 <sched+0x98>
  if(p->state == RUNNING)
    800026ec:	4c98                	lw	a4,24(s1)
    800026ee:	4791                	li	a5,4
    800026f0:	06f70663          	beq	a4,a5,8000275c <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026f8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800026fa:	e7bd                	bnez	a5,80002768 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026fc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800026fe:	00011917          	auipc	s2,0x11
    80002702:	2da90913          	addi	s2,s2,730 # 800139d8 <tm>
    80002706:	2781                	sext.w	a5,a5
    80002708:	079e                	slli	a5,a5,0x7
    8000270a:	97ca                	add	a5,a5,s2
    8000270c:	22c7a983          	lw	s3,556(a5)
    80002710:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002712:	2781                	sext.w	a5,a5
    80002714:	079e                	slli	a5,a5,0x7
    80002716:	07a1                	addi	a5,a5,8
    80002718:	00011597          	auipc	a1,0x11
    8000271c:	47058593          	addi	a1,a1,1136 # 80013b88 <cpus>
    80002720:	95be                	add	a1,a1,a5
    80002722:	06848513          	addi	a0,s1,104
    80002726:	6f0000ef          	jal	80002e16 <swtch>
    8000272a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000272c:	2781                	sext.w	a5,a5
    8000272e:	079e                	slli	a5,a5,0x7
    80002730:	993e                	add	s2,s2,a5
    80002732:	23392623          	sw	s3,556(s2)
}
    80002736:	70a2                	ld	ra,40(sp)
    80002738:	7402                	ld	s0,32(sp)
    8000273a:	64e2                	ld	s1,24(sp)
    8000273c:	6942                	ld	s2,16(sp)
    8000273e:	69a2                	ld	s3,8(sp)
    80002740:	6145                	addi	sp,sp,48
    80002742:	8082                	ret
    panic("sched p->lock");
    80002744:	00006517          	auipc	a0,0x6
    80002748:	d7450513          	addi	a0,a0,-652 # 800084b8 <etext+0x4b8>
    8000274c:	8d8fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80002750:	00006517          	auipc	a0,0x6
    80002754:	d7850513          	addi	a0,a0,-648 # 800084c8 <etext+0x4c8>
    80002758:	8ccfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    8000275c:	00006517          	auipc	a0,0x6
    80002760:	d7c50513          	addi	a0,a0,-644 # 800084d8 <etext+0x4d8>
    80002764:	8c0fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80002768:	00006517          	auipc	a0,0x6
    8000276c:	d8050513          	addi	a0,a0,-640 # 800084e8 <etext+0x4e8>
    80002770:	8b4fe0ef          	jal	80000824 <panic>

0000000080002774 <yield>:
{
    80002774:	1101                	addi	sp,sp,-32
    80002776:	ec06                	sd	ra,24(sp)
    80002778:	e822                	sd	s0,16(sp)
    8000277a:	e426                	sd	s1,8(sp)
    8000277c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000277e:	b76ff0ef          	jal	80001af4 <myproc>
    80002782:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002784:	ca4fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002788:	478d                	li	a5,3
    8000278a:	cc9c                	sw	a5,24(s1)
  sched();
    8000278c:	f2dff0ef          	jal	800026b8 <sched>
  release(&p->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	d2afe0ef          	jal	80000cbc <release>
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret

00000000800027a0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800027a0:	7179                	addi	sp,sp,-48
    800027a2:	f406                	sd	ra,40(sp)
    800027a4:	f022                	sd	s0,32(sp)
    800027a6:	ec26                	sd	s1,24(sp)
    800027a8:	e84a                	sd	s2,16(sp)
    800027aa:	e44e                	sd	s3,8(sp)
    800027ac:	1800                	addi	s0,sp,48
    800027ae:	89aa                	mv	s3,a0
    800027b0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027b2:	b42ff0ef          	jal	80001af4 <myproc>
    800027b6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800027b8:	c70fe0ef          	jal	80000c28 <acquire>
  release(lk);
    800027bc:	854a                	mv	a0,s2
    800027be:	cfefe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    800027c2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027c6:	4789                	li	a5,2
    800027c8:	cc9c                	sw	a5,24(s1)

  sched();
    800027ca:	eefff0ef          	jal	800026b8 <sched>

  // Tidy up.
  p->chan = 0;
    800027ce:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ce8fe0ef          	jal	80000cbc <release>
  acquire(lk);
    800027d8:	854a                	mv	a0,s2
    800027da:	c4efe0ef          	jal	80000c28 <acquire>
}
    800027de:	70a2                	ld	ra,40(sp)
    800027e0:	7402                	ld	s0,32(sp)
    800027e2:	64e2                	ld	s1,24(sp)
    800027e4:	6942                	ld	s2,16(sp)
    800027e6:	69a2                	ld	s3,8(sp)
    800027e8:	6145                	addi	sp,sp,48
    800027ea:	8082                	ret

00000000800027ec <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800027ec:	7139                	addi	sp,sp,-64
    800027ee:	fc06                	sd	ra,56(sp)
    800027f0:	f822                	sd	s0,48(sp)
    800027f2:	f426                	sd	s1,40(sp)
    800027f4:	f04a                	sd	s2,32(sp)
    800027f6:	ec4e                	sd	s3,24(sp)
    800027f8:	e852                	sd	s4,16(sp)
    800027fa:	e456                	sd	s5,8(sp)
    800027fc:	0080                	addi	s0,sp,64
    800027fe:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002800:	00011497          	auipc	s1,0x11
    80002804:	78848493          	addi	s1,s1,1928 # 80013f88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002808:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000280a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000280c:	00017917          	auipc	s2,0x17
    80002810:	37c90913          	addi	s2,s2,892 # 80019b88 <tickslock>
    80002814:	a801                	j	80002824 <wakeup+0x38>
      }
      release(&p->lock);
    80002816:	8526                	mv	a0,s1
    80002818:	ca4fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000281c:	17048493          	addi	s1,s1,368
    80002820:	03248263          	beq	s1,s2,80002844 <wakeup+0x58>
    if(p != myproc()){
    80002824:	ad0ff0ef          	jal	80001af4 <myproc>
    80002828:	fe950ae3          	beq	a0,s1,8000281c <wakeup+0x30>
      acquire(&p->lock);
    8000282c:	8526                	mv	a0,s1
    8000282e:	bfafe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002832:	4c9c                	lw	a5,24(s1)
    80002834:	ff3791e3          	bne	a5,s3,80002816 <wakeup+0x2a>
    80002838:	709c                	ld	a5,32(s1)
    8000283a:	fd479ee3          	bne	a5,s4,80002816 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000283e:	0154ac23          	sw	s5,24(s1)
    80002842:	bfd1                	j	80002816 <wakeup+0x2a>
    }
  }
}
    80002844:	70e2                	ld	ra,56(sp)
    80002846:	7442                	ld	s0,48(sp)
    80002848:	74a2                	ld	s1,40(sp)
    8000284a:	7902                	ld	s2,32(sp)
    8000284c:	69e2                	ld	s3,24(sp)
    8000284e:	6a42                	ld	s4,16(sp)
    80002850:	6aa2                	ld	s5,8(sp)
    80002852:	6121                	addi	sp,sp,64
    80002854:	8082                	ret

0000000080002856 <reparent>:
{
    80002856:	7179                	addi	sp,sp,-48
    80002858:	f406                	sd	ra,40(sp)
    8000285a:	f022                	sd	s0,32(sp)
    8000285c:	ec26                	sd	s1,24(sp)
    8000285e:	e84a                	sd	s2,16(sp)
    80002860:	e44e                	sd	s3,8(sp)
    80002862:	e052                	sd	s4,0(sp)
    80002864:	1800                	addi	s0,sp,48
    80002866:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002868:	00011497          	auipc	s1,0x11
    8000286c:	72048493          	addi	s1,s1,1824 # 80013f88 <proc>
      pp->parent = initproc;
    80002870:	00009a17          	auipc	s4,0x9
    80002874:	060a0a13          	addi	s4,s4,96 # 8000b8d0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002878:	00017997          	auipc	s3,0x17
    8000287c:	31098993          	addi	s3,s3,784 # 80019b88 <tickslock>
    80002880:	a029                	j	8000288a <reparent+0x34>
    80002882:	17048493          	addi	s1,s1,368
    80002886:	01348b63          	beq	s1,s3,8000289c <reparent+0x46>
    if(pp->parent == p){
    8000288a:	60bc                	ld	a5,64(s1)
    8000288c:	ff279be3          	bne	a5,s2,80002882 <reparent+0x2c>
      pp->parent = initproc;
    80002890:	000a3503          	ld	a0,0(s4)
    80002894:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002896:	f57ff0ef          	jal	800027ec <wakeup>
    8000289a:	b7e5                	j	80002882 <reparent+0x2c>
}
    8000289c:	70a2                	ld	ra,40(sp)
    8000289e:	7402                	ld	s0,32(sp)
    800028a0:	64e2                	ld	s1,24(sp)
    800028a2:	6942                	ld	s2,16(sp)
    800028a4:	69a2                	ld	s3,8(sp)
    800028a6:	6a02                	ld	s4,0(sp)
    800028a8:	6145                	addi	sp,sp,48
    800028aa:	8082                	ret

00000000800028ac <kexit>:
{
    800028ac:	7179                	addi	sp,sp,-48
    800028ae:	f406                	sd	ra,40(sp)
    800028b0:	f022                	sd	s0,32(sp)
    800028b2:	ec26                	sd	s1,24(sp)
    800028b4:	e84a                	sd	s2,16(sp)
    800028b6:	e44e                	sd	s3,8(sp)
    800028b8:	e052                	sd	s4,0(sp)
    800028ba:	1800                	addi	s0,sp,48
    800028bc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800028be:	a36ff0ef          	jal	80001af4 <myproc>
    800028c2:	89aa                	mv	s3,a0
  if(p == initproc)
    800028c4:	00009797          	auipc	a5,0x9
    800028c8:	00c7b783          	ld	a5,12(a5) # 8000b8d0 <initproc>
    800028cc:	0d850493          	addi	s1,a0,216
    800028d0:	15850913          	addi	s2,a0,344
    800028d4:	00a79b63          	bne	a5,a0,800028ea <kexit+0x3e>
    panic("init exiting");
    800028d8:	00006517          	auipc	a0,0x6
    800028dc:	c2850513          	addi	a0,a0,-984 # 80008500 <etext+0x500>
    800028e0:	f45fd0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800028e4:	04a1                	addi	s1,s1,8
    800028e6:	01248963          	beq	s1,s2,800028f8 <kexit+0x4c>
    if(p->ofile[fd]){
    800028ea:	6088                	ld	a0,0(s1)
    800028ec:	dd65                	beqz	a0,800028e4 <kexit+0x38>
      fileclose(f);
    800028ee:	1e8020ef          	jal	80004ad6 <fileclose>
      p->ofile[fd] = 0;
    800028f2:	0004b023          	sd	zero,0(s1)
    800028f6:	b7fd                	j	800028e4 <kexit+0x38>
  begin_op();
    800028f8:	5bb010ef          	jal	800046b2 <begin_op>
  iput(p->cwd);
    800028fc:	1589b503          	ld	a0,344(s3)
    80002900:	528010ef          	jal	80003e28 <iput>
  end_op();
    80002904:	61f010ef          	jal	80004722 <end_op>
  p->cwd = 0;
    80002908:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000290c:	00011517          	auipc	a0,0x11
    80002910:	26450513          	addi	a0,a0,612 # 80013b70 <wait_lock>
    80002914:	b14fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002918:	854e                	mv	a0,s3
    8000291a:	f3dff0ef          	jal	80002856 <reparent>
  wakeup(p->parent);
    8000291e:	0409b503          	ld	a0,64(s3)
    80002922:	ecbff0ef          	jal	800027ec <wakeup>
  acquire(&p->lock);
    80002926:	854e                	mv	a0,s3
    80002928:	b00fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000292c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002930:	4795                	li	a5,5
    80002932:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002936:	00011517          	auipc	a0,0x11
    8000293a:	23a50513          	addi	a0,a0,570 # 80013b70 <wait_lock>
    8000293e:	b7efe0ef          	jal	80000cbc <release>
  sched();
    80002942:	d77ff0ef          	jal	800026b8 <sched>
  panic("zombie exit");
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	bca50513          	addi	a0,a0,-1078 # 80008510 <etext+0x510>
    8000294e:	ed7fd0ef          	jal	80000824 <panic>

0000000080002952 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002952:	7179                	addi	sp,sp,-48
    80002954:	f406                	sd	ra,40(sp)
    80002956:	f022                	sd	s0,32(sp)
    80002958:	ec26                	sd	s1,24(sp)
    8000295a:	e84a                	sd	s2,16(sp)
    8000295c:	e44e                	sd	s3,8(sp)
    8000295e:	1800                	addi	s0,sp,48
    80002960:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002962:	00011497          	auipc	s1,0x11
    80002966:	62648493          	addi	s1,s1,1574 # 80013f88 <proc>
    8000296a:	00017997          	auipc	s3,0x17
    8000296e:	21e98993          	addi	s3,s3,542 # 80019b88 <tickslock>
    acquire(&p->lock);
    80002972:	8526                	mv	a0,s1
    80002974:	ab4fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002978:	589c                	lw	a5,48(s1)
    8000297a:	01278b63          	beq	a5,s2,80002990 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000297e:	8526                	mv	a0,s1
    80002980:	b3cfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002984:	17048493          	addi	s1,s1,368
    80002988:	ff3495e3          	bne	s1,s3,80002972 <kkill+0x20>
  }
  return -1;
    8000298c:	557d                	li	a0,-1
    8000298e:	a819                	j	800029a4 <kkill+0x52>
      p->killed = 1;
    80002990:	4785                	li	a5,1
    80002992:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002994:	4c98                	lw	a4,24(s1)
    80002996:	4789                	li	a5,2
    80002998:	00f70d63          	beq	a4,a5,800029b2 <kkill+0x60>
      release(&p->lock);
    8000299c:	8526                	mv	a0,s1
    8000299e:	b1efe0ef          	jal	80000cbc <release>
      return 0;
    800029a2:	4501                	li	a0,0
}
    800029a4:	70a2                	ld	ra,40(sp)
    800029a6:	7402                	ld	s0,32(sp)
    800029a8:	64e2                	ld	s1,24(sp)
    800029aa:	6942                	ld	s2,16(sp)
    800029ac:	69a2                	ld	s3,8(sp)
    800029ae:	6145                	addi	sp,sp,48
    800029b0:	8082                	ret
        p->state = RUNNABLE;
    800029b2:	478d                	li	a5,3
    800029b4:	cc9c                	sw	a5,24(s1)
    800029b6:	b7dd                	j	8000299c <kkill+0x4a>

00000000800029b8 <setkilled>:

void
setkilled(struct proc *p)
{
    800029b8:	1101                	addi	sp,sp,-32
    800029ba:	ec06                	sd	ra,24(sp)
    800029bc:	e822                	sd	s0,16(sp)
    800029be:	e426                	sd	s1,8(sp)
    800029c0:	1000                	addi	s0,sp,32
    800029c2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800029c4:	a64fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800029c8:	4785                	li	a5,1
    800029ca:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800029cc:	8526                	mv	a0,s1
    800029ce:	aeefe0ef          	jal	80000cbc <release>
}
    800029d2:	60e2                	ld	ra,24(sp)
    800029d4:	6442                	ld	s0,16(sp)
    800029d6:	64a2                	ld	s1,8(sp)
    800029d8:	6105                	addi	sp,sp,32
    800029da:	8082                	ret

00000000800029dc <killed>:

int
killed(struct proc *p)
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	e426                	sd	s1,8(sp)
    800029e4:	e04a                	sd	s2,0(sp)
    800029e6:	1000                	addi	s0,sp,32
    800029e8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800029ea:	a3efe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800029ee:	549c                	lw	a5,40(s1)
    800029f0:	893e                	mv	s2,a5
  release(&p->lock);
    800029f2:	8526                	mv	a0,s1
    800029f4:	ac8fe0ef          	jal	80000cbc <release>
  return k;
}
    800029f8:	854a                	mv	a0,s2
    800029fa:	60e2                	ld	ra,24(sp)
    800029fc:	6442                	ld	s0,16(sp)
    800029fe:	64a2                	ld	s1,8(sp)
    80002a00:	6902                	ld	s2,0(sp)
    80002a02:	6105                	addi	sp,sp,32
    80002a04:	8082                	ret

0000000080002a06 <kwait>:
{
    80002a06:	715d                	addi	sp,sp,-80
    80002a08:	e486                	sd	ra,72(sp)
    80002a0a:	e0a2                	sd	s0,64(sp)
    80002a0c:	fc26                	sd	s1,56(sp)
    80002a0e:	f84a                	sd	s2,48(sp)
    80002a10:	f44e                	sd	s3,40(sp)
    80002a12:	f052                	sd	s4,32(sp)
    80002a14:	ec56                	sd	s5,24(sp)
    80002a16:	e85a                	sd	s6,16(sp)
    80002a18:	e45e                	sd	s7,8(sp)
    80002a1a:	0880                	addi	s0,sp,80
    80002a1c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002a1e:	8d6ff0ef          	jal	80001af4 <myproc>
    80002a22:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a24:	00011517          	auipc	a0,0x11
    80002a28:	14c50513          	addi	a0,a0,332 # 80013b70 <wait_lock>
    80002a2c:	9fcfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002a30:	4a15                	li	s4,5
        havekids = 1;
    80002a32:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a34:	00017997          	auipc	s3,0x17
    80002a38:	15498993          	addi	s3,s3,340 # 80019b88 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a3c:	00011b17          	auipc	s6,0x11
    80002a40:	134b0b13          	addi	s6,s6,308 # 80013b70 <wait_lock>
    80002a44:	a869                	j	80002ade <kwait+0xd8>
          pid = pp->pid;
    80002a46:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a4a:	000b8c63          	beqz	s7,80002a62 <kwait+0x5c>
    80002a4e:	4691                	li	a3,4
    80002a50:	02c48613          	addi	a2,s1,44
    80002a54:	85de                	mv	a1,s7
    80002a56:	05893503          	ld	a0,88(s2)
    80002a5a:	bfbfe0ef          	jal	80001654 <copyout>
    80002a5e:	02054a63          	bltz	a0,80002a92 <kwait+0x8c>
          freeproc(pp);
    80002a62:	8526                	mv	a0,s1
    80002a64:	a66ff0ef          	jal	80001cca <freeproc>
          release(&pp->lock);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	a52fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002a6e:	00011517          	auipc	a0,0x11
    80002a72:	10250513          	addi	a0,a0,258 # 80013b70 <wait_lock>
    80002a76:	a46fe0ef          	jal	80000cbc <release>
}
    80002a7a:	854e                	mv	a0,s3
    80002a7c:	60a6                	ld	ra,72(sp)
    80002a7e:	6406                	ld	s0,64(sp)
    80002a80:	74e2                	ld	s1,56(sp)
    80002a82:	7942                	ld	s2,48(sp)
    80002a84:	79a2                	ld	s3,40(sp)
    80002a86:	7a02                	ld	s4,32(sp)
    80002a88:	6ae2                	ld	s5,24(sp)
    80002a8a:	6b42                	ld	s6,16(sp)
    80002a8c:	6ba2                	ld	s7,8(sp)
    80002a8e:	6161                	addi	sp,sp,80
    80002a90:	8082                	ret
            release(&pp->lock);
    80002a92:	8526                	mv	a0,s1
    80002a94:	a28fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002a98:	00011517          	auipc	a0,0x11
    80002a9c:	0d850513          	addi	a0,a0,216 # 80013b70 <wait_lock>
    80002aa0:	a1cfe0ef          	jal	80000cbc <release>
            return -1;
    80002aa4:	59fd                	li	s3,-1
    80002aa6:	bfd1                	j	80002a7a <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002aa8:	17048493          	addi	s1,s1,368
    80002aac:	03348063          	beq	s1,s3,80002acc <kwait+0xc6>
      if(pp->parent == p){
    80002ab0:	60bc                	ld	a5,64(s1)
    80002ab2:	ff279be3          	bne	a5,s2,80002aa8 <kwait+0xa2>
        acquire(&pp->lock);
    80002ab6:	8526                	mv	a0,s1
    80002ab8:	970fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002abc:	4c9c                	lw	a5,24(s1)
    80002abe:	f94784e3          	beq	a5,s4,80002a46 <kwait+0x40>
        release(&pp->lock);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	9f8fe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002ac8:	8756                	mv	a4,s5
    80002aca:	bff9                	j	80002aa8 <kwait+0xa2>
    if(!havekids || killed(p)){
    80002acc:	cf19                	beqz	a4,80002aea <kwait+0xe4>
    80002ace:	854a                	mv	a0,s2
    80002ad0:	f0dff0ef          	jal	800029dc <killed>
    80002ad4:	e919                	bnez	a0,80002aea <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002ad6:	85da                	mv	a1,s6
    80002ad8:	854a                	mv	a0,s2
    80002ada:	cc7ff0ef          	jal	800027a0 <sleep>
    havekids = 0;
    80002ade:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002ae0:	00011497          	auipc	s1,0x11
    80002ae4:	4a848493          	addi	s1,s1,1192 # 80013f88 <proc>
    80002ae8:	b7e1                	j	80002ab0 <kwait+0xaa>
      release(&wait_lock);
    80002aea:	00011517          	auipc	a0,0x11
    80002aee:	08650513          	addi	a0,a0,134 # 80013b70 <wait_lock>
    80002af2:	9cafe0ef          	jal	80000cbc <release>
      return -1;
    80002af6:	59fd                	li	s3,-1
    80002af8:	b749                	j	80002a7a <kwait+0x74>

0000000080002afa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002afa:	7179                	addi	sp,sp,-48
    80002afc:	f406                	sd	ra,40(sp)
    80002afe:	f022                	sd	s0,32(sp)
    80002b00:	ec26                	sd	s1,24(sp)
    80002b02:	e84a                	sd	s2,16(sp)
    80002b04:	e44e                	sd	s3,8(sp)
    80002b06:	e052                	sd	s4,0(sp)
    80002b08:	1800                	addi	s0,sp,48
    80002b0a:	84aa                	mv	s1,a0
    80002b0c:	8a2e                	mv	s4,a1
    80002b0e:	89b2                	mv	s3,a2
    80002b10:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002b12:	fe3fe0ef          	jal	80001af4 <myproc>
  if(user_dst){
    80002b16:	cc99                	beqz	s1,80002b34 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002b18:	86ca                	mv	a3,s2
    80002b1a:	864e                	mv	a2,s3
    80002b1c:	85d2                	mv	a1,s4
    80002b1e:	6d28                	ld	a0,88(a0)
    80002b20:	b35fe0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b24:	70a2                	ld	ra,40(sp)
    80002b26:	7402                	ld	s0,32(sp)
    80002b28:	64e2                	ld	s1,24(sp)
    80002b2a:	6942                	ld	s2,16(sp)
    80002b2c:	69a2                	ld	s3,8(sp)
    80002b2e:	6a02                	ld	s4,0(sp)
    80002b30:	6145                	addi	sp,sp,48
    80002b32:	8082                	ret
    memmove((char *)dst, src, len);
    80002b34:	0009061b          	sext.w	a2,s2
    80002b38:	85ce                	mv	a1,s3
    80002b3a:	8552                	mv	a0,s4
    80002b3c:	a1cfe0ef          	jal	80000d58 <memmove>
    return 0;
    80002b40:	8526                	mv	a0,s1
    80002b42:	b7cd                	j	80002b24 <either_copyout+0x2a>

0000000080002b44 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b44:	7179                	addi	sp,sp,-48
    80002b46:	f406                	sd	ra,40(sp)
    80002b48:	f022                	sd	s0,32(sp)
    80002b4a:	ec26                	sd	s1,24(sp)
    80002b4c:	e84a                	sd	s2,16(sp)
    80002b4e:	e44e                	sd	s3,8(sp)
    80002b50:	e052                	sd	s4,0(sp)
    80002b52:	1800                	addi	s0,sp,48
    80002b54:	8a2a                	mv	s4,a0
    80002b56:	84ae                	mv	s1,a1
    80002b58:	89b2                	mv	s3,a2
    80002b5a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002b5c:	f99fe0ef          	jal	80001af4 <myproc>
  if(user_src){
    80002b60:	cc99                	beqz	s1,80002b7e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002b62:	86ca                	mv	a3,s2
    80002b64:	864e                	mv	a2,s3
    80002b66:	85d2                	mv	a1,s4
    80002b68:	6d28                	ld	a0,88(a0)
    80002b6a:	ba9fe0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b6e:	70a2                	ld	ra,40(sp)
    80002b70:	7402                	ld	s0,32(sp)
    80002b72:	64e2                	ld	s1,24(sp)
    80002b74:	6942                	ld	s2,16(sp)
    80002b76:	69a2                	ld	s3,8(sp)
    80002b78:	6a02                	ld	s4,0(sp)
    80002b7a:	6145                	addi	sp,sp,48
    80002b7c:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b7e:	0009061b          	sext.w	a2,s2
    80002b82:	85ce                	mv	a1,s3
    80002b84:	8552                	mv	a0,s4
    80002b86:	9d2fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	b7cd                	j	80002b6e <either_copyin+0x2a>

0000000080002b8e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b8e:	715d                	addi	sp,sp,-80
    80002b90:	e486                	sd	ra,72(sp)
    80002b92:	e0a2                	sd	s0,64(sp)
    80002b94:	fc26                	sd	s1,56(sp)
    80002b96:	f84a                	sd	s2,48(sp)
    80002b98:	f44e                	sd	s3,40(sp)
    80002b9a:	f052                	sd	s4,32(sp)
    80002b9c:	ec56                	sd	s5,24(sp)
    80002b9e:	e85a                	sd	s6,16(sp)
    80002ba0:	e45e                	sd	s7,8(sp)
    80002ba2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	4d450513          	addi	a0,a0,1236 # 80008078 <etext+0x78>
    80002bac:	94ffd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bb0:	00011497          	auipc	s1,0x11
    80002bb4:	53848493          	addi	s1,s1,1336 # 800140e8 <proc+0x160>
    80002bb8:	00017917          	auipc	s2,0x17
    80002bbc:	13090913          	addi	s2,s2,304 # 80019ce8 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bc0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002bc2:	00006997          	auipc	s3,0x6
    80002bc6:	95e98993          	addi	s3,s3,-1698 # 80008520 <etext+0x520>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002bca:	00006a97          	auipc	s5,0x6
    80002bce:	95ea8a93          	addi	s5,s5,-1698 # 80008528 <etext+0x528>
    printf("\n");
    80002bd2:	00005a17          	auipc	s4,0x5
    80002bd6:	4a6a0a13          	addi	s4,s4,1190 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bda:	00006b97          	auipc	s7,0x6
    80002bde:	fdeb8b93          	addi	s7,s7,-34 # 80008bb8 <states.1>
    80002be2:	a839                	j	80002c00 <procdump+0x72>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002be4:	ed86a703          	lw	a4,-296(a3)
    80002be8:	ed06a583          	lw	a1,-304(a3)
    80002bec:	8556                	mv	a0,s5
    80002bee:	90dfd0ef          	jal	800004fa <printf>
    printf("\n");
    80002bf2:	8552                	mv	a0,s4
    80002bf4:	907fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bf8:	17048493          	addi	s1,s1,368
    80002bfc:	03248263          	beq	s1,s2,80002c20 <procdump+0x92>
    if(p->state == UNUSED)
    80002c00:	86a6                	mv	a3,s1
    80002c02:	eb84a783          	lw	a5,-328(s1)
    80002c06:	dbed                	beqz	a5,80002bf8 <procdump+0x6a>
      state = "???";
    80002c08:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c0a:	fcfb6de3          	bltu	s6,a5,80002be4 <procdump+0x56>
    80002c0e:	02079713          	slli	a4,a5,0x20
    80002c12:	01d75793          	srli	a5,a4,0x1d
    80002c16:	97de                	add	a5,a5,s7
    80002c18:	6390                	ld	a2,0(a5)
    80002c1a:	f669                	bnez	a2,80002be4 <procdump+0x56>
      state = "???";
    80002c1c:	864e                	mv	a2,s3
    80002c1e:	b7d9                	j	80002be4 <procdump+0x56>
  }
}
    80002c20:	60a6                	ld	ra,72(sp)
    80002c22:	6406                	ld	s0,64(sp)
    80002c24:	74e2                	ld	s1,56(sp)
    80002c26:	7942                	ld	s2,48(sp)
    80002c28:	79a2                	ld	s3,40(sp)
    80002c2a:	7a02                	ld	s4,32(sp)
    80002c2c:	6ae2                	ld	s5,24(sp)
    80002c2e:	6b42                	ld	s6,16(sp)
    80002c30:	6ba2                	ld	s7,8(sp)
    80002c32:	6161                	addi	sp,sp,80
    80002c34:	8082                	ret

0000000080002c36 <kps>:


int
kps(char *arguments)
{
    80002c36:	7179                	addi	sp,sp,-48
    80002c38:	f406                	sd	ra,40(sp)
    80002c3a:	f022                	sd	s0,32(sp)
    80002c3c:	ec26                	sd	s1,24(sp)
    80002c3e:	1800                	addi	s0,sp,48
    80002c40:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    80002c42:	4609                	li	a2,2
    80002c44:	00006597          	auipc	a1,0x6
    80002c48:	8fc58593          	addi	a1,a1,-1796 # 80008540 <etext+0x540>
    80002c4c:	980fe0ef          	jal	80000dcc <strncmp>
    80002c50:	e931                	bnez	a0,80002ca4 <kps+0x6e>
    80002c52:	e84a                	sd	s2,16(sp)
    80002c54:	e44e                	sd	s3,8(sp)
    80002c56:	00011497          	auipc	s1,0x11
    80002c5a:	49248493          	addi	s1,s1,1170 # 800140e8 <proc+0x160>
    80002c5e:	00017917          	auipc	s2,0x17
    80002c62:	08a90913          	addi	s2,s2,138 # 80019ce8 <bcache+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    80002c66:	00006997          	auipc	s3,0x6
    80002c6a:	8e298993          	addi	s3,s3,-1822 # 80008548 <etext+0x548>
    80002c6e:	a029                	j	80002c78 <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    80002c70:	17048493          	addi	s1,s1,368
    80002c74:	01248a63          	beq	s1,s2,80002c88 <kps+0x52>
      if (p->state != UNUSED){
    80002c78:	eb84a783          	lw	a5,-328(s1)
    80002c7c:	dbf5                	beqz	a5,80002c70 <kps+0x3a>
        printf("%s ", p->name);
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	854e                	mv	a0,s3
    80002c82:	879fd0ef          	jal	800004fa <printf>
    80002c86:	b7ed                	j	80002c70 <kps+0x3a>
      }
    }
    printf("\n");
    80002c88:	00005517          	auipc	a0,0x5
    80002c8c:	3f050513          	addi	a0,a0,1008 # 80008078 <etext+0x78>
    80002c90:	86bfd0ef          	jal	800004fa <printf>
    80002c94:	6942                	ld	s2,16(sp)
    80002c96:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l | -t]\n");
  }

  return 0;

    80002c98:	4501                	li	a0,0
    80002c9a:	70a2                	ld	ra,40(sp)
    80002c9c:	7402                	ld	s0,32(sp)
    80002c9e:	64e2                	ld	s1,24(sp)
    80002ca0:	6145                	addi	sp,sp,48
    80002ca2:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    80002ca4:	4609                	li	a2,2
    80002ca6:	00006597          	auipc	a1,0x6
    80002caa:	8aa58593          	addi	a1,a1,-1878 # 80008550 <etext+0x550>
    80002cae:	8526                	mv	a0,s1
    80002cb0:	91cfe0ef          	jal	80000dcc <strncmp>
    80002cb4:	e92d                	bnez	a0,80002d26 <kps+0xf0>
    80002cb6:	e84a                	sd	s2,16(sp)
    80002cb8:	e44e                	sd	s3,8(sp)
    80002cba:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    80002cbc:	00006517          	auipc	a0,0x6
    80002cc0:	89c50513          	addi	a0,a0,-1892 # 80008558 <etext+0x558>
    80002cc4:	837fd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    80002cc8:	00006517          	auipc	a0,0x6
    80002ccc:	95050513          	addi	a0,a0,-1712 # 80008618 <etext+0x618>
    80002cd0:	82bfd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002cd4:	00011497          	auipc	s1,0x11
    80002cd8:	41448493          	addi	s1,s1,1044 # 800140e8 <proc+0x160>
    80002cdc:	00017917          	auipc	s2,0x17
    80002ce0:	00c90913          	addi	s2,s2,12 # 80019ce8 <bcache+0x148>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002ce4:	00006a17          	auipc	s4,0x6
    80002ce8:	ed4a0a13          	addi	s4,s4,-300 # 80008bb8 <states.1>
    80002cec:	00006997          	auipc	s3,0x6
    80002cf0:	88498993          	addi	s3,s3,-1916 # 80008570 <etext+0x570>
    80002cf4:	a029                	j	80002cfe <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    80002cf6:	17048493          	addi	s1,s1,368
    80002cfa:	03248263          	beq	s1,s2,80002d1e <kps+0xe8>
      if (p->state != UNUSED){
    80002cfe:	eb84a783          	lw	a5,-328(s1)
    80002d02:	dbf5                	beqz	a5,80002cf6 <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002d04:	02079713          	slli	a4,a5,0x20
    80002d08:	01d75793          	srli	a5,a4,0x1d
    80002d0c:	97d2                	add	a5,a5,s4
    80002d0e:	86a6                	mv	a3,s1
    80002d10:	7b90                	ld	a2,48(a5)
    80002d12:	ed04a583          	lw	a1,-304(s1)
    80002d16:	854e                	mv	a0,s3
    80002d18:	fe2fd0ef          	jal	800004fa <printf>
    80002d1c:	bfe9                	j	80002cf6 <kps+0xc0>
    80002d1e:	6942                	ld	s2,16(sp)
    80002d20:	69a2                	ld	s3,8(sp)
    80002d22:	6a02                	ld	s4,0(sp)
    80002d24:	bf95                	j	80002c98 <kps+0x62>
  }else if(strncmp(arguments, "-t", 2)==0){
    80002d26:	4609                	li	a2,2
    80002d28:	00006597          	auipc	a1,0x6
    80002d2c:	85858593          	addi	a1,a1,-1960 # 80008580 <etext+0x580>
    80002d30:	8526                	mv	a0,s1
    80002d32:	89afe0ef          	jal	80000dcc <strncmp>
    80002d36:	e969                	bnez	a0,80002e08 <kps+0x1d2>
    80002d38:	e84a                	sd	s2,16(sp)
    80002d3a:	e44e                	sd	s3,8(sp)
    80002d3c:	e052                	sd	s4,0(sp)
    printf("===== Thermal Monitor =====\n");
    80002d3e:	00006517          	auipc	a0,0x6
    80002d42:	84a50513          	addi	a0,a0,-1974 # 80008588 <etext+0x588>
    80002d46:	fb4fd0ef          	jal	800004fa <printf>
    printf("CPU Temperature: %d / 100", cpu_temp);
    80002d4a:	00009497          	auipc	s1,0x9
    80002d4e:	b1e48493          	addi	s1,s1,-1250 # 8000b868 <cpu_temp>
    80002d52:	408c                	lw	a1,0(s1)
    80002d54:	00006517          	auipc	a0,0x6
    80002d58:	85450513          	addi	a0,a0,-1964 # 800085a8 <etext+0x5a8>
    80002d5c:	f9efd0ef          	jal	800004fa <printf>
    if(cpu_temp >= 80)
    80002d60:	409c                	lw	a5,0(s1)
    80002d62:	04f00713          	li	a4,79
    80002d66:	04f74963          	blt	a4,a5,80002db8 <kps+0x182>
    else if(cpu_temp >= 60)
    80002d6a:	03b00713          	li	a4,59
    80002d6e:	04f75c63          	bge	a4,a5,80002dc6 <kps+0x190>
      printf("  [WARM]\n");
    80002d72:	00006517          	auipc	a0,0x6
    80002d76:	86650513          	addi	a0,a0,-1946 # 800085d8 <etext+0x5d8>
    80002d7a:	f80fd0ef          	jal	800004fa <printf>
    printf("\nPID\tSTATE\t\tHEAT\tNAME\n");
    80002d7e:	00006517          	auipc	a0,0x6
    80002d82:	87a50513          	addi	a0,a0,-1926 # 800085f8 <etext+0x5f8>
    80002d86:	f74fd0ef          	jal	800004fa <printf>
    printf("---------------------------------------\n");
    80002d8a:	00006517          	auipc	a0,0x6
    80002d8e:	88650513          	addi	a0,a0,-1914 # 80008610 <etext+0x610>
    80002d92:	f68fd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002d96:	00011497          	auipc	s1,0x11
    80002d9a:	35248493          	addi	s1,s1,850 # 800140e8 <proc+0x160>
    80002d9e:	00017917          	auipc	s2,0x17
    80002da2:	f4a90913          	addi	s2,s2,-182 # 80019ce8 <bcache+0x148>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002da6:	00006a17          	auipc	s4,0x6
    80002daa:	e12a0a13          	addi	s4,s4,-494 # 80008bb8 <states.1>
    80002dae:	00006997          	auipc	s3,0x6
    80002db2:	89298993          	addi	s3,s3,-1902 # 80008640 <etext+0x640>
    80002db6:	a01d                	j	80002ddc <kps+0x1a6>
      printf("  [HOT]\n");
    80002db8:	00006517          	auipc	a0,0x6
    80002dbc:	81050513          	addi	a0,a0,-2032 # 800085c8 <etext+0x5c8>
    80002dc0:	f3afd0ef          	jal	800004fa <printf>
    80002dc4:	bf6d                	j	80002d7e <kps+0x148>
      printf("  [COOL]\n");
    80002dc6:	00006517          	auipc	a0,0x6
    80002dca:	82250513          	addi	a0,a0,-2014 # 800085e8 <etext+0x5e8>
    80002dce:	f2cfd0ef          	jal	800004fa <printf>
    80002dd2:	b775                	j	80002d7e <kps+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
    80002dd4:	17048493          	addi	s1,s1,368
    80002dd8:	03248463          	beq	s1,s2,80002e00 <kps+0x1ca>
      if (p->state != UNUSED){
    80002ddc:	eb84a783          	lw	a5,-328(s1)
    80002de0:	dbf5                	beqz	a5,80002dd4 <kps+0x19e>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002de2:	02079713          	slli	a4,a5,0x20
    80002de6:	01d75793          	srli	a5,a4,0x1d
    80002dea:	97d2                	add	a5,a5,s4
    80002dec:	8726                	mv	a4,s1
    80002dee:	ed84a683          	lw	a3,-296(s1)
    80002df2:	7b90                	ld	a2,48(a5)
    80002df4:	ed04a583          	lw	a1,-304(s1)
    80002df8:	854e                	mv	a0,s3
    80002dfa:	f00fd0ef          	jal	800004fa <printf>
    80002dfe:	bfd9                	j	80002dd4 <kps+0x19e>
    80002e00:	6942                	ld	s2,16(sp)
    80002e02:	69a2                	ld	s3,8(sp)
    80002e04:	6a02                	ld	s4,0(sp)
    80002e06:	bd49                	j	80002c98 <kps+0x62>
    printf("Usage: ps [-o | -l | -t]\n");
    80002e08:	00006517          	auipc	a0,0x6
    80002e0c:	84850513          	addi	a0,a0,-1976 # 80008650 <etext+0x650>
    80002e10:	eeafd0ef          	jal	800004fa <printf>
    80002e14:	b551                	j	80002c98 <kps+0x62>

0000000080002e16 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002e16:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002e1a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002e1e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002e20:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002e22:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002e26:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002e2a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002e2e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002e32:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002e36:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002e3a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002e3e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002e42:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002e46:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002e4a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002e4e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002e52:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002e54:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002e56:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002e5a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002e5e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002e62:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002e66:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002e6a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002e6e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002e72:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002e76:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002e7a:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002e7e:	8082                	ret

0000000080002e80 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e80:	1141                	addi	sp,sp,-16
    80002e82:	e406                	sd	ra,8(sp)
    80002e84:	e022                	sd	s0,0(sp)
    80002e86:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e88:	00006597          	auipc	a1,0x6
    80002e8c:	85858593          	addi	a1,a1,-1960 # 800086e0 <etext+0x6e0>
    80002e90:	00017517          	auipc	a0,0x17
    80002e94:	cf850513          	addi	a0,a0,-776 # 80019b88 <tickslock>
    80002e98:	d07fd0ef          	jal	80000b9e <initlock>
}
    80002e9c:	60a2                	ld	ra,8(sp)
    80002e9e:	6402                	ld	s0,0(sp)
    80002ea0:	0141                	addi	sp,sp,16
    80002ea2:	8082                	ret

0000000080002ea4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ea4:	1141                	addi	sp,sp,-16
    80002ea6:	e406                	sd	ra,8(sp)
    80002ea8:	e022                	sd	s0,0(sp)
    80002eaa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002eac:	00003797          	auipc	a5,0x3
    80002eb0:	03478793          	addi	a5,a5,52 # 80005ee0 <kernelvec>
    80002eb4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002eb8:	60a2                	ld	ra,8(sp)
    80002eba:	6402                	ld	s0,0(sp)
    80002ebc:	0141                	addi	sp,sp,16
    80002ebe:	8082                	ret

0000000080002ec0 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002ec0:	1141                	addi	sp,sp,-16
    80002ec2:	e406                	sd	ra,8(sp)
    80002ec4:	e022                	sd	s0,0(sp)
    80002ec6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ec8:	c2dfe0ef          	jal	80001af4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ecc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ed0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ed2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ed6:	04000737          	lui	a4,0x4000
    80002eda:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002edc:	0732                	slli	a4,a4,0xc
    80002ede:	00004797          	auipc	a5,0x4
    80002ee2:	12278793          	addi	a5,a5,290 # 80007000 <_trampoline>
    80002ee6:	00004697          	auipc	a3,0x4
    80002eea:	11a68693          	addi	a3,a3,282 # 80007000 <_trampoline>
    80002eee:	8f95                	sub	a5,a5,a3
    80002ef0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ef2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ef6:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ef8:	18002773          	csrr	a4,satp
    80002efc:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002efe:	7138                	ld	a4,96(a0)
    80002f00:	653c                	ld	a5,72(a0)
    80002f02:	6685                	lui	a3,0x1
    80002f04:	97b6                	add	a5,a5,a3
    80002f06:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002f08:	713c                	ld	a5,96(a0)
    80002f0a:	00000717          	auipc	a4,0x0
    80002f0e:	11c70713          	addi	a4,a4,284 # 80003026 <usertrap>
    80002f12:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002f14:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f16:	8712                	mv	a4,tp
    80002f18:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f1a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f1e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f22:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f26:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f2a:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f2c:	6f9c                	ld	a5,24(a5)
    80002f2e:	14179073          	csrw	sepc,a5
}
    80002f32:	60a2                	ld	ra,8(sp)
    80002f34:	6402                	ld	s0,0(sp)
    80002f36:	0141                	addi	sp,sp,16
    80002f38:	8082                	ret

0000000080002f3a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002f3a:	1141                	addi	sp,sp,-16
    80002f3c:	e406                	sd	ra,8(sp)
    80002f3e:	e022                	sd	s0,0(sp)
    80002f40:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002f42:	b7ffe0ef          	jal	80001ac0 <cpuid>
    80002f46:	c915                	beqz	a0,80002f7a <clockintr+0x40>
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  if (myproc() != 0 && myproc()->state == RUNNING) {
    80002f48:	badfe0ef          	jal	80001af4 <myproc>
    80002f4c:	c519                	beqz	a0,80002f5a <clockintr+0x20>
    80002f4e:	ba7fe0ef          	jal	80001af4 <myproc>
    80002f52:	4d18                	lw	a4,24(a0)
    80002f54:	4791                	li	a5,4
    80002f56:	04f70963          	beq	a4,a5,80002fa8 <clockintr+0x6e>
    update_cpu_temp(1);   // CPU is active
  } else {
    update_cpu_temp(0);   // CPU is idle
    80002f5a:	4501                	li	a0,0
    80002f5c:	98dfe0ef          	jal	800018e8 <update_cpu_temp>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002f60:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002f64:	000f4737          	lui	a4,0xf4
    80002f68:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002f6c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002f6e:	14d79073          	csrw	stimecmp,a5
}
    80002f72:	60a2                	ld	ra,8(sp)
    80002f74:	6402                	ld	s0,0(sp)
    80002f76:	0141                	addi	sp,sp,16
    80002f78:	8082                	ret
    acquire(&tickslock);
    80002f7a:	00017517          	auipc	a0,0x17
    80002f7e:	c0e50513          	addi	a0,a0,-1010 # 80019b88 <tickslock>
    80002f82:	ca7fd0ef          	jal	80000c28 <acquire>
    ticks++;
    80002f86:	00009717          	auipc	a4,0x9
    80002f8a:	95270713          	addi	a4,a4,-1710 # 8000b8d8 <ticks>
    80002f8e:	431c                	lw	a5,0(a4)
    80002f90:	2785                	addiw	a5,a5,1
    80002f92:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002f94:	853a                	mv	a0,a4
    80002f96:	857ff0ef          	jal	800027ec <wakeup>
    release(&tickslock);
    80002f9a:	00017517          	auipc	a0,0x17
    80002f9e:	bee50513          	addi	a0,a0,-1042 # 80019b88 <tickslock>
    80002fa2:	d1bfd0ef          	jal	80000cbc <release>
    80002fa6:	b74d                	j	80002f48 <clockintr+0xe>
    update_cpu_temp(1);   // CPU is active
    80002fa8:	4505                	li	a0,1
    80002faa:	93ffe0ef          	jal	800018e8 <update_cpu_temp>
    80002fae:	bf4d                	j	80002f60 <clockintr+0x26>

0000000080002fb0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fb8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002fbc:	57fd                	li	a5,-1
    80002fbe:	17fe                	slli	a5,a5,0x3f
    80002fc0:	07a5                	addi	a5,a5,9
    80002fc2:	00f70c63          	beq	a4,a5,80002fda <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002fc6:	57fd                	li	a5,-1
    80002fc8:	17fe                	slli	a5,a5,0x3f
    80002fca:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002fcc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002fce:	04f70863          	beq	a4,a5,8000301e <devintr+0x6e>
  }
}
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	6105                	addi	sp,sp,32
    80002fd8:	8082                	ret
    80002fda:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002fdc:	7b1020ef          	jal	80005f8c <plic_claim>
    80002fe0:	872a                	mv	a4,a0
    80002fe2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002fe4:	47a9                	li	a5,10
    80002fe6:	00f50963          	beq	a0,a5,80002ff8 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002fea:	4785                	li	a5,1
    80002fec:	00f50963          	beq	a0,a5,80002ffe <devintr+0x4e>
    return 1;
    80002ff0:	4505                	li	a0,1
    } else if(irq){
    80002ff2:	eb09                	bnez	a4,80003004 <devintr+0x54>
    80002ff4:	64a2                	ld	s1,8(sp)
    80002ff6:	bff1                	j	80002fd2 <devintr+0x22>
      uartintr();
    80002ff8:	9fdfd0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002ffc:	a819                	j	80003012 <devintr+0x62>
      virtio_disk_intr();
    80002ffe:	424030ef          	jal	80006422 <virtio_disk_intr>
    if(irq)
    80003002:	a801                	j	80003012 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80003004:	85ba                	mv	a1,a4
    80003006:	00005517          	auipc	a0,0x5
    8000300a:	6e250513          	addi	a0,a0,1762 # 800086e8 <etext+0x6e8>
    8000300e:	cecfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80003012:	8526                	mv	a0,s1
    80003014:	799020ef          	jal	80005fac <plic_complete>
    return 1;
    80003018:	4505                	li	a0,1
    8000301a:	64a2                	ld	s1,8(sp)
    8000301c:	bf5d                	j	80002fd2 <devintr+0x22>
    clockintr();
    8000301e:	f1dff0ef          	jal	80002f3a <clockintr>
    return 2;
    80003022:	4509                	li	a0,2
    80003024:	b77d                	j	80002fd2 <devintr+0x22>

0000000080003026 <usertrap>:
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	e04a                	sd	s2,0(sp)
    80003030:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003032:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003036:	1007f793          	andi	a5,a5,256
    8000303a:	eba5                	bnez	a5,800030aa <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000303c:	00003797          	auipc	a5,0x3
    80003040:	ea478793          	addi	a5,a5,-348 # 80005ee0 <kernelvec>
    80003044:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003048:	aadfe0ef          	jal	80001af4 <myproc>
    8000304c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000304e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003050:	14102773          	csrr	a4,sepc
    80003054:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003056:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000305a:	47a1                	li	a5,8
    8000305c:	04f70d63          	beq	a4,a5,800030b6 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80003060:	f51ff0ef          	jal	80002fb0 <devintr>
    80003064:	892a                	mv	s2,a0
    80003066:	e945                	bnez	a0,80003116 <usertrap+0xf0>
    80003068:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000306c:	47bd                	li	a5,15
    8000306e:	08f70863          	beq	a4,a5,800030fe <usertrap+0xd8>
    80003072:	14202773          	csrr	a4,scause
    80003076:	47b5                	li	a5,13
    80003078:	08f70363          	beq	a4,a5,800030fe <usertrap+0xd8>
    8000307c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80003080:	5890                	lw	a2,48(s1)
    80003082:	00005517          	auipc	a0,0x5
    80003086:	6a650513          	addi	a0,a0,1702 # 80008728 <etext+0x728>
    8000308a:	c70fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000308e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003092:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003096:	00005517          	auipc	a0,0x5
    8000309a:	6c250513          	addi	a0,a0,1730 # 80008758 <etext+0x758>
    8000309e:	c5cfd0ef          	jal	800004fa <printf>
    setkilled(p);
    800030a2:	8526                	mv	a0,s1
    800030a4:	915ff0ef          	jal	800029b8 <setkilled>
    800030a8:	a035                	j	800030d4 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800030aa:	00005517          	auipc	a0,0x5
    800030ae:	65e50513          	addi	a0,a0,1630 # 80008708 <etext+0x708>
    800030b2:	f72fd0ef          	jal	80000824 <panic>
    if(killed(p))
    800030b6:	927ff0ef          	jal	800029dc <killed>
    800030ba:	ed15                	bnez	a0,800030f6 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800030bc:	70b8                	ld	a4,96(s1)
    800030be:	6f1c                	ld	a5,24(a4)
    800030c0:	0791                	addi	a5,a5,4
    800030c2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800030c8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030cc:	10079073          	csrw	sstatus,a5
    syscall();
    800030d0:	240000ef          	jal	80003310 <syscall>
  if(killed(p))
    800030d4:	8526                	mv	a0,s1
    800030d6:	907ff0ef          	jal	800029dc <killed>
    800030da:	e139                	bnez	a0,80003120 <usertrap+0xfa>
  prepare_return();
    800030dc:	de5ff0ef          	jal	80002ec0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800030e0:	6ca8                	ld	a0,88(s1)
    800030e2:	8131                	srli	a0,a0,0xc
    800030e4:	57fd                	li	a5,-1
    800030e6:	17fe                	slli	a5,a5,0x3f
    800030e8:	8d5d                	or	a0,a0,a5
}
    800030ea:	60e2                	ld	ra,24(sp)
    800030ec:	6442                	ld	s0,16(sp)
    800030ee:	64a2                	ld	s1,8(sp)
    800030f0:	6902                	ld	s2,0(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret
      kexit(-1);
    800030f6:	557d                	li	a0,-1
    800030f8:	fb4ff0ef          	jal	800028ac <kexit>
    800030fc:	b7c1                	j	800030bc <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030fe:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003102:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80003106:	164d                	addi	a2,a2,-13
    80003108:	00163613          	seqz	a2,a2
    8000310c:	6ca8                	ld	a0,88(s1)
    8000310e:	cc2fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80003112:	f169                	bnez	a0,800030d4 <usertrap+0xae>
    80003114:	b7a5                	j	8000307c <usertrap+0x56>
  if(killed(p))
    80003116:	8526                	mv	a0,s1
    80003118:	8c5ff0ef          	jal	800029dc <killed>
    8000311c:	c511                	beqz	a0,80003128 <usertrap+0x102>
    8000311e:	a011                	j	80003122 <usertrap+0xfc>
    80003120:	4901                	li	s2,0
    kexit(-1);
    80003122:	557d                	li	a0,-1
    80003124:	f88ff0ef          	jal	800028ac <kexit>
  if(which_dev == 2)
    80003128:	4789                	li	a5,2
    8000312a:	faf919e3          	bne	s2,a5,800030dc <usertrap+0xb6>
    yield();
    8000312e:	e46ff0ef          	jal	80002774 <yield>
    80003132:	b76d                	j	800030dc <usertrap+0xb6>

0000000080003134 <kerneltrap>:
{
    80003134:	7179                	addi	sp,sp,-48
    80003136:	f406                	sd	ra,40(sp)
    80003138:	f022                	sd	s0,32(sp)
    8000313a:	ec26                	sd	s1,24(sp)
    8000313c:	e84a                	sd	s2,16(sp)
    8000313e:	e44e                	sd	s3,8(sp)
    80003140:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003142:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003146:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000314a:	142027f3          	csrr	a5,scause
    8000314e:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80003150:	1004f793          	andi	a5,s1,256
    80003154:	c795                	beqz	a5,80003180 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003156:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000315a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000315c:	eb85                	bnez	a5,8000318c <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    8000315e:	e53ff0ef          	jal	80002fb0 <devintr>
    80003162:	c91d                	beqz	a0,80003198 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80003164:	4789                	li	a5,2
    80003166:	04f50a63          	beq	a0,a5,800031ba <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000316a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000316e:	10049073          	csrw	sstatus,s1
}
    80003172:	70a2                	ld	ra,40(sp)
    80003174:	7402                	ld	s0,32(sp)
    80003176:	64e2                	ld	s1,24(sp)
    80003178:	6942                	ld	s2,16(sp)
    8000317a:	69a2                	ld	s3,8(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003180:	00005517          	auipc	a0,0x5
    80003184:	60050513          	addi	a0,a0,1536 # 80008780 <etext+0x780>
    80003188:	e9cfd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	61c50513          	addi	a0,a0,1564 # 800087a8 <etext+0x7a8>
    80003194:	e90fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003198:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000319c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800031a0:	85ce                	mv	a1,s3
    800031a2:	00005517          	auipc	a0,0x5
    800031a6:	62650513          	addi	a0,a0,1574 # 800087c8 <etext+0x7c8>
    800031aa:	b50fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800031ae:	00005517          	auipc	a0,0x5
    800031b2:	64250513          	addi	a0,a0,1602 # 800087f0 <etext+0x7f0>
    800031b6:	e6efd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    800031ba:	93bfe0ef          	jal	80001af4 <myproc>
    800031be:	d555                	beqz	a0,8000316a <kerneltrap+0x36>
    yield();
    800031c0:	db4ff0ef          	jal	80002774 <yield>
    800031c4:	b75d                	j	8000316a <kerneltrap+0x36>

00000000800031c6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	1000                	addi	s0,sp,32
    800031d0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031d2:	923fe0ef          	jal	80001af4 <myproc>
  switch (n) {
    800031d6:	4795                	li	a5,5
    800031d8:	0497e163          	bltu	a5,s1,8000321a <argraw+0x54>
    800031dc:	048a                	slli	s1,s1,0x2
    800031de:	00006717          	auipc	a4,0x6
    800031e2:	a3a70713          	addi	a4,a4,-1478 # 80008c18 <states.0+0x30>
    800031e6:	94ba                	add	s1,s1,a4
    800031e8:	409c                	lw	a5,0(s1)
    800031ea:	97ba                	add	a5,a5,a4
    800031ec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800031ee:	713c                	ld	a5,96(a0)
    800031f0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret
    return p->trapframe->a1;
    800031fc:	713c                	ld	a5,96(a0)
    800031fe:	7fa8                	ld	a0,120(a5)
    80003200:	bfcd                	j	800031f2 <argraw+0x2c>
    return p->trapframe->a2;
    80003202:	713c                	ld	a5,96(a0)
    80003204:	63c8                	ld	a0,128(a5)
    80003206:	b7f5                	j	800031f2 <argraw+0x2c>
    return p->trapframe->a3;
    80003208:	713c                	ld	a5,96(a0)
    8000320a:	67c8                	ld	a0,136(a5)
    8000320c:	b7dd                	j	800031f2 <argraw+0x2c>
    return p->trapframe->a4;
    8000320e:	713c                	ld	a5,96(a0)
    80003210:	6bc8                	ld	a0,144(a5)
    80003212:	b7c5                	j	800031f2 <argraw+0x2c>
    return p->trapframe->a5;
    80003214:	713c                	ld	a5,96(a0)
    80003216:	6fc8                	ld	a0,152(a5)
    80003218:	bfe9                	j	800031f2 <argraw+0x2c>
  panic("argraw");
    8000321a:	00005517          	auipc	a0,0x5
    8000321e:	5e650513          	addi	a0,a0,1510 # 80008800 <etext+0x800>
    80003222:	e02fd0ef          	jal	80000824 <panic>

0000000080003226 <fetchaddr>:
{
    80003226:	1101                	addi	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	e426                	sd	s1,8(sp)
    8000322e:	e04a                	sd	s2,0(sp)
    80003230:	1000                	addi	s0,sp,32
    80003232:	84aa                	mv	s1,a0
    80003234:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003236:	8bffe0ef          	jal	80001af4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000323a:	693c                	ld	a5,80(a0)
    8000323c:	02f4f663          	bgeu	s1,a5,80003268 <fetchaddr+0x42>
    80003240:	00848713          	addi	a4,s1,8
    80003244:	02e7e463          	bltu	a5,a4,8000326c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003248:	46a1                	li	a3,8
    8000324a:	8626                	mv	a2,s1
    8000324c:	85ca                	mv	a1,s2
    8000324e:	6d28                	ld	a0,88(a0)
    80003250:	cc2fe0ef          	jal	80001712 <copyin>
    80003254:	00a03533          	snez	a0,a0
    80003258:	40a0053b          	negw	a0,a0
}
    8000325c:	60e2                	ld	ra,24(sp)
    8000325e:	6442                	ld	s0,16(sp)
    80003260:	64a2                	ld	s1,8(sp)
    80003262:	6902                	ld	s2,0(sp)
    80003264:	6105                	addi	sp,sp,32
    80003266:	8082                	ret
    return -1;
    80003268:	557d                	li	a0,-1
    8000326a:	bfcd                	j	8000325c <fetchaddr+0x36>
    8000326c:	557d                	li	a0,-1
    8000326e:	b7fd                	j	8000325c <fetchaddr+0x36>

0000000080003270 <fetchstr>:
{
    80003270:	7179                	addi	sp,sp,-48
    80003272:	f406                	sd	ra,40(sp)
    80003274:	f022                	sd	s0,32(sp)
    80003276:	ec26                	sd	s1,24(sp)
    80003278:	e84a                	sd	s2,16(sp)
    8000327a:	e44e                	sd	s3,8(sp)
    8000327c:	1800                	addi	s0,sp,48
    8000327e:	89aa                	mv	s3,a0
    80003280:	84ae                	mv	s1,a1
    80003282:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80003284:	871fe0ef          	jal	80001af4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003288:	86ca                	mv	a3,s2
    8000328a:	864e                	mv	a2,s3
    8000328c:	85a6                	mv	a1,s1
    8000328e:	6d28                	ld	a0,88(a0)
    80003290:	a68fe0ef          	jal	800014f8 <copyinstr>
    80003294:	00054c63          	bltz	a0,800032ac <fetchstr+0x3c>
  return strlen(buf);
    80003298:	8526                	mv	a0,s1
    8000329a:	be9fd0ef          	jal	80000e82 <strlen>
}
    8000329e:	70a2                	ld	ra,40(sp)
    800032a0:	7402                	ld	s0,32(sp)
    800032a2:	64e2                	ld	s1,24(sp)
    800032a4:	6942                	ld	s2,16(sp)
    800032a6:	69a2                	ld	s3,8(sp)
    800032a8:	6145                	addi	sp,sp,48
    800032aa:	8082                	ret
    return -1;
    800032ac:	557d                	li	a0,-1
    800032ae:	bfc5                	j	8000329e <fetchstr+0x2e>

00000000800032b0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
    800032ba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032bc:	f0bff0ef          	jal	800031c6 <argraw>
    800032c0:	c088                	sw	a0,0(s1)
}
    800032c2:	60e2                	ld	ra,24(sp)
    800032c4:	6442                	ld	s0,16(sp)
    800032c6:	64a2                	ld	s1,8(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800032cc:	1101                	addi	sp,sp,-32
    800032ce:	ec06                	sd	ra,24(sp)
    800032d0:	e822                	sd	s0,16(sp)
    800032d2:	e426                	sd	s1,8(sp)
    800032d4:	1000                	addi	s0,sp,32
    800032d6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032d8:	eefff0ef          	jal	800031c6 <argraw>
    800032dc:	e088                	sd	a0,0(s1)
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6105                	addi	sp,sp,32
    800032e6:	8082                	ret

00000000800032e8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032e8:	1101                	addi	sp,sp,-32
    800032ea:	ec06                	sd	ra,24(sp)
    800032ec:	e822                	sd	s0,16(sp)
    800032ee:	e426                	sd	s1,8(sp)
    800032f0:	e04a                	sd	s2,0(sp)
    800032f2:	1000                	addi	s0,sp,32
    800032f4:	892e                	mv	s2,a1
    800032f6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800032f8:	ecfff0ef          	jal	800031c6 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800032fc:	8626                	mv	a2,s1
    800032fe:	85ca                	mv	a1,s2
    80003300:	f71ff0ef          	jal	80003270 <fetchstr>
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6902                	ld	s2,0(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret

0000000080003310 <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    80003310:	1101                	addi	sp,sp,-32
    80003312:	ec06                	sd	ra,24(sp)
    80003314:	e822                	sd	s0,16(sp)
    80003316:	e426                	sd	s1,8(sp)
    80003318:	e04a                	sd	s2,0(sp)
    8000331a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000331c:	fd8fe0ef          	jal	80001af4 <myproc>
    80003320:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003322:	06053903          	ld	s2,96(a0)
    80003326:	0a893783          	ld	a5,168(s2)
    8000332a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000332e:	37fd                	addiw	a5,a5,-1
    80003330:	4755                	li	a4,21
    80003332:	00f76f63          	bltu	a4,a5,80003350 <syscall+0x40>
    80003336:	00369713          	slli	a4,a3,0x3
    8000333a:	00006797          	auipc	a5,0x6
    8000333e:	8f678793          	addi	a5,a5,-1802 # 80008c30 <syscalls>
    80003342:	97ba                	add	a5,a5,a4
    80003344:	639c                	ld	a5,0(a5)
    80003346:	c789                	beqz	a5,80003350 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003348:	9782                	jalr	a5
    8000334a:	06a93823          	sd	a0,112(s2)
    8000334e:	a829                	j	80003368 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003350:	16048613          	addi	a2,s1,352
    80003354:	588c                	lw	a1,48(s1)
    80003356:	00005517          	auipc	a0,0x5
    8000335a:	4b250513          	addi	a0,a0,1202 # 80008808 <etext+0x808>
    8000335e:	99cfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003362:	70bc                	ld	a5,96(s1)
    80003364:	577d                	li	a4,-1
    80003366:	fbb8                	sd	a4,112(a5)
  }
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	6105                	addi	sp,sp,32
    80003372:	8082                	ret

0000000080003374 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80003374:	1101                	addi	sp,sp,-32
    80003376:	ec06                	sd	ra,24(sp)
    80003378:	e822                	sd	s0,16(sp)
    8000337a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000337c:	fec40593          	addi	a1,s0,-20
    80003380:	4501                	li	a0,0
    80003382:	f2fff0ef          	jal	800032b0 <argint>
  kexit(n);
    80003386:	fec42503          	lw	a0,-20(s0)
    8000338a:	d22ff0ef          	jal	800028ac <kexit>
  return 0;  // not reached
}
    8000338e:	4501                	li	a0,0
    80003390:	60e2                	ld	ra,24(sp)
    80003392:	6442                	ld	s0,16(sp)
    80003394:	6105                	addi	sp,sp,32
    80003396:	8082                	ret

0000000080003398 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003398:	1141                	addi	sp,sp,-16
    8000339a:	e406                	sd	ra,8(sp)
    8000339c:	e022                	sd	s0,0(sp)
    8000339e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033a0:	f54fe0ef          	jal	80001af4 <myproc>
}
    800033a4:	5908                	lw	a0,48(a0)
    800033a6:	60a2                	ld	ra,8(sp)
    800033a8:	6402                	ld	s0,0(sp)
    800033aa:	0141                	addi	sp,sp,16
    800033ac:	8082                	ret

00000000800033ae <sys_fork>:

uint64
sys_fork(void)
{
    800033ae:	1141                	addi	sp,sp,-16
    800033b0:	e406                	sd	ra,8(sp)
    800033b2:	e022                	sd	s0,0(sp)
    800033b4:	0800                	addi	s0,sp,16
  return kfork();
    800033b6:	ab5fe0ef          	jal	80001e6a <kfork>
}
    800033ba:	60a2                	ld	ra,8(sp)
    800033bc:	6402                	ld	s0,0(sp)
    800033be:	0141                	addi	sp,sp,16
    800033c0:	8082                	ret

00000000800033c2 <sys_wait>:

uint64
sys_wait(void)
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033ca:	fe840593          	addi	a1,s0,-24
    800033ce:	4501                	li	a0,0
    800033d0:	efdff0ef          	jal	800032cc <argaddr>
  return kwait(p);
    800033d4:	fe843503          	ld	a0,-24(s0)
    800033d8:	e2eff0ef          	jal	80002a06 <kwait>
}
    800033dc:	60e2                	ld	ra,24(sp)
    800033de:	6442                	ld	s0,16(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret

00000000800033e4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033e4:	7179                	addi	sp,sp,-48
    800033e6:	f406                	sd	ra,40(sp)
    800033e8:	f022                	sd	s0,32(sp)
    800033ea:	ec26                	sd	s1,24(sp)
    800033ec:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800033ee:	fd840593          	addi	a1,s0,-40
    800033f2:	4501                	li	a0,0
    800033f4:	ebdff0ef          	jal	800032b0 <argint>
  argint(1, &t);
    800033f8:	fdc40593          	addi	a1,s0,-36
    800033fc:	4505                	li	a0,1
    800033fe:	eb3ff0ef          	jal	800032b0 <argint>
  addr = myproc()->sz;
    80003402:	ef2fe0ef          	jal	80001af4 <myproc>
    80003406:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80003408:	fdc42703          	lw	a4,-36(s0)
    8000340c:	4785                	li	a5,1
    8000340e:	02f70763          	beq	a4,a5,8000343c <sys_sbrk+0x58>
    80003412:	fd842783          	lw	a5,-40(s0)
    80003416:	0207c363          	bltz	a5,8000343c <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000341a:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    8000341c:	02000737          	lui	a4,0x2000
    80003420:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80003422:	0736                	slli	a4,a4,0xd
    80003424:	02f76a63          	bltu	a4,a5,80003458 <sys_sbrk+0x74>
    80003428:	0297e863          	bltu	a5,s1,80003458 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    8000342c:	ec8fe0ef          	jal	80001af4 <myproc>
    80003430:	fd842703          	lw	a4,-40(s0)
    80003434:	693c                	ld	a5,80(a0)
    80003436:	97ba                	add	a5,a5,a4
    80003438:	e93c                	sd	a5,80(a0)
    8000343a:	a039                	j	80003448 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000343c:	fd842503          	lw	a0,-40(s0)
    80003440:	9c9fe0ef          	jal	80001e08 <growproc>
    80003444:	00054863          	bltz	a0,80003454 <sys_sbrk+0x70>
  }
  return addr;
}
    80003448:	8526                	mv	a0,s1
    8000344a:	70a2                	ld	ra,40(sp)
    8000344c:	7402                	ld	s0,32(sp)
    8000344e:	64e2                	ld	s1,24(sp)
    80003450:	6145                	addi	sp,sp,48
    80003452:	8082                	ret
      return -1;
    80003454:	54fd                	li	s1,-1
    80003456:	bfcd                	j	80003448 <sys_sbrk+0x64>
      return -1;
    80003458:	54fd                	li	s1,-1
    8000345a:	b7fd                	j	80003448 <sys_sbrk+0x64>

000000008000345c <sys_pause>:

uint64
sys_pause(void)
{
    8000345c:	7139                	addi	sp,sp,-64
    8000345e:	fc06                	sd	ra,56(sp)
    80003460:	f822                	sd	s0,48(sp)
    80003462:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003464:	fcc40593          	addi	a1,s0,-52
    80003468:	4501                	li	a0,0
    8000346a:	e47ff0ef          	jal	800032b0 <argint>
  if(n < 0)
    8000346e:	fcc42783          	lw	a5,-52(s0)
    80003472:	0607c863          	bltz	a5,800034e2 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003476:	00016517          	auipc	a0,0x16
    8000347a:	71250513          	addi	a0,a0,1810 # 80019b88 <tickslock>
    8000347e:	faafd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80003482:	fcc42783          	lw	a5,-52(s0)
    80003486:	c3b9                	beqz	a5,800034cc <sys_pause+0x70>
    80003488:	f426                	sd	s1,40(sp)
    8000348a:	f04a                	sd	s2,32(sp)
    8000348c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    8000348e:	00008997          	auipc	s3,0x8
    80003492:	44a9a983          	lw	s3,1098(s3) # 8000b8d8 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003496:	00016917          	auipc	s2,0x16
    8000349a:	6f290913          	addi	s2,s2,1778 # 80019b88 <tickslock>
    8000349e:	00008497          	auipc	s1,0x8
    800034a2:	43a48493          	addi	s1,s1,1082 # 8000b8d8 <ticks>
    if(killed(myproc())){
    800034a6:	e4efe0ef          	jal	80001af4 <myproc>
    800034aa:	d32ff0ef          	jal	800029dc <killed>
    800034ae:	ed0d                	bnez	a0,800034e8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800034b0:	85ca                	mv	a1,s2
    800034b2:	8526                	mv	a0,s1
    800034b4:	aecff0ef          	jal	800027a0 <sleep>
  while(ticks - ticks0 < n){
    800034b8:	409c                	lw	a5,0(s1)
    800034ba:	413787bb          	subw	a5,a5,s3
    800034be:	fcc42703          	lw	a4,-52(s0)
    800034c2:	fee7e2e3          	bltu	a5,a4,800034a6 <sys_pause+0x4a>
    800034c6:	74a2                	ld	s1,40(sp)
    800034c8:	7902                	ld	s2,32(sp)
    800034ca:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800034cc:	00016517          	auipc	a0,0x16
    800034d0:	6bc50513          	addi	a0,a0,1724 # 80019b88 <tickslock>
    800034d4:	fe8fd0ef          	jal	80000cbc <release>
  return 0;
    800034d8:	4501                	li	a0,0
}
    800034da:	70e2                	ld	ra,56(sp)
    800034dc:	7442                	ld	s0,48(sp)
    800034de:	6121                	addi	sp,sp,64
    800034e0:	8082                	ret
    n = 0;
    800034e2:	fc042623          	sw	zero,-52(s0)
    800034e6:	bf41                	j	80003476 <sys_pause+0x1a>
      release(&tickslock);
    800034e8:	00016517          	auipc	a0,0x16
    800034ec:	6a050513          	addi	a0,a0,1696 # 80019b88 <tickslock>
    800034f0:	fccfd0ef          	jal	80000cbc <release>
      return -1;
    800034f4:	557d                	li	a0,-1
    800034f6:	74a2                	ld	s1,40(sp)
    800034f8:	7902                	ld	s2,32(sp)
    800034fa:	69e2                	ld	s3,24(sp)
    800034fc:	bff9                	j	800034da <sys_pause+0x7e>

00000000800034fe <sys_kill>:

uint64
sys_kill(void)
{
    800034fe:	1101                	addi	sp,sp,-32
    80003500:	ec06                	sd	ra,24(sp)
    80003502:	e822                	sd	s0,16(sp)
    80003504:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003506:	fec40593          	addi	a1,s0,-20
    8000350a:	4501                	li	a0,0
    8000350c:	da5ff0ef          	jal	800032b0 <argint>
  return kkill(pid);
    80003510:	fec42503          	lw	a0,-20(s0)
    80003514:	c3eff0ef          	jal	80002952 <kkill>
}
    80003518:	60e2                	ld	ra,24(sp)
    8000351a:	6442                	ld	s0,16(sp)
    8000351c:	6105                	addi	sp,sp,32
    8000351e:	8082                	ret

0000000080003520 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003520:	1101                	addi	sp,sp,-32
    80003522:	ec06                	sd	ra,24(sp)
    80003524:	e822                	sd	s0,16(sp)
    80003526:	e426                	sd	s1,8(sp)
    80003528:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000352a:	00016517          	auipc	a0,0x16
    8000352e:	65e50513          	addi	a0,a0,1630 # 80019b88 <tickslock>
    80003532:	ef6fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80003536:	00008797          	auipc	a5,0x8
    8000353a:	3a27a783          	lw	a5,930(a5) # 8000b8d8 <ticks>
    8000353e:	84be                	mv	s1,a5
  release(&tickslock);
    80003540:	00016517          	auipc	a0,0x16
    80003544:	64850513          	addi	a0,a0,1608 # 80019b88 <tickslock>
    80003548:	f74fd0ef          	jal	80000cbc <release>
  return xticks;
}
    8000354c:	02049513          	slli	a0,s1,0x20
    80003550:	9101                	srli	a0,a0,0x20
    80003552:	60e2                	ld	ra,24(sp)
    80003554:	6442                	ld	s0,16(sp)
    80003556:	64a2                	ld	s1,8(sp)
    80003558:	6105                	addi	sp,sp,32
    8000355a:	8082                	ret

000000008000355c <sys_kps>:

uint64
sys_kps(void)
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003564:	4611                	li	a2,4
    80003566:	fe840593          	addi	a1,s0,-24
    8000356a:	4501                	li	a0,0
    8000356c:	d7dff0ef          	jal	800032e8 <argstr>
    80003570:	87aa                	mv	a5,a0
    return -1;
    80003572:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80003574:	0007c663          	bltz	a5,80003580 <sys_kps+0x24>

  return kps(buffer);
    80003578:	fe840513          	addi	a0,s0,-24
    8000357c:	ebaff0ef          	jal	80002c36 <kps>
    80003580:	60e2                	ld	ra,24(sp)
    80003582:	6442                	ld	s0,16(sp)
    80003584:	6105                	addi	sp,sp,32
    80003586:	8082                	ret

0000000080003588 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003588:	7179                	addi	sp,sp,-48
    8000358a:	f406                	sd	ra,40(sp)
    8000358c:	f022                	sd	s0,32(sp)
    8000358e:	ec26                	sd	s1,24(sp)
    80003590:	e84a                	sd	s2,16(sp)
    80003592:	e44e                	sd	s3,8(sp)
    80003594:	e052                	sd	s4,0(sp)
    80003596:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003598:	00005597          	auipc	a1,0x5
    8000359c:	29058593          	addi	a1,a1,656 # 80008828 <etext+0x828>
    800035a0:	00016517          	auipc	a0,0x16
    800035a4:	60050513          	addi	a0,a0,1536 # 80019ba0 <bcache>
    800035a8:	df6fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035ac:	0001e797          	auipc	a5,0x1e
    800035b0:	5f478793          	addi	a5,a5,1524 # 80021ba0 <bcache+0x8000>
    800035b4:	0001f717          	auipc	a4,0x1f
    800035b8:	85470713          	addi	a4,a4,-1964 # 80021e08 <bcache+0x8268>
    800035bc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800035c0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035c4:	00016497          	auipc	s1,0x16
    800035c8:	5f448493          	addi	s1,s1,1524 # 80019bb8 <bcache+0x18>
    b->next = bcache.head.next;
    800035cc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035ce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035d0:	00005a17          	auipc	s4,0x5
    800035d4:	260a0a13          	addi	s4,s4,608 # 80008830 <etext+0x830>
    b->next = bcache.head.next;
    800035d8:	2b893783          	ld	a5,696(s2)
    800035dc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800035de:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800035e2:	85d2                	mv	a1,s4
    800035e4:	01048513          	addi	a0,s1,16
    800035e8:	328010ef          	jal	80004910 <initsleeplock>
    bcache.head.next->prev = b;
    800035ec:	2b893783          	ld	a5,696(s2)
    800035f0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035f2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035f6:	45848493          	addi	s1,s1,1112
    800035fa:	fd349fe3          	bne	s1,s3,800035d8 <binit+0x50>
  }
}
    800035fe:	70a2                	ld	ra,40(sp)
    80003600:	7402                	ld	s0,32(sp)
    80003602:	64e2                	ld	s1,24(sp)
    80003604:	6942                	ld	s2,16(sp)
    80003606:	69a2                	ld	s3,8(sp)
    80003608:	6a02                	ld	s4,0(sp)
    8000360a:	6145                	addi	sp,sp,48
    8000360c:	8082                	ret

000000008000360e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000360e:	7179                	addi	sp,sp,-48
    80003610:	f406                	sd	ra,40(sp)
    80003612:	f022                	sd	s0,32(sp)
    80003614:	ec26                	sd	s1,24(sp)
    80003616:	e84a                	sd	s2,16(sp)
    80003618:	e44e                	sd	s3,8(sp)
    8000361a:	1800                	addi	s0,sp,48
    8000361c:	892a                	mv	s2,a0
    8000361e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003620:	00016517          	auipc	a0,0x16
    80003624:	58050513          	addi	a0,a0,1408 # 80019ba0 <bcache>
    80003628:	e00fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000362c:	0001f497          	auipc	s1,0x1f
    80003630:	82c4b483          	ld	s1,-2004(s1) # 80021e58 <bcache+0x82b8>
    80003634:	0001e797          	auipc	a5,0x1e
    80003638:	7d478793          	addi	a5,a5,2004 # 80021e08 <bcache+0x8268>
    8000363c:	02f48b63          	beq	s1,a5,80003672 <bread+0x64>
    80003640:	873e                	mv	a4,a5
    80003642:	a021                	j	8000364a <bread+0x3c>
    80003644:	68a4                	ld	s1,80(s1)
    80003646:	02e48663          	beq	s1,a4,80003672 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000364a:	449c                	lw	a5,8(s1)
    8000364c:	ff279ce3          	bne	a5,s2,80003644 <bread+0x36>
    80003650:	44dc                	lw	a5,12(s1)
    80003652:	ff3799e3          	bne	a5,s3,80003644 <bread+0x36>
      b->refcnt++;
    80003656:	40bc                	lw	a5,64(s1)
    80003658:	2785                	addiw	a5,a5,1
    8000365a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000365c:	00016517          	auipc	a0,0x16
    80003660:	54450513          	addi	a0,a0,1348 # 80019ba0 <bcache>
    80003664:	e58fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80003668:	01048513          	addi	a0,s1,16
    8000366c:	2da010ef          	jal	80004946 <acquiresleep>
      return b;
    80003670:	a889                	j	800036c2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003672:	0001e497          	auipc	s1,0x1e
    80003676:	7de4b483          	ld	s1,2014(s1) # 80021e50 <bcache+0x82b0>
    8000367a:	0001e797          	auipc	a5,0x1e
    8000367e:	78e78793          	addi	a5,a5,1934 # 80021e08 <bcache+0x8268>
    80003682:	00f48863          	beq	s1,a5,80003692 <bread+0x84>
    80003686:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003688:	40bc                	lw	a5,64(s1)
    8000368a:	cb91                	beqz	a5,8000369e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000368c:	64a4                	ld	s1,72(s1)
    8000368e:	fee49de3          	bne	s1,a4,80003688 <bread+0x7a>
  panic("bget: no buffers");
    80003692:	00005517          	auipc	a0,0x5
    80003696:	1a650513          	addi	a0,a0,422 # 80008838 <etext+0x838>
    8000369a:	98afd0ef          	jal	80000824 <panic>
      b->dev = dev;
    8000369e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800036a2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800036a6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036aa:	4785                	li	a5,1
    800036ac:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036ae:	00016517          	auipc	a0,0x16
    800036b2:	4f250513          	addi	a0,a0,1266 # 80019ba0 <bcache>
    800036b6:	e06fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    800036ba:	01048513          	addi	a0,s1,16
    800036be:	288010ef          	jal	80004946 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036c2:	409c                	lw	a5,0(s1)
    800036c4:	cb89                	beqz	a5,800036d6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800036c6:	8526                	mv	a0,s1
    800036c8:	70a2                	ld	ra,40(sp)
    800036ca:	7402                	ld	s0,32(sp)
    800036cc:	64e2                	ld	s1,24(sp)
    800036ce:	6942                	ld	s2,16(sp)
    800036d0:	69a2                	ld	s3,8(sp)
    800036d2:	6145                	addi	sp,sp,48
    800036d4:	8082                	ret
    virtio_disk_rw(b, 0);
    800036d6:	4581                	li	a1,0
    800036d8:	8526                	mv	a0,s1
    800036da:	337020ef          	jal	80006210 <virtio_disk_rw>
    b->valid = 1;
    800036de:	4785                	li	a5,1
    800036e0:	c09c                	sw	a5,0(s1)
  return b;
    800036e2:	b7d5                	j	800036c6 <bread+0xb8>

00000000800036e4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036e4:	1101                	addi	sp,sp,-32
    800036e6:	ec06                	sd	ra,24(sp)
    800036e8:	e822                	sd	s0,16(sp)
    800036ea:	e426                	sd	s1,8(sp)
    800036ec:	1000                	addi	s0,sp,32
    800036ee:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036f0:	0541                	addi	a0,a0,16
    800036f2:	2d2010ef          	jal	800049c4 <holdingsleep>
    800036f6:	c911                	beqz	a0,8000370a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036f8:	4585                	li	a1,1
    800036fa:	8526                	mv	a0,s1
    800036fc:	315020ef          	jal	80006210 <virtio_disk_rw>
}
    80003700:	60e2                	ld	ra,24(sp)
    80003702:	6442                	ld	s0,16(sp)
    80003704:	64a2                	ld	s1,8(sp)
    80003706:	6105                	addi	sp,sp,32
    80003708:	8082                	ret
    panic("bwrite");
    8000370a:	00005517          	auipc	a0,0x5
    8000370e:	14650513          	addi	a0,a0,326 # 80008850 <etext+0x850>
    80003712:	912fd0ef          	jal	80000824 <panic>

0000000080003716 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003716:	1101                	addi	sp,sp,-32
    80003718:	ec06                	sd	ra,24(sp)
    8000371a:	e822                	sd	s0,16(sp)
    8000371c:	e426                	sd	s1,8(sp)
    8000371e:	e04a                	sd	s2,0(sp)
    80003720:	1000                	addi	s0,sp,32
    80003722:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003724:	01050913          	addi	s2,a0,16
    80003728:	854a                	mv	a0,s2
    8000372a:	29a010ef          	jal	800049c4 <holdingsleep>
    8000372e:	c125                	beqz	a0,8000378e <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003730:	854a                	mv	a0,s2
    80003732:	25a010ef          	jal	8000498c <releasesleep>

  acquire(&bcache.lock);
    80003736:	00016517          	auipc	a0,0x16
    8000373a:	46a50513          	addi	a0,a0,1130 # 80019ba0 <bcache>
    8000373e:	ceafd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003742:	40bc                	lw	a5,64(s1)
    80003744:	37fd                	addiw	a5,a5,-1
    80003746:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003748:	e79d                	bnez	a5,80003776 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000374a:	68b8                	ld	a4,80(s1)
    8000374c:	64bc                	ld	a5,72(s1)
    8000374e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003750:	68b8                	ld	a4,80(s1)
    80003752:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003754:	0001e797          	auipc	a5,0x1e
    80003758:	44c78793          	addi	a5,a5,1100 # 80021ba0 <bcache+0x8000>
    8000375c:	2b87b703          	ld	a4,696(a5)
    80003760:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003762:	0001e717          	auipc	a4,0x1e
    80003766:	6a670713          	addi	a4,a4,1702 # 80021e08 <bcache+0x8268>
    8000376a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000376c:	2b87b703          	ld	a4,696(a5)
    80003770:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003772:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003776:	00016517          	auipc	a0,0x16
    8000377a:	42a50513          	addi	a0,a0,1066 # 80019ba0 <bcache>
    8000377e:	d3efd0ef          	jal	80000cbc <release>
}
    80003782:	60e2                	ld	ra,24(sp)
    80003784:	6442                	ld	s0,16(sp)
    80003786:	64a2                	ld	s1,8(sp)
    80003788:	6902                	ld	s2,0(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret
    panic("brelse");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	0ca50513          	addi	a0,a0,202 # 80008858 <etext+0x858>
    80003796:	88efd0ef          	jal	80000824 <panic>

000000008000379a <bpin>:

void
bpin(struct buf *b) {
    8000379a:	1101                	addi	sp,sp,-32
    8000379c:	ec06                	sd	ra,24(sp)
    8000379e:	e822                	sd	s0,16(sp)
    800037a0:	e426                	sd	s1,8(sp)
    800037a2:	1000                	addi	s0,sp,32
    800037a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037a6:	00016517          	auipc	a0,0x16
    800037aa:	3fa50513          	addi	a0,a0,1018 # 80019ba0 <bcache>
    800037ae:	c7afd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    800037b2:	40bc                	lw	a5,64(s1)
    800037b4:	2785                	addiw	a5,a5,1
    800037b6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037b8:	00016517          	auipc	a0,0x16
    800037bc:	3e850513          	addi	a0,a0,1000 # 80019ba0 <bcache>
    800037c0:	cfcfd0ef          	jal	80000cbc <release>
}
    800037c4:	60e2                	ld	ra,24(sp)
    800037c6:	6442                	ld	s0,16(sp)
    800037c8:	64a2                	ld	s1,8(sp)
    800037ca:	6105                	addi	sp,sp,32
    800037cc:	8082                	ret

00000000800037ce <bunpin>:

void
bunpin(struct buf *b) {
    800037ce:	1101                	addi	sp,sp,-32
    800037d0:	ec06                	sd	ra,24(sp)
    800037d2:	e822                	sd	s0,16(sp)
    800037d4:	e426                	sd	s1,8(sp)
    800037d6:	1000                	addi	s0,sp,32
    800037d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037da:	00016517          	auipc	a0,0x16
    800037de:	3c650513          	addi	a0,a0,966 # 80019ba0 <bcache>
    800037e2:	c46fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800037e6:	40bc                	lw	a5,64(s1)
    800037e8:	37fd                	addiw	a5,a5,-1
    800037ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037ec:	00016517          	auipc	a0,0x16
    800037f0:	3b450513          	addi	a0,a0,948 # 80019ba0 <bcache>
    800037f4:	cc8fd0ef          	jal	80000cbc <release>
}
    800037f8:	60e2                	ld	ra,24(sp)
    800037fa:	6442                	ld	s0,16(sp)
    800037fc:	64a2                	ld	s1,8(sp)
    800037fe:	6105                	addi	sp,sp,32
    80003800:	8082                	ret

0000000080003802 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003802:	1101                	addi	sp,sp,-32
    80003804:	ec06                	sd	ra,24(sp)
    80003806:	e822                	sd	s0,16(sp)
    80003808:	e426                	sd	s1,8(sp)
    8000380a:	e04a                	sd	s2,0(sp)
    8000380c:	1000                	addi	s0,sp,32
    8000380e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003810:	00d5d79b          	srliw	a5,a1,0xd
    80003814:	0001f597          	auipc	a1,0x1f
    80003818:	a685a583          	lw	a1,-1432(a1) # 8002227c <sb+0x1c>
    8000381c:	9dbd                	addw	a1,a1,a5
    8000381e:	df1ff0ef          	jal	8000360e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003822:	0074f713          	andi	a4,s1,7
    80003826:	4785                	li	a5,1
    80003828:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000382c:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000382e:	90d9                	srli	s1,s1,0x36
    80003830:	00950733          	add	a4,a0,s1
    80003834:	05874703          	lbu	a4,88(a4)
    80003838:	00e7f6b3          	and	a3,a5,a4
    8000383c:	c29d                	beqz	a3,80003862 <bfree+0x60>
    8000383e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003840:	94aa                	add	s1,s1,a0
    80003842:	fff7c793          	not	a5,a5
    80003846:	8f7d                	and	a4,a4,a5
    80003848:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000384c:	000010ef          	jal	8000484c <log_write>
  brelse(bp);
    80003850:	854a                	mv	a0,s2
    80003852:	ec5ff0ef          	jal	80003716 <brelse>
}
    80003856:	60e2                	ld	ra,24(sp)
    80003858:	6442                	ld	s0,16(sp)
    8000385a:	64a2                	ld	s1,8(sp)
    8000385c:	6902                	ld	s2,0(sp)
    8000385e:	6105                	addi	sp,sp,32
    80003860:	8082                	ret
    panic("freeing free block");
    80003862:	00005517          	auipc	a0,0x5
    80003866:	ffe50513          	addi	a0,a0,-2 # 80008860 <etext+0x860>
    8000386a:	fbbfc0ef          	jal	80000824 <panic>

000000008000386e <balloc>:
{
    8000386e:	715d                	addi	sp,sp,-80
    80003870:	e486                	sd	ra,72(sp)
    80003872:	e0a2                	sd	s0,64(sp)
    80003874:	fc26                	sd	s1,56(sp)
    80003876:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003878:	0001f797          	auipc	a5,0x1f
    8000387c:	9ec7a783          	lw	a5,-1556(a5) # 80022264 <sb+0x4>
    80003880:	0e078263          	beqz	a5,80003964 <balloc+0xf6>
    80003884:	f84a                	sd	s2,48(sp)
    80003886:	f44e                	sd	s3,40(sp)
    80003888:	f052                	sd	s4,32(sp)
    8000388a:	ec56                	sd	s5,24(sp)
    8000388c:	e85a                	sd	s6,16(sp)
    8000388e:	e45e                	sd	s7,8(sp)
    80003890:	e062                	sd	s8,0(sp)
    80003892:	8baa                	mv	s7,a0
    80003894:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003896:	0001fb17          	auipc	s6,0x1f
    8000389a:	9cab0b13          	addi	s6,s6,-1590 # 80022260 <sb>
      m = 1 << (bi % 8);
    8000389e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038a2:	6c09                	lui	s8,0x2
    800038a4:	a09d                	j	8000390a <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038a6:	97ca                	add	a5,a5,s2
    800038a8:	8e55                	or	a2,a2,a3
    800038aa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038ae:	854a                	mv	a0,s2
    800038b0:	79d000ef          	jal	8000484c <log_write>
        brelse(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	e61ff0ef          	jal	80003716 <brelse>
  bp = bread(dev, bno);
    800038ba:	85a6                	mv	a1,s1
    800038bc:	855e                	mv	a0,s7
    800038be:	d51ff0ef          	jal	8000360e <bread>
    800038c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038c4:	40000613          	li	a2,1024
    800038c8:	4581                	li	a1,0
    800038ca:	05850513          	addi	a0,a0,88
    800038ce:	c2afd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    800038d2:	854a                	mv	a0,s2
    800038d4:	779000ef          	jal	8000484c <log_write>
  brelse(bp);
    800038d8:	854a                	mv	a0,s2
    800038da:	e3dff0ef          	jal	80003716 <brelse>
}
    800038de:	7942                	ld	s2,48(sp)
    800038e0:	79a2                	ld	s3,40(sp)
    800038e2:	7a02                	ld	s4,32(sp)
    800038e4:	6ae2                	ld	s5,24(sp)
    800038e6:	6b42                	ld	s6,16(sp)
    800038e8:	6ba2                	ld	s7,8(sp)
    800038ea:	6c02                	ld	s8,0(sp)
}
    800038ec:	8526                	mv	a0,s1
    800038ee:	60a6                	ld	ra,72(sp)
    800038f0:	6406                	ld	s0,64(sp)
    800038f2:	74e2                	ld	s1,56(sp)
    800038f4:	6161                	addi	sp,sp,80
    800038f6:	8082                	ret
    brelse(bp);
    800038f8:	854a                	mv	a0,s2
    800038fa:	e1dff0ef          	jal	80003716 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038fe:	015c0abb          	addw	s5,s8,s5
    80003902:	004b2783          	lw	a5,4(s6)
    80003906:	04faf863          	bgeu	s5,a5,80003956 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000390a:	40dad59b          	sraiw	a1,s5,0xd
    8000390e:	01cb2783          	lw	a5,28(s6)
    80003912:	9dbd                	addw	a1,a1,a5
    80003914:	855e                	mv	a0,s7
    80003916:	cf9ff0ef          	jal	8000360e <bread>
    8000391a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000391c:	004b2503          	lw	a0,4(s6)
    80003920:	84d6                	mv	s1,s5
    80003922:	4701                	li	a4,0
    80003924:	fca4fae3          	bgeu	s1,a0,800038f8 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003928:	00777693          	andi	a3,a4,7
    8000392c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003930:	41f7579b          	sraiw	a5,a4,0x1f
    80003934:	01d7d79b          	srliw	a5,a5,0x1d
    80003938:	9fb9                	addw	a5,a5,a4
    8000393a:	4037d79b          	sraiw	a5,a5,0x3
    8000393e:	00f90633          	add	a2,s2,a5
    80003942:	05864603          	lbu	a2,88(a2)
    80003946:	00c6f5b3          	and	a1,a3,a2
    8000394a:	ddb1                	beqz	a1,800038a6 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000394c:	2705                	addiw	a4,a4,1
    8000394e:	2485                	addiw	s1,s1,1
    80003950:	fd471ae3          	bne	a4,s4,80003924 <balloc+0xb6>
    80003954:	b755                	j	800038f8 <balloc+0x8a>
    80003956:	7942                	ld	s2,48(sp)
    80003958:	79a2                	ld	s3,40(sp)
    8000395a:	7a02                	ld	s4,32(sp)
    8000395c:	6ae2                	ld	s5,24(sp)
    8000395e:	6b42                	ld	s6,16(sp)
    80003960:	6ba2                	ld	s7,8(sp)
    80003962:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003964:	00005517          	auipc	a0,0x5
    80003968:	f1450513          	addi	a0,a0,-236 # 80008878 <etext+0x878>
    8000396c:	b8ffc0ef          	jal	800004fa <printf>
  return 0;
    80003970:	4481                	li	s1,0
    80003972:	bfad                	j	800038ec <balloc+0x7e>

0000000080003974 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003974:	7179                	addi	sp,sp,-48
    80003976:	f406                	sd	ra,40(sp)
    80003978:	f022                	sd	s0,32(sp)
    8000397a:	ec26                	sd	s1,24(sp)
    8000397c:	e84a                	sd	s2,16(sp)
    8000397e:	e44e                	sd	s3,8(sp)
    80003980:	1800                	addi	s0,sp,48
    80003982:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003984:	47ad                	li	a5,11
    80003986:	02b7e363          	bltu	a5,a1,800039ac <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000398a:	02059793          	slli	a5,a1,0x20
    8000398e:	01e7d593          	srli	a1,a5,0x1e
    80003992:	00b509b3          	add	s3,a0,a1
    80003996:	0509a483          	lw	s1,80(s3)
    8000399a:	e0b5                	bnez	s1,800039fe <bmap+0x8a>
      addr = balloc(ip->dev);
    8000399c:	4108                	lw	a0,0(a0)
    8000399e:	ed1ff0ef          	jal	8000386e <balloc>
    800039a2:	84aa                	mv	s1,a0
      if(addr == 0)
    800039a4:	cd29                	beqz	a0,800039fe <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800039a6:	04a9a823          	sw	a0,80(s3)
    800039aa:	a891                	j	800039fe <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039ac:	ff45879b          	addiw	a5,a1,-12
    800039b0:	873e                	mv	a4,a5
    800039b2:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800039b4:	0ff00793          	li	a5,255
    800039b8:	06e7e763          	bltu	a5,a4,80003a26 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800039bc:	08052483          	lw	s1,128(a0)
    800039c0:	e891                	bnez	s1,800039d4 <bmap+0x60>
      addr = balloc(ip->dev);
    800039c2:	4108                	lw	a0,0(a0)
    800039c4:	eabff0ef          	jal	8000386e <balloc>
    800039c8:	84aa                	mv	s1,a0
      if(addr == 0)
    800039ca:	c915                	beqz	a0,800039fe <bmap+0x8a>
    800039cc:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800039ce:	08a92023          	sw	a0,128(s2)
    800039d2:	a011                	j	800039d6 <bmap+0x62>
    800039d4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800039d6:	85a6                	mv	a1,s1
    800039d8:	00092503          	lw	a0,0(s2)
    800039dc:	c33ff0ef          	jal	8000360e <bread>
    800039e0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039e2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800039e6:	02099713          	slli	a4,s3,0x20
    800039ea:	01e75593          	srli	a1,a4,0x1e
    800039ee:	97ae                	add	a5,a5,a1
    800039f0:	89be                	mv	s3,a5
    800039f2:	4384                	lw	s1,0(a5)
    800039f4:	cc89                	beqz	s1,80003a0e <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800039f6:	8552                	mv	a0,s4
    800039f8:	d1fff0ef          	jal	80003716 <brelse>
    return addr;
    800039fc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800039fe:	8526                	mv	a0,s1
    80003a00:	70a2                	ld	ra,40(sp)
    80003a02:	7402                	ld	s0,32(sp)
    80003a04:	64e2                	ld	s1,24(sp)
    80003a06:	6942                	ld	s2,16(sp)
    80003a08:	69a2                	ld	s3,8(sp)
    80003a0a:	6145                	addi	sp,sp,48
    80003a0c:	8082                	ret
      addr = balloc(ip->dev);
    80003a0e:	00092503          	lw	a0,0(s2)
    80003a12:	e5dff0ef          	jal	8000386e <balloc>
    80003a16:	84aa                	mv	s1,a0
      if(addr){
    80003a18:	dd79                	beqz	a0,800039f6 <bmap+0x82>
        a[bn] = addr;
    80003a1a:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003a1e:	8552                	mv	a0,s4
    80003a20:	62d000ef          	jal	8000484c <log_write>
    80003a24:	bfc9                	j	800039f6 <bmap+0x82>
    80003a26:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003a28:	00005517          	auipc	a0,0x5
    80003a2c:	e6850513          	addi	a0,a0,-408 # 80008890 <etext+0x890>
    80003a30:	df5fc0ef          	jal	80000824 <panic>

0000000080003a34 <iget>:
{
    80003a34:	7179                	addi	sp,sp,-48
    80003a36:	f406                	sd	ra,40(sp)
    80003a38:	f022                	sd	s0,32(sp)
    80003a3a:	ec26                	sd	s1,24(sp)
    80003a3c:	e84a                	sd	s2,16(sp)
    80003a3e:	e44e                	sd	s3,8(sp)
    80003a40:	e052                	sd	s4,0(sp)
    80003a42:	1800                	addi	s0,sp,48
    80003a44:	892a                	mv	s2,a0
    80003a46:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a48:	0001f517          	auipc	a0,0x1f
    80003a4c:	83850513          	addi	a0,a0,-1992 # 80022280 <itable>
    80003a50:	9d8fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003a54:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a56:	0001f497          	auipc	s1,0x1f
    80003a5a:	84248493          	addi	s1,s1,-1982 # 80022298 <itable+0x18>
    80003a5e:	00020697          	auipc	a3,0x20
    80003a62:	2ca68693          	addi	a3,a3,714 # 80023d28 <log>
    80003a66:	a809                	j	80003a78 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a68:	e781                	bnez	a5,80003a70 <iget+0x3c>
    80003a6a:	00099363          	bnez	s3,80003a70 <iget+0x3c>
      empty = ip;
    80003a6e:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a70:	08848493          	addi	s1,s1,136
    80003a74:	02d48563          	beq	s1,a3,80003a9e <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a78:	449c                	lw	a5,8(s1)
    80003a7a:	fef057e3          	blez	a5,80003a68 <iget+0x34>
    80003a7e:	4098                	lw	a4,0(s1)
    80003a80:	ff2718e3          	bne	a4,s2,80003a70 <iget+0x3c>
    80003a84:	40d8                	lw	a4,4(s1)
    80003a86:	ff4715e3          	bne	a4,s4,80003a70 <iget+0x3c>
      ip->ref++;
    80003a8a:	2785                	addiw	a5,a5,1
    80003a8c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a8e:	0001e517          	auipc	a0,0x1e
    80003a92:	7f250513          	addi	a0,a0,2034 # 80022280 <itable>
    80003a96:	a26fd0ef          	jal	80000cbc <release>
      return ip;
    80003a9a:	89a6                	mv	s3,s1
    80003a9c:	a015                	j	80003ac0 <iget+0x8c>
  if(empty == 0)
    80003a9e:	02098a63          	beqz	s3,80003ad2 <iget+0x9e>
  ip->dev = dev;
    80003aa2:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003aa6:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003aaa:	4785                	li	a5,1
    80003aac:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003ab0:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003ab4:	0001e517          	auipc	a0,0x1e
    80003ab8:	7cc50513          	addi	a0,a0,1996 # 80022280 <itable>
    80003abc:	a00fd0ef          	jal	80000cbc <release>
}
    80003ac0:	854e                	mv	a0,s3
    80003ac2:	70a2                	ld	ra,40(sp)
    80003ac4:	7402                	ld	s0,32(sp)
    80003ac6:	64e2                	ld	s1,24(sp)
    80003ac8:	6942                	ld	s2,16(sp)
    80003aca:	69a2                	ld	s3,8(sp)
    80003acc:	6a02                	ld	s4,0(sp)
    80003ace:	6145                	addi	sp,sp,48
    80003ad0:	8082                	ret
    panic("iget: no inodes");
    80003ad2:	00005517          	auipc	a0,0x5
    80003ad6:	dd650513          	addi	a0,a0,-554 # 800088a8 <etext+0x8a8>
    80003ada:	d4bfc0ef          	jal	80000824 <panic>

0000000080003ade <iinit>:
{
    80003ade:	7179                	addi	sp,sp,-48
    80003ae0:	f406                	sd	ra,40(sp)
    80003ae2:	f022                	sd	s0,32(sp)
    80003ae4:	ec26                	sd	s1,24(sp)
    80003ae6:	e84a                	sd	s2,16(sp)
    80003ae8:	e44e                	sd	s3,8(sp)
    80003aea:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003aec:	00005597          	auipc	a1,0x5
    80003af0:	dcc58593          	addi	a1,a1,-564 # 800088b8 <etext+0x8b8>
    80003af4:	0001e517          	auipc	a0,0x1e
    80003af8:	78c50513          	addi	a0,a0,1932 # 80022280 <itable>
    80003afc:	8a2fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b00:	0001e497          	auipc	s1,0x1e
    80003b04:	7a848493          	addi	s1,s1,1960 # 800222a8 <itable+0x28>
    80003b08:	00020997          	auipc	s3,0x20
    80003b0c:	23098993          	addi	s3,s3,560 # 80023d38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b10:	00005917          	auipc	s2,0x5
    80003b14:	db090913          	addi	s2,s2,-592 # 800088c0 <etext+0x8c0>
    80003b18:	85ca                	mv	a1,s2
    80003b1a:	8526                	mv	a0,s1
    80003b1c:	5f5000ef          	jal	80004910 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b20:	08848493          	addi	s1,s1,136
    80003b24:	ff349ae3          	bne	s1,s3,80003b18 <iinit+0x3a>
}
    80003b28:	70a2                	ld	ra,40(sp)
    80003b2a:	7402                	ld	s0,32(sp)
    80003b2c:	64e2                	ld	s1,24(sp)
    80003b2e:	6942                	ld	s2,16(sp)
    80003b30:	69a2                	ld	s3,8(sp)
    80003b32:	6145                	addi	sp,sp,48
    80003b34:	8082                	ret

0000000080003b36 <ialloc>:
{
    80003b36:	7139                	addi	sp,sp,-64
    80003b38:	fc06                	sd	ra,56(sp)
    80003b3a:	f822                	sd	s0,48(sp)
    80003b3c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b3e:	0001e717          	auipc	a4,0x1e
    80003b42:	72e72703          	lw	a4,1838(a4) # 8002226c <sb+0xc>
    80003b46:	4785                	li	a5,1
    80003b48:	06e7f063          	bgeu	a5,a4,80003ba8 <ialloc+0x72>
    80003b4c:	f426                	sd	s1,40(sp)
    80003b4e:	f04a                	sd	s2,32(sp)
    80003b50:	ec4e                	sd	s3,24(sp)
    80003b52:	e852                	sd	s4,16(sp)
    80003b54:	e456                	sd	s5,8(sp)
    80003b56:	e05a                	sd	s6,0(sp)
    80003b58:	8aaa                	mv	s5,a0
    80003b5a:	8b2e                	mv	s6,a1
    80003b5c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003b5e:	0001ea17          	auipc	s4,0x1e
    80003b62:	702a0a13          	addi	s4,s4,1794 # 80022260 <sb>
    80003b66:	00495593          	srli	a1,s2,0x4
    80003b6a:	018a2783          	lw	a5,24(s4)
    80003b6e:	9dbd                	addw	a1,a1,a5
    80003b70:	8556                	mv	a0,s5
    80003b72:	a9dff0ef          	jal	8000360e <bread>
    80003b76:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b78:	05850993          	addi	s3,a0,88
    80003b7c:	00f97793          	andi	a5,s2,15
    80003b80:	079a                	slli	a5,a5,0x6
    80003b82:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b84:	00099783          	lh	a5,0(s3)
    80003b88:	cb9d                	beqz	a5,80003bbe <ialloc+0x88>
    brelse(bp);
    80003b8a:	b8dff0ef          	jal	80003716 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b8e:	0905                	addi	s2,s2,1
    80003b90:	00ca2703          	lw	a4,12(s4)
    80003b94:	0009079b          	sext.w	a5,s2
    80003b98:	fce7e7e3          	bltu	a5,a4,80003b66 <ialloc+0x30>
    80003b9c:	74a2                	ld	s1,40(sp)
    80003b9e:	7902                	ld	s2,32(sp)
    80003ba0:	69e2                	ld	s3,24(sp)
    80003ba2:	6a42                	ld	s4,16(sp)
    80003ba4:	6aa2                	ld	s5,8(sp)
    80003ba6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003ba8:	00005517          	auipc	a0,0x5
    80003bac:	d2050513          	addi	a0,a0,-736 # 800088c8 <etext+0x8c8>
    80003bb0:	94bfc0ef          	jal	800004fa <printf>
  return 0;
    80003bb4:	4501                	li	a0,0
}
    80003bb6:	70e2                	ld	ra,56(sp)
    80003bb8:	7442                	ld	s0,48(sp)
    80003bba:	6121                	addi	sp,sp,64
    80003bbc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003bbe:	04000613          	li	a2,64
    80003bc2:	4581                	li	a1,0
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	932fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003bca:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bce:	8526                	mv	a0,s1
    80003bd0:	47d000ef          	jal	8000484c <log_write>
      brelse(bp);
    80003bd4:	8526                	mv	a0,s1
    80003bd6:	b41ff0ef          	jal	80003716 <brelse>
      return iget(dev, inum);
    80003bda:	0009059b          	sext.w	a1,s2
    80003bde:	8556                	mv	a0,s5
    80003be0:	e55ff0ef          	jal	80003a34 <iget>
    80003be4:	74a2                	ld	s1,40(sp)
    80003be6:	7902                	ld	s2,32(sp)
    80003be8:	69e2                	ld	s3,24(sp)
    80003bea:	6a42                	ld	s4,16(sp)
    80003bec:	6aa2                	ld	s5,8(sp)
    80003bee:	6b02                	ld	s6,0(sp)
    80003bf0:	b7d9                	j	80003bb6 <ialloc+0x80>

0000000080003bf2 <iupdate>:
{
    80003bf2:	1101                	addi	sp,sp,-32
    80003bf4:	ec06                	sd	ra,24(sp)
    80003bf6:	e822                	sd	s0,16(sp)
    80003bf8:	e426                	sd	s1,8(sp)
    80003bfa:	e04a                	sd	s2,0(sp)
    80003bfc:	1000                	addi	s0,sp,32
    80003bfe:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c00:	415c                	lw	a5,4(a0)
    80003c02:	0047d79b          	srliw	a5,a5,0x4
    80003c06:	0001e597          	auipc	a1,0x1e
    80003c0a:	6725a583          	lw	a1,1650(a1) # 80022278 <sb+0x18>
    80003c0e:	9dbd                	addw	a1,a1,a5
    80003c10:	4108                	lw	a0,0(a0)
    80003c12:	9fdff0ef          	jal	8000360e <bread>
    80003c16:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c18:	05850793          	addi	a5,a0,88
    80003c1c:	40d8                	lw	a4,4(s1)
    80003c1e:	8b3d                	andi	a4,a4,15
    80003c20:	071a                	slli	a4,a4,0x6
    80003c22:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003c24:	04449703          	lh	a4,68(s1)
    80003c28:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003c2c:	04649703          	lh	a4,70(s1)
    80003c30:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c34:	04849703          	lh	a4,72(s1)
    80003c38:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c3c:	04a49703          	lh	a4,74(s1)
    80003c40:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c44:	44f8                	lw	a4,76(s1)
    80003c46:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c48:	03400613          	li	a2,52
    80003c4c:	05048593          	addi	a1,s1,80
    80003c50:	00c78513          	addi	a0,a5,12
    80003c54:	904fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003c58:	854a                	mv	a0,s2
    80003c5a:	3f3000ef          	jal	8000484c <log_write>
  brelse(bp);
    80003c5e:	854a                	mv	a0,s2
    80003c60:	ab7ff0ef          	jal	80003716 <brelse>
}
    80003c64:	60e2                	ld	ra,24(sp)
    80003c66:	6442                	ld	s0,16(sp)
    80003c68:	64a2                	ld	s1,8(sp)
    80003c6a:	6902                	ld	s2,0(sp)
    80003c6c:	6105                	addi	sp,sp,32
    80003c6e:	8082                	ret

0000000080003c70 <idup>:
{
    80003c70:	1101                	addi	sp,sp,-32
    80003c72:	ec06                	sd	ra,24(sp)
    80003c74:	e822                	sd	s0,16(sp)
    80003c76:	e426                	sd	s1,8(sp)
    80003c78:	1000                	addi	s0,sp,32
    80003c7a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c7c:	0001e517          	auipc	a0,0x1e
    80003c80:	60450513          	addi	a0,a0,1540 # 80022280 <itable>
    80003c84:	fa5fc0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003c88:	449c                	lw	a5,8(s1)
    80003c8a:	2785                	addiw	a5,a5,1
    80003c8c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c8e:	0001e517          	auipc	a0,0x1e
    80003c92:	5f250513          	addi	a0,a0,1522 # 80022280 <itable>
    80003c96:	826fd0ef          	jal	80000cbc <release>
}
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	60e2                	ld	ra,24(sp)
    80003c9e:	6442                	ld	s0,16(sp)
    80003ca0:	64a2                	ld	s1,8(sp)
    80003ca2:	6105                	addi	sp,sp,32
    80003ca4:	8082                	ret

0000000080003ca6 <ilock>:
{
    80003ca6:	1101                	addi	sp,sp,-32
    80003ca8:	ec06                	sd	ra,24(sp)
    80003caa:	e822                	sd	s0,16(sp)
    80003cac:	e426                	sd	s1,8(sp)
    80003cae:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003cb0:	cd19                	beqz	a0,80003cce <ilock+0x28>
    80003cb2:	84aa                	mv	s1,a0
    80003cb4:	451c                	lw	a5,8(a0)
    80003cb6:	00f05c63          	blez	a5,80003cce <ilock+0x28>
  acquiresleep(&ip->lock);
    80003cba:	0541                	addi	a0,a0,16
    80003cbc:	48b000ef          	jal	80004946 <acquiresleep>
  if(ip->valid == 0){
    80003cc0:	40bc                	lw	a5,64(s1)
    80003cc2:	cf89                	beqz	a5,80003cdc <ilock+0x36>
}
    80003cc4:	60e2                	ld	ra,24(sp)
    80003cc6:	6442                	ld	s0,16(sp)
    80003cc8:	64a2                	ld	s1,8(sp)
    80003cca:	6105                	addi	sp,sp,32
    80003ccc:	8082                	ret
    80003cce:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003cd0:	00005517          	auipc	a0,0x5
    80003cd4:	c1050513          	addi	a0,a0,-1008 # 800088e0 <etext+0x8e0>
    80003cd8:	b4dfc0ef          	jal	80000824 <panic>
    80003cdc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cde:	40dc                	lw	a5,4(s1)
    80003ce0:	0047d79b          	srliw	a5,a5,0x4
    80003ce4:	0001e597          	auipc	a1,0x1e
    80003ce8:	5945a583          	lw	a1,1428(a1) # 80022278 <sb+0x18>
    80003cec:	9dbd                	addw	a1,a1,a5
    80003cee:	4088                	lw	a0,0(s1)
    80003cf0:	91fff0ef          	jal	8000360e <bread>
    80003cf4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cf6:	05850593          	addi	a1,a0,88
    80003cfa:	40dc                	lw	a5,4(s1)
    80003cfc:	8bbd                	andi	a5,a5,15
    80003cfe:	079a                	slli	a5,a5,0x6
    80003d00:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d02:	00059783          	lh	a5,0(a1)
    80003d06:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d0a:	00259783          	lh	a5,2(a1)
    80003d0e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d12:	00459783          	lh	a5,4(a1)
    80003d16:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d1a:	00659783          	lh	a5,6(a1)
    80003d1e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d22:	459c                	lw	a5,8(a1)
    80003d24:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d26:	03400613          	li	a2,52
    80003d2a:	05b1                	addi	a1,a1,12
    80003d2c:	05048513          	addi	a0,s1,80
    80003d30:	828fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003d34:	854a                	mv	a0,s2
    80003d36:	9e1ff0ef          	jal	80003716 <brelse>
    ip->valid = 1;
    80003d3a:	4785                	li	a5,1
    80003d3c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d3e:	04449783          	lh	a5,68(s1)
    80003d42:	c399                	beqz	a5,80003d48 <ilock+0xa2>
    80003d44:	6902                	ld	s2,0(sp)
    80003d46:	bfbd                	j	80003cc4 <ilock+0x1e>
      panic("ilock: no type");
    80003d48:	00005517          	auipc	a0,0x5
    80003d4c:	ba050513          	addi	a0,a0,-1120 # 800088e8 <etext+0x8e8>
    80003d50:	ad5fc0ef          	jal	80000824 <panic>

0000000080003d54 <iunlock>:
{
    80003d54:	1101                	addi	sp,sp,-32
    80003d56:	ec06                	sd	ra,24(sp)
    80003d58:	e822                	sd	s0,16(sp)
    80003d5a:	e426                	sd	s1,8(sp)
    80003d5c:	e04a                	sd	s2,0(sp)
    80003d5e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d60:	c505                	beqz	a0,80003d88 <iunlock+0x34>
    80003d62:	84aa                	mv	s1,a0
    80003d64:	01050913          	addi	s2,a0,16
    80003d68:	854a                	mv	a0,s2
    80003d6a:	45b000ef          	jal	800049c4 <holdingsleep>
    80003d6e:	cd09                	beqz	a0,80003d88 <iunlock+0x34>
    80003d70:	449c                	lw	a5,8(s1)
    80003d72:	00f05b63          	blez	a5,80003d88 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003d76:	854a                	mv	a0,s2
    80003d78:	415000ef          	jal	8000498c <releasesleep>
}
    80003d7c:	60e2                	ld	ra,24(sp)
    80003d7e:	6442                	ld	s0,16(sp)
    80003d80:	64a2                	ld	s1,8(sp)
    80003d82:	6902                	ld	s2,0(sp)
    80003d84:	6105                	addi	sp,sp,32
    80003d86:	8082                	ret
    panic("iunlock");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	b7050513          	addi	a0,a0,-1168 # 800088f8 <etext+0x8f8>
    80003d90:	a95fc0ef          	jal	80000824 <panic>

0000000080003d94 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d94:	7179                	addi	sp,sp,-48
    80003d96:	f406                	sd	ra,40(sp)
    80003d98:	f022                	sd	s0,32(sp)
    80003d9a:	ec26                	sd	s1,24(sp)
    80003d9c:	e84a                	sd	s2,16(sp)
    80003d9e:	e44e                	sd	s3,8(sp)
    80003da0:	1800                	addi	s0,sp,48
    80003da2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003da4:	05050493          	addi	s1,a0,80
    80003da8:	08050913          	addi	s2,a0,128
    80003dac:	a021                	j	80003db4 <itrunc+0x20>
    80003dae:	0491                	addi	s1,s1,4
    80003db0:	01248b63          	beq	s1,s2,80003dc6 <itrunc+0x32>
    if(ip->addrs[i]){
    80003db4:	408c                	lw	a1,0(s1)
    80003db6:	dde5                	beqz	a1,80003dae <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003db8:	0009a503          	lw	a0,0(s3)
    80003dbc:	a47ff0ef          	jal	80003802 <bfree>
      ip->addrs[i] = 0;
    80003dc0:	0004a023          	sw	zero,0(s1)
    80003dc4:	b7ed                	j	80003dae <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dc6:	0809a583          	lw	a1,128(s3)
    80003dca:	ed89                	bnez	a1,80003de4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dcc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	e21ff0ef          	jal	80003bf2 <iupdate>
}
    80003dd6:	70a2                	ld	ra,40(sp)
    80003dd8:	7402                	ld	s0,32(sp)
    80003dda:	64e2                	ld	s1,24(sp)
    80003ddc:	6942                	ld	s2,16(sp)
    80003dde:	69a2                	ld	s3,8(sp)
    80003de0:	6145                	addi	sp,sp,48
    80003de2:	8082                	ret
    80003de4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003de6:	0009a503          	lw	a0,0(s3)
    80003dea:	825ff0ef          	jal	8000360e <bread>
    80003dee:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003df0:	05850493          	addi	s1,a0,88
    80003df4:	45850913          	addi	s2,a0,1112
    80003df8:	a021                	j	80003e00 <itrunc+0x6c>
    80003dfa:	0491                	addi	s1,s1,4
    80003dfc:	01248963          	beq	s1,s2,80003e0e <itrunc+0x7a>
      if(a[j])
    80003e00:	408c                	lw	a1,0(s1)
    80003e02:	dde5                	beqz	a1,80003dfa <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003e04:	0009a503          	lw	a0,0(s3)
    80003e08:	9fbff0ef          	jal	80003802 <bfree>
    80003e0c:	b7fd                	j	80003dfa <itrunc+0x66>
    brelse(bp);
    80003e0e:	8552                	mv	a0,s4
    80003e10:	907ff0ef          	jal	80003716 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e14:	0809a583          	lw	a1,128(s3)
    80003e18:	0009a503          	lw	a0,0(s3)
    80003e1c:	9e7ff0ef          	jal	80003802 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e20:	0809a023          	sw	zero,128(s3)
    80003e24:	6a02                	ld	s4,0(sp)
    80003e26:	b75d                	j	80003dcc <itrunc+0x38>

0000000080003e28 <iput>:
{
    80003e28:	1101                	addi	sp,sp,-32
    80003e2a:	ec06                	sd	ra,24(sp)
    80003e2c:	e822                	sd	s0,16(sp)
    80003e2e:	e426                	sd	s1,8(sp)
    80003e30:	1000                	addi	s0,sp,32
    80003e32:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e34:	0001e517          	auipc	a0,0x1e
    80003e38:	44c50513          	addi	a0,a0,1100 # 80022280 <itable>
    80003e3c:	dedfc0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e40:	4498                	lw	a4,8(s1)
    80003e42:	4785                	li	a5,1
    80003e44:	02f70063          	beq	a4,a5,80003e64 <iput+0x3c>
  ip->ref--;
    80003e48:	449c                	lw	a5,8(s1)
    80003e4a:	37fd                	addiw	a5,a5,-1
    80003e4c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e4e:	0001e517          	auipc	a0,0x1e
    80003e52:	43250513          	addi	a0,a0,1074 # 80022280 <itable>
    80003e56:	e67fc0ef          	jal	80000cbc <release>
}
    80003e5a:	60e2                	ld	ra,24(sp)
    80003e5c:	6442                	ld	s0,16(sp)
    80003e5e:	64a2                	ld	s1,8(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e64:	40bc                	lw	a5,64(s1)
    80003e66:	d3ed                	beqz	a5,80003e48 <iput+0x20>
    80003e68:	04a49783          	lh	a5,74(s1)
    80003e6c:	fff1                	bnez	a5,80003e48 <iput+0x20>
    80003e6e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e70:	01048793          	addi	a5,s1,16
    80003e74:	893e                	mv	s2,a5
    80003e76:	853e                	mv	a0,a5
    80003e78:	2cf000ef          	jal	80004946 <acquiresleep>
    release(&itable.lock);
    80003e7c:	0001e517          	auipc	a0,0x1e
    80003e80:	40450513          	addi	a0,a0,1028 # 80022280 <itable>
    80003e84:	e39fc0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	f0bff0ef          	jal	80003d94 <itrunc>
    ip->type = 0;
    80003e8e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e92:	8526                	mv	a0,s1
    80003e94:	d5fff0ef          	jal	80003bf2 <iupdate>
    ip->valid = 0;
    80003e98:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e9c:	854a                	mv	a0,s2
    80003e9e:	2ef000ef          	jal	8000498c <releasesleep>
    acquire(&itable.lock);
    80003ea2:	0001e517          	auipc	a0,0x1e
    80003ea6:	3de50513          	addi	a0,a0,990 # 80022280 <itable>
    80003eaa:	d7ffc0ef          	jal	80000c28 <acquire>
    80003eae:	6902                	ld	s2,0(sp)
    80003eb0:	bf61                	j	80003e48 <iput+0x20>

0000000080003eb2 <iunlockput>:
{
    80003eb2:	1101                	addi	sp,sp,-32
    80003eb4:	ec06                	sd	ra,24(sp)
    80003eb6:	e822                	sd	s0,16(sp)
    80003eb8:	e426                	sd	s1,8(sp)
    80003eba:	1000                	addi	s0,sp,32
    80003ebc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ebe:	e97ff0ef          	jal	80003d54 <iunlock>
  iput(ip);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	f65ff0ef          	jal	80003e28 <iput>
}
    80003ec8:	60e2                	ld	ra,24(sp)
    80003eca:	6442                	ld	s0,16(sp)
    80003ecc:	64a2                	ld	s1,8(sp)
    80003ece:	6105                	addi	sp,sp,32
    80003ed0:	8082                	ret

0000000080003ed2 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ed2:	0001e717          	auipc	a4,0x1e
    80003ed6:	39a72703          	lw	a4,922(a4) # 8002226c <sb+0xc>
    80003eda:	4785                	li	a5,1
    80003edc:	0ae7fe63          	bgeu	a5,a4,80003f98 <ireclaim+0xc6>
{
    80003ee0:	7139                	addi	sp,sp,-64
    80003ee2:	fc06                	sd	ra,56(sp)
    80003ee4:	f822                	sd	s0,48(sp)
    80003ee6:	f426                	sd	s1,40(sp)
    80003ee8:	f04a                	sd	s2,32(sp)
    80003eea:	ec4e                	sd	s3,24(sp)
    80003eec:	e852                	sd	s4,16(sp)
    80003eee:	e456                	sd	s5,8(sp)
    80003ef0:	e05a                	sd	s6,0(sp)
    80003ef2:	0080                	addi	s0,sp,64
    80003ef4:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ef6:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ef8:	0001ea17          	auipc	s4,0x1e
    80003efc:	368a0a13          	addi	s4,s4,872 # 80022260 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003f00:	00005b17          	auipc	s6,0x5
    80003f04:	a00b0b13          	addi	s6,s6,-1536 # 80008900 <etext+0x900>
    80003f08:	a099                	j	80003f4e <ireclaim+0x7c>
    80003f0a:	85ce                	mv	a1,s3
    80003f0c:	855a                	mv	a0,s6
    80003f0e:	decfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003f12:	85ce                	mv	a1,s3
    80003f14:	8556                	mv	a0,s5
    80003f16:	b1fff0ef          	jal	80003a34 <iget>
    80003f1a:	89aa                	mv	s3,a0
    brelse(bp);
    80003f1c:	854a                	mv	a0,s2
    80003f1e:	ff8ff0ef          	jal	80003716 <brelse>
    if (ip) {
    80003f22:	00098f63          	beqz	s3,80003f40 <ireclaim+0x6e>
      begin_op();
    80003f26:	78c000ef          	jal	800046b2 <begin_op>
      ilock(ip);
    80003f2a:	854e                	mv	a0,s3
    80003f2c:	d7bff0ef          	jal	80003ca6 <ilock>
      iunlock(ip);
    80003f30:	854e                	mv	a0,s3
    80003f32:	e23ff0ef          	jal	80003d54 <iunlock>
      iput(ip);
    80003f36:	854e                	mv	a0,s3
    80003f38:	ef1ff0ef          	jal	80003e28 <iput>
      end_op();
    80003f3c:	7e6000ef          	jal	80004722 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003f40:	0485                	addi	s1,s1,1
    80003f42:	00ca2703          	lw	a4,12(s4)
    80003f46:	0004879b          	sext.w	a5,s1
    80003f4a:	02e7fd63          	bgeu	a5,a4,80003f84 <ireclaim+0xb2>
    80003f4e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003f52:	0044d593          	srli	a1,s1,0x4
    80003f56:	018a2783          	lw	a5,24(s4)
    80003f5a:	9dbd                	addw	a1,a1,a5
    80003f5c:	8556                	mv	a0,s5
    80003f5e:	eb0ff0ef          	jal	8000360e <bread>
    80003f62:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003f64:	05850793          	addi	a5,a0,88
    80003f68:	00f9f713          	andi	a4,s3,15
    80003f6c:	071a                	slli	a4,a4,0x6
    80003f6e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003f70:	00079703          	lh	a4,0(a5)
    80003f74:	c701                	beqz	a4,80003f7c <ireclaim+0xaa>
    80003f76:	00679783          	lh	a5,6(a5)
    80003f7a:	dbc1                	beqz	a5,80003f0a <ireclaim+0x38>
    brelse(bp);
    80003f7c:	854a                	mv	a0,s2
    80003f7e:	f98ff0ef          	jal	80003716 <brelse>
    if (ip) {
    80003f82:	bf7d                	j	80003f40 <ireclaim+0x6e>
}
    80003f84:	70e2                	ld	ra,56(sp)
    80003f86:	7442                	ld	s0,48(sp)
    80003f88:	74a2                	ld	s1,40(sp)
    80003f8a:	7902                	ld	s2,32(sp)
    80003f8c:	69e2                	ld	s3,24(sp)
    80003f8e:	6a42                	ld	s4,16(sp)
    80003f90:	6aa2                	ld	s5,8(sp)
    80003f92:	6b02                	ld	s6,0(sp)
    80003f94:	6121                	addi	sp,sp,64
    80003f96:	8082                	ret
    80003f98:	8082                	ret

0000000080003f9a <fsinit>:
fsinit(int dev) {
    80003f9a:	1101                	addi	sp,sp,-32
    80003f9c:	ec06                	sd	ra,24(sp)
    80003f9e:	e822                	sd	s0,16(sp)
    80003fa0:	e426                	sd	s1,8(sp)
    80003fa2:	e04a                	sd	s2,0(sp)
    80003fa4:	1000                	addi	s0,sp,32
    80003fa6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003fa8:	4585                	li	a1,1
    80003faa:	e64ff0ef          	jal	8000360e <bread>
    80003fae:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003fb0:	02000613          	li	a2,32
    80003fb4:	05850593          	addi	a1,a0,88
    80003fb8:	0001e517          	auipc	a0,0x1e
    80003fbc:	2a850513          	addi	a0,a0,680 # 80022260 <sb>
    80003fc0:	d99fc0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	f50ff0ef          	jal	80003716 <brelse>
  if(sb.magic != FSMAGIC)
    80003fca:	0001e717          	auipc	a4,0x1e
    80003fce:	29672703          	lw	a4,662(a4) # 80022260 <sb>
    80003fd2:	102037b7          	lui	a5,0x10203
    80003fd6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003fda:	02f71263          	bne	a4,a5,80003ffe <fsinit+0x64>
  initlog(dev, &sb);
    80003fde:	0001e597          	auipc	a1,0x1e
    80003fe2:	28258593          	addi	a1,a1,642 # 80022260 <sb>
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	648000ef          	jal	80004630 <initlog>
  ireclaim(dev);
    80003fec:	854a                	mv	a0,s2
    80003fee:	ee5ff0ef          	jal	80003ed2 <ireclaim>
}
    80003ff2:	60e2                	ld	ra,24(sp)
    80003ff4:	6442                	ld	s0,16(sp)
    80003ff6:	64a2                	ld	s1,8(sp)
    80003ff8:	6902                	ld	s2,0(sp)
    80003ffa:	6105                	addi	sp,sp,32
    80003ffc:	8082                	ret
    panic("invalid file system");
    80003ffe:	00005517          	auipc	a0,0x5
    80004002:	92250513          	addi	a0,a0,-1758 # 80008920 <etext+0x920>
    80004006:	81ffc0ef          	jal	80000824 <panic>

000000008000400a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000400a:	1141                	addi	sp,sp,-16
    8000400c:	e406                	sd	ra,8(sp)
    8000400e:	e022                	sd	s0,0(sp)
    80004010:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004012:	411c                	lw	a5,0(a0)
    80004014:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004016:	415c                	lw	a5,4(a0)
    80004018:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000401a:	04451783          	lh	a5,68(a0)
    8000401e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004022:	04a51783          	lh	a5,74(a0)
    80004026:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000402a:	04c56783          	lwu	a5,76(a0)
    8000402e:	e99c                	sd	a5,16(a1)
}
    80004030:	60a2                	ld	ra,8(sp)
    80004032:	6402                	ld	s0,0(sp)
    80004034:	0141                	addi	sp,sp,16
    80004036:	8082                	ret

0000000080004038 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004038:	457c                	lw	a5,76(a0)
    8000403a:	0ed7e663          	bltu	a5,a3,80004126 <readi+0xee>
{
    8000403e:	7159                	addi	sp,sp,-112
    80004040:	f486                	sd	ra,104(sp)
    80004042:	f0a2                	sd	s0,96(sp)
    80004044:	eca6                	sd	s1,88(sp)
    80004046:	e0d2                	sd	s4,64(sp)
    80004048:	fc56                	sd	s5,56(sp)
    8000404a:	f85a                	sd	s6,48(sp)
    8000404c:	f45e                	sd	s7,40(sp)
    8000404e:	1880                	addi	s0,sp,112
    80004050:	8b2a                	mv	s6,a0
    80004052:	8bae                	mv	s7,a1
    80004054:	8a32                	mv	s4,a2
    80004056:	84b6                	mv	s1,a3
    80004058:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000405a:	9f35                	addw	a4,a4,a3
    return 0;
    8000405c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000405e:	0ad76b63          	bltu	a4,a3,80004114 <readi+0xdc>
    80004062:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004064:	00e7f463          	bgeu	a5,a4,8000406c <readi+0x34>
    n = ip->size - off;
    80004068:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000406c:	080a8b63          	beqz	s5,80004102 <readi+0xca>
    80004070:	e8ca                	sd	s2,80(sp)
    80004072:	f062                	sd	s8,32(sp)
    80004074:	ec66                	sd	s9,24(sp)
    80004076:	e86a                	sd	s10,16(sp)
    80004078:	e46e                	sd	s11,8(sp)
    8000407a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000407c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004080:	5c7d                	li	s8,-1
    80004082:	a80d                	j	800040b4 <readi+0x7c>
    80004084:	020d1d93          	slli	s11,s10,0x20
    80004088:	020ddd93          	srli	s11,s11,0x20
    8000408c:	05890613          	addi	a2,s2,88
    80004090:	86ee                	mv	a3,s11
    80004092:	963e                	add	a2,a2,a5
    80004094:	85d2                	mv	a1,s4
    80004096:	855e                	mv	a0,s7
    80004098:	a63fe0ef          	jal	80002afa <either_copyout>
    8000409c:	05850363          	beq	a0,s8,800040e2 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040a0:	854a                	mv	a0,s2
    800040a2:	e74ff0ef          	jal	80003716 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040a6:	013d09bb          	addw	s3,s10,s3
    800040aa:	009d04bb          	addw	s1,s10,s1
    800040ae:	9a6e                	add	s4,s4,s11
    800040b0:	0559f363          	bgeu	s3,s5,800040f6 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800040b4:	00a4d59b          	srliw	a1,s1,0xa
    800040b8:	855a                	mv	a0,s6
    800040ba:	8bbff0ef          	jal	80003974 <bmap>
    800040be:	85aa                	mv	a1,a0
    if(addr == 0)
    800040c0:	c139                	beqz	a0,80004106 <readi+0xce>
    bp = bread(ip->dev, addr);
    800040c2:	000b2503          	lw	a0,0(s6)
    800040c6:	d48ff0ef          	jal	8000360e <bread>
    800040ca:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040cc:	3ff4f793          	andi	a5,s1,1023
    800040d0:	40fc873b          	subw	a4,s9,a5
    800040d4:	413a86bb          	subw	a3,s5,s3
    800040d8:	8d3a                	mv	s10,a4
    800040da:	fae6f5e3          	bgeu	a3,a4,80004084 <readi+0x4c>
    800040de:	8d36                	mv	s10,a3
    800040e0:	b755                	j	80004084 <readi+0x4c>
      brelse(bp);
    800040e2:	854a                	mv	a0,s2
    800040e4:	e32ff0ef          	jal	80003716 <brelse>
      tot = -1;
    800040e8:	59fd                	li	s3,-1
      break;
    800040ea:	6946                	ld	s2,80(sp)
    800040ec:	7c02                	ld	s8,32(sp)
    800040ee:	6ce2                	ld	s9,24(sp)
    800040f0:	6d42                	ld	s10,16(sp)
    800040f2:	6da2                	ld	s11,8(sp)
    800040f4:	a831                	j	80004110 <readi+0xd8>
    800040f6:	6946                	ld	s2,80(sp)
    800040f8:	7c02                	ld	s8,32(sp)
    800040fa:	6ce2                	ld	s9,24(sp)
    800040fc:	6d42                	ld	s10,16(sp)
    800040fe:	6da2                	ld	s11,8(sp)
    80004100:	a801                	j	80004110 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004102:	89d6                	mv	s3,s5
    80004104:	a031                	j	80004110 <readi+0xd8>
    80004106:	6946                	ld	s2,80(sp)
    80004108:	7c02                	ld	s8,32(sp)
    8000410a:	6ce2                	ld	s9,24(sp)
    8000410c:	6d42                	ld	s10,16(sp)
    8000410e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004110:	854e                	mv	a0,s3
    80004112:	69a6                	ld	s3,72(sp)
}
    80004114:	70a6                	ld	ra,104(sp)
    80004116:	7406                	ld	s0,96(sp)
    80004118:	64e6                	ld	s1,88(sp)
    8000411a:	6a06                	ld	s4,64(sp)
    8000411c:	7ae2                	ld	s5,56(sp)
    8000411e:	7b42                	ld	s6,48(sp)
    80004120:	7ba2                	ld	s7,40(sp)
    80004122:	6165                	addi	sp,sp,112
    80004124:	8082                	ret
    return 0;
    80004126:	4501                	li	a0,0
}
    80004128:	8082                	ret

000000008000412a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000412a:	457c                	lw	a5,76(a0)
    8000412c:	0ed7eb63          	bltu	a5,a3,80004222 <writei+0xf8>
{
    80004130:	7159                	addi	sp,sp,-112
    80004132:	f486                	sd	ra,104(sp)
    80004134:	f0a2                	sd	s0,96(sp)
    80004136:	e8ca                	sd	s2,80(sp)
    80004138:	e0d2                	sd	s4,64(sp)
    8000413a:	fc56                	sd	s5,56(sp)
    8000413c:	f85a                	sd	s6,48(sp)
    8000413e:	f45e                	sd	s7,40(sp)
    80004140:	1880                	addi	s0,sp,112
    80004142:	8aaa                	mv	s5,a0
    80004144:	8bae                	mv	s7,a1
    80004146:	8a32                	mv	s4,a2
    80004148:	8936                	mv	s2,a3
    8000414a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000414c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004150:	00043737          	lui	a4,0x43
    80004154:	0cf76963          	bltu	a4,a5,80004226 <writei+0xfc>
    80004158:	0cd7e763          	bltu	a5,a3,80004226 <writei+0xfc>
    8000415c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000415e:	0a0b0a63          	beqz	s6,80004212 <writei+0xe8>
    80004162:	eca6                	sd	s1,88(sp)
    80004164:	f062                	sd	s8,32(sp)
    80004166:	ec66                	sd	s9,24(sp)
    80004168:	e86a                	sd	s10,16(sp)
    8000416a:	e46e                	sd	s11,8(sp)
    8000416c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000416e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004172:	5c7d                	li	s8,-1
    80004174:	a825                	j	800041ac <writei+0x82>
    80004176:	020d1d93          	slli	s11,s10,0x20
    8000417a:	020ddd93          	srli	s11,s11,0x20
    8000417e:	05848513          	addi	a0,s1,88
    80004182:	86ee                	mv	a3,s11
    80004184:	8652                	mv	a2,s4
    80004186:	85de                	mv	a1,s7
    80004188:	953e                	add	a0,a0,a5
    8000418a:	9bbfe0ef          	jal	80002b44 <either_copyin>
    8000418e:	05850663          	beq	a0,s8,800041da <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004192:	8526                	mv	a0,s1
    80004194:	6b8000ef          	jal	8000484c <log_write>
    brelse(bp);
    80004198:	8526                	mv	a0,s1
    8000419a:	d7cff0ef          	jal	80003716 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000419e:	013d09bb          	addw	s3,s10,s3
    800041a2:	012d093b          	addw	s2,s10,s2
    800041a6:	9a6e                	add	s4,s4,s11
    800041a8:	0369fc63          	bgeu	s3,s6,800041e0 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800041ac:	00a9559b          	srliw	a1,s2,0xa
    800041b0:	8556                	mv	a0,s5
    800041b2:	fc2ff0ef          	jal	80003974 <bmap>
    800041b6:	85aa                	mv	a1,a0
    if(addr == 0)
    800041b8:	c505                	beqz	a0,800041e0 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800041ba:	000aa503          	lw	a0,0(s5)
    800041be:	c50ff0ef          	jal	8000360e <bread>
    800041c2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c4:	3ff97793          	andi	a5,s2,1023
    800041c8:	40fc873b          	subw	a4,s9,a5
    800041cc:	413b06bb          	subw	a3,s6,s3
    800041d0:	8d3a                	mv	s10,a4
    800041d2:	fae6f2e3          	bgeu	a3,a4,80004176 <writei+0x4c>
    800041d6:	8d36                	mv	s10,a3
    800041d8:	bf79                	j	80004176 <writei+0x4c>
      brelse(bp);
    800041da:	8526                	mv	a0,s1
    800041dc:	d3aff0ef          	jal	80003716 <brelse>
  }

  if(off > ip->size)
    800041e0:	04caa783          	lw	a5,76(s5)
    800041e4:	0327f963          	bgeu	a5,s2,80004216 <writei+0xec>
    ip->size = off;
    800041e8:	052aa623          	sw	s2,76(s5)
    800041ec:	64e6                	ld	s1,88(sp)
    800041ee:	7c02                	ld	s8,32(sp)
    800041f0:	6ce2                	ld	s9,24(sp)
    800041f2:	6d42                	ld	s10,16(sp)
    800041f4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041f6:	8556                	mv	a0,s5
    800041f8:	9fbff0ef          	jal	80003bf2 <iupdate>

  return tot;
    800041fc:	854e                	mv	a0,s3
    800041fe:	69a6                	ld	s3,72(sp)
}
    80004200:	70a6                	ld	ra,104(sp)
    80004202:	7406                	ld	s0,96(sp)
    80004204:	6946                	ld	s2,80(sp)
    80004206:	6a06                	ld	s4,64(sp)
    80004208:	7ae2                	ld	s5,56(sp)
    8000420a:	7b42                	ld	s6,48(sp)
    8000420c:	7ba2                	ld	s7,40(sp)
    8000420e:	6165                	addi	sp,sp,112
    80004210:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004212:	89da                	mv	s3,s6
    80004214:	b7cd                	j	800041f6 <writei+0xcc>
    80004216:	64e6                	ld	s1,88(sp)
    80004218:	7c02                	ld	s8,32(sp)
    8000421a:	6ce2                	ld	s9,24(sp)
    8000421c:	6d42                	ld	s10,16(sp)
    8000421e:	6da2                	ld	s11,8(sp)
    80004220:	bfd9                	j	800041f6 <writei+0xcc>
    return -1;
    80004222:	557d                	li	a0,-1
}
    80004224:	8082                	ret
    return -1;
    80004226:	557d                	li	a0,-1
    80004228:	bfe1                	j	80004200 <writei+0xd6>

000000008000422a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000422a:	1141                	addi	sp,sp,-16
    8000422c:	e406                	sd	ra,8(sp)
    8000422e:	e022                	sd	s0,0(sp)
    80004230:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004232:	4639                	li	a2,14
    80004234:	b99fc0ef          	jal	80000dcc <strncmp>
}
    80004238:	60a2                	ld	ra,8(sp)
    8000423a:	6402                	ld	s0,0(sp)
    8000423c:	0141                	addi	sp,sp,16
    8000423e:	8082                	ret

0000000080004240 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004240:	711d                	addi	sp,sp,-96
    80004242:	ec86                	sd	ra,88(sp)
    80004244:	e8a2                	sd	s0,80(sp)
    80004246:	e4a6                	sd	s1,72(sp)
    80004248:	e0ca                	sd	s2,64(sp)
    8000424a:	fc4e                	sd	s3,56(sp)
    8000424c:	f852                	sd	s4,48(sp)
    8000424e:	f456                	sd	s5,40(sp)
    80004250:	f05a                	sd	s6,32(sp)
    80004252:	ec5e                	sd	s7,24(sp)
    80004254:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004256:	04451703          	lh	a4,68(a0)
    8000425a:	4785                	li	a5,1
    8000425c:	00f71f63          	bne	a4,a5,8000427a <dirlookup+0x3a>
    80004260:	892a                	mv	s2,a0
    80004262:	8aae                	mv	s5,a1
    80004264:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004266:	457c                	lw	a5,76(a0)
    80004268:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000426a:	fa040a13          	addi	s4,s0,-96
    8000426e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80004270:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004274:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004276:	e39d                	bnez	a5,8000429c <dirlookup+0x5c>
    80004278:	a8b9                	j	800042d6 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000427a:	00004517          	auipc	a0,0x4
    8000427e:	6be50513          	addi	a0,a0,1726 # 80008938 <etext+0x938>
    80004282:	da2fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80004286:	00004517          	auipc	a0,0x4
    8000428a:	6ca50513          	addi	a0,a0,1738 # 80008950 <etext+0x950>
    8000428e:	d96fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004292:	24c1                	addiw	s1,s1,16
    80004294:	04c92783          	lw	a5,76(s2)
    80004298:	02f4fe63          	bgeu	s1,a5,800042d4 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000429c:	874e                	mv	a4,s3
    8000429e:	86a6                	mv	a3,s1
    800042a0:	8652                	mv	a2,s4
    800042a2:	4581                	li	a1,0
    800042a4:	854a                	mv	a0,s2
    800042a6:	d93ff0ef          	jal	80004038 <readi>
    800042aa:	fd351ee3          	bne	a0,s3,80004286 <dirlookup+0x46>
    if(de.inum == 0)
    800042ae:	fa045783          	lhu	a5,-96(s0)
    800042b2:	d3e5                	beqz	a5,80004292 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800042b4:	85da                	mv	a1,s6
    800042b6:	8556                	mv	a0,s5
    800042b8:	f73ff0ef          	jal	8000422a <namecmp>
    800042bc:	f979                	bnez	a0,80004292 <dirlookup+0x52>
      if(poff)
    800042be:	000b8463          	beqz	s7,800042c6 <dirlookup+0x86>
        *poff = off;
    800042c2:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800042c6:	fa045583          	lhu	a1,-96(s0)
    800042ca:	00092503          	lw	a0,0(s2)
    800042ce:	f66ff0ef          	jal	80003a34 <iget>
    800042d2:	a011                	j	800042d6 <dirlookup+0x96>
  return 0;
    800042d4:	4501                	li	a0,0
}
    800042d6:	60e6                	ld	ra,88(sp)
    800042d8:	6446                	ld	s0,80(sp)
    800042da:	64a6                	ld	s1,72(sp)
    800042dc:	6906                	ld	s2,64(sp)
    800042de:	79e2                	ld	s3,56(sp)
    800042e0:	7a42                	ld	s4,48(sp)
    800042e2:	7aa2                	ld	s5,40(sp)
    800042e4:	7b02                	ld	s6,32(sp)
    800042e6:	6be2                	ld	s7,24(sp)
    800042e8:	6125                	addi	sp,sp,96
    800042ea:	8082                	ret

00000000800042ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042ec:	711d                	addi	sp,sp,-96
    800042ee:	ec86                	sd	ra,88(sp)
    800042f0:	e8a2                	sd	s0,80(sp)
    800042f2:	e4a6                	sd	s1,72(sp)
    800042f4:	e0ca                	sd	s2,64(sp)
    800042f6:	fc4e                	sd	s3,56(sp)
    800042f8:	f852                	sd	s4,48(sp)
    800042fa:	f456                	sd	s5,40(sp)
    800042fc:	f05a                	sd	s6,32(sp)
    800042fe:	ec5e                	sd	s7,24(sp)
    80004300:	e862                	sd	s8,16(sp)
    80004302:	e466                	sd	s9,8(sp)
    80004304:	e06a                	sd	s10,0(sp)
    80004306:	1080                	addi	s0,sp,96
    80004308:	84aa                	mv	s1,a0
    8000430a:	8b2e                	mv	s6,a1
    8000430c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000430e:	00054703          	lbu	a4,0(a0)
    80004312:	02f00793          	li	a5,47
    80004316:	00f70f63          	beq	a4,a5,80004334 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000431a:	fdafd0ef          	jal	80001af4 <myproc>
    8000431e:	15853503          	ld	a0,344(a0)
    80004322:	94fff0ef          	jal	80003c70 <idup>
    80004326:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004328:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    8000432c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000432e:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004330:	4b85                	li	s7,1
    80004332:	a879                	j	800043d0 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004334:	4585                	li	a1,1
    80004336:	852e                	mv	a0,a1
    80004338:	efcff0ef          	jal	80003a34 <iget>
    8000433c:	8a2a                	mv	s4,a0
    8000433e:	b7ed                	j	80004328 <namex+0x3c>
      iunlockput(ip);
    80004340:	8552                	mv	a0,s4
    80004342:	b71ff0ef          	jal	80003eb2 <iunlockput>
      return 0;
    80004346:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004348:	8552                	mv	a0,s4
    8000434a:	60e6                	ld	ra,88(sp)
    8000434c:	6446                	ld	s0,80(sp)
    8000434e:	64a6                	ld	s1,72(sp)
    80004350:	6906                	ld	s2,64(sp)
    80004352:	79e2                	ld	s3,56(sp)
    80004354:	7a42                	ld	s4,48(sp)
    80004356:	7aa2                	ld	s5,40(sp)
    80004358:	7b02                	ld	s6,32(sp)
    8000435a:	6be2                	ld	s7,24(sp)
    8000435c:	6c42                	ld	s8,16(sp)
    8000435e:	6ca2                	ld	s9,8(sp)
    80004360:	6d02                	ld	s10,0(sp)
    80004362:	6125                	addi	sp,sp,96
    80004364:	8082                	ret
      iunlock(ip);
    80004366:	8552                	mv	a0,s4
    80004368:	9edff0ef          	jal	80003d54 <iunlock>
      return ip;
    8000436c:	bff1                	j	80004348 <namex+0x5c>
      iunlockput(ip);
    8000436e:	8552                	mv	a0,s4
    80004370:	b43ff0ef          	jal	80003eb2 <iunlockput>
      return 0;
    80004374:	8a4a                	mv	s4,s2
    80004376:	bfc9                	j	80004348 <namex+0x5c>
  len = path - s;
    80004378:	40990633          	sub	a2,s2,s1
    8000437c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004380:	09ac5463          	bge	s8,s10,80004408 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80004384:	8666                	mv	a2,s9
    80004386:	85a6                	mv	a1,s1
    80004388:	8556                	mv	a0,s5
    8000438a:	9cffc0ef          	jal	80000d58 <memmove>
    8000438e:	84ca                	mv	s1,s2
  while(*path == '/')
    80004390:	0004c783          	lbu	a5,0(s1)
    80004394:	01379763          	bne	a5,s3,800043a2 <namex+0xb6>
    path++;
    80004398:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000439a:	0004c783          	lbu	a5,0(s1)
    8000439e:	ff378de3          	beq	a5,s3,80004398 <namex+0xac>
    ilock(ip);
    800043a2:	8552                	mv	a0,s4
    800043a4:	903ff0ef          	jal	80003ca6 <ilock>
    if(ip->type != T_DIR){
    800043a8:	044a1783          	lh	a5,68(s4)
    800043ac:	f9779ae3          	bne	a5,s7,80004340 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800043b0:	000b0563          	beqz	s6,800043ba <namex+0xce>
    800043b4:	0004c783          	lbu	a5,0(s1)
    800043b8:	d7dd                	beqz	a5,80004366 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043ba:	4601                	li	a2,0
    800043bc:	85d6                	mv	a1,s5
    800043be:	8552                	mv	a0,s4
    800043c0:	e81ff0ef          	jal	80004240 <dirlookup>
    800043c4:	892a                	mv	s2,a0
    800043c6:	d545                	beqz	a0,8000436e <namex+0x82>
    iunlockput(ip);
    800043c8:	8552                	mv	a0,s4
    800043ca:	ae9ff0ef          	jal	80003eb2 <iunlockput>
    ip = next;
    800043ce:	8a4a                	mv	s4,s2
  while(*path == '/')
    800043d0:	0004c783          	lbu	a5,0(s1)
    800043d4:	01379763          	bne	a5,s3,800043e2 <namex+0xf6>
    path++;
    800043d8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043da:	0004c783          	lbu	a5,0(s1)
    800043de:	ff378de3          	beq	a5,s3,800043d8 <namex+0xec>
  if(*path == 0)
    800043e2:	cf8d                	beqz	a5,8000441c <namex+0x130>
  while(*path != '/' && *path != 0)
    800043e4:	0004c783          	lbu	a5,0(s1)
    800043e8:	fd178713          	addi	a4,a5,-47
    800043ec:	cb19                	beqz	a4,80004402 <namex+0x116>
    800043ee:	cb91                	beqz	a5,80004402 <namex+0x116>
    800043f0:	8926                	mv	s2,s1
    path++;
    800043f2:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    800043f4:	00094783          	lbu	a5,0(s2)
    800043f8:	fd178713          	addi	a4,a5,-47
    800043fc:	df35                	beqz	a4,80004378 <namex+0x8c>
    800043fe:	fbf5                	bnez	a5,800043f2 <namex+0x106>
    80004400:	bfa5                	j	80004378 <namex+0x8c>
    80004402:	8926                	mv	s2,s1
  len = path - s;
    80004404:	4d01                	li	s10,0
    80004406:	4601                	li	a2,0
    memmove(name, s, len);
    80004408:	2601                	sext.w	a2,a2
    8000440a:	85a6                	mv	a1,s1
    8000440c:	8556                	mv	a0,s5
    8000440e:	94bfc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80004412:	9d56                	add	s10,s10,s5
    80004414:	000d0023          	sb	zero,0(s10)
    80004418:	84ca                	mv	s1,s2
    8000441a:	bf9d                	j	80004390 <namex+0xa4>
  if(nameiparent){
    8000441c:	f20b06e3          	beqz	s6,80004348 <namex+0x5c>
    iput(ip);
    80004420:	8552                	mv	a0,s4
    80004422:	a07ff0ef          	jal	80003e28 <iput>
    return 0;
    80004426:	4a01                	li	s4,0
    80004428:	b705                	j	80004348 <namex+0x5c>

000000008000442a <dirlink>:
{
    8000442a:	715d                	addi	sp,sp,-80
    8000442c:	e486                	sd	ra,72(sp)
    8000442e:	e0a2                	sd	s0,64(sp)
    80004430:	f84a                	sd	s2,48(sp)
    80004432:	ec56                	sd	s5,24(sp)
    80004434:	e85a                	sd	s6,16(sp)
    80004436:	0880                	addi	s0,sp,80
    80004438:	892a                	mv	s2,a0
    8000443a:	8aae                	mv	s5,a1
    8000443c:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000443e:	4601                	li	a2,0
    80004440:	e01ff0ef          	jal	80004240 <dirlookup>
    80004444:	ed1d                	bnez	a0,80004482 <dirlink+0x58>
    80004446:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004448:	04c92483          	lw	s1,76(s2)
    8000444c:	c4b9                	beqz	s1,8000449a <dirlink+0x70>
    8000444e:	f44e                	sd	s3,40(sp)
    80004450:	f052                	sd	s4,32(sp)
    80004452:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004454:	fb040a13          	addi	s4,s0,-80
    80004458:	49c1                	li	s3,16
    8000445a:	874e                	mv	a4,s3
    8000445c:	86a6                	mv	a3,s1
    8000445e:	8652                	mv	a2,s4
    80004460:	4581                	li	a1,0
    80004462:	854a                	mv	a0,s2
    80004464:	bd5ff0ef          	jal	80004038 <readi>
    80004468:	03351163          	bne	a0,s3,8000448a <dirlink+0x60>
    if(de.inum == 0)
    8000446c:	fb045783          	lhu	a5,-80(s0)
    80004470:	c39d                	beqz	a5,80004496 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004472:	24c1                	addiw	s1,s1,16
    80004474:	04c92783          	lw	a5,76(s2)
    80004478:	fef4e1e3          	bltu	s1,a5,8000445a <dirlink+0x30>
    8000447c:	79a2                	ld	s3,40(sp)
    8000447e:	7a02                	ld	s4,32(sp)
    80004480:	a829                	j	8000449a <dirlink+0x70>
    iput(ip);
    80004482:	9a7ff0ef          	jal	80003e28 <iput>
    return -1;
    80004486:	557d                	li	a0,-1
    80004488:	a83d                	j	800044c6 <dirlink+0x9c>
      panic("dirlink read");
    8000448a:	00004517          	auipc	a0,0x4
    8000448e:	4d650513          	addi	a0,a0,1238 # 80008960 <etext+0x960>
    80004492:	b92fc0ef          	jal	80000824 <panic>
    80004496:	79a2                	ld	s3,40(sp)
    80004498:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000449a:	4639                	li	a2,14
    8000449c:	85d6                	mv	a1,s5
    8000449e:	fb240513          	addi	a0,s0,-78
    800044a2:	965fc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    800044a6:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044aa:	4741                	li	a4,16
    800044ac:	86a6                	mv	a3,s1
    800044ae:	fb040613          	addi	a2,s0,-80
    800044b2:	4581                	li	a1,0
    800044b4:	854a                	mv	a0,s2
    800044b6:	c75ff0ef          	jal	8000412a <writei>
    800044ba:	1541                	addi	a0,a0,-16
    800044bc:	00a03533          	snez	a0,a0
    800044c0:	40a0053b          	negw	a0,a0
    800044c4:	74e2                	ld	s1,56(sp)
}
    800044c6:	60a6                	ld	ra,72(sp)
    800044c8:	6406                	ld	s0,64(sp)
    800044ca:	7942                	ld	s2,48(sp)
    800044cc:	6ae2                	ld	s5,24(sp)
    800044ce:	6b42                	ld	s6,16(sp)
    800044d0:	6161                	addi	sp,sp,80
    800044d2:	8082                	ret

00000000800044d4 <namei>:

struct inode*
namei(char *path)
{
    800044d4:	1101                	addi	sp,sp,-32
    800044d6:	ec06                	sd	ra,24(sp)
    800044d8:	e822                	sd	s0,16(sp)
    800044da:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044dc:	fe040613          	addi	a2,s0,-32
    800044e0:	4581                	li	a1,0
    800044e2:	e0bff0ef          	jal	800042ec <namex>
}
    800044e6:	60e2                	ld	ra,24(sp)
    800044e8:	6442                	ld	s0,16(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret

00000000800044ee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044ee:	1141                	addi	sp,sp,-16
    800044f0:	e406                	sd	ra,8(sp)
    800044f2:	e022                	sd	s0,0(sp)
    800044f4:	0800                	addi	s0,sp,16
    800044f6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044f8:	4585                	li	a1,1
    800044fa:	df3ff0ef          	jal	800042ec <namex>
}
    800044fe:	60a2                	ld	ra,8(sp)
    80004500:	6402                	ld	s0,0(sp)
    80004502:	0141                	addi	sp,sp,16
    80004504:	8082                	ret

0000000080004506 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004506:	1101                	addi	sp,sp,-32
    80004508:	ec06                	sd	ra,24(sp)
    8000450a:	e822                	sd	s0,16(sp)
    8000450c:	e426                	sd	s1,8(sp)
    8000450e:	e04a                	sd	s2,0(sp)
    80004510:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004512:	00020917          	auipc	s2,0x20
    80004516:	81690913          	addi	s2,s2,-2026 # 80023d28 <log>
    8000451a:	01892583          	lw	a1,24(s2)
    8000451e:	02492503          	lw	a0,36(s2)
    80004522:	8ecff0ef          	jal	8000360e <bread>
    80004526:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004528:	02892603          	lw	a2,40(s2)
    8000452c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000452e:	00c05f63          	blez	a2,8000454c <write_head+0x46>
    80004532:	00020717          	auipc	a4,0x20
    80004536:	82270713          	addi	a4,a4,-2014 # 80023d54 <log+0x2c>
    8000453a:	87aa                	mv	a5,a0
    8000453c:	060a                	slli	a2,a2,0x2
    8000453e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004540:	4314                	lw	a3,0(a4)
    80004542:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004544:	0711                	addi	a4,a4,4
    80004546:	0791                	addi	a5,a5,4
    80004548:	fec79ce3          	bne	a5,a2,80004540 <write_head+0x3a>
  }
  bwrite(buf);
    8000454c:	8526                	mv	a0,s1
    8000454e:	996ff0ef          	jal	800036e4 <bwrite>
  brelse(buf);
    80004552:	8526                	mv	a0,s1
    80004554:	9c2ff0ef          	jal	80003716 <brelse>
}
    80004558:	60e2                	ld	ra,24(sp)
    8000455a:	6442                	ld	s0,16(sp)
    8000455c:	64a2                	ld	s1,8(sp)
    8000455e:	6902                	ld	s2,0(sp)
    80004560:	6105                	addi	sp,sp,32
    80004562:	8082                	ret

0000000080004564 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004564:	0001f797          	auipc	a5,0x1f
    80004568:	7ec7a783          	lw	a5,2028(a5) # 80023d50 <log+0x28>
    8000456c:	0cf05163          	blez	a5,8000462e <install_trans+0xca>
{
    80004570:	715d                	addi	sp,sp,-80
    80004572:	e486                	sd	ra,72(sp)
    80004574:	e0a2                	sd	s0,64(sp)
    80004576:	fc26                	sd	s1,56(sp)
    80004578:	f84a                	sd	s2,48(sp)
    8000457a:	f44e                	sd	s3,40(sp)
    8000457c:	f052                	sd	s4,32(sp)
    8000457e:	ec56                	sd	s5,24(sp)
    80004580:	e85a                	sd	s6,16(sp)
    80004582:	e45e                	sd	s7,8(sp)
    80004584:	e062                	sd	s8,0(sp)
    80004586:	0880                	addi	s0,sp,80
    80004588:	8b2a                	mv	s6,a0
    8000458a:	0001fa97          	auipc	s5,0x1f
    8000458e:	7caa8a93          	addi	s5,s5,1994 # 80023d54 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004592:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004594:	00004c17          	auipc	s8,0x4
    80004598:	3dcc0c13          	addi	s8,s8,988 # 80008970 <etext+0x970>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000459c:	0001fa17          	auipc	s4,0x1f
    800045a0:	78ca0a13          	addi	s4,s4,1932 # 80023d28 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045a4:	40000b93          	li	s7,1024
    800045a8:	a025                	j	800045d0 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800045aa:	000aa603          	lw	a2,0(s5)
    800045ae:	85ce                	mv	a1,s3
    800045b0:	8562                	mv	a0,s8
    800045b2:	f49fb0ef          	jal	800004fa <printf>
    800045b6:	a839                	j	800045d4 <install_trans+0x70>
    brelse(lbuf);
    800045b8:	854a                	mv	a0,s2
    800045ba:	95cff0ef          	jal	80003716 <brelse>
    brelse(dbuf);
    800045be:	8526                	mv	a0,s1
    800045c0:	956ff0ef          	jal	80003716 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045c4:	2985                	addiw	s3,s3,1
    800045c6:	0a91                	addi	s5,s5,4
    800045c8:	028a2783          	lw	a5,40(s4)
    800045cc:	04f9d563          	bge	s3,a5,80004616 <install_trans+0xb2>
    if(recovering) {
    800045d0:	fc0b1de3          	bnez	s6,800045aa <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045d4:	018a2583          	lw	a1,24(s4)
    800045d8:	013585bb          	addw	a1,a1,s3
    800045dc:	2585                	addiw	a1,a1,1
    800045de:	024a2503          	lw	a0,36(s4)
    800045e2:	82cff0ef          	jal	8000360e <bread>
    800045e6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045e8:	000aa583          	lw	a1,0(s5)
    800045ec:	024a2503          	lw	a0,36(s4)
    800045f0:	81eff0ef          	jal	8000360e <bread>
    800045f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045f6:	865e                	mv	a2,s7
    800045f8:	05890593          	addi	a1,s2,88
    800045fc:	05850513          	addi	a0,a0,88
    80004600:	f58fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004604:	8526                	mv	a0,s1
    80004606:	8deff0ef          	jal	800036e4 <bwrite>
    if(recovering == 0)
    8000460a:	fa0b17e3          	bnez	s6,800045b8 <install_trans+0x54>
      bunpin(dbuf);
    8000460e:	8526                	mv	a0,s1
    80004610:	9beff0ef          	jal	800037ce <bunpin>
    80004614:	b755                	j	800045b8 <install_trans+0x54>
}
    80004616:	60a6                	ld	ra,72(sp)
    80004618:	6406                	ld	s0,64(sp)
    8000461a:	74e2                	ld	s1,56(sp)
    8000461c:	7942                	ld	s2,48(sp)
    8000461e:	79a2                	ld	s3,40(sp)
    80004620:	7a02                	ld	s4,32(sp)
    80004622:	6ae2                	ld	s5,24(sp)
    80004624:	6b42                	ld	s6,16(sp)
    80004626:	6ba2                	ld	s7,8(sp)
    80004628:	6c02                	ld	s8,0(sp)
    8000462a:	6161                	addi	sp,sp,80
    8000462c:	8082                	ret
    8000462e:	8082                	ret

0000000080004630 <initlog>:
{
    80004630:	7179                	addi	sp,sp,-48
    80004632:	f406                	sd	ra,40(sp)
    80004634:	f022                	sd	s0,32(sp)
    80004636:	ec26                	sd	s1,24(sp)
    80004638:	e84a                	sd	s2,16(sp)
    8000463a:	e44e                	sd	s3,8(sp)
    8000463c:	1800                	addi	s0,sp,48
    8000463e:	84aa                	mv	s1,a0
    80004640:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004642:	0001f917          	auipc	s2,0x1f
    80004646:	6e690913          	addi	s2,s2,1766 # 80023d28 <log>
    8000464a:	00004597          	auipc	a1,0x4
    8000464e:	34658593          	addi	a1,a1,838 # 80008990 <etext+0x990>
    80004652:	854a                	mv	a0,s2
    80004654:	d4afc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80004658:	0149a583          	lw	a1,20(s3)
    8000465c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80004660:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80004664:	8526                	mv	a0,s1
    80004666:	fa9fe0ef          	jal	8000360e <bread>
  log.lh.n = lh->n;
    8000466a:	4d30                	lw	a2,88(a0)
    8000466c:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80004670:	00c05f63          	blez	a2,8000468e <initlog+0x5e>
    80004674:	87aa                	mv	a5,a0
    80004676:	0001f717          	auipc	a4,0x1f
    8000467a:	6de70713          	addi	a4,a4,1758 # 80023d54 <log+0x2c>
    8000467e:	060a                	slli	a2,a2,0x2
    80004680:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004682:	4ff4                	lw	a3,92(a5)
    80004684:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004686:	0791                	addi	a5,a5,4
    80004688:	0711                	addi	a4,a4,4
    8000468a:	fec79ce3          	bne	a5,a2,80004682 <initlog+0x52>
  brelse(buf);
    8000468e:	888ff0ef          	jal	80003716 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004692:	4505                	li	a0,1
    80004694:	ed1ff0ef          	jal	80004564 <install_trans>
  log.lh.n = 0;
    80004698:	0001f797          	auipc	a5,0x1f
    8000469c:	6a07ac23          	sw	zero,1720(a5) # 80023d50 <log+0x28>
  write_head(); // clear the log
    800046a0:	e67ff0ef          	jal	80004506 <write_head>
}
    800046a4:	70a2                	ld	ra,40(sp)
    800046a6:	7402                	ld	s0,32(sp)
    800046a8:	64e2                	ld	s1,24(sp)
    800046aa:	6942                	ld	s2,16(sp)
    800046ac:	69a2                	ld	s3,8(sp)
    800046ae:	6145                	addi	sp,sp,48
    800046b0:	8082                	ret

00000000800046b2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046b2:	1101                	addi	sp,sp,-32
    800046b4:	ec06                	sd	ra,24(sp)
    800046b6:	e822                	sd	s0,16(sp)
    800046b8:	e426                	sd	s1,8(sp)
    800046ba:	e04a                	sd	s2,0(sp)
    800046bc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046be:	0001f517          	auipc	a0,0x1f
    800046c2:	66a50513          	addi	a0,a0,1642 # 80023d28 <log>
    800046c6:	d62fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    800046ca:	0001f497          	auipc	s1,0x1f
    800046ce:	65e48493          	addi	s1,s1,1630 # 80023d28 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800046d2:	4979                	li	s2,30
    800046d4:	a029                	j	800046de <begin_op+0x2c>
      sleep(&log, &log.lock);
    800046d6:	85a6                	mv	a1,s1
    800046d8:	8526                	mv	a0,s1
    800046da:	8c6fe0ef          	jal	800027a0 <sleep>
    if(log.committing){
    800046de:	509c                	lw	a5,32(s1)
    800046e0:	fbfd                	bnez	a5,800046d6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800046e2:	4cd8                	lw	a4,28(s1)
    800046e4:	2705                	addiw	a4,a4,1
    800046e6:	0027179b          	slliw	a5,a4,0x2
    800046ea:	9fb9                	addw	a5,a5,a4
    800046ec:	0017979b          	slliw	a5,a5,0x1
    800046f0:	5494                	lw	a3,40(s1)
    800046f2:	9fb5                	addw	a5,a5,a3
    800046f4:	00f95763          	bge	s2,a5,80004702 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046f8:	85a6                	mv	a1,s1
    800046fa:	8526                	mv	a0,s1
    800046fc:	8a4fe0ef          	jal	800027a0 <sleep>
    80004700:	bff9                	j	800046de <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004702:	0001f797          	auipc	a5,0x1f
    80004706:	64e7a123          	sw	a4,1602(a5) # 80023d44 <log+0x1c>
      release(&log.lock);
    8000470a:	0001f517          	auipc	a0,0x1f
    8000470e:	61e50513          	addi	a0,a0,1566 # 80023d28 <log>
    80004712:	daafc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80004716:	60e2                	ld	ra,24(sp)
    80004718:	6442                	ld	s0,16(sp)
    8000471a:	64a2                	ld	s1,8(sp)
    8000471c:	6902                	ld	s2,0(sp)
    8000471e:	6105                	addi	sp,sp,32
    80004720:	8082                	ret

0000000080004722 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004722:	7139                	addi	sp,sp,-64
    80004724:	fc06                	sd	ra,56(sp)
    80004726:	f822                	sd	s0,48(sp)
    80004728:	f426                	sd	s1,40(sp)
    8000472a:	f04a                	sd	s2,32(sp)
    8000472c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000472e:	0001f497          	auipc	s1,0x1f
    80004732:	5fa48493          	addi	s1,s1,1530 # 80023d28 <log>
    80004736:	8526                	mv	a0,s1
    80004738:	cf0fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    8000473c:	4cdc                	lw	a5,28(s1)
    8000473e:	37fd                	addiw	a5,a5,-1
    80004740:	893e                	mv	s2,a5
    80004742:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004744:	509c                	lw	a5,32(s1)
    80004746:	e7b1                	bnez	a5,80004792 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004748:	04091e63          	bnez	s2,800047a4 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    8000474c:	0001f497          	auipc	s1,0x1f
    80004750:	5dc48493          	addi	s1,s1,1500 # 80023d28 <log>
    80004754:	4785                	li	a5,1
    80004756:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004758:	8526                	mv	a0,s1
    8000475a:	d62fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000475e:	549c                	lw	a5,40(s1)
    80004760:	06f04463          	bgtz	a5,800047c8 <end_op+0xa6>
    acquire(&log.lock);
    80004764:	0001f517          	auipc	a0,0x1f
    80004768:	5c450513          	addi	a0,a0,1476 # 80023d28 <log>
    8000476c:	cbcfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004770:	0001f797          	auipc	a5,0x1f
    80004774:	5c07ac23          	sw	zero,1496(a5) # 80023d48 <log+0x20>
    wakeup(&log);
    80004778:	0001f517          	auipc	a0,0x1f
    8000477c:	5b050513          	addi	a0,a0,1456 # 80023d28 <log>
    80004780:	86cfe0ef          	jal	800027ec <wakeup>
    release(&log.lock);
    80004784:	0001f517          	auipc	a0,0x1f
    80004788:	5a450513          	addi	a0,a0,1444 # 80023d28 <log>
    8000478c:	d30fc0ef          	jal	80000cbc <release>
}
    80004790:	a035                	j	800047bc <end_op+0x9a>
    80004792:	ec4e                	sd	s3,24(sp)
    80004794:	e852                	sd	s4,16(sp)
    80004796:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004798:	00004517          	auipc	a0,0x4
    8000479c:	20050513          	addi	a0,a0,512 # 80008998 <etext+0x998>
    800047a0:	884fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    800047a4:	0001f517          	auipc	a0,0x1f
    800047a8:	58450513          	addi	a0,a0,1412 # 80023d28 <log>
    800047ac:	840fe0ef          	jal	800027ec <wakeup>
  release(&log.lock);
    800047b0:	0001f517          	auipc	a0,0x1f
    800047b4:	57850513          	addi	a0,a0,1400 # 80023d28 <log>
    800047b8:	d04fc0ef          	jal	80000cbc <release>
}
    800047bc:	70e2                	ld	ra,56(sp)
    800047be:	7442                	ld	s0,48(sp)
    800047c0:	74a2                	ld	s1,40(sp)
    800047c2:	7902                	ld	s2,32(sp)
    800047c4:	6121                	addi	sp,sp,64
    800047c6:	8082                	ret
    800047c8:	ec4e                	sd	s3,24(sp)
    800047ca:	e852                	sd	s4,16(sp)
    800047cc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ce:	0001fa97          	auipc	s5,0x1f
    800047d2:	586a8a93          	addi	s5,s5,1414 # 80023d54 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047d6:	0001fa17          	auipc	s4,0x1f
    800047da:	552a0a13          	addi	s4,s4,1362 # 80023d28 <log>
    800047de:	018a2583          	lw	a1,24(s4)
    800047e2:	012585bb          	addw	a1,a1,s2
    800047e6:	2585                	addiw	a1,a1,1
    800047e8:	024a2503          	lw	a0,36(s4)
    800047ec:	e23fe0ef          	jal	8000360e <bread>
    800047f0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047f2:	000aa583          	lw	a1,0(s5)
    800047f6:	024a2503          	lw	a0,36(s4)
    800047fa:	e15fe0ef          	jal	8000360e <bread>
    800047fe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004800:	40000613          	li	a2,1024
    80004804:	05850593          	addi	a1,a0,88
    80004808:	05848513          	addi	a0,s1,88
    8000480c:	d4cfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80004810:	8526                	mv	a0,s1
    80004812:	ed3fe0ef          	jal	800036e4 <bwrite>
    brelse(from);
    80004816:	854e                	mv	a0,s3
    80004818:	efffe0ef          	jal	80003716 <brelse>
    brelse(to);
    8000481c:	8526                	mv	a0,s1
    8000481e:	ef9fe0ef          	jal	80003716 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004822:	2905                	addiw	s2,s2,1
    80004824:	0a91                	addi	s5,s5,4
    80004826:	028a2783          	lw	a5,40(s4)
    8000482a:	faf94ae3          	blt	s2,a5,800047de <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000482e:	cd9ff0ef          	jal	80004506 <write_head>
    install_trans(0); // Now install writes to home locations
    80004832:	4501                	li	a0,0
    80004834:	d31ff0ef          	jal	80004564 <install_trans>
    log.lh.n = 0;
    80004838:	0001f797          	auipc	a5,0x1f
    8000483c:	5007ac23          	sw	zero,1304(a5) # 80023d50 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004840:	cc7ff0ef          	jal	80004506 <write_head>
    80004844:	69e2                	ld	s3,24(sp)
    80004846:	6a42                	ld	s4,16(sp)
    80004848:	6aa2                	ld	s5,8(sp)
    8000484a:	bf29                	j	80004764 <end_op+0x42>

000000008000484c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000484c:	1101                	addi	sp,sp,-32
    8000484e:	ec06                	sd	ra,24(sp)
    80004850:	e822                	sd	s0,16(sp)
    80004852:	e426                	sd	s1,8(sp)
    80004854:	1000                	addi	s0,sp,32
    80004856:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004858:	0001f517          	auipc	a0,0x1f
    8000485c:	4d050513          	addi	a0,a0,1232 # 80023d28 <log>
    80004860:	bc8fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004864:	0001f617          	auipc	a2,0x1f
    80004868:	4ec62603          	lw	a2,1260(a2) # 80023d50 <log+0x28>
    8000486c:	47f5                	li	a5,29
    8000486e:	04c7cd63          	blt	a5,a2,800048c8 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004872:	0001f797          	auipc	a5,0x1f
    80004876:	4d27a783          	lw	a5,1234(a5) # 80023d44 <log+0x1c>
    8000487a:	04f05d63          	blez	a5,800048d4 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000487e:	4781                	li	a5,0
    80004880:	06c05063          	blez	a2,800048e0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004884:	44cc                	lw	a1,12(s1)
    80004886:	0001f717          	auipc	a4,0x1f
    8000488a:	4ce70713          	addi	a4,a4,1230 # 80023d54 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000488e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004890:	4314                	lw	a3,0(a4)
    80004892:	04b68763          	beq	a3,a1,800048e0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004896:	2785                	addiw	a5,a5,1
    80004898:	0711                	addi	a4,a4,4
    8000489a:	fef61be3          	bne	a2,a5,80004890 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000489e:	060a                	slli	a2,a2,0x2
    800048a0:	02060613          	addi	a2,a2,32
    800048a4:	0001f797          	auipc	a5,0x1f
    800048a8:	48478793          	addi	a5,a5,1156 # 80023d28 <log>
    800048ac:	97b2                	add	a5,a5,a2
    800048ae:	44d8                	lw	a4,12(s1)
    800048b0:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048b2:	8526                	mv	a0,s1
    800048b4:	ee7fe0ef          	jal	8000379a <bpin>
    log.lh.n++;
    800048b8:	0001f717          	auipc	a4,0x1f
    800048bc:	47070713          	addi	a4,a4,1136 # 80023d28 <log>
    800048c0:	571c                	lw	a5,40(a4)
    800048c2:	2785                	addiw	a5,a5,1
    800048c4:	d71c                	sw	a5,40(a4)
    800048c6:	a815                	j	800048fa <log_write+0xae>
    panic("too big a transaction");
    800048c8:	00004517          	auipc	a0,0x4
    800048cc:	0e050513          	addi	a0,a0,224 # 800089a8 <etext+0x9a8>
    800048d0:	f55fb0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    800048d4:	00004517          	auipc	a0,0x4
    800048d8:	0ec50513          	addi	a0,a0,236 # 800089c0 <etext+0x9c0>
    800048dc:	f49fb0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800048e0:	00279693          	slli	a3,a5,0x2
    800048e4:	02068693          	addi	a3,a3,32
    800048e8:	0001f717          	auipc	a4,0x1f
    800048ec:	44070713          	addi	a4,a4,1088 # 80023d28 <log>
    800048f0:	9736                	add	a4,a4,a3
    800048f2:	44d4                	lw	a3,12(s1)
    800048f4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048f6:	faf60ee3          	beq	a2,a5,800048b2 <log_write+0x66>
  }
  release(&log.lock);
    800048fa:	0001f517          	auipc	a0,0x1f
    800048fe:	42e50513          	addi	a0,a0,1070 # 80023d28 <log>
    80004902:	bbafc0ef          	jal	80000cbc <release>
}
    80004906:	60e2                	ld	ra,24(sp)
    80004908:	6442                	ld	s0,16(sp)
    8000490a:	64a2                	ld	s1,8(sp)
    8000490c:	6105                	addi	sp,sp,32
    8000490e:	8082                	ret

0000000080004910 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004910:	1101                	addi	sp,sp,-32
    80004912:	ec06                	sd	ra,24(sp)
    80004914:	e822                	sd	s0,16(sp)
    80004916:	e426                	sd	s1,8(sp)
    80004918:	e04a                	sd	s2,0(sp)
    8000491a:	1000                	addi	s0,sp,32
    8000491c:	84aa                	mv	s1,a0
    8000491e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004920:	00004597          	auipc	a1,0x4
    80004924:	0c058593          	addi	a1,a1,192 # 800089e0 <etext+0x9e0>
    80004928:	0521                	addi	a0,a0,8
    8000492a:	a74fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    8000492e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004932:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004936:	0204a423          	sw	zero,40(s1)
}
    8000493a:	60e2                	ld	ra,24(sp)
    8000493c:	6442                	ld	s0,16(sp)
    8000493e:	64a2                	ld	s1,8(sp)
    80004940:	6902                	ld	s2,0(sp)
    80004942:	6105                	addi	sp,sp,32
    80004944:	8082                	ret

0000000080004946 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004946:	1101                	addi	sp,sp,-32
    80004948:	ec06                	sd	ra,24(sp)
    8000494a:	e822                	sd	s0,16(sp)
    8000494c:	e426                	sd	s1,8(sp)
    8000494e:	e04a                	sd	s2,0(sp)
    80004950:	1000                	addi	s0,sp,32
    80004952:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004954:	00850913          	addi	s2,a0,8
    80004958:	854a                	mv	a0,s2
    8000495a:	acefc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000495e:	409c                	lw	a5,0(s1)
    80004960:	c799                	beqz	a5,8000496e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004962:	85ca                	mv	a1,s2
    80004964:	8526                	mv	a0,s1
    80004966:	e3bfd0ef          	jal	800027a0 <sleep>
  while (lk->locked) {
    8000496a:	409c                	lw	a5,0(s1)
    8000496c:	fbfd                	bnez	a5,80004962 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000496e:	4785                	li	a5,1
    80004970:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004972:	982fd0ef          	jal	80001af4 <myproc>
    80004976:	591c                	lw	a5,48(a0)
    80004978:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000497a:	854a                	mv	a0,s2
    8000497c:	b40fc0ef          	jal	80000cbc <release>
}
    80004980:	60e2                	ld	ra,24(sp)
    80004982:	6442                	ld	s0,16(sp)
    80004984:	64a2                	ld	s1,8(sp)
    80004986:	6902                	ld	s2,0(sp)
    80004988:	6105                	addi	sp,sp,32
    8000498a:	8082                	ret

000000008000498c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000498c:	1101                	addi	sp,sp,-32
    8000498e:	ec06                	sd	ra,24(sp)
    80004990:	e822                	sd	s0,16(sp)
    80004992:	e426                	sd	s1,8(sp)
    80004994:	e04a                	sd	s2,0(sp)
    80004996:	1000                	addi	s0,sp,32
    80004998:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000499a:	00850913          	addi	s2,a0,8
    8000499e:	854a                	mv	a0,s2
    800049a0:	a88fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800049a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049a8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049ac:	8526                	mv	a0,s1
    800049ae:	e3ffd0ef          	jal	800027ec <wakeup>
  release(&lk->lk);
    800049b2:	854a                	mv	a0,s2
    800049b4:	b08fc0ef          	jal	80000cbc <release>
}
    800049b8:	60e2                	ld	ra,24(sp)
    800049ba:	6442                	ld	s0,16(sp)
    800049bc:	64a2                	ld	s1,8(sp)
    800049be:	6902                	ld	s2,0(sp)
    800049c0:	6105                	addi	sp,sp,32
    800049c2:	8082                	ret

00000000800049c4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049c4:	7179                	addi	sp,sp,-48
    800049c6:	f406                	sd	ra,40(sp)
    800049c8:	f022                	sd	s0,32(sp)
    800049ca:	ec26                	sd	s1,24(sp)
    800049cc:	e84a                	sd	s2,16(sp)
    800049ce:	1800                	addi	s0,sp,48
    800049d0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049d2:	00850913          	addi	s2,a0,8
    800049d6:	854a                	mv	a0,s2
    800049d8:	a50fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049dc:	409c                	lw	a5,0(s1)
    800049de:	ef81                	bnez	a5,800049f6 <holdingsleep+0x32>
    800049e0:	4481                	li	s1,0
  release(&lk->lk);
    800049e2:	854a                	mv	a0,s2
    800049e4:	ad8fc0ef          	jal	80000cbc <release>
  return r;
}
    800049e8:	8526                	mv	a0,s1
    800049ea:	70a2                	ld	ra,40(sp)
    800049ec:	7402                	ld	s0,32(sp)
    800049ee:	64e2                	ld	s1,24(sp)
    800049f0:	6942                	ld	s2,16(sp)
    800049f2:	6145                	addi	sp,sp,48
    800049f4:	8082                	ret
    800049f6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800049f8:	0284a983          	lw	s3,40(s1)
    800049fc:	8f8fd0ef          	jal	80001af4 <myproc>
    80004a00:	5904                	lw	s1,48(a0)
    80004a02:	413484b3          	sub	s1,s1,s3
    80004a06:	0014b493          	seqz	s1,s1
    80004a0a:	69a2                	ld	s3,8(sp)
    80004a0c:	bfd9                	j	800049e2 <holdingsleep+0x1e>

0000000080004a0e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a0e:	1141                	addi	sp,sp,-16
    80004a10:	e406                	sd	ra,8(sp)
    80004a12:	e022                	sd	s0,0(sp)
    80004a14:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a16:	00004597          	auipc	a1,0x4
    80004a1a:	fda58593          	addi	a1,a1,-38 # 800089f0 <etext+0x9f0>
    80004a1e:	0001f517          	auipc	a0,0x1f
    80004a22:	45250513          	addi	a0,a0,1106 # 80023e70 <ftable>
    80004a26:	978fc0ef          	jal	80000b9e <initlock>
}
    80004a2a:	60a2                	ld	ra,8(sp)
    80004a2c:	6402                	ld	s0,0(sp)
    80004a2e:	0141                	addi	sp,sp,16
    80004a30:	8082                	ret

0000000080004a32 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a32:	1101                	addi	sp,sp,-32
    80004a34:	ec06                	sd	ra,24(sp)
    80004a36:	e822                	sd	s0,16(sp)
    80004a38:	e426                	sd	s1,8(sp)
    80004a3a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a3c:	0001f517          	auipc	a0,0x1f
    80004a40:	43450513          	addi	a0,a0,1076 # 80023e70 <ftable>
    80004a44:	9e4fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a48:	0001f497          	auipc	s1,0x1f
    80004a4c:	44048493          	addi	s1,s1,1088 # 80023e88 <ftable+0x18>
    80004a50:	00020717          	auipc	a4,0x20
    80004a54:	3d870713          	addi	a4,a4,984 # 80024e28 <disk>
    if(f->ref == 0){
    80004a58:	40dc                	lw	a5,4(s1)
    80004a5a:	cf89                	beqz	a5,80004a74 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a5c:	02848493          	addi	s1,s1,40
    80004a60:	fee49ce3          	bne	s1,a4,80004a58 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a64:	0001f517          	auipc	a0,0x1f
    80004a68:	40c50513          	addi	a0,a0,1036 # 80023e70 <ftable>
    80004a6c:	a50fc0ef          	jal	80000cbc <release>
  return 0;
    80004a70:	4481                	li	s1,0
    80004a72:	a809                	j	80004a84 <filealloc+0x52>
      f->ref = 1;
    80004a74:	4785                	li	a5,1
    80004a76:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a78:	0001f517          	auipc	a0,0x1f
    80004a7c:	3f850513          	addi	a0,a0,1016 # 80023e70 <ftable>
    80004a80:	a3cfc0ef          	jal	80000cbc <release>
}
    80004a84:	8526                	mv	a0,s1
    80004a86:	60e2                	ld	ra,24(sp)
    80004a88:	6442                	ld	s0,16(sp)
    80004a8a:	64a2                	ld	s1,8(sp)
    80004a8c:	6105                	addi	sp,sp,32
    80004a8e:	8082                	ret

0000000080004a90 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a90:	1101                	addi	sp,sp,-32
    80004a92:	ec06                	sd	ra,24(sp)
    80004a94:	e822                	sd	s0,16(sp)
    80004a96:	e426                	sd	s1,8(sp)
    80004a98:	1000                	addi	s0,sp,32
    80004a9a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a9c:	0001f517          	auipc	a0,0x1f
    80004aa0:	3d450513          	addi	a0,a0,980 # 80023e70 <ftable>
    80004aa4:	984fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004aa8:	40dc                	lw	a5,4(s1)
    80004aaa:	02f05063          	blez	a5,80004aca <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004aae:	2785                	addiw	a5,a5,1
    80004ab0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ab2:	0001f517          	auipc	a0,0x1f
    80004ab6:	3be50513          	addi	a0,a0,958 # 80023e70 <ftable>
    80004aba:	a02fc0ef          	jal	80000cbc <release>
  return f;
}
    80004abe:	8526                	mv	a0,s1
    80004ac0:	60e2                	ld	ra,24(sp)
    80004ac2:	6442                	ld	s0,16(sp)
    80004ac4:	64a2                	ld	s1,8(sp)
    80004ac6:	6105                	addi	sp,sp,32
    80004ac8:	8082                	ret
    panic("filedup");
    80004aca:	00004517          	auipc	a0,0x4
    80004ace:	f2e50513          	addi	a0,a0,-210 # 800089f8 <etext+0x9f8>
    80004ad2:	d53fb0ef          	jal	80000824 <panic>

0000000080004ad6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ad6:	7139                	addi	sp,sp,-64
    80004ad8:	fc06                	sd	ra,56(sp)
    80004ada:	f822                	sd	s0,48(sp)
    80004adc:	f426                	sd	s1,40(sp)
    80004ade:	0080                	addi	s0,sp,64
    80004ae0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ae2:	0001f517          	auipc	a0,0x1f
    80004ae6:	38e50513          	addi	a0,a0,910 # 80023e70 <ftable>
    80004aea:	93efc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004aee:	40dc                	lw	a5,4(s1)
    80004af0:	04f05a63          	blez	a5,80004b44 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004af4:	37fd                	addiw	a5,a5,-1
    80004af6:	c0dc                	sw	a5,4(s1)
    80004af8:	06f04063          	bgtz	a5,80004b58 <fileclose+0x82>
    80004afc:	f04a                	sd	s2,32(sp)
    80004afe:	ec4e                	sd	s3,24(sp)
    80004b00:	e852                	sd	s4,16(sp)
    80004b02:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b04:	0004a903          	lw	s2,0(s1)
    80004b08:	0094c783          	lbu	a5,9(s1)
    80004b0c:	89be                	mv	s3,a5
    80004b0e:	689c                	ld	a5,16(s1)
    80004b10:	8a3e                	mv	s4,a5
    80004b12:	6c9c                	ld	a5,24(s1)
    80004b14:	8abe                	mv	s5,a5
  f->ref = 0;
    80004b16:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b1a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b1e:	0001f517          	auipc	a0,0x1f
    80004b22:	35250513          	addi	a0,a0,850 # 80023e70 <ftable>
    80004b26:	996fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004b2a:	4785                	li	a5,1
    80004b2c:	04f90163          	beq	s2,a5,80004b6e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b30:	ffe9079b          	addiw	a5,s2,-2
    80004b34:	4705                	li	a4,1
    80004b36:	04f77563          	bgeu	a4,a5,80004b80 <fileclose+0xaa>
    80004b3a:	7902                	ld	s2,32(sp)
    80004b3c:	69e2                	ld	s3,24(sp)
    80004b3e:	6a42                	ld	s4,16(sp)
    80004b40:	6aa2                	ld	s5,8(sp)
    80004b42:	a00d                	j	80004b64 <fileclose+0x8e>
    80004b44:	f04a                	sd	s2,32(sp)
    80004b46:	ec4e                	sd	s3,24(sp)
    80004b48:	e852                	sd	s4,16(sp)
    80004b4a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004b4c:	00004517          	auipc	a0,0x4
    80004b50:	eb450513          	addi	a0,a0,-332 # 80008a00 <etext+0xa00>
    80004b54:	cd1fb0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004b58:	0001f517          	auipc	a0,0x1f
    80004b5c:	31850513          	addi	a0,a0,792 # 80023e70 <ftable>
    80004b60:	95cfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004b64:	70e2                	ld	ra,56(sp)
    80004b66:	7442                	ld	s0,48(sp)
    80004b68:	74a2                	ld	s1,40(sp)
    80004b6a:	6121                	addi	sp,sp,64
    80004b6c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b6e:	85ce                	mv	a1,s3
    80004b70:	8552                	mv	a0,s4
    80004b72:	380000ef          	jal	80004ef2 <pipeclose>
    80004b76:	7902                	ld	s2,32(sp)
    80004b78:	69e2                	ld	s3,24(sp)
    80004b7a:	6a42                	ld	s4,16(sp)
    80004b7c:	6aa2                	ld	s5,8(sp)
    80004b7e:	b7dd                	j	80004b64 <fileclose+0x8e>
    begin_op();
    80004b80:	b33ff0ef          	jal	800046b2 <begin_op>
    iput(ff.ip);
    80004b84:	8556                	mv	a0,s5
    80004b86:	aa2ff0ef          	jal	80003e28 <iput>
    end_op();
    80004b8a:	b99ff0ef          	jal	80004722 <end_op>
    80004b8e:	7902                	ld	s2,32(sp)
    80004b90:	69e2                	ld	s3,24(sp)
    80004b92:	6a42                	ld	s4,16(sp)
    80004b94:	6aa2                	ld	s5,8(sp)
    80004b96:	b7f9                	j	80004b64 <fileclose+0x8e>

0000000080004b98 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b98:	715d                	addi	sp,sp,-80
    80004b9a:	e486                	sd	ra,72(sp)
    80004b9c:	e0a2                	sd	s0,64(sp)
    80004b9e:	fc26                	sd	s1,56(sp)
    80004ba0:	f052                	sd	s4,32(sp)
    80004ba2:	0880                	addi	s0,sp,80
    80004ba4:	84aa                	mv	s1,a0
    80004ba6:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004ba8:	f4dfc0ef          	jal	80001af4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bac:	409c                	lw	a5,0(s1)
    80004bae:	37f9                	addiw	a5,a5,-2
    80004bb0:	4705                	li	a4,1
    80004bb2:	04f76263          	bltu	a4,a5,80004bf6 <filestat+0x5e>
    80004bb6:	f84a                	sd	s2,48(sp)
    80004bb8:	f44e                	sd	s3,40(sp)
    80004bba:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004bbc:	6c88                	ld	a0,24(s1)
    80004bbe:	8e8ff0ef          	jal	80003ca6 <ilock>
    stati(f->ip, &st);
    80004bc2:	fb840913          	addi	s2,s0,-72
    80004bc6:	85ca                	mv	a1,s2
    80004bc8:	6c88                	ld	a0,24(s1)
    80004bca:	c40ff0ef          	jal	8000400a <stati>
    iunlock(f->ip);
    80004bce:	6c88                	ld	a0,24(s1)
    80004bd0:	984ff0ef          	jal	80003d54 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bd4:	46e1                	li	a3,24
    80004bd6:	864a                	mv	a2,s2
    80004bd8:	85d2                	mv	a1,s4
    80004bda:	0589b503          	ld	a0,88(s3)
    80004bde:	a77fc0ef          	jal	80001654 <copyout>
    80004be2:	41f5551b          	sraiw	a0,a0,0x1f
    80004be6:	7942                	ld	s2,48(sp)
    80004be8:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004bea:	60a6                	ld	ra,72(sp)
    80004bec:	6406                	ld	s0,64(sp)
    80004bee:	74e2                	ld	s1,56(sp)
    80004bf0:	7a02                	ld	s4,32(sp)
    80004bf2:	6161                	addi	sp,sp,80
    80004bf4:	8082                	ret
  return -1;
    80004bf6:	557d                	li	a0,-1
    80004bf8:	bfcd                	j	80004bea <filestat+0x52>

0000000080004bfa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bfa:	7179                	addi	sp,sp,-48
    80004bfc:	f406                	sd	ra,40(sp)
    80004bfe:	f022                	sd	s0,32(sp)
    80004c00:	e84a                	sd	s2,16(sp)
    80004c02:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c04:	00854783          	lbu	a5,8(a0)
    80004c08:	cfd1                	beqz	a5,80004ca4 <fileread+0xaa>
    80004c0a:	ec26                	sd	s1,24(sp)
    80004c0c:	e44e                	sd	s3,8(sp)
    80004c0e:	84aa                	mv	s1,a0
    80004c10:	892e                	mv	s2,a1
    80004c12:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c14:	411c                	lw	a5,0(a0)
    80004c16:	4705                	li	a4,1
    80004c18:	04e78363          	beq	a5,a4,80004c5e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c1c:	470d                	li	a4,3
    80004c1e:	04e78763          	beq	a5,a4,80004c6c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c22:	4709                	li	a4,2
    80004c24:	06e79a63          	bne	a5,a4,80004c98 <fileread+0x9e>
    ilock(f->ip);
    80004c28:	6d08                	ld	a0,24(a0)
    80004c2a:	87cff0ef          	jal	80003ca6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c2e:	874e                	mv	a4,s3
    80004c30:	5094                	lw	a3,32(s1)
    80004c32:	864a                	mv	a2,s2
    80004c34:	4585                	li	a1,1
    80004c36:	6c88                	ld	a0,24(s1)
    80004c38:	c00ff0ef          	jal	80004038 <readi>
    80004c3c:	892a                	mv	s2,a0
    80004c3e:	00a05563          	blez	a0,80004c48 <fileread+0x4e>
      f->off += r;
    80004c42:	509c                	lw	a5,32(s1)
    80004c44:	9fa9                	addw	a5,a5,a0
    80004c46:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c48:	6c88                	ld	a0,24(s1)
    80004c4a:	90aff0ef          	jal	80003d54 <iunlock>
    80004c4e:	64e2                	ld	s1,24(sp)
    80004c50:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004c52:	854a                	mv	a0,s2
    80004c54:	70a2                	ld	ra,40(sp)
    80004c56:	7402                	ld	s0,32(sp)
    80004c58:	6942                	ld	s2,16(sp)
    80004c5a:	6145                	addi	sp,sp,48
    80004c5c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c5e:	6908                	ld	a0,16(a0)
    80004c60:	3f8000ef          	jal	80005058 <piperead>
    80004c64:	892a                	mv	s2,a0
    80004c66:	64e2                	ld	s1,24(sp)
    80004c68:	69a2                	ld	s3,8(sp)
    80004c6a:	b7e5                	j	80004c52 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c6c:	02451783          	lh	a5,36(a0)
    80004c70:	03079693          	slli	a3,a5,0x30
    80004c74:	92c1                	srli	a3,a3,0x30
    80004c76:	4725                	li	a4,9
    80004c78:	02d76963          	bltu	a4,a3,80004caa <fileread+0xb0>
    80004c7c:	0792                	slli	a5,a5,0x4
    80004c7e:	0001f717          	auipc	a4,0x1f
    80004c82:	15270713          	addi	a4,a4,338 # 80023dd0 <devsw>
    80004c86:	97ba                	add	a5,a5,a4
    80004c88:	639c                	ld	a5,0(a5)
    80004c8a:	c78d                	beqz	a5,80004cb4 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004c8c:	4505                	li	a0,1
    80004c8e:	9782                	jalr	a5
    80004c90:	892a                	mv	s2,a0
    80004c92:	64e2                	ld	s1,24(sp)
    80004c94:	69a2                	ld	s3,8(sp)
    80004c96:	bf75                	j	80004c52 <fileread+0x58>
    panic("fileread");
    80004c98:	00004517          	auipc	a0,0x4
    80004c9c:	d7850513          	addi	a0,a0,-648 # 80008a10 <etext+0xa10>
    80004ca0:	b85fb0ef          	jal	80000824 <panic>
    return -1;
    80004ca4:	57fd                	li	a5,-1
    80004ca6:	893e                	mv	s2,a5
    80004ca8:	b76d                	j	80004c52 <fileread+0x58>
      return -1;
    80004caa:	57fd                	li	a5,-1
    80004cac:	893e                	mv	s2,a5
    80004cae:	64e2                	ld	s1,24(sp)
    80004cb0:	69a2                	ld	s3,8(sp)
    80004cb2:	b745                	j	80004c52 <fileread+0x58>
    80004cb4:	57fd                	li	a5,-1
    80004cb6:	893e                	mv	s2,a5
    80004cb8:	64e2                	ld	s1,24(sp)
    80004cba:	69a2                	ld	s3,8(sp)
    80004cbc:	bf59                	j	80004c52 <fileread+0x58>

0000000080004cbe <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004cbe:	00954783          	lbu	a5,9(a0)
    80004cc2:	10078f63          	beqz	a5,80004de0 <filewrite+0x122>
{
    80004cc6:	711d                	addi	sp,sp,-96
    80004cc8:	ec86                	sd	ra,88(sp)
    80004cca:	e8a2                	sd	s0,80(sp)
    80004ccc:	e0ca                	sd	s2,64(sp)
    80004cce:	f456                	sd	s5,40(sp)
    80004cd0:	f05a                	sd	s6,32(sp)
    80004cd2:	1080                	addi	s0,sp,96
    80004cd4:	892a                	mv	s2,a0
    80004cd6:	8b2e                	mv	s6,a1
    80004cd8:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cda:	411c                	lw	a5,0(a0)
    80004cdc:	4705                	li	a4,1
    80004cde:	02e78a63          	beq	a5,a4,80004d12 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ce2:	470d                	li	a4,3
    80004ce4:	02e78b63          	beq	a5,a4,80004d1a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ce8:	4709                	li	a4,2
    80004cea:	0ce79f63          	bne	a5,a4,80004dc8 <filewrite+0x10a>
    80004cee:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cf0:	0ac05a63          	blez	a2,80004da4 <filewrite+0xe6>
    80004cf4:	e4a6                	sd	s1,72(sp)
    80004cf6:	fc4e                	sd	s3,56(sp)
    80004cf8:	ec5e                	sd	s7,24(sp)
    80004cfa:	e862                	sd	s8,16(sp)
    80004cfc:	e466                	sd	s9,8(sp)
    int i = 0;
    80004cfe:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004d00:	6b85                	lui	s7,0x1
    80004d02:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004d06:	6785                	lui	a5,0x1
    80004d08:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004d0c:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d0e:	4c05                	li	s8,1
    80004d10:	a8ad                	j	80004d8a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004d12:	6908                	ld	a0,16(a0)
    80004d14:	252000ef          	jal	80004f66 <pipewrite>
    80004d18:	a04d                	j	80004dba <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d1a:	02451783          	lh	a5,36(a0)
    80004d1e:	03079693          	slli	a3,a5,0x30
    80004d22:	92c1                	srli	a3,a3,0x30
    80004d24:	4725                	li	a4,9
    80004d26:	0ad76f63          	bltu	a4,a3,80004de4 <filewrite+0x126>
    80004d2a:	0792                	slli	a5,a5,0x4
    80004d2c:	0001f717          	auipc	a4,0x1f
    80004d30:	0a470713          	addi	a4,a4,164 # 80023dd0 <devsw>
    80004d34:	97ba                	add	a5,a5,a4
    80004d36:	679c                	ld	a5,8(a5)
    80004d38:	cbc5                	beqz	a5,80004de8 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004d3a:	4505                	li	a0,1
    80004d3c:	9782                	jalr	a5
    80004d3e:	a8b5                	j	80004dba <filewrite+0xfc>
      if(n1 > max)
    80004d40:	2981                	sext.w	s3,s3
      begin_op();
    80004d42:	971ff0ef          	jal	800046b2 <begin_op>
      ilock(f->ip);
    80004d46:	01893503          	ld	a0,24(s2)
    80004d4a:	f5dfe0ef          	jal	80003ca6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d4e:	874e                	mv	a4,s3
    80004d50:	02092683          	lw	a3,32(s2)
    80004d54:	016a0633          	add	a2,s4,s6
    80004d58:	85e2                	mv	a1,s8
    80004d5a:	01893503          	ld	a0,24(s2)
    80004d5e:	bccff0ef          	jal	8000412a <writei>
    80004d62:	84aa                	mv	s1,a0
    80004d64:	00a05763          	blez	a0,80004d72 <filewrite+0xb4>
        f->off += r;
    80004d68:	02092783          	lw	a5,32(s2)
    80004d6c:	9fa9                	addw	a5,a5,a0
    80004d6e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d72:	01893503          	ld	a0,24(s2)
    80004d76:	fdffe0ef          	jal	80003d54 <iunlock>
      end_op();
    80004d7a:	9a9ff0ef          	jal	80004722 <end_op>

      if(r != n1){
    80004d7e:	02999563          	bne	s3,s1,80004da8 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004d82:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004d86:	015a5963          	bge	s4,s5,80004d98 <filewrite+0xda>
      int n1 = n - i;
    80004d8a:	414a87bb          	subw	a5,s5,s4
    80004d8e:	89be                	mv	s3,a5
      if(n1 > max)
    80004d90:	fafbd8e3          	bge	s7,a5,80004d40 <filewrite+0x82>
    80004d94:	89e6                	mv	s3,s9
    80004d96:	b76d                	j	80004d40 <filewrite+0x82>
    80004d98:	64a6                	ld	s1,72(sp)
    80004d9a:	79e2                	ld	s3,56(sp)
    80004d9c:	6be2                	ld	s7,24(sp)
    80004d9e:	6c42                	ld	s8,16(sp)
    80004da0:	6ca2                	ld	s9,8(sp)
    80004da2:	a801                	j	80004db2 <filewrite+0xf4>
    int i = 0;
    80004da4:	4a01                	li	s4,0
    80004da6:	a031                	j	80004db2 <filewrite+0xf4>
    80004da8:	64a6                	ld	s1,72(sp)
    80004daa:	79e2                	ld	s3,56(sp)
    80004dac:	6be2                	ld	s7,24(sp)
    80004dae:	6c42                	ld	s8,16(sp)
    80004db0:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004db2:	034a9d63          	bne	s5,s4,80004dec <filewrite+0x12e>
    80004db6:	8556                	mv	a0,s5
    80004db8:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dba:	60e6                	ld	ra,88(sp)
    80004dbc:	6446                	ld	s0,80(sp)
    80004dbe:	6906                	ld	s2,64(sp)
    80004dc0:	7aa2                	ld	s5,40(sp)
    80004dc2:	7b02                	ld	s6,32(sp)
    80004dc4:	6125                	addi	sp,sp,96
    80004dc6:	8082                	ret
    80004dc8:	e4a6                	sd	s1,72(sp)
    80004dca:	fc4e                	sd	s3,56(sp)
    80004dcc:	f852                	sd	s4,48(sp)
    80004dce:	ec5e                	sd	s7,24(sp)
    80004dd0:	e862                	sd	s8,16(sp)
    80004dd2:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004dd4:	00004517          	auipc	a0,0x4
    80004dd8:	c4c50513          	addi	a0,a0,-948 # 80008a20 <etext+0xa20>
    80004ddc:	a49fb0ef          	jal	80000824 <panic>
    return -1;
    80004de0:	557d                	li	a0,-1
}
    80004de2:	8082                	ret
      return -1;
    80004de4:	557d                	li	a0,-1
    80004de6:	bfd1                	j	80004dba <filewrite+0xfc>
    80004de8:	557d                	li	a0,-1
    80004dea:	bfc1                	j	80004dba <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004dec:	557d                	li	a0,-1
    80004dee:	7a42                	ld	s4,48(sp)
    80004df0:	b7e9                	j	80004dba <filewrite+0xfc>

0000000080004df2 <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004df2:	1101                	addi	sp,sp,-32
    80004df4:	ec06                	sd	ra,24(sp)
    80004df6:	e822                	sd	s0,16(sp)
    80004df8:	e426                	sd	s1,8(sp)
    80004dfa:	e04a                	sd	s2,0(sp)
    80004dfc:	1000                	addi	s0,sp,32
    80004dfe:	84aa                	mv	s1,a0
    80004e00:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e02:	0005b023          	sd	zero,0(a1)
    80004e06:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e0a:	c29ff0ef          	jal	80004a32 <filealloc>
    80004e0e:	e088                	sd	a0,0(s1)
    80004e10:	cd35                	beqz	a0,80004e8c <pipealloc+0x9a>
    80004e12:	c21ff0ef          	jal	80004a32 <filealloc>
    80004e16:	00a93023          	sd	a0,0(s2)
    80004e1a:	c52d                	beqz	a0,80004e84 <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e1c:	d29fb0ef          	jal	80000b44 <kalloc>
    80004e20:	cd39                	beqz	a0,80004e7e <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    80004e22:	4785                	li	a5,1
    80004e24:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    80004e28:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    80004e2c:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    80004e30:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    80004e34:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    80004e38:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    80004e3c:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004e40:	6098                	ld	a4,0(s1)
    80004e42:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    80004e44:	6098                	ld	a4,0(s1)
    80004e46:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    80004e4a:	6098                	ld	a4,0(s1)
    80004e4c:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004e50:	6098                	ld	a4,0(s1)
    80004e52:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    80004e54:	00093703          	ld	a4,0(s2)
    80004e58:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    80004e5a:	00093703          	ld	a4,0(s2)
    80004e5e:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    80004e62:	00093703          	ld	a4,0(s2)
    80004e66:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    80004e6a:	00093783          	ld	a5,0(s2)
    80004e6e:	eb88                	sd	a0,16(a5)
  return 0;
    80004e70:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    80004e72:	60e2                	ld	ra,24(sp)
    80004e74:	6442                	ld	s0,16(sp)
    80004e76:	64a2                	ld	s1,8(sp)
    80004e78:	6902                	ld	s2,0(sp)
    80004e7a:	6105                	addi	sp,sp,32
    80004e7c:	8082                	ret
  if(*f0)
    80004e7e:	6088                	ld	a0,0(s1)
    80004e80:	e501                	bnez	a0,80004e88 <pipealloc+0x96>
    80004e82:	a029                	j	80004e8c <pipealloc+0x9a>
    80004e84:	6088                	ld	a0,0(s1)
    80004e86:	cd01                	beqz	a0,80004e9e <pipealloc+0xac>
    fileclose(*f0);
    80004e88:	c4fff0ef          	jal	80004ad6 <fileclose>
  if(*f1)
    80004e8c:	00093783          	ld	a5,0(s2)
  return -1;
    80004e90:	557d                	li	a0,-1
  if(*f1)
    80004e92:	d3e5                	beqz	a5,80004e72 <pipealloc+0x80>
    fileclose(*f1);
    80004e94:	853e                	mv	a0,a5
    80004e96:	c41ff0ef          	jal	80004ad6 <fileclose>
  return -1;
    80004e9a:	557d                	li	a0,-1
    80004e9c:	bfd9                	j	80004e72 <pipealloc+0x80>
    80004e9e:	557d                	li	a0,-1
    80004ea0:	bfc9                	j	80004e72 <pipealloc+0x80>

0000000080004ea2 <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    80004ea2:	1141                	addi	sp,sp,-16
    80004ea4:	e406                	sd	ra,8(sp)
    80004ea6:	e022                	sd	s0,0(sp)
    80004ea8:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    80004eaa:	4785                	li	a5,1
    80004eac:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    80004eae:	058a                	slli	a1,a1,0x2
    80004eb0:	21058593          	addi	a1,a1,528
    80004eb4:	95aa                	add	a1,a1,a0
    80004eb6:	4705                	li	a4,1
    80004eb8:	c198                	sw	a4,0(a1)
  pi->turn = other;
    80004eba:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    80004ebe:	078a                	slli	a5,a5,0x2
    80004ec0:	21078793          	addi	a5,a5,528
    80004ec4:	953e                	add	a0,a0,a5
    80004ec6:	4118                	lw	a4,0(a0)
    80004ec8:	4785                	li	a5,1
    80004eca:	00f70063          	beq	a4,a5,80004eca <peterson_enter+0x28>
}
    80004ece:	60a2                	ld	ra,8(sp)
    80004ed0:	6402                	ld	s0,0(sp)
    80004ed2:	0141                	addi	sp,sp,16
    80004ed4:	8082                	ret

0000000080004ed6 <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    80004ed6:	1141                	addi	sp,sp,-16
    80004ed8:	e406                	sd	ra,8(sp)
    80004eda:	e022                	sd	s0,0(sp)
    80004edc:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    80004ede:	058a                	slli	a1,a1,0x2
    80004ee0:	21058593          	addi	a1,a1,528
    80004ee4:	952e                	add	a0,a0,a1
    80004ee6:	00052023          	sw	zero,0(a0)
}
    80004eea:	60a2                	ld	ra,8(sp)
    80004eec:	6402                	ld	s0,0(sp)
    80004eee:	0141                	addi	sp,sp,16
    80004ef0:	8082                	ret

0000000080004ef2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ef2:	7179                	addi	sp,sp,-48
    80004ef4:	f406                	sd	ra,40(sp)
    80004ef6:	f022                	sd	s0,32(sp)
    80004ef8:	ec26                	sd	s1,24(sp)
    80004efa:	e84a                	sd	s2,16(sp)
    80004efc:	e44e                	sd	s3,8(sp)
    80004efe:	1800                	addi	s0,sp,48
    80004f00:	84aa                	mv	s1,a0
    80004f02:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    80004f04:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    80004f08:	85ca                	mv	a1,s2
    80004f0a:	f99ff0ef          	jal	80004ea2 <peterson_enter>
  if(writable){
    80004f0e:	02098b63          	beqz	s3,80004f44 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f12:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    80004f16:	20048513          	addi	a0,s1,512
    80004f1a:	8d3fd0ef          	jal	800027ec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f1e:	2084a783          	lw	a5,520(s1)
    80004f22:	e781                	bnez	a5,80004f2a <pipeclose+0x38>
    80004f24:	20c4a783          	lw	a5,524(s1)
    80004f28:	c78d                	beqz	a5,80004f52 <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    80004f2a:	090a                	slli	s2,s2,0x2
    80004f2c:	21090913          	addi	s2,s2,528
    80004f30:	94ca                	add	s1,s1,s2
    80004f32:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    80004f36:	70a2                	ld	ra,40(sp)
    80004f38:	7402                	ld	s0,32(sp)
    80004f3a:	64e2                	ld	s1,24(sp)
    80004f3c:	6942                	ld	s2,16(sp)
    80004f3e:	69a2                	ld	s3,8(sp)
    80004f40:	6145                	addi	sp,sp,48
    80004f42:	8082                	ret
    pi->readopen = 0;
    80004f44:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    80004f48:	20448513          	addi	a0,s1,516
    80004f4c:	8a1fd0ef          	jal	800027ec <wakeup>
    80004f50:	b7f9                	j	80004f1e <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    80004f52:	090a                	slli	s2,s2,0x2
    80004f54:	21090913          	addi	s2,s2,528
    80004f58:	9926                	add	s2,s2,s1
    80004f5a:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    80004f5e:	8526                	mv	a0,s1
    80004f60:	afdfb0ef          	jal	80000a5c <kfree>
    80004f64:	bfc9                	j	80004f36 <pipeclose+0x44>

0000000080004f66 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f66:	7159                	addi	sp,sp,-112
    80004f68:	f486                	sd	ra,104(sp)
    80004f6a:	f0a2                	sd	s0,96(sp)
    80004f6c:	eca6                	sd	s1,88(sp)
    80004f6e:	e8ca                	sd	s2,80(sp)
    80004f70:	e4ce                	sd	s3,72(sp)
    80004f72:	e0d2                	sd	s4,64(sp)
    80004f74:	fc56                	sd	s5,56(sp)
    80004f76:	1880                	addi	s0,sp,112
    80004f78:	84aa                	mv	s1,a0
    80004f7a:	8aae                	mv	s5,a1
    80004f7c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f7e:	b77fc0ef          	jal	80001af4 <myproc>
    80004f82:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    80004f84:	4581                	li	a1,0
    80004f86:	8526                	mv	a0,s1
    80004f88:	f1bff0ef          	jal	80004ea2 <peterson_enter>
  while(i < n){
    80004f8c:	0b405e63          	blez	s4,80005048 <pipewrite+0xe2>
    80004f90:	f85a                	sd	s6,48(sp)
    80004f92:	f45e                	sd	s7,40(sp)
    80004f94:	f062                	sd	s8,32(sp)
    80004f96:	ec66                	sd	s9,24(sp)
    80004f98:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004f9a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f9c:	f9f40c13          	addi	s8,s0,-97
    80004fa0:	4b85                	li	s7,1
    80004fa2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fa4:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    80004fa8:	20448c93          	addi	s9,s1,516
    80004fac:	a825                	j	80004fe4 <pipewrite+0x7e>
      return -1;
    80004fae:	597d                	li	s2,-1
}
    80004fb0:	7b42                	ld	s6,48(sp)
    80004fb2:	7ba2                	ld	s7,40(sp)
    80004fb4:	7c02                	ld	s8,32(sp)
    80004fb6:	6ce2                	ld	s9,24(sp)
    80004fb8:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    80004fba:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004fbe:	854a                	mv	a0,s2
    80004fc0:	70a6                	ld	ra,104(sp)
    80004fc2:	7406                	ld	s0,96(sp)
    80004fc4:	64e6                	ld	s1,88(sp)
    80004fc6:	6946                	ld	s2,80(sp)
    80004fc8:	69a6                	ld	s3,72(sp)
    80004fca:	6a06                	ld	s4,64(sp)
    80004fcc:	7ae2                	ld	s5,56(sp)
    80004fce:	6165                	addi	sp,sp,112
    80004fd0:	8082                	ret
      wakeup(&pi->nread);
    80004fd2:	856a                	mv	a0,s10
    80004fd4:	819fd0ef          	jal	800027ec <wakeup>
      sleep(&pi->nwrite, 0);
    80004fd8:	4581                	li	a1,0
    80004fda:	8566                	mv	a0,s9
    80004fdc:	fc4fd0ef          	jal	800027a0 <sleep>
  while(i < n){
    80004fe0:	05495a63          	bge	s2,s4,80005034 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004fe4:	2084a783          	lw	a5,520(s1)
    80004fe8:	d3f9                	beqz	a5,80004fae <pipewrite+0x48>
    80004fea:	854e                	mv	a0,s3
    80004fec:	9f1fd0ef          	jal	800029dc <killed>
    80004ff0:	fd5d                	bnez	a0,80004fae <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ff2:	2004a783          	lw	a5,512(s1)
    80004ff6:	2044a703          	lw	a4,516(s1)
    80004ffa:	2007879b          	addiw	a5,a5,512
    80004ffe:	fcf70ae3          	beq	a4,a5,80004fd2 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005002:	86de                	mv	a3,s7
    80005004:	01590633          	add	a2,s2,s5
    80005008:	85e2                	mv	a1,s8
    8000500a:	0589b503          	ld	a0,88(s3)
    8000500e:	f04fc0ef          	jal	80001712 <copyin>
    80005012:	03650d63          	beq	a0,s6,8000504c <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005016:	2044a783          	lw	a5,516(s1)
    8000501a:	0017871b          	addiw	a4,a5,1
    8000501e:	20e4a223          	sw	a4,516(s1)
    80005022:	1ff7f793          	andi	a5,a5,511
    80005026:	97a6                	add	a5,a5,s1
    80005028:	f9f44703          	lbu	a4,-97(s0)
    8000502c:	00e78023          	sb	a4,0(a5)
      i++;
    80005030:	2905                	addiw	s2,s2,1
    80005032:	b77d                	j	80004fe0 <pipewrite+0x7a>
    80005034:	7b42                	ld	s6,48(sp)
    80005036:	7ba2                	ld	s7,40(sp)
    80005038:	7c02                	ld	s8,32(sp)
    8000503a:	6ce2                	ld	s9,24(sp)
    8000503c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000503e:	20048513          	addi	a0,s1,512
    80005042:	faafd0ef          	jal	800027ec <wakeup>
}
    80005046:	bf95                	j	80004fba <pipewrite+0x54>
  int i = 0;
    80005048:	4901                	li	s2,0
    8000504a:	bfd5                	j	8000503e <pipewrite+0xd8>
    8000504c:	7b42                	ld	s6,48(sp)
    8000504e:	7ba2                	ld	s7,40(sp)
    80005050:	7c02                	ld	s8,32(sp)
    80005052:	6ce2                	ld	s9,24(sp)
    80005054:	6d42                	ld	s10,16(sp)
    80005056:	b7e5                	j	8000503e <pipewrite+0xd8>

0000000080005058 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005058:	711d                	addi	sp,sp,-96
    8000505a:	ec86                	sd	ra,88(sp)
    8000505c:	e8a2                	sd	s0,80(sp)
    8000505e:	e4a6                	sd	s1,72(sp)
    80005060:	e0ca                	sd	s2,64(sp)
    80005062:	fc4e                	sd	s3,56(sp)
    80005064:	f852                	sd	s4,48(sp)
    80005066:	f456                	sd	s5,40(sp)
    80005068:	1080                	addi	s0,sp,96
    8000506a:	84aa                	mv	s1,a0
    8000506c:	892e                	mv	s2,a1
    8000506e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005070:	a85fc0ef          	jal	80001af4 <myproc>
    80005074:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    80005076:	4585                	li	a1,1
    80005078:	8526                	mv	a0,s1
    8000507a:	e29ff0ef          	jal	80004ea2 <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000507e:	2004a703          	lw	a4,512(s1)
    80005082:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80005086:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000508a:	02f71763          	bne	a4,a5,800050b8 <piperead+0x60>
    8000508e:	20c4a783          	lw	a5,524(s1)
    80005092:	c79d                	beqz	a5,800050c0 <piperead+0x68>
    if(killed(pr)){
    80005094:	8552                	mv	a0,s4
    80005096:	947fd0ef          	jal	800029dc <killed>
    8000509a:	e15d                	bnez	a0,80005140 <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    8000509c:	4581                	li	a1,0
    8000509e:	854e                	mv	a0,s3
    800050a0:	f00fd0ef          	jal	800027a0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050a4:	2004a703          	lw	a4,512(s1)
    800050a8:	2044a783          	lw	a5,516(s1)
    800050ac:	fef701e3          	beq	a4,a5,8000508e <piperead+0x36>
    800050b0:	f05a                	sd	s6,32(sp)
    800050b2:	ec5e                	sd	s7,24(sp)
    800050b4:	e862                	sd	s8,16(sp)
    800050b6:	a801                	j	800050c6 <piperead+0x6e>
    800050b8:	f05a                	sd	s6,32(sp)
    800050ba:	ec5e                	sd	s7,24(sp)
    800050bc:	e862                	sd	s8,16(sp)
    800050be:	a021                	j	800050c6 <piperead+0x6e>
    800050c0:	f05a                	sd	s6,32(sp)
    800050c2:	ec5e                	sd	s7,24(sp)
    800050c4:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050c8:	faf40c13          	addi	s8,s0,-81
    800050cc:	4b85                	li	s7,1
    800050ce:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050d0:	05505163          	blez	s5,80005112 <piperead+0xba>
    if(pi->nread == pi->nwrite)
    800050d4:	2004a783          	lw	a5,512(s1)
    800050d8:	2044a703          	lw	a4,516(s1)
    800050dc:	02f70b63          	beq	a4,a5,80005112 <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    800050e0:	1ff7f793          	andi	a5,a5,511
    800050e4:	97a6                	add	a5,a5,s1
    800050e6:	0007c783          	lbu	a5,0(a5)
    800050ea:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050ee:	86de                	mv	a3,s7
    800050f0:	8662                	mv	a2,s8
    800050f2:	85ca                	mv	a1,s2
    800050f4:	058a3503          	ld	a0,88(s4)
    800050f8:	d5cfc0ef          	jal	80001654 <copyout>
    800050fc:	03650e63          	beq	a0,s6,80005138 <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005100:	2004a783          	lw	a5,512(s1)
    80005104:	2785                	addiw	a5,a5,1
    80005106:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000510a:	2985                	addiw	s3,s3,1
    8000510c:	0905                	addi	s2,s2,1
    8000510e:	fd3a93e3          	bne	s5,s3,800050d4 <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005112:	20448513          	addi	a0,s1,516
    80005116:	ed6fd0ef          	jal	800027ec <wakeup>
}
    8000511a:	7b02                	ld	s6,32(sp)
    8000511c:	6be2                	ld	s7,24(sp)
    8000511e:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    80005120:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    80005124:	854e                	mv	a0,s3
    80005126:	60e6                	ld	ra,88(sp)
    80005128:	6446                	ld	s0,80(sp)
    8000512a:	64a6                	ld	s1,72(sp)
    8000512c:	6906                	ld	s2,64(sp)
    8000512e:	79e2                	ld	s3,56(sp)
    80005130:	7a42                	ld	s4,48(sp)
    80005132:	7aa2                	ld	s5,40(sp)
    80005134:	6125                	addi	sp,sp,96
    80005136:	8082                	ret
      if(i == 0)
    80005138:	fc099de3          	bnez	s3,80005112 <piperead+0xba>
        i = -1;
    8000513c:	89aa                	mv	s3,a0
    8000513e:	bfd1                	j	80005112 <piperead+0xba>
      return -1;
    80005140:	59fd                	li	s3,-1
    80005142:	bff9                	j	80005120 <piperead+0xc8>

0000000080005144 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005144:	1141                	addi	sp,sp,-16
    80005146:	e406                	sd	ra,8(sp)
    80005148:	e022                	sd	s0,0(sp)
    8000514a:	0800                	addi	s0,sp,16
    8000514c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000514e:	0035151b          	slliw	a0,a0,0x3
    80005152:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80005154:	8b89                	andi	a5,a5,2
    80005156:	c399                	beqz	a5,8000515c <flags2perm+0x18>
      perm |= PTE_W;
    80005158:	00456513          	ori	a0,a0,4
    return perm;
}
    8000515c:	60a2                	ld	ra,8(sp)
    8000515e:	6402                	ld	s0,0(sp)
    80005160:	0141                	addi	sp,sp,16
    80005162:	8082                	ret

0000000080005164 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005164:	de010113          	addi	sp,sp,-544
    80005168:	20113c23          	sd	ra,536(sp)
    8000516c:	20813823          	sd	s0,528(sp)
    80005170:	20913423          	sd	s1,520(sp)
    80005174:	21213023          	sd	s2,512(sp)
    80005178:	1400                	addi	s0,sp,544
    8000517a:	892a                	mv	s2,a0
    8000517c:	dea43823          	sd	a0,-528(s0)
    80005180:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005184:	971fc0ef          	jal	80001af4 <myproc>
    80005188:	84aa                	mv	s1,a0

  begin_op();
    8000518a:	d28ff0ef          	jal	800046b2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000518e:	854a                	mv	a0,s2
    80005190:	b44ff0ef          	jal	800044d4 <namei>
    80005194:	cd21                	beqz	a0,800051ec <kexec+0x88>
    80005196:	fbd2                	sd	s4,496(sp)
    80005198:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000519a:	b0dfe0ef          	jal	80003ca6 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000519e:	04000713          	li	a4,64
    800051a2:	4681                	li	a3,0
    800051a4:	e5040613          	addi	a2,s0,-432
    800051a8:	4581                	li	a1,0
    800051aa:	8552                	mv	a0,s4
    800051ac:	e8dfe0ef          	jal	80004038 <readi>
    800051b0:	04000793          	li	a5,64
    800051b4:	00f51a63          	bne	a0,a5,800051c8 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800051b8:	e5042703          	lw	a4,-432(s0)
    800051bc:	464c47b7          	lui	a5,0x464c4
    800051c0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051c4:	02f70863          	beq	a4,a5,800051f4 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051c8:	8552                	mv	a0,s4
    800051ca:	ce9fe0ef          	jal	80003eb2 <iunlockput>
    end_op();
    800051ce:	d54ff0ef          	jal	80004722 <end_op>
  }
  return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	7a5e                	ld	s4,496(sp)
}
    800051d6:	21813083          	ld	ra,536(sp)
    800051da:	21013403          	ld	s0,528(sp)
    800051de:	20813483          	ld	s1,520(sp)
    800051e2:	20013903          	ld	s2,512(sp)
    800051e6:	22010113          	addi	sp,sp,544
    800051ea:	8082                	ret
    end_op();
    800051ec:	d36ff0ef          	jal	80004722 <end_op>
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	b7d5                	j	800051d6 <kexec+0x72>
    800051f4:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800051f6:	8526                	mv	a0,s1
    800051f8:	a09fc0ef          	jal	80001c00 <proc_pagetable>
    800051fc:	8b2a                	mv	s6,a0
    800051fe:	26050f63          	beqz	a0,8000547c <kexec+0x318>
    80005202:	ffce                	sd	s3,504(sp)
    80005204:	f7d6                	sd	s5,488(sp)
    80005206:	efde                	sd	s7,472(sp)
    80005208:	ebe2                	sd	s8,464(sp)
    8000520a:	e7e6                	sd	s9,456(sp)
    8000520c:	e3ea                	sd	s10,448(sp)
    8000520e:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005210:	e8845783          	lhu	a5,-376(s0)
    80005214:	0e078963          	beqz	a5,80005306 <kexec+0x1a2>
    80005218:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000521c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000521e:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005220:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80005224:	6c85                	lui	s9,0x1
    80005226:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000522a:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000522e:	6a85                	lui	s5,0x1
    80005230:	a085                	j	80005290 <kexec+0x12c>
      panic("loadseg: address should exist");
    80005232:	00003517          	auipc	a0,0x3
    80005236:	7fe50513          	addi	a0,a0,2046 # 80008a30 <etext+0xa30>
    8000523a:	deafb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    8000523e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005240:	874a                	mv	a4,s2
    80005242:	009b86bb          	addw	a3,s7,s1
    80005246:	4581                	li	a1,0
    80005248:	8552                	mv	a0,s4
    8000524a:	deffe0ef          	jal	80004038 <readi>
    8000524e:	22a91b63          	bne	s2,a0,80005484 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80005252:	009a84bb          	addw	s1,s5,s1
    80005256:	0334f263          	bgeu	s1,s3,8000527a <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    8000525a:	02049593          	slli	a1,s1,0x20
    8000525e:	9181                	srli	a1,a1,0x20
    80005260:	95e2                	add	a1,a1,s8
    80005262:	855a                	mv	a0,s6
    80005264:	dc3fb0ef          	jal	80001026 <walkaddr>
    80005268:	862a                	mv	a2,a0
    if(pa == 0)
    8000526a:	d561                	beqz	a0,80005232 <kexec+0xce>
    if(sz - i < PGSIZE)
    8000526c:	409987bb          	subw	a5,s3,s1
    80005270:	893e                	mv	s2,a5
    80005272:	fcfcf6e3          	bgeu	s9,a5,8000523e <kexec+0xda>
    80005276:	8956                	mv	s2,s5
    80005278:	b7d9                	j	8000523e <kexec+0xda>
    sz = sz1;
    8000527a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000527e:	2d05                	addiw	s10,s10,1
    80005280:	e0843783          	ld	a5,-504(s0)
    80005284:	0387869b          	addiw	a3,a5,56
    80005288:	e8845783          	lhu	a5,-376(s0)
    8000528c:	06fd5e63          	bge	s10,a5,80005308 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005290:	e0d43423          	sd	a3,-504(s0)
    80005294:	876e                	mv	a4,s11
    80005296:	e1840613          	addi	a2,s0,-488
    8000529a:	4581                	li	a1,0
    8000529c:	8552                	mv	a0,s4
    8000529e:	d9bfe0ef          	jal	80004038 <readi>
    800052a2:	1db51f63          	bne	a0,s11,80005480 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    800052a6:	e1842783          	lw	a5,-488(s0)
    800052aa:	4705                	li	a4,1
    800052ac:	fce799e3          	bne	a5,a4,8000527e <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    800052b0:	e4043483          	ld	s1,-448(s0)
    800052b4:	e3843783          	ld	a5,-456(s0)
    800052b8:	1ef4e463          	bltu	s1,a5,800054a0 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052bc:	e2843783          	ld	a5,-472(s0)
    800052c0:	94be                	add	s1,s1,a5
    800052c2:	1ef4e263          	bltu	s1,a5,800054a6 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    800052c6:	de843703          	ld	a4,-536(s0)
    800052ca:	8ff9                	and	a5,a5,a4
    800052cc:	1e079063          	bnez	a5,800054ac <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052d0:	e1c42503          	lw	a0,-484(s0)
    800052d4:	e71ff0ef          	jal	80005144 <flags2perm>
    800052d8:	86aa                	mv	a3,a0
    800052da:	8626                	mv	a2,s1
    800052dc:	85ca                	mv	a1,s2
    800052de:	855a                	mv	a0,s6
    800052e0:	81cfc0ef          	jal	800012fc <uvmalloc>
    800052e4:	dea43c23          	sd	a0,-520(s0)
    800052e8:	1c050563          	beqz	a0,800054b2 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052ec:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052f0:	00098863          	beqz	s3,80005300 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052f4:	e2843c03          	ld	s8,-472(s0)
    800052f8:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052fc:	4481                	li	s1,0
    800052fe:	bfb1                	j	8000525a <kexec+0xf6>
    sz = sz1;
    80005300:	df843903          	ld	s2,-520(s0)
    80005304:	bfad                	j	8000527e <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005306:	4901                	li	s2,0
  iunlockput(ip);
    80005308:	8552                	mv	a0,s4
    8000530a:	ba9fe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    8000530e:	c14ff0ef          	jal	80004722 <end_op>
  p = myproc();
    80005312:	fe2fc0ef          	jal	80001af4 <myproc>
    80005316:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005318:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000531c:	6985                	lui	s3,0x1
    8000531e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005320:	99ca                	add	s3,s3,s2
    80005322:	77fd                	lui	a5,0xfffff
    80005324:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005328:	4691                	li	a3,4
    8000532a:	6609                	lui	a2,0x2
    8000532c:	964e                	add	a2,a2,s3
    8000532e:	85ce                	mv	a1,s3
    80005330:	855a                	mv	a0,s6
    80005332:	fcbfb0ef          	jal	800012fc <uvmalloc>
    80005336:	8a2a                	mv	s4,a0
    80005338:	e105                	bnez	a0,80005358 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    8000533a:	85ce                	mv	a1,s3
    8000533c:	855a                	mv	a0,s6
    8000533e:	947fc0ef          	jal	80001c84 <proc_freepagetable>
  return -1;
    80005342:	557d                	li	a0,-1
    80005344:	79fe                	ld	s3,504(sp)
    80005346:	7a5e                	ld	s4,496(sp)
    80005348:	7abe                	ld	s5,488(sp)
    8000534a:	7b1e                	ld	s6,480(sp)
    8000534c:	6bfe                	ld	s7,472(sp)
    8000534e:	6c5e                	ld	s8,464(sp)
    80005350:	6cbe                	ld	s9,456(sp)
    80005352:	6d1e                	ld	s10,448(sp)
    80005354:	7dfa                	ld	s11,440(sp)
    80005356:	b541                	j	800051d6 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005358:	75f9                	lui	a1,0xffffe
    8000535a:	95aa                	add	a1,a1,a0
    8000535c:	855a                	mv	a0,s6
    8000535e:	970fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005362:	800a0b93          	addi	s7,s4,-2048
    80005366:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    8000536a:	e0043783          	ld	a5,-512(s0)
    8000536e:	6388                	ld	a0,0(a5)
  sp = sz;
    80005370:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005372:	4481                	li	s1,0
    ustack[argc] = sp;
    80005374:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005378:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000537c:	cd21                	beqz	a0,800053d4 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    8000537e:	b05fb0ef          	jal	80000e82 <strlen>
    80005382:	0015079b          	addiw	a5,a0,1
    80005386:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000538a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000538e:	13796563          	bltu	s2,s7,800054b8 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005392:	e0043d83          	ld	s11,-512(s0)
    80005396:	000db983          	ld	s3,0(s11)
    8000539a:	854e                	mv	a0,s3
    8000539c:	ae7fb0ef          	jal	80000e82 <strlen>
    800053a0:	0015069b          	addiw	a3,a0,1
    800053a4:	864e                	mv	a2,s3
    800053a6:	85ca                	mv	a1,s2
    800053a8:	855a                	mv	a0,s6
    800053aa:	aaafc0ef          	jal	80001654 <copyout>
    800053ae:	10054763          	bltz	a0,800054bc <kexec+0x358>
    ustack[argc] = sp;
    800053b2:	00349793          	slli	a5,s1,0x3
    800053b6:	97e6                	add	a5,a5,s9
    800053b8:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffda098>
  for(argc = 0; argv[argc]; argc++) {
    800053bc:	0485                	addi	s1,s1,1
    800053be:	008d8793          	addi	a5,s11,8
    800053c2:	e0f43023          	sd	a5,-512(s0)
    800053c6:	008db503          	ld	a0,8(s11)
    800053ca:	c509                	beqz	a0,800053d4 <kexec+0x270>
    if(argc >= MAXARG)
    800053cc:	fb8499e3          	bne	s1,s8,8000537e <kexec+0x21a>
  sz = sz1;
    800053d0:	89d2                	mv	s3,s4
    800053d2:	b7a5                	j	8000533a <kexec+0x1d6>
  ustack[argc] = 0;
    800053d4:	00349793          	slli	a5,s1,0x3
    800053d8:	f9078793          	addi	a5,a5,-112
    800053dc:	97a2                	add	a5,a5,s0
    800053de:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800053e2:	00349693          	slli	a3,s1,0x3
    800053e6:	06a1                	addi	a3,a3,8
    800053e8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053ec:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800053f0:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800053f2:	f57964e3          	bltu	s2,s7,8000533a <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053f6:	e9040613          	addi	a2,s0,-368
    800053fa:	85ca                	mv	a1,s2
    800053fc:	855a                	mv	a0,s6
    800053fe:	a56fc0ef          	jal	80001654 <copyout>
    80005402:	f2054ce3          	bltz	a0,8000533a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80005406:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    8000540a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000540e:	df043783          	ld	a5,-528(s0)
    80005412:	0007c703          	lbu	a4,0(a5)
    80005416:	cf11                	beqz	a4,80005432 <kexec+0x2ce>
    80005418:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000541a:	02f00693          	li	a3,47
    8000541e:	a029                	j	80005428 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80005420:	0785                	addi	a5,a5,1
    80005422:	fff7c703          	lbu	a4,-1(a5)
    80005426:	c711                	beqz	a4,80005432 <kexec+0x2ce>
    if(*s == '/')
    80005428:	fed71ce3          	bne	a4,a3,80005420 <kexec+0x2bc>
      last = s+1;
    8000542c:	def43823          	sd	a5,-528(s0)
    80005430:	bfc5                	j	80005420 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80005432:	4641                	li	a2,16
    80005434:	df043583          	ld	a1,-528(s0)
    80005438:	160a8513          	addi	a0,s5,352
    8000543c:	a11fb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80005440:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005444:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80005448:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000544c:	060ab783          	ld	a5,96(s5)
    80005450:	e6843703          	ld	a4,-408(s0)
    80005454:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005456:	060ab783          	ld	a5,96(s5)
    8000545a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000545e:	85ea                	mv	a1,s10
    80005460:	825fc0ef          	jal	80001c84 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005464:	0004851b          	sext.w	a0,s1
    80005468:	79fe                	ld	s3,504(sp)
    8000546a:	7a5e                	ld	s4,496(sp)
    8000546c:	7abe                	ld	s5,488(sp)
    8000546e:	7b1e                	ld	s6,480(sp)
    80005470:	6bfe                	ld	s7,472(sp)
    80005472:	6c5e                	ld	s8,464(sp)
    80005474:	6cbe                	ld	s9,456(sp)
    80005476:	6d1e                	ld	s10,448(sp)
    80005478:	7dfa                	ld	s11,440(sp)
    8000547a:	bbb1                	j	800051d6 <kexec+0x72>
    8000547c:	7b1e                	ld	s6,480(sp)
    8000547e:	b3a9                	j	800051c8 <kexec+0x64>
    80005480:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005484:	df843583          	ld	a1,-520(s0)
    80005488:	855a                	mv	a0,s6
    8000548a:	ffafc0ef          	jal	80001c84 <proc_freepagetable>
  if(ip){
    8000548e:	79fe                	ld	s3,504(sp)
    80005490:	7abe                	ld	s5,488(sp)
    80005492:	7b1e                	ld	s6,480(sp)
    80005494:	6bfe                	ld	s7,472(sp)
    80005496:	6c5e                	ld	s8,464(sp)
    80005498:	6cbe                	ld	s9,456(sp)
    8000549a:	6d1e                	ld	s10,448(sp)
    8000549c:	7dfa                	ld	s11,440(sp)
    8000549e:	b32d                	j	800051c8 <kexec+0x64>
    800054a0:	df243c23          	sd	s2,-520(s0)
    800054a4:	b7c5                	j	80005484 <kexec+0x320>
    800054a6:	df243c23          	sd	s2,-520(s0)
    800054aa:	bfe9                	j	80005484 <kexec+0x320>
    800054ac:	df243c23          	sd	s2,-520(s0)
    800054b0:	bfd1                	j	80005484 <kexec+0x320>
    800054b2:	df243c23          	sd	s2,-520(s0)
    800054b6:	b7f9                	j	80005484 <kexec+0x320>
  sz = sz1;
    800054b8:	89d2                	mv	s3,s4
    800054ba:	b541                	j	8000533a <kexec+0x1d6>
    800054bc:	89d2                	mv	s3,s4
    800054be:	bdb5                	j	8000533a <kexec+0x1d6>

00000000800054c0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054c0:	7179                	addi	sp,sp,-48
    800054c2:	f406                	sd	ra,40(sp)
    800054c4:	f022                	sd	s0,32(sp)
    800054c6:	ec26                	sd	s1,24(sp)
    800054c8:	e84a                	sd	s2,16(sp)
    800054ca:	1800                	addi	s0,sp,48
    800054cc:	892e                	mv	s2,a1
    800054ce:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054d0:	fdc40593          	addi	a1,s0,-36
    800054d4:	dddfd0ef          	jal	800032b0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054d8:	fdc42703          	lw	a4,-36(s0)
    800054dc:	47bd                	li	a5,15
    800054de:	02e7ea63          	bltu	a5,a4,80005512 <argfd+0x52>
    800054e2:	e12fc0ef          	jal	80001af4 <myproc>
    800054e6:	fdc42703          	lw	a4,-36(s0)
    800054ea:	00371793          	slli	a5,a4,0x3
    800054ee:	0d078793          	addi	a5,a5,208
    800054f2:	953e                	add	a0,a0,a5
    800054f4:	651c                	ld	a5,8(a0)
    800054f6:	c385                	beqz	a5,80005516 <argfd+0x56>
    return -1;
  if(pfd)
    800054f8:	00090463          	beqz	s2,80005500 <argfd+0x40>
    *pfd = fd;
    800054fc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005500:	4501                	li	a0,0
  if(pf)
    80005502:	c091                	beqz	s1,80005506 <argfd+0x46>
    *pf = f;
    80005504:	e09c                	sd	a5,0(s1)
}
    80005506:	70a2                	ld	ra,40(sp)
    80005508:	7402                	ld	s0,32(sp)
    8000550a:	64e2                	ld	s1,24(sp)
    8000550c:	6942                	ld	s2,16(sp)
    8000550e:	6145                	addi	sp,sp,48
    80005510:	8082                	ret
    return -1;
    80005512:	557d                	li	a0,-1
    80005514:	bfcd                	j	80005506 <argfd+0x46>
    80005516:	557d                	li	a0,-1
    80005518:	b7fd                	j	80005506 <argfd+0x46>

000000008000551a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000551a:	1101                	addi	sp,sp,-32
    8000551c:	ec06                	sd	ra,24(sp)
    8000551e:	e822                	sd	s0,16(sp)
    80005520:	e426                	sd	s1,8(sp)
    80005522:	1000                	addi	s0,sp,32
    80005524:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005526:	dcefc0ef          	jal	80001af4 <myproc>
    8000552a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000552c:	0d850793          	addi	a5,a0,216
    80005530:	4501                	li	a0,0
    80005532:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005534:	6398                	ld	a4,0(a5)
    80005536:	cb19                	beqz	a4,8000554c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005538:	2505                	addiw	a0,a0,1
    8000553a:	07a1                	addi	a5,a5,8
    8000553c:	fed51ce3          	bne	a0,a3,80005534 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005540:	557d                	li	a0,-1
}
    80005542:	60e2                	ld	ra,24(sp)
    80005544:	6442                	ld	s0,16(sp)
    80005546:	64a2                	ld	s1,8(sp)
    80005548:	6105                	addi	sp,sp,32
    8000554a:	8082                	ret
      p->ofile[fd] = f;
    8000554c:	00351793          	slli	a5,a0,0x3
    80005550:	0d078793          	addi	a5,a5,208
    80005554:	963e                	add	a2,a2,a5
    80005556:	e604                	sd	s1,8(a2)
      return fd;
    80005558:	b7ed                	j	80005542 <fdalloc+0x28>

000000008000555a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000555a:	715d                	addi	sp,sp,-80
    8000555c:	e486                	sd	ra,72(sp)
    8000555e:	e0a2                	sd	s0,64(sp)
    80005560:	fc26                	sd	s1,56(sp)
    80005562:	f84a                	sd	s2,48(sp)
    80005564:	f44e                	sd	s3,40(sp)
    80005566:	f052                	sd	s4,32(sp)
    80005568:	ec56                	sd	s5,24(sp)
    8000556a:	e85a                	sd	s6,16(sp)
    8000556c:	0880                	addi	s0,sp,80
    8000556e:	892e                	mv	s2,a1
    80005570:	8a2e                	mv	s4,a1
    80005572:	8ab2                	mv	s5,a2
    80005574:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005576:	fb040593          	addi	a1,s0,-80
    8000557a:	f75fe0ef          	jal	800044ee <nameiparent>
    8000557e:	84aa                	mv	s1,a0
    80005580:	10050763          	beqz	a0,8000568e <create+0x134>
    return 0;

  ilock(dp);
    80005584:	f22fe0ef          	jal	80003ca6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005588:	4601                	li	a2,0
    8000558a:	fb040593          	addi	a1,s0,-80
    8000558e:	8526                	mv	a0,s1
    80005590:	cb1fe0ef          	jal	80004240 <dirlookup>
    80005594:	89aa                	mv	s3,a0
    80005596:	c131                	beqz	a0,800055da <create+0x80>
    iunlockput(dp);
    80005598:	8526                	mv	a0,s1
    8000559a:	919fe0ef          	jal	80003eb2 <iunlockput>
    ilock(ip);
    8000559e:	854e                	mv	a0,s3
    800055a0:	f06fe0ef          	jal	80003ca6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055a4:	4789                	li	a5,2
    800055a6:	02f91563          	bne	s2,a5,800055d0 <create+0x76>
    800055aa:	0449d783          	lhu	a5,68(s3)
    800055ae:	37f9                	addiw	a5,a5,-2
    800055b0:	17c2                	slli	a5,a5,0x30
    800055b2:	93c1                	srli	a5,a5,0x30
    800055b4:	4705                	li	a4,1
    800055b6:	00f76d63          	bltu	a4,a5,800055d0 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055ba:	854e                	mv	a0,s3
    800055bc:	60a6                	ld	ra,72(sp)
    800055be:	6406                	ld	s0,64(sp)
    800055c0:	74e2                	ld	s1,56(sp)
    800055c2:	7942                	ld	s2,48(sp)
    800055c4:	79a2                	ld	s3,40(sp)
    800055c6:	7a02                	ld	s4,32(sp)
    800055c8:	6ae2                	ld	s5,24(sp)
    800055ca:	6b42                	ld	s6,16(sp)
    800055cc:	6161                	addi	sp,sp,80
    800055ce:	8082                	ret
    iunlockput(ip);
    800055d0:	854e                	mv	a0,s3
    800055d2:	8e1fe0ef          	jal	80003eb2 <iunlockput>
    return 0;
    800055d6:	4981                	li	s3,0
    800055d8:	b7cd                	j	800055ba <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055da:	85ca                	mv	a1,s2
    800055dc:	4088                	lw	a0,0(s1)
    800055de:	d58fe0ef          	jal	80003b36 <ialloc>
    800055e2:	892a                	mv	s2,a0
    800055e4:	cd15                	beqz	a0,80005620 <create+0xc6>
  ilock(ip);
    800055e6:	ec0fe0ef          	jal	80003ca6 <ilock>
  ip->major = major;
    800055ea:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    800055ee:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    800055f2:	4785                	li	a5,1
    800055f4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055f8:	854a                	mv	a0,s2
    800055fa:	df8fe0ef          	jal	80003bf2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055fe:	4705                	li	a4,1
    80005600:	02ea0463          	beq	s4,a4,80005628 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005604:	00492603          	lw	a2,4(s2)
    80005608:	fb040593          	addi	a1,s0,-80
    8000560c:	8526                	mv	a0,s1
    8000560e:	e1dfe0ef          	jal	8000442a <dirlink>
    80005612:	06054263          	bltz	a0,80005676 <create+0x11c>
  iunlockput(dp);
    80005616:	8526                	mv	a0,s1
    80005618:	89bfe0ef          	jal	80003eb2 <iunlockput>
  return ip;
    8000561c:	89ca                	mv	s3,s2
    8000561e:	bf71                	j	800055ba <create+0x60>
    iunlockput(dp);
    80005620:	8526                	mv	a0,s1
    80005622:	891fe0ef          	jal	80003eb2 <iunlockput>
    return 0;
    80005626:	bf51                	j	800055ba <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005628:	00492603          	lw	a2,4(s2)
    8000562c:	00003597          	auipc	a1,0x3
    80005630:	42458593          	addi	a1,a1,1060 # 80008a50 <etext+0xa50>
    80005634:	854a                	mv	a0,s2
    80005636:	df5fe0ef          	jal	8000442a <dirlink>
    8000563a:	02054e63          	bltz	a0,80005676 <create+0x11c>
    8000563e:	40d0                	lw	a2,4(s1)
    80005640:	00003597          	auipc	a1,0x3
    80005644:	41858593          	addi	a1,a1,1048 # 80008a58 <etext+0xa58>
    80005648:	854a                	mv	a0,s2
    8000564a:	de1fe0ef          	jal	8000442a <dirlink>
    8000564e:	02054463          	bltz	a0,80005676 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005652:	00492603          	lw	a2,4(s2)
    80005656:	fb040593          	addi	a1,s0,-80
    8000565a:	8526                	mv	a0,s1
    8000565c:	dcffe0ef          	jal	8000442a <dirlink>
    80005660:	00054b63          	bltz	a0,80005676 <create+0x11c>
    dp->nlink++;  // for ".."
    80005664:	04a4d783          	lhu	a5,74(s1)
    80005668:	2785                	addiw	a5,a5,1
    8000566a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000566e:	8526                	mv	a0,s1
    80005670:	d82fe0ef          	jal	80003bf2 <iupdate>
    80005674:	b74d                	j	80005616 <create+0xbc>
  ip->nlink = 0;
    80005676:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    8000567a:	854a                	mv	a0,s2
    8000567c:	d76fe0ef          	jal	80003bf2 <iupdate>
  iunlockput(ip);
    80005680:	854a                	mv	a0,s2
    80005682:	831fe0ef          	jal	80003eb2 <iunlockput>
  iunlockput(dp);
    80005686:	8526                	mv	a0,s1
    80005688:	82bfe0ef          	jal	80003eb2 <iunlockput>
  return 0;
    8000568c:	b73d                	j	800055ba <create+0x60>
    return 0;
    8000568e:	89aa                	mv	s3,a0
    80005690:	b72d                	j	800055ba <create+0x60>

0000000080005692 <sys_dup>:
{
    80005692:	7179                	addi	sp,sp,-48
    80005694:	f406                	sd	ra,40(sp)
    80005696:	f022                	sd	s0,32(sp)
    80005698:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000569a:	fd840613          	addi	a2,s0,-40
    8000569e:	4581                	li	a1,0
    800056a0:	4501                	li	a0,0
    800056a2:	e1fff0ef          	jal	800054c0 <argfd>
    return -1;
    800056a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056a8:	02054363          	bltz	a0,800056ce <sys_dup+0x3c>
    800056ac:	ec26                	sd	s1,24(sp)
    800056ae:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800056b0:	fd843483          	ld	s1,-40(s0)
    800056b4:	8526                	mv	a0,s1
    800056b6:	e65ff0ef          	jal	8000551a <fdalloc>
    800056ba:	892a                	mv	s2,a0
    return -1;
    800056bc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056be:	00054d63          	bltz	a0,800056d8 <sys_dup+0x46>
  filedup(f);
    800056c2:	8526                	mv	a0,s1
    800056c4:	bccff0ef          	jal	80004a90 <filedup>
  return fd;
    800056c8:	87ca                	mv	a5,s2
    800056ca:	64e2                	ld	s1,24(sp)
    800056cc:	6942                	ld	s2,16(sp)
}
    800056ce:	853e                	mv	a0,a5
    800056d0:	70a2                	ld	ra,40(sp)
    800056d2:	7402                	ld	s0,32(sp)
    800056d4:	6145                	addi	sp,sp,48
    800056d6:	8082                	ret
    800056d8:	64e2                	ld	s1,24(sp)
    800056da:	6942                	ld	s2,16(sp)
    800056dc:	bfcd                	j	800056ce <sys_dup+0x3c>

00000000800056de <sys_read>:
{
    800056de:	7179                	addi	sp,sp,-48
    800056e0:	f406                	sd	ra,40(sp)
    800056e2:	f022                	sd	s0,32(sp)
    800056e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056e6:	fd840593          	addi	a1,s0,-40
    800056ea:	4505                	li	a0,1
    800056ec:	be1fd0ef          	jal	800032cc <argaddr>
  argint(2, &n);
    800056f0:	fe440593          	addi	a1,s0,-28
    800056f4:	4509                	li	a0,2
    800056f6:	bbbfd0ef          	jal	800032b0 <argint>
  if(argfd(0, 0, &f) < 0)
    800056fa:	fe840613          	addi	a2,s0,-24
    800056fe:	4581                	li	a1,0
    80005700:	4501                	li	a0,0
    80005702:	dbfff0ef          	jal	800054c0 <argfd>
    80005706:	87aa                	mv	a5,a0
    return -1;
    80005708:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000570a:	0007ca63          	bltz	a5,8000571e <sys_read+0x40>
  return fileread(f, p, n);
    8000570e:	fe442603          	lw	a2,-28(s0)
    80005712:	fd843583          	ld	a1,-40(s0)
    80005716:	fe843503          	ld	a0,-24(s0)
    8000571a:	ce0ff0ef          	jal	80004bfa <fileread>
}
    8000571e:	70a2                	ld	ra,40(sp)
    80005720:	7402                	ld	s0,32(sp)
    80005722:	6145                	addi	sp,sp,48
    80005724:	8082                	ret

0000000080005726 <sys_write>:
{
    80005726:	7179                	addi	sp,sp,-48
    80005728:	f406                	sd	ra,40(sp)
    8000572a:	f022                	sd	s0,32(sp)
    8000572c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000572e:	fd840593          	addi	a1,s0,-40
    80005732:	4505                	li	a0,1
    80005734:	b99fd0ef          	jal	800032cc <argaddr>
  argint(2, &n);
    80005738:	fe440593          	addi	a1,s0,-28
    8000573c:	4509                	li	a0,2
    8000573e:	b73fd0ef          	jal	800032b0 <argint>
  if(argfd(0, 0, &f) < 0)
    80005742:	fe840613          	addi	a2,s0,-24
    80005746:	4581                	li	a1,0
    80005748:	4501                	li	a0,0
    8000574a:	d77ff0ef          	jal	800054c0 <argfd>
    8000574e:	87aa                	mv	a5,a0
    return -1;
    80005750:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005752:	0007ca63          	bltz	a5,80005766 <sys_write+0x40>
  return filewrite(f, p, n);
    80005756:	fe442603          	lw	a2,-28(s0)
    8000575a:	fd843583          	ld	a1,-40(s0)
    8000575e:	fe843503          	ld	a0,-24(s0)
    80005762:	d5cff0ef          	jal	80004cbe <filewrite>
}
    80005766:	70a2                	ld	ra,40(sp)
    80005768:	7402                	ld	s0,32(sp)
    8000576a:	6145                	addi	sp,sp,48
    8000576c:	8082                	ret

000000008000576e <sys_close>:
{
    8000576e:	1101                	addi	sp,sp,-32
    80005770:	ec06                	sd	ra,24(sp)
    80005772:	e822                	sd	s0,16(sp)
    80005774:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005776:	fe040613          	addi	a2,s0,-32
    8000577a:	fec40593          	addi	a1,s0,-20
    8000577e:	4501                	li	a0,0
    80005780:	d41ff0ef          	jal	800054c0 <argfd>
    return -1;
    80005784:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005786:	02054163          	bltz	a0,800057a8 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000578a:	b6afc0ef          	jal	80001af4 <myproc>
    8000578e:	fec42783          	lw	a5,-20(s0)
    80005792:	078e                	slli	a5,a5,0x3
    80005794:	0d078793          	addi	a5,a5,208
    80005798:	953e                	add	a0,a0,a5
    8000579a:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000579e:	fe043503          	ld	a0,-32(s0)
    800057a2:	b34ff0ef          	jal	80004ad6 <fileclose>
  return 0;
    800057a6:	4781                	li	a5,0
}
    800057a8:	853e                	mv	a0,a5
    800057aa:	60e2                	ld	ra,24(sp)
    800057ac:	6442                	ld	s0,16(sp)
    800057ae:	6105                	addi	sp,sp,32
    800057b0:	8082                	ret

00000000800057b2 <sys_fstat>:
{
    800057b2:	1101                	addi	sp,sp,-32
    800057b4:	ec06                	sd	ra,24(sp)
    800057b6:	e822                	sd	s0,16(sp)
    800057b8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057ba:	fe040593          	addi	a1,s0,-32
    800057be:	4505                	li	a0,1
    800057c0:	b0dfd0ef          	jal	800032cc <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057c4:	fe840613          	addi	a2,s0,-24
    800057c8:	4581                	li	a1,0
    800057ca:	4501                	li	a0,0
    800057cc:	cf5ff0ef          	jal	800054c0 <argfd>
    800057d0:	87aa                	mv	a5,a0
    return -1;
    800057d2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057d4:	0007c863          	bltz	a5,800057e4 <sys_fstat+0x32>
  return filestat(f, st);
    800057d8:	fe043583          	ld	a1,-32(s0)
    800057dc:	fe843503          	ld	a0,-24(s0)
    800057e0:	bb8ff0ef          	jal	80004b98 <filestat>
}
    800057e4:	60e2                	ld	ra,24(sp)
    800057e6:	6442                	ld	s0,16(sp)
    800057e8:	6105                	addi	sp,sp,32
    800057ea:	8082                	ret

00000000800057ec <sys_link>:
{
    800057ec:	7169                	addi	sp,sp,-304
    800057ee:	f606                	sd	ra,296(sp)
    800057f0:	f222                	sd	s0,288(sp)
    800057f2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057f4:	08000613          	li	a2,128
    800057f8:	ed040593          	addi	a1,s0,-304
    800057fc:	4501                	li	a0,0
    800057fe:	aebfd0ef          	jal	800032e8 <argstr>
    return -1;
    80005802:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005804:	0c054e63          	bltz	a0,800058e0 <sys_link+0xf4>
    80005808:	08000613          	li	a2,128
    8000580c:	f5040593          	addi	a1,s0,-176
    80005810:	4505                	li	a0,1
    80005812:	ad7fd0ef          	jal	800032e8 <argstr>
    return -1;
    80005816:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005818:	0c054463          	bltz	a0,800058e0 <sys_link+0xf4>
    8000581c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000581e:	e95fe0ef          	jal	800046b2 <begin_op>
  if((ip = namei(old)) == 0){
    80005822:	ed040513          	addi	a0,s0,-304
    80005826:	caffe0ef          	jal	800044d4 <namei>
    8000582a:	84aa                	mv	s1,a0
    8000582c:	c53d                	beqz	a0,8000589a <sys_link+0xae>
  ilock(ip);
    8000582e:	c78fe0ef          	jal	80003ca6 <ilock>
  if(ip->type == T_DIR){
    80005832:	04449703          	lh	a4,68(s1)
    80005836:	4785                	li	a5,1
    80005838:	06f70663          	beq	a4,a5,800058a4 <sys_link+0xb8>
    8000583c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000583e:	04a4d783          	lhu	a5,74(s1)
    80005842:	2785                	addiw	a5,a5,1
    80005844:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005848:	8526                	mv	a0,s1
    8000584a:	ba8fe0ef          	jal	80003bf2 <iupdate>
  iunlock(ip);
    8000584e:	8526                	mv	a0,s1
    80005850:	d04fe0ef          	jal	80003d54 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005854:	fd040593          	addi	a1,s0,-48
    80005858:	f5040513          	addi	a0,s0,-176
    8000585c:	c93fe0ef          	jal	800044ee <nameiparent>
    80005860:	892a                	mv	s2,a0
    80005862:	cd21                	beqz	a0,800058ba <sys_link+0xce>
  ilock(dp);
    80005864:	c42fe0ef          	jal	80003ca6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005868:	854a                	mv	a0,s2
    8000586a:	00092703          	lw	a4,0(s2)
    8000586e:	409c                	lw	a5,0(s1)
    80005870:	04f71263          	bne	a4,a5,800058b4 <sys_link+0xc8>
    80005874:	40d0                	lw	a2,4(s1)
    80005876:	fd040593          	addi	a1,s0,-48
    8000587a:	bb1fe0ef          	jal	8000442a <dirlink>
    8000587e:	02054b63          	bltz	a0,800058b4 <sys_link+0xc8>
  iunlockput(dp);
    80005882:	854a                	mv	a0,s2
    80005884:	e2efe0ef          	jal	80003eb2 <iunlockput>
  iput(ip);
    80005888:	8526                	mv	a0,s1
    8000588a:	d9efe0ef          	jal	80003e28 <iput>
  end_op();
    8000588e:	e95fe0ef          	jal	80004722 <end_op>
  return 0;
    80005892:	4781                	li	a5,0
    80005894:	64f2                	ld	s1,280(sp)
    80005896:	6952                	ld	s2,272(sp)
    80005898:	a0a1                	j	800058e0 <sys_link+0xf4>
    end_op();
    8000589a:	e89fe0ef          	jal	80004722 <end_op>
    return -1;
    8000589e:	57fd                	li	a5,-1
    800058a0:	64f2                	ld	s1,280(sp)
    800058a2:	a83d                	j	800058e0 <sys_link+0xf4>
    iunlockput(ip);
    800058a4:	8526                	mv	a0,s1
    800058a6:	e0cfe0ef          	jal	80003eb2 <iunlockput>
    end_op();
    800058aa:	e79fe0ef          	jal	80004722 <end_op>
    return -1;
    800058ae:	57fd                	li	a5,-1
    800058b0:	64f2                	ld	s1,280(sp)
    800058b2:	a03d                	j	800058e0 <sys_link+0xf4>
    iunlockput(dp);
    800058b4:	854a                	mv	a0,s2
    800058b6:	dfcfe0ef          	jal	80003eb2 <iunlockput>
  ilock(ip);
    800058ba:	8526                	mv	a0,s1
    800058bc:	beafe0ef          	jal	80003ca6 <ilock>
  ip->nlink--;
    800058c0:	04a4d783          	lhu	a5,74(s1)
    800058c4:	37fd                	addiw	a5,a5,-1
    800058c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	b26fe0ef          	jal	80003bf2 <iupdate>
  iunlockput(ip);
    800058d0:	8526                	mv	a0,s1
    800058d2:	de0fe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    800058d6:	e4dfe0ef          	jal	80004722 <end_op>
  return -1;
    800058da:	57fd                	li	a5,-1
    800058dc:	64f2                	ld	s1,280(sp)
    800058de:	6952                	ld	s2,272(sp)
}
    800058e0:	853e                	mv	a0,a5
    800058e2:	70b2                	ld	ra,296(sp)
    800058e4:	7412                	ld	s0,288(sp)
    800058e6:	6155                	addi	sp,sp,304
    800058e8:	8082                	ret

00000000800058ea <sys_unlink>:
{
    800058ea:	7151                	addi	sp,sp,-240
    800058ec:	f586                	sd	ra,232(sp)
    800058ee:	f1a2                	sd	s0,224(sp)
    800058f0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058f2:	08000613          	li	a2,128
    800058f6:	f3040593          	addi	a1,s0,-208
    800058fa:	4501                	li	a0,0
    800058fc:	9edfd0ef          	jal	800032e8 <argstr>
    80005900:	14054d63          	bltz	a0,80005a5a <sys_unlink+0x170>
    80005904:	eda6                	sd	s1,216(sp)
  begin_op();
    80005906:	dadfe0ef          	jal	800046b2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000590a:	fb040593          	addi	a1,s0,-80
    8000590e:	f3040513          	addi	a0,s0,-208
    80005912:	bddfe0ef          	jal	800044ee <nameiparent>
    80005916:	84aa                	mv	s1,a0
    80005918:	c955                	beqz	a0,800059cc <sys_unlink+0xe2>
  ilock(dp);
    8000591a:	b8cfe0ef          	jal	80003ca6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000591e:	00003597          	auipc	a1,0x3
    80005922:	13258593          	addi	a1,a1,306 # 80008a50 <etext+0xa50>
    80005926:	fb040513          	addi	a0,s0,-80
    8000592a:	901fe0ef          	jal	8000422a <namecmp>
    8000592e:	10050b63          	beqz	a0,80005a44 <sys_unlink+0x15a>
    80005932:	00003597          	auipc	a1,0x3
    80005936:	12658593          	addi	a1,a1,294 # 80008a58 <etext+0xa58>
    8000593a:	fb040513          	addi	a0,s0,-80
    8000593e:	8edfe0ef          	jal	8000422a <namecmp>
    80005942:	10050163          	beqz	a0,80005a44 <sys_unlink+0x15a>
    80005946:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005948:	f2c40613          	addi	a2,s0,-212
    8000594c:	fb040593          	addi	a1,s0,-80
    80005950:	8526                	mv	a0,s1
    80005952:	8effe0ef          	jal	80004240 <dirlookup>
    80005956:	892a                	mv	s2,a0
    80005958:	0e050563          	beqz	a0,80005a42 <sys_unlink+0x158>
    8000595c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000595e:	b48fe0ef          	jal	80003ca6 <ilock>
  if(ip->nlink < 1)
    80005962:	04a91783          	lh	a5,74(s2)
    80005966:	06f05863          	blez	a5,800059d6 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000596a:	04491703          	lh	a4,68(s2)
    8000596e:	4785                	li	a5,1
    80005970:	06f70963          	beq	a4,a5,800059e2 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005974:	fc040993          	addi	s3,s0,-64
    80005978:	4641                	li	a2,16
    8000597a:	4581                	li	a1,0
    8000597c:	854e                	mv	a0,s3
    8000597e:	b7afb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005982:	4741                	li	a4,16
    80005984:	f2c42683          	lw	a3,-212(s0)
    80005988:	864e                	mv	a2,s3
    8000598a:	4581                	li	a1,0
    8000598c:	8526                	mv	a0,s1
    8000598e:	f9cfe0ef          	jal	8000412a <writei>
    80005992:	47c1                	li	a5,16
    80005994:	08f51863          	bne	a0,a5,80005a24 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005998:	04491703          	lh	a4,68(s2)
    8000599c:	4785                	li	a5,1
    8000599e:	08f70963          	beq	a4,a5,80005a30 <sys_unlink+0x146>
  iunlockput(dp);
    800059a2:	8526                	mv	a0,s1
    800059a4:	d0efe0ef          	jal	80003eb2 <iunlockput>
  ip->nlink--;
    800059a8:	04a95783          	lhu	a5,74(s2)
    800059ac:	37fd                	addiw	a5,a5,-1
    800059ae:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059b2:	854a                	mv	a0,s2
    800059b4:	a3efe0ef          	jal	80003bf2 <iupdate>
  iunlockput(ip);
    800059b8:	854a                	mv	a0,s2
    800059ba:	cf8fe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    800059be:	d65fe0ef          	jal	80004722 <end_op>
  return 0;
    800059c2:	4501                	li	a0,0
    800059c4:	64ee                	ld	s1,216(sp)
    800059c6:	694e                	ld	s2,208(sp)
    800059c8:	69ae                	ld	s3,200(sp)
    800059ca:	a061                	j	80005a52 <sys_unlink+0x168>
    end_op();
    800059cc:	d57fe0ef          	jal	80004722 <end_op>
    return -1;
    800059d0:	557d                	li	a0,-1
    800059d2:	64ee                	ld	s1,216(sp)
    800059d4:	a8bd                	j	80005a52 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800059d6:	00003517          	auipc	a0,0x3
    800059da:	08a50513          	addi	a0,a0,138 # 80008a60 <etext+0xa60>
    800059de:	e47fa0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059e2:	04c92703          	lw	a4,76(s2)
    800059e6:	02000793          	li	a5,32
    800059ea:	f8e7f5e3          	bgeu	a5,a4,80005974 <sys_unlink+0x8a>
    800059ee:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059f0:	4741                	li	a4,16
    800059f2:	86ce                	mv	a3,s3
    800059f4:	f1840613          	addi	a2,s0,-232
    800059f8:	4581                	li	a1,0
    800059fa:	854a                	mv	a0,s2
    800059fc:	e3cfe0ef          	jal	80004038 <readi>
    80005a00:	47c1                	li	a5,16
    80005a02:	00f51b63          	bne	a0,a5,80005a18 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005a06:	f1845783          	lhu	a5,-232(s0)
    80005a0a:	ebb1                	bnez	a5,80005a5e <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a0c:	29c1                	addiw	s3,s3,16
    80005a0e:	04c92783          	lw	a5,76(s2)
    80005a12:	fcf9efe3          	bltu	s3,a5,800059f0 <sys_unlink+0x106>
    80005a16:	bfb9                	j	80005974 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005a18:	00003517          	auipc	a0,0x3
    80005a1c:	06050513          	addi	a0,a0,96 # 80008a78 <etext+0xa78>
    80005a20:	e05fa0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005a24:	00003517          	auipc	a0,0x3
    80005a28:	06c50513          	addi	a0,a0,108 # 80008a90 <etext+0xa90>
    80005a2c:	df9fa0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005a30:	04a4d783          	lhu	a5,74(s1)
    80005a34:	37fd                	addiw	a5,a5,-1
    80005a36:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a3a:	8526                	mv	a0,s1
    80005a3c:	9b6fe0ef          	jal	80003bf2 <iupdate>
    80005a40:	b78d                	j	800059a2 <sys_unlink+0xb8>
    80005a42:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005a44:	8526                	mv	a0,s1
    80005a46:	c6cfe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    80005a4a:	cd9fe0ef          	jal	80004722 <end_op>
  return -1;
    80005a4e:	557d                	li	a0,-1
    80005a50:	64ee                	ld	s1,216(sp)
}
    80005a52:	70ae                	ld	ra,232(sp)
    80005a54:	740e                	ld	s0,224(sp)
    80005a56:	616d                	addi	sp,sp,240
    80005a58:	8082                	ret
    return -1;
    80005a5a:	557d                	li	a0,-1
    80005a5c:	bfdd                	j	80005a52 <sys_unlink+0x168>
    iunlockput(ip);
    80005a5e:	854a                	mv	a0,s2
    80005a60:	c52fe0ef          	jal	80003eb2 <iunlockput>
    goto bad;
    80005a64:	694e                	ld	s2,208(sp)
    80005a66:	69ae                	ld	s3,200(sp)
    80005a68:	bff1                	j	80005a44 <sys_unlink+0x15a>

0000000080005a6a <sys_open>:

uint64
sys_open(void)
{
    80005a6a:	7131                	addi	sp,sp,-192
    80005a6c:	fd06                	sd	ra,184(sp)
    80005a6e:	f922                	sd	s0,176(sp)
    80005a70:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a72:	f4c40593          	addi	a1,s0,-180
    80005a76:	4505                	li	a0,1
    80005a78:	839fd0ef          	jal	800032b0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a7c:	08000613          	li	a2,128
    80005a80:	f5040593          	addi	a1,s0,-176
    80005a84:	4501                	li	a0,0
    80005a86:	863fd0ef          	jal	800032e8 <argstr>
    80005a8a:	87aa                	mv	a5,a0
    return -1;
    80005a8c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a8e:	0a07c363          	bltz	a5,80005b34 <sys_open+0xca>
    80005a92:	f526                	sd	s1,168(sp)

  begin_op();
    80005a94:	c1ffe0ef          	jal	800046b2 <begin_op>

  if(omode & O_CREATE){
    80005a98:	f4c42783          	lw	a5,-180(s0)
    80005a9c:	2007f793          	andi	a5,a5,512
    80005aa0:	c3dd                	beqz	a5,80005b46 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005aa2:	4681                	li	a3,0
    80005aa4:	4601                	li	a2,0
    80005aa6:	4589                	li	a1,2
    80005aa8:	f5040513          	addi	a0,s0,-176
    80005aac:	aafff0ef          	jal	8000555a <create>
    80005ab0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ab2:	c549                	beqz	a0,80005b3c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ab4:	04449703          	lh	a4,68(s1)
    80005ab8:	478d                	li	a5,3
    80005aba:	00f71763          	bne	a4,a5,80005ac8 <sys_open+0x5e>
    80005abe:	0464d703          	lhu	a4,70(s1)
    80005ac2:	47a5                	li	a5,9
    80005ac4:	0ae7ee63          	bltu	a5,a4,80005b80 <sys_open+0x116>
    80005ac8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005aca:	f69fe0ef          	jal	80004a32 <filealloc>
    80005ace:	892a                	mv	s2,a0
    80005ad0:	c561                	beqz	a0,80005b98 <sys_open+0x12e>
    80005ad2:	ed4e                	sd	s3,152(sp)
    80005ad4:	a47ff0ef          	jal	8000551a <fdalloc>
    80005ad8:	89aa                	mv	s3,a0
    80005ada:	0a054b63          	bltz	a0,80005b90 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ade:	04449703          	lh	a4,68(s1)
    80005ae2:	478d                	li	a5,3
    80005ae4:	0cf70363          	beq	a4,a5,80005baa <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ae8:	4789                	li	a5,2
    80005aea:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005aee:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005af2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005af6:	f4c42783          	lw	a5,-180(s0)
    80005afa:	0017f713          	andi	a4,a5,1
    80005afe:	00174713          	xori	a4,a4,1
    80005b02:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b06:	0037f713          	andi	a4,a5,3
    80005b0a:	00e03733          	snez	a4,a4
    80005b0e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b12:	4007f793          	andi	a5,a5,1024
    80005b16:	c791                	beqz	a5,80005b22 <sys_open+0xb8>
    80005b18:	04449703          	lh	a4,68(s1)
    80005b1c:	4789                	li	a5,2
    80005b1e:	08f70d63          	beq	a4,a5,80005bb8 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005b22:	8526                	mv	a0,s1
    80005b24:	a30fe0ef          	jal	80003d54 <iunlock>
  end_op();
    80005b28:	bfbfe0ef          	jal	80004722 <end_op>

  return fd;
    80005b2c:	854e                	mv	a0,s3
    80005b2e:	74aa                	ld	s1,168(sp)
    80005b30:	790a                	ld	s2,160(sp)
    80005b32:	69ea                	ld	s3,152(sp)
}
    80005b34:	70ea                	ld	ra,184(sp)
    80005b36:	744a                	ld	s0,176(sp)
    80005b38:	6129                	addi	sp,sp,192
    80005b3a:	8082                	ret
      end_op();
    80005b3c:	be7fe0ef          	jal	80004722 <end_op>
      return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	74aa                	ld	s1,168(sp)
    80005b44:	bfc5                	j	80005b34 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005b46:	f5040513          	addi	a0,s0,-176
    80005b4a:	98bfe0ef          	jal	800044d4 <namei>
    80005b4e:	84aa                	mv	s1,a0
    80005b50:	c11d                	beqz	a0,80005b76 <sys_open+0x10c>
    ilock(ip);
    80005b52:	954fe0ef          	jal	80003ca6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b56:	04449703          	lh	a4,68(s1)
    80005b5a:	4785                	li	a5,1
    80005b5c:	f4f71ce3          	bne	a4,a5,80005ab4 <sys_open+0x4a>
    80005b60:	f4c42783          	lw	a5,-180(s0)
    80005b64:	d3b5                	beqz	a5,80005ac8 <sys_open+0x5e>
      iunlockput(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	b4afe0ef          	jal	80003eb2 <iunlockput>
      end_op();
    80005b6c:	bb7fe0ef          	jal	80004722 <end_op>
      return -1;
    80005b70:	557d                	li	a0,-1
    80005b72:	74aa                	ld	s1,168(sp)
    80005b74:	b7c1                	j	80005b34 <sys_open+0xca>
      end_op();
    80005b76:	badfe0ef          	jal	80004722 <end_op>
      return -1;
    80005b7a:	557d                	li	a0,-1
    80005b7c:	74aa                	ld	s1,168(sp)
    80005b7e:	bf5d                	j	80005b34 <sys_open+0xca>
    iunlockput(ip);
    80005b80:	8526                	mv	a0,s1
    80005b82:	b30fe0ef          	jal	80003eb2 <iunlockput>
    end_op();
    80005b86:	b9dfe0ef          	jal	80004722 <end_op>
    return -1;
    80005b8a:	557d                	li	a0,-1
    80005b8c:	74aa                	ld	s1,168(sp)
    80005b8e:	b75d                	j	80005b34 <sys_open+0xca>
      fileclose(f);
    80005b90:	854a                	mv	a0,s2
    80005b92:	f45fe0ef          	jal	80004ad6 <fileclose>
    80005b96:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005b98:	8526                	mv	a0,s1
    80005b9a:	b18fe0ef          	jal	80003eb2 <iunlockput>
    end_op();
    80005b9e:	b85fe0ef          	jal	80004722 <end_op>
    return -1;
    80005ba2:	557d                	li	a0,-1
    80005ba4:	74aa                	ld	s1,168(sp)
    80005ba6:	790a                	ld	s2,160(sp)
    80005ba8:	b771                	j	80005b34 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005baa:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005bae:	04649783          	lh	a5,70(s1)
    80005bb2:	02f91223          	sh	a5,36(s2)
    80005bb6:	bf35                	j	80005af2 <sys_open+0x88>
    itrunc(ip);
    80005bb8:	8526                	mv	a0,s1
    80005bba:	9dafe0ef          	jal	80003d94 <itrunc>
    80005bbe:	b795                	j	80005b22 <sys_open+0xb8>

0000000080005bc0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bc0:	7175                	addi	sp,sp,-144
    80005bc2:	e506                	sd	ra,136(sp)
    80005bc4:	e122                	sd	s0,128(sp)
    80005bc6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bc8:	aebfe0ef          	jal	800046b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bcc:	08000613          	li	a2,128
    80005bd0:	f7040593          	addi	a1,s0,-144
    80005bd4:	4501                	li	a0,0
    80005bd6:	f12fd0ef          	jal	800032e8 <argstr>
    80005bda:	02054363          	bltz	a0,80005c00 <sys_mkdir+0x40>
    80005bde:	4681                	li	a3,0
    80005be0:	4601                	li	a2,0
    80005be2:	4585                	li	a1,1
    80005be4:	f7040513          	addi	a0,s0,-144
    80005be8:	973ff0ef          	jal	8000555a <create>
    80005bec:	c911                	beqz	a0,80005c00 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bee:	ac4fe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    80005bf2:	b31fe0ef          	jal	80004722 <end_op>
  return 0;
    80005bf6:	4501                	li	a0,0
}
    80005bf8:	60aa                	ld	ra,136(sp)
    80005bfa:	640a                	ld	s0,128(sp)
    80005bfc:	6149                	addi	sp,sp,144
    80005bfe:	8082                	ret
    end_op();
    80005c00:	b23fe0ef          	jal	80004722 <end_op>
    return -1;
    80005c04:	557d                	li	a0,-1
    80005c06:	bfcd                	j	80005bf8 <sys_mkdir+0x38>

0000000080005c08 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c08:	7135                	addi	sp,sp,-160
    80005c0a:	ed06                	sd	ra,152(sp)
    80005c0c:	e922                	sd	s0,144(sp)
    80005c0e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c10:	aa3fe0ef          	jal	800046b2 <begin_op>
  argint(1, &major);
    80005c14:	f6c40593          	addi	a1,s0,-148
    80005c18:	4505                	li	a0,1
    80005c1a:	e96fd0ef          	jal	800032b0 <argint>
  argint(2, &minor);
    80005c1e:	f6840593          	addi	a1,s0,-152
    80005c22:	4509                	li	a0,2
    80005c24:	e8cfd0ef          	jal	800032b0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c28:	08000613          	li	a2,128
    80005c2c:	f7040593          	addi	a1,s0,-144
    80005c30:	4501                	li	a0,0
    80005c32:	eb6fd0ef          	jal	800032e8 <argstr>
    80005c36:	02054563          	bltz	a0,80005c60 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c3a:	f6841683          	lh	a3,-152(s0)
    80005c3e:	f6c41603          	lh	a2,-148(s0)
    80005c42:	458d                	li	a1,3
    80005c44:	f7040513          	addi	a0,s0,-144
    80005c48:	913ff0ef          	jal	8000555a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c4c:	c911                	beqz	a0,80005c60 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c4e:	a64fe0ef          	jal	80003eb2 <iunlockput>
  end_op();
    80005c52:	ad1fe0ef          	jal	80004722 <end_op>
  return 0;
    80005c56:	4501                	li	a0,0
}
    80005c58:	60ea                	ld	ra,152(sp)
    80005c5a:	644a                	ld	s0,144(sp)
    80005c5c:	610d                	addi	sp,sp,160
    80005c5e:	8082                	ret
    end_op();
    80005c60:	ac3fe0ef          	jal	80004722 <end_op>
    return -1;
    80005c64:	557d                	li	a0,-1
    80005c66:	bfcd                	j	80005c58 <sys_mknod+0x50>

0000000080005c68 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c68:	7135                	addi	sp,sp,-160
    80005c6a:	ed06                	sd	ra,152(sp)
    80005c6c:	e922                	sd	s0,144(sp)
    80005c6e:	e14a                	sd	s2,128(sp)
    80005c70:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c72:	e83fb0ef          	jal	80001af4 <myproc>
    80005c76:	892a                	mv	s2,a0
  
  begin_op();
    80005c78:	a3bfe0ef          	jal	800046b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c7c:	08000613          	li	a2,128
    80005c80:	f6040593          	addi	a1,s0,-160
    80005c84:	4501                	li	a0,0
    80005c86:	e62fd0ef          	jal	800032e8 <argstr>
    80005c8a:	04054363          	bltz	a0,80005cd0 <sys_chdir+0x68>
    80005c8e:	e526                	sd	s1,136(sp)
    80005c90:	f6040513          	addi	a0,s0,-160
    80005c94:	841fe0ef          	jal	800044d4 <namei>
    80005c98:	84aa                	mv	s1,a0
    80005c9a:	c915                	beqz	a0,80005cce <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c9c:	80afe0ef          	jal	80003ca6 <ilock>
  if(ip->type != T_DIR){
    80005ca0:	04449703          	lh	a4,68(s1)
    80005ca4:	4785                	li	a5,1
    80005ca6:	02f71963          	bne	a4,a5,80005cd8 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005caa:	8526                	mv	a0,s1
    80005cac:	8a8fe0ef          	jal	80003d54 <iunlock>
  iput(p->cwd);
    80005cb0:	15893503          	ld	a0,344(s2)
    80005cb4:	974fe0ef          	jal	80003e28 <iput>
  end_op();
    80005cb8:	a6bfe0ef          	jal	80004722 <end_op>
  p->cwd = ip;
    80005cbc:	14993c23          	sd	s1,344(s2)
  return 0;
    80005cc0:	4501                	li	a0,0
    80005cc2:	64aa                	ld	s1,136(sp)
}
    80005cc4:	60ea                	ld	ra,152(sp)
    80005cc6:	644a                	ld	s0,144(sp)
    80005cc8:	690a                	ld	s2,128(sp)
    80005cca:	610d                	addi	sp,sp,160
    80005ccc:	8082                	ret
    80005cce:	64aa                	ld	s1,136(sp)
    end_op();
    80005cd0:	a53fe0ef          	jal	80004722 <end_op>
    return -1;
    80005cd4:	557d                	li	a0,-1
    80005cd6:	b7fd                	j	80005cc4 <sys_chdir+0x5c>
    iunlockput(ip);
    80005cd8:	8526                	mv	a0,s1
    80005cda:	9d8fe0ef          	jal	80003eb2 <iunlockput>
    end_op();
    80005cde:	a45fe0ef          	jal	80004722 <end_op>
    return -1;
    80005ce2:	557d                	li	a0,-1
    80005ce4:	64aa                	ld	s1,136(sp)
    80005ce6:	bff9                	j	80005cc4 <sys_chdir+0x5c>

0000000080005ce8 <sys_exec>:

uint64
sys_exec(void)
{
    80005ce8:	7105                	addi	sp,sp,-480
    80005cea:	ef86                	sd	ra,472(sp)
    80005cec:	eba2                	sd	s0,464(sp)
    80005cee:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cf0:	e2840593          	addi	a1,s0,-472
    80005cf4:	4505                	li	a0,1
    80005cf6:	dd6fd0ef          	jal	800032cc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cfa:	08000613          	li	a2,128
    80005cfe:	f3040593          	addi	a1,s0,-208
    80005d02:	4501                	li	a0,0
    80005d04:	de4fd0ef          	jal	800032e8 <argstr>
    80005d08:	87aa                	mv	a5,a0
    return -1;
    80005d0a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d0c:	0e07c063          	bltz	a5,80005dec <sys_exec+0x104>
    80005d10:	e7a6                	sd	s1,456(sp)
    80005d12:	e3ca                	sd	s2,448(sp)
    80005d14:	ff4e                	sd	s3,440(sp)
    80005d16:	fb52                	sd	s4,432(sp)
    80005d18:	f756                	sd	s5,424(sp)
    80005d1a:	f35a                	sd	s6,416(sp)
    80005d1c:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005d1e:	e3040a13          	addi	s4,s0,-464
    80005d22:	10000613          	li	a2,256
    80005d26:	4581                	li	a1,0
    80005d28:	8552                	mv	a0,s4
    80005d2a:	fcffa0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d2e:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005d30:	89d2                	mv	s3,s4
    80005d32:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d34:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d38:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005d3a:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d3e:	00391513          	slli	a0,s2,0x3
    80005d42:	85d6                	mv	a1,s5
    80005d44:	e2843783          	ld	a5,-472(s0)
    80005d48:	953e                	add	a0,a0,a5
    80005d4a:	cdcfd0ef          	jal	80003226 <fetchaddr>
    80005d4e:	02054663          	bltz	a0,80005d7a <sys_exec+0x92>
    if(uarg == 0){
    80005d52:	e2043783          	ld	a5,-480(s0)
    80005d56:	c7a1                	beqz	a5,80005d9e <sys_exec+0xb6>
    argv[i] = kalloc();
    80005d58:	dedfa0ef          	jal	80000b44 <kalloc>
    80005d5c:	85aa                	mv	a1,a0
    80005d5e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d62:	cd01                	beqz	a0,80005d7a <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d64:	865a                	mv	a2,s6
    80005d66:	e2043503          	ld	a0,-480(s0)
    80005d6a:	d06fd0ef          	jal	80003270 <fetchstr>
    80005d6e:	00054663          	bltz	a0,80005d7a <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005d72:	0905                	addi	s2,s2,1
    80005d74:	09a1                	addi	s3,s3,8
    80005d76:	fd7914e3          	bne	s2,s7,80005d3e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d7a:	100a0a13          	addi	s4,s4,256
    80005d7e:	6088                	ld	a0,0(s1)
    80005d80:	cd31                	beqz	a0,80005ddc <sys_exec+0xf4>
    kfree(argv[i]);
    80005d82:	cdbfa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d86:	04a1                	addi	s1,s1,8
    80005d88:	ff449be3          	bne	s1,s4,80005d7e <sys_exec+0x96>
  return -1;
    80005d8c:	557d                	li	a0,-1
    80005d8e:	64be                	ld	s1,456(sp)
    80005d90:	691e                	ld	s2,448(sp)
    80005d92:	79fa                	ld	s3,440(sp)
    80005d94:	7a5a                	ld	s4,432(sp)
    80005d96:	7aba                	ld	s5,424(sp)
    80005d98:	7b1a                	ld	s6,416(sp)
    80005d9a:	6bfa                	ld	s7,408(sp)
    80005d9c:	a881                	j	80005dec <sys_exec+0x104>
      argv[i] = 0;
    80005d9e:	0009079b          	sext.w	a5,s2
    80005da2:	e3040593          	addi	a1,s0,-464
    80005da6:	078e                	slli	a5,a5,0x3
    80005da8:	97ae                	add	a5,a5,a1
    80005daa:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005dae:	f3040513          	addi	a0,s0,-208
    80005db2:	bb2ff0ef          	jal	80005164 <kexec>
    80005db6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db8:	100a0a13          	addi	s4,s4,256
    80005dbc:	6088                	ld	a0,0(s1)
    80005dbe:	c511                	beqz	a0,80005dca <sys_exec+0xe2>
    kfree(argv[i]);
    80005dc0:	c9dfa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dc4:	04a1                	addi	s1,s1,8
    80005dc6:	ff449be3          	bne	s1,s4,80005dbc <sys_exec+0xd4>
  return ret;
    80005dca:	854a                	mv	a0,s2
    80005dcc:	64be                	ld	s1,456(sp)
    80005dce:	691e                	ld	s2,448(sp)
    80005dd0:	79fa                	ld	s3,440(sp)
    80005dd2:	7a5a                	ld	s4,432(sp)
    80005dd4:	7aba                	ld	s5,424(sp)
    80005dd6:	7b1a                	ld	s6,416(sp)
    80005dd8:	6bfa                	ld	s7,408(sp)
    80005dda:	a809                	j	80005dec <sys_exec+0x104>
  return -1;
    80005ddc:	557d                	li	a0,-1
    80005dde:	64be                	ld	s1,456(sp)
    80005de0:	691e                	ld	s2,448(sp)
    80005de2:	79fa                	ld	s3,440(sp)
    80005de4:	7a5a                	ld	s4,432(sp)
    80005de6:	7aba                	ld	s5,424(sp)
    80005de8:	7b1a                	ld	s6,416(sp)
    80005dea:	6bfa                	ld	s7,408(sp)
}
    80005dec:	60fe                	ld	ra,472(sp)
    80005dee:	645e                	ld	s0,464(sp)
    80005df0:	613d                	addi	sp,sp,480
    80005df2:	8082                	ret

0000000080005df4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005df4:	7139                	addi	sp,sp,-64
    80005df6:	fc06                	sd	ra,56(sp)
    80005df8:	f822                	sd	s0,48(sp)
    80005dfa:	f426                	sd	s1,40(sp)
    80005dfc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dfe:	cf7fb0ef          	jal	80001af4 <myproc>
    80005e02:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e04:	fd840593          	addi	a1,s0,-40
    80005e08:	4501                	li	a0,0
    80005e0a:	cc2fd0ef          	jal	800032cc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e0e:	fc840593          	addi	a1,s0,-56
    80005e12:	fd040513          	addi	a0,s0,-48
    80005e16:	fddfe0ef          	jal	80004df2 <pipealloc>
    return -1;
    80005e1a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e1c:	0a054763          	bltz	a0,80005eca <sys_pipe+0xd6>
  fd0 = -1;
    80005e20:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e24:	fd043503          	ld	a0,-48(s0)
    80005e28:	ef2ff0ef          	jal	8000551a <fdalloc>
    80005e2c:	fca42223          	sw	a0,-60(s0)
    80005e30:	08054463          	bltz	a0,80005eb8 <sys_pipe+0xc4>
    80005e34:	fc843503          	ld	a0,-56(s0)
    80005e38:	ee2ff0ef          	jal	8000551a <fdalloc>
    80005e3c:	fca42023          	sw	a0,-64(s0)
    80005e40:	06054263          	bltz	a0,80005ea4 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e44:	4691                	li	a3,4
    80005e46:	fc440613          	addi	a2,s0,-60
    80005e4a:	fd843583          	ld	a1,-40(s0)
    80005e4e:	6ca8                	ld	a0,88(s1)
    80005e50:	805fb0ef          	jal	80001654 <copyout>
    80005e54:	00054e63          	bltz	a0,80005e70 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e58:	4691                	li	a3,4
    80005e5a:	fc040613          	addi	a2,s0,-64
    80005e5e:	fd843583          	ld	a1,-40(s0)
    80005e62:	95b6                	add	a1,a1,a3
    80005e64:	6ca8                	ld	a0,88(s1)
    80005e66:	feefb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e6c:	04055f63          	bgez	a0,80005eca <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005e70:	fc442783          	lw	a5,-60(s0)
    80005e74:	078e                	slli	a5,a5,0x3
    80005e76:	0d078793          	addi	a5,a5,208
    80005e7a:	97a6                	add	a5,a5,s1
    80005e7c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e80:	fc042783          	lw	a5,-64(s0)
    80005e84:	078e                	slli	a5,a5,0x3
    80005e86:	0d078793          	addi	a5,a5,208
    80005e8a:	97a6                	add	a5,a5,s1
    80005e8c:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e90:	fd043503          	ld	a0,-48(s0)
    80005e94:	c43fe0ef          	jal	80004ad6 <fileclose>
    fileclose(wf);
    80005e98:	fc843503          	ld	a0,-56(s0)
    80005e9c:	c3bfe0ef          	jal	80004ad6 <fileclose>
    return -1;
    80005ea0:	57fd                	li	a5,-1
    80005ea2:	a025                	j	80005eca <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005ea4:	fc442783          	lw	a5,-60(s0)
    80005ea8:	0007c863          	bltz	a5,80005eb8 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005eac:	078e                	slli	a5,a5,0x3
    80005eae:	0d078793          	addi	a5,a5,208
    80005eb2:	97a6                	add	a5,a5,s1
    80005eb4:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005eb8:	fd043503          	ld	a0,-48(s0)
    80005ebc:	c1bfe0ef          	jal	80004ad6 <fileclose>
    fileclose(wf);
    80005ec0:	fc843503          	ld	a0,-56(s0)
    80005ec4:	c13fe0ef          	jal	80004ad6 <fileclose>
    return -1;
    80005ec8:	57fd                	li	a5,-1
}
    80005eca:	853e                	mv	a0,a5
    80005ecc:	70e2                	ld	ra,56(sp)
    80005ece:	7442                	ld	s0,48(sp)
    80005ed0:	74a2                	ld	s1,40(sp)
    80005ed2:	6121                	addi	sp,sp,64
    80005ed4:	8082                	ret
	...

0000000080005ee0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005ee0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005ee2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005ee4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005ee6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005ee8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005eea:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005eec:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005eee:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005ef0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005ef2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005ef4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005ef6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005ef8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005efa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005efc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005efe:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005f00:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005f02:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005f04:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005f06:	a2efd0ef          	jal	80003134 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005f0a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005f0c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005f0e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005f10:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005f12:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005f14:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005f16:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005f18:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005f1a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005f1c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005f1e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005f20:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005f22:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005f24:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005f26:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005f28:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005f2a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005f2c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005f2e:	10200073          	sret
    80005f32:	00000013          	nop
    80005f36:	00000013          	nop
    80005f3a:	00000013          	nop

0000000080005f3e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f3e:	1141                	addi	sp,sp,-16
    80005f40:	e406                	sd	ra,8(sp)
    80005f42:	e022                	sd	s0,0(sp)
    80005f44:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f46:	0c000737          	lui	a4,0xc000
    80005f4a:	4785                	li	a5,1
    80005f4c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f4e:	c35c                	sw	a5,4(a4)
}
    80005f50:	60a2                	ld	ra,8(sp)
    80005f52:	6402                	ld	s0,0(sp)
    80005f54:	0141                	addi	sp,sp,16
    80005f56:	8082                	ret

0000000080005f58 <plicinithart>:

void
plicinithart(void)
{
    80005f58:	1141                	addi	sp,sp,-16
    80005f5a:	e406                	sd	ra,8(sp)
    80005f5c:	e022                	sd	s0,0(sp)
    80005f5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f60:	b61fb0ef          	jal	80001ac0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f64:	0085171b          	slliw	a4,a0,0x8
    80005f68:	0c0027b7          	lui	a5,0xc002
    80005f6c:	97ba                	add	a5,a5,a4
    80005f6e:	40200713          	li	a4,1026
    80005f72:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f76:	00d5151b          	slliw	a0,a0,0xd
    80005f7a:	0c2017b7          	lui	a5,0xc201
    80005f7e:	97aa                	add	a5,a5,a0
    80005f80:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f8c:	1141                	addi	sp,sp,-16
    80005f8e:	e406                	sd	ra,8(sp)
    80005f90:	e022                	sd	s0,0(sp)
    80005f92:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f94:	b2dfb0ef          	jal	80001ac0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f98:	00d5151b          	slliw	a0,a0,0xd
    80005f9c:	0c2017b7          	lui	a5,0xc201
    80005fa0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fa2:	43c8                	lw	a0,4(a5)
    80005fa4:	60a2                	ld	ra,8(sp)
    80005fa6:	6402                	ld	s0,0(sp)
    80005fa8:	0141                	addi	sp,sp,16
    80005faa:	8082                	ret

0000000080005fac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fac:	1101                	addi	sp,sp,-32
    80005fae:	ec06                	sd	ra,24(sp)
    80005fb0:	e822                	sd	s0,16(sp)
    80005fb2:	e426                	sd	s1,8(sp)
    80005fb4:	1000                	addi	s0,sp,32
    80005fb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fb8:	b09fb0ef          	jal	80001ac0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fbc:	00d5179b          	slliw	a5,a0,0xd
    80005fc0:	0c201737          	lui	a4,0xc201
    80005fc4:	97ba                	add	a5,a5,a4
    80005fc6:	c3c4                	sw	s1,4(a5)
}
    80005fc8:	60e2                	ld	ra,24(sp)
    80005fca:	6442                	ld	s0,16(sp)
    80005fcc:	64a2                	ld	s1,8(sp)
    80005fce:	6105                	addi	sp,sp,32
    80005fd0:	8082                	ret

0000000080005fd2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fd2:	1141                	addi	sp,sp,-16
    80005fd4:	e406                	sd	ra,8(sp)
    80005fd6:	e022                	sd	s0,0(sp)
    80005fd8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fda:	479d                	li	a5,7
    80005fdc:	04a7ca63          	blt	a5,a0,80006030 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005fe0:	0001f797          	auipc	a5,0x1f
    80005fe4:	e4878793          	addi	a5,a5,-440 # 80024e28 <disk>
    80005fe8:	97aa                	add	a5,a5,a0
    80005fea:	0187c783          	lbu	a5,24(a5)
    80005fee:	e7b9                	bnez	a5,8000603c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ff0:	00451693          	slli	a3,a0,0x4
    80005ff4:	0001f797          	auipc	a5,0x1f
    80005ff8:	e3478793          	addi	a5,a5,-460 # 80024e28 <disk>
    80005ffc:	6398                	ld	a4,0(a5)
    80005ffe:	9736                	add	a4,a4,a3
    80006000:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80006004:	6398                	ld	a4,0(a5)
    80006006:	9736                	add	a4,a4,a3
    80006008:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000600c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006010:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006014:	97aa                	add	a5,a5,a0
    80006016:	4705                	li	a4,1
    80006018:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000601c:	0001f517          	auipc	a0,0x1f
    80006020:	e2450513          	addi	a0,a0,-476 # 80024e40 <disk+0x18>
    80006024:	fc8fc0ef          	jal	800027ec <wakeup>
}
    80006028:	60a2                	ld	ra,8(sp)
    8000602a:	6402                	ld	s0,0(sp)
    8000602c:	0141                	addi	sp,sp,16
    8000602e:	8082                	ret
    panic("free_desc 1");
    80006030:	00003517          	auipc	a0,0x3
    80006034:	a7050513          	addi	a0,a0,-1424 # 80008aa0 <etext+0xaa0>
    80006038:	fecfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000603c:	00003517          	auipc	a0,0x3
    80006040:	a7450513          	addi	a0,a0,-1420 # 80008ab0 <etext+0xab0>
    80006044:	fe0fa0ef          	jal	80000824 <panic>

0000000080006048 <virtio_disk_init>:
{
    80006048:	1101                	addi	sp,sp,-32
    8000604a:	ec06                	sd	ra,24(sp)
    8000604c:	e822                	sd	s0,16(sp)
    8000604e:	e426                	sd	s1,8(sp)
    80006050:	e04a                	sd	s2,0(sp)
    80006052:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006054:	00003597          	auipc	a1,0x3
    80006058:	a6c58593          	addi	a1,a1,-1428 # 80008ac0 <etext+0xac0>
    8000605c:	0001f517          	auipc	a0,0x1f
    80006060:	ef450513          	addi	a0,a0,-268 # 80024f50 <disk+0x128>
    80006064:	b3bfa0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006068:	100017b7          	lui	a5,0x10001
    8000606c:	4398                	lw	a4,0(a5)
    8000606e:	2701                	sext.w	a4,a4
    80006070:	747277b7          	lui	a5,0x74727
    80006074:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006078:	14f71863          	bne	a4,a5,800061c8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000607c:	100017b7          	lui	a5,0x10001
    80006080:	43dc                	lw	a5,4(a5)
    80006082:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006084:	4709                	li	a4,2
    80006086:	14e79163          	bne	a5,a4,800061c8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000608a:	100017b7          	lui	a5,0x10001
    8000608e:	479c                	lw	a5,8(a5)
    80006090:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006092:	12e79b63          	bne	a5,a4,800061c8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006096:	100017b7          	lui	a5,0x10001
    8000609a:	47d8                	lw	a4,12(a5)
    8000609c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000609e:	554d47b7          	lui	a5,0x554d4
    800060a2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060a6:	12f71163          	bne	a4,a5,800061c8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060aa:	100017b7          	lui	a5,0x10001
    800060ae:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b2:	4705                	li	a4,1
    800060b4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b6:	470d                	li	a4,3
    800060b8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ba:	10001737          	lui	a4,0x10001
    800060be:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060c0:	c7ffe6b7          	lui	a3,0xc7ffe
    800060c4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd97f7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060c8:	8f75                	and	a4,a4,a3
    800060ca:	100016b7          	lui	a3,0x10001
    800060ce:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060d0:	472d                	li	a4,11
    800060d2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060d4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800060d8:	439c                	lw	a5,0(a5)
    800060da:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060de:	8ba1                	andi	a5,a5,8
    800060e0:	0e078a63          	beqz	a5,800061d4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060e4:	100017b7          	lui	a5,0x10001
    800060e8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060ec:	43fc                	lw	a5,68(a5)
    800060ee:	2781                	sext.w	a5,a5
    800060f0:	0e079863          	bnez	a5,800061e0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060f4:	100017b7          	lui	a5,0x10001
    800060f8:	5bdc                	lw	a5,52(a5)
    800060fa:	2781                	sext.w	a5,a5
  if(max == 0)
    800060fc:	0e078863          	beqz	a5,800061ec <virtio_disk_init+0x1a4>
  if(max < NUM)
    80006100:	471d                	li	a4,7
    80006102:	0ef77b63          	bgeu	a4,a5,800061f8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80006106:	a3ffa0ef          	jal	80000b44 <kalloc>
    8000610a:	0001f497          	auipc	s1,0x1f
    8000610e:	d1e48493          	addi	s1,s1,-738 # 80024e28 <disk>
    80006112:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006114:	a31fa0ef          	jal	80000b44 <kalloc>
    80006118:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000611a:	a2bfa0ef          	jal	80000b44 <kalloc>
    8000611e:	87aa                	mv	a5,a0
    80006120:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006122:	6088                	ld	a0,0(s1)
    80006124:	0e050063          	beqz	a0,80006204 <virtio_disk_init+0x1bc>
    80006128:	0001f717          	auipc	a4,0x1f
    8000612c:	d0873703          	ld	a4,-760(a4) # 80024e30 <disk+0x8>
    80006130:	cb71                	beqz	a4,80006204 <virtio_disk_init+0x1bc>
    80006132:	cbe9                	beqz	a5,80006204 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80006134:	6605                	lui	a2,0x1
    80006136:	4581                	li	a1,0
    80006138:	bc1fa0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000613c:	0001f497          	auipc	s1,0x1f
    80006140:	cec48493          	addi	s1,s1,-788 # 80024e28 <disk>
    80006144:	6605                	lui	a2,0x1
    80006146:	4581                	li	a1,0
    80006148:	6488                	ld	a0,8(s1)
    8000614a:	baffa0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000614e:	6605                	lui	a2,0x1
    80006150:	4581                	li	a1,0
    80006152:	6888                	ld	a0,16(s1)
    80006154:	ba5fa0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	4721                	li	a4,8
    8000615e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006160:	4098                	lw	a4,0(s1)
    80006162:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006166:	40d8                	lw	a4,4(s1)
    80006168:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000616c:	649c                	ld	a5,8(s1)
    8000616e:	0007869b          	sext.w	a3,a5
    80006172:	10001737          	lui	a4,0x10001
    80006176:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000617a:	9781                	srai	a5,a5,0x20
    8000617c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006180:	689c                	ld	a5,16(s1)
    80006182:	0007869b          	sext.w	a3,a5
    80006186:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000618a:	9781                	srai	a5,a5,0x20
    8000618c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006190:	4785                	li	a5,1
    80006192:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006194:	00f48c23          	sb	a5,24(s1)
    80006198:	00f48ca3          	sb	a5,25(s1)
    8000619c:	00f48d23          	sb	a5,26(s1)
    800061a0:	00f48da3          	sb	a5,27(s1)
    800061a4:	00f48e23          	sb	a5,28(s1)
    800061a8:	00f48ea3          	sb	a5,29(s1)
    800061ac:	00f48f23          	sb	a5,30(s1)
    800061b0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061b4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b8:	07272823          	sw	s2,112(a4)
}
    800061bc:	60e2                	ld	ra,24(sp)
    800061be:	6442                	ld	s0,16(sp)
    800061c0:	64a2                	ld	s1,8(sp)
    800061c2:	6902                	ld	s2,0(sp)
    800061c4:	6105                	addi	sp,sp,32
    800061c6:	8082                	ret
    panic("could not find virtio disk");
    800061c8:	00003517          	auipc	a0,0x3
    800061cc:	90850513          	addi	a0,a0,-1784 # 80008ad0 <etext+0xad0>
    800061d0:	e54fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061d4:	00003517          	auipc	a0,0x3
    800061d8:	91c50513          	addi	a0,a0,-1764 # 80008af0 <etext+0xaf0>
    800061dc:	e48fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    800061e0:	00003517          	auipc	a0,0x3
    800061e4:	93050513          	addi	a0,a0,-1744 # 80008b10 <etext+0xb10>
    800061e8:	e3cfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    800061ec:	00003517          	auipc	a0,0x3
    800061f0:	94450513          	addi	a0,a0,-1724 # 80008b30 <etext+0xb30>
    800061f4:	e30fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    800061f8:	00003517          	auipc	a0,0x3
    800061fc:	95850513          	addi	a0,a0,-1704 # 80008b50 <etext+0xb50>
    80006200:	e24fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80006204:	00003517          	auipc	a0,0x3
    80006208:	96c50513          	addi	a0,a0,-1684 # 80008b70 <etext+0xb70>
    8000620c:	e18fa0ef          	jal	80000824 <panic>

0000000080006210 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006210:	711d                	addi	sp,sp,-96
    80006212:	ec86                	sd	ra,88(sp)
    80006214:	e8a2                	sd	s0,80(sp)
    80006216:	e4a6                	sd	s1,72(sp)
    80006218:	e0ca                	sd	s2,64(sp)
    8000621a:	fc4e                	sd	s3,56(sp)
    8000621c:	f852                	sd	s4,48(sp)
    8000621e:	f456                	sd	s5,40(sp)
    80006220:	f05a                	sd	s6,32(sp)
    80006222:	ec5e                	sd	s7,24(sp)
    80006224:	e862                	sd	s8,16(sp)
    80006226:	1080                	addi	s0,sp,96
    80006228:	89aa                	mv	s3,a0
    8000622a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000622c:	00c52b83          	lw	s7,12(a0)
    80006230:	001b9b9b          	slliw	s7,s7,0x1
    80006234:	1b82                	slli	s7,s7,0x20
    80006236:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000623a:	0001f517          	auipc	a0,0x1f
    8000623e:	d1650513          	addi	a0,a0,-746 # 80024f50 <disk+0x128>
    80006242:	9e7fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80006246:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006248:	0001fa97          	auipc	s5,0x1f
    8000624c:	be0a8a93          	addi	s5,s5,-1056 # 80024e28 <disk>
  for(int i = 0; i < 3; i++){
    80006250:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80006252:	5c7d                	li	s8,-1
    80006254:	a095                	j	800062b8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80006256:	00fa8733          	add	a4,s5,a5
    8000625a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000625e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006260:	0207c563          	bltz	a5,8000628a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80006264:	2905                	addiw	s2,s2,1
    80006266:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006268:	05490c63          	beq	s2,s4,800062c0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000626c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000626e:	0001f717          	auipc	a4,0x1f
    80006272:	bba70713          	addi	a4,a4,-1094 # 80024e28 <disk>
    80006276:	4781                	li	a5,0
    if(disk.free[i]){
    80006278:	01874683          	lbu	a3,24(a4)
    8000627c:	fee9                	bnez	a3,80006256 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000627e:	2785                	addiw	a5,a5,1
    80006280:	0705                	addi	a4,a4,1
    80006282:	fe979be3          	bne	a5,s1,80006278 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80006286:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000628a:	01205d63          	blez	s2,800062a4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000628e:	fa042503          	lw	a0,-96(s0)
    80006292:	d41ff0ef          	jal	80005fd2 <free_desc>
      for(int j = 0; j < i; j++)
    80006296:	4785                	li	a5,1
    80006298:	0127d663          	bge	a5,s2,800062a4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000629c:	fa442503          	lw	a0,-92(s0)
    800062a0:	d33ff0ef          	jal	80005fd2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062a4:	0001f597          	auipc	a1,0x1f
    800062a8:	cac58593          	addi	a1,a1,-852 # 80024f50 <disk+0x128>
    800062ac:	0001f517          	auipc	a0,0x1f
    800062b0:	b9450513          	addi	a0,a0,-1132 # 80024e40 <disk+0x18>
    800062b4:	cecfc0ef          	jal	800027a0 <sleep>
  for(int i = 0; i < 3; i++){
    800062b8:	fa040613          	addi	a2,s0,-96
    800062bc:	4901                	li	s2,0
    800062be:	b77d                	j	8000626c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062c0:	fa042503          	lw	a0,-96(s0)
    800062c4:	00451693          	slli	a3,a0,0x4

  if(write)
    800062c8:	0001f797          	auipc	a5,0x1f
    800062cc:	b6078793          	addi	a5,a5,-1184 # 80024e28 <disk>
    800062d0:	00451713          	slli	a4,a0,0x4
    800062d4:	0a070713          	addi	a4,a4,160
    800062d8:	973e                	add	a4,a4,a5
    800062da:	01603633          	snez	a2,s6
    800062de:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062e0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062e4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062e8:	6398                	ld	a4,0(a5)
    800062ea:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062ec:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800062f0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062f2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062f4:	6390                	ld	a2,0(a5)
    800062f6:	00d60833          	add	a6,a2,a3
    800062fa:	4741                	li	a4,16
    800062fc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006300:	4585                	li	a1,1
    80006302:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80006306:	fa442703          	lw	a4,-92(s0)
    8000630a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000630e:	0712                	slli	a4,a4,0x4
    80006310:	963a                	add	a2,a2,a4
    80006312:	05898813          	addi	a6,s3,88
    80006316:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000631a:	0007b883          	ld	a7,0(a5)
    8000631e:	9746                	add	a4,a4,a7
    80006320:	40000613          	li	a2,1024
    80006324:	c710                	sw	a2,8(a4)
  if(write)
    80006326:	001b3613          	seqz	a2,s6
    8000632a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000632e:	8e4d                	or	a2,a2,a1
    80006330:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006334:	fa842603          	lw	a2,-88(s0)
    80006338:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000633c:	00451813          	slli	a6,a0,0x4
    80006340:	02080813          	addi	a6,a6,32
    80006344:	983e                	add	a6,a6,a5
    80006346:	577d                	li	a4,-1
    80006348:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000634c:	0612                	slli	a2,a2,0x4
    8000634e:	98b2                	add	a7,a7,a2
    80006350:	03068713          	addi	a4,a3,48
    80006354:	973e                	add	a4,a4,a5
    80006356:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    8000635a:	6398                	ld	a4,0(a5)
    8000635c:	9732                	add	a4,a4,a2
    8000635e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006360:	4689                	li	a3,2
    80006362:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006366:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000636a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000636e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006372:	6794                	ld	a3,8(a5)
    80006374:	0026d703          	lhu	a4,2(a3)
    80006378:	8b1d                	andi	a4,a4,7
    8000637a:	0706                	slli	a4,a4,0x1
    8000637c:	96ba                	add	a3,a3,a4
    8000637e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006382:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006386:	6798                	ld	a4,8(a5)
    80006388:	00275783          	lhu	a5,2(a4)
    8000638c:	2785                	addiw	a5,a5,1
    8000638e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006392:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006396:	100017b7          	lui	a5,0x10001
    8000639a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000639e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    800063a2:	0001f917          	auipc	s2,0x1f
    800063a6:	bae90913          	addi	s2,s2,-1106 # 80024f50 <disk+0x128>
  while(b->disk == 1) {
    800063aa:	84ae                	mv	s1,a1
    800063ac:	00b79a63          	bne	a5,a1,800063c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800063b0:	85ca                	mv	a1,s2
    800063b2:	854e                	mv	a0,s3
    800063b4:	becfc0ef          	jal	800027a0 <sleep>
  while(b->disk == 1) {
    800063b8:	0049a783          	lw	a5,4(s3)
    800063bc:	fe978ae3          	beq	a5,s1,800063b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800063c0:	fa042903          	lw	s2,-96(s0)
    800063c4:	00491713          	slli	a4,s2,0x4
    800063c8:	02070713          	addi	a4,a4,32
    800063cc:	0001f797          	auipc	a5,0x1f
    800063d0:	a5c78793          	addi	a5,a5,-1444 # 80024e28 <disk>
    800063d4:	97ba                	add	a5,a5,a4
    800063d6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063da:	0001f997          	auipc	s3,0x1f
    800063de:	a4e98993          	addi	s3,s3,-1458 # 80024e28 <disk>
    800063e2:	00491713          	slli	a4,s2,0x4
    800063e6:	0009b783          	ld	a5,0(s3)
    800063ea:	97ba                	add	a5,a5,a4
    800063ec:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063f0:	854a                	mv	a0,s2
    800063f2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063f6:	bddff0ef          	jal	80005fd2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063fa:	8885                	andi	s1,s1,1
    800063fc:	f0fd                	bnez	s1,800063e2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063fe:	0001f517          	auipc	a0,0x1f
    80006402:	b5250513          	addi	a0,a0,-1198 # 80024f50 <disk+0x128>
    80006406:	8b7fa0ef          	jal	80000cbc <release>
}
    8000640a:	60e6                	ld	ra,88(sp)
    8000640c:	6446                	ld	s0,80(sp)
    8000640e:	64a6                	ld	s1,72(sp)
    80006410:	6906                	ld	s2,64(sp)
    80006412:	79e2                	ld	s3,56(sp)
    80006414:	7a42                	ld	s4,48(sp)
    80006416:	7aa2                	ld	s5,40(sp)
    80006418:	7b02                	ld	s6,32(sp)
    8000641a:	6be2                	ld	s7,24(sp)
    8000641c:	6c42                	ld	s8,16(sp)
    8000641e:	6125                	addi	sp,sp,96
    80006420:	8082                	ret

0000000080006422 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006422:	1101                	addi	sp,sp,-32
    80006424:	ec06                	sd	ra,24(sp)
    80006426:	e822                	sd	s0,16(sp)
    80006428:	e426                	sd	s1,8(sp)
    8000642a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000642c:	0001f497          	auipc	s1,0x1f
    80006430:	9fc48493          	addi	s1,s1,-1540 # 80024e28 <disk>
    80006434:	0001f517          	auipc	a0,0x1f
    80006438:	b1c50513          	addi	a0,a0,-1252 # 80024f50 <disk+0x128>
    8000643c:	fecfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006440:	100017b7          	lui	a5,0x10001
    80006444:	53bc                	lw	a5,96(a5)
    80006446:	8b8d                	andi	a5,a5,3
    80006448:	10001737          	lui	a4,0x10001
    8000644c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000644e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006452:	689c                	ld	a5,16(s1)
    80006454:	0204d703          	lhu	a4,32(s1)
    80006458:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000645c:	04f70863          	beq	a4,a5,800064ac <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006460:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006464:	6898                	ld	a4,16(s1)
    80006466:	0204d783          	lhu	a5,32(s1)
    8000646a:	8b9d                	andi	a5,a5,7
    8000646c:	078e                	slli	a5,a5,0x3
    8000646e:	97ba                	add	a5,a5,a4
    80006470:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006472:	00479713          	slli	a4,a5,0x4
    80006476:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    8000647a:	9726                	add	a4,a4,s1
    8000647c:	01074703          	lbu	a4,16(a4)
    80006480:	e329                	bnez	a4,800064c2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006482:	0792                	slli	a5,a5,0x4
    80006484:	02078793          	addi	a5,a5,32
    80006488:	97a6                	add	a5,a5,s1
    8000648a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000648c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006490:	b5cfc0ef          	jal	800027ec <wakeup>

    disk.used_idx += 1;
    80006494:	0204d783          	lhu	a5,32(s1)
    80006498:	2785                	addiw	a5,a5,1
    8000649a:	17c2                	slli	a5,a5,0x30
    8000649c:	93c1                	srli	a5,a5,0x30
    8000649e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064a2:	6898                	ld	a4,16(s1)
    800064a4:	00275703          	lhu	a4,2(a4)
    800064a8:	faf71ce3          	bne	a4,a5,80006460 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064ac:	0001f517          	auipc	a0,0x1f
    800064b0:	aa450513          	addi	a0,a0,-1372 # 80024f50 <disk+0x128>
    800064b4:	809fa0ef          	jal	80000cbc <release>
}
    800064b8:	60e2                	ld	ra,24(sp)
    800064ba:	6442                	ld	s0,16(sp)
    800064bc:	64a2                	ld	s1,8(sp)
    800064be:	6105                	addi	sp,sp,32
    800064c0:	8082                	ret
      panic("virtio_disk_intr status");
    800064c2:	00002517          	auipc	a0,0x2
    800064c6:	6c650513          	addi	a0,a0,1734 # 80008b88 <etext+0xb88>
    800064ca:	b5afa0ef          	jal	80000824 <panic>
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
