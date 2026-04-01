
user/_matrix:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <mat_init>:
static int C[N][N];

// Fill a matrix with a simple deterministic pattern.
static void
mat_init(int m[N][N], int seed)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  for(int i = 0; i < N; i++)
   8:	05050813          	addi	a6,a0,80
   c:	69050893          	addi	a7,a0,1680
    for(int j = 0; j < N; j++)
      m[i][j] = (seed + i * N + j) % 97;   // small primes keep values bounded
  10:	151d0537          	lui	a0,0x151d0
  14:	7eb50513          	addi	a0,a0,2027 # 151d07eb <base+0x151cd51b>
    for(int j = 0; j < N; j++)
  18:	fb080613          	addi	a2,a6,-80
{
  1c:	86ae                	mv	a3,a1
      m[i][j] = (seed + i * N + j) % 97;   // small primes keep values bounded
  1e:	02a68733          	mul	a4,a3,a0
  22:	970d                	srai	a4,a4,0x23
  24:	41f6d79b          	sraiw	a5,a3,0x1f
  28:	9f1d                	subw	a4,a4,a5
  2a:	0017179b          	slliw	a5,a4,0x1
  2e:	9fb9                	addw	a5,a5,a4
  30:	0057979b          	slliw	a5,a5,0x5
  34:	9fb9                	addw	a5,a5,a4
  36:	40f687bb          	subw	a5,a3,a5
  3a:	c21c                	sw	a5,0(a2)
    for(int j = 0; j < N; j++)
  3c:	2685                	addiw	a3,a3,1
  3e:	0611                	addi	a2,a2,4
  40:	fd061fe3          	bne	a2,a6,1e <mat_init+0x1e>
  for(int i = 0; i < N; i++)
  44:	25d1                	addiw	a1,a1,20
  46:	05080813          	addi	a6,a6,80
  4a:	fd1817e3          	bne	a6,a7,18 <mat_init+0x18>
}
  4e:	60a2                	ld	ra,8(sp)
  50:	6402                	ld	s0,0(sp)
  52:	0141                	addi	sp,sp,16
  54:	8082                	ret

0000000000000056 <main>:
         child_id, getpid(), total, chk);
}

