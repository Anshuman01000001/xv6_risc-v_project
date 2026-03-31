
user/_hello_world:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <demo_variables>:
#include "user/user.h"

// Example 1: Variables and types
void
demo_variables(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("\n=== Variables and Types ===\n");
   8:	00001517          	auipc	a0,0x1
   c:	cd850513          	addi	a0,a0,-808 # ce0 <malloc+0xfc>
  10:	321000ef          	jal	b30 <printf>
  int x = 42;
  char c = 'A';
  
  printf("Integer x = %d\n", x);
  14:	02a00593          	li	a1,42
  18:	00001517          	auipc	a0,0x1
  1c:	cf050513          	addi	a0,a0,-784 # d08 <malloc+0x124>
  20:	311000ef          	jal	b30 <printf>
  printf("Character c = %c\n", c);
  24:	04100593          	li	a1,65
  28:	00001517          	auipc	a0,0x1
  2c:	cf050513          	addi	a0,a0,-784 # d18 <malloc+0x134>
  30:	301000ef          	jal	b30 <printf>
}
  34:	60a2                	ld	ra,8(sp)
  36:	6402                	ld	s0,0(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <add_numbers>:

// Example 2: Functions with parameters and return values
int
add_numbers(int a, int b)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e422                	sd	s0,8(sp)
  40:	0800                	addi	s0,sp,16
  return a + b;
}
  42:	9d2d                	addw	a0,a0,a1
  44:	6422                	ld	s0,8(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <multiply>:

int
multiply(int a, int b)
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e422                	sd	s0,8(sp)
  4e:	0800                	addi	s0,sp,16
  int result = a * b;
  return result;
}
  50:	02b5053b          	mulw	a0,a0,a1
  54:	6422                	ld	s0,8(sp)
  56:	0141                	addi	sp,sp,16
  58:	8082                	ret

000000000000005a <demo_functions>:

