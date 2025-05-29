
build/fw-flash.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <crtStart>:
.global crtStart
.global main
.global irqCallback

crtStart:
  j crtInit
       0:	0a00006f          	j	a0 <crtInit>
  nop
       4:	00000013          	nop
  nop
       8:	00000013          	nop
  nop
       c:	00000013          	nop

00000010 <trap_entry>:
// x0 is constant
// x2 is sp (always changing)
// x3-4 are gp, tp (fixed through program)
// x8-9, x18-27 are callee-saved registers
trap_entry:
  sw x1,  - 1*4(sp)
      10:	fe112e23          	sw	ra,-4(sp)
  sw x5,  - 2*4(sp)
      14:	fe512c23          	sw	t0,-8(sp)
  sw x6,  - 3*4(sp)
      18:	fe612a23          	sw	t1,-12(sp)
  sw x7,  - 4*4(sp)
      1c:	fe712823          	sw	t2,-16(sp)
  sw x10, - 5*4(sp)
      20:	fea12623          	sw	a0,-20(sp)
  sw x11, - 6*4(sp)
      24:	feb12423          	sw	a1,-24(sp)
  sw x12, - 7*4(sp)
      28:	fec12223          	sw	a2,-28(sp)
  sw x13, - 8*4(sp)
      2c:	fed12023          	sw	a3,-32(sp)
  sw x14, - 9*4(sp)
      30:	fce12e23          	sw	a4,-36(sp)
  sw x15, -10*4(sp)
      34:	fcf12c23          	sw	a5,-40(sp)
  sw x16, -11*4(sp)
      38:	fd012a23          	sw	a6,-44(sp)
  sw x17, -12*4(sp)
      3c:	fd112823          	sw	a7,-48(sp)
  sw x28, -13*4(sp)
      40:	fdc12623          	sw	t3,-52(sp)
  sw x29, -14*4(sp)
      44:	fdd12423          	sw	t4,-56(sp)
  sw x30, -15*4(sp)
      48:	fde12223          	sw	t5,-60(sp)
  sw x31, -16*4(sp)
      4c:	fdf12023          	sw	t6,-64(sp)
  addi sp,sp,-16*4
      50:	fc010113          	addi	sp,sp,-64
  call irqCallback
      54:	5e4000ef          	jal	ra,638 <irqCallback>
  lw x1 , 15*4(sp)
      58:	03c12083          	lw	ra,60(sp)
  lw x5,  14*4(sp)
      5c:	03812283          	lw	t0,56(sp)
  lw x6,  13*4(sp)
      60:	03412303          	lw	t1,52(sp)
  lw x7,  12*4(sp)
      64:	03012383          	lw	t2,48(sp)
  lw x10, 11*4(sp)
      68:	02c12503          	lw	a0,44(sp)
  lw x11, 10*4(sp)
      6c:	02812583          	lw	a1,40(sp)
  lw x12,  9*4(sp)
      70:	02412603          	lw	a2,36(sp)
  lw x13,  8*4(sp)
      74:	02012683          	lw	a3,32(sp)
  lw x14,  7*4(sp)
      78:	01c12703          	lw	a4,28(sp)
  lw x15,  6*4(sp)
      7c:	01812783          	lw	a5,24(sp)
  lw x16,  5*4(sp)
      80:	01412803          	lw	a6,20(sp)
  lw x17,  4*4(sp)
      84:	01012883          	lw	a7,16(sp)
  lw x28,  3*4(sp)
      88:	00c12e03          	lw	t3,12(sp)
  lw x29,  2*4(sp)
      8c:	00812e83          	lw	t4,8(sp)
  lw x30,  1*4(sp)
      90:	00412f03          	lw	t5,4(sp)
  lw x31,  0*4(sp)
      94:	00012f83          	lw	t6,0(sp)
  addi sp,sp,16*4
      98:	04010113          	addi	sp,sp,64
  mret
      9c:	30200073          	mret

000000a0 <crtInit>:
  .text

crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
      a0:	40000197          	auipc	gp,0x40000
      a4:	76018193          	addi	gp,gp,1888 # 40000800 <__global_pointer$>
  .option pop
  la sp, _stack_start
      a8:	0a018113          	addi	sp,gp,160 # 400008a0 <_stack_start>

# copy data section
  la a0, _sidata
      ac:	00001517          	auipc	a0,0x1
      b0:	3f850513          	addi	a0,a0,1016 # 14a4 <_etext>
  la a1, _sdata
      b4:	40000597          	auipc	a1,0x40000
      b8:	f4c58593          	addi	a1,a1,-180 # 40000000 <timer_interval>
  la a2, _edata
      bc:	80418613          	addi	a2,gp,-2044 # 40000004 <perf_stats>
  bge a1, a2, end_init_data
      c0:	00c5dc63          	bge	a1,a2,d8 <bss_init>

000000c4 <loop_init_data>:
loop_init_data:
  lw a3, 0(a0)
      c4:	00052683          	lw	a3,0(a0)
  sw a3, 0(a1)
      c8:	00d5a023          	sw	a3,0(a1)
  addi a0, a0, 4
      cc:	00450513          	addi	a0,a0,4
  addi a1, a1, 4
      d0:	00458593          	addi	a1,a1,4
  blt a1, a2, loop_init_data
      d4:	fec5c8e3          	blt	a1,a2,c4 <loop_init_data>

000000d8 <bss_init>:
end_init_data:

bss_init:
  la a0, _bss_start
      d8:	40000517          	auipc	a0,0x40000
      dc:	f2c50513          	addi	a0,a0,-212 # 40000004 <perf_stats>
  la a1, _bss_end
      e0:	c9c18593          	addi	a1,gp,-868 # 4000049c <_bss_end>

000000e4 <bss_loop>:
bss_loop:
  beq a0,a1,bss_done
      e4:	00b50863          	beq	a0,a1,f4 <bss_done>
  sw zero,0(a0)
      e8:	00052023          	sw	zero,0(a0)
  add a0,a0,4
      ec:	00450513          	addi	a0,a0,4
  j bss_loop
      f0:	ff5ff06f          	j	e4 <bss_loop>

000000f4 <bss_done>:
bss_done:

ctors_init:
  la a0, _ctors_start
      f4:	00001517          	auipc	a0,0x1
      f8:	3b050513          	addi	a0,a0,944 # 14a4 <_etext>
  addi sp,sp,-4
      fc:	ffc10113          	addi	sp,sp,-4

00000100 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
     100:	00001597          	auipc	a1,0x1
     104:	3a458593          	addi	a1,a1,932 # 14a4 <_etext>
  beq a0,a1,ctors_done
     108:	00b50e63          	beq	a0,a1,124 <ctors_done>
  lw a3,0(a0)
     10c:	00052683          	lw	a3,0(a0)
  add a0,a0,4
     110:	00450513          	addi	a0,a0,4
  sw a0,0(sp)
     114:	00a12023          	sw	a0,0(sp)
  jalr  a3
     118:	000680e7          	jalr	a3
  lw a0,0(sp)
     11c:	00012503          	lw	a0,0(sp)
  j ctors_loop
     120:	fe1ff06f          	j	100 <ctors_loop>

00000124 <ctors_done>:
ctors_done:
  addi sp,sp,4
     124:	00410113          	addi	sp,sp,4

  call main
     128:	0dc000ef          	jal	ra,204 <main>

0000012c <infinitLoop>:
infinitLoop:
  j infinitLoop
     12c:	0000006f          	j	12c <infinitLoop>

00000130 <__divsi3>:
     130:	06054063          	bltz	a0,190 <__umodsi3+0x10>
     134:	0605c663          	bltz	a1,1a0 <__umodsi3+0x20>

00000138 <__udivsi3>:
     138:	00058613          	mv	a2,a1
     13c:	00050593          	mv	a1,a0
     140:	fff00513          	li	a0,-1
     144:	02060c63          	beqz	a2,17c <__udivsi3+0x44>
     148:	00100693          	li	a3,1
     14c:	00b67a63          	bgeu	a2,a1,160 <__udivsi3+0x28>
     150:	00c05863          	blez	a2,160 <__udivsi3+0x28>
     154:	00161613          	slli	a2,a2,0x1
     158:	00169693          	slli	a3,a3,0x1
     15c:	feb66ae3          	bltu	a2,a1,150 <__udivsi3+0x18>
     160:	00000513          	li	a0,0
     164:	00c5e663          	bltu	a1,a2,170 <__udivsi3+0x38>
     168:	40c585b3          	sub	a1,a1,a2
     16c:	00d56533          	or	a0,a0,a3
     170:	0016d693          	srli	a3,a3,0x1
     174:	00165613          	srli	a2,a2,0x1
     178:	fe0696e3          	bnez	a3,164 <__udivsi3+0x2c>
     17c:	00008067          	ret

00000180 <__umodsi3>:
     180:	00008293          	mv	t0,ra
     184:	fb5ff0ef          	jal	ra,138 <__udivsi3>
     188:	00058513          	mv	a0,a1
     18c:	00028067          	jr	t0
     190:	40a00533          	neg	a0,a0
     194:	00b04863          	bgtz	a1,1a4 <__umodsi3+0x24>
     198:	40b005b3          	neg	a1,a1
     19c:	f9dff06f          	j	138 <__udivsi3>
     1a0:	40b005b3          	neg	a1,a1
     1a4:	00008293          	mv	t0,ra
     1a8:	f91ff0ef          	jal	ra,138 <__udivsi3>
     1ac:	40a00533          	neg	a0,a0
     1b0:	00028067          	jr	t0

000001b4 <__modsi3>:
     1b4:	00008293          	mv	t0,ra
     1b8:	0005ca63          	bltz	a1,1cc <__modsi3+0x18>
     1bc:	00054c63          	bltz	a0,1d4 <__modsi3+0x20>
     1c0:	f79ff0ef          	jal	ra,138 <__udivsi3>
     1c4:	00058513          	mv	a0,a1
     1c8:	00028067          	jr	t0
     1cc:	40b005b3          	neg	a1,a1
     1d0:	fe0558e3          	bgez	a0,1c0 <__modsi3+0xc>
     1d4:	40a00533          	neg	a0,a0
     1d8:	f61ff0ef          	jal	ra,138 <__udivsi3>
     1dc:	40b00533          	neg	a0,a1
     1e0:	00028067          	jr	t0

000001e4 <putchar>:

void (*spi_flashio)(uint8_t *pdata, int length, int wren) = FLASHIO_ENTRY_ADDR;

int putchar(int c)
{	
    if (c == '\n')
     1e4:	00a00793          	li	a5,10
     1e8:	00f51863          	bne	a0,a5,1f8 <putchar+0x14>
        UART0->DATA = '\r';
     1ec:	830007b7          	lui	a5,0x83000
     1f0:	00d00713          	li	a4,13
     1f4:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
    UART0->DATA = c;
     1f8:	830007b7          	lui	a5,0x83000
     1fc:	00a7a023          	sw	a0,0(a5) # 83000000 <_stack_start+0x42fff760>
    
    return c;
}
     200:	00008067          	ret

00000204 <main>:
#define CLK_FREQ        25175000
#define UART_BAUD       115200