int
main(void)
{
  56:	7139                	addi	sp,sp,-64
  58:	fc06                	sd	ra,56(sp)
  5a:	f822                	sd	s0,48(sp)
  5c:	f426                	sd	s1,40(sp)
  5e:	f04a                	sd	s2,32(sp)
  60:	ec4e                	sd	s3,24(sp)
  62:	e852                	sd	s4,16(sp)
  64:	0080                	addi	s0,sp,64
  printf("matrix: forking %d children (N=%d)\n", NCHILD, N);
  66:	4651                	li	a2,20
  68:	4595                	li	a1,5
  6a:	00001517          	auipc	a0,0x1
  6e:	a6650513          	addi	a0,a0,-1434 # ad0 <malloc+0x100>
  72:	0a7000ef          	jal	918 <printf>

  for(int i = 0; i < NCHILD; i++){
  76:	4a01                	li	s4,0
    }
    if(pid == 0){
      child_work(i + 1);
      exit(0);
    }
    printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
  78:	00001997          	auipc	s3,0x1
  7c:	ad898993          	addi	s3,s3,-1320 # b50 <malloc+0x180>
  for(int i = 0; i < NCHILD; i++){
  80:	4915                	li	s2,5
    int pid = fork();
  82:	440000ef          	jal	4c2 <fork>
  86:	84aa                	mv	s1,a0
    if(pid < 0){
  88:	02054d63          	bltz	a0,c2 <main+0x6c>
    if(pid == 0){
  8c:	c921                	beqz	a0,dc <main+0x86>
    printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
  8e:	001a059b          	addiw	a1,s4,1
  92:	8a2e                	mv	s4,a1
  94:	862a                	mv	a2,a0
  96:	854e                	mv	a0,s3
  98:	081000ef          	jal	918 <printf>
  for(int i = 0; i < NCHILD; i++){
  9c:	ff2a13e3          	bne	s4,s2,82 <main+0x2c>
  a0:	e456                	sd	s5,8(sp)
  a2:	e05a                	sd	s6,0(sp)
  a4:	4495                	li	s1,5
  }

  // Wait for all children
  for(int i = 0; i < NCHILD; i++)
    wait(0);
  a6:	4501                	li	a0,0
  a8:	42a000ef          	jal	4d2 <wait>
  for(int i = 0; i < NCHILD; i++)
  ac:	34fd                	addiw	s1,s1,-1
  ae:	fce5                	bnez	s1,a6 <main+0x50>

  printf("matrix: all children finished\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	ac850513          	addi	a0,a0,-1336 # b78 <malloc+0x1a8>
  b8:	061000ef          	jal	918 <printf>
  exit(0);
  bc:	4501                	li	a0,0
  be:	40c000ef          	jal	4ca <exit>
  c2:	e456                	sd	s5,8(sp)
  c4:	e05a                	sd	s6,0(sp)
      printf("matrix: fork failed for child %d\n", i + 1);
  c6:	001a059b          	addiw	a1,s4,1
  ca:	00001517          	auipc	a0,0x1
  ce:	a2e50513          	addi	a0,a0,-1490 # af8 <malloc+0x128>
  d2:	047000ef          	jal	918 <printf>
      exit(1);
  d6:	4505                	li	a0,1
  d8:	3f2000ef          	jal	4ca <exit>
  dc:	e456                	sd	s5,8(sp)
  de:	e05a                	sd	s6,0(sp)
      child_work(i + 1);
  e0:	001a099b          	addiw	s3,s4,1
  int total = ROUNDS + extra;
  e4:	4925                	li	s2,9
  e6:	4139093b          	subw	s2,s2,s3
  ea:	8b4a                	mv	s6,s2
  mat_init(A, child_id);
  ec:	85ce                	mv	a1,s3
  ee:	00002517          	auipc	a0,0x2
  f2:	f2250513          	addi	a0,a0,-222 # 2010 <A>
  f6:	f0bff0ef          	jal	0 <mat_init>
  mat_init(B, child_id + 37);
  fa:	026a059b          	addiw	a1,s4,38
  fe:	00002517          	auipc	a0,0x2
 102:	55250513          	addi	a0,a0,1362 # 2650 <B>
 106:	efbff0ef          	jal	0 <mat_init>
  for(int r = 0; r < total; r++){
 10a:	88a6                	mv	a7,s1
  int chk = 0;
 10c:	8e26                	mv	t3,s1
 10e:	00002317          	auipc	t1,0x2
 112:	54230313          	addi	t1,t1,1346 # 2650 <B>
 116:	00002597          	auipc	a1,0x2
 11a:	58a58593          	addi	a1,a1,1418 # 26a0 <B+0x50>
 11e:	00003817          	auipc	a6,0x3
 122:	20280813          	addi	a6,a6,514 # 3320 <base+0x50>
        A[i][j] = C[i][j] % 97;
 126:	151d0637          	lui	a2,0x151d0
 12a:	7eb60613          	addi	a2,a2,2027 # 151d07eb <base+0x151cd51b>
  for(int i = 0; i < N; i++)
 12e:	00002517          	auipc	a0,0x2
 132:	ee250513          	addi	a0,a0,-286 # 2010 <A>
      int sum = 0;
 136:	00003a97          	auipc	s5,0x3
 13a:	b5aa8a93          	addi	s5,s5,-1190 # 2c90 <C>
 13e:	8a2a                	mv	s4,a0
    for(int j = 0; j < N; j++){
 140:	00002697          	auipc	a3,0x2
 144:	51068693          	addi	a3,a3,1296 # 2650 <B>
      int sum = 0;
 148:	8fd6                	mv	t6,s5
  for(int i = 0; i < NCHILD; i++){
 14a:	8736                	mv	a4,a3
 14c:	8ed2                	mv	t4,s4
      int sum = 0;
 14e:	8f26                	mv	t5,s1
      for(int k = 0; k < N; k++)
 150:	64068393          	addi	t2,a3,1600
        sum += A[i][k] * B[k][j];
 154:	000ea283          	lw	t0,0(t4)
 158:	431c                	lw	a5,0(a4)
 15a:	025787bb          	mulw	a5,a5,t0
 15e:	01e787bb          	addw	a5,a5,t5
 162:	8f3e                	mv	t5,a5
      for(int k = 0; k < N; k++)
 164:	0e91                	addi	t4,t4,4
 166:	05070713          	addi	a4,a4,80
 16a:	fe7715e3          	bne	a4,t2,154 <main+0xfe>
      C[i][j] = sum;
 16e:	00ffa023          	sw	a5,0(t6)
    for(int j = 0; j < N; j++){
 172:	0f91                	addi	t6,t6,4
 174:	0691                	addi	a3,a3,4
 176:	fcb69ae3          	bne	a3,a1,14a <main+0xf4>
  for(int i = 0; i < N; i++)
 17a:	050a0a13          	addi	s4,s4,80
 17e:	050a8a93          	addi	s5,s5,80
 182:	fa6a1fe3          	bne	s4,t1,140 <main+0xea>
 186:	00003f17          	auipc	t5,0x3
 18a:	b5af0f13          	addi	t5,t5,-1190 # 2ce0 <C+0x50>
 18e:	86fa                	mv	a3,t5
  int s = 0;
 190:	8726                	mv	a4,s1
    for(int j = 0; j < N; j++)
 192:	fb068793          	addi	a5,a3,-80
      s += C[i][j];
 196:	0007aa03          	lw	s4,0(a5)
 19a:	00ea0a3b          	addw	s4,s4,a4
 19e:	8752                	mv	a4,s4
    for(int j = 0; j < N; j++)
 1a0:	0791                	addi	a5,a5,4
 1a2:	fed79ae3          	bne	a5,a3,196 <main+0x140>
  for(int i = 0; i < N; i++)
 1a6:	05068693          	addi	a3,a3,80
 1aa:	ff0694e3          	bne	a3,a6,192 <main+0x13c>
    chk += mat_checksum();
 1ae:	01ca0a3b          	addw	s4,s4,t3
 1b2:	8e52                	mv	t3,s4
      for(int j = 0; j < N; j++)
 1b4:	fb0f0e93          	addi	t4,t5,-80
  int s = 0;
 1b8:	8faa                	mv	t6,a0
        A[i][j] = C[i][j] % 97;
 1ba:	000ea683          	lw	a3,0(t4)
 1be:	02c68733          	mul	a4,a3,a2
 1c2:	970d                	srai	a4,a4,0x23
 1c4:	41f6d79b          	sraiw	a5,a3,0x1f
 1c8:	9f1d                	subw	a4,a4,a5
 1ca:	0017179b          	slliw	a5,a4,0x1
 1ce:	9fb9                	addw	a5,a5,a4
 1d0:	0057979b          	slliw	a5,a5,0x5
 1d4:	9fb9                	addw	a5,a5,a4
 1d6:	9e9d                	subw	a3,a3,a5
 1d8:	00dfa023          	sw	a3,0(t6)
      for(int j = 0; j < N; j++)
 1dc:	0e91                	addi	t4,t4,4
 1de:	0f91                	addi	t6,t6,4
 1e0:	fdee9de3          	bne	t4,t5,1ba <main+0x164>
    for(int i = 0; i < N; i++)
 1e4:	05050513          	addi	a0,a0,80
 1e8:	050f0f13          	addi	t5,t5,80
 1ec:	fd0f14e3          	bne	t5,a6,1b4 <main+0x15e>
  for(int r = 0; r < total; r++){
 1f0:	2885                	addiw	a7,a7,1
 1f2:	f31b1ee3          	bne	s6,a7,12e <main+0xd8>
  printf("  Child %d (PID %d): %d rounds, checksum %d\n",
 1f6:	354000ef          	jal	54a <getpid>
 1fa:	862a                	mv	a2,a0
 1fc:	8752                	mv	a4,s4
 1fe:	86ca                	mv	a3,s2
 200:	85ce                	mv	a1,s3
 202:	00001517          	auipc	a0,0x1
 206:	91e50513          	addi	a0,a0,-1762 # b20 <malloc+0x150>
 20a:	70e000ef          	jal	918 <printf>
      exit(0);
 20e:	4501                	li	a0,0
 210:	2ba000ef          	jal	4ca <exit>

0000000000000214 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 214:	1141                	addi	sp,sp,-16
 216:	e406                	sd	ra,8(sp)
 218:	e022                	sd	s0,0(sp)
 21a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 21c:	e3bff0ef          	jal	56 <main>
  exit(r);
 220:	2aa000ef          	jal	4ca <exit>

0000000000000224 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 224:	1141                	addi	sp,sp,-16
 226:	e406                	sd	ra,8(sp)
 228:	e022                	sd	s0,0(sp)
 22a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 22c:	87aa                	mv	a5,a0
 22e:	0585                	addi	a1,a1,1
 230:	0785                	addi	a5,a5,1
 232:	fff5c703          	lbu	a4,-1(a1)
 236:	fee78fa3          	sb	a4,-1(a5)
 23a:	fb75                	bnez	a4,22e <strcpy+0xa>
    ;
  return os;
}
 23c:	60a2                	ld	ra,8(sp)
 23e:	6402                	ld	s0,0(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret

0000000000000244 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 244:	1141                	addi	sp,sp,-16
 246:	e406                	sd	ra,8(sp)
 248:	e022                	sd	s0,0(sp)
 24a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 24c:	00054783          	lbu	a5,0(a0)
 250:	cb91                	beqz	a5,264 <strcmp+0x20>
 252:	0005c703          	lbu	a4,0(a1)
 256:	00f71763          	bne	a4,a5,264 <strcmp+0x20>
    p++, q++;
 25a:	0505                	addi	a0,a0,1
 25c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 25e:	00054783          	lbu	a5,0(a0)
 262:	fbe5                	bnez	a5,252 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 264:	0005c503          	lbu	a0,0(a1)
}
 268:	40a7853b          	subw	a0,a5,a0
 26c:	60a2                	ld	ra,8(sp)
 26e:	6402                	ld	s0,0(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strlen>:

uint
strlen(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e406                	sd	ra,8(sp)
 278:	e022                	sd	s0,0(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 27c:	00054783          	lbu	a5,0(a0)
 280:	cf91                	beqz	a5,29c <strlen+0x28>
 282:	00150793          	addi	a5,a0,1
 286:	86be                	mv	a3,a5
 288:	0785                	addi	a5,a5,1
 28a:	fff7c703          	lbu	a4,-1(a5)
 28e:	ff65                	bnez	a4,286 <strlen+0x12>
 290:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  for(n = 0; s[n]; n++)
 29c:	4501                	li	a0,0
 29e:	bfdd                	j	294 <strlen+0x20>

00000000000002a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a8:	ca19                	beqz	a2,2be <memset+0x1e>
 2aa:	87aa                	mv	a5,a0
 2ac:	1602                	slli	a2,a2,0x20
 2ae:	9201                	srli	a2,a2,0x20
 2b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b8:	0785                	addi	a5,a5,1
 2ba:	fee79de3          	bne	a5,a4,2b4 <memset+0x14>
  }
  return dst;
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <strchr>:

char*
strchr(const char *s, char c)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	cf81                	beqz	a5,2ea <strchr+0x24>
    if(*s == c)
 2d4:	00f58763          	beq	a1,a5,2e2 <strchr+0x1c>
  for(; *s; s++)
 2d8:	0505                	addi	a0,a0,1
 2da:	00054783          	lbu	a5,0(a0)
 2de:	fbfd                	bnez	a5,2d4 <strchr+0xe>
      return (char*)s;
  return 0;
 2e0:	4501                	li	a0,0
}
 2e2:	60a2                	ld	ra,8(sp)
 2e4:	6402                	ld	s0,0(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	bfdd                	j	2e2 <strchr+0x1c>

00000000000002ee <gets>:

char*
gets(char *buf, int max)
{
 2ee:	711d                	addi	sp,sp,-96
 2f0:	ec86                	sd	ra,88(sp)
 2f2:	e8a2                	sd	s0,80(sp)
 2f4:	e4a6                	sd	s1,72(sp)
 2f6:	e0ca                	sd	s2,64(sp)
 2f8:	fc4e                	sd	s3,56(sp)
 2fa:	f852                	sd	s4,48(sp)
 2fc:	f456                	sd	s5,40(sp)
 2fe:	f05a                	sd	s6,32(sp)
 300:	ec5e                	sd	s7,24(sp)
 302:	e862                	sd	s8,16(sp)
 304:	1080                	addi	s0,sp,96
 306:	8baa                	mv	s7,a0
 308:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 30a:	892a                	mv	s2,a0
 30c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 30e:	faf40b13          	addi	s6,s0,-81
 312:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 314:	8c26                	mv	s8,s1
 316:	0014899b          	addiw	s3,s1,1
 31a:	84ce                	mv	s1,s3
 31c:	0349d463          	bge	s3,s4,344 <gets+0x56>
    cc = read(0, &c, 1);
 320:	8656                	mv	a2,s5
 322:	85da                	mv	a1,s6
 324:	4501                	li	a0,0
 326:	1bc000ef          	jal	4e2 <read>
    if(cc < 1)
 32a:	00a05d63          	blez	a0,344 <gets+0x56>
      break;
    buf[i++] = c;
 32e:	faf44783          	lbu	a5,-81(s0)
 332:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 336:	0905                	addi	s2,s2,1
 338:	ff678713          	addi	a4,a5,-10
 33c:	c319                	beqz	a4,342 <gets+0x54>
 33e:	17cd                	addi	a5,a5,-13
 340:	fbf1                	bnez	a5,314 <gets+0x26>
    buf[i++] = c;
 342:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 344:	9c5e                	add	s8,s8,s7
 346:	000c0023          	sb	zero,0(s8)
  return buf;
}
 34a:	855e                	mv	a0,s7
 34c:	60e6                	ld	ra,88(sp)
 34e:	6446                	ld	s0,80(sp)
 350:	64a6                	ld	s1,72(sp)
 352:	6906                	ld	s2,64(sp)
 354:	79e2                	ld	s3,56(sp)
 356:	7a42                	ld	s4,48(sp)
 358:	7aa2                	ld	s5,40(sp)
 35a:	7b02                	ld	s6,32(sp)
 35c:	6be2                	ld	s7,24(sp)
 35e:	6c42                	ld	s8,16(sp)
 360:	6125                	addi	sp,sp,96
 362:	8082                	ret

0000000000000364 <stat>:

int
stat(const char *n, struct stat *st)
{
 364:	1101                	addi	sp,sp,-32
 366:	ec06                	sd	ra,24(sp)
 368:	e822                	sd	s0,16(sp)
 36a:	e04a                	sd	s2,0(sp)
 36c:	1000                	addi	s0,sp,32
 36e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 370:	4581                	li	a1,0
 372:	198000ef          	jal	50a <open>
  if(fd < 0)
 376:	02054263          	bltz	a0,39a <stat+0x36>
 37a:	e426                	sd	s1,8(sp)
 37c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 37e:	85ca                	mv	a1,s2
 380:	1a2000ef          	jal	522 <fstat>
 384:	892a                	mv	s2,a0
  close(fd);
 386:	8526                	mv	a0,s1
 388:	16a000ef          	jal	4f2 <close>
  return r;
 38c:	64a2                	ld	s1,8(sp)
}
 38e:	854a                	mv	a0,s2
 390:	60e2                	ld	ra,24(sp)
 392:	6442                	ld	s0,16(sp)
 394:	6902                	ld	s2,0(sp)
 396:	6105                	addi	sp,sp,32
 398:	8082                	ret
    return -1;
 39a:	57fd                	li	a5,-1
 39c:	893e                	mv	s2,a5
 39e:	bfc5                	j	38e <stat+0x2a>

00000000000003a0 <atoi>:

int
atoi(const char *s)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3a8:	00054683          	lbu	a3,0(a0)
 3ac:	fd06879b          	addiw	a5,a3,-48
 3b0:	0ff7f793          	zext.b	a5,a5
 3b4:	4625                	li	a2,9
 3b6:	02f66963          	bltu	a2,a5,3e8 <atoi+0x48>
 3ba:	872a                	mv	a4,a0
  n = 0;
 3bc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3be:	0705                	addi	a4,a4,1
 3c0:	0025179b          	slliw	a5,a0,0x2
 3c4:	9fa9                	addw	a5,a5,a0
 3c6:	0017979b          	slliw	a5,a5,0x1
 3ca:	9fb5                	addw	a5,a5,a3
 3cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3d0:	00074683          	lbu	a3,0(a4)
 3d4:	fd06879b          	addiw	a5,a3,-48
 3d8:	0ff7f793          	zext.b	a5,a5
 3dc:	fef671e3          	bgeu	a2,a5,3be <atoi+0x1e>
  return n;
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
  n = 0;
 3e8:	4501                	li	a0,0
 3ea:	bfdd                	j	3e0 <atoi+0x40>

00000000000003ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e406                	sd	ra,8(sp)
 3f0:	e022                	sd	s0,0(sp)
 3f2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3f4:	02b57563          	bgeu	a0,a1,41e <memmove+0x32>
    while(n-- > 0)
 3f8:	00c05f63          	blez	a2,416 <memmove+0x2a>
 3fc:	1602                	slli	a2,a2,0x20
 3fe:	9201                	srli	a2,a2,0x20
 400:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 404:	872a                	mv	a4,a0
      *dst++ = *src++;
 406:	0585                	addi	a1,a1,1
 408:	0705                	addi	a4,a4,1
 40a:	fff5c683          	lbu	a3,-1(a1)
 40e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 412:	fee79ae3          	bne	a5,a4,406 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret
    while(n-- > 0)
 41e:	fec05ce3          	blez	a2,416 <memmove+0x2a>
    dst += n;
 422:	00c50733          	add	a4,a0,a2
    src += n;
 426:	95b2                	add	a1,a1,a2
 428:	fff6079b          	addiw	a5,a2,-1
 42c:	1782                	slli	a5,a5,0x20
 42e:	9381                	srli	a5,a5,0x20
 430:	fff7c793          	not	a5,a5
 434:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 436:	15fd                	addi	a1,a1,-1
 438:	177d                	addi	a4,a4,-1
 43a:	0005c683          	lbu	a3,0(a1)
 43e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 442:	fef71ae3          	bne	a4,a5,436 <memmove+0x4a>
 446:	bfc1                	j	416 <memmove+0x2a>

0000000000000448 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e406                	sd	ra,8(sp)
 44c:	e022                	sd	s0,0(sp)
 44e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 450:	c61d                	beqz	a2,47e <memcmp+0x36>
 452:	1602                	slli	a2,a2,0x20
 454:	9201                	srli	a2,a2,0x20
 456:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 45a:	00054783          	lbu	a5,0(a0)
 45e:	0005c703          	lbu	a4,0(a1)
 462:	00e79863          	bne	a5,a4,472 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 466:	0505                	addi	a0,a0,1
    p2++;
 468:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 46a:	fed518e3          	bne	a0,a3,45a <memcmp+0x12>
  }
  return 0;
 46e:	4501                	li	a0,0
 470:	a019                	j	476 <memcmp+0x2e>
      return *p1 - *p2;
 472:	40e7853b          	subw	a0,a5,a4
}
 476:	60a2                	ld	ra,8(sp)
 478:	6402                	ld	s0,0(sp)
 47a:	0141                	addi	sp,sp,16
 47c:	8082                	ret
  return 0;
 47e:	4501                	li	a0,0
 480:	bfdd                	j	476 <memcmp+0x2e>

0000000000000482 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 482:	1141                	addi	sp,sp,-16
 484:	e406                	sd	ra,8(sp)
 486:	e022                	sd	s0,0(sp)
 488:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 48a:	f63ff0ef          	jal	3ec <memmove>
}
 48e:	60a2                	ld	ra,8(sp)
 490:	6402                	ld	s0,0(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret

0000000000000496 <sbrk>:

char *
sbrk(int n) {
 496:	1141                	addi	sp,sp,-16
 498:	e406                	sd	ra,8(sp)
 49a:	e022                	sd	s0,0(sp)
 49c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 49e:	4585                	li	a1,1
 4a0:	0b2000ef          	jal	552 <sys_sbrk>
}
 4a4:	60a2                	ld	ra,8(sp)
 4a6:	6402                	ld	s0,0(sp)
 4a8:	0141                	addi	sp,sp,16
 4aa:	8082                	ret

00000000000004ac <sbrklazy>:

char *
sbrklazy(int n) {
 4ac:	1141                	addi	sp,sp,-16
 4ae:	e406                	sd	ra,8(sp)
 4b0:	e022                	sd	s0,0(sp)
 4b2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4b4:	4589                	li	a1,2
 4b6:	09c000ef          	jal	552 <sys_sbrk>
}
 4ba:	60a2                	ld	ra,8(sp)
 4bc:	6402                	ld	s0,0(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret

00000000000004c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c2:	4885                	li	a7,1
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ca:	4889                	li	a7,2
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d2:	488d                	li	a7,3
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4da:	4891                	li	a7,4
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <read>:
.global read
read:
 li a7, SYS_read
 4e2:	4895                	li	a7,5
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <write>:
.global write
write:
 li a7, SYS_write
 4ea:	48c1                	li	a7,16
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <close>:
.global close
close:
 li a7, SYS_close
 4f2:	48d5                	li	a7,21
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 4fa:	4899                	li	a7,6
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <exec>:
.global exec
exec:
 li a7, SYS_exec
 502:	489d                	li	a7,7
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <open>:
.global open
open:
 li a7, SYS_open
 50a:	48bd                	li	a7,15
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 512:	48c5                	li	a7,17
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 51a:	48c9                	li	a7,18
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 522:	48a1                	li	a7,8
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <link>:
.global link
link:
 li a7, SYS_link
 52a:	48cd                	li	a7,19
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 532:	48d1                	li	a7,20
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 53a:	48a5                	li	a7,9
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <dup>:
.global dup
dup:
 li a7, SYS_dup
 542:	48a9                	li	a7,10
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 54a:	48ad                	li	a7,11
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 552:	48b1                	li	a7,12
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <pause>:
.global pause
pause:
 li a7, SYS_pause
 55a:	48b5                	li	a7,13
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 562:	48b9                	li	a7,14
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <kps>:
.global kps
kps:
 li a7, SYS_kps
 56a:	48d9                	li	a7,22
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 572:	1101                	addi	sp,sp,-32
 574:	ec06                	sd	ra,24(sp)
 576:	e822                	sd	s0,16(sp)
 578:	1000                	addi	s0,sp,32
 57a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 57e:	4605                	li	a2,1
 580:	fef40593          	addi	a1,s0,-17
 584:	f67ff0ef          	jal	4ea <write>
}
 588:	60e2                	ld	ra,24(sp)
 58a:	6442                	ld	s0,16(sp)
 58c:	6105                	addi	sp,sp,32
 58e:	8082                	ret

0000000000000590 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 590:	715d                	addi	sp,sp,-80
 592:	e486                	sd	ra,72(sp)
 594:	e0a2                	sd	s0,64(sp)
 596:	f84a                	sd	s2,48(sp)
 598:	f44e                	sd	s3,40(sp)
 59a:	0880                	addi	s0,sp,80
 59c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 59e:	c6d1                	beqz	a3,62a <printint+0x9a>
 5a0:	0805d563          	bgez	a1,62a <printint+0x9a>
    neg = 1;
    x = -xx;
 5a4:	40b005b3          	neg	a1,a1
    neg = 1;
 5a8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5aa:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5ae:	86ce                	mv	a3,s3
  i = 0;
 5b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5b2:	00000817          	auipc	a6,0x0
 5b6:	5ee80813          	addi	a6,a6,1518 # ba0 <digits>
 5ba:	88ba                	mv	a7,a4
 5bc:	0017051b          	addiw	a0,a4,1
 5c0:	872a                	mv	a4,a0
 5c2:	02c5f7b3          	remu	a5,a1,a2
 5c6:	97c2                	add	a5,a5,a6
 5c8:	0007c783          	lbu	a5,0(a5)
 5cc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5d0:	87ae                	mv	a5,a1
 5d2:	02c5d5b3          	divu	a1,a1,a2
 5d6:	0685                	addi	a3,a3,1
 5d8:	fec7f1e3          	bgeu	a5,a2,5ba <printint+0x2a>
  if(neg)
 5dc:	00030c63          	beqz	t1,5f4 <printint+0x64>
    buf[i++] = '-';
 5e0:	fd050793          	addi	a5,a0,-48
 5e4:	00878533          	add	a0,a5,s0
 5e8:	02d00793          	li	a5,45
 5ec:	fef50423          	sb	a5,-24(a0)
 5f0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5f4:	02e05563          	blez	a4,61e <printint+0x8e>
 5f8:	fc26                	sd	s1,56(sp)
 5fa:	377d                	addiw	a4,a4,-1
 5fc:	00e984b3          	add	s1,s3,a4
 600:	19fd                	addi	s3,s3,-1
 602:	99ba                	add	s3,s3,a4
 604:	1702                	slli	a4,a4,0x20
 606:	9301                	srli	a4,a4,0x20
 608:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 60c:	0004c583          	lbu	a1,0(s1)
 610:	854a                	mv	a0,s2
 612:	f61ff0ef          	jal	572 <putc>
  while(--i >= 0)
 616:	14fd                	addi	s1,s1,-1
 618:	ff349ae3          	bne	s1,s3,60c <printint+0x7c>
 61c:	74e2                	ld	s1,56(sp)
}
 61e:	60a6                	ld	ra,72(sp)
 620:	6406                	ld	s0,64(sp)
 622:	7942                	ld	s2,48(sp)
 624:	79a2                	ld	s3,40(sp)
 626:	6161                	addi	sp,sp,80
 628:	8082                	ret
  neg = 0;
 62a:	4301                	li	t1,0
 62c:	bfbd                	j	5aa <printint+0x1a>

000000000000062e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 62e:	711d                	addi	sp,sp,-96
 630:	ec86                	sd	ra,88(sp)
 632:	e8a2                	sd	s0,80(sp)
 634:	e4a6                	sd	s1,72(sp)
 636:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 638:	0005c483          	lbu	s1,0(a1)
 63c:	22048363          	beqz	s1,862 <vprintf+0x234>
 640:	e0ca                	sd	s2,64(sp)
 642:	fc4e                	sd	s3,56(sp)
 644:	f852                	sd	s4,48(sp)
 646:	f456                	sd	s5,40(sp)
 648:	f05a                	sd	s6,32(sp)
 64a:	ec5e                	sd	s7,24(sp)
 64c:	e862                	sd	s8,16(sp)
 64e:	8b2a                	mv	s6,a0
 650:	8a2e                	mv	s4,a1
 652:	8bb2                	mv	s7,a2
  state = 0;
 654:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 656:	4901                	li	s2,0
 658:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 65a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 65e:	06400c13          	li	s8,100
 662:	a00d                	j	684 <vprintf+0x56>
        putc(fd, c0);
 664:	85a6                	mv	a1,s1
 666:	855a                	mv	a0,s6
 668:	f0bff0ef          	jal	572 <putc>
 66c:	a019                	j	672 <vprintf+0x44>
    } else if(state == '%'){
 66e:	03598363          	beq	s3,s5,694 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 672:	0019079b          	addiw	a5,s2,1
 676:	893e                	mv	s2,a5
 678:	873e                	mv	a4,a5
 67a:	97d2                	add	a5,a5,s4
 67c:	0007c483          	lbu	s1,0(a5)
 680:	1c048a63          	beqz	s1,854 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 684:	0004879b          	sext.w	a5,s1
    if(state == 0){
 688:	fe0993e3          	bnez	s3,66e <vprintf+0x40>
      if(c0 == '%'){
 68c:	fd579ce3          	bne	a5,s5,664 <vprintf+0x36>
        state = '%';
 690:	89be                	mv	s3,a5
 692:	b7c5                	j	672 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 694:	00ea06b3          	add	a3,s4,a4
 698:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 69c:	1c060863          	beqz	a2,86c <vprintf+0x23e>
      if(c0 == 'd'){
 6a0:	03878763          	beq	a5,s8,6ce <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6a4:	f9478693          	addi	a3,a5,-108
 6a8:	0016b693          	seqz	a3,a3
 6ac:	f9c60593          	addi	a1,a2,-100
 6b0:	e99d                	bnez	a1,6e6 <vprintf+0xb8>
 6b2:	ca95                	beqz	a3,6e6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	008b8493          	addi	s1,s7,8
 6b8:	4685                	li	a3,1
 6ba:	4629                	li	a2,10
 6bc:	000bb583          	ld	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	ecfff0ef          	jal	590 <printint>
        i += 1;
 6c6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c8:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b75d                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6ce:	008b8493          	addi	s1,s7,8
 6d2:	4685                	li	a3,1
 6d4:	4629                	li	a2,10
 6d6:	000ba583          	lw	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	eb5ff0ef          	jal	590 <printint>
 6e0:	8ba6                	mv	s7,s1
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b779                	j	672 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 6e6:	9752                	add	a4,a4,s4
 6e8:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ec:	f9460713          	addi	a4,a2,-108
 6f0:	00173713          	seqz	a4,a4
 6f4:	8f75                	and	a4,a4,a3
 6f6:	f9c58513          	addi	a0,a1,-100
 6fa:	18051363          	bnez	a0,880 <vprintf+0x252>
 6fe:	18070163          	beqz	a4,880 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 702:	008b8493          	addi	s1,s7,8
 706:	4685                	li	a3,1
 708:	4629                	li	a2,10
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	e81ff0ef          	jal	590 <printint>
        i += 2;
 714:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 716:	8ba6                	mv	s7,s1
      state = 0;
 718:	4981                	li	s3,0
        i += 2;
 71a:	bfa1                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 71c:	008b8493          	addi	s1,s7,8
 720:	4681                	li	a3,0
 722:	4629                	li	a2,10
 724:	000be583          	lwu	a1,0(s7)
 728:	855a                	mv	a0,s6
 72a:	e67ff0ef          	jal	590 <printint>
 72e:	8ba6                	mv	s7,s1
      state = 0;
 730:	4981                	li	s3,0
 732:	b781                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 734:	008b8493          	addi	s1,s7,8
 738:	4681                	li	a3,0
 73a:	4629                	li	a2,10
 73c:	000bb583          	ld	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	e4fff0ef          	jal	590 <printint>
        i += 1;
 746:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 748:	8ba6                	mv	s7,s1
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b71d                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 74e:	008b8493          	addi	s1,s7,8
 752:	4681                	li	a3,0
 754:	4629                	li	a2,10
 756:	000bb583          	ld	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	e35ff0ef          	jal	590 <printint>
        i += 2;
 760:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 762:	8ba6                	mv	s7,s1
      state = 0;
 764:	4981                	li	s3,0
        i += 2;
 766:	b731                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 768:	008b8493          	addi	s1,s7,8
 76c:	4681                	li	a3,0
 76e:	4641                	li	a2,16
 770:	000be583          	lwu	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	e1bff0ef          	jal	590 <printint>
 77a:	8ba6                	mv	s7,s1
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bdd5                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 780:	008b8493          	addi	s1,s7,8
 784:	4681                	li	a3,0
 786:	4641                	li	a2,16
 788:	000bb583          	ld	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	e03ff0ef          	jal	590 <printint>
        i += 1;
 792:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 794:	8ba6                	mv	s7,s1
      state = 0;
 796:	4981                	li	s3,0
 798:	bde9                	j	672 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 79a:	008b8493          	addi	s1,s7,8
 79e:	4681                	li	a3,0
 7a0:	4641                	li	a2,16
 7a2:	000bb583          	ld	a1,0(s7)
 7a6:	855a                	mv	a0,s6
 7a8:	de9ff0ef          	jal	590 <printint>
        i += 2;
 7ac:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ae:	8ba6                	mv	s7,s1
      state = 0;
 7b0:	4981                	li	s3,0
        i += 2;
 7b2:	b5c1                	j	672 <vprintf+0x44>
 7b4:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7b6:	008b8793          	addi	a5,s7,8
 7ba:	8cbe                	mv	s9,a5
 7bc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c0:	03000593          	li	a1,48
 7c4:	855a                	mv	a0,s6
 7c6:	dadff0ef          	jal	572 <putc>
  putc(fd, 'x');
 7ca:	07800593          	li	a1,120
 7ce:	855a                	mv	a0,s6
 7d0:	da3ff0ef          	jal	572 <putc>
 7d4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d6:	00000b97          	auipc	s7,0x0
 7da:	3cab8b93          	addi	s7,s7,970 # ba0 <digits>
 7de:	03c9d793          	srli	a5,s3,0x3c
 7e2:	97de                	add	a5,a5,s7
 7e4:	0007c583          	lbu	a1,0(a5)
 7e8:	855a                	mv	a0,s6
 7ea:	d89ff0ef          	jal	572 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ee:	0992                	slli	s3,s3,0x4
 7f0:	34fd                	addiw	s1,s1,-1
 7f2:	f4f5                	bnez	s1,7de <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7f4:	8be6                	mv	s7,s9
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	6ca2                	ld	s9,8(sp)
 7fa:	bda5                	j	672 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7fc:	008b8493          	addi	s1,s7,8
 800:	000bc583          	lbu	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	d6dff0ef          	jal	572 <putc>
 80a:	8ba6                	mv	s7,s1
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b595                	j	672 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 810:	008b8993          	addi	s3,s7,8
 814:	000bb483          	ld	s1,0(s7)
 818:	cc91                	beqz	s1,834 <vprintf+0x206>
        for(; *s; s++)
 81a:	0004c583          	lbu	a1,0(s1)
 81e:	c985                	beqz	a1,84e <vprintf+0x220>
          putc(fd, *s);
 820:	855a                	mv	a0,s6
 822:	d51ff0ef          	jal	572 <putc>
        for(; *s; s++)
 826:	0485                	addi	s1,s1,1
 828:	0004c583          	lbu	a1,0(s1)
 82c:	f9f5                	bnez	a1,820 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 82e:	8bce                	mv	s7,s3
      state = 0;
 830:	4981                	li	s3,0
 832:	b581                	j	672 <vprintf+0x44>
          s = "(null)";
 834:	00000497          	auipc	s1,0x0
 838:	36448493          	addi	s1,s1,868 # b98 <malloc+0x1c8>
        for(; *s; s++)
 83c:	02800593          	li	a1,40
 840:	b7c5                	j	820 <vprintf+0x1f2>
        putc(fd, '%');
 842:	85be                	mv	a1,a5
 844:	855a                	mv	a0,s6
 846:	d2dff0ef          	jal	572 <putc>
      state = 0;
 84a:	4981                	li	s3,0
 84c:	b51d                	j	672 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 84e:	8bce                	mv	s7,s3
      state = 0;
 850:	4981                	li	s3,0
 852:	b505                	j	672 <vprintf+0x44>
 854:	6906                	ld	s2,64(sp)
 856:	79e2                	ld	s3,56(sp)
 858:	7a42                	ld	s4,48(sp)
 85a:	7aa2                	ld	s5,40(sp)
 85c:	7b02                	ld	s6,32(sp)
 85e:	6be2                	ld	s7,24(sp)
 860:	6c42                	ld	s8,16(sp)
    }
  }
}
 862:	60e6                	ld	ra,88(sp)
 864:	6446                	ld	s0,80(sp)
 866:	64a6                	ld	s1,72(sp)
 868:	6125                	addi	sp,sp,96
 86a:	8082                	ret
      if(c0 == 'd'){
 86c:	06400713          	li	a4,100
 870:	e4e78fe3          	beq	a5,a4,6ce <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 874:	f9478693          	addi	a3,a5,-108
 878:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 87c:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 87e:	4701                	li	a4,0
      } else if(c0 == 'u'){
 880:	07500513          	li	a0,117
 884:	e8a78ce3          	beq	a5,a0,71c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 888:	f8b60513          	addi	a0,a2,-117
 88c:	e119                	bnez	a0,892 <vprintf+0x264>
 88e:	ea0693e3          	bnez	a3,734 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 892:	f8b58513          	addi	a0,a1,-117
 896:	e119                	bnez	a0,89c <vprintf+0x26e>
 898:	ea071be3          	bnez	a4,74e <vprintf+0x120>
      } else if(c0 == 'x'){
 89c:	07800513          	li	a0,120
 8a0:	eca784e3          	beq	a5,a0,768 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8a4:	f8860613          	addi	a2,a2,-120
 8a8:	e219                	bnez	a2,8ae <vprintf+0x280>
 8aa:	ec069be3          	bnez	a3,780 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8ae:	f8858593          	addi	a1,a1,-120
 8b2:	e199                	bnez	a1,8b8 <vprintf+0x28a>
 8b4:	ee0713e3          	bnez	a4,79a <vprintf+0x16c>
      } else if(c0 == 'p'){
 8b8:	07000713          	li	a4,112
 8bc:	eee78ce3          	beq	a5,a4,7b4 <vprintf+0x186>
      } else if(c0 == 'c'){
 8c0:	06300713          	li	a4,99
 8c4:	f2e78ce3          	beq	a5,a4,7fc <vprintf+0x1ce>
      } else if(c0 == 's'){
 8c8:	07300713          	li	a4,115
 8cc:	f4e782e3          	beq	a5,a4,810 <vprintf+0x1e2>
      } else if(c0 == '%'){
 8d0:	02500713          	li	a4,37
 8d4:	f6e787e3          	beq	a5,a4,842 <vprintf+0x214>
        putc(fd, '%');
 8d8:	02500593          	li	a1,37
 8dc:	855a                	mv	a0,s6
 8de:	c95ff0ef          	jal	572 <putc>
        putc(fd, c0);
 8e2:	85a6                	mv	a1,s1
 8e4:	855a                	mv	a0,s6
 8e6:	c8dff0ef          	jal	572 <putc>
      state = 0;
 8ea:	4981                	li	s3,0
 8ec:	b359                	j	672 <vprintf+0x44>

00000000000008ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ee:	715d                	addi	sp,sp,-80
 8f0:	ec06                	sd	ra,24(sp)
 8f2:	e822                	sd	s0,16(sp)
 8f4:	1000                	addi	s0,sp,32
 8f6:	e010                	sd	a2,0(s0)
 8f8:	e414                	sd	a3,8(s0)
 8fa:	e818                	sd	a4,16(s0)
 8fc:	ec1c                	sd	a5,24(s0)
 8fe:	03043023          	sd	a6,32(s0)
 902:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 906:	8622                	mv	a2,s0
 908:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 90c:	d23ff0ef          	jal	62e <vprintf>
}
 910:	60e2                	ld	ra,24(sp)
 912:	6442                	ld	s0,16(sp)
 914:	6161                	addi	sp,sp,80
 916:	8082                	ret

0000000000000918 <printf>:

void
printf(const char *fmt, ...)
{
 918:	711d                	addi	sp,sp,-96
 91a:	ec06                	sd	ra,24(sp)
 91c:	e822                	sd	s0,16(sp)
 91e:	1000                	addi	s0,sp,32
 920:	e40c                	sd	a1,8(s0)
 922:	e810                	sd	a2,16(s0)
 924:	ec14                	sd	a3,24(s0)
 926:	f018                	sd	a4,32(s0)
 928:	f41c                	sd	a5,40(s0)
 92a:	03043823          	sd	a6,48(s0)
 92e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 932:	00840613          	addi	a2,s0,8
 936:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 93a:	85aa                	mv	a1,a0
 93c:	4505                	li	a0,1
 93e:	cf1ff0ef          	jal	62e <vprintf>
}
 942:	60e2                	ld	ra,24(sp)
 944:	6442                	ld	s0,16(sp)
 946:	6125                	addi	sp,sp,96
 948:	8082                	ret

000000000000094a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 94a:	1141                	addi	sp,sp,-16
 94c:	e406                	sd	ra,8(sp)
 94e:	e022                	sd	s0,0(sp)
 950:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 952:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 956:	00001797          	auipc	a5,0x1
 95a:	6aa7b783          	ld	a5,1706(a5) # 2000 <freep>
 95e:	a039                	j	96c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 960:	6398                	ld	a4,0(a5)
 962:	00e7e463          	bltu	a5,a4,96a <free+0x20>
 966:	00e6ea63          	bltu	a3,a4,97a <free+0x30>
{
 96a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 96c:	fed7fae3          	bgeu	a5,a3,960 <free+0x16>
 970:	6398                	ld	a4,0(a5)
 972:	00e6e463          	bltu	a3,a4,97a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 976:	fee7eae3          	bltu	a5,a4,96a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 97a:	ff852583          	lw	a1,-8(a0)
 97e:	6390                	ld	a2,0(a5)
 980:	02059813          	slli	a6,a1,0x20
 984:	01c85713          	srli	a4,a6,0x1c
 988:	9736                	add	a4,a4,a3
 98a:	02e60563          	beq	a2,a4,9b4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 98e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 992:	4790                	lw	a2,8(a5)
 994:	02061593          	slli	a1,a2,0x20
 998:	01c5d713          	srli	a4,a1,0x1c
 99c:	973e                	add	a4,a4,a5
 99e:	02e68263          	beq	a3,a4,9c2 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9a2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9a4:	00001717          	auipc	a4,0x1
 9a8:	64f73e23          	sd	a5,1628(a4) # 2000 <freep>
}
 9ac:	60a2                	ld	ra,8(sp)
 9ae:	6402                	ld	s0,0(sp)
 9b0:	0141                	addi	sp,sp,16
 9b2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9b4:	4618                	lw	a4,8(a2)
 9b6:	9f2d                	addw	a4,a4,a1
 9b8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9bc:	6398                	ld	a4,0(a5)
 9be:	6310                	ld	a2,0(a4)
 9c0:	b7f9                	j	98e <free+0x44>
    p->s.size += bp->s.size;
 9c2:	ff852703          	lw	a4,-8(a0)
 9c6:	9f31                	addw	a4,a4,a2
 9c8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9ca:	ff053683          	ld	a3,-16(a0)
 9ce:	bfd1                	j	9a2 <free+0x58>

00000000000009d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9d0:	7139                	addi	sp,sp,-64
 9d2:	fc06                	sd	ra,56(sp)
 9d4:	f822                	sd	s0,48(sp)
 9d6:	f04a                	sd	s2,32(sp)
 9d8:	ec4e                	sd	s3,24(sp)
 9da:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9dc:	02051993          	slli	s3,a0,0x20
 9e0:	0209d993          	srli	s3,s3,0x20
 9e4:	09bd                	addi	s3,s3,15
 9e6:	0049d993          	srli	s3,s3,0x4
 9ea:	2985                	addiw	s3,s3,1
 9ec:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9ee:	00001517          	auipc	a0,0x1
 9f2:	61253503          	ld	a0,1554(a0) # 2000 <freep>
 9f6:	c905                	beqz	a0,a26 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9fa:	4798                	lw	a4,8(a5)
 9fc:	09377663          	bgeu	a4,s3,a88 <malloc+0xb8>
 a00:	f426                	sd	s1,40(sp)
 a02:	e852                	sd	s4,16(sp)
 a04:	e456                	sd	s5,8(sp)
 a06:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a08:	8a4e                	mv	s4,s3
 a0a:	6705                	lui	a4,0x1
 a0c:	00e9f363          	bgeu	s3,a4,a12 <malloc+0x42>
 a10:	6a05                	lui	s4,0x1
 a12:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a16:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a1a:	00001497          	auipc	s1,0x1
 a1e:	5e648493          	addi	s1,s1,1510 # 2000 <freep>
  if(p == SBRK_ERROR)
 a22:	5afd                	li	s5,-1
 a24:	a83d                	j	a62 <malloc+0x92>
 a26:	f426                	sd	s1,40(sp)
 a28:	e852                	sd	s4,16(sp)
 a2a:	e456                	sd	s5,8(sp)
 a2c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a2e:	00003797          	auipc	a5,0x3
 a32:	8a278793          	addi	a5,a5,-1886 # 32d0 <base>
 a36:	00001717          	auipc	a4,0x1
 a3a:	5cf73523          	sd	a5,1482(a4) # 2000 <freep>
 a3e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a40:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a44:	b7d1                	j	a08 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a46:	6398                	ld	a4,0(a5)
 a48:	e118                	sd	a4,0(a0)
 a4a:	a899                	j	aa0 <malloc+0xd0>
  hp->s.size = nu;
 a4c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a50:	0541                	addi	a0,a0,16
 a52:	ef9ff0ef          	jal	94a <free>
  return freep;
 a56:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a58:	c125                	beqz	a0,ab8 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a5c:	4798                	lw	a4,8(a5)
 a5e:	03277163          	bgeu	a4,s2,a80 <malloc+0xb0>
    if(p == freep)
 a62:	6098                	ld	a4,0(s1)
 a64:	853e                	mv	a0,a5
 a66:	fef71ae3          	bne	a4,a5,a5a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a6a:	8552                	mv	a0,s4
 a6c:	a2bff0ef          	jal	496 <sbrk>
  if(p == SBRK_ERROR)
 a70:	fd551ee3          	bne	a0,s5,a4c <malloc+0x7c>
        return 0;
 a74:	4501                	li	a0,0
 a76:	74a2                	ld	s1,40(sp)
 a78:	6a42                	ld	s4,16(sp)
 a7a:	6aa2                	ld	s5,8(sp)
 a7c:	6b02                	ld	s6,0(sp)
 a7e:	a03d                	j	aac <malloc+0xdc>
 a80:	74a2                	ld	s1,40(sp)
 a82:	6a42                	ld	s4,16(sp)
 a84:	6aa2                	ld	s5,8(sp)
 a86:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a88:	fae90fe3          	beq	s2,a4,a46 <malloc+0x76>
        p->s.size -= nunits;
 a8c:	4137073b          	subw	a4,a4,s3
 a90:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a92:	02071693          	slli	a3,a4,0x20
 a96:	01c6d713          	srli	a4,a3,0x1c
 a9a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a9c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa0:	00001717          	auipc	a4,0x1
 aa4:	56a73023          	sd	a0,1376(a4) # 2000 <freep>
      return (void*)(p + 1);
 aa8:	01078513          	addi	a0,a5,16
  }
}
 aac:	70e2                	ld	ra,56(sp)
 aae:	7442                	ld	s0,48(sp)
 ab0:	7902                	ld	s2,32(sp)
 ab2:	69e2                	ld	s3,24(sp)
 ab4:	6121                	addi	sp,sp,64
 ab6:	8082                	ret
 ab8:	74a2                	ld	s1,40(sp)
 aba:	6a42                	ld	s4,16(sp)
 abc:	6aa2                	ld	s5,8(sp)
 abe:	6b02                	ld	s6,0(sp)
 ac0:	b7f5                	j	aac <malloc+0xdc>