void
demo_functions(void)
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e406                	sd	ra,8(sp)
  5e:	e022                	sd	s0,0(sp)
  60:	0800                	addi	s0,sp,16
  printf("\n=== Functions ===\n");
  62:	00001517          	auipc	a0,0x1
  66:	cce50513          	addi	a0,a0,-818 # d30 <malloc+0x14c>
  6a:	2c7000ef          	jal	b30 <printf>
  int sum = add_numbers(10, 20);
  int product = multiply(5, 7);
  
  printf("10 + 20 = %d\n", sum);
  6e:	45f9                	li	a1,30
  70:	00001517          	auipc	a0,0x1
  74:	cd850513          	addi	a0,a0,-808 # d48 <malloc+0x164>
  78:	2b9000ef          	jal	b30 <printf>
  printf("5 * 7 = %d\n", product);
  7c:	02300593          	li	a1,35
  80:	00001517          	auipc	a0,0x1
  84:	cd850513          	addi	a0,a0,-808 # d58 <malloc+0x174>
  88:	2a9000ef          	jal	b30 <printf>
}
  8c:	60a2                	ld	ra,8(sp)
  8e:	6402                	ld	s0,0(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <demo_arrays>:

// Example 3: Arrays
void
demo_arrays(void)
{
  94:	715d                	addi	sp,sp,-80
  96:	e486                	sd	ra,72(sp)
  98:	e0a2                	sd	s0,64(sp)
  9a:	fc26                	sd	s1,56(sp)
  9c:	f84a                	sd	s2,48(sp)
  9e:	f44e                	sd	s3,40(sp)
  a0:	f052                	sd	s4,32(sp)
  a2:	0880                	addi	s0,sp,80
  printf("\n=== Arrays ===\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	cc450513          	addi	a0,a0,-828 # d68 <malloc+0x184>
  ac:	285000ef          	jal	b30 <printf>
  int numbers[5] = {10, 20, 30, 40, 50};
  b0:	47a9                	li	a5,10
  b2:	faf42c23          	sw	a5,-72(s0)
  b6:	47d1                	li	a5,20
  b8:	faf42e23          	sw	a5,-68(s0)
  bc:	47f9                	li	a5,30
  be:	fcf42023          	sw	a5,-64(s0)
  c2:	02800793          	li	a5,40
  c6:	fcf42223          	sw	a5,-60(s0)
  ca:	03200793          	li	a5,50
  ce:	fcf42423          	sw	a5,-56(s0)
  
  printf("Array elements:\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	cae50513          	addi	a0,a0,-850 # d80 <malloc+0x19c>
  da:	257000ef          	jal	b30 <printf>
  for(int i = 0; i < 5; i++) {
  de:	fb840913          	addi	s2,s0,-72
  e2:	4481                	li	s1,0
    printf("  numbers[%d] = %d\n", i, numbers[i]);
  e4:	00001a17          	auipc	s4,0x1
  e8:	cb4a0a13          	addi	s4,s4,-844 # d98 <malloc+0x1b4>
  for(int i = 0; i < 5; i++) {
  ec:	4995                	li	s3,5
    printf("  numbers[%d] = %d\n", i, numbers[i]);
  ee:	00092603          	lw	a2,0(s2)
  f2:	85a6                	mv	a1,s1
  f4:	8552                	mv	a0,s4
  f6:	23b000ef          	jal	b30 <printf>
  for(int i = 0; i < 5; i++) {
  fa:	2485                	addiw	s1,s1,1
  fc:	0911                	addi	s2,s2,4
  fe:	ff3498e3          	bne	s1,s3,ee <demo_arrays+0x5a>
  // Calculate sum
  int sum = 0;
  for(int i = 0; i < 5; i++) {
    sum += numbers[i];
  }
  printf("Sum of array = %d\n", sum);
 102:	09600593          	li	a1,150
 106:	00001517          	auipc	a0,0x1
 10a:	caa50513          	addi	a0,a0,-854 # db0 <malloc+0x1cc>
 10e:	223000ef          	jal	b30 <printf>
}
 112:	60a6                	ld	ra,72(sp)
 114:	6406                	ld	s0,64(sp)
 116:	74e2                	ld	s1,56(sp)
 118:	7942                	ld	s2,48(sp)
 11a:	79a2                	ld	s3,40(sp)
 11c:	7a02                	ld	s4,32(sp)
 11e:	6161                	addi	sp,sp,80
 120:	8082                	ret

0000000000000122 <demo_structs>:
  int id;
};

void
demo_structs(void)
{
 122:	1141                	addi	sp,sp,-16
 124:	e406                	sd	ra,8(sp)
 126:	e022                	sd	s0,0(sp)
 128:	0800                	addi	s0,sp,16
  printf("\n=== Structures ===\n");
 12a:	00001517          	auipc	a0,0x1
 12e:	c9e50513          	addi	a0,a0,-866 # dc8 <malloc+0x1e4>
 132:	1ff000ef          	jal	b30 <printf>
  
  struct point p;
  p.x = 100;
  p.y = 200;
  printf("Point: (%d, %d)\n", p.x, p.y);
 136:	0c800613          	li	a2,200
 13a:	06400593          	li	a1,100
 13e:	00001517          	auipc	a0,0x1
 142:	ca250513          	addi	a0,a0,-862 # de0 <malloc+0x1fc>
 146:	1eb000ef          	jal	b30 <printf>
  
  struct person student;
  student.age = 20;
  student.id = 12345;
  printf("Person: age=%d, id=%d\n", student.age, student.id);
 14a:	660d                	lui	a2,0x3
 14c:	03960613          	addi	a2,a2,57 # 3039 <base+0x1029>
 150:	45d1                	li	a1,20
 152:	00001517          	auipc	a0,0x1
 156:	ca650513          	addi	a0,a0,-858 # df8 <malloc+0x214>
 15a:	1d7000ef          	jal	b30 <printf>
}
 15e:	60a2                	ld	ra,8(sp)
 160:	6402                	ld	s0,0(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <demo_strings>:

// Example 5: Strings (character arrays)
void
demo_strings(void)
{
 166:	711d                	addi	sp,sp,-96
 168:	ec86                	sd	ra,88(sp)
 16a:	e8a2                	sd	s0,80(sp)
 16c:	1080                	addi	s0,sp,96
  printf("\n=== Strings ===\n");
 16e:	00001517          	auipc	a0,0x1
 172:	ca250513          	addi	a0,a0,-862 # e10 <malloc+0x22c>
 176:	1bb000ef          	jal	b30 <printf>
  
  char greeting[] = "Hello";
 17a:	6c6c67b7          	lui	a5,0x6c6c6
 17e:	54878793          	addi	a5,a5,1352 # 6c6c6548 <base+0x6c6c4538>
 182:	fef42423          	sw	a5,-24(s0)
 186:	06f00793          	li	a5,111
 18a:	fef41623          	sh	a5,-20(s0)
  char name[] = "xv6";  // Need 4 chars: 'x', 'v', '6', '\0'
 18e:	003677b7          	lui	a5,0x367
 192:	67878793          	addi	a5,a5,1656 # 367678 <base+0x365668>
 196:	fef42023          	sw	a5,-32(s0)
  
  printf("Greeting: %s\n", greeting);
 19a:	fe840593          	addi	a1,s0,-24
 19e:	00001517          	auipc	a0,0x1
 1a2:	c8a50513          	addi	a0,a0,-886 # e28 <malloc+0x244>
 1a6:	18b000ef          	jal	b30 <printf>
  printf("Name: %s\n", name);
 1aa:	fe040593          	addi	a1,s0,-32
 1ae:	00001517          	auipc	a0,0x1
 1b2:	c8a50513          	addi	a0,a0,-886 # e38 <malloc+0x254>
 1b6:	17b000ef          	jal	b30 <printf>
  
  // String length
  int len = strlen(name);
 1ba:	fe040513          	addi	a0,s0,-32
 1be:	306000ef          	jal	4c4 <strlen>
  printf("Length of '%s' = %d\n", name, len);
 1c2:	0005061b          	sext.w	a2,a0
 1c6:	fe040593          	addi	a1,s0,-32
 1ca:	00001517          	auipc	a0,0x1
 1ce:	c7e50513          	addi	a0,a0,-898 # e48 <malloc+0x264>
 1d2:	15f000ef          	jal	b30 <printf>
  
  // String concatenation (manual)
  char message[50] = "Welcome to ";
 1d6:	00001797          	auipc	a5,0x1
 1da:	c9a78793          	addi	a5,a5,-870 # e70 <malloc+0x28c>
 1de:	0007cf03          	lbu	t5,0(a5)
 1e2:	0017ce83          	lbu	t4,1(a5)
 1e6:	0027ce03          	lbu	t3,2(a5)
 1ea:	0037c303          	lbu	t1,3(a5)
 1ee:	0047c883          	lbu	a7,4(a5)
 1f2:	0057c803          	lbu	a6,5(a5)
 1f6:	0067c503          	lbu	a0,6(a5)
 1fa:	0077c583          	lbu	a1,7(a5)
 1fe:	0087c603          	lbu	a2,8(a5)
 202:	0097c683          	lbu	a3,9(a5)
 206:	00a7c703          	lbu	a4,10(a5)
 20a:	00b7c783          	lbu	a5,11(a5)
 20e:	fbe40423          	sb	t5,-88(s0)
 212:	fbd404a3          	sb	t4,-87(s0)
 216:	fbc40523          	sb	t3,-86(s0)
 21a:	fa6405a3          	sb	t1,-85(s0)
 21e:	fb140623          	sb	a7,-84(s0)
 222:	fb0406a3          	sb	a6,-83(s0)
 226:	faa40723          	sb	a0,-82(s0)
 22a:	fab407a3          	sb	a1,-81(s0)
 22e:	fac40823          	sb	a2,-80(s0)
 232:	fad408a3          	sb	a3,-79(s0)
 236:	fae40923          	sb	a4,-78(s0)
 23a:	faf409a3          	sb	a5,-77(s0)
 23e:	fa042a23          	sw	zero,-76(s0)
 242:	fa042c23          	sw	zero,-72(s0)
 246:	fa042e23          	sw	zero,-68(s0)
 24a:	fc042023          	sw	zero,-64(s0)
 24e:	fc042223          	sw	zero,-60(s0)
 252:	fc042423          	sw	zero,-56(s0)
 256:	fc042623          	sw	zero,-52(s0)
 25a:	fc042823          	sw	zero,-48(s0)
 25e:	fc042a23          	sw	zero,-44(s0)
 262:	fc041c23          	sh	zero,-40(s0)
  int i = strlen(message);
 266:	fa840513          	addi	a0,s0,-88
 26a:	25a000ef          	jal	4c4 <strlen>
 26e:	2501                	sext.w	a0,a0
  int j = 0;
  while(name[j] != '\0') {
 270:	fe044703          	lbu	a4,-32(s0)
 274:	c30d                	beqz	a4,296 <demo_strings+0x130>
 276:	0015079b          	addiw	a5,a0,1
 27a:	fe040693          	addi	a3,s0,-32
    message[i++] = name[j++];
 27e:	fa840613          	addi	a2,s0,-88
 282:	963e                	add	a2,a2,a5
 284:	fee60fa3          	sb	a4,-1(a2)
  while(name[j] != '\0') {
 288:	0016c703          	lbu	a4,1(a3)
 28c:	853e                	mv	a0,a5
 28e:	0785                	addi	a5,a5,1
 290:	0685                	addi	a3,a3,1
 292:	f775                	bnez	a4,27e <demo_strings+0x118>
    message[i++] = name[j++];
 294:	2501                	sext.w	a0,a0
  }
  message[i] = '\0';
 296:	ff050793          	addi	a5,a0,-16
 29a:	00878533          	add	a0,a5,s0
 29e:	fa050c23          	sb	zero,-72(a0)
  printf("Message: %s\n", message);
 2a2:	fa840593          	addi	a1,s0,-88
 2a6:	00001517          	auipc	a0,0x1
 2aa:	bba50513          	addi	a0,a0,-1094 # e60 <malloc+0x27c>
 2ae:	083000ef          	jal	b30 <printf>
}
 2b2:	60e6                	ld	ra,88(sp)
 2b4:	6446                	ld	s0,80(sp)
 2b6:	6125                	addi	sp,sp,96
 2b8:	8082                	ret

00000000000002ba <demo_pointers>:

// Example 6: Pointers
void
demo_pointers(void)
{
 2ba:	1101                	addi	sp,sp,-32
 2bc:	ec06                	sd	ra,24(sp)
 2be:	e822                	sd	s0,16(sp)
 2c0:	1000                	addi	s0,sp,32
  printf("\n=== Pointers ===\n");
 2c2:	00001517          	auipc	a0,0x1
 2c6:	bbe50513          	addi	a0,a0,-1090 # e80 <malloc+0x29c>
 2ca:	067000ef          	jal	b30 <printf>
  
  int a = 5;           
 2ce:	4795                	li	a5,5
 2d0:	fef42623          	sw	a5,-20(s0)
  // a regular integer, stored somewhere in memory
  printf("a = %d\n", a);
 2d4:	4595                	li	a1,5
 2d6:	00001517          	auipc	a0,0x1
 2da:	bc250513          	addi	a0,a0,-1086 # e98 <malloc+0x2b4>
 2de:	053000ef          	jal	b30 <printf>
  
  int *p = &a;         
 2e2:	fec40593          	addi	a1,s0,-20
 2e6:	feb43023          	sd	a1,-32(s0)
  // a pointer to an integer value, `p` stores the memory location of `a`
  printf("p = %p (address of a)\n", p);
 2ea:	00001517          	auipc	a0,0x1
 2ee:	bb650513          	addi	a0,a0,-1098 # ea0 <malloc+0x2bc>
 2f2:	03f000ef          	jal	b30 <printf>
  printf("*p = %d (value at address p)\n", *p);
 2f6:	fe043783          	ld	a5,-32(s0)
 2fa:	438c                	lw	a1,0(a5)
 2fc:	00001517          	auipc	a0,0x1
 300:	bbc50513          	addi	a0,a0,-1092 # eb8 <malloc+0x2d4>
 304:	02d000ef          	jal	b30 <printf>
  
  *p = 6;              
 308:	fe043783          	ld	a5,-32(s0)
 30c:	4719                	li	a4,6
 30e:	c398                	sw	a4,0(a5)
  // when outside of declarations, * is a 'dereference' operator, i.e., give me the content in the address that variable p refers to
  printf("After *p = 6:\n");
 310:	00001517          	auipc	a0,0x1
 314:	bc850513          	addi	a0,a0,-1080 # ed8 <malloc+0x2f4>
 318:	019000ef          	jal	b30 <printf>
  printf("a = %d (changed via pointer)\n", a);
 31c:	fec42583          	lw	a1,-20(s0)
 320:	00001517          	auipc	a0,0x1
 324:	bc850513          	addi	a0,a0,-1080 # ee8 <malloc+0x304>
 328:	009000ef          	jal	b30 <printf>
  
  int **x = &p;        
  // a pointer to a pointer, `x` stores the memory location of `p`
  
  printf("x = %p (address of p)\n", x);
 32c:	fe040593          	addi	a1,s0,-32
 330:	00001517          	auipc	a0,0x1
 334:	bd850513          	addi	a0,a0,-1064 # f08 <malloc+0x324>
 338:	7f8000ef          	jal	b30 <printf>
  printf("*x = %p (value at x, which is address of a)\n", *x);
 33c:	fe043583          	ld	a1,-32(s0)
 340:	00001517          	auipc	a0,0x1
 344:	be050513          	addi	a0,a0,-1056 # f20 <malloc+0x33c>
 348:	7e8000ef          	jal	b30 <printf>
  printf("**x = %d (value at address stored in p)\n", **x);
 34c:	fe043783          	ld	a5,-32(s0)
 350:	438c                	lw	a1,0(a5)
 352:	00001517          	auipc	a0,0x1
 356:	bfe50513          	addi	a0,a0,-1026 # f50 <malloc+0x36c>
 35a:	7d6000ef          	jal	b30 <printf>
}
 35e:	60e2                	ld	ra,24(sp)
 360:	6442                	ld	s0,16(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret

0000000000000366 <demo_file_read>:

// Example 7: File I/O - Reading a file
void
demo_file_read(char *file)
{
 366:	de010113          	addi	sp,sp,-544
 36a:	20113c23          	sd	ra,536(sp)
 36e:	20813823          	sd	s0,528(sp)
 372:	21213023          	sd	s2,512(sp)
 376:	1400                	addi	s0,sp,544
 378:	892a                	mv	s2,a0
  printf("\n=== File Reading ===\n");
 37a:	00001517          	auipc	a0,0x1
 37e:	c0650513          	addi	a0,a0,-1018 # f80 <malloc+0x39c>
 382:	7ae000ef          	jal	b30 <printf>
  
  char buf[512];
  int fd, n;
  
  // Open the file for reading
  fd = open(file, 0);  // 0 = O_RDONLY
 386:	4581                	li	a1,0
 388:	854a                	mv	a0,s2
 38a:	3b6000ef          	jal	740 <open>
  if(fd < 0){
 38e:	00054d63          	bltz	a0,3a8 <demo_file_read+0x42>
 392:	20913423          	sd	s1,520(sp)
 396:	84aa                	mv	s1,a0
    printf("Error: cannot open %s\n", file);
    return;
  }
  
  printf("Reading from %s:\n", file);
 398:	85ca                	mv	a1,s2
 39a:	00001517          	auipc	a0,0x1
 39e:	c1650513          	addi	a0,a0,-1002 # fb0 <malloc+0x3cc>
 3a2:	78e000ef          	jal	b30 <printf>
  
  // Read and print file contents
  while((n = read(fd, buf, sizeof(buf))) > 0) {
 3a6:	a831                	j	3c2 <demo_file_read+0x5c>
    printf("Error: cannot open %s\n", file);
 3a8:	85ca                	mv	a1,s2
 3aa:	00001517          	auipc	a0,0x1
 3ae:	bee50513          	addi	a0,a0,-1042 # f98 <malloc+0x3b4>
 3b2:	77e000ef          	jal	b30 <printf>
    return;
 3b6:	a81d                	j	3ec <demo_file_read+0x86>
    write(1, buf, n);  // Write to stdout (fd = 1)
 3b8:	de040593          	addi	a1,s0,-544
 3bc:	4505                	li	a0,1
 3be:	362000ef          	jal	720 <write>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
 3c2:	20000613          	li	a2,512
 3c6:	de040593          	addi	a1,s0,-544
 3ca:	8526                	mv	a0,s1
 3cc:	34c000ef          	jal	718 <read>
 3d0:	862a                	mv	a2,a0
 3d2:	fea043e3          	bgtz	a0,3b8 <demo_file_read+0x52>
  }
  
  // Close the file
  close(fd);
 3d6:	8526                	mv	a0,s1
 3d8:	350000ef          	jal	728 <close>
  printf("\n");
 3dc:	00001517          	auipc	a0,0x1
 3e0:	bec50513          	addi	a0,a0,-1044 # fc8 <malloc+0x3e4>
 3e4:	74c000ef          	jal	b30 <printf>
 3e8:	20813483          	ld	s1,520(sp)
}
 3ec:	21813083          	ld	ra,536(sp)
 3f0:	21013403          	ld	s0,528(sp)
 3f4:	20013903          	ld	s2,512(sp)
 3f8:	22010113          	addi	sp,sp,544
 3fc:	8082                	ret

00000000000003fe <main>:

int
main(int argc, char *argv[])
{
 3fe:	1101                	addi	sp,sp,-32
 400:	ec06                	sd	ra,24(sp)
 402:	e822                	sd	s0,16(sp)
 404:	e426                	sd	s1,8(sp)
 406:	e04a                	sd	s2,0(sp)
 408:	1000                	addi	s0,sp,32
 40a:	84aa                	mv	s1,a0
 40c:	892e                	mv	s2,a1
  printf("=== Basic C Programming Examples ===\n");
 40e:	00001517          	auipc	a0,0x1
 412:	bc250513          	addi	a0,a0,-1086 # fd0 <malloc+0x3ec>
 416:	71a000ef          	jal	b30 <printf>
  
  demo_variables();
 41a:	be7ff0ef          	jal	0 <demo_variables>
  demo_functions();
 41e:	c3dff0ef          	jal	5a <demo_functions>
  demo_arrays();
 422:	c73ff0ef          	jal	94 <demo_arrays>
  demo_structs();
 426:	cfdff0ef          	jal	122 <demo_structs>
  demo_strings();
 42a:	d3dff0ef          	jal	166 <demo_strings>
  demo_pointers();
 42e:	e8dff0ef          	jal	2ba <demo_pointers>

  if(argc < 2) {
 432:	4785                	li	a5,1
 434:	0097cf63          	blt	a5,s1,452 <main+0x54>
    printf("\nNo file specified for reading demo. Skipping file read demo.\n");
 438:	00001517          	auipc	a0,0x1
 43c:	bc050513          	addi	a0,a0,-1088 # ff8 <malloc+0x414>
 440:	6f0000ef          	jal	b30 <printf>
    demo_file_read(argv[1]);
  }
  
  printf("\n=== All demos complete! ===\n");
  exit(0);
}
 444:	4501                	li	a0,0
 446:	60e2                	ld	ra,24(sp)
 448:	6442                	ld	s0,16(sp)
 44a:	64a2                	ld	s1,8(sp)
 44c:	6902                	ld	s2,0(sp)
 44e:	6105                	addi	sp,sp,32
 450:	8082                	ret
    demo_file_read(argv[1]);
 452:	00893503          	ld	a0,8(s2)
 456:	f11ff0ef          	jal	366 <demo_file_read>
  printf("\n=== All demos complete! ===\n");
 45a:	00001517          	auipc	a0,0x1
 45e:	bde50513          	addi	a0,a0,-1058 # 1038 <malloc+0x454>
 462:	6ce000ef          	jal	b30 <printf>
  exit(0);
 466:	4501                	li	a0,0
 468:	298000ef          	jal	700 <exit>

000000000000046c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e406                	sd	ra,8(sp)
 470:	e022                	sd	s0,0(sp)
 472:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 474:	f8bff0ef          	jal	3fe <main>
  exit(r);
 478:	288000ef          	jal	700 <exit>

000000000000047c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 482:	87aa                	mv	a5,a0
 484:	0585                	addi	a1,a1,1
 486:	0785                	addi	a5,a5,1
 488:	fff5c703          	lbu	a4,-1(a1)
 48c:	fee78fa3          	sb	a4,-1(a5)
 490:	fb75                	bnez	a4,484 <strcpy+0x8>
    ;
  return os;
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret

0000000000000498 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e422                	sd	s0,8(sp)
 49c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 49e:	00054783          	lbu	a5,0(a0)
 4a2:	cb91                	beqz	a5,4b6 <strcmp+0x1e>
 4a4:	0005c703          	lbu	a4,0(a1)
 4a8:	00f71763          	bne	a4,a5,4b6 <strcmp+0x1e>
    p++, q++;
 4ac:	0505                	addi	a0,a0,1
 4ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4b0:	00054783          	lbu	a5,0(a0)
 4b4:	fbe5                	bnez	a5,4a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4b6:	0005c503          	lbu	a0,0(a1)
}
 4ba:	40a7853b          	subw	a0,a5,a0
 4be:	6422                	ld	s0,8(sp)
 4c0:	0141                	addi	sp,sp,16
 4c2:	8082                	ret

00000000000004c4 <strlen>:

uint
strlen(const char *s)
{
 4c4:	1141                	addi	sp,sp,-16
 4c6:	e422                	sd	s0,8(sp)
 4c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4ca:	00054783          	lbu	a5,0(a0)
 4ce:	cf91                	beqz	a5,4ea <strlen+0x26>
 4d0:	0505                	addi	a0,a0,1
 4d2:	87aa                	mv	a5,a0
 4d4:	86be                	mv	a3,a5
 4d6:	0785                	addi	a5,a5,1
 4d8:	fff7c703          	lbu	a4,-1(a5)
 4dc:	ff65                	bnez	a4,4d4 <strlen+0x10>
 4de:	40a6853b          	subw	a0,a3,a0
 4e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 4e4:	6422                	ld	s0,8(sp)
 4e6:	0141                	addi	sp,sp,16
 4e8:	8082                	ret
  for(n = 0; s[n]; n++)
 4ea:	4501                	li	a0,0
 4ec:	bfe5                	j	4e4 <strlen+0x20>

00000000000004ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 4ee:	1141                	addi	sp,sp,-16
 4f0:	e422                	sd	s0,8(sp)
 4f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4f4:	ca19                	beqz	a2,50a <memset+0x1c>
 4f6:	87aa                	mv	a5,a0
 4f8:	1602                	slli	a2,a2,0x20
 4fa:	9201                	srli	a2,a2,0x20
 4fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 500:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 504:	0785                	addi	a5,a5,1
 506:	fee79de3          	bne	a5,a4,500 <memset+0x12>
  }
  return dst;
}
 50a:	6422                	ld	s0,8(sp)
 50c:	0141                	addi	sp,sp,16
 50e:	8082                	ret

0000000000000510 <strchr>:

char*
strchr(const char *s, char c)
{
 510:	1141                	addi	sp,sp,-16
 512:	e422                	sd	s0,8(sp)
 514:	0800                	addi	s0,sp,16
  for(; *s; s++)
 516:	00054783          	lbu	a5,0(a0)
 51a:	cb99                	beqz	a5,530 <strchr+0x20>
    if(*s == c)
 51c:	00f58763          	beq	a1,a5,52a <strchr+0x1a>
  for(; *s; s++)
 520:	0505                	addi	a0,a0,1
 522:	00054783          	lbu	a5,0(a0)
 526:	fbfd                	bnez	a5,51c <strchr+0xc>
      return (char*)s;
  return 0;
 528:	4501                	li	a0,0
}
 52a:	6422                	ld	s0,8(sp)
 52c:	0141                	addi	sp,sp,16
 52e:	8082                	ret
  return 0;
 530:	4501                	li	a0,0
 532:	bfe5                	j	52a <strchr+0x1a>

0000000000000534 <gets>:

char*
gets(char *buf, int max)
{
 534:	711d                	addi	sp,sp,-96
 536:	ec86                	sd	ra,88(sp)
 538:	e8a2                	sd	s0,80(sp)
 53a:	e4a6                	sd	s1,72(sp)
 53c:	e0ca                	sd	s2,64(sp)
 53e:	fc4e                	sd	s3,56(sp)
 540:	f852                	sd	s4,48(sp)
 542:	f456                	sd	s5,40(sp)
 544:	f05a                	sd	s6,32(sp)
 546:	ec5e                	sd	s7,24(sp)
 548:	1080                	addi	s0,sp,96
 54a:	8baa                	mv	s7,a0
 54c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 54e:	892a                	mv	s2,a0
 550:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 552:	4aa9                	li	s5,10
 554:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 556:	89a6                	mv	s3,s1
 558:	2485                	addiw	s1,s1,1
 55a:	0344d663          	bge	s1,s4,586 <gets+0x52>
    cc = read(0, &c, 1);
 55e:	4605                	li	a2,1
 560:	faf40593          	addi	a1,s0,-81
 564:	4501                	li	a0,0
 566:	1b2000ef          	jal	718 <read>
    if(cc < 1)
 56a:	00a05e63          	blez	a0,586 <gets+0x52>
    buf[i++] = c;
 56e:	faf44783          	lbu	a5,-81(s0)
 572:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 576:	01578763          	beq	a5,s5,584 <gets+0x50>
 57a:	0905                	addi	s2,s2,1
 57c:	fd679de3          	bne	a5,s6,556 <gets+0x22>
    buf[i++] = c;
 580:	89a6                	mv	s3,s1
 582:	a011                	j	586 <gets+0x52>
 584:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 586:	99de                	add	s3,s3,s7
 588:	00098023          	sb	zero,0(s3)
  return buf;
}
 58c:	855e                	mv	a0,s7
 58e:	60e6                	ld	ra,88(sp)
 590:	6446                	ld	s0,80(sp)
 592:	64a6                	ld	s1,72(sp)
 594:	6906                	ld	s2,64(sp)
 596:	79e2                	ld	s3,56(sp)
 598:	7a42                	ld	s4,48(sp)
 59a:	7aa2                	ld	s5,40(sp)
 59c:	7b02                	ld	s6,32(sp)
 59e:	6be2                	ld	s7,24(sp)
 5a0:	6125                	addi	sp,sp,96
 5a2:	8082                	ret

00000000000005a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 5a4:	1101                	addi	sp,sp,-32
 5a6:	ec06                	sd	ra,24(sp)
 5a8:	e822                	sd	s0,16(sp)
 5aa:	e04a                	sd	s2,0(sp)
 5ac:	1000                	addi	s0,sp,32
 5ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b0:	4581                	li	a1,0
 5b2:	18e000ef          	jal	740 <open>
  if(fd < 0)
 5b6:	02054263          	bltz	a0,5da <stat+0x36>
 5ba:	e426                	sd	s1,8(sp)
 5bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5be:	85ca                	mv	a1,s2
 5c0:	198000ef          	jal	758 <fstat>
 5c4:	892a                	mv	s2,a0
  close(fd);
 5c6:	8526                	mv	a0,s1
 5c8:	160000ef          	jal	728 <close>
  return r;
 5cc:	64a2                	ld	s1,8(sp)
}
 5ce:	854a                	mv	a0,s2
 5d0:	60e2                	ld	ra,24(sp)
 5d2:	6442                	ld	s0,16(sp)
 5d4:	6902                	ld	s2,0(sp)
 5d6:	6105                	addi	sp,sp,32
 5d8:	8082                	ret
    return -1;
 5da:	597d                	li	s2,-1
 5dc:	bfcd                	j	5ce <stat+0x2a>

00000000000005de <atoi>:

int
atoi(const char *s)
{
 5de:	1141                	addi	sp,sp,-16
 5e0:	e422                	sd	s0,8(sp)
 5e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5e4:	00054683          	lbu	a3,0(a0)
 5e8:	fd06879b          	addiw	a5,a3,-48
 5ec:	0ff7f793          	zext.b	a5,a5
 5f0:	4625                	li	a2,9
 5f2:	02f66863          	bltu	a2,a5,622 <atoi+0x44>
 5f6:	872a                	mv	a4,a0
  n = 0;
 5f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 5fa:	0705                	addi	a4,a4,1
 5fc:	0025179b          	slliw	a5,a0,0x2
 600:	9fa9                	addw	a5,a5,a0
 602:	0017979b          	slliw	a5,a5,0x1
 606:	9fb5                	addw	a5,a5,a3
 608:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 60c:	00074683          	lbu	a3,0(a4)
 610:	fd06879b          	addiw	a5,a3,-48
 614:	0ff7f793          	zext.b	a5,a5
 618:	fef671e3          	bgeu	a2,a5,5fa <atoi+0x1c>
  return n;
}
 61c:	6422                	ld	s0,8(sp)
 61e:	0141                	addi	sp,sp,16
 620:	8082                	ret
  n = 0;
 622:	4501                	li	a0,0
 624:	bfe5                	j	61c <atoi+0x3e>

0000000000000626 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 626:	1141                	addi	sp,sp,-16
 628:	e422                	sd	s0,8(sp)
 62a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 62c:	02b57463          	bgeu	a0,a1,654 <memmove+0x2e>
    while(n-- > 0)
 630:	00c05f63          	blez	a2,64e <memmove+0x28>
 634:	1602                	slli	a2,a2,0x20
 636:	9201                	srli	a2,a2,0x20
 638:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 63c:	872a                	mv	a4,a0
      *dst++ = *src++;
 63e:	0585                	addi	a1,a1,1
 640:	0705                	addi	a4,a4,1
 642:	fff5c683          	lbu	a3,-1(a1)
 646:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 64a:	fef71ae3          	bne	a4,a5,63e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 64e:	6422                	ld	s0,8(sp)
 650:	0141                	addi	sp,sp,16
 652:	8082                	ret
    dst += n;
 654:	00c50733          	add	a4,a0,a2
    src += n;
 658:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 65a:	fec05ae3          	blez	a2,64e <memmove+0x28>
 65e:	fff6079b          	addiw	a5,a2,-1
 662:	1782                	slli	a5,a5,0x20
 664:	9381                	srli	a5,a5,0x20
 666:	fff7c793          	not	a5,a5
 66a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 66c:	15fd                	addi	a1,a1,-1
 66e:	177d                	addi	a4,a4,-1
 670:	0005c683          	lbu	a3,0(a1)
 674:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 678:	fee79ae3          	bne	a5,a4,66c <memmove+0x46>
 67c:	bfc9                	j	64e <memmove+0x28>

000000000000067e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 67e:	1141                	addi	sp,sp,-16
 680:	e422                	sd	s0,8(sp)
 682:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 684:	ca05                	beqz	a2,6b4 <memcmp+0x36>
 686:	fff6069b          	addiw	a3,a2,-1
 68a:	1682                	slli	a3,a3,0x20
 68c:	9281                	srli	a3,a3,0x20
 68e:	0685                	addi	a3,a3,1
 690:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 692:	00054783          	lbu	a5,0(a0)
 696:	0005c703          	lbu	a4,0(a1)
 69a:	00e79863          	bne	a5,a4,6aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 69e:	0505                	addi	a0,a0,1
    p2++;
 6a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6a2:	fed518e3          	bne	a0,a3,692 <memcmp+0x14>
  }
  return 0;
 6a6:	4501                	li	a0,0
 6a8:	a019                	j	6ae <memcmp+0x30>
      return *p1 - *p2;
 6aa:	40e7853b          	subw	a0,a5,a4
}
 6ae:	6422                	ld	s0,8(sp)
 6b0:	0141                	addi	sp,sp,16
 6b2:	8082                	ret
  return 0;
 6b4:	4501                	li	a0,0
 6b6:	bfe5                	j	6ae <memcmp+0x30>

00000000000006b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6b8:	1141                	addi	sp,sp,-16
 6ba:	e406                	sd	ra,8(sp)
 6bc:	e022                	sd	s0,0(sp)
 6be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6c0:	f67ff0ef          	jal	626 <memmove>
}
 6c4:	60a2                	ld	ra,8(sp)
 6c6:	6402                	ld	s0,0(sp)
 6c8:	0141                	addi	sp,sp,16
 6ca:	8082                	ret

00000000000006cc <sbrk>:

char *
sbrk(int n) {
 6cc:	1141                	addi	sp,sp,-16
 6ce:	e406                	sd	ra,8(sp)
 6d0:	e022                	sd	s0,0(sp)
 6d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 6d4:	4585                	li	a1,1
 6d6:	0b2000ef          	jal	788 <sys_sbrk>
}
 6da:	60a2                	ld	ra,8(sp)
 6dc:	6402                	ld	s0,0(sp)
 6de:	0141                	addi	sp,sp,16
 6e0:	8082                	ret

00000000000006e2 <sbrklazy>:

char *
sbrklazy(int n) {
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e406                	sd	ra,8(sp)
 6e6:	e022                	sd	s0,0(sp)
 6e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 6ea:	4589                	li	a1,2
 6ec:	09c000ef          	jal	788 <sys_sbrk>
}
 6f0:	60a2                	ld	ra,8(sp)
 6f2:	6402                	ld	s0,0(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret

00000000000006f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6f8:	4885                	li	a7,1
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <exit>:
.global exit
exit:
 li a7, SYS_exit
 700:	4889                	li	a7,2
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <wait>:
.global wait
wait:
 li a7, SYS_wait
 708:	488d                	li	a7,3
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 710:	4891                	li	a7,4
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <read>:
.global read
read:
 li a7, SYS_read
 718:	4895                	li	a7,5
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <write>:
.global write
write:
 li a7, SYS_write
 720:	48c1                	li	a7,16
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <close>:
.global close
close:
 li a7, SYS_close
 728:	48d5                	li	a7,21
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <kill>:
.global kill
kill:
 li a7, SYS_kill
 730:	4899                	li	a7,6
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <exec>:
.global exec
exec:
 li a7, SYS_exec
 738:	489d                	li	a7,7
 ecall
 73a:	00000073          	ecall
 ret
 73e:	8082                	ret

0000000000000740 <open>:
.global open
open:
 li a7, SYS_open
 740:	48bd                	li	a7,15
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 748:	48c5                	li	a7,17
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 750:	48c9                	li	a7,18
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 758:	48a1                	li	a7,8
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <link>:
.global link
link:
 li a7, SYS_link
 760:	48cd                	li	a7,19
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 768:	48d1                	li	a7,20
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 770:	48a5                	li	a7,9
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <dup>:
.global dup
dup:
 li a7, SYS_dup
 778:	48a9                	li	a7,10
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 780:	48ad                	li	a7,11
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 788:	48b1                	li	a7,12
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <pause>:
.global pause
pause:
 li a7, SYS_pause
 790:	48b5                	li	a7,13
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 798:	48b9                	li	a7,14
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <kps>:
.global kps
kps:
 li a7, SYS_kps
 7a0:	48d9                	li	a7,22
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7a8:	1101                	addi	sp,sp,-32
 7aa:	ec06                	sd	ra,24(sp)
 7ac:	e822                	sd	s0,16(sp)
 7ae:	1000                	addi	s0,sp,32
 7b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b4:	4605                	li	a2,1
 7b6:	fef40593          	addi	a1,s0,-17
 7ba:	f67ff0ef          	jal	720 <write>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6105                	addi	sp,sp,32
 7c4:	8082                	ret

00000000000007c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 7c6:	715d                	addi	sp,sp,-80
 7c8:	e486                	sd	ra,72(sp)
 7ca:	e0a2                	sd	s0,64(sp)
 7cc:	f84a                	sd	s2,48(sp)
 7ce:	0880                	addi	s0,sp,80
 7d0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 7d2:	c299                	beqz	a3,7d8 <printint+0x12>
 7d4:	0805c363          	bltz	a1,85a <printint+0x94>
  neg = 0;
 7d8:	4881                	li	a7,0
 7da:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 7de:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 7e0:	00001517          	auipc	a0,0x1
 7e4:	88050513          	addi	a0,a0,-1920 # 1060 <digits>
 7e8:	883e                	mv	a6,a5
 7ea:	2785                	addiw	a5,a5,1
 7ec:	02c5f733          	remu	a4,a1,a2
 7f0:	972a                	add	a4,a4,a0
 7f2:	00074703          	lbu	a4,0(a4)
 7f6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 7fa:	872e                	mv	a4,a1
 7fc:	02c5d5b3          	divu	a1,a1,a2
 800:	0685                	addi	a3,a3,1
 802:	fec773e3          	bgeu	a4,a2,7e8 <printint+0x22>
  if(neg)
 806:	00088b63          	beqz	a7,81c <printint+0x56>
    buf[i++] = '-';
 80a:	fd078793          	addi	a5,a5,-48
 80e:	97a2                	add	a5,a5,s0
 810:	02d00713          	li	a4,45
 814:	fee78423          	sb	a4,-24(a5)
 818:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 81c:	02f05a63          	blez	a5,850 <printint+0x8a>
 820:	fc26                	sd	s1,56(sp)
 822:	f44e                	sd	s3,40(sp)
 824:	fb840713          	addi	a4,s0,-72
 828:	00f704b3          	add	s1,a4,a5
 82c:	fff70993          	addi	s3,a4,-1
 830:	99be                	add	s3,s3,a5
 832:	37fd                	addiw	a5,a5,-1
 834:	1782                	slli	a5,a5,0x20
 836:	9381                	srli	a5,a5,0x20
 838:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 83c:	fff4c583          	lbu	a1,-1(s1)
 840:	854a                	mv	a0,s2
 842:	f67ff0ef          	jal	7a8 <putc>
  while(--i >= 0)
 846:	14fd                	addi	s1,s1,-1
 848:	ff349ae3          	bne	s1,s3,83c <printint+0x76>
 84c:	74e2                	ld	s1,56(sp)
 84e:	79a2                	ld	s3,40(sp)
}
 850:	60a6                	ld	ra,72(sp)
 852:	6406                	ld	s0,64(sp)
 854:	7942                	ld	s2,48(sp)
 856:	6161                	addi	sp,sp,80
 858:	8082                	ret
    x = -xx;
 85a:	40b005b3          	neg	a1,a1
    neg = 1;
 85e:	4885                	li	a7,1
    x = -xx;
 860:	bfad                	j	7da <printint+0x14>

0000000000000862 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 862:	711d                	addi	sp,sp,-96
 864:	ec86                	sd	ra,88(sp)
 866:	e8a2                	sd	s0,80(sp)
 868:	e0ca                	sd	s2,64(sp)
 86a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 86c:	0005c903          	lbu	s2,0(a1)
 870:	28090663          	beqz	s2,afc <vprintf+0x29a>
 874:	e4a6                	sd	s1,72(sp)
 876:	fc4e                	sd	s3,56(sp)
 878:	f852                	sd	s4,48(sp)
 87a:	f456                	sd	s5,40(sp)
 87c:	f05a                	sd	s6,32(sp)
 87e:	ec5e                	sd	s7,24(sp)
 880:	e862                	sd	s8,16(sp)
 882:	e466                	sd	s9,8(sp)
 884:	8b2a                	mv	s6,a0
 886:	8a2e                	mv	s4,a1
 888:	8bb2                	mv	s7,a2
  state = 0;
 88a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 88c:	4481                	li	s1,0
 88e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 890:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 894:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 898:	06c00c93          	li	s9,108
 89c:	a005                	j	8bc <vprintf+0x5a>
        putc(fd, c0);
 89e:	85ca                	mv	a1,s2
 8a0:	855a                	mv	a0,s6
 8a2:	f07ff0ef          	jal	7a8 <putc>
 8a6:	a019                	j	8ac <vprintf+0x4a>
    } else if(state == '%'){
 8a8:	03598263          	beq	s3,s5,8cc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 8ac:	2485                	addiw	s1,s1,1
 8ae:	8726                	mv	a4,s1
 8b0:	009a07b3          	add	a5,s4,s1
 8b4:	0007c903          	lbu	s2,0(a5)
 8b8:	22090a63          	beqz	s2,aec <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 8bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8c0:	fe0994e3          	bnez	s3,8a8 <vprintf+0x46>
      if(c0 == '%'){
 8c4:	fd579de3          	bne	a5,s5,89e <vprintf+0x3c>
        state = '%';
 8c8:	89be                	mv	s3,a5
 8ca:	b7cd                	j	8ac <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 8cc:	00ea06b3          	add	a3,s4,a4
 8d0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 8d4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 8d6:	c681                	beqz	a3,8de <vprintf+0x7c>
 8d8:	9752                	add	a4,a4,s4
 8da:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 8de:	05878363          	beq	a5,s8,924 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 8e2:	05978d63          	beq	a5,s9,93c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 8e6:	07500713          	li	a4,117
 8ea:	0ee78763          	beq	a5,a4,9d8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 8ee:	07800713          	li	a4,120
 8f2:	12e78963          	beq	a5,a4,a24 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 8f6:	07000713          	li	a4,112
 8fa:	14e78e63          	beq	a5,a4,a56 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 8fe:	06300713          	li	a4,99
 902:	18e78e63          	beq	a5,a4,a9e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 906:	07300713          	li	a4,115
 90a:	1ae78463          	beq	a5,a4,ab2 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 90e:	02500713          	li	a4,37
 912:	04e79563          	bne	a5,a4,95c <vprintf+0xfa>
        putc(fd, '%');
 916:	02500593          	li	a1,37
 91a:	855a                	mv	a0,s6
 91c:	e8dff0ef          	jal	7a8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 920:	4981                	li	s3,0
 922:	b769                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 924:	008b8913          	addi	s2,s7,8
 928:	4685                	li	a3,1
 92a:	4629                	li	a2,10
 92c:	000ba583          	lw	a1,0(s7)
 930:	855a                	mv	a0,s6
 932:	e95ff0ef          	jal	7c6 <printint>
 936:	8bca                	mv	s7,s2
      state = 0;
 938:	4981                	li	s3,0
 93a:	bf8d                	j	8ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 93c:	06400793          	li	a5,100
 940:	02f68963          	beq	a3,a5,972 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 944:	06c00793          	li	a5,108
 948:	04f68263          	beq	a3,a5,98c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 94c:	07500793          	li	a5,117
 950:	0af68063          	beq	a3,a5,9f0 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 954:	07800793          	li	a5,120
 958:	0ef68263          	beq	a3,a5,a3c <vprintf+0x1da>
        putc(fd, '%');
 95c:	02500593          	li	a1,37
 960:	855a                	mv	a0,s6
 962:	e47ff0ef          	jal	7a8 <putc>
        putc(fd, c0);
 966:	85ca                	mv	a1,s2
 968:	855a                	mv	a0,s6
 96a:	e3fff0ef          	jal	7a8 <putc>
      state = 0;
 96e:	4981                	li	s3,0
 970:	bf35                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 972:	008b8913          	addi	s2,s7,8
 976:	4685                	li	a3,1
 978:	4629                	li	a2,10
 97a:	000bb583          	ld	a1,0(s7)
 97e:	855a                	mv	a0,s6
 980:	e47ff0ef          	jal	7c6 <printint>
        i += 1;
 984:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 986:	8bca                	mv	s7,s2
      state = 0;
 988:	4981                	li	s3,0
        i += 1;
 98a:	b70d                	j	8ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 98c:	06400793          	li	a5,100
 990:	02f60763          	beq	a2,a5,9be <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 994:	07500793          	li	a5,117
 998:	06f60963          	beq	a2,a5,a0a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 99c:	07800793          	li	a5,120
 9a0:	faf61ee3          	bne	a2,a5,95c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 9a4:	008b8913          	addi	s2,s7,8
 9a8:	4681                	li	a3,0
 9aa:	4641                	li	a2,16
 9ac:	000bb583          	ld	a1,0(s7)
 9b0:	855a                	mv	a0,s6
 9b2:	e15ff0ef          	jal	7c6 <printint>
        i += 2;
 9b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 9b8:	8bca                	mv	s7,s2
      state = 0;
 9ba:	4981                	li	s3,0
        i += 2;
 9bc:	bdc5                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 9be:	008b8913          	addi	s2,s7,8
 9c2:	4685                	li	a3,1
 9c4:	4629                	li	a2,10
 9c6:	000bb583          	ld	a1,0(s7)
 9ca:	855a                	mv	a0,s6
 9cc:	dfbff0ef          	jal	7c6 <printint>
        i += 2;
 9d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 9d2:	8bca                	mv	s7,s2
      state = 0;
 9d4:	4981                	li	s3,0
        i += 2;
 9d6:	bdd9                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 9d8:	008b8913          	addi	s2,s7,8
 9dc:	4681                	li	a3,0
 9de:	4629                	li	a2,10
 9e0:	000be583          	lwu	a1,0(s7)
 9e4:	855a                	mv	a0,s6
 9e6:	de1ff0ef          	jal	7c6 <printint>
 9ea:	8bca                	mv	s7,s2
      state = 0;
 9ec:	4981                	li	s3,0
 9ee:	bd7d                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9f0:	008b8913          	addi	s2,s7,8
 9f4:	4681                	li	a3,0
 9f6:	4629                	li	a2,10
 9f8:	000bb583          	ld	a1,0(s7)
 9fc:	855a                	mv	a0,s6
 9fe:	dc9ff0ef          	jal	7c6 <printint>
        i += 1;
 a02:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 a04:	8bca                	mv	s7,s2
      state = 0;
 a06:	4981                	li	s3,0
        i += 1;
 a08:	b555                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a0a:	008b8913          	addi	s2,s7,8
 a0e:	4681                	li	a3,0
 a10:	4629                	li	a2,10
 a12:	000bb583          	ld	a1,0(s7)
 a16:	855a                	mv	a0,s6
 a18:	dafff0ef          	jal	7c6 <printint>
        i += 2;
 a1c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 a1e:	8bca                	mv	s7,s2
      state = 0;
 a20:	4981                	li	s3,0
        i += 2;
 a22:	b569                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 a24:	008b8913          	addi	s2,s7,8
 a28:	4681                	li	a3,0
 a2a:	4641                	li	a2,16
 a2c:	000be583          	lwu	a1,0(s7)
 a30:	855a                	mv	a0,s6
 a32:	d95ff0ef          	jal	7c6 <printint>
 a36:	8bca                	mv	s7,s2
      state = 0;
 a38:	4981                	li	s3,0
 a3a:	bd8d                	j	8ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a3c:	008b8913          	addi	s2,s7,8
 a40:	4681                	li	a3,0
 a42:	4641                	li	a2,16
 a44:	000bb583          	ld	a1,0(s7)
 a48:	855a                	mv	a0,s6
 a4a:	d7dff0ef          	jal	7c6 <printint>
        i += 1;
 a4e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a50:	8bca                	mv	s7,s2
      state = 0;
 a52:	4981                	li	s3,0
        i += 1;
 a54:	bda1                	j	8ac <vprintf+0x4a>
 a56:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 a58:	008b8d13          	addi	s10,s7,8
 a5c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a60:	03000593          	li	a1,48
 a64:	855a                	mv	a0,s6
 a66:	d43ff0ef          	jal	7a8 <putc>
  putc(fd, 'x');
 a6a:	07800593          	li	a1,120
 a6e:	855a                	mv	a0,s6
 a70:	d39ff0ef          	jal	7a8 <putc>
 a74:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a76:	00000b97          	auipc	s7,0x0
 a7a:	5eab8b93          	addi	s7,s7,1514 # 1060 <digits>
 a7e:	03c9d793          	srli	a5,s3,0x3c
 a82:	97de                	add	a5,a5,s7
 a84:	0007c583          	lbu	a1,0(a5)
 a88:	855a                	mv	a0,s6
 a8a:	d1fff0ef          	jal	7a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a8e:	0992                	slli	s3,s3,0x4
 a90:	397d                	addiw	s2,s2,-1
 a92:	fe0916e3          	bnez	s2,a7e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 a96:	8bea                	mv	s7,s10
      state = 0;
 a98:	4981                	li	s3,0
 a9a:	6d02                	ld	s10,0(sp)
 a9c:	bd01                	j	8ac <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 a9e:	008b8913          	addi	s2,s7,8
 aa2:	000bc583          	lbu	a1,0(s7)
 aa6:	855a                	mv	a0,s6
 aa8:	d01ff0ef          	jal	7a8 <putc>
 aac:	8bca                	mv	s7,s2
      state = 0;
 aae:	4981                	li	s3,0
 ab0:	bbf5                	j	8ac <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 ab2:	008b8993          	addi	s3,s7,8
 ab6:	000bb903          	ld	s2,0(s7)
 aba:	00090f63          	beqz	s2,ad8 <vprintf+0x276>
        for(; *s; s++)
 abe:	00094583          	lbu	a1,0(s2)
 ac2:	c195                	beqz	a1,ae6 <vprintf+0x284>
          putc(fd, *s);
 ac4:	855a                	mv	a0,s6
 ac6:	ce3ff0ef          	jal	7a8 <putc>
        for(; *s; s++)
 aca:	0905                	addi	s2,s2,1
 acc:	00094583          	lbu	a1,0(s2)
 ad0:	f9f5                	bnez	a1,ac4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 ad2:	8bce                	mv	s7,s3
      state = 0;
 ad4:	4981                	li	s3,0
 ad6:	bbd9                	j	8ac <vprintf+0x4a>
          s = "(null)";
 ad8:	00000917          	auipc	s2,0x0
 adc:	58090913          	addi	s2,s2,1408 # 1058 <malloc+0x474>
        for(; *s; s++)
 ae0:	02800593          	li	a1,40
 ae4:	b7c5                	j	ac4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 ae6:	8bce                	mv	s7,s3
      state = 0;
 ae8:	4981                	li	s3,0
 aea:	b3c9                	j	8ac <vprintf+0x4a>
 aec:	64a6                	ld	s1,72(sp)
 aee:	79e2                	ld	s3,56(sp)
 af0:	7a42                	ld	s4,48(sp)
 af2:	7aa2                	ld	s5,40(sp)
 af4:	7b02                	ld	s6,32(sp)
 af6:	6be2                	ld	s7,24(sp)
 af8:	6c42                	ld	s8,16(sp)
 afa:	6ca2                	ld	s9,8(sp)
    }
  }
}
 afc:	60e6                	ld	ra,88(sp)
 afe:	6446                	ld	s0,80(sp)
 b00:	6906                	ld	s2,64(sp)
 b02:	6125                	addi	sp,sp,96
 b04:	8082                	ret

