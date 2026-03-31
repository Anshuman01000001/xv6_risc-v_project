
user/_bad_pipe:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <pipe_write>:
    uint nwrite;    // number of bytes written
};

void 
pipe_write(struct bad_pipe *pi, char ch)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    // if(pi->nwrite - pi->nread == PIPESIZE) {
    //     // Pipe is full, cannot write
    //     return;
    // }

    pi->data[pi->nwrite % PIPESIZE] = ch;
   6:	515c                	lw	a5,36(a0)
   8:	01f7f713          	andi	a4,a5,31
   c:	972a                	add	a4,a4,a0
   e:	00b70023          	sb	a1,0(a4)
    pi->nwrite++;
  12:	2785                	addiw	a5,a5,1
  14:	d15c                	sw	a5,36(a0)
}
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <pipe_read>:

int 
pipe_read(struct bad_pipe *pi)
{
  1c:	1141                	addi	sp,sp,-16
  1e:	e422                	sd	s0,8(sp)
  20:	0800                	addi	s0,sp,16
    if(pi->nread == pi->nwrite) {
  22:	511c                	lw	a5,32(a0)
  24:	5158                	lw	a4,36(a0)
  26:	00f70e63          	beq	a4,a5,42 <pipe_read+0x26>
        // Pipe is empty, cannot read
        return -1;
    }

    char ch = pi->data[pi->nread % PIPESIZE];
  2a:	01f7f713          	andi	a4,a5,31
  2e:	972a                	add	a4,a4,a0
  30:	00074703          	lbu	a4,0(a4)
    pi->nread++;
  34:	2785                	addiw	a5,a5,1
  36:	d11c                	sw	a5,32(a0)
    return ch;
  38:	0007051b          	sext.w	a0,a4
}
  3c:	6422                	ld	s0,8(sp)
  3e:	0141                	addi	sp,sp,16
  40:	8082                	ret
        return -1;
  42:	557d                	li	a0,-1
  44:	bfe5                	j	3c <pipe_read+0x20>

0000000000000046 <main>:

int
main(void)
{
  46:	7159                	addi	sp,sp,-112
  48:	f486                	sd	ra,104(sp)
  4a:	f0a2                	sd	s0,96(sp)
  4c:	eca6                	sd	s1,88(sp)
  4e:	e8ca                	sd	s2,80(sp)
  50:	e4ce                	sd	s3,72(sp)
  52:	e0d2                	sd	s4,64(sp)
  54:	fc56                	sd	s5,56(sp)
  56:	f85a                	sd	s6,48(sp)
  58:	1880                	addi	s0,sp,112
    struct bad_pipe pipe;

    char last3[3] = {0,0,0};
    char ch;

    printf("Type text. Enter 'ok?' to stop and display buffer contents.\n\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	94650513          	addi	a0,a0,-1722 # 9a0 <malloc+0x102>
  62:	788000ef          	jal	7ea <printf>

    pipe.nread = 0;
  66:	fa042c23          	sw	zero,-72(s0)
    pipe.nwrite = 0;
  6a:	fa042e23          	sw	zero,-68(s0)
    char last3[3] = {0,0,0};
  6e:	4901                	li	s2,0
  70:	4981                	li	s3,0
        // Check for "ok?" pattern before writing
        last3[0] = last3[1];
        last3[1] = last3[2];
        last3[2] = ch;        

        if(last3[0] == 'o' && last3[1] == 'k' && last3[2] == '?') {
  72:	06f00a13          	li	s4,111
  76:	06b00a93          	li	s5,107
  7a:	03f00b13          	li	s6,63
    while(read(0, &ch, 1) == 1){
  7e:	a801                	j	8e <main+0x48>
            // Remove the 'o' and 'k' that were already written
            pipe.nwrite -= 2;
            break;
        }else{
            pipe_write(&pipe, ch);
  80:	85a6                	mv	a1,s1
  82:	f9840513          	addi	a0,s0,-104
  86:	f7bff0ef          	jal	0 <pipe_write>
        last3[1] = last3[2];
  8a:	89ca                	mv	s3,s2
        last3[2] = ch;        
  8c:	8926                	mv	s2,s1
    while(read(0, &ch, 1) == 1){
  8e:	4605                	li	a2,1
  90:	f9740593          	addi	a1,s0,-105
  94:	4501                	li	a0,0
  96:	33c000ef          	jal	3d2 <read>
  9a:	4785                	li	a5,1
  9c:	00f51f63          	bne	a0,a5,ba <main+0x74>
        last3[2] = ch;        
  a0:	f9744483          	lbu	s1,-105(s0)
        if(last3[0] == 'o' && last3[1] == 'k' && last3[2] == '?') {
  a4:	fd499ee3          	bne	s3,s4,80 <main+0x3a>
  a8:	fd591ce3          	bne	s2,s5,80 <main+0x3a>
  ac:	fd649ae3          	bne	s1,s6,80 <main+0x3a>
            pipe.nwrite -= 2;
  b0:	fbc42783          	lw	a5,-68(s0)
  b4:	37f9                	addiw	a5,a5,-2
  b6:	faf42e23          	sw	a5,-68(s0)
        }
    }

    if(pipe.nwrite - pipe.nread == PIPESIZE) {
  ba:	fbc42703          	lw	a4,-68(s0)
  be:	02000793          	li	a5,32
  c2:	00f70e63          	beq	a4,a5,de <main+0x98>
        printf("\nPipe overflow occurred!\n");
        pipe.nread = pipe.nwrite - PIPESIZE; // Adjust read pointer to avoid overflow
    }

    printf("\nBuffer contents:\n");
  c6:	00001517          	auipc	a0,0x1
  ca:	94250513          	addi	a0,a0,-1726 # a08 <malloc+0x16a>
  ce:	71c000ef          	jal	7ea <printf>
    int out_ch;
    while((out_ch = pipe_read(&pipe)) != -1) {
  d2:	54fd                	li	s1,-1
        printf("%c", out_ch);
  d4:	00001917          	auipc	s2,0x1
  d8:	94c90913          	addi	s2,s2,-1716 # a20 <malloc+0x182>
    while((out_ch = pipe_read(&pipe)) != -1) {
  dc:	a829                	j	f6 <main+0xb0>
        printf("\nPipe overflow occurred!\n");
  de:	00001517          	auipc	a0,0x1
  e2:	90a50513          	addi	a0,a0,-1782 # 9e8 <malloc+0x14a>
  e6:	704000ef          	jal	7ea <printf>
        pipe.nread = pipe.nwrite - PIPESIZE; // Adjust read pointer to avoid overflow
  ea:	fa042c23          	sw	zero,-72(s0)
  ee:	bfe1                	j	c6 <main+0x80>
        printf("%c", out_ch);
  f0:	854a                	mv	a0,s2
  f2:	6f8000ef          	jal	7ea <printf>
    while((out_ch = pipe_read(&pipe)) != -1) {
  f6:	f9840513          	addi	a0,s0,-104
  fa:	f23ff0ef          	jal	1c <pipe_read>
  fe:	85aa                	mv	a1,a0
 100:	fe9518e3          	bne	a0,s1,f0 <main+0xaa>
    }
    printf("\n");
 104:	00001517          	auipc	a0,0x1
 108:	92450513          	addi	a0,a0,-1756 # a28 <malloc+0x18a>
 10c:	6de000ef          	jal	7ea <printf>
}
 110:	4501                	li	a0,0
 112:	70a6                	ld	ra,104(sp)
 114:	7406                	ld	s0,96(sp)
 116:	64e6                	ld	s1,88(sp)
 118:	6946                	ld	s2,80(sp)
 11a:	69a6                	ld	s3,72(sp)
 11c:	6a06                	ld	s4,64(sp)
 11e:	7ae2                	ld	s5,56(sp)
 120:	7b42                	ld	s6,48(sp)
 122:	6165                	addi	sp,sp,112
 124:	8082                	ret

0000000000000126 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 12e:	f19ff0ef          	jal	46 <main>
  exit(r);
 132:	288000ef          	jal	3ba <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13c:	87aa                	mv	a5,a0
 13e:	0585                	addi	a1,a1,1
 140:	0785                	addi	a5,a5,1
 142:	fff5c703          	lbu	a4,-1(a1)
 146:	fee78fa3          	sb	a4,-1(a5)
 14a:	fb75                	bnez	a4,13e <strcpy+0x8>
    ;
  return os;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x1e>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x1e>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 184:	00054783          	lbu	a5,0(a0)
 188:	cf91                	beqz	a5,1a4 <strlen+0x26>
 18a:	0505                	addi	a0,a0,1
 18c:	87aa                	mv	a5,a0
 18e:	86be                	mv	a3,a5
 190:	0785                	addi	a5,a5,1
 192:	fff7c703          	lbu	a4,-1(a5)
 196:	ff65                	bnez	a4,18e <strlen+0x10>
 198:	40a6853b          	subw	a0,a3,a0
 19c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret
  for(n = 0; s[n]; n++)
 1a4:	4501                	li	a0,0
 1a6:	bfe5                	j	19e <strlen+0x20>

00000000000001a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ae:	ca19                	beqz	a2,1c4 <memset+0x1c>
 1b0:	87aa                	mv	a5,a0
 1b2:	1602                	slli	a2,a2,0x20
 1b4:	9201                	srli	a2,a2,0x20
 1b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1be:	0785                	addi	a5,a5,1
 1c0:	fee79de3          	bne	a5,a4,1ba <memset+0x12>
  }
  return dst;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cb99                	beqz	a5,1ea <strchr+0x20>
    if(*s == c)
 1d6:	00f58763          	beq	a1,a5,1e4 <strchr+0x1a>
  for(; *s; s++)
 1da:	0505                	addi	a0,a0,1
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	fbfd                	bnez	a5,1d6 <strchr+0xc>
      return (char*)s;
  return 0;
 1e2:	4501                	li	a0,0
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  return 0;
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <strchr+0x1a>

00000000000001ee <gets>:

char*
gets(char *buf, int max)
{
 1ee:	711d                	addi	sp,sp,-96
 1f0:	ec86                	sd	ra,88(sp)
 1f2:	e8a2                	sd	s0,80(sp)
 1f4:	e4a6                	sd	s1,72(sp)
 1f6:	e0ca                	sd	s2,64(sp)
 1f8:	fc4e                	sd	s3,56(sp)
 1fa:	f852                	sd	s4,48(sp)
 1fc:	f456                	sd	s5,40(sp)
 1fe:	f05a                	sd	s6,32(sp)
 200:	ec5e                	sd	s7,24(sp)
 202:	1080                	addi	s0,sp,96
 204:	8baa                	mv	s7,a0
 206:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	892a                	mv	s2,a0
 20a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20c:	4aa9                	li	s5,10
 20e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 210:	89a6                	mv	s3,s1
 212:	2485                	addiw	s1,s1,1
 214:	0344d663          	bge	s1,s4,240 <gets+0x52>
    cc = read(0, &c, 1);
 218:	4605                	li	a2,1
 21a:	faf40593          	addi	a1,s0,-81
 21e:	4501                	li	a0,0
 220:	1b2000ef          	jal	3d2 <read>
    if(cc < 1)
 224:	00a05e63          	blez	a0,240 <gets+0x52>
    buf[i++] = c;
 228:	faf44783          	lbu	a5,-81(s0)
 22c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 230:	01578763          	beq	a5,s5,23e <gets+0x50>
 234:	0905                	addi	s2,s2,1
 236:	fd679de3          	bne	a5,s6,210 <gets+0x22>
    buf[i++] = c;
 23a:	89a6                	mv	s3,s1
 23c:	a011                	j	240 <gets+0x52>
 23e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 240:	99de                	add	s3,s3,s7
 242:	00098023          	sb	zero,0(s3)
  return buf;
}
 246:	855e                	mv	a0,s7
 248:	60e6                	ld	ra,88(sp)
 24a:	6446                	ld	s0,80(sp)
 24c:	64a6                	ld	s1,72(sp)
 24e:	6906                	ld	s2,64(sp)
 250:	79e2                	ld	s3,56(sp)
 252:	7a42                	ld	s4,48(sp)
 254:	7aa2                	ld	s5,40(sp)
 256:	7b02                	ld	s6,32(sp)
 258:	6be2                	ld	s7,24(sp)
 25a:	6125                	addi	sp,sp,96
 25c:	8082                	ret

000000000000025e <stat>:

int
stat(const char *n, struct stat *st)
{
 25e:	1101                	addi	sp,sp,-32
 260:	ec06                	sd	ra,24(sp)
 262:	e822                	sd	s0,16(sp)
 264:	e04a                	sd	s2,0(sp)
 266:	1000                	addi	s0,sp,32
 268:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26a:	4581                	li	a1,0
 26c:	18e000ef          	jal	3fa <open>
  if(fd < 0)
 270:	02054263          	bltz	a0,294 <stat+0x36>
 274:	e426                	sd	s1,8(sp)
 276:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 278:	85ca                	mv	a1,s2
 27a:	198000ef          	jal	412 <fstat>
 27e:	892a                	mv	s2,a0
  close(fd);
 280:	8526                	mv	a0,s1
 282:	160000ef          	jal	3e2 <close>
  return r;
 286:	64a2                	ld	s1,8(sp)
}
 288:	854a                	mv	a0,s2
 28a:	60e2                	ld	ra,24(sp)
 28c:	6442                	ld	s0,16(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	addi	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfcd                	j	288 <stat+0x2a>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	addi	a4,a4,1
 2b6:	0025179b          	slliw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	slliw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addiw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57463          	bgeu	a0,a1,30e <memmove+0x2e>
    while(n-- > 0)
 2ea:	00c05f63          	blez	a2,308 <memmove+0x28>
 2ee:	1602                	slli	a2,a2,0x20
 2f0:	9201                	srli	a2,a2,0x20
 2f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f8:	0585                	addi	a1,a1,1
 2fa:	0705                	addi	a4,a4,1
 2fc:	fff5c683          	lbu	a3,-1(a1)
 300:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 304:	fef71ae3          	bne	a4,a5,2f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 314:	fec05ae3          	blez	a2,308 <memmove+0x28>
 318:	fff6079b          	addiw	a5,a2,-1
 31c:	1782                	slli	a5,a5,0x20
 31e:	9381                	srli	a5,a5,0x20
 320:	fff7c793          	not	a5,a5
 324:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 326:	15fd                	addi	a1,a1,-1
 328:	177d                	addi	a4,a4,-1
 32a:	0005c683          	lbu	a3,0(a1)
 32e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x46>
 336:	bfc9                	j	308 <memmove+0x28>

0000000000000338 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	ca05                	beqz	a2,36e <memcmp+0x36>
 340:	fff6069b          	addiw	a3,a2,-1
 344:	1682                	slli	a3,a3,0x20
 346:	9281                	srli	a3,a3,0x20
 348:	0685                	addi	a3,a3,1
 34a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34c:	00054783          	lbu	a5,0(a0)
 350:	0005c703          	lbu	a4,0(a1)
 354:	00e79863          	bne	a5,a4,364 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 358:	0505                	addi	a0,a0,1
    p2++;
 35a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 35c:	fed518e3          	bne	a0,a3,34c <memcmp+0x14>
  }
  return 0;
 360:	4501                	li	a0,0
 362:	a019                	j	368 <memcmp+0x30>
      return *p1 - *p2;
 364:	40e7853b          	subw	a0,a5,a4
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfe5                	j	368 <memcmp+0x30>

0000000000000372 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 37a:	f67ff0ef          	jal	2e0 <memmove>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <sbrk>:

char *
sbrk(int n) {
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 38e:	4585                	li	a1,1
 390:	0b2000ef          	jal	442 <sys_sbrk>
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret

000000000000039c <sbrklazy>:

char *
sbrklazy(int n) {
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3a4:	4589                	li	a1,2
 3a6:	09c000ef          	jal	442 <sys_sbrk>
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret

00000000000003b2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b2:	4885                	li	a7,1
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ba:	4889                	li	a7,2
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c2:	488d                	li	a7,3
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ca:	4891                	li	a7,4
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <read>:
.global read
read:
 li a7, SYS_read
 3d2:	4895                	li	a7,5
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <write>:
.global write
write:
 li a7, SYS_write
 3da:	48c1                	li	a7,16
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <close>:
.global close
close:
 li a7, SYS_close
 3e2:	48d5                	li	a7,21
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ea:	4899                	li	a7,6
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f2:	489d                	li	a7,7
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <open>:
.global open
open:
 li a7, SYS_open
 3fa:	48bd                	li	a7,15
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 402:	48c5                	li	a7,17
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40a:	48c9                	li	a7,18
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 412:	48a1                	li	a7,8
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <link>:
.global link
link:
 li a7, SYS_link
 41a:	48cd                	li	a7,19
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 422:	48d1                	li	a7,20
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42a:	48a5                	li	a7,9
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <dup>:
.global dup
dup:
 li a7, SYS_dup
 432:	48a9                	li	a7,10
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43a:	48ad                	li	a7,11
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 442:	48b1                	li	a7,12
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <pause>:
.global pause
pause:
 li a7, SYS_pause
 44a:	48b5                	li	a7,13
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 452:	48b9                	li	a7,14
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <kps>:
.global kps
kps:
 li a7, SYS_kps
 45a:	48d9                	li	a7,22
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 462:	1101                	addi	sp,sp,-32
 464:	ec06                	sd	ra,24(sp)
 466:	e822                	sd	s0,16(sp)
 468:	1000                	addi	s0,sp,32
 46a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 46e:	4605                	li	a2,1
 470:	fef40593          	addi	a1,s0,-17
 474:	f67ff0ef          	jal	3da <write>
}
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	6105                	addi	sp,sp,32
 47e:	8082                	ret

0000000000000480 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 480:	715d                	addi	sp,sp,-80
 482:	e486                	sd	ra,72(sp)
 484:	e0a2                	sd	s0,64(sp)
 486:	f84a                	sd	s2,48(sp)
 488:	0880                	addi	s0,sp,80
 48a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 48c:	c299                	beqz	a3,492 <printint+0x12>
 48e:	0805c363          	bltz	a1,514 <printint+0x94>
  neg = 0;
 492:	4881                	li	a7,0
 494:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 498:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 49a:	00000517          	auipc	a0,0x0
 49e:	59e50513          	addi	a0,a0,1438 # a38 <digits>
 4a2:	883e                	mv	a6,a5
 4a4:	2785                	addiw	a5,a5,1
 4a6:	02c5f733          	remu	a4,a1,a2
 4aa:	972a                	add	a4,a4,a0
 4ac:	00074703          	lbu	a4,0(a4)
 4b0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4b4:	872e                	mv	a4,a1
 4b6:	02c5d5b3          	divu	a1,a1,a2
 4ba:	0685                	addi	a3,a3,1
 4bc:	fec773e3          	bgeu	a4,a2,4a2 <printint+0x22>
  if(neg)
 4c0:	00088b63          	beqz	a7,4d6 <printint+0x56>
    buf[i++] = '-';
 4c4:	fd078793          	addi	a5,a5,-48
 4c8:	97a2                	add	a5,a5,s0
 4ca:	02d00713          	li	a4,45
 4ce:	fee78423          	sb	a4,-24(a5)
 4d2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4d6:	02f05a63          	blez	a5,50a <printint+0x8a>
 4da:	fc26                	sd	s1,56(sp)
 4dc:	f44e                	sd	s3,40(sp)
 4de:	fb840713          	addi	a4,s0,-72
 4e2:	00f704b3          	add	s1,a4,a5
 4e6:	fff70993          	addi	s3,a4,-1
 4ea:	99be                	add	s3,s3,a5
 4ec:	37fd                	addiw	a5,a5,-1
 4ee:	1782                	slli	a5,a5,0x20
 4f0:	9381                	srli	a5,a5,0x20
 4f2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4f6:	fff4c583          	lbu	a1,-1(s1)
 4fa:	854a                	mv	a0,s2
 4fc:	f67ff0ef          	jal	462 <putc>
  while(--i >= 0)
 500:	14fd                	addi	s1,s1,-1
 502:	ff349ae3          	bne	s1,s3,4f6 <printint+0x76>
 506:	74e2                	ld	s1,56(sp)
 508:	79a2                	ld	s3,40(sp)
}
 50a:	60a6                	ld	ra,72(sp)
 50c:	6406                	ld	s0,64(sp)
 50e:	7942                	ld	s2,48(sp)
 510:	6161                	addi	sp,sp,80
 512:	8082                	ret
    x = -xx;
 514:	40b005b3          	neg	a1,a1
    neg = 1;
 518:	4885                	li	a7,1
    x = -xx;
 51a:	bfad                	j	494 <printint+0x14>

000000000000051c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 51c:	711d                	addi	sp,sp,-96
 51e:	ec86                	sd	ra,88(sp)
 520:	e8a2                	sd	s0,80(sp)
 522:	e0ca                	sd	s2,64(sp)
 524:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 526:	0005c903          	lbu	s2,0(a1)
 52a:	28090663          	beqz	s2,7b6 <vprintf+0x29a>
 52e:	e4a6                	sd	s1,72(sp)
 530:	fc4e                	sd	s3,56(sp)
 532:	f852                	sd	s4,48(sp)
 534:	f456                	sd	s5,40(sp)
 536:	f05a                	sd	s6,32(sp)
 538:	ec5e                	sd	s7,24(sp)
 53a:	e862                	sd	s8,16(sp)
 53c:	e466                	sd	s9,8(sp)
 53e:	8b2a                	mv	s6,a0
 540:	8a2e                	mv	s4,a1
 542:	8bb2                	mv	s7,a2
  state = 0;
 544:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 546:	4481                	li	s1,0
 548:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 54a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 54e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 552:	06c00c93          	li	s9,108
 556:	a005                	j	576 <vprintf+0x5a>
        putc(fd, c0);
 558:	85ca                	mv	a1,s2
 55a:	855a                	mv	a0,s6
 55c:	f07ff0ef          	jal	462 <putc>
 560:	a019                	j	566 <vprintf+0x4a>
    } else if(state == '%'){
 562:	03598263          	beq	s3,s5,586 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 566:	2485                	addiw	s1,s1,1
 568:	8726                	mv	a4,s1
 56a:	009a07b3          	add	a5,s4,s1
 56e:	0007c903          	lbu	s2,0(a5)
 572:	22090a63          	beqz	s2,7a6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 576:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57a:	fe0994e3          	bnez	s3,562 <vprintf+0x46>
      if(c0 == '%'){
 57e:	fd579de3          	bne	a5,s5,558 <vprintf+0x3c>
        state = '%';
 582:	89be                	mv	s3,a5
 584:	b7cd                	j	566 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 586:	00ea06b3          	add	a3,s4,a4
 58a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 58e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 590:	c681                	beqz	a3,598 <vprintf+0x7c>
 592:	9752                	add	a4,a4,s4
 594:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 598:	05878363          	beq	a5,s8,5de <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 59c:	05978d63          	beq	a5,s9,5f6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a0:	07500713          	li	a4,117
 5a4:	0ee78763          	beq	a5,a4,692 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a8:	07800713          	li	a4,120
 5ac:	12e78963          	beq	a5,a4,6de <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5b0:	07000713          	li	a4,112
 5b4:	14e78e63          	beq	a5,a4,710 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b8:	06300713          	li	a4,99
 5bc:	18e78e63          	beq	a5,a4,758 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5c0:	07300713          	li	a4,115
 5c4:	1ae78463          	beq	a5,a4,76c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c8:	02500713          	li	a4,37
 5cc:	04e79563          	bne	a5,a4,616 <vprintf+0xfa>
        putc(fd, '%');
 5d0:	02500593          	li	a1,37
 5d4:	855a                	mv	a0,s6
 5d6:	e8dff0ef          	jal	462 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b769                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e95ff0ef          	jal	480 <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bf8d                	j	566 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5f6:	06400793          	li	a5,100
 5fa:	02f68963          	beq	a3,a5,62c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fe:	06c00793          	li	a5,108
 602:	04f68263          	beq	a3,a5,646 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 606:	07500793          	li	a5,117
 60a:	0af68063          	beq	a3,a5,6aa <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 60e:	07800793          	li	a5,120
 612:	0ef68263          	beq	a3,a5,6f6 <vprintf+0x1da>
        putc(fd, '%');
 616:	02500593          	li	a1,37
 61a:	855a                	mv	a0,s6
 61c:	e47ff0ef          	jal	462 <putc>
        putc(fd, c0);
 620:	85ca                	mv	a1,s2
 622:	855a                	mv	a0,s6
 624:	e3fff0ef          	jal	462 <putc>
      state = 0;
 628:	4981                	li	s3,0
 62a:	bf35                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	008b8913          	addi	s2,s7,8
 630:	4685                	li	a3,1
 632:	4629                	li	a2,10
 634:	000bb583          	ld	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	e47ff0ef          	jal	480 <printint>
        i += 1;
 63e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	8bca                	mv	s7,s2
      state = 0;
 642:	4981                	li	s3,0
        i += 1;
 644:	b70d                	j	566 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 646:	06400793          	li	a5,100
 64a:	02f60763          	beq	a2,a5,678 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 64e:	07500793          	li	a5,117
 652:	06f60963          	beq	a2,a5,6c4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 656:	07800793          	li	a5,120
 65a:	faf61ee3          	bne	a2,a5,616 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4641                	li	a2,16
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e15ff0ef          	jal	480 <printint>
        i += 2;
 670:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	bdc5                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 678:	008b8913          	addi	s2,s7,8
 67c:	4685                	li	a3,1
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	dfbff0ef          	jal	480 <printint>
        i += 2;
 68a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 2;
 690:	bdd9                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 692:	008b8913          	addi	s2,s7,8
 696:	4681                	li	a3,0
 698:	4629                	li	a2,10
 69a:	000be583          	lwu	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	de1ff0ef          	jal	480 <printint>
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bd7d                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	dc9ff0ef          	jal	480 <printint>
        i += 1;
 6bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 1;
 6c2:	b555                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4629                	li	a2,10
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	dafff0ef          	jal	480 <printint>
        i += 2;
 6d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
        i += 2;
 6dc:	b569                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4681                	li	a3,0
 6e4:	4641                	li	a2,16
 6e6:	000be583          	lwu	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	d95ff0ef          	jal	480 <printint>
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd8d                	j	566 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4641                	li	a2,16
 6fe:	000bb583          	ld	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	d7dff0ef          	jal	480 <printint>
        i += 1;
 708:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
        i += 1;
 70e:	bda1                	j	566 <vprintf+0x4a>
 710:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 712:	008b8d13          	addi	s10,s7,8
 716:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 71a:	03000593          	li	a1,48
 71e:	855a                	mv	a0,s6
 720:	d43ff0ef          	jal	462 <putc>
  putc(fd, 'x');
 724:	07800593          	li	a1,120
 728:	855a                	mv	a0,s6
 72a:	d39ff0ef          	jal	462 <putc>
 72e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 730:	00000b97          	auipc	s7,0x0
 734:	308b8b93          	addi	s7,s7,776 # a38 <digits>
 738:	03c9d793          	srli	a5,s3,0x3c
 73c:	97de                	add	a5,a5,s7
 73e:	0007c583          	lbu	a1,0(a5)
 742:	855a                	mv	a0,s6
 744:	d1fff0ef          	jal	462 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 748:	0992                	slli	s3,s3,0x4
 74a:	397d                	addiw	s2,s2,-1
 74c:	fe0916e3          	bnez	s2,738 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 750:	8bea                	mv	s7,s10
      state = 0;
 752:	4981                	li	s3,0
 754:	6d02                	ld	s10,0(sp)
 756:	bd01                	j	566 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 758:	008b8913          	addi	s2,s7,8
 75c:	000bc583          	lbu	a1,0(s7)
 760:	855a                	mv	a0,s6
 762:	d01ff0ef          	jal	462 <putc>
 766:	8bca                	mv	s7,s2
      state = 0;
 768:	4981                	li	s3,0
 76a:	bbf5                	j	566 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 76c:	008b8993          	addi	s3,s7,8
 770:	000bb903          	ld	s2,0(s7)
 774:	00090f63          	beqz	s2,792 <vprintf+0x276>
        for(; *s; s++)
 778:	00094583          	lbu	a1,0(s2)
 77c:	c195                	beqz	a1,7a0 <vprintf+0x284>
          putc(fd, *s);
 77e:	855a                	mv	a0,s6
 780:	ce3ff0ef          	jal	462 <putc>
        for(; *s; s++)
 784:	0905                	addi	s2,s2,1
 786:	00094583          	lbu	a1,0(s2)
 78a:	f9f5                	bnez	a1,77e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 78c:	8bce                	mv	s7,s3
      state = 0;
 78e:	4981                	li	s3,0
 790:	bbd9                	j	566 <vprintf+0x4a>
          s = "(null)";
 792:	00000917          	auipc	s2,0x0
 796:	29e90913          	addi	s2,s2,670 # a30 <malloc+0x192>
        for(; *s; s++)
 79a:	02800593          	li	a1,40
 79e:	b7c5                	j	77e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a0:	8bce                	mv	s7,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b3c9                	j	566 <vprintf+0x4a>
 7a6:	64a6                	ld	s1,72(sp)
 7a8:	79e2                	ld	s3,56(sp)
 7aa:	7a42                	ld	s4,48(sp)
 7ac:	7aa2                	ld	s5,40(sp)
 7ae:	7b02                	ld	s6,32(sp)
 7b0:	6be2                	ld	s7,24(sp)
 7b2:	6c42                	ld	s8,16(sp)
 7b4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7b6:	60e6                	ld	ra,88(sp)
 7b8:	6446                	ld	s0,80(sp)
 7ba:	6906                	ld	s2,64(sp)
 7bc:	6125                	addi	sp,sp,96
 7be:	8082                	ret

00000000000007c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c0:	715d                	addi	sp,sp,-80
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	1000                	addi	s0,sp,32
 7c8:	e010                	sd	a2,0(s0)
 7ca:	e414                	sd	a3,8(s0)
 7cc:	e818                	sd	a4,16(s0)
 7ce:	ec1c                	sd	a5,24(s0)
 7d0:	03043023          	sd	a6,32(s0)
 7d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7dc:	8622                	mv	a2,s0
 7de:	d3fff0ef          	jal	51c <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6161                	addi	sp,sp,80
 7e8:	8082                	ret

00000000000007ea <printf>:

void
printf(const char *fmt, ...)
{
 7ea:	711d                	addi	sp,sp,-96
 7ec:	ec06                	sd	ra,24(sp)
 7ee:	e822                	sd	s0,16(sp)
 7f0:	1000                	addi	s0,sp,32
 7f2:	e40c                	sd	a1,8(s0)
 7f4:	e810                	sd	a2,16(s0)
 7f6:	ec14                	sd	a3,24(s0)
 7f8:	f018                	sd	a4,32(s0)
 7fa:	f41c                	sd	a5,40(s0)
 7fc:	03043823          	sd	a6,48(s0)
 800:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	00840613          	addi	a2,s0,8
 808:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80c:	85aa                	mv	a1,a0
 80e:	4505                	li	a0,1
 810:	d0dff0ef          	jal	51c <vprintf>
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	6125                	addi	sp,sp,96
 81a:	8082                	ret

000000000000081c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81c:	1141                	addi	sp,sp,-16
 81e:	e422                	sd	s0,8(sp)
 820:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 822:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 826:	00000797          	auipc	a5,0x0
 82a:	7da7b783          	ld	a5,2010(a5) # 1000 <freep>
 82e:	a02d                	j	858 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 830:	4618                	lw	a4,8(a2)
 832:	9f2d                	addw	a4,a4,a1
 834:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	6398                	ld	a4,0(a5)
 83a:	6310                	ld	a2,0(a4)
 83c:	a83d                	j	87a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83e:	ff852703          	lw	a4,-8(a0)
 842:	9f31                	addw	a4,a4,a2
 844:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 846:	ff053683          	ld	a3,-16(a0)
 84a:	a091                	j	88e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	6398                	ld	a4,0(a5)
 84e:	00e7e463          	bltu	a5,a4,856 <free+0x3a>
 852:	00e6ea63          	bltu	a3,a4,866 <free+0x4a>
{
 856:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 858:	fed7fae3          	bgeu	a5,a3,84c <free+0x30>
 85c:	6398                	ld	a4,0(a5)
 85e:	00e6e463          	bltu	a3,a4,866 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	fee7eae3          	bltu	a5,a4,856 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 866:	ff852583          	lw	a1,-8(a0)
 86a:	6390                	ld	a2,0(a5)
 86c:	02059813          	slli	a6,a1,0x20
 870:	01c85713          	srli	a4,a6,0x1c
 874:	9736                	add	a4,a4,a3
 876:	fae60de3          	beq	a2,a4,830 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 87a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87e:	4790                	lw	a2,8(a5)
 880:	02061593          	slli	a1,a2,0x20
 884:	01c5d713          	srli	a4,a1,0x1c
 888:	973e                	add	a4,a4,a5
 88a:	fae68ae3          	beq	a3,a4,83e <free+0x22>
    p->s.ptr = bp->s.ptr;
 88e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 890:	00000717          	auipc	a4,0x0
 894:	76f73823          	sd	a5,1904(a4) # 1000 <freep>
}
 898:	6422                	ld	s0,8(sp)
 89a:	0141                	addi	sp,sp,16
 89c:	8082                	ret

000000000000089e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89e:	7139                	addi	sp,sp,-64
 8a0:	fc06                	sd	ra,56(sp)
 8a2:	f822                	sd	s0,48(sp)
 8a4:	f426                	sd	s1,40(sp)
 8a6:	ec4e                	sd	s3,24(sp)
 8a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8aa:	02051493          	slli	s1,a0,0x20
 8ae:	9081                	srli	s1,s1,0x20
 8b0:	04bd                	addi	s1,s1,15
 8b2:	8091                	srli	s1,s1,0x4
 8b4:	0014899b          	addiw	s3,s1,1
 8b8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ba:	00000517          	auipc	a0,0x0
 8be:	74653503          	ld	a0,1862(a0) # 1000 <freep>
 8c2:	c915                	beqz	a0,8f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	08977a63          	bgeu	a4,s1,95c <malloc+0xbe>
 8cc:	f04a                	sd	s2,32(sp)
 8ce:	e852                	sd	s4,16(sp)
 8d0:	e456                	sd	s5,8(sp)
 8d2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8d4:	8a4e                	mv	s4,s3
 8d6:	0009871b          	sext.w	a4,s3
 8da:	6685                	lui	a3,0x1
 8dc:	00d77363          	bgeu	a4,a3,8e2 <malloc+0x44>
 8e0:	6a05                	lui	s4,0x1
 8e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ea:	00000917          	auipc	s2,0x0
 8ee:	71690913          	addi	s2,s2,1814 # 1000 <freep>
  if(p == SBRK_ERROR)
 8f2:	5afd                	li	s5,-1
 8f4:	a081                	j	934 <malloc+0x96>
 8f6:	f04a                	sd	s2,32(sp)
 8f8:	e852                	sd	s4,16(sp)
 8fa:	e456                	sd	s5,8(sp)
 8fc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8fe:	00000797          	auipc	a5,0x0
 902:	71278793          	addi	a5,a5,1810 # 1010 <base>
 906:	00000717          	auipc	a4,0x0
 90a:	6ef73d23          	sd	a5,1786(a4) # 1000 <freep>
 90e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 910:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 914:	b7c1                	j	8d4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	a8a9                	j	974 <malloc+0xd6>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	efbff0ef          	jal	81c <free>
  return freep;
 926:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92a:	c12d                	beqz	a0,98c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92e:	4798                	lw	a4,8(a5)
 930:	02977263          	bgeu	a4,s1,954 <malloc+0xb6>
    if(p == freep)
 934:	00093703          	ld	a4,0(s2)
 938:	853e                	mv	a0,a5
 93a:	fef719e3          	bne	a4,a5,92c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 93e:	8552                	mv	a0,s4
 940:	a47ff0ef          	jal	386 <sbrk>
  if(p == SBRK_ERROR)
 944:	fd551ce3          	bne	a0,s5,91c <malloc+0x7e>
        return 0;
 948:	4501                	li	a0,0
 94a:	7902                	ld	s2,32(sp)
 94c:	6a42                	ld	s4,16(sp)
 94e:	6aa2                	ld	s5,8(sp)
 950:	6b02                	ld	s6,0(sp)
 952:	a03d                	j	980 <malloc+0xe2>
 954:	7902                	ld	s2,32(sp)
 956:	6a42                	ld	s4,16(sp)
 958:	6aa2                	ld	s5,8(sp)
 95a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 95c:	fae48de3          	beq	s1,a4,916 <malloc+0x78>
        p->s.size -= nunits;
 960:	4137073b          	subw	a4,a4,s3
 964:	c798                	sw	a4,8(a5)
        p += p->s.size;
 966:	02071693          	slli	a3,a4,0x20
 96a:	01c6d713          	srli	a4,a3,0x1c
 96e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 970:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 974:	00000717          	auipc	a4,0x0
 978:	68a73623          	sd	a0,1676(a4) # 1000 <freep>
      return (void*)(p + 1);
 97c:	01078513          	addi	a0,a5,16
  }
}
 980:	70e2                	ld	ra,56(sp)
 982:	7442                	ld	s0,48(sp)
 984:	74a2                	ld	s1,40(sp)
 986:	69e2                	ld	s3,24(sp)
 988:	6121                	addi	sp,sp,64
 98a:	8082                	ret
 98c:	7902                	ld	s2,32(sp)
 98e:	6a42                	ld	s4,16(sp)
 990:	6aa2                	ld	s5,8(sp)
 992:	6b02                	ld	s6,0(sp)
 994:	b7f5                	j	980 <malloc+0xe2>