void main()
{
    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;
     204:	830007b7          	lui	a5,0x83000
     208:	0d800713          	li	a4,216
     20c:	00e7a223          	sw	a4,4(a5) # 83000004 <_stack_start+0x42fff764>

    GPIO0->OE = 0x3F;
     210:	03f00693          	li	a3,63
     214:	82000737          	lui	a4,0x82000
     218:	00d72423          	sw	a3,8(a4) # 82000008 <_stack_start+0x41fff768>
    GPIO0->OUT = 0x3F;
     21c:	00d72023          	sw	a3,0(a4)
        QSPI0->REG |= QSPI_REG_CRM;
     220:	81000737          	lui	a4,0x81000
     224:	00072683          	lw	a3,0(a4) # 81000000 <_stack_start+0x40fff760>
     228:	00100637          	lui	a2,0x100
        UART0->DATA = '\r';
     22c:	00d00593          	li	a1,13
        QSPI0->REG |= QSPI_REG_CRM;
     230:	00c6e6b3          	or	a3,a3,a2
     234:	00d72023          	sw	a3,0(a4)
        QSPI0->REG |= QSPI_REG_DSPI;
     238:	00072683          	lw	a3,0(a4)
     23c:	00400637          	lui	a2,0x400
     240:	00c6e6b3          	or	a3,a3,a2
     244:	00d72023          	sw	a3,0(a4)
        UART0->DATA = '\r';
     248:	00d00713          	li	a4,13
     24c:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     250:	00a00713          	li	a4,10
     254:	00e7a023          	sw	a4,0(a5)
     258:	02000713          	li	a4,32
     25c:	00e7a023          	sw	a4,0(a5)
        putchar(*(p++));
     260:	00001737          	lui	a4,0x1
    while (*p)
     264:	02000793          	li	a5,32
        putchar(*(p++));
     268:	15570713          	addi	a4,a4,341 # 1155 <rt_main_loop+0x19>
    if (c == '\n')
     26c:	00a00613          	li	a2,10
    UART0->DATA = c;
     270:	830006b7          	lui	a3,0x83000
        putchar(*(p++));
     274:	00170713          	addi	a4,a4,1
    if (c == '\n')
     278:	3ac78663          	beq	a5,a2,624 <_stack_size+0x224>
    UART0->DATA = c;
     27c:	00f6a023          	sw	a5,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     280:	00074783          	lbu	a5,0(a4)
     284:	fe0798e3          	bnez	a5,274 <main+0x70>
    UART0->DATA = c;
     288:	830007b7          	lui	a5,0x83000
     28c:	02000713          	li	a4,32
     290:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
        putchar(*(p++));
     294:	00001737          	lui	a4,0x1
     298:	17d70713          	addi	a4,a4,381 # 117d <rt_main_loop+0x41>
    while (*p)
     29c:	07c00793          	li	a5,124
    if (c == '\n')
     2a0:	00a00613          	li	a2,10
    UART0->DATA = c;
     2a4:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     2a8:	00d00593          	li	a1,13
        putchar(*(p++));
     2ac:	00170713          	addi	a4,a4,1
    if (c == '\n')
     2b0:	36c78063          	beq	a5,a2,610 <_stack_size+0x210>
    UART0->DATA = c;
     2b4:	00f6a023          	sw	a5,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     2b8:	00074783          	lbu	a5,0(a4)
     2bc:	fe0798e3          	bnez	a5,2ac <main+0xa8>
    UART0->DATA = c;
     2c0:	830007b7          	lui	a5,0x83000
     2c4:	02000713          	li	a4,32
     2c8:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
        putchar(*(p++));
     2cc:	00001737          	lui	a4,0x1
    while (*p)
     2d0:	07c00793          	li	a5,124
        putchar(*(p++));
     2d4:	1a570713          	addi	a4,a4,421 # 11a5 <rt_main_loop+0x69>
    if (c == '\n')
     2d8:	00a00613          	li	a2,10
    UART0->DATA = c;
     2dc:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     2e0:	00d00593          	li	a1,13
        putchar(*(p++));
     2e4:	00170713          	addi	a4,a4,1
    if (c == '\n')
     2e8:	30c78a63          	beq	a5,a2,5fc <_stack_size+0x1fc>
    UART0->DATA = c;
     2ec:	00f6a023          	sw	a5,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     2f0:	00074783          	lbu	a5,0(a4)
     2f4:	fe0798e3          	bnez	a5,2e4 <main+0xe0>
    UART0->DATA = c;
     2f8:	830007b7          	lui	a5,0x83000
     2fc:	02000713          	li	a4,32
     300:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
        putchar(*(p++));
     304:	00001737          	lui	a4,0x1
     308:	1c970713          	addi	a4,a4,457 # 11c9 <rt_main_loop+0x8d>
    while (*p)
     30c:	07c00793          	li	a5,124
    if (c == '\n')
     310:	00a00613          	li	a2,10
    UART0->DATA = c;
     314:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     318:	00d00593          	li	a1,13
        putchar(*(p++));
     31c:	00170713          	addi	a4,a4,1
    if (c == '\n')
     320:	2cc78463          	beq	a5,a2,5e8 <_stack_size+0x1e8>
    UART0->DATA = c;
     324:	00f6a023          	sw	a5,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     328:	00074783          	lbu	a5,0(a4)
     32c:	fe0798e3          	bnez	a5,31c <main+0x118>
    UART0->DATA = c;
     330:	830007b7          	lui	a5,0x83000
     334:	02000713          	li	a4,32
     338:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
        putchar(*(p++));
     33c:	00001737          	lui	a4,0x1
    while (*p)
     340:	07c00793          	li	a5,124
        putchar(*(p++));
     344:	1f170713          	addi	a4,a4,497 # 11f1 <rt_main_loop+0xb5>
    if (c == '\n')
     348:	00a00613          	li	a2,10
    UART0->DATA = c;
     34c:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     350:	00d00593          	li	a1,13
        putchar(*(p++));
     354:	00170713          	addi	a4,a4,1
    if (c == '\n')
     358:	26c78e63          	beq	a5,a2,5d4 <_stack_size+0x1d4>
    UART0->DATA = c;
     35c:	00f6a023          	sw	a5,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     360:	00074783          	lbu	a5,0(a4)
     364:	fe0798e3          	bnez	a5,354 <main+0x150>
        UART0->DATA = '\r';
     368:	830007b7          	lui	a5,0x83000
     36c:	00d00713          	li	a4,13
     370:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
    UART0->DATA = c;
     374:	00a00713          	li	a4,10
     378:	00e7a023          	sw	a4,0(a5)
     37c:	02000713          	li	a4,32
     380:	00e7a023          	sw	a4,0(a5)
        putchar(*(p++));
     384:	000017b7          	lui	a5,0x1
     388:	21978793          	addi	a5,a5,537 # 1219 <rt_main_loop+0xdd>
    if (c == '\n')
     38c:	00a00613          	li	a2,10
    UART0->DATA = c;
     390:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     394:	00d00593          	li	a1,13
        putchar(*(p++));
     398:	00178793          	addi	a5,a5,1
    if (c == '\n')
     39c:	22c70263          	beq	a4,a2,5c0 <_stack_size+0x1c0>
    UART0->DATA = c;
     3a0:	00e6a023          	sw	a4,0(a3) # 83000000 <_stack_start+0x42fff760>
    while (*p)
     3a4:	0007c703          	lbu	a4,0(a5)
     3a8:	fe0718e3          	bnez	a4,398 <main+0x194>
        UART0->DATA = '\r';
     3ac:	830007b7          	lui	a5,0x83000
     3b0:	00d00713          	li	a4,13
     3b4:	00e7a023          	sw	a4,0(a5) # 83000000 <_stack_start+0x42fff760>
    UART0->DATA = c;
     3b8:	00a00713          	li	a4,10
     3bc:	00e7a023          	sw	a4,0(a5)
    print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
    print("\n");
    print("        On Lichee Tang Nano-9K\n");
    print("\n");

    for ( i = 0 ; i < 10000; i++);
     3c0:	c7418793          	addi	a5,gp,-908 # 40000474 <i>
     3c4:	0007a023          	sw	zero,0(a5)
     3c8:	0007a683          	lw	a3,0(a5)
     3cc:	00002737          	lui	a4,0x2
     3d0:	70f70713          	addi	a4,a4,1807 # 270f <_etext+0x126b>
     3d4:	00d74c63          	blt	a4,a3,3ec <main+0x1e8>
     3d8:	0007a683          	lw	a3,0(a5)
     3dc:	00168693          	addi	a3,a3,1
     3e0:	00d7a023          	sw	a3,0(a5)
     3e4:	0007a683          	lw	a3,0(a5)
     3e8:	fed758e3          	bge	a4,a3,3d8 <main+0x1d4>
    GPIO0->OUT = 0x3F ^ 0x01;
     3ec:	82000737          	lui	a4,0x82000
     3f0:	03e00693          	li	a3,62
     3f4:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     3f8:	0007a023          	sw	zero,0(a5)
     3fc:	0007a703          	lw	a4,0(a5)
     400:	000026b7          	lui	a3,0x2
     404:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     408:	00e6cc63          	blt	a3,a4,420 <_stack_size+0x20>
     40c:	0007a703          	lw	a4,0(a5)
     410:	00170713          	addi	a4,a4,1
     414:	00e7a023          	sw	a4,0(a5)
     418:	0007a703          	lw	a4,0(a5)
     41c:	fee6d8e3          	bge	a3,a4,40c <_stack_size+0xc>
    GPIO0->OUT = 0x3F ^ 0x02;
     420:	82000737          	lui	a4,0x82000
     424:	03d00693          	li	a3,61
     428:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     42c:	0007a023          	sw	zero,0(a5)
     430:	0007a703          	lw	a4,0(a5)
     434:	000026b7          	lui	a3,0x2
     438:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     43c:	00e6cc63          	blt	a3,a4,454 <_stack_size+0x54>
     440:	0007a703          	lw	a4,0(a5)
     444:	00170713          	addi	a4,a4,1
     448:	00e7a023          	sw	a4,0(a5)
     44c:	0007a703          	lw	a4,0(a5)
     450:	fee6d8e3          	bge	a3,a4,440 <_stack_size+0x40>
    GPIO0->OUT = 0x3F ^ 0x04;
     454:	82000737          	lui	a4,0x82000
     458:	03b00693          	li	a3,59
     45c:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     460:	0007a023          	sw	zero,0(a5)
     464:	0007a703          	lw	a4,0(a5)
     468:	000026b7          	lui	a3,0x2
     46c:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     470:	00e6cc63          	blt	a3,a4,488 <_stack_size+0x88>
     474:	0007a703          	lw	a4,0(a5)
     478:	00170713          	addi	a4,a4,1
     47c:	00e7a023          	sw	a4,0(a5)
     480:	0007a703          	lw	a4,0(a5)
     484:	fee6d8e3          	bge	a3,a4,474 <_stack_size+0x74>
    GPIO0->OUT = 0x3F ^ 0x08;
     488:	82000737          	lui	a4,0x82000
     48c:	03700693          	li	a3,55
     490:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     494:	0007a023          	sw	zero,0(a5)
     498:	0007a703          	lw	a4,0(a5)
     49c:	000026b7          	lui	a3,0x2
     4a0:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     4a4:	00e6cc63          	blt	a3,a4,4bc <_stack_size+0xbc>
     4a8:	0007a703          	lw	a4,0(a5)
     4ac:	00170713          	addi	a4,a4,1
     4b0:	00e7a023          	sw	a4,0(a5)
     4b4:	0007a703          	lw	a4,0(a5)
     4b8:	fee6d8e3          	bge	a3,a4,4a8 <_stack_size+0xa8>
    GPIO0->OUT = 0x3F ^ 0x10;
     4bc:	82000737          	lui	a4,0x82000
     4c0:	02f00693          	li	a3,47
     4c4:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     4c8:	0007a023          	sw	zero,0(a5)
     4cc:	0007a703          	lw	a4,0(a5)
     4d0:	000026b7          	lui	a3,0x2
     4d4:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     4d8:	00e6cc63          	blt	a3,a4,4f0 <_stack_size+0xf0>
     4dc:	0007a703          	lw	a4,0(a5)
     4e0:	00170713          	addi	a4,a4,1
     4e4:	00e7a023          	sw	a4,0(a5)
     4e8:	0007a703          	lw	a4,0(a5)
     4ec:	fee6d8e3          	bge	a3,a4,4dc <_stack_size+0xdc>
    GPIO0->OUT = 0x3F ^ 0x20;
     4f0:	82000737          	lui	a4,0x82000
     4f4:	01f00693          	li	a3,31
     4f8:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     4fc:	0007a023          	sw	zero,0(a5)
     500:	0007a703          	lw	a4,0(a5)
     504:	000026b7          	lui	a3,0x2
     508:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     50c:	00e6cc63          	blt	a3,a4,524 <_stack_size+0x124>
     510:	0007a703          	lw	a4,0(a5)
     514:	00170713          	addi	a4,a4,1
     518:	00e7a023          	sw	a4,0(a5)
     51c:	0007a703          	lw	a4,0(a5)
     520:	fee6d8e3          	bge	a3,a4,510 <_stack_size+0x110>
    GPIO0->OUT = 0x3F;
     524:	82000737          	lui	a4,0x82000
     528:	03f00693          	li	a3,63
     52c:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     530:	0007a023          	sw	zero,0(a5)
     534:	0007a703          	lw	a4,0(a5)
     538:	000026b7          	lui	a3,0x2
     53c:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     540:	00e6cc63          	blt	a3,a4,558 <_stack_size+0x158>
     544:	0007a703          	lw	a4,0(a5)
     548:	00170713          	addi	a4,a4,1
     54c:	00e7a023          	sw	a4,0(a5)
     550:	0007a703          	lw	a4,0(a5)
     554:	fee6d8e3          	bge	a3,a4,544 <_stack_size+0x144>
    GPIO0->OUT = 0x00;
     558:	82000737          	lui	a4,0x82000
     55c:	00072023          	sw	zero,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     560:	0007a023          	sw	zero,0(a5)
     564:	0007a703          	lw	a4,0(a5)
     568:	000026b7          	lui	a3,0x2
     56c:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     570:	00e6cc63          	blt	a3,a4,588 <_stack_size+0x188>
     574:	0007a703          	lw	a4,0(a5)
     578:	00170713          	addi	a4,a4,1
     57c:	00e7a023          	sw	a4,0(a5)
     580:	0007a703          	lw	a4,0(a5)
     584:	fee6d8e3          	bge	a3,a4,574 <_stack_size+0x174>
    GPIO0->OUT = 0x3F;
     588:	82000737          	lui	a4,0x82000
     58c:	03f00693          	li	a3,63
     590:	00d72023          	sw	a3,0(a4) # 82000000 <_stack_start+0x41fff760>
    for ( i = 0 ; i < 10000; i++);
     594:	0007a023          	sw	zero,0(a5)
     598:	0007a703          	lw	a4,0(a5)
     59c:	000026b7          	lui	a3,0x2
     5a0:	70f68693          	addi	a3,a3,1807 # 270f <_etext+0x126b>
     5a4:	00e6cc63          	blt	a3,a4,5bc <_stack_size+0x1bc>
     5a8:	0007a703          	lw	a4,0(a5)
     5ac:	00170713          	addi	a4,a4,1
     5b0:	00e7a023          	sw	a4,0(a5)
     5b4:	0007a703          	lw	a4,0(a5)
     5b8:	fee6d8e3          	bge	a3,a4,5a8 <_stack_size+0x1a8>

    // Zameni while(1) sa rt_main_loop()
    rt_main_loop();
     5bc:	3810006f          	j	113c <rt_main_loop>
        UART0->DATA = '\r';
     5c0:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     5c4:	00e6a023          	sw	a4,0(a3)
    while (*p)
     5c8:	0007c703          	lbu	a4,0(a5)
     5cc:	dc0716e3          	bnez	a4,398 <main+0x194>
     5d0:	dddff06f          	j	3ac <main+0x1a8>
        UART0->DATA = '\r';
     5d4:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     5d8:	00f6a023          	sw	a5,0(a3)
    while (*p)
     5dc:	00074783          	lbu	a5,0(a4)
     5e0:	d6079ae3          	bnez	a5,354 <main+0x150>
     5e4:	d85ff06f          	j	368 <main+0x164>
        UART0->DATA = '\r';
     5e8:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     5ec:	00f6a023          	sw	a5,0(a3)
    while (*p)
     5f0:	00074783          	lbu	a5,0(a4)
     5f4:	d20794e3          	bnez	a5,31c <main+0x118>
     5f8:	d39ff06f          	j	330 <main+0x12c>
        UART0->DATA = '\r';
     5fc:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     600:	00f6a023          	sw	a5,0(a3)
    while (*p)
     604:	00074783          	lbu	a5,0(a4)
     608:	cc079ee3          	bnez	a5,2e4 <main+0xe0>
     60c:	cedff06f          	j	2f8 <main+0xf4>
        UART0->DATA = '\r';
     610:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     614:	00f6a023          	sw	a5,0(a3)
    while (*p)
     618:	00074783          	lbu	a5,0(a4)
     61c:	c80798e3          	bnez	a5,2ac <main+0xa8>
     620:	ca1ff06f          	j	2c0 <main+0xbc>
        UART0->DATA = '\r';
     624:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
     628:	00f6a023          	sw	a5,0(a3)
    while (*p)
     62c:	00074783          	lbu	a5,0(a4)
     630:	c40792e3          	bnez	a5,274 <main+0x70>
     634:	c55ff06f          	j	288 <main+0x84>

00000638 <irqCallback>:
}