0000000000000b06 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b06:	715d                	addi	sp,sp,-80
 b08:	ec06                	sd	ra,24(sp)
 b0a:	e822                	sd	s0,16(sp)
 b0c:	1000                	addi	s0,sp,32
 b0e:	e010                	sd	a2,0(s0)
 b10:	e414                	sd	a3,8(s0)
 b12:	e818                	sd	a4,16(s0)
 b14:	ec1c                	sd	a5,24(s0)
 b16:	03043023          	sd	a6,32(s0)
 b1a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b1e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b22:	8622                	mv	a2,s0
 b24:	d3fff0ef          	jal	862 <vprintf>
}
 b28:	60e2                	ld	ra,24(sp)
 b2a:	6442                	ld	s0,16(sp)
 b2c:	6161                	addi	sp,sp,80
 b2e:	8082                	ret

0000000000000b30 <printf>:

void
printf(const char *fmt, ...)
{
 b30:	711d                	addi	sp,sp,-96
 b32:	ec06                	sd	ra,24(sp)
 b34:	e822                	sd	s0,16(sp)
 b36:	1000                	addi	s0,sp,32
 b38:	e40c                	sd	a1,8(s0)
 b3a:	e810                	sd	a2,16(s0)
 b3c:	ec14                	sd	a3,24(s0)
 b3e:	f018                	sd	a4,32(s0)
 b40:	f41c                	sd	a5,40(s0)
 b42:	03043823          	sd	a6,48(s0)
 b46:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b4a:	00840613          	addi	a2,s0,8
 b4e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b52:	85aa                	mv	a1,a0
 b54:	4505                	li	a0,1
 b56:	d0dff0ef          	jal	862 <vprintf>
}
 b5a:	60e2                	ld	ra,24(sp)
 b5c:	6442                	ld	s0,16(sp)
 b5e:	6125                	addi	sp,sp,96
 b60:	8082                	ret

