
progmem:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <start>:
   0:	4e000293          	li	t0,1248
   4:	4e000313          	li	t1,1248
   8:	00628863          	beq	t0,t1,18 <clear_bss_done>

0000000c <clear_bss>:
   c:	0002a023          	sw	zero,0(t0)
  10:	00428293          	addi	t0,t0,4
  14:	fe629ce3          	bne	t0,t1,c <clear_bss>

00000018 <clear_bss_done>:
  18:	00002117          	auipc	sp,0x2
  1c:	fe810113          	addi	sp,sp,-24 # 2000 <stack_top>
  20:	0d4000ef          	jal	ra,f4 <main>
  24:	0000006f          	j	24 <clear_bss_done+0xc>

00000028 <uart_putc>:
#define BAUD_RATE 9600

#define BARRIER_UP   10
#define BARRIER_DOWN  0

static void uart_putc(char c) {
  28:	fe010113          	addi	sp,sp,-32
  2c:	00812e23          	sw	s0,28(sp)
  30:	02010413          	addi	s0,sp,32
  34:	00050793          	mv	a5,a0
  38:	fef407a3          	sb	a5,-17(s0)
    while (!(UART_STATUS & UART_STATUS_TX_READY));
  3c:	00000013          	nop
  40:	000207b7          	lui	a5,0x20
  44:	00478793          	addi	a5,a5,4 # 20004 <stack_top+0x1e004>
  48:	0007a783          	lw	a5,0(a5)
  4c:	0017f793          	andi	a5,a5,1
  50:	fe0788e3          	beqz	a5,40 <uart_putc+0x18>
    UART_DATA = c;
  54:	000207b7          	lui	a5,0x20
  58:	00878793          	addi	a5,a5,8 # 20008 <stack_top+0x1e008>
  5c:	fef44703          	lbu	a4,-17(s0)
  60:	00e7a023          	sw	a4,0(a5)
}
  64:	00000013          	nop
  68:	01c12403          	lw	s0,28(sp)
  6c:	02010113          	addi	sp,sp,32
  70:	00008067          	ret

00000074 <uart_puts>:

static void uart_puts(const char *str) {
  74:	fd010113          	addi	sp,sp,-48
  78:	02112623          	sw	ra,44(sp)
  7c:	02812423          	sw	s0,40(sp)
  80:	03010413          	addi	s0,sp,48
  84:	fca42e23          	sw	a0,-36(s0)
    char c;
    while ((c = *str++)) {
  88:	0100006f          	j	98 <uart_puts+0x24>
        uart_putc(c);
  8c:	fef44783          	lbu	a5,-17(s0)
  90:	00078513          	mv	a0,a5
  94:	f95ff0ef          	jal	ra,28 <uart_putc>
    while ((c = *str++)) {
  98:	fdc42783          	lw	a5,-36(s0)
  9c:	00178713          	addi	a4,a5,1
  a0:	fce42e23          	sw	a4,-36(s0)
  a4:	0007c783          	lbu	a5,0(a5)
  a8:	fef407a3          	sb	a5,-17(s0)
  ac:	fef44783          	lbu	a5,-17(s0)
  b0:	fc079ee3          	bnez	a5,8c <uart_puts+0x18>
    }
}
  b4:	00000013          	nop
  b8:	00000013          	nop
  bc:	02c12083          	lw	ra,44(sp)
  c0:	02812403          	lw	s0,40(sp)
  c4:	03010113          	addi	sp,sp,48
  c8:	00008067          	ret

000000cc <rdcycle>:

static inline uint32_t rdcycle(void) {
  cc:	fe010113          	addi	sp,sp,-32
  d0:	00812e23          	sw	s0,28(sp)
  d4:	02010413          	addi	s0,sp,32
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
  d8:	c00027f3          	rdcycle	a5
  dc:	fef42623          	sw	a5,-20(s0)
    return cycle;
  e0:	fec42783          	lw	a5,-20(s0)
}
  e4:	00078513          	mv	a0,a5
  e8:	01c12403          	lw	s0,28(sp)
  ec:	02010113          	addi	sp,sp,32
  f0:	00008067          	ret

000000f4 <main>:

enum State {Starting = 1, WaitingRTC, ReadingButtons, BarrierUp, Working, Rejected}; 

int main() {
  f4:	fd010113          	addi	sp,sp,-48
  f8:	02112623          	sw	ra,44(sp)
  fc:	02812423          	sw	s0,40(sp)
 100:	03010413          	addi	s0,sp,48

    UART_BAUD = FREQ / BAUD_RATE; 
 104:	000207b7          	lui	a5,0x20
 108:	00001737          	lui	a4,0x1
 10c:	ea670713          	addi	a4,a4,-346 # ea6 <bss_end+0x9c6>
 110:	00e7a023          	sw	a4,0(a5) # 20000 <stack_top+0x1e000>

    enum State state = Starting;
 114:	00100793          	li	a5,1
 118:	fef42623          	sw	a5,-20(s0)
    char buttons;
    char buttonAuth;
    char buttonReq;
    char position = BARRIER_DOWN;
 11c:	fe0405a3          	sb	zero,-21(s0)
    char msg[12];
    msg[0]='R';
 120:	05200793          	li	a5,82
 124:	fcf40823          	sb	a5,-48(s0)
    msg[1]='T';
 128:	05400793          	li	a5,84
 12c:	fcf408a3          	sb	a5,-47(s0)
    msg[2]='C';
 130:	04300793          	li	a5,67
 134:	fcf40923          	sb	a5,-46(s0)
    msg[3]=':';
 138:	03a00793          	li	a5,58
 13c:	fcf409a3          	sb	a5,-45(s0)
    msg[4]=' ';
 140:	02000793          	li	a5,32
 144:	fcf40a23          	sb	a5,-44(s0)
    msg[5]='.';
 148:	02e00793          	li	a5,46
 14c:	fcf40aa3          	sb	a5,-43(s0)
    msg[6]='.';
 150:	02e00793          	li	a5,46
 154:	fcf40b23          	sb	a5,-42(s0)
    msg[7]=':';
 158:	03a00793          	li	a5,58
 15c:	fcf40ba3          	sb	a5,-41(s0)
    msg[8]='.';
 160:	02e00793          	li	a5,46
 164:	fcf40c23          	sb	a5,-40(s0)
    msg[9]='.';
 168:	02e00793          	li	a5,46
 16c:	fcf40ca3          	sb	a5,-39(s0)
    msg[10]=' ';
 170:	02000793          	li	a5,32
 174:	fcf40d23          	sb	a5,-38(s0)
    msg[11]='\0';
 178:	fc040da3          	sb	zero,-37(s0)
 
    for (;;) {
        uint32_t rtc = RTC;
 17c:	000107b7          	lui	a5,0x10
 180:	01478793          	addi	a5,a5,20 # 10014 <stack_top+0xe014>
 184:	0007a783          	lw	a5,0(a5)
 188:	fef42223          	sw	a5,-28(s0)

        msg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
 18c:	fe442783          	lw	a5,-28(s0)
 190:	00c7d793          	srli	a5,a5,0xc
 194:	0ff7f793          	zext.b	a5,a5
 198:	00f7f793          	andi	a5,a5,15
 19c:	0ff7f793          	zext.b	a5,a5
 1a0:	03078793          	addi	a5,a5,48
 1a4:	0ff7f793          	zext.b	a5,a5
 1a8:	fcf40aa3          	sb	a5,-43(s0)
        msg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
 1ac:	fe442783          	lw	a5,-28(s0)
 1b0:	0087d793          	srli	a5,a5,0x8
 1b4:	0ff7f793          	zext.b	a5,a5
 1b8:	00f7f793          	andi	a5,a5,15
 1bc:	0ff7f793          	zext.b	a5,a5
 1c0:	03078793          	addi	a5,a5,48
 1c4:	0ff7f793          	zext.b	a5,a5
 1c8:	fcf40b23          	sb	a5,-42(s0)
        msg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
 1cc:	fe442783          	lw	a5,-28(s0)
 1d0:	0047d793          	srli	a5,a5,0x4
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	00f7f793          	andi	a5,a5,15
 1dc:	0ff7f793          	zext.b	a5,a5
 1e0:	03078793          	addi	a5,a5,48
 1e4:	0ff7f793          	zext.b	a5,a5
 1e8:	fcf40c23          	sb	a5,-40(s0)
        msg[9] = ( rtc & 0xf ) + '0';
 1ec:	fe442783          	lw	a5,-28(s0)
 1f0:	0ff7f793          	zext.b	a5,a5
 1f4:	00f7f793          	andi	a5,a5,15
 1f8:	0ff7f793          	zext.b	a5,a5
 1fc:	03078793          	addi	a5,a5,48
 200:	0ff7f793          	zext.b	a5,a5
 204:	fcf40ca3          	sb	a5,-39(s0)
        uart_puts(msg);
 208:	fd040793          	addi	a5,s0,-48
 20c:	00078513          	mv	a0,a5
 210:	e65ff0ef          	jal	ra,74 <uart_puts>

        SERVO = position;
 214:	000107b7          	lui	a5,0x10
 218:	01878793          	addi	a5,a5,24 # 10018 <stack_top+0xe018>
 21c:	feb44703          	lbu	a4,-21(s0)
 220:	00e7a023          	sw	a4,0(a5)
        switch (state) {
 224:	fec42703          	lw	a4,-20(s0)
 228:	00600793          	li	a5,6
 22c:	14e7ea63          	bltu	a5,a4,380 <main+0x28c>
 230:	fec42783          	lw	a5,-20(s0)
 234:	00279713          	slli	a4,a5,0x2
 238:	4c400793          	li	a5,1220
 23c:	00f707b3          	add	a5,a4,a5
 240:	0007a783          	lw	a5,0(a5)
 244:	00078067          	jr	a5
            case Starting:
                if (rtc >= 0x00000005  ) {
 248:	fe442703          	lw	a4,-28(s0)
 24c:	00400793          	li	a5,4
 250:	00e7fc63          	bgeu	a5,a4,268 <main+0x174>
                    state = WaitingRTC; 
 254:	00200793          	li	a5,2
 258:	fef42623          	sw	a5,-20(s0)
                    uart_puts("Waiting until 00:10 to enable buttons\r\n");
 25c:	3b800513          	li	a0,952
 260:	e15ff0ef          	jal	ra,74 <uart_puts>
                } else {
                    uart_puts("Warming up until 00:05\r\n");
                }
            break;
 264:	11c0006f          	j	380 <main+0x28c>
                    uart_puts("Warming up until 00:05\r\n");
 268:	3e000513          	li	a0,992
 26c:	e09ff0ef          	jal	ra,74 <uart_puts>
            break;
 270:	1100006f          	j	380 <main+0x28c>
            case WaitingRTC:
                if (rtc >= 0x00000010  ) {
 274:	fe442703          	lw	a4,-28(s0)
 278:	00f00793          	li	a5,15
 27c:	00e7fc63          	bgeu	a5,a4,294 <main+0x1a0>
                    state = ReadingButtons; 
 280:	00300793          	li	a5,3
 284:	fef42623          	sw	a5,-20(s0)
                    uart_puts("It is 00:10, you have up to twenty seconds to push first and last buttons\r\n");
 288:	3fc00513          	li	a0,1020
 28c:	de9ff0ef          	jal	ra,74 <uart_puts>
                } else {
                    uart_puts("\r\n");
                }
            break;
 290:	0f00006f          	j	380 <main+0x28c>
                    uart_puts("\r\n");
 294:	44800513          	li	a0,1096
 298:	dddff0ef          	jal	ra,74 <uart_puts>
            break;
 29c:	0e40006f          	j	380 <main+0x28c>
            case ReadingButtons:
                buttons = ~BUTTONS;
 2a0:	000107b7          	lui	a5,0x10
 2a4:	00478793          	addi	a5,a5,4 # 10004 <stack_top+0xe004>
 2a8:	0007a783          	lw	a5,0(a5)
 2ac:	0ff7f793          	zext.b	a5,a5
 2b0:	fff7c793          	not	a5,a5
 2b4:	fef401a3          	sb	a5,-29(s0)
                buttonReq  = buttons & 8;
 2b8:	fe344783          	lbu	a5,-29(s0)
 2bc:	0087f793          	andi	a5,a5,8
 2c0:	fef40123          	sb	a5,-30(s0)
                buttonAuth = buttons & 1;
 2c4:	fe344783          	lbu	a5,-29(s0)
 2c8:	0017f793          	andi	a5,a5,1
 2cc:	fef400a3          	sb	a5,-31(s0)
                if (buttonReq == 8  )   {   //// open request
 2d0:	fe244703          	lbu	a4,-30(s0)
 2d4:	00800793          	li	a5,8
 2d8:	02f71a63          	bne	a4,a5,30c <main+0x218>
                    if (buttonAuth == 1 ) {  //// auth button
 2dc:	fe144703          	lbu	a4,-31(s0)
 2e0:	00100793          	li	a5,1
 2e4:	02f71063          	bne	a4,a5,304 <main+0x210>
                        state = BarrierUp;
 2e8:	00400793          	li	a5,4
 2ec:	fef42623          	sw	a5,-20(s0)
                        position = BARRIER_UP;
 2f0:	00a00793          	li	a5,10
 2f4:	fef405a3          	sb	a5,-21(s0)
                        uart_puts("Raising barrier, hurry!\r\n");  
 2f8:	44c00513          	li	a0,1100
 2fc:	d79ff0ef          	jal	ra,74 <uart_puts>
 300:	00c0006f          	j	30c <main+0x218>
                    } else {
                        uart_puts("Bad authentication button\r\n");  
 304:	46800513          	li	a0,1128
 308:	d6dff0ef          	jal	ra,74 <uart_puts>
                    }
                }
                if (rtc >= 0x00000030) {
 30c:	fe442703          	lw	a4,-28(s0)
 310:	02f00793          	li	a5,47
 314:	00e7fc63          	bgeu	a5,a4,32c <main+0x238>
                    uart_puts("Time is out, sorry\r\n");
 318:	48400513          	li	a0,1156
 31c:	d59ff0ef          	jal	ra,74 <uart_puts>
                    state = Rejected;
 320:	00600793          	li	a5,6
 324:	fef42623          	sw	a5,-20(s0)
                } else {
                    uart_puts("\r\n");
                }
            break;
 328:	0580006f          	j	380 <main+0x28c>
                    uart_puts("\r\n");
 32c:	44800513          	li	a0,1096
 330:	d45ff0ef          	jal	ra,74 <uart_puts>
            break;
 334:	04c0006f          	j	380 <main+0x28c>
            case BarrierUp:
                if (rtc >= 0x00000030) {
 338:	fe442703          	lw	a4,-28(s0)
 33c:	02f00793          	li	a5,47
 340:	00e7fe63          	bgeu	a5,a4,35c <main+0x268>
                    uart_puts("Lowering barrier\r\n");
 344:	49c00513          	li	a0,1180
 348:	d2dff0ef          	jal	ra,74 <uart_puts>
                    position = BARRIER_DOWN;
 34c:	fe0405a3          	sb	zero,-21(s0)
                    state = Working;
 350:	00500793          	li	a5,5
 354:	fef42623          	sw	a5,-20(s0)
                } else {
                    uart_puts("\r\n");
                }
            break;
 358:	0280006f          	j	380 <main+0x28c>
                    uart_puts("\r\n");
 35c:	44800513          	li	a0,1096
 360:	d15ff0ef          	jal	ra,74 <uart_puts>
            break;
 364:	01c0006f          	j	380 <main+0x28c>
            case Working:
                uart_puts("Enjoy\r\n");
 368:	4b000513          	li	a0,1200
 36c:	d09ff0ef          	jal	ra,74 <uart_puts>
            break;
 370:	0100006f          	j	380 <main+0x28c>
            case Rejected:
                uart_puts("Cry alone\r\n");
 374:	4b800513          	li	a0,1208
 378:	cfdff0ef          	jal	ra,74 <uart_puts>
            break;
 37c:	00000013          	nop

        }
        LEDS = state;
 380:	000107b7          	lui	a5,0x10
 384:	fec42703          	lw	a4,-20(s0)
 388:	00e7a023          	sw	a4,0(a5) # 10000 <stack_top+0xe000>

        uint32_t start = rdcycle();
 38c:	d41ff0ef          	jal	ra,cc <rdcycle>
 390:	fca42e23          	sw	a0,-36(s0)
        while ((rdcycle() - start) <= FREQ);
 394:	00000013          	nop
 398:	d35ff0ef          	jal	ra,cc <rdcycle>
 39c:	00050713          	mv	a4,a0
 3a0:	fdc42783          	lw	a5,-36(s0)
 3a4:	40f70733          	sub	a4,a4,a5
 3a8:	022557b7          	lui	a5,0x2255
 3ac:	10078793          	addi	a5,a5,256 # 2255100 <stack_top+0x2253100>
 3b0:	fee7f4e3          	bgeu	a5,a4,398 <main+0x2a4>
    for (;;) {
 3b4:	dc9ff06f          	j	17c <main+0x88>