void irqCallback() {

     638:	00008067          	ret

0000063c <zero_stack_registers.constprop.0>:
}

/*
 * Funkcija koja sprečava kompajler da optimizuje petlje u memset
 */
static void __attribute__((noinline)) zero_stack_registers(uint32_t* stack_ptr, int count) {
     63c:	ff010113          	addi	sp,sp,-16
    volatile int i;  // volatile sprečava optimizaciju
    for (i = 0; i < count; i++) {
     640:	00012623          	sw	zero,12(sp)
     644:	00c12703          	lw	a4,12(sp)
     648:	01e00793          	li	a5,30
     64c:	02e7c863          	blt	a5,a4,67c <zero_stack_registers.constprop.0+0x40>
     650:	01e00693          	li	a3,30
        stack_ptr[-i-1] = 0;  // Direktno postavljanje bez pointer manipulacije
     654:	00c12783          	lw	a5,12(sp)
    for (i = 0; i < count; i++) {
     658:	00c12703          	lw	a4,12(sp)
        stack_ptr[-i-1] = 0;  // Direktno postavljanje bez pointer manipulacije
     65c:	fff7c793          	not	a5,a5
    for (i = 0; i < count; i++) {
     660:	00170713          	addi	a4,a4,1
     664:	00e12623          	sw	a4,12(sp)
        stack_ptr[-i-1] = 0;  // Direktno postavljanje bez pointer manipulacije
     668:	00279793          	slli	a5,a5,0x2
    for (i = 0; i < count; i++) {
     66c:	00c12703          	lw	a4,12(sp)
        stack_ptr[-i-1] = 0;  // Direktno postavljanje bez pointer manipulacije
     670:	00f507b3          	add	a5,a0,a5
     674:	0007a023          	sw	zero,0(a5)
    for (i = 0; i < count; i++) {
     678:	fce6dee3          	bge	a3,a4,654 <zero_stack_registers.constprop.0+0x18>
    }
}
     67c:	01010113          	addi	sp,sp,16
     680:	00008067          	ret

00000684 <schedule.part.0>:
    uint8_t next = current_task;
    uint8_t highest_priority = 255;
    uint8_t selected_task = 0;
    
    // Prvo proveri da li neki task treba da se probudi
    for (int i = 0; i < task_count; i++) {
     684:	c801c703          	lbu	a4,-896(gp) # 40000480 <task_count>
     688:	12070863          	beqz	a4,7b8 <schedule.part.0+0x134>
        if (tasks[i].state == TASK_BLOCKED && 
     68c:	c1418793          	addi	a5,gp,-1004 # 40000414 <tasks>
     690:	00c7a603          	lw	a2,12(a5)
     694:	00200693          	li	a3,2
            tasks[i].wake_time <= system_tick) {
     698:	c7c1a583          	lw	a1,-900(gp) # 4000047c <system_tick>
        if (tasks[i].state == TASK_BLOCKED && 
     69c:	12d60263          	beq	a2,a3,7c0 <schedule.part.0+0x13c>
    for (int i = 0; i < task_count; i++) {
     6a0:	00100693          	li	a3,1
     6a4:	10d70663          	beq	a4,a3,7b0 <schedule.part.0+0x12c>
        if (tasks[i].state == TASK_BLOCKED && 
     6a8:	0247a603          	lw	a2,36(a5)
     6ac:	00200693          	li	a3,2
     6b0:	0ed60663          	beq	a2,a3,79c <schedule.part.0+0x118>
    for (int i = 0; i < task_count; i++) {
     6b4:	00200693          	li	a3,2
     6b8:	02d70063          	beq	a4,a3,6d8 <schedule.part.0+0x54>
        if (tasks[i].state == TASK_BLOCKED && 
     6bc:	03c7a603          	lw	a2,60(a5)
     6c0:	10d60863          	beq	a2,a3,7d0 <schedule.part.0+0x14c>
    for (int i = 0; i < task_count; i++) {
     6c4:	00300693          	li	a3,3
     6c8:	00d70863          	beq	a4,a3,6d8 <schedule.part.0+0x54>
        if (tasks[i].state == TASK_BLOCKED && 
     6cc:	0547a603          	lw	a2,84(a5)
     6d0:	00200693          	li	a3,2
     6d4:	10d60c63          	beq	a2,a3,7ec <schedule.part.0+0x168>
        }
    }
    
    // Nađi task sa najvišim prioritetom koji je spreman
    for (int i = 0; i < task_count; i++) {
        if (tasks[i].state == TASK_READY && 
     6d8:	00c7a683          	lw	a3,12(a5)
     6dc:	0a069c63          	bnez	a3,794 <schedule.part.0+0x110>
    for (int i = 0; i < task_count; i++) {
     6e0:	00100613          	li	a2,1
            tasks[i].priority < highest_priority) {
     6e4:	0087c683          	lbu	a3,8(a5)
    for (int i = 0; i < task_count; i++) {
     6e8:	0cc70863          	beq	a4,a2,7b8 <schedule.part.0+0x134>
        if (tasks[i].state == TASK_READY && 
     6ec:	0247a583          	lw	a1,36(a5)
     6f0:	00000613          	li	a2,0
     6f4:	00059663          	bnez	a1,700 <schedule.part.0+0x7c>
            tasks[i].priority < highest_priority) {
     6f8:	0207c583          	lbu	a1,32(a5)
        if (tasks[i].state == TASK_READY && 
     6fc:	0ed5e263          	bltu	a1,a3,7e0 <schedule.part.0+0x15c>
    for (int i = 0; i < task_count; i++) {
     700:	00200593          	li	a1,2
     704:	02e5d663          	bge	a1,a4,730 <schedule.part.0+0xac>
        if (tasks[i].state == TASK_READY && 
     708:	03c7a583          	lw	a1,60(a5)
     70c:	00059663          	bnez	a1,718 <schedule.part.0+0x94>
            tasks[i].priority < highest_priority) {
     710:	0387c583          	lbu	a1,56(a5)
        if (tasks[i].state == TASK_READY && 
     714:	0ed5e463          	bltu	a1,a3,7fc <schedule.part.0+0x178>
    for (int i = 0; i < task_count; i++) {
     718:	00300593          	li	a1,3
     71c:	00b70a63          	beq	a4,a1,730 <schedule.part.0+0xac>
        if (tasks[i].state == TASK_READY && 
     720:	0547a703          	lw	a4,84(a5)
     724:	00071663          	bnez	a4,730 <schedule.part.0+0xac>
     728:	0507c783          	lbu	a5,80(a5)
     72c:	0cd7ee63          	bltu	a5,a3,808 <schedule.part.0+0x184>
void schedule(void) {
    if (!scheduler_started) return;
    
    uint8_t next_task = get_next_task();
    
    if (next_task != current_task) {
     730:	c7818693          	addi	a3,gp,-904 # 40000478 <current_task>
     734:	0006c583          	lbu	a1,0(a3)
     738:	06c58a63          	beq	a1,a2,7ac <schedule.part.0+0x128>
        // Promeni stanje task-ova
        if (tasks[current_task].state == TASK_RUNNING) {
     73c:	00159713          	slli	a4,a1,0x1
     740:	00b70733          	add	a4,a4,a1
     744:	c1418793          	addi	a5,gp,-1004 # 40000414 <tasks>
     748:	00371713          	slli	a4,a4,0x3
     74c:	00e78733          	add	a4,a5,a4
     750:	00c72503          	lw	a0,12(a4)
     754:	00100593          	li	a1,1
     758:	00b51463          	bne	a0,a1,760 <schedule.part.0+0xdc>
            tasks[current_task].state = TASK_READY;
     75c:	00072623          	sw	zero,12(a4)
        }
        
        tasks[next_task].state = TASK_RUNNING;
        current_task = next_task;
        
        perf_stats.context_switches++;
     760:	400005b7          	lui	a1,0x40000
     764:	00458593          	addi	a1,a1,4 # 40000004 <perf_stats>
     768:	0005a503          	lw	a0,0(a1)
        tasks[next_task].state = TASK_RUNNING;
     76c:	00161713          	slli	a4,a2,0x1
     770:	00c70733          	add	a4,a4,a2
     774:	00371713          	slli	a4,a4,0x3
     778:	00e787b3          	add	a5,a5,a4
        perf_stats.context_switches++;
     77c:	00150713          	addi	a4,a0,1
        tasks[next_task].state = TASK_RUNNING;
     780:	00100513          	li	a0,1
     784:	00a7a623          	sw	a0,12(a5)
        current_task = next_task;
     788:	00c68023          	sb	a2,0(a3)
        perf_stats.context_switches++;
     78c:	00e5a023          	sw	a4,0(a1)
}
     790:	00008067          	ret
        if (tasks[i].state == TASK_READY && 
     794:	0ff00693          	li	a3,255
     798:	f55ff06f          	j	6ec <schedule.part.0+0x68>
        if (tasks[i].state == TASK_BLOCKED && 
     79c:	0287a683          	lw	a3,40(a5)
     7a0:	f0d5eae3          	bltu	a1,a3,6b4 <schedule.part.0+0x30>
            tasks[i].state = TASK_READY;
     7a4:	0207a223          	sw	zero,36(a5)
     7a8:	f0dff06f          	j	6b4 <schedule.part.0+0x30>
        
        // Ovde bi trebao context_switch() u assembly-ju
        context_switch();
    }
}
     7ac:	00008067          	ret
        if (tasks[i].state == TASK_READY && 
     7b0:	00c7a683          	lw	a3,12(a5)
     7b4:	f20686e3          	beqz	a3,6e0 <schedule.part.0+0x5c>
    uint8_t selected_task = 0;
     7b8:	00000613          	li	a2,0
     7bc:	f75ff06f          	j	730 <schedule.part.0+0xac>
        if (tasks[i].state == TASK_BLOCKED && 
     7c0:	0107a683          	lw	a3,16(a5)
     7c4:	ecd5eee3          	bltu	a1,a3,6a0 <schedule.part.0+0x1c>
            tasks[i].state = TASK_READY;
     7c8:	0007a623          	sw	zero,12(a5)
     7cc:	ed5ff06f          	j	6a0 <schedule.part.0+0x1c>
        if (tasks[i].state == TASK_BLOCKED && 
     7d0:	0407a683          	lw	a3,64(a5)
     7d4:	eed5e8e3          	bltu	a1,a3,6c4 <schedule.part.0+0x40>
            tasks[i].state = TASK_READY;
     7d8:	0207ae23          	sw	zero,60(a5)
     7dc:	ee9ff06f          	j	6c4 <schedule.part.0+0x40>
        if (tasks[i].state == TASK_READY && 
     7e0:	00058693          	mv	a3,a1
            selected_task = i;
     7e4:	00100613          	li	a2,1
     7e8:	f19ff06f          	j	700 <schedule.part.0+0x7c>
        if (tasks[i].state == TASK_BLOCKED && 
     7ec:	0587a683          	lw	a3,88(a5)
     7f0:	eed5e4e3          	bltu	a1,a3,6d8 <schedule.part.0+0x54>
            tasks[i].state = TASK_READY;
     7f4:	0407aa23          	sw	zero,84(a5)
    for (int i = 0; i < task_count; i++) {
     7f8:	ee1ff06f          	j	6d8 <schedule.part.0+0x54>
        if (tasks[i].state == TASK_READY && 
     7fc:	00058693          	mv	a3,a1
            selected_task = i;
     800:	00200613          	li	a2,2
     804:	f15ff06f          	j	718 <schedule.part.0+0x94>
     808:	00300613          	li	a2,3
    for (int i = 0; i < task_count; i++) {
     80c:	f25ff06f          	j	730 <schedule.part.0+0xac>

00000810 <uart_printf>:
void uart_printf(const char* format, ...) {
     810:	fd010113          	addi	sp,sp,-48
     814:	00812423          	sw	s0,8(sp)
     818:	00112623          	sw	ra,12(sp)
     81c:	00050413          	mv	s0,a0
    while (*p) {
     820:	00054503          	lbu	a0,0(a0)
void uart_printf(const char* format, ...) {
     824:	00b12a23          	sw	a1,20(sp)
     828:	00c12c23          	sw	a2,24(sp)
     82c:	00d12e23          	sw	a3,28(sp)
     830:	02e12023          	sw	a4,32(sp)
     834:	02f12223          	sw	a5,36(sp)
     838:	03012423          	sw	a6,40(sp)
     83c:	03112623          	sw	a7,44(sp)
    while (*p) {
     840:	00050a63          	beqz	a0,854 <uart_printf+0x44>
        p++;
     844:	00140413          	addi	s0,s0,1
        putchar(*p);
     848:	99dff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     84c:	00044503          	lbu	a0,0(s0)
     850:	fe051ae3          	bnez	a0,844 <uart_printf+0x34>
}
     854:	00c12083          	lw	ra,12(sp)
     858:	00812403          	lw	s0,8(sp)
     85c:	03010113          	addi	sp,sp,48
     860:	00008067          	ret

00000864 <task_create>:
int task_create(void (*task_func)(void), uint8_t priority, const char* name) {
     864:	fe010113          	addi	sp,sp,-32
     868:	00112e23          	sw	ra,28(sp)
     86c:	00812c23          	sw	s0,24(sp)
     870:	00912a23          	sw	s1,20(sp)
     874:	01212823          	sw	s2,16(sp)
     878:	01312623          	sw	s3,12(sp)
     87c:	01412423          	sw	s4,8(sp)
    if (task_count >= MAX_TASKS) {
     880:	c8018693          	addi	a3,gp,-896 # 40000480 <task_count>
     884:	0006c783          	lbu	a5,0(a3)
     888:	00300713          	li	a4,3
     88c:	08f76663          	bltu	a4,a5,918 <task_create+0xb4>
    tasks[task_id].stack_base = task_stacks[task_id] + (STACK_SIZE/4 - 1);
     890:	00179413          	slli	s0,a5,0x1
     894:	00f40433          	add	s0,s0,a5
     898:	00879713          	slli	a4,a5,0x8
     89c:	81418493          	addi	s1,gp,-2028 # 40000014 <task_stacks>
     8a0:	00e484b3          	add	s1,s1,a4
     8a4:	00341713          	slli	a4,s0,0x3
     8a8:	c1418413          	addi	s0,gp,-1004 # 40000414 <tasks>
     8ac:	00e40433          	add	s0,s0,a4
     8b0:	00050813          	mv	a6,a0
     8b4:	0fc48713          	addi	a4,s1,252
    *(tasks[task_id].stack_ptr) = (uint32_t)task_func;  // PC
     8b8:	0f04ae23          	sw	a6,252(s1)
     8bc:	00058a13          	mv	s4,a1
     8c0:	00060993          	mv	s3,a2
    zero_stack_registers(tasks[task_id].stack_ptr, 31);
     8c4:	0f848513          	addi	a0,s1,248
    tasks[task_id].stack_base = task_stacks[task_id] + (STACK_SIZE/4 - 1);
     8c8:	00078913          	mv	s2,a5
     8cc:	00e42223          	sw	a4,4(s0)
    uint8_t task_id = task_count++;
     8d0:	00178793          	addi	a5,a5,1
    tasks[task_id].stack_ptr -= 31;
     8d4:	07c48493          	addi	s1,s1,124
    uint8_t task_id = task_count++;
     8d8:	00f68023          	sb	a5,0(a3)
    zero_stack_registers(tasks[task_id].stack_ptr, 31);
     8dc:	d61ff0ef          	jal	ra,63c <zero_stack_registers.constprop.0>
    tasks[task_id].stack_ptr -= 31;
     8e0:	00942023          	sw	s1,0(s0)
    tasks[task_id].priority = priority;
     8e4:	01440423          	sb	s4,8(s0)
    tasks[task_id].state = TASK_READY;
     8e8:	00042623          	sw	zero,12(s0)
    tasks[task_id].wake_time = 0;
     8ec:	00042823          	sw	zero,16(s0)
    tasks[task_id].name = name;
     8f0:	01342a23          	sw	s3,20(s0)
}
     8f4:	01c12083          	lw	ra,28(sp)
     8f8:	01812403          	lw	s0,24(sp)
     8fc:	01412483          	lw	s1,20(sp)
     900:	00c12983          	lw	s3,12(sp)
     904:	00812a03          	lw	s4,8(sp)
     908:	00090513          	mv	a0,s2
     90c:	01012903          	lw	s2,16(sp)
     910:	02010113          	addi	sp,sp,32
     914:	00008067          	ret
        return -1; // Nema više mesta
     918:	fff00913          	li	s2,-1
     91c:	fd9ff06f          	j	8f4 <task_create+0x90>

00000920 <task_yield>:

/*
 * Task yield - pozivaju task-ovi da predaju kontrolu
 */
void task_yield(void) {
    if (scheduler_started) {
     920:	c791c783          	lbu	a5,-903(gp) # 40000479 <scheduler_started>
     924:	00079463          	bnez	a5,92c <task_yield+0xc>
        schedule();
    }
}
     928:	00008067          	ret
    if (!scheduler_started) return;
     92c:	d59ff06f          	j	684 <schedule.part.0>

00000930 <kernel_run>:

/*
 * Main scheduler loop - poziva se iz main() funkcije
 */
void kernel_run(void) {
     930:	c7c1a503          	lw	a0,-900(gp) # 4000047c <system_tick>
     934:	c841a683          	lw	a3,-892(gp) # 40000484 <timer_last_tick>
    if ((current - timer_last_tick) >= timer_interval) {
     938:	400007b7          	lui	a5,0x40000
     93c:	0007a583          	lw	a1,0(a5) # 40000000 <timer_interval>
void kernel_run(void) {
     940:	fe010113          	addi	sp,sp,-32
    if (!scheduler_started) return;
     944:	c791ce03          	lbu	t3,-903(gp) # 40000479 <scheduler_started>
            tasks[i].wake_time <= system_tick) {
     948:	c1418613          	addi	a2,gp,-1004 # 40000414 <tasks>
void kernel_run(void) {
     94c:	00112e23          	sw	ra,28(sp)
     950:	00912a23          	sw	s1,20(sp)
     954:	01212823          	sw	s2,16(sp)
     958:	01312623          	sw	s3,12(sp)
     95c:	00812c23          	sw	s0,24(sp)
     960:	01412423          	sw	s4,8(sp)
    for (int i = 0; i < task_count; i++) {
     964:	c801c803          	lbu	a6,-896(gp) # 40000480 <task_count>
     968:	c781c983          	lbu	s3,-904(gp) # 40000478 <current_task>
            tasks[i].wake_time <= system_tick) {
     96c:	01062383          	lw	t2,16(a2) # 400010 <_etext+0x3feb6c>
     970:	02862083          	lw	ra,40(a2)
     974:	04062483          	lw	s1,64(a2)
     978:	05862903          	lw	s2,88(a2)
            tasks[i].priority < highest_priority) {
     97c:	00864283          	lbu	t0,8(a2)
     980:	02064f03          	lbu	t5,32(a2)
     984:	03864f83          	lbu	t6,56(a2)
     988:	05064403          	lbu	s0,80(a2)
     98c:	00150513          	addi	a0,a0,1
        if (tasks[current_task].state == TASK_RUNNING) {
     990:	00100313          	li	t1,1
        if (tasks[i].state == TASK_BLOCKED && 
     994:	00200893          	li	a7,2
    for (int i = 0; i < task_count; i++) {
     998:	00300e93          	li	t4,3
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
     99c:	c00027f3          	rdcycle	a5
    if ((current - timer_last_tick) >= timer_interval) {
     9a0:	40d78733          	sub	a4,a5,a3
     9a4:	feb76ce3          	bltu	a4,a1,99c <kernel_run+0x6c>
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
     9a8:	c0002773          	rdcycle	a4
    if (!scheduler_started) return;
     9ac:	0a0e0e63          	beqz	t3,a68 <kernel_run+0x138>
    for (int i = 0; i < task_count; i++) {
     9b0:	10080063          	beqz	a6,ab0 <kernel_run+0x180>
        if (tasks[i].state == TASK_BLOCKED && 
     9b4:	00c62703          	lw	a4,12(a2)
     9b8:	0d170063          	beq	a4,a7,a78 <kernel_run+0x148>
    for (int i = 0; i < task_count; i++) {
     9bc:	0c680463          	beq	a6,t1,a84 <kernel_run+0x154>
        if (tasks[i].state == TASK_BLOCKED && 
     9c0:	02462703          	lw	a4,36(a2)
     9c4:	0d170a63          	beq	a4,a7,a98 <kernel_run+0x168>
    for (int i = 0; i < task_count; i++) {
     9c8:	01180c63          	beq	a6,a7,9e0 <kernel_run+0xb0>
        if (tasks[i].state == TASK_BLOCKED && 
     9cc:	03c62703          	lw	a4,60(a2)
     9d0:	0d170a63          	beq	a4,a7,aa4 <kernel_run+0x174>
    for (int i = 0; i < task_count; i++) {
     9d4:	01d80663          	beq	a6,t4,9e0 <kernel_run+0xb0>
        if (tasks[i].state == TASK_BLOCKED && 
     9d8:	05462703          	lw	a4,84(a2)
     9dc:	0d170e63          	beq	a4,a7,ab8 <kernel_run+0x188>
        if (tasks[i].state == TASK_READY && 
     9e0:	00c62703          	lw	a4,12(a2)
     9e4:	0a070463          	beqz	a4,a8c <kernel_run+0x15c>
     9e8:	0ff00713          	li	a4,255
     9ec:	02462a03          	lw	s4,36(a2)
     9f0:	00000693          	li	a3,0
     9f4:	000a1863          	bnez	s4,a04 <kernel_run+0xd4>
     9f8:	00ef7663          	bgeu	t5,a4,a04 <kernel_run+0xd4>
     9fc:	000f0713          	mv	a4,t5
            selected_task = i;
     a00:	00100693          	li	a3,1
    for (int i = 0; i < task_count; i++) {
     a04:	0308d663          	bge	a7,a6,a30 <kernel_run+0x100>
        if (tasks[i].state == TASK_READY && 
     a08:	03c62a03          	lw	s4,60(a2)
     a0c:	000a1863          	bnez	s4,a1c <kernel_run+0xec>
     a10:	00eff663          	bgeu	t6,a4,a1c <kernel_run+0xec>
     a14:	000f8713          	mv	a4,t6
            selected_task = i;
     a18:	00200693          	li	a3,2
    for (int i = 0; i < task_count; i++) {
     a1c:	01d80a63          	beq	a6,t4,a30 <kernel_run+0x100>
        if (tasks[i].state == TASK_READY && 
     a20:	05462a03          	lw	s4,84(a2)
     a24:	000a1663          	bnez	s4,a30 <kernel_run+0x100>
     a28:	00e47463          	bgeu	s0,a4,a30 <kernel_run+0x100>
            selected_task = i;
     a2c:	00300693          	li	a3,3
    if (next_task != current_task) {
     a30:	02d98c63          	beq	s3,a3,a68 <kernel_run+0x138>
        if (tasks[current_task].state == TASK_RUNNING) {
     a34:	00199713          	slli	a4,s3,0x1
     a38:	01370733          	add	a4,a4,s3
     a3c:	00371713          	slli	a4,a4,0x3
     a40:	00e60733          	add	a4,a2,a4
     a44:	00c72983          	lw	s3,12(a4)
     a48:	00699463          	bne	s3,t1,a50 <kernel_run+0x120>
            tasks[current_task].state = TASK_READY;
     a4c:	00072623          	sw	zero,12(a4)
        tasks[next_task].state = TASK_RUNNING;
     a50:	00169713          	slli	a4,a3,0x1
     a54:	00d70733          	add	a4,a4,a3
     a58:	00371713          	slli	a4,a4,0x3
     a5c:	00e60733          	add	a4,a2,a4
     a60:	00672623          	sw	t1,12(a4)
}
     a64:	00068993          	mv	s3,a3
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
     a68:	c0002773          	rdcycle	a4
    perf_stats.interrupt_count++;
     a6c:	00150513          	addi	a0,a0,1
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
     a70:	00078693          	mv	a3,a5
}
     a74:	f29ff06f          	j	99c <kernel_run+0x6c>
        if (tasks[i].state == TASK_BLOCKED && 
     a78:	f47562e3          	bltu	a0,t2,9bc <kernel_run+0x8c>
            tasks[i].state = TASK_READY;
     a7c:	00062623          	sw	zero,12(a2)
    for (int i = 0; i < task_count; i++) {
     a80:	f46810e3          	bne	a6,t1,9c0 <kernel_run+0x90>
        if (tasks[i].state == TASK_READY && 
     a84:	00c62703          	lw	a4,12(a2)
     a88:	02071463          	bnez	a4,ab0 <kernel_run+0x180>
    for (int i = 0; i < task_count; i++) {
     a8c:	02680263          	beq	a6,t1,ab0 <kernel_run+0x180>
     a90:	00028713          	mv	a4,t0
     a94:	f59ff06f          	j	9ec <kernel_run+0xbc>
        if (tasks[i].state == TASK_BLOCKED && 
     a98:	f21568e3          	bltu	a0,ra,9c8 <kernel_run+0x98>
            tasks[i].state = TASK_READY;
     a9c:	02062223          	sw	zero,36(a2)
     aa0:	f29ff06f          	j	9c8 <kernel_run+0x98>
        if (tasks[i].state == TASK_BLOCKED && 
     aa4:	f29568e3          	bltu	a0,s1,9d4 <kernel_run+0xa4>
            tasks[i].state = TASK_READY;
     aa8:	02062e23          	sw	zero,60(a2)
     aac:	f29ff06f          	j	9d4 <kernel_run+0xa4>
    uint8_t selected_task = 0;
     ab0:	00000693          	li	a3,0
     ab4:	f7dff06f          	j	a30 <kernel_run+0x100>
        if (tasks[i].state == TASK_BLOCKED && 
     ab8:	f32564e3          	bltu	a0,s2,9e0 <kernel_run+0xb0>
            tasks[i].state = TASK_READY;
     abc:	04062a23          	sw	zero,84(a2)
    for (int i = 0; i < task_count; i++) {
     ac0:	f21ff06f          	j	9e0 <kernel_run+0xb0>

00000ac4 <kernel_init>:
}

/*
 * Kernel inicijalizacija i start
 */
void kernel_init(void) {
     ac4:	fe010113          	addi	sp,sp,-32
    // Reset svih task-ova - eksplicitno jedan po jedan
    volatile int i;  // volatile sprečava optimizaciju
    for (i = 0; i < MAX_TASKS; i++) {
     ac8:	00012623          	sw	zero,12(sp)
     acc:	00c12703          	lw	a4,12(sp)
void kernel_init(void) {
     ad0:	00812e23          	sw	s0,28(sp)
    for (i = 0; i < MAX_TASKS; i++) {
     ad4:	00300793          	li	a5,3
     ad8:	0ae7cc63          	blt	a5,a4,b90 <kernel_init+0xcc>
     adc:	00001337          	lui	t1,0x1
     ae0:	c1418813          	addi	a6,gp,-1004 # 40000414 <tasks>
     ae4:	23830313          	addi	t1,t1,568 # 1238 <rt_main_loop+0xfc>
        tasks[i].state = TASK_TERMINATED;
     ae8:	00300893          	li	a7,3
     aec:	00c12403          	lw	s0,12(sp)
        tasks[i].priority = 0;
     af0:	00c12383          	lw	t2,12(sp)
        tasks[i].wake_time = 0;
     af4:	00c12283          	lw	t0,12(sp)
        tasks[i].name = "unused";
     af8:	00c12f83          	lw	t6,12(sp)
        tasks[i].stack_base = 0;
     afc:	00c12f03          	lw	t5,12(sp)
        tasks[i].stack_ptr = 0;
     b00:	00c12e83          	lw	t4,12(sp)
    for (i = 0; i < MAX_TASKS; i++) {
     b04:	00c12e03          	lw	t3,12(sp)
        tasks[i].state = TASK_TERMINATED;
     b08:	00141513          	slli	a0,s0,0x1
        tasks[i].priority = 0;
     b0c:	00139593          	slli	a1,t2,0x1
    for (i = 0; i < MAX_TASKS; i++) {
     b10:	001e0e13          	addi	t3,t3,1
        tasks[i].wake_time = 0;
     b14:	00129613          	slli	a2,t0,0x1
        tasks[i].name = "unused";
     b18:	001f9693          	slli	a3,t6,0x1
        tasks[i].stack_base = 0;
     b1c:	001f1713          	slli	a4,t5,0x1
        tasks[i].stack_ptr = 0;
     b20:	001e9793          	slli	a5,t4,0x1
        tasks[i].state = TASK_TERMINATED;
     b24:	00850533          	add	a0,a0,s0
        tasks[i].priority = 0;
     b28:	007585b3          	add	a1,a1,t2
        tasks[i].wake_time = 0;
     b2c:	00560633          	add	a2,a2,t0
        tasks[i].name = "unused";
     b30:	01f686b3          	add	a3,a3,t6
        tasks[i].stack_base = 0;
     b34:	01e70733          	add	a4,a4,t5
        tasks[i].stack_ptr = 0;
     b38:	01d787b3          	add	a5,a5,t4
    for (i = 0; i < MAX_TASKS; i++) {
     b3c:	01c12623          	sw	t3,12(sp)
        tasks[i].state = TASK_TERMINATED;
     b40:	00351513          	slli	a0,a0,0x3
        tasks[i].priority = 0;
     b44:	00359593          	slli	a1,a1,0x3
        tasks[i].wake_time = 0;
     b48:	00361613          	slli	a2,a2,0x3
        tasks[i].name = "unused";
     b4c:	00369693          	slli	a3,a3,0x3
        tasks[i].stack_base = 0;
     b50:	00371713          	slli	a4,a4,0x3
        tasks[i].stack_ptr = 0;
     b54:	00379793          	slli	a5,a5,0x3
    for (i = 0; i < MAX_TASKS; i++) {
     b58:	00c12e03          	lw	t3,12(sp)
        tasks[i].state = TASK_TERMINATED;
     b5c:	00a80533          	add	a0,a6,a0
        tasks[i].priority = 0;
     b60:	00b805b3          	add	a1,a6,a1
        tasks[i].wake_time = 0;
     b64:	00c80633          	add	a2,a6,a2
        tasks[i].name = "unused";
     b68:	00d806b3          	add	a3,a6,a3
        tasks[i].stack_base = 0;
     b6c:	00e80733          	add	a4,a6,a4
        tasks[i].stack_ptr = 0;
     b70:	00f807b3          	add	a5,a6,a5
        tasks[i].state = TASK_TERMINATED;
     b74:	01152623          	sw	a7,12(a0)
        tasks[i].priority = 0;
     b78:	00058423          	sb	zero,8(a1)
        tasks[i].wake_time = 0;
     b7c:	00062823          	sw	zero,16(a2)
        tasks[i].name = "unused";
     b80:	0066aa23          	sw	t1,20(a3)
        tasks[i].stack_base = 0;
     b84:	00072223          	sw	zero,4(a4)
        tasks[i].stack_ptr = 0;
     b88:	0007a023          	sw	zero,0(a5)
    for (i = 0; i < MAX_TASKS; i++) {
     b8c:	f7c8d0e3          	bge	a7,t3,aec <kernel_init+0x28>
    }
    
    current_task = 0;
     b90:	c6018c23          	sb	zero,-904(gp) # 40000478 <current_task>
    // Reset performance counters - eksplicitno
    perf_stats.context_switches = 0;
    perf_stats.tick_count = 0;
    perf_stats.interrupt_latency_sum = 0;
    perf_stats.interrupt_count = 0;
}
     b94:	01c12403          	lw	s0,28(sp)
    task_count = 0;
     b98:	c8018023          	sb	zero,-896(gp) # 40000480 <task_count>
    perf_stats.context_switches = 0;
     b9c:	400007b7          	lui	a5,0x40000
     ba0:	00478793          	addi	a5,a5,4 # 40000004 <perf_stats>
    system_tick = 0;
     ba4:	c601ae23          	sw	zero,-900(gp) # 4000047c <system_tick>
    scheduler_started = false;
     ba8:	c6018ca3          	sb	zero,-903(gp) # 40000479 <scheduler_started>
    perf_stats.context_switches = 0;
     bac:	0007a023          	sw	zero,0(a5)
    perf_stats.tick_count = 0;
     bb0:	0007a223          	sw	zero,4(a5)
    perf_stats.interrupt_latency_sum = 0;
     bb4:	0007a423          	sw	zero,8(a5)
    perf_stats.interrupt_count = 0;
     bb8:	0007a623          	sw	zero,12(a5)
}
     bbc:	02010113          	addi	sp,sp,32
     bc0:	00008067          	ret

00000bc4 <kernel_start>:

void kernel_start(void) {
    if (task_count == 0) {
     bc4:	c801c783          	lbu	a5,-896(gp) # 40000480 <task_count>
     bc8:	02078663          	beqz	a5,bf4 <kernel_start+0x30>
        return; // Nema task-ova za pokretanje
    }
    
    // Prvi task postaje current
    tasks[0].state = TASK_RUNNING;
     bcc:	00100793          	li	a5,1
     bd0:	c2f1a023          	sw	a5,-992(gp) # 40000420 <tasks+0xc>
    current_task = 0;
     bd4:	c6018c23          	sb	zero,-904(gp) # 40000478 <current_task>
    
    scheduler_started = true;
     bd8:	c6f18ca3          	sb	a5,-903(gp) # 40000479 <scheduler_started>
    timer_interval = 25175000 / frequency;
     bdc:	000067b7          	lui	a5,0x6
     be0:	40000737          	lui	a4,0x40000
     be4:	25778793          	addi	a5,a5,599 # 6257 <_etext+0x4db3>
     be8:	00f72023          	sw	a5,0(a4) # 40000000 <timer_interval>
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
     bec:	c0002773          	rdcycle	a4
    timer_last_tick = get_cycle_count();
     bf0:	c8e1a223          	sw	a4,-892(gp) # 40000484 <timer_last_tick>
    // Konfiguracija timer-a (ovo zavisi od PicoTiny implementacije)
    configure_system_timer(TICK_FREQUENCY);
    
    // Pokreni prvi task
    start_first_task();
}
     bf4:	00008067          	ret

00000bf8 <get_context_switch_count>:

/*
 * Performance monitoring funkcije
 */
uint32_t get_context_switch_count(void) {
    return perf_stats.context_switches;
     bf8:	400007b7          	lui	a5,0x40000
}
     bfc:	0047a503          	lw	a0,4(a5) # 40000004 <perf_stats>
     c00:	00008067          	ret

00000c04 <get_average_interrupt_latency>:

uint32_t get_average_interrupt_latency(void) {
    if (perf_stats.interrupt_count == 0) return 0;
     c04:	400007b7          	lui	a5,0x40000
     c08:	00478793          	addi	a5,a5,4 # 40000004 <perf_stats>
     c0c:	00c7a583          	lw	a1,12(a5)
     c10:	02058063          	beqz	a1,c30 <get_average_interrupt_latency+0x2c>
    return perf_stats.interrupt_latency_sum / perf_stats.interrupt_count;
     c14:	0087a503          	lw	a0,8(a5)
uint32_t get_average_interrupt_latency(void) {
     c18:	ff010113          	addi	sp,sp,-16
     c1c:	00112623          	sw	ra,12(sp)
    return perf_stats.interrupt_latency_sum / perf_stats.interrupt_count;
     c20:	d18ff0ef          	jal	ra,138 <__udivsi3>
}
     c24:	00c12083          	lw	ra,12(sp)
     c28:	01010113          	addi	sp,sp,16
     c2c:	00008067          	ret
     c30:	00058513          	mv	a0,a1
     c34:	00008067          	ret

00000c38 <get_system_uptime>:

uint32_t get_system_uptime(void) {
    return system_tick;
}
     c38:	c7c1a503          	lw	a0,-900(gp) # 4000047c <system_tick>
     c3c:	00008067          	ret

00000c40 <print_task_info>:

void print_task_info(void) {
     c40:	fc010113          	addi	sp,sp,-64
     c44:	03212823          	sw	s2,48(sp)
    // Debug funkcija za UART output
    for (int i = 0; i < task_count; i++) {
     c48:	c8018913          	addi	s2,gp,-896 # 40000480 <task_count>
     c4c:	00094783          	lbu	a5,0(s2)
void print_task_info(void) {
     c50:	02112e23          	sw	ra,60(sp)
     c54:	02812c23          	sw	s0,56(sp)
     c58:	02912a23          	sw	s1,52(sp)
     c5c:	03312623          	sw	s3,44(sp)
     c60:	03412423          	sw	s4,40(sp)
     c64:	03512223          	sw	s5,36(sp)
     c68:	03612023          	sw	s6,32(sp)
     c6c:	01712e23          	sw	s7,28(sp)
     c70:	01812c23          	sw	s8,24(sp)
     c74:	01912a23          	sw	s9,20(sp)
     c78:	01a12823          	sw	s10,16(sp)
     c7c:	01b12623          	sw	s11,12(sp)
    for (int i = 0; i < task_count; i++) {
     c80:	0e078663          	beqz	a5,d6c <print_task_info+0x12c>
     c84:	00001b37          	lui	s6,0x1
     c88:	00001ab7          	lui	s5,0x1
     c8c:	00001a37          	lui	s4,0x1
     c90:	c2018493          	addi	s1,gp,-992 # 40000420 <tasks+0xc>
     c94:	00000413          	li	s0,0
     c98:	248b0b13          	addi	s6,s6,584 # 1248 <rt_main_loop+0x10c>
     c9c:	24ca8a93          	addi	s5,s5,588 # 124c <rt_main_loop+0x110>
     ca0:	240a0a13          	addi	s4,s4,576 # 1240 <rt_main_loop+0x104>
        uart_printf("Task[");
        // Simple number printing
        if (i == 0) uart_printf("0");
        else if (i == 1) uart_printf("1");
     ca4:	00100993          	li	s3,1
        else if (i == 2) uart_printf("2");
     ca8:	00200b93          	li	s7,2
        else if (i == 3) uart_printf("3");
     cac:	00300c93          	li	s9,3
    const char* p = format;
     cb0:	00001c37          	lui	s8,0x1
     cb4:	00001d37          	lui	s10,0x1
     cb8:	000a0d93          	mv	s11,s4
    while (*p) {
     cbc:	05400513          	li	a0,84
        p++;
     cc0:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     cc4:	d20ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     cc8:	000dc503          	lbu	a0,0(s11)
     ccc:	fe051ae3          	bnez	a0,cc0 <print_task_info+0x80>
        if (i == 0) uart_printf("0");
     cd0:	10040663          	beqz	s0,ddc <print_task_info+0x19c>
        else if (i == 1) uart_printf("1");
     cd4:	19340263          	beq	s0,s3,e58 <print_task_info+0x218>
        else if (i == 2) uart_printf("2");
     cd8:	19740663          	beq	s0,s7,e64 <print_task_info+0x224>
        else if (i == 3) uart_printf("3");
     cdc:	19940a63          	beq	s0,s9,e70 <print_task_info+0x230>
    while (*p) {
     ce0:	000b0d93          	mv	s11,s6
     ce4:	05d00513          	li	a0,93
        p++;
     ce8:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     cec:	cf8ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     cf0:	000dc503          	lbu	a0,0(s11)
     cf4:	fe051ae3          	bnez	a0,ce8 <print_task_info+0xa8>
        uart_printf("]: ");
        uart_printf(tasks[i].name);
     cf8:	0084ad83          	lw	s11,8(s1)
    while (*p) {
     cfc:	000dc503          	lbu	a0,0(s11)
     d00:	00050a63          	beqz	a0,d14 <print_task_info+0xd4>
        p++;
     d04:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     d08:	cdcff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     d0c:	000dc503          	lbu	a0,0(s11)
     d10:	fe051ae3          	bnez	a0,d04 <print_task_info+0xc4>
    const char* p = format;
     d14:	000a8d93          	mv	s11,s5
    while (*p) {
     d18:	02c00513          	li	a0,44
        p++;
     d1c:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     d20:	cc4ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     d24:	000dc503          	lbu	a0,0(s11)
     d28:	fe051ae3          	bnez	a0,d1c <print_task_info+0xdc>
        uart_printf(", State: ");
        if (tasks[i].state == 0) uart_printf("READY");
     d2c:	0004a703          	lw	a4,0(s1)
     d30:	06070c63          	beqz	a4,da8 <print_task_info+0x168>
        else if (tasks[i].state == 1) uart_printf("RUNNING");
     d34:	0f370663          	beq	a4,s3,e20 <print_task_info+0x1e0>
    const char* p = format;
     d38:	270c0d93          	addi	s11,s8,624 # 1270 <rt_main_loop+0x134>
    while (*p) {
     d3c:	05400513          	li	a0,84
        else if (tasks[i].state == 2) uart_printf("BLOCKED");
     d40:	0b770463          	beq	a4,s7,de8 <print_task_info+0x1a8>
        p++;
     d44:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     d48:	c9cff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     d4c:	000dc503          	lbu	a0,0(s11)
     d50:	fe051ae3          	bnez	a0,d44 <print_task_info+0x104>
        putchar(*p);
     d54:	00a00513          	li	a0,10
     d58:	c8cff0ef          	jal	ra,1e4 <putchar>
    for (int i = 0; i < task_count; i++) {
     d5c:	00094783          	lbu	a5,0(s2)
     d60:	00140413          	addi	s0,s0,1
     d64:	01848493          	addi	s1,s1,24
     d68:	f4f448e3          	blt	s0,a5,cb8 <print_task_info+0x78>
        else uart_printf("TERMINATED");
        uart_printf("\n");
    }
     d6c:	03c12083          	lw	ra,60(sp)
     d70:	03812403          	lw	s0,56(sp)
     d74:	03412483          	lw	s1,52(sp)
     d78:	03012903          	lw	s2,48(sp)
     d7c:	02c12983          	lw	s3,44(sp)
     d80:	02812a03          	lw	s4,40(sp)
     d84:	02412a83          	lw	s5,36(sp)
     d88:	02012b03          	lw	s6,32(sp)
     d8c:	01c12b83          	lw	s7,28(sp)
     d90:	01812c03          	lw	s8,24(sp)
     d94:	01412c83          	lw	s9,20(sp)
     d98:	01012d03          	lw	s10,16(sp)
     d9c:	00c12d83          	lw	s11,12(sp)
     da0:	04010113          	addi	sp,sp,64
     da4:	00008067          	ret
    const char* p = format;
     da8:	258d0d93          	addi	s11,s10,600 # 1258 <rt_main_loop+0x11c>
    while (*p) {
     dac:	05200513          	li	a0,82
        p++;
     db0:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     db4:	c30ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     db8:	000dc503          	lbu	a0,0(s11)
     dbc:	fe051ae3          	bnez	a0,db0 <print_task_info+0x170>
        putchar(*p);
     dc0:	00a00513          	li	a0,10
     dc4:	c20ff0ef          	jal	ra,1e4 <putchar>
    for (int i = 0; i < task_count; i++) {
     dc8:	00094783          	lbu	a5,0(s2)
     dcc:	00140413          	addi	s0,s0,1
     dd0:	01848493          	addi	s1,s1,24
     dd4:	eef442e3          	blt	s0,a5,cb8 <print_task_info+0x78>
     dd8:	f95ff06f          	j	d6c <print_task_info+0x12c>
        putchar(*p);
     ddc:	03000513          	li	a0,48
     de0:	c04ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     de4:	efdff06f          	j	ce0 <print_task_info+0xa0>
    const char* p = format;
     de8:	000017b7          	lui	a5,0x1
     dec:	26878d93          	addi	s11,a5,616 # 1268 <rt_main_loop+0x12c>
    while (*p) {
     df0:	04200513          	li	a0,66
        p++;
     df4:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     df8:	becff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     dfc:	000dc503          	lbu	a0,0(s11)
     e00:	fe051ae3          	bnez	a0,df4 <print_task_info+0x1b4>
        putchar(*p);
     e04:	00a00513          	li	a0,10
     e08:	bdcff0ef          	jal	ra,1e4 <putchar>
    for (int i = 0; i < task_count; i++) {
     e0c:	00094783          	lbu	a5,0(s2)
     e10:	00140413          	addi	s0,s0,1
     e14:	01848493          	addi	s1,s1,24
     e18:	eaf440e3          	blt	s0,a5,cb8 <print_task_info+0x78>
     e1c:	f51ff06f          	j	d6c <print_task_info+0x12c>
    const char* p = format;
     e20:	000017b7          	lui	a5,0x1
     e24:	26078d93          	addi	s11,a5,608 # 1260 <rt_main_loop+0x124>
    while (*p) {
     e28:	05200513          	li	a0,82
        p++;
     e2c:	001d8d93          	addi	s11,s11,1
        putchar(*p);
     e30:	bb4ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     e34:	000dc503          	lbu	a0,0(s11)
     e38:	fe051ae3          	bnez	a0,e2c <print_task_info+0x1ec>
        putchar(*p);
     e3c:	00a00513          	li	a0,10
     e40:	ba4ff0ef          	jal	ra,1e4 <putchar>
    for (int i = 0; i < task_count; i++) {
     e44:	00094783          	lbu	a5,0(s2)
     e48:	00140413          	addi	s0,s0,1
     e4c:	01848493          	addi	s1,s1,24
     e50:	e6f444e3          	blt	s0,a5,cb8 <print_task_info+0x78>
     e54:	f19ff06f          	j	d6c <print_task_info+0x12c>
        putchar(*p);
     e58:	03100513          	li	a0,49
     e5c:	b88ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     e60:	e81ff06f          	j	ce0 <print_task_info+0xa0>
        putchar(*p);
     e64:	03200513          	li	a0,50
     e68:	b7cff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     e6c:	e75ff06f          	j	ce0 <print_task_info+0xa0>
        putchar(*p);
     e70:	03300513          	li	a0,51
     e74:	b70ff0ef          	jal	ra,1e4 <putchar>
    while (*p) {
     e78:	e69ff06f          	j	ce0 <print_task_info+0xa0>

00000e7c <led_blink_task>:

/*
 * Task 1: LED Blink Task
 * Blinka LED-om na GPIO pin-u svakih 500ms
 */
void led_blink_task(void) {
     e7c:	fe010113          	addi	sp,sp,-32
     e80:	00812c23          	sw	s0,24(sp)
     e84:	00912a23          	sw	s1,20(sp)
     e88:	01212823          	sw	s2,16(sp)
     e8c:	01312623          	sw	s3,12(sp)
     e90:	01412423          	sw	s4,8(sp)
     e94:	00112e23          	sw	ra,28(sp)
    static uint32_t last_toggle = 0;
    uint32_t current_time = get_system_uptime();
     e98:	da1ff0ef          	jal	ra,c38 <get_system_uptime>
     e9c:	00050413          	mv	s0,a0
     ea0:	c9818493          	addi	s1,gp,-872 # 40000498 <last_toggle.4>
     ea4:	00001a37          	lui	s4,0x1
    
    while (1) {
        if ((current_time - last_toggle) >= 500) { // 500ms
     ea8:	1f300993          	li	s3,499
            // Zameni: GPIO0->OUT ^= 0x01;
            *((volatile uint32_t*)0x82000004) ^= 0x01;
     eac:	82000937          	lui	s2,0x82000
        if ((current_time - last_toggle) >= 500) { // 500ms
     eb0:	0004a783          	lw	a5,0(s1)
            last_toggle = current_time;
            uart_printf("LED Toggle at tick %d\n", current_time);
     eb4:	00040593          	mv	a1,s0
     eb8:	27ca0513          	addi	a0,s4,636 # 127c <rt_main_loop+0x140>
        if ((current_time - last_toggle) >= 500) { // 500ms
     ebc:	40f407b3          	sub	a5,s0,a5
     ec0:	00f9fc63          	bgeu	s3,a5,ed8 <led_blink_task+0x5c>
            *((volatile uint32_t*)0x82000004) ^= 0x01;
     ec4:	00492783          	lw	a5,4(s2) # 82000004 <_stack_start+0x41fff764>
     ec8:	0017c793          	xori	a5,a5,1
     ecc:	00f92223          	sw	a5,4(s2)
            last_toggle = current_time;
     ed0:	0084a023          	sw	s0,0(s1)
            uart_printf("LED Toggle at tick %d\n", current_time);
     ed4:	93dff0ef          	jal	ra,810 <uart_printf>
        }
        
        current_time = get_system_uptime();
     ed8:	d61ff0ef          	jal	ra,c38 <get_system_uptime>
     edc:	00050413          	mv	s0,a0
        task_yield(); // Predaj kontrolu drugim task-ovima
     ee0:	a41ff0ef          	jal	ra,920 <task_yield>
        if ((current_time - last_toggle) >= 500) { // 500ms
     ee4:	fcdff06f          	j	eb0 <led_blink_task+0x34>

00000ee8 <counter_task>:

/*
 * Task 3: Counter Task
 * Broji i periodično izveštava
 */
void counter_task(void) {
     ee8:	fe010113          	addi	sp,sp,-32
     eec:	00812c23          	sw	s0,24(sp)
     ef0:	00912a23          	sw	s1,20(sp)
     ef4:	01212823          	sw	s2,16(sp)
     ef8:	01312623          	sw	s3,12(sp)
     efc:	01412423          	sw	s4,8(sp)
     f00:	00112e23          	sw	ra,28(sp)
    static uint32_t counter = 0;
    static uint32_t last_report = 0;
    uint32_t current_time = get_system_uptime();
     f04:	d35ff0ef          	jal	ra,c38 <get_system_uptime>
     f08:	00050413          	mv	s0,a0
     f0c:	c8818493          	addi	s1,gp,-888 # 40000488 <counter.2>
     f10:	c9418913          	addi	s2,gp,-876 # 40000494 <last_report.1>
     f14:	00001a37          	lui	s4,0x1
    
    while (1) {
        counter++;
        
        if ((current_time - last_report) >= 2000) { // 2000ms
     f18:	7cf00993          	li	s3,1999
        counter++;
     f1c:	0004a583          	lw	a1,0(s1)
        if ((current_time - last_report) >= 2000) { // 2000ms
     f20:	00092783          	lw	a5,0(s2)
            uart_printf("Counter Task: %d iterations\n", counter);
     f24:	294a0513          	addi	a0,s4,660 # 1294 <rt_main_loop+0x158>
        counter++;
     f28:	00158593          	addi	a1,a1,1
        if ((current_time - last_report) >= 2000) { // 2000ms
     f2c:	40f407b3          	sub	a5,s0,a5
        counter++;
     f30:	00b4a023          	sw	a1,0(s1)
        if ((current_time - last_report) >= 2000) { // 2000ms
     f34:	00f9f663          	bgeu	s3,a5,f40 <counter_task+0x58>
            uart_printf("Counter Task: %d iterations\n", counter);
     f38:	8d9ff0ef          	jal	ra,810 <uart_printf>
            last_report = current_time;
     f3c:	00892023          	sw	s0,0(s2)
        }
        
        current_time = get_system_uptime();
     f40:	cf9ff0ef          	jal	ra,c38 <get_system_uptime>
     f44:	00050413          	mv	s0,a0
        task_yield();
     f48:	9d9ff0ef          	jal	ra,920 <task_yield>
        counter++;
     f4c:	fd1ff06f          	j	f1c <counter_task+0x34>

00000f50 <gpio_monitor_task>:

/*
 * Task 4: GPIO Monitor Task
 * Čita GPIO input stanje i reaguje na promene
 */
void gpio_monitor_task(void) {
     f50:	fe010113          	addi	sp,sp,-32
     f54:	00912a23          	sw	s1,20(sp)
     f58:	01212823          	sw	s2,16(sp)
     f5c:	01312623          	sw	s3,12(sp)
     f60:	00112e23          	sw	ra,28(sp)
     f64:	00812c23          	sw	s0,24(sp)
     f68:	c9018493          	addi	s1,gp,-880 # 40000490 <last_gpio_state.0>
     f6c:	000019b7          	lui	s3,0x1
    static uint32_t last_gpio_state = 0;
    uint32_t current_gpio;
    
    while (1) {
        // Zameni: current_gpio = GPIO0->IN;
        current_gpio = *((volatile uint32_t*)0x82000000);
     f70:	82000937          	lui	s2,0x82000
     f74:	00092403          	lw	s0,0(s2) # 82000000 <_stack_start+0x41fff760>
        
        if (current_gpio != last_gpio_state) {
     f78:	0004a583          	lw	a1,0(s1)
            uart_printf("GPIO State Change: 0x%08x -> 0x%08x\n", 
     f7c:	2b498513          	addi	a0,s3,692 # 12b4 <rt_main_loop+0x178>
     f80:	00040613          	mv	a2,s0
        if (current_gpio != last_gpio_state) {
     f84:	00858663          	beq	a1,s0,f90 <gpio_monitor_task+0x40>
            uart_printf("GPIO State Change: 0x%08x -> 0x%08x\n", 
     f88:	889ff0ef          	jal	ra,810 <uart_printf>
                       last_gpio_state, current_gpio);
            last_gpio_state = current_gpio;
     f8c:	0084a023          	sw	s0,0(s1)
        }
        
        task_yield();
     f90:	991ff0ef          	jal	ra,920 <task_yield>
        current_gpio = *((volatile uint32_t*)0x82000000);
     f94:	fe1ff06f          	j	f74 <gpio_monitor_task+0x24>

00000f98 <uart_debug_task>:
void uart_debug_task(void) {
     f98:	fd010113          	addi	sp,sp,-48
     f9c:	02812423          	sw	s0,40(sp)
     fa0:	02912223          	sw	s1,36(sp)
     fa4:	03212023          	sw	s2,32(sp)
     fa8:	01312e23          	sw	s3,28(sp)
     fac:	01412c23          	sw	s4,24(sp)
     fb0:	01512a23          	sw	s5,20(sp)
     fb4:	01612823          	sw	s6,16(sp)
     fb8:	01712623          	sw	s7,12(sp)
     fbc:	02112623          	sw	ra,44(sp)
    uint32_t current_time = get_system_uptime();
     fc0:	c79ff0ef          	jal	ra,c38 <get_system_uptime>
     fc4:	00050413          	mv	s0,a0
     fc8:	c8c18493          	addi	s1,gp,-884 # 4000048c <last_debug.3>
     fcc:	000019b7          	lui	s3,0x1
     fd0:	00001bb7          	lui	s7,0x1
     fd4:	00001b37          	lui	s6,0x1
     fd8:	00001ab7          	lui	s5,0x1
     fdc:	00001a37          	lui	s4,0x1
        if ((current_time - last_debug) >= 1000) { // 1000ms
     fe0:	3e700913          	li	s2,999
     fe4:	0004a783          	lw	a5,0(s1)
            uart_printf("=== RT System Status ===\n");
     fe8:	2dc98513          	addi	a0,s3,732 # 12dc <rt_main_loop+0x1a0>
        if ((current_time - last_debug) >= 1000) { // 1000ms
     fec:	40f407b3          	sub	a5,s0,a5
     ff0:	04f97263          	bgeu	s2,a5,1034 <uart_debug_task+0x9c>
            uart_printf("=== RT System Status ===\n");
     ff4:	81dff0ef          	jal	ra,810 <uart_printf>
            uart_printf("Uptime: %d ticks\n", current_time);
     ff8:	00040593          	mv	a1,s0
     ffc:	2f8b8513          	addi	a0,s7,760 # 12f8 <rt_main_loop+0x1bc>
    1000:	811ff0ef          	jal	ra,810 <uart_printf>
            uart_printf("Context switches: %d\n", get_context_switch_count());
    1004:	bf5ff0ef          	jal	ra,bf8 <get_context_switch_count>
    1008:	00050593          	mv	a1,a0
    100c:	30cb0513          	addi	a0,s6,780 # 130c <rt_main_loop+0x1d0>
    1010:	801ff0ef          	jal	ra,810 <uart_printf>
            uart_printf("Avg interrupt latency: %d cycles\n", get_average_interrupt_latency());
    1014:	bf1ff0ef          	jal	ra,c04 <get_average_interrupt_latency>
    1018:	00050593          	mv	a1,a0
    101c:	324a8513          	addi	a0,s5,804 # 1324 <rt_main_loop+0x1e8>
    1020:	ff0ff0ef          	jal	ra,810 <uart_printf>
            print_task_info();
    1024:	c1dff0ef          	jal	ra,c40 <print_task_info>
            uart_printf("========================\n");
    1028:	348a0513          	addi	a0,s4,840 # 1348 <rt_main_loop+0x20c>
    102c:	fe4ff0ef          	jal	ra,810 <uart_printf>
            last_debug = current_time;
    1030:	0084a023          	sw	s0,0(s1)
        current_time = get_system_uptime();
    1034:	c05ff0ef          	jal	ra,c38 <get_system_uptime>
    1038:	00050413          	mv	s0,a0
        task_yield();
    103c:	8e5ff0ef          	jal	ra,920 <task_yield>
        if ((current_time - last_debug) >= 1000) { // 1000ms
    1040:	fa5ff06f          	j	fe4 <uart_debug_task+0x4c>

00001044 <rt_system_init>:

/*
 * Inicijalizacija RT sistema
 */
void rt_system_init(void) {
    uart_printf("\n=== PicoTiny Real-Time Kernel Demo ===\n");
    1044:	00001537          	lui	a0,0x1
void rt_system_init(void) {
    1048:	ff010113          	addi	sp,sp,-16
    uart_printf("\n=== PicoTiny Real-Time Kernel Demo ===\n");
    104c:	36450513          	addi	a0,a0,868 # 1364 <rt_main_loop+0x228>
void rt_system_init(void) {
    1050:	00112623          	sw	ra,12(sp)
    uart_printf("\n=== PicoTiny Real-Time Kernel Demo ===\n");
    1054:	fbcff0ef          	jal	ra,810 <uart_printf>
    uart_printf("Initializing RT system...\n");
    1058:	00001537          	lui	a0,0x1
    105c:	39050513          	addi	a0,a0,912 # 1390 <rt_main_loop+0x254>
    1060:	fb0ff0ef          	jal	ra,810 <uart_printf>
    
    // Inicijalizuj kernel
    kernel_init();
    1064:	a61ff0ef          	jal	ra,ac4 <kernel_init>
    
    // Kreiraj task-ove
    int task_id;
    
    task_id = task_create(led_blink_task, 1, "LED_Blink");
    1068:	00001637          	lui	a2,0x1
    106c:	00001537          	lui	a0,0x1
    1070:	3ac60613          	addi	a2,a2,940 # 13ac <rt_main_loop+0x270>
    1074:	00100593          	li	a1,1
    1078:	e7c50513          	addi	a0,a0,-388 # e7c <led_blink_task>
    107c:	fe8ff0ef          	jal	ra,864 <task_create>
    if (task_id >= 0) {
    1080:	00054a63          	bltz	a0,1094 <rt_system_init+0x50>
        uart_printf("Created LED Blink Task (ID: %d)\n", task_id);
    1084:	00050593          	mv	a1,a0
    1088:	00001537          	lui	a0,0x1
    108c:	3b850513          	addi	a0,a0,952 # 13b8 <rt_main_loop+0x27c>
    1090:	f80ff0ef          	jal	ra,810 <uart_printf>
    }
    
    task_id = task_create(uart_debug_task, 2, "UART_Debug");  
    1094:	00001637          	lui	a2,0x1
    1098:	00001537          	lui	a0,0x1
    109c:	3dc60613          	addi	a2,a2,988 # 13dc <rt_main_loop+0x2a0>
    10a0:	00200593          	li	a1,2
    10a4:	f9850513          	addi	a0,a0,-104 # f98 <uart_debug_task>
    10a8:	fbcff0ef          	jal	ra,864 <task_create>
    if (task_id >= 0) {
    10ac:	00054a63          	bltz	a0,10c0 <rt_system_init+0x7c>
        uart_printf("Created UART Debug Task (ID: %d)\n", task_id);
    10b0:	00050593          	mv	a1,a0
    10b4:	00001537          	lui	a0,0x1
    10b8:	3e850513          	addi	a0,a0,1000 # 13e8 <rt_main_loop+0x2ac>
    10bc:	f54ff0ef          	jal	ra,810 <uart_printf>
    }
    
    task_id = task_create(counter_task, 3, "Counter");
    10c0:	00001637          	lui	a2,0x1
    10c4:	00001537          	lui	a0,0x1
    10c8:	40c60613          	addi	a2,a2,1036 # 140c <rt_main_loop+0x2d0>
    10cc:	00300593          	li	a1,3
    10d0:	ee850513          	addi	a0,a0,-280 # ee8 <counter_task>
    10d4:	f90ff0ef          	jal	ra,864 <task_create>
    if (task_id >= 0) {
    10d8:	00054a63          	bltz	a0,10ec <rt_system_init+0xa8>
        uart_printf("Created Counter Task (ID: %d)\n", task_id);
    10dc:	00050593          	mv	a1,a0
    10e0:	00001537          	lui	a0,0x1
    10e4:	41450513          	addi	a0,a0,1044 # 1414 <rt_main_loop+0x2d8>
    10e8:	f28ff0ef          	jal	ra,810 <uart_printf>
    }
    
    task_id = task_create(gpio_monitor_task, 2, "GPIO_Monitor");
    10ec:	00001637          	lui	a2,0x1
    10f0:	00001537          	lui	a0,0x1
    10f4:	43460613          	addi	a2,a2,1076 # 1434 <rt_main_loop+0x2f8>
    10f8:	00200593          	li	a1,2
    10fc:	f5050513          	addi	a0,a0,-176 # f50 <gpio_monitor_task>
    1100:	f64ff0ef          	jal	ra,864 <task_create>
    if (task_id >= 0) {
    1104:	00054a63          	bltz	a0,1118 <rt_system_init+0xd4>
        uart_printf("Created GPIO Monitor Task (ID: %d)\n", task_id);
    1108:	00050593          	mv	a1,a0
    110c:	00001537          	lui	a0,0x1
    1110:	44450513          	addi	a0,a0,1092 # 1444 <rt_main_loop+0x308>
    1114:	efcff0ef          	jal	ra,810 <uart_printf>
    }
    
    uart_printf("Starting RT kernel...\n");
    1118:	00001537          	lui	a0,0x1
    111c:	46850513          	addi	a0,a0,1128 # 1468 <rt_main_loop+0x32c>
    1120:	ef0ff0ef          	jal	ra,810 <uart_printf>
    
    // Pokreni kernel
    kernel_start();
    1124:	aa1ff0ef          	jal	ra,bc4 <kernel_start>
    
    uart_printf("RT Kernel started successfully!\n");
}
    1128:	00c12083          	lw	ra,12(sp)
    uart_printf("RT Kernel started successfully!\n");
    112c:	00001537          	lui	a0,0x1
    1130:	48050513          	addi	a0,a0,1152 # 1480 <rt_main_loop+0x344>
}
    1134:	01010113          	addi	sp,sp,16
    uart_printf("RT Kernel started successfully!\n");
    1138:	ed8ff06f          	j	810 <uart_printf>

0000113c <rt_main_loop>:

/*
 * Integracija sa postojećim firmware.c main loop
 * Poziva se umesto postojećeg while(1) loop-a
 */
void rt_main_loop(void) {
    113c:	ff010113          	addi	sp,sp,-16
    1140:	00112623          	sw	ra,12(sp)
    // Inicijalizuj RT sistem
    rt_system_init();
    1144:	f01ff0ef          	jal	ra,1044 <rt_system_init>
    
    // Pokreni glavni scheduler loop
    kernel_run(); // Ova funkcija nikad ne vraća kontrolu
    1148:	00c12083          	lw	ra,12(sp)
    114c:	01010113          	addi	sp,sp,16
    kernel_run(); // Ova funkcija nikad ne vraća kontrolu
    1150:	fe0ff06f          	j	930 <kernel_run>
    1154:	2020                	fld	fs0,64(s0)
    1156:	5f5f 5f5f 2020      	0x20205f5f5f5f
    115c:	205f 2020 2020      	0x20202020205f
    1162:	2020                	fld	fs0,64(s0)
    1164:	2020                	fld	fs0,64(s0)
    1166:	5f20                	lw	s0,120(a4)
    1168:	5f5f 205f 2020      	0x2020205f5f5f
    116e:	2020                	fld	fs0,64(s0)
    1170:	2020                	fld	fs0,64(s0)
    1172:	2020                	fld	fs0,64(s0)
    1174:	5f5f 5f5f 000a      	0xa5f5f5f5f
    117a:	0000                	unimp
    117c:	7c20                	flw	fs0,120(s0)
    117e:	2020                	fld	fs0,64(s0)
    1180:	205f 285c 295f      	0x295f285c205f
    1186:	5f20                	lw	s0,120(a4)
    1188:	5f5f 5f20 5f5f      	0x5f5f5f205f5f
    118e:	5f5f202f          	0x5f5f202f
    1192:	7c5f 2020 5f5f      	0x5f5f20207c5f
    1198:	205f 2f20 5f20      	0x5f202f20205f
    119e:	5f5f 0a7c 0000      	0xa7c5f5f
    11a4:	7c20                	flw	fs0,120(s0)
    11a6:	7c20                	flw	fs0,120(s0)
    11a8:	295f 7c20 7c20      	0x7c207c20295f
    11ae:	5f5f202f          	0x5f5f202f
    11b2:	205f202f          	amoxor.w	zero,t0,(t5)
    11b6:	5f5c                	lw	a5,60(a4)
    11b8:	5f5f 5c20 2f20      	0x2f205c205f5f
    11be:	5f20                	lw	s0,120(a4)
    11c0:	5c20                	lw	s0,120(s0)
    11c2:	207c                	fld	fa5,192(s0)
    11c4:	0a7c                	addi	a5,sp,284
    11c6:	0000                	unimp
    11c8:	7c20                	flw	fs0,120(s0)
    11ca:	2020                	fld	fs0,64(s0)
    11cc:	5f5f 7c2f 7c20      	0x7c207c2f5f5f
    11d2:	2820                	fld	fs0,80(s0)
    11d4:	7c5f 2820 295f      	0x295f28207c5f
    11da:	7c20                	flw	fs0,120(s0)
    11dc:	5f5f 2029 207c      	0x207c20295f5f
    11e2:	5f28                	lw	a0,120(a4)
    11e4:	2029                	jal	11ee <rt_main_loop+0xb2>
    11e6:	207c                	fld	fa5,192(s0)
    11e8:	5f7c                	lw	a5,124(a4)
    11ea:	5f5f 000a 0000      	0xa5f5f
    11f0:	7c20                	flw	fs0,120(s0)
    11f2:	7c5f 2020 7c20      	0x7c2020207c5f
    11f8:	7c5f 5f5c 5f5f      	0x5f5f5f5c7c5f
    11fe:	5f5c                	lw	a5,60(a4)
    1200:	5f5f 5f2f 5f5f      	0x5f5f5f2f5f5f
    1206:	2f5f 5c20 5f5f      	0x5f5f5c202f5f
    120c:	2f5f 5c20 5f5f      	0x5f5f5c202f5f
    1212:	5f5f 0a7c 0000      	0xa7c5f5f
    1218:	2020                	fld	fs0,64(s0)
    121a:	2020                	fld	fs0,64(s0)
    121c:	2020                	fld	fs0,64(s0)
    121e:	2020                	fld	fs0,64(s0)
    1220:	4c206e4f          	0x4c206e4f
    1224:	6369                	lui	t1,0x1a
    1226:	6568                	flw	fa0,76(a0)
    1228:	2065                	jal	12d0 <rt_main_loop+0x194>
    122a:	6154                	flw	fa3,4(a0)
    122c:	676e                	flw	fa4,216(sp)
    122e:	4e20                	lw	s0,88(a2)
    1230:	6e61                	lui	t3,0x18
    1232:	4b392d6f          	jal	s10,93ee4 <_etext+0x92a40>
    1236:	000a                	c.slli	zero,0x2
    1238:	6e75                	lui	t3,0x1d
    123a:	7375                	lui	t1,0xffffd
    123c:	6465                	lui	s0,0x19
    123e:	0000                	unimp
    1240:	6154                	flw	fa3,4(a0)
    1242:	005b6b73          	csrrsi	s6,utvec,22
    1246:	0000                	unimp
    1248:	3a5d                	jal	bfe <get_context_switch_count+0x6>
    124a:	0020                	addi	s0,sp,8
    124c:	202c                	fld	fa1,64(s0)
    124e:	74617453          	0x74617453
    1252:	3a65                	jal	c0a <get_average_interrupt_latency+0x6>
    1254:	0020                	addi	s0,sp,8
    1256:	0000                	unimp
    1258:	4552                	lw	a0,20(sp)
    125a:	4441                	li	s0,16
    125c:	0059                	c.nop	22
    125e:	0000                	unimp
    1260:	5552                	lw	a0,52(sp)
    1262:	4e4e                	lw	t3,208(sp)
    1264:	4e49                	li	t3,18
    1266:	4c420047          	0x4c420047
    126a:	454b434f          	0x454b434f
    126e:	0044                	addi	s1,sp,4
    1270:	4554                	lw	a3,12(a0)
    1272:	4d52                	lw	s10,20(sp)
    1274:	4e49                	li	t3,18
    1276:	5441                	li	s0,-16
    1278:	4445                	li	s0,17
    127a:	0000                	unimp
    127c:	454c                	lw	a1,12(a0)
    127e:	2044                	fld	fs1,128(s0)
    1280:	6f54                	flw	fa3,28(a4)
    1282:	656c6767          	0x656c6767
    1286:	6120                	flw	fs0,64(a0)
    1288:	2074                	fld	fa3,192(s0)
    128a:	6974                	flw	fa3,84(a0)
    128c:	25206b63          	bltu	zero,s2,14e2 <_etext+0x3e>
    1290:	0a64                	addi	s1,sp,284
    1292:	0000                	unimp
    1294:	6e756f43          	fmadd.q	ft10,fa0,ft7,fa3,unknown
    1298:	6574                	flw	fa3,76(a0)
    129a:	2072                	fld	ft0,280(sp)
    129c:	6154                	flw	fa3,4(a0)
    129e:	203a6b73          	csrrsi	s6,hideleg,20
    12a2:	6425                	lui	s0,0x9
    12a4:	6920                	flw	fs0,80(a0)
    12a6:	6574                	flw	fa3,76(a0)
    12a8:	6172                	flw	ft2,28(sp)
    12aa:	6974                	flw	fa3,84(a0)
    12ac:	0a736e6f          	jal	t3,37b52 <_etext+0x366ae>
    12b0:	0000                	unimp
    12b2:	0000                	unimp
    12b4:	4f495047          	fmsub.q	ft0,fs2,fs4,fs1,unknown
    12b8:	5320                	lw	s0,96(a4)
    12ba:	6174                	flw	fa3,68(a0)
    12bc:	6574                	flw	fa3,76(a0)
    12be:	4320                	lw	s0,64(a4)
    12c0:	6168                	flw	fa0,68(a0)
    12c2:	676e                	flw	fa4,216(sp)
    12c4:	3a65                	jal	c7c <print_task_info+0x3c>
    12c6:	3020                	fld	fs0,96(s0)
    12c8:	2578                	fld	fa4,200(a0)
    12ca:	3830                	fld	fa2,112(s0)
    12cc:	2078                	fld	fa4,192(s0)
    12ce:	3e2d                	jal	e08 <print_task_info+0x1c8>
    12d0:	3020                	fld	fs0,96(s0)
    12d2:	2578                	fld	fa4,200(a0)
    12d4:	3830                	fld	fa2,112(s0)
    12d6:	0a78                	addi	a4,sp,284
    12d8:	0000                	unimp
    12da:	0000                	unimp
    12dc:	3d3d                	jal	111a <rt_system_init+0xd6>
    12de:	203d                	jal	130c <rt_main_loop+0x1d0>
    12e0:	5452                	lw	s0,52(sp)
    12e2:	5320                	lw	s0,96(a4)
    12e4:	7379                	lui	t1,0xffffe
    12e6:	6574                	flw	fa3,76(a0)
    12e8:	206d                	jal	1392 <rt_main_loop+0x256>
    12ea:	74617453          	0x74617453
    12ee:	7375                	lui	t1,0xffffd
    12f0:	3d20                	fld	fs0,120(a0)
    12f2:	3d3d                	jal	1130 <rt_system_init+0xec>
    12f4:	000a                	c.slli	zero,0x2
    12f6:	0000                	unimp
    12f8:	7055                	c.lui	zero,0xffff5
    12fa:	6974                	flw	fa3,84(a0)
    12fc:	656d                	lui	a0,0x1b
    12fe:	203a                	fld	ft0,392(sp)
    1300:	6425                	lui	s0,0x9
    1302:	7420                	flw	fs0,104(s0)
    1304:	6369                	lui	t1,0x1a
    1306:	000a736b          	0xa736b
    130a:	0000                	unimp
    130c:	746e6f43          	0x746e6f43
    1310:	7865                	lui	a6,0xffff9
    1312:	2074                	fld	fa3,192(s0)
    1314:	74697773          	csrrci	a4,0x746,18
    1318:	73656863          	bltu	a0,s6,1a48 <_etext+0x5a4>
    131c:	203a                	fld	ft0,392(sp)
    131e:	6425                	lui	s0,0x9
    1320:	000a                	c.slli	zero,0x2
    1322:	0000                	unimp
    1324:	7641                	lui	a2,0xffff0
    1326:	6e692067          	0x6e692067
    132a:	6574                	flw	fa3,76(a0)
    132c:	7272                	flw	ft4,60(sp)
    132e:	7075                	c.lui	zero,0xffffd
    1330:	2074                	fld	fa3,192(s0)
    1332:	616c                	flw	fa1,68(a0)
    1334:	6574                	flw	fa3,76(a0)
    1336:	636e                	flw	ft6,216(sp)
    1338:	3a79                	jal	cd6 <print_task_info+0x96>
    133a:	2520                	fld	fs0,72(a0)
    133c:	2064                	fld	fs1,192(s0)
    133e:	6c637963          	bgeu	t1,t1,1a10 <_etext+0x56c>
    1342:	7365                	lui	t1,0xffff9
    1344:	000a                	c.slli	zero,0x2
    1346:	0000                	unimp
    1348:	3d3d                	jal	1186 <rt_main_loop+0x4a>
    134a:	3d3d                	jal	1188 <rt_main_loop+0x4c>
    134c:	3d3d                	jal	118a <rt_main_loop+0x4e>
    134e:	3d3d                	jal	118c <rt_main_loop+0x50>
    1350:	3d3d                	jal	118e <rt_main_loop+0x52>
    1352:	3d3d                	jal	1190 <rt_main_loop+0x54>
    1354:	3d3d                	jal	1192 <rt_main_loop+0x56>
    1356:	3d3d                	jal	1194 <rt_main_loop+0x58>
    1358:	3d3d                	jal	1196 <rt_main_loop+0x5a>
    135a:	3d3d                	jal	1198 <rt_main_loop+0x5c>
    135c:	3d3d                	jal	119a <rt_main_loop+0x5e>
    135e:	3d3d                	jal	119c <rt_main_loop+0x60>
    1360:	000a                	c.slli	zero,0x2
    1362:	0000                	unimp
    1364:	3d0a                	fld	fs10,160(sp)
    1366:	3d3d                	jal	11a4 <rt_main_loop+0x68>
    1368:	5020                	lw	s0,96(s0)
    136a:	6369                	lui	t1,0x1a
    136c:	6e69546f          	jal	s0,96a52 <_etext+0x955ae>
    1370:	2079                	jal	13fe <rt_main_loop+0x2c2>
    1372:	6552                	flw	fa0,20(sp)
    1374:	6c61                	lui	s8,0x18
    1376:	542d                	li	s0,-21
    1378:	6d69                	lui	s10,0x1a
    137a:	2065                	jal	1422 <rt_main_loop+0x2e6>
    137c:	6e72654b          	fnmsub.q	fa0,ft4,ft7,fa3,unknown
    1380:	6c65                	lui	s8,0x19
    1382:	4420                	lw	s0,72(s0)
    1384:	6d65                	lui	s10,0x19
    1386:	3d3d206f          	j	d3f58 <_etext+0xd2ab4>
    138a:	0a3d                	addi	s4,s4,15
    138c:	0000                	unimp
    138e:	0000                	unimp
    1390:	6e49                	lui	t3,0x12
    1392:	7469                	lui	s0,0xffffa
    1394:	6169                	addi	sp,sp,208
    1396:	696c                	flw	fa1,84(a0)
    1398:	697a                	flw	fs2,156(sp)
    139a:	676e                	flw	fa4,216(sp)
    139c:	5220                	lw	s0,96(a2)
    139e:	2054                	fld	fa3,128(s0)
    13a0:	74737973          	csrrci	s2,0x747,6
    13a4:	6d65                	lui	s10,0x19
    13a6:	2e2e                	fld	ft8,200(sp)
    13a8:	0a2e                	slli	s4,s4,0xb
    13aa:	0000                	unimp
    13ac:	454c                	lw	a1,12(a0)
    13ae:	5f44                	lw	s1,60(a4)
    13b0:	6c42                	flw	fs8,16(sp)
    13b2:	6e69                	lui	t3,0x1a
    13b4:	0000006b          	0x6b
    13b8:	61657243          	fmadd.s	ft4,fa0,fs6,fa2
    13bc:	6574                	flw	fa3,76(a0)
    13be:	2064                	fld	fs1,192(s0)
    13c0:	454c                	lw	a1,12(a0)
    13c2:	2044                	fld	fs1,128(s0)
    13c4:	6c42                	flw	fs8,16(sp)
    13c6:	6e69                	lui	t3,0x1a
    13c8:	6154206b          	0x6154206b
    13cc:	28206b73          	csrrsi	s6,0x282,0
    13d0:	4449                	li	s0,18
    13d2:	203a                	fld	ft0,392(sp)
    13d4:	6425                	lui	s0,0x9
    13d6:	0a29                	addi	s4,s4,10
    13d8:	0000                	unimp
    13da:	0000                	unimp
    13dc:	4155                	li	sp,21
    13de:	5452                	lw	s0,52(sp)
    13e0:	445f 6265 6775      	0x67756265445f
    13e6:	0000                	unimp
    13e8:	61657243          	fmadd.s	ft4,fa0,fs6,fa2
    13ec:	6574                	flw	fa3,76(a0)
    13ee:	2064                	fld	fs1,192(s0)
    13f0:	4155                	li	sp,21
    13f2:	5452                	lw	s0,52(sp)
    13f4:	4420                	lw	s0,72(s0)
    13f6:	6265                	lui	tp,0x19
    13f8:	6775                	lui	a4,0x1d
    13fa:	5420                	lw	s0,104(s0)
    13fc:	7361                	lui	t1,0xffff8
    13fe:	4928206b          	0x4928206b
    1402:	3a44                	fld	fs1,176(a2)
    1404:	2520                	fld	fs0,72(a0)
    1406:	2964                	fld	fs1,208(a0)
    1408:	000a                	c.slli	zero,0x2
    140a:	0000                	unimp
    140c:	6e756f43          	fmadd.q	ft10,fa0,ft7,fa3,unknown
    1410:	6574                	flw	fa3,76(a0)
    1412:	0072                	c.slli	zero,0x1c
    1414:	61657243          	fmadd.s	ft4,fa0,fs6,fa2
    1418:	6574                	flw	fa3,76(a0)
    141a:	2064                	fld	fs1,192(s0)
    141c:	6e756f43          	fmadd.q	ft10,fa0,ft7,fa3,unknown
    1420:	6574                	flw	fa3,76(a0)
    1422:	2072                	fld	ft0,280(sp)
    1424:	6154                	flw	fa3,4(a0)
    1426:	28206b73          	csrrsi	s6,0x282,0
    142a:	4449                	li	s0,18
    142c:	203a                	fld	ft0,392(sp)
    142e:	6425                	lui	s0,0x9
    1430:	0a29                	addi	s4,s4,10
    1432:	0000                	unimp
    1434:	4f495047          	fmsub.q	ft0,fs2,fs4,fs1,unknown
    1438:	4d5f 6e6f 7469      	0x74696e6f4d5f
    143e:	0000726f          	jal	tp,843e <_etext+0x6f9a>
    1442:	0000                	unimp
    1444:	61657243          	fmadd.s	ft4,fa0,fs6,fa2
    1448:	6574                	flw	fa3,76(a0)
    144a:	2064                	fld	fs1,192(s0)
    144c:	4f495047          	fmsub.q	ft0,fs2,fs4,fs1,unknown
    1450:	4d20                	lw	s0,88(a0)
    1452:	74696e6f          	jal	t3,97b98 <_etext+0x966f4>
    1456:	5420726f          	jal	tp,8998 <_etext+0x74f4>
    145a:	7361                	lui	t1,0xffff8
    145c:	4928206b          	0x4928206b
    1460:	3a44                	fld	fs1,176(a2)
    1462:	2520                	fld	fs0,72(a0)
    1464:	2964                	fld	fs1,208(a0)
    1466:	000a                	c.slli	zero,0x2
    1468:	72617453          	0x72617453
    146c:	6974                	flw	fa3,84(a0)
    146e:	676e                	flw	fa4,216(sp)
    1470:	5220                	lw	s0,96(a2)
    1472:	2054                	fld	fa3,128(s0)
    1474:	6e72656b          	0x6e72656b
    1478:	6c65                	lui	s8,0x19
    147a:	2e2e                	fld	ft8,200(sp)
    147c:	0a2e                	slli	s4,s4,0xb
    147e:	0000                	unimp
    1480:	5452                	lw	s0,52(sp)
    1482:	4b20                	lw	s0,80(a4)
    1484:	7265                	lui	tp,0xffff9
    1486:	656e                	flw	fa0,216(sp)
    1488:	206c                	fld	fa1,192(s0)
    148a:	72617473          	csrrci	s0,0x726,2
    148e:	6574                	flw	fa3,76(a0)
    1490:	2064                	fld	fs1,192(s0)
    1492:	63637573          	csrrci	a0,0x636,6
    1496:	7365                	lui	t1,0xffff9
    1498:	6c756673          	csrrsi	a2,0x6c7,10
    149c:	796c                	flw	fa1,116(a0)
    149e:	0a21                	addi	s4,s4,8
    14a0:	0000                	unimp
	...