0000000000000b62 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b62:	1141                	addi	sp,sp,-16
 b64:	e422                	sd	s0,8(sp)
 b66:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b68:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b6c:	00001797          	auipc	a5,0x1
 b70:	4947b783          	ld	a5,1172(a5) # 2000 <freep>
 b74:	a02d                	j	b9e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b76:	4618                	lw	a4,8(a2)
 b78:	9f2d                	addw	a4,a4,a1
 b7a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b7e:	6398                	ld	a4,0(a5)
 b80:	6310                	ld	a2,0(a4)
 b82:	a83d                	j	bc0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b84:	ff852703          	lw	a4,-8(a0)
 b88:	9f31                	addw	a4,a4,a2
 b8a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b8c:	ff053683          	ld	a3,-16(a0)
 b90:	a091                	j	bd4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b92:	6398                	ld	a4,0(a5)
 b94:	00e7e463          	bltu	a5,a4,b9c <free+0x3a>
 b98:	00e6ea63          	bltu	a3,a4,bac <free+0x4a>
{
 b9c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b9e:	fed7fae3          	bgeu	a5,a3,b92 <free+0x30>
 ba2:	6398                	ld	a4,0(a5)
 ba4:	00e6e463          	bltu	a3,a4,bac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ba8:	fee7eae3          	bltu	a5,a4,b9c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 bac:	ff852583          	lw	a1,-8(a0)
 bb0:	6390                	ld	a2,0(a5)
 bb2:	02059813          	slli	a6,a1,0x20
 bb6:	01c85713          	srli	a4,a6,0x1c
 bba:	9736                	add	a4,a4,a3
 bbc:	fae60de3          	beq	a2,a4,b76 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 bc0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 bc4:	4790                	lw	a2,8(a5)
 bc6:	02061593          	slli	a1,a2,0x20
 bca:	01c5d713          	srli	a4,a1,0x1c
 bce:	973e                	add	a4,a4,a5
 bd0:	fae68ae3          	beq	a3,a4,b84 <free+0x22>
    p->s.ptr = bp->s.ptr;
 bd4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bd6:	00001717          	auipc	a4,0x1
 bda:	42f73523          	sd	a5,1066(a4) # 2000 <freep>
}
 bde:	6422                	ld	s0,8(sp)
 be0:	0141                	addi	sp,sp,16
 be2:	8082                	ret

