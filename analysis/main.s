
main.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <uart_putc>:
#define BAUD_RATE 9600

#define BARRIER_UP   10
#define BARRIER_DOWN  0

static void uart_putc(char c) {
   0:	fe010113          	addi	sp,sp,-32
   4:	00812e23          	sw	s0,28(sp)
   8:	02010413          	addi	s0,sp,32
   c:	00050793          	mv	a5,a0
  10:	fef407a3          	sb	a5,-17(s0)
    while (!(UART_STATUS & UART_STATUS_TX_READY));
  14:	00000013          	nop

00000018 <.L2>:
  18:	000207b7          	lui	a5,0x20
  1c:	00478793          	addi	a5,a5,4 # 20004 <.LFE3+0x1fc00>
  20:	0007a783          	lw	a5,0(a5)
  24:	0017f793          	andi	a5,a5,1
  28:	fe0788e3          	beqz	a5,18 <.L2>
    UART_DATA = c;
  2c:	000207b7          	lui	a5,0x20
  30:	00878793          	addi	a5,a5,8 # 20008 <.LFE3+0x1fc04>
  34:	fef44703          	lbu	a4,-17(s0)
  38:	00e7a023          	sw	a4,0(a5)
}
  3c:	00000013          	nop
  40:	01c12403          	lw	s0,28(sp)
  44:	02010113          	addi	sp,sp,32
  48:	00008067          	ret

0000004c <uart_puts>:

static void uart_puts(const char *str) {
  4c:	fd010113          	addi	sp,sp,-48
  50:	02112623          	sw	ra,44(sp)
  54:	02812423          	sw	s0,40(sp)
  58:	03010413          	addi	s0,sp,48
  5c:	fca42e23          	sw	a0,-36(s0)
    char c;
    while ((c = *str++)) {
  60:	0140006f          	j	74 <.L4>

00000064 <.L5>:
        uart_putc(c);
  64:	fef44783          	lbu	a5,-17(s0)
  68:	00078513          	mv	a0,a5
  6c:	00000097          	auipc	ra,0x0
  70:	000080e7          	jalr	ra # 6c <.L5+0x8>

00000074 <.L4>:
    while ((c = *str++)) {
  74:	fdc42783          	lw	a5,-36(s0)
  78:	00178713          	addi	a4,a5,1
  7c:	fce42e23          	sw	a4,-36(s0)
  80:	0007c783          	lbu	a5,0(a5)
  84:	fef407a3          	sb	a5,-17(s0)
  88:	fef44783          	lbu	a5,-17(s0)
  8c:	fc079ce3          	bnez	a5,64 <.L5>
    }
}
  90:	00000013          	nop
  94:	00000013          	nop
  98:	02c12083          	lw	ra,44(sp)
  9c:	02812403          	lw	s0,40(sp)
  a0:	03010113          	addi	sp,sp,48
  a4:	00008067          	ret

000000a8 <rdcycle>:

static inline uint32_t rdcycle(void) {
  a8:	fe010113          	addi	sp,sp,-32
  ac:	00812e23          	sw	s0,28(sp)
  b0:	02010413          	addi	s0,sp,32
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
  b4:	c00027f3          	rdcycle	a5
  b8:	fef42623          	sw	a5,-20(s0)
    return cycle;
  bc:	fec42783          	lw	a5,-20(s0)
}
  c0:	00078513          	mv	a0,a5
  c4:	01c12403          	lw	s0,28(sp)
  c8:	02010113          	addi	sp,sp,32
  cc:	00008067          	ret

000000d0 <main>:

enum State {Starting = 1, WaitingRTC, ReadingButtons, BarrierUp, Working, Rejected}; 

int main() {
  d0:	fd010113          	addi	sp,sp,-48
  d4:	02112623          	sw	ra,44(sp)
  d8:	02812423          	sw	s0,40(sp)
  dc:	03010413          	addi	s0,sp,48

    UART_BAUD = FREQ / BAUD_RATE; 
  e0:	000207b7          	lui	a5,0x20
  e4:	00001737          	lui	a4,0x1
  e8:	ea670713          	addi	a4,a4,-346 # ea6 <.LFE3+0xaa2>
  ec:	00e7a023          	sw	a4,0(a5) # 20000 <.LFE3+0x1fbfc>

    enum State state = Starting;
  f0:	00100793          	li	a5,1
  f4:	fef42623          	sw	a5,-20(s0)
    char buttons;
    char buttonAuth;
    char buttonReq;
    char position = BARRIER_DOWN;
  f8:	fe0405a3          	sb	zero,-21(s0)
    char msg[12];
    msg[0]='R';
  fc:	05200793          	li	a5,82
 100:	fcf40823          	sb	a5,-48(s0)
    msg[1]='T';
 104:	05400793          	li	a5,84
 108:	fcf408a3          	sb	a5,-47(s0)
    msg[2]='C';
 10c:	04300793          	li	a5,67
 110:	fcf40923          	sb	a5,-46(s0)
    msg[3]=':';
 114:	03a00793          	li	a5,58
 118:	fcf409a3          	sb	a5,-45(s0)
    msg[4]=' ';
 11c:	02000793          	li	a5,32
 120:	fcf40a23          	sb	a5,-44(s0)
    msg[5]='.';
 124:	02e00793          	li	a5,46
 128:	fcf40aa3          	sb	a5,-43(s0)
    msg[6]='.';
 12c:	02e00793          	li	a5,46
 130:	fcf40b23          	sb	a5,-42(s0)
    msg[7]=':';
 134:	03a00793          	li	a5,58
 138:	fcf40ba3          	sb	a5,-41(s0)
    msg[8]='.';
 13c:	02e00793          	li	a5,46
 140:	fcf40c23          	sb	a5,-40(s0)
    msg[9]='.';
 144:	02e00793          	li	a5,46
 148:	fcf40ca3          	sb	a5,-39(s0)
    msg[10]=' ';
 14c:	02000793          	li	a5,32
 150:	fcf40d23          	sb	a5,-38(s0)
    msg[11]='\0';
 154:	fc040da3          	sb	zero,-37(s0)

00000158 <.L28>:
 
    for (;;) {
        uint32_t rtc = RTC;
 158:	000107b7          	lui	a5,0x10
 15c:	01478793          	addi	a5,a5,20 # 10014 <.LFE3+0xfc10>
 160:	0007a783          	lw	a5,0(a5)
 164:	fef42223          	sw	a5,-28(s0)

        msg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
 168:	fe442783          	lw	a5,-28(s0)
 16c:	00c7d793          	srli	a5,a5,0xc
 170:	0ff7f793          	zext.b	a5,a5
 174:	00f7f793          	andi	a5,a5,15
 178:	0ff7f793          	zext.b	a5,a5
 17c:	03078793          	addi	a5,a5,48
 180:	0ff7f793          	zext.b	a5,a5
 184:	fcf40aa3          	sb	a5,-43(s0)
        msg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
 188:	fe442783          	lw	a5,-28(s0)
 18c:	0087d793          	srli	a5,a5,0x8
 190:	0ff7f793          	zext.b	a5,a5
 194:	00f7f793          	andi	a5,a5,15
 198:	0ff7f793          	zext.b	a5,a5
 19c:	03078793          	addi	a5,a5,48
 1a0:	0ff7f793          	zext.b	a5,a5
 1a4:	fcf40b23          	sb	a5,-42(s0)
        msg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
 1a8:	fe442783          	lw	a5,-28(s0)
 1ac:	0047d793          	srli	a5,a5,0x4
 1b0:	0ff7f793          	zext.b	a5,a5
 1b4:	00f7f793          	andi	a5,a5,15
 1b8:	0ff7f793          	zext.b	a5,a5
 1bc:	03078793          	addi	a5,a5,48
 1c0:	0ff7f793          	zext.b	a5,a5
 1c4:	fcf40c23          	sb	a5,-40(s0)
        msg[9] = ( rtc & 0xf ) + '0';
 1c8:	fe442783          	lw	a5,-28(s0)
 1cc:	0ff7f793          	zext.b	a5,a5
 1d0:	00f7f793          	andi	a5,a5,15
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	03078793          	addi	a5,a5,48
 1dc:	0ff7f793          	zext.b	a5,a5
 1e0:	fcf40ca3          	sb	a5,-39(s0)
        uart_puts(msg);
 1e4:	fd040793          	addi	a5,s0,-48
 1e8:	00078513          	mv	a0,a5
 1ec:	00000097          	auipc	ra,0x0
 1f0:	000080e7          	jalr	ra # 1ec <.L28+0x94>

        SERVO = position;
 1f4:	000107b7          	lui	a5,0x10
 1f8:	01878793          	addi	a5,a5,24 # 10018 <.LFE3+0xfc14>
 1fc:	feb44703          	lbu	a4,-21(s0)
 200:	00e7a023          	sw	a4,0(a5)
        switch (state) {
 204:	fec42703          	lw	a4,-20(s0)
 208:	00600793          	li	a5,6
 20c:	1ae7ec63          	bltu	a5,a4,3c4 <.L9>
 210:	fec42783          	lw	a5,-20(s0)
 214:	00279713          	slli	a4,a5,0x2
 218:	000007b7          	lui	a5,0x0
 21c:	00078793          	mv	a5,a5
 220:	00f707b3          	add	a5,a4,a5
 224:	0007a783          	lw	a5,0(a5) # 0 <uart_putc>
 228:	00078067          	jr	a5

0000022c <.L16>:
            case Starting:
                if (rtc >= 0x00000005  ) {
 22c:	fe442703          	lw	a4,-28(s0)
 230:	00400793          	li	a5,4
 234:	02e7f063          	bgeu	a5,a4,254 <.L17>
                    state = WaitingRTC; 
 238:	00200793          	li	a5,2
 23c:	fef42623          	sw	a5,-20(s0)
                    uart_puts("Waiting until 00:10 to enable buttons\r\n");
 240:	000007b7          	lui	a5,0x0
 244:	00078513          	mv	a0,a5
 248:	00000097          	auipc	ra,0x0
 24c:	000080e7          	jalr	ra # 248 <.L16+0x1c>
                } else {
                    uart_puts("Warming up until 00:05\r\n");
                }
            break;
 250:	1740006f          	j	3c4 <.L9>

00000254 <.L17>:
                    uart_puts("Warming up until 00:05\r\n");
 254:	000007b7          	lui	a5,0x0
 258:	00078513          	mv	a0,a5
 25c:	00000097          	auipc	ra,0x0
 260:	000080e7          	jalr	ra # 25c <.L17+0x8>
            break;
 264:	1600006f          	j	3c4 <.L9>

00000268 <.L15>:
            case WaitingRTC:
                if (rtc >= 0x00000010  ) {
 268:	fe442703          	lw	a4,-28(s0)
 26c:	00f00793          	li	a5,15
 270:	02e7f063          	bgeu	a5,a4,290 <.L19>
                    state = ReadingButtons; 
 274:	00300793          	li	a5,3
 278:	fef42623          	sw	a5,-20(s0)
                    uart_puts("It is 00:10, you have up to twenty seconds to push first and last buttons\r\n");
 27c:	000007b7          	lui	a5,0x0
 280:	00078513          	mv	a0,a5
 284:	00000097          	auipc	ra,0x0
 288:	000080e7          	jalr	ra # 284 <.L15+0x1c>
                } else {
                    uart_puts("\r\n");
                }
            break;
 28c:	1380006f          	j	3c4 <.L9>

00000290 <.L19>:
                    uart_puts("\r\n");
 290:	000007b7          	lui	a5,0x0
 294:	00078513          	mv	a0,a5
 298:	00000097          	auipc	ra,0x0
 29c:	000080e7          	jalr	ra # 298 <.L19+0x8>
            break;
 2a0:	1240006f          	j	3c4 <.L9>

000002a4 <.L14>:
            case ReadingButtons:
                buttons = ~BUTTONS;
 2a4:	000107b7          	lui	a5,0x10
 2a8:	00478793          	addi	a5,a5,4 # 10004 <.LFE3+0xfc00>
 2ac:	0007a783          	lw	a5,0(a5)
 2b0:	0ff7f793          	zext.b	a5,a5
 2b4:	fff7c793          	not	a5,a5
 2b8:	fef401a3          	sb	a5,-29(s0)
                buttonReq  = buttons & 8;
 2bc:	fe344783          	lbu	a5,-29(s0)
 2c0:	0087f793          	andi	a5,a5,8
 2c4:	fef40123          	sb	a5,-30(s0)
                buttonAuth = buttons & 1;
 2c8:	fe344783          	lbu	a5,-29(s0)
 2cc:	0017f793          	andi	a5,a5,1
 2d0:	fef400a3          	sb	a5,-31(s0)
                if (buttonReq == 8  )   {   //// open request
 2d4:	fe244703          	lbu	a4,-30(s0)
 2d8:	00800793          	li	a5,8
 2dc:	04f71263          	bne	a4,a5,320 <.L21>
                    if (buttonAuth == 1 ) {  //// auth button
 2e0:	fe144703          	lbu	a4,-31(s0)
 2e4:	00100793          	li	a5,1
 2e8:	02f71463          	bne	a4,a5,310 <.L22>
                        state = BarrierUp;
 2ec:	00400793          	li	a5,4
 2f0:	fef42623          	sw	a5,-20(s0)
                        position = BARRIER_UP;
 2f4:	00a00793          	li	a5,10
 2f8:	fef405a3          	sb	a5,-21(s0)
                        uart_puts("Raising barrier, hurry!\r\n");  
 2fc:	000007b7          	lui	a5,0x0
 300:	00078513          	mv	a0,a5
 304:	00000097          	auipc	ra,0x0
 308:	000080e7          	jalr	ra # 304 <.L14+0x60>
 30c:	0140006f          	j	320 <.L21>

00000310 <.L22>:
                    } else {
                        uart_puts("Bad authentication button\r\n");  
 310:	000007b7          	lui	a5,0x0
 314:	00078513          	mv	a0,a5
 318:	00000097          	auipc	ra,0x0
 31c:	000080e7          	jalr	ra # 318 <.L22+0x8>

00000320 <.L21>:
                    }
                }
                if (rtc >= 0x00000030) {
 320:	fe442703          	lw	a4,-28(s0)
 324:	02f00793          	li	a5,47
 328:	02e7f063          	bgeu	a5,a4,348 <.L23>
                    uart_puts("Time is out, sorry\r\n");
 32c:	000007b7          	lui	a5,0x0
 330:	00078513          	mv	a0,a5
 334:	00000097          	auipc	ra,0x0
 338:	000080e7          	jalr	ra # 334 <.L21+0x14>
                    state = Rejected;
 33c:	00600793          	li	a5,6
 340:	fef42623          	sw	a5,-20(s0)
                } else {
                    uart_puts("\r\n");
                }
            break;
 344:	0800006f          	j	3c4 <.L9>

00000348 <.L23>:
                    uart_puts("\r\n");
 348:	000007b7          	lui	a5,0x0
 34c:	00078513          	mv	a0,a5
 350:	00000097          	auipc	ra,0x0
 354:	000080e7          	jalr	ra # 350 <.L23+0x8>
            break;
 358:	06c0006f          	j	3c4 <.L9>

0000035c <.L13>:
            case BarrierUp:
                if (rtc >= 0x00000030) {
 35c:	fe442703          	lw	a4,-28(s0)
 360:	02f00793          	li	a5,47
 364:	02e7f263          	bgeu	a5,a4,388 <.L25>
                    uart_puts("Lowering barrier\r\n");
 368:	000007b7          	lui	a5,0x0
 36c:	00078513          	mv	a0,a5
 370:	00000097          	auipc	ra,0x0
 374:	000080e7          	jalr	ra # 370 <.L13+0x14>
                    position = BARRIER_DOWN;
 378:	fe0405a3          	sb	zero,-21(s0)
                    state = Working;
 37c:	00500793          	li	a5,5
 380:	fef42623          	sw	a5,-20(s0)
                } else {
                    uart_puts("\r\n");
                }
            break;
 384:	0400006f          	j	3c4 <.L9>

00000388 <.L25>:
                    uart_puts("\r\n");
 388:	000007b7          	lui	a5,0x0
 38c:	00078513          	mv	a0,a5
 390:	00000097          	auipc	ra,0x0
 394:	000080e7          	jalr	ra # 390 <.L25+0x8>
            break;
 398:	02c0006f          	j	3c4 <.L9>

0000039c <.L12>:
            case Working:
                uart_puts("Enjoy\r\n");
 39c:	000007b7          	lui	a5,0x0
 3a0:	00078513          	mv	a0,a5
 3a4:	00000097          	auipc	ra,0x0
 3a8:	000080e7          	jalr	ra # 3a4 <.L12+0x8>
            break;
 3ac:	0180006f          	j	3c4 <.L9>

000003b0 <.L10>:
            case Rejected:
                uart_puts("Cry alone\r\n");
 3b0:	000007b7          	lui	a5,0x0
 3b4:	00078513          	mv	a0,a5
 3b8:	00000097          	auipc	ra,0x0
 3bc:	000080e7          	jalr	ra # 3b8 <.L10+0x8>
            break;
 3c0:	00000013          	nop

000003c4 <.L9>:

        }
        LEDS = state;
 3c4:	000107b7          	lui	a5,0x10
 3c8:	fec42703          	lw	a4,-20(s0)
 3cc:	00e7a023          	sw	a4,0(a5) # 10000 <.LFE3+0xfbfc>

        uint32_t start = rdcycle();
 3d0:	00000097          	auipc	ra,0x0
 3d4:	000080e7          	jalr	ra # 3d0 <.L9+0xc>
 3d8:	fca42e23          	sw	a0,-36(s0)
        while ((rdcycle() - start) <= FREQ);
 3dc:	00000013          	nop

000003e0 <.L27>:
 3e0:	00000097          	auipc	ra,0x0
 3e4:	000080e7          	jalr	ra # 3e0 <.L27>
 3e8:	00050713          	mv	a4,a0
 3ec:	fdc42783          	lw	a5,-36(s0)
 3f0:	40f70733          	sub	a4,a4,a5
 3f4:	022557b7          	lui	a5,0x2255
 3f8:	10078793          	addi	a5,a5,256 # 2255100 <.LFE3+0x2254cfc>
 3fc:	fee7f2e3          	bgeu	a5,a4,3e0 <.L27>

00000400 <.LBE2>:
    for (;;) {
 400:	d59ff06f          	j	158 <.L28>