0000000000000be4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 be4:	7139                	addi	sp,sp,-64
 be6:	fc06                	sd	ra,56(sp)
 be8:	f822                	sd	s0,48(sp)
 bea:	f426                	sd	s1,40(sp)
 bec:	ec4e                	sd	s3,24(sp)
 bee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bf0:	02051493          	slli	s1,a0,0x20
 bf4:	9081                	srli	s1,s1,0x20
 bf6:	04bd                	addi	s1,s1,15
 bf8:	8091                	srli	s1,s1,0x4
 bfa:	0014899b          	addiw	s3,s1,1
 bfe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c00:	00001517          	auipc	a0,0x1
 c04:	40053503          	ld	a0,1024(a0) # 2000 <freep>
 c08:	c915                	beqz	a0,c3c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c0c:	4798                	lw	a4,8(a5)
 c0e:	08977a63          	bgeu	a4,s1,ca2 <malloc+0xbe>
 c12:	f04a                	sd	s2,32(sp)
 c14:	e852                	sd	s4,16(sp)
 c16:	e456                	sd	s5,8(sp)
 c18:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 c1a:	8a4e                	mv	s4,s3
 c1c:	0009871b          	sext.w	a4,s3
 c20:	6685                	lui	a3,0x1
 c22:	00d77363          	bgeu	a4,a3,c28 <malloc+0x44>
 c26:	6a05                	lui	s4,0x1
 c28:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c2c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c30:	00001917          	auipc	s2,0x1
 c34:	3d090913          	addi	s2,s2,976 # 2000 <freep>
  if(p == SBRK_ERROR)
 c38:	5afd                	li	s5,-1
 c3a:	a081                	j	c7a <malloc+0x96>
 c3c:	f04a                	sd	s2,32(sp)
 c3e:	e852                	sd	s4,16(sp)
 c40:	e456                	sd	s5,8(sp)
 c42:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c44:	00001797          	auipc	a5,0x1
 c48:	3cc78793          	addi	a5,a5,972 # 2010 <base>
 c4c:	00001717          	auipc	a4,0x1
 c50:	3af73a23          	sd	a5,948(a4) # 2000 <freep>
 c54:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c56:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c5a:	b7c1                	j	c1a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 c5c:	6398                	ld	a4,0(a5)
 c5e:	e118                	sd	a4,0(a0)
 c60:	a8a9                	j	cba <malloc+0xd6>
  hp->s.size = nu;
 c62:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c66:	0541                	addi	a0,a0,16
 c68:	efbff0ef          	jal	b62 <free>
  return freep;
 c6c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c70:	c12d                	beqz	a0,cd2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c72:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c74:	4798                	lw	a4,8(a5)
 c76:	02977263          	bgeu	a4,s1,c9a <malloc+0xb6>
    if(p == freep)
 c7a:	00093703          	ld	a4,0(s2)
 c7e:	853e                	mv	a0,a5
 c80:	fef719e3          	bne	a4,a5,c72 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 c84:	8552                	mv	a0,s4
 c86:	a47ff0ef          	jal	6cc <sbrk>
  if(p == SBRK_ERROR)
 c8a:	fd551ce3          	bne	a0,s5,c62 <malloc+0x7e>
        return 0;
 c8e:	4501                	li	a0,0
 c90:	7902                	ld	s2,32(sp)
 c92:	6a42                	ld	s4,16(sp)
 c94:	6aa2                	ld	s5,8(sp)
 c96:	6b02                	ld	s6,0(sp)
 c98:	a03d                	j	cc6 <malloc+0xe2>
 c9a:	7902                	ld	s2,32(sp)
 c9c:	6a42                	ld	s4,16(sp)
 c9e:	6aa2                	ld	s5,8(sp)
 ca0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ca2:	fae48de3          	beq	s1,a4,c5c <malloc+0x78>
        p->s.size -= nunits;
 ca6:	4137073b          	subw	a4,a4,s3
 caa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cac:	02071693          	slli	a3,a4,0x20
 cb0:	01c6d713          	srli	a4,a3,0x1c
 cb4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 cb6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 cba:	00001717          	auipc	a4,0x1
 cbe:	34a73323          	sd	a0,838(a4) # 2000 <freep>
      return (void*)(p + 1);
 cc2:	01078513          	addi	a0,a5,16
  }
}
 cc6:	70e2                	ld	ra,56(sp)
 cc8:	7442                	ld	s0,48(sp)
 cca:	74a2                	ld	s1,40(sp)
 ccc:	69e2                	ld	s3,24(sp)
 cce:	6121                	addi	sp,sp,64
 cd0:	8082                	ret
 cd2:	7902                	ld	s2,32(sp)
 cd4:	6a42                	ld	s4,16(sp)
 cd6:	6aa2                	ld	s5,8(sp)
 cd8:	6b02                	ld	s6,0(sp)
 cda:	b7f5                	j	cc6 <malloc+0xe2>
