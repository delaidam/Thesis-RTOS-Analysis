
build/fw-flash.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <crtStart>:
       0:	0a00006f          	j	a0 <crtInit>
       4:	00000013          	nop
       8:	00000013          	nop
       c:	00000013          	nop

00000010 <trap_entry>:
      10:	fe112e23          	sw	ra,-4(sp)
      14:	fe512c23          	sw	t0,-8(sp)
      18:	fe612a23          	sw	t1,-12(sp)
      1c:	fe712823          	sw	t2,-16(sp)
      20:	fea12623          	sw	a0,-20(sp)
      24:	feb12423          	sw	a1,-24(sp)
      28:	fec12223          	sw	a2,-28(sp)
      2c:	fed12023          	sw	a3,-32(sp)
      30:	fce12e23          	sw	a4,-36(sp)
      34:	fcf12c23          	sw	a5,-40(sp)
      38:	fd012a23          	sw	a6,-44(sp)
      3c:	fd112823          	sw	a7,-48(sp)
      40:	fdc12623          	sw	t3,-52(sp)
      44:	fdd12423          	sw	t4,-56(sp)
      48:	fde12223          	sw	t5,-60(sp)
      4c:	fdf12023          	sw	t6,-64(sp)
      50:	fc010113          	addi	sp,sp,-64
      54:	458020ef          	jal	24ac <irqCallback>
      58:	03c12083          	lw	ra,60(sp)
      5c:	03812283          	lw	t0,56(sp)
      60:	03412303          	lw	t1,52(sp)
      64:	03012383          	lw	t2,48(sp)
      68:	02c12503          	lw	a0,44(sp)
      6c:	02812583          	lw	a1,40(sp)
      70:	02412603          	lw	a2,36(sp)
      74:	02012683          	lw	a3,32(sp)
      78:	01c12703          	lw	a4,28(sp)
  lw x10, 11*4(sp)
  lw x11, 10*4(sp)
  lw x12,  9*4(sp)
  lw x13,  8*4(sp)
  lw x14,  7*4(sp)
  lw x15,  6*4(sp)
      7c:	01812783          	lw	a5,24(sp)
  lw x16,  5*4(sp)
      80:	01412803          	lw	a6,20(sp)
  lw x17,  4*4(sp)
      84:	01012883          	lw	a7,16(sp)
  lw x28,  3*4(sp)
      88:	00c12e03          	lw	t3,12(sp)
      8c:	00812e83          	lw	t4,8(sp)
      90:	00412f03          	lw	t5,4(sp)
  lw x29,  2*4(sp)
  lw x30,  1*4(sp)
  lw x31,  0*4(sp)
      94:	00012f83          	lw	t6,0(sp)
  addi sp,sp,16*4
      98:	04010113          	addi	sp,sp,64
      9c:	30200073          	mret

000000a0 <crtInit>:
      a0:	40000197          	auipc	gp,0x40000
      a4:	76018193          	addi	gp,gp,1888 # 40000800 <__global_pointer$>
      a8:	c1018113          	addi	sp,gp,-1008 # 40000410 <_stack_start>
      ac:	00003517          	auipc	a0,0x3
      b0:	82050513          	addi	a0,a0,-2016 # 28cc <_etext>
      b4:	40000597          	auipc	a1,0x40000
      b8:	f4c58593          	addi	a1,a1,-180 # 40000000 <spi_flashio>
      bc:	80418613          	addi	a2,gp,-2044 # 40000004 <i>
      c0:	00c5dc63          	bge	a1,a2,d8 <bss_init>

000000c4 <loop_init_data>:
      c4:	00052683          	lw	a3,0(a0)
      c8:	00d5a023          	sw	a3,0(a1)
      cc:	00450513          	addi	a0,a0,4
      d0:	00458593          	addi	a1,a1,4
      d4:	fec5c8e3          	blt	a1,a2,c4 <loop_init_data>

000000d8 <bss_init>:
      d8:	80418513          	addi	a0,gp,-2044 # 40000004 <i>
      dc:	80818593          	addi	a1,gp,-2040 # 40000008 <_bss_end>

000000e0 <bss_loop>:
      e0:	00b50863          	beq	a0,a1,f0 <bss_done>
      e4:	00052023          	sw	zero,0(a0)
      e8:	00450513          	addi	a0,a0,4
      ec:	ff5ff06f          	j	e0 <bss_loop>

000000f0 <bss_done>:
      f0:	00002517          	auipc	a0,0x2
      f4:	7dc50513          	addi	a0,a0,2012 # 28cc <_etext>
      f8:	ffc10113          	addi	sp,sp,-4

000000fc <ctors_loop>:
      fc:	00002597          	auipc	a1,0x2
     100:	7d058593          	addi	a1,a1,2000 # 28cc <_etext>
     104:	00b50e63          	beq	a0,a1,120 <ctors_done>
     108:	00052683          	lw	a3,0(a0)
     10c:	00450513          	addi	a0,a0,4
     110:	00a12023          	sw	a0,0(sp)
     114:	000680e7          	jalr	a3
     118:	00012503          	lw	a0,0(sp)
     11c:	fe1ff06f          	j	fc <ctors_loop>

00000120 <ctors_done>:
     120:	00410113          	addi	sp,sp,4
     124:	7d1000ef          	jal	10f4 <main>

00000128 <infinitLoop>:
     128:	0000006f          	j	128 <infinitLoop>

0000012c <cmd_read_flash_id>:
int cmd_get_dspi() {
    return QSPI0->REG & QSPI_REG_DSPI;
}

void cmd_read_flash_id()
{
     12c:	fe010113          	addi	sp,sp,-32
    return QSPI0->REG & QSPI_REG_DSPI;
     130:	810007b7          	lui	a5,0x81000
{
     134:	00812c23          	sw	s0,24(sp)
    return QSPI0->REG & QSPI_REG_DSPI;
     138:	0007a403          	lw	s0,0(a5) # 81000000 <__global_pointer$+0x40fff800>
        QSPI0->REG &= ~QSPI_REG_DSPI;
     13c:	0007a703          	lw	a4,0(a5)
     140:	ffc006b7          	lui	a3,0xffc00
     144:	fff68693          	addi	a3,a3,-1 # ffbfffff <__global_pointer$+0xbfbff7ff>
     148:	00d77733          	and	a4,a4,a3
{
     14c:	00112e23          	sw	ra,28(sp)
        QSPI0->REG &= ~QSPI_REG_DSPI;
     150:	00e7a023          	sw	a4,0(a5)
    int pre_dspi = cmd_get_dspi();

    cmd_set_dspi(0);
    
    uint8_t buffer[4] = { 0x9F, /* zeros */ };
    spi_flashio(buffer, 4, 0);
     154:	400007b7          	lui	a5,0x40000
     158:	0007a783          	lw	a5,0(a5) # 40000000 <spi_flashio>
    uint8_t buffer[4] = { 0x9F, /* zeros */ };
     15c:	09f00713          	li	a4,159
     160:	00e12623          	sw	a4,12(sp)
    spi_flashio(buffer, 4, 0);
     164:	00000613          	li	a2,0
     168:	00400737          	lui	a4,0x400
     16c:	00400593          	li	a1,4
     170:	00c10513          	addi	a0,sp,12
     174:	00e47433          	and	s0,s0,a4
     178:	000780e7          	jalr	a5
    UART0->DATA = c;
     17c:	02000793          	li	a5,32
     180:	83000637          	lui	a2,0x83000
     184:	00f62023          	sw	a5,0(a2) # 83000000 <__global_pointer$+0x42fff800>

    for (int i = 1; i <= 3; i++) {
        putchar(' ');
        print_hex(buffer[i], 2);
     188:	00d14703          	lbu	a4,13(sp)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     18c:	000027b7          	lui	a5,0x2
     190:	4b078793          	addi	a5,a5,1200 # 24b0 <irqCallback+0x4>
     194:	00475693          	srli	a3,a4,0x4
     198:	00d786b3          	add	a3,a5,a3
     19c:	0006c683          	lbu	a3,0(a3)
    if (c == '\n')
     1a0:	00a00593          	li	a1,10
     1a4:	10b68863          	beq	a3,a1,2b4 <cmd_read_flash_id+0x188>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     1a8:	00f77713          	andi	a4,a4,15
     1ac:	00e78733          	add	a4,a5,a4
     1b0:	00074703          	lbu	a4,0(a4) # 400000 <_etext+0x3fd734>
    UART0->DATA = c;
     1b4:	83000637          	lui	a2,0x83000
     1b8:	00d62023          	sw	a3,0(a2) # 83000000 <__global_pointer$+0x42fff800>
    if (c == '\n')
     1bc:	00a00693          	li	a3,10
     1c0:	10d70c63          	beq	a4,a3,2d8 <cmd_read_flash_id+0x1ac>
    UART0->DATA = c;
     1c4:	83000637          	lui	a2,0x83000
     1c8:	00e62023          	sw	a4,0(a2) # 83000000 <__global_pointer$+0x42fff800>
     1cc:	02000713          	li	a4,32
     1d0:	00e62023          	sw	a4,0(a2)
        print_hex(buffer[i], 2);
     1d4:	00e14703          	lbu	a4,14(sp)
    if (c == '\n')
     1d8:	00a00593          	li	a1,10
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     1dc:	00475693          	srli	a3,a4,0x4
     1e0:	00d786b3          	add	a3,a5,a3
     1e4:	0006c683          	lbu	a3,0(a3)
    if (c == '\n')
     1e8:	12b68063          	beq	a3,a1,308 <cmd_read_flash_id+0x1dc>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     1ec:	00f77713          	andi	a4,a4,15
     1f0:	00e78733          	add	a4,a5,a4
     1f4:	00074703          	lbu	a4,0(a4)
    UART0->DATA = c;
     1f8:	83000637          	lui	a2,0x83000
     1fc:	00d62023          	sw	a3,0(a2) # 83000000 <__global_pointer$+0x42fff800>
    if (c == '\n')
     200:	00a00693          	li	a3,10
     204:	0ed70c63          	beq	a4,a3,2fc <cmd_read_flash_id+0x1d0>
    UART0->DATA = c;
     208:	83000637          	lui	a2,0x83000
     20c:	00e62023          	sw	a4,0(a2) # 83000000 <__global_pointer$+0x42fff800>
     210:	02000713          	li	a4,32
     214:	00e62023          	sw	a4,0(a2)
        print_hex(buffer[i], 2);
     218:	00f14703          	lbu	a4,15(sp)
    if (c == '\n')
     21c:	00a00593          	li	a1,10
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     220:	00475693          	srli	a3,a4,0x4
     224:	00d786b3          	add	a3,a5,a3
     228:	0006c683          	lbu	a3,0(a3)
    if (c == '\n')
     22c:	0cb68263          	beq	a3,a1,2f0 <cmd_read_flash_id+0x1c4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     230:	00f77713          	andi	a4,a4,15
     234:	00e78733          	add	a4,a5,a4
     238:	00074703          	lbu	a4,0(a4)
    UART0->DATA = c;
     23c:	830007b7          	lui	a5,0x83000
     240:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
    if (c == '\n')
     244:	00a00693          	li	a3,10
     248:	08d70e63          	beq	a4,a3,2e4 <cmd_read_flash_id+0x1b8>
    UART0->DATA = c;
     24c:	830007b7          	lui	a5,0x83000
     250:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     254:	00d00713          	li	a4,13
     258:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     25c:	00a00713          	li	a4,10
     260:	00e7a023          	sw	a4,0(a5)
    if (on) {
     264:	02040463          	beqz	s0,28c <cmd_read_flash_id+0x160>
        QSPI0->REG |= QSPI_REG_DSPI;
     268:	81000737          	lui	a4,0x81000
     26c:	00072783          	lw	a5,0(a4) # 81000000 <__global_pointer$+0x40fff800>
    }
    putchar('\n');

    cmd_set_dspi(pre_dspi);
}
     270:	01c12083          	lw	ra,28(sp)
     274:	01812403          	lw	s0,24(sp)
        QSPI0->REG |= QSPI_REG_DSPI;
     278:	004006b7          	lui	a3,0x400
     27c:	00d7e7b3          	or	a5,a5,a3
     280:	00f72023          	sw	a5,0(a4)
}
     284:	02010113          	addi	sp,sp,32
     288:	00008067          	ret
        QSPI0->REG &= ~QSPI_REG_DSPI;
     28c:	810006b7          	lui	a3,0x81000
     290:	0006a783          	lw	a5,0(a3) # 81000000 <__global_pointer$+0x40fff800>
     294:	ffc00737          	lui	a4,0xffc00
}
     298:	01c12083          	lw	ra,28(sp)
     29c:	01812403          	lw	s0,24(sp)
        QSPI0->REG &= ~QSPI_REG_DSPI;
     2a0:	fff70713          	addi	a4,a4,-1 # ffbfffff <__global_pointer$+0xbfbff7ff>
     2a4:	00e7f7b3          	and	a5,a5,a4
     2a8:	00f6a023          	sw	a5,0(a3)
}
     2ac:	02010113          	addi	sp,sp,32
     2b0:	00008067          	ret
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     2b4:	00f77713          	andi	a4,a4,15
     2b8:	00e78733          	add	a4,a5,a4
        UART0->DATA = '\r';
     2bc:	00d00593          	li	a1,13
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     2c0:	00074703          	lbu	a4,0(a4)
        UART0->DATA = '\r';
     2c4:	00b62023          	sw	a1,0(a2)
    UART0->DATA = c;
     2c8:	83000637          	lui	a2,0x83000
     2cc:	00d62023          	sw	a3,0(a2) # 83000000 <__global_pointer$+0x42fff800>
    if (c == '\n')
     2d0:	00a00693          	li	a3,10
     2d4:	eed718e3          	bne	a4,a3,1c4 <cmd_read_flash_id+0x98>
        UART0->DATA = '\r';
     2d8:	00d00693          	li	a3,13
     2dc:	00d62023          	sw	a3,0(a2)
     2e0:	ee5ff06f          	j	1c4 <cmd_read_flash_id+0x98>
     2e4:	00d00693          	li	a3,13
     2e8:	00d7a023          	sw	a3,0(a5)
     2ec:	f61ff06f          	j	24c <cmd_read_flash_id+0x120>
     2f0:	00d00593          	li	a1,13
     2f4:	00b62023          	sw	a1,0(a2)
     2f8:	f39ff06f          	j	230 <cmd_read_flash_id+0x104>
     2fc:	00d00693          	li	a3,13
     300:	00d62023          	sw	a3,0(a2)
     304:	f05ff06f          	j	208 <cmd_read_flash_id+0xdc>
     308:	00d00593          	li	a1,13
     30c:	00b62023          	sw	a1,0(a2)
     310:	eddff06f          	j	1ec <cmd_read_flash_id+0xc0>

00000314 <cmd_benchmark>:

// --------------------------------------------------------

uint32_t cmd_benchmark(bool verbose, uint32_t *instns_p)
{
     314:	f0010113          	addi	sp,sp,-256
     318:	00050f93          	mv	t6,a0
     31c:	00058e93          	mv	t4,a1

    uint32_t x32 = 314159265;

    uint32_t cycles_begin, cycles_end;
    uint32_t instns_begin, instns_end;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
     320:	c00022f3          	rdcycle	t0
    __asm__ volatile ("rdinstret %0" : "=r"(instns_begin));
     324:	c0202f73          	rdinstret	t5
    uint32_t x32 = 314159265;
     328:	12b9b7b7          	lui	a5,0x12b9b
    __asm__ volatile ("rdinstret %0" : "=r"(instns_begin));
     32c:	01400e13          	li	t3,20
    uint32_t x32 = 314159265;
     330:	0a178793          	addi	a5,a5,161 # 12b9b0a1 <_etext+0x12b987d5>
     334:	10010813          	addi	a6,sp,256
            x32 ^= x32 >> 17;
            x32 ^= x32 << 5;
            data[k] = x32;
        }

        for (int k = 0, p = 0; k < 256; k++)
     338:	10000313          	li	t1,256
        for (int k = 0; k < 256; k++)
     33c:	00010613          	mv	a2,sp
{
     340:	00010693          	mv	a3,sp
            x32 ^= x32 << 13;
     344:	00d79713          	slli	a4,a5,0xd
     348:	00f747b3          	xor	a5,a4,a5
            x32 ^= x32 >> 17;
     34c:	0117d713          	srli	a4,a5,0x11
     350:	00f74733          	xor	a4,a4,a5
            x32 ^= x32 << 5;
     354:	00571793          	slli	a5,a4,0x5
     358:	00e7c7b3          	xor	a5,a5,a4
            data[k] = x32;
     35c:	00f68023          	sb	a5,0(a3)
        for (int k = 0; k < 256; k++)
     360:	00168693          	addi	a3,a3,1
     364:	fed810e3          	bne	a6,a3,344 <cmd_benchmark+0x30>
     368:	00010693          	mv	a3,sp
        for (int k = 0, p = 0; k < 256; k++)
     36c:	00000593          	li	a1,0
     370:	00000713          	li	a4,0
        {
            if (data[k])
     374:	0006c503          	lbu	a0,0(a3)
                data[p++] = k;
     378:	10058893          	addi	a7,a1,256
     37c:	002888b3          	add	a7,a7,sp
        for (int k = 0, p = 0; k < 256; k++)
     380:	00168693          	addi	a3,a3,1
            if (data[k])
     384:	00050663          	beqz	a0,390 <cmd_benchmark+0x7c>
                data[p++] = k;
     388:	f0e88023          	sb	a4,-256(a7)
     38c:	00158593          	addi	a1,a1,1
        for (int k = 0, p = 0; k < 256; k++)
     390:	00170713          	addi	a4,a4,1
     394:	fe6710e3          	bne	a4,t1,374 <cmd_benchmark+0x60>
        }

        for (int k = 0, p = 0; k < 64; k++)
        {
            x32 = x32 ^ words[k];
     398:	00062703          	lw	a4,0(a2)
        for (int k = 0, p = 0; k < 64; k++)
     39c:	00460613          	addi	a2,a2,4
            x32 = x32 ^ words[k];
     3a0:	00e7c7b3          	xor	a5,a5,a4
        for (int k = 0, p = 0; k < 64; k++)
     3a4:	fec81ae3          	bne	a6,a2,398 <cmd_benchmark+0x84>
    for (int i = 0; i < 20; i++)
     3a8:	fffe0e13          	addi	t3,t3,-1
     3ac:	f80e18e3          	bnez	t3,33c <cmd_benchmark+0x28>
        }
    }

    __asm__ volatile ("rdcycle %0" : "=r"(cycles_end));
     3b0:	c0002573          	rdcycle	a0
    __asm__ volatile ("rdinstret %0" : "=r"(instns_end));
     3b4:	c02025f3          	rdinstret	a1

    if (verbose)
     3b8:	000f9e63          	bnez	t6,3d4 <cmd_benchmark+0xc0>
    }

    if (instns_p)
        *instns_p = instns_end - instns_begin;

    return cycles_end - cycles_begin;
     3bc:	40550533          	sub	a0,a0,t0
    if (instns_p)
     3c0:	000e8663          	beqz	t4,3cc <cmd_benchmark+0xb8>
        *instns_p = instns_end - instns_begin;
     3c4:	41e585b3          	sub	a1,a1,t5
     3c8:	00bea023          	sw	a1,0(t4)
}
     3cc:	10010113          	addi	sp,sp,256
     3d0:	00008067          	ret
     3d4:	00002737          	lui	a4,0x2
    while (*p)
     3d8:	04300693          	li	a3,67
     3dc:	4c470713          	addi	a4,a4,1220 # 24c4 <irqCallback+0x18>
    if (c == '\n')
     3e0:	00a00813          	li	a6,10
    UART0->DATA = c;
     3e4:	83000637          	lui	a2,0x83000
        UART0->DATA = '\r';
     3e8:	00d00893          	li	a7,13
        putchar(*(p++));
     3ec:	00170713          	addi	a4,a4,1
    if (c == '\n')
     3f0:	49068663          	beq	a3,a6,87c <_stack_size+0x47c>
    UART0->DATA = c;
     3f4:	00d62023          	sw	a3,0(a2) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     3f8:	00074683          	lbu	a3,0(a4)
     3fc:	fe0698e3          	bnez	a3,3ec <cmd_benchmark+0xd8>
        print_hex(cycles_end - cycles_begin, 8);
     400:	40550533          	sub	a0,a0,t0
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     404:	00002737          	lui	a4,0x2
     408:	4b070713          	addi	a4,a4,1200 # 24b0 <irqCallback+0x4>
     40c:	01c55693          	srli	a3,a0,0x1c
     410:	00d706b3          	add	a3,a4,a3
     414:	0006c803          	lbu	a6,0(a3)
        if (c == '0' && i >= digits) continue;
     418:	00a00693          	li	a3,10
     41c:	00d81863          	bne	a6,a3,42c <_stack_size+0x2c>
        UART0->DATA = '\r';
     420:	830006b7          	lui	a3,0x83000
     424:	00d00613          	li	a2,13
     428:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     42c:	01855693          	srli	a3,a0,0x18
     430:	00f6f693          	andi	a3,a3,15
     434:	00d706b3          	add	a3,a4,a3
     438:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     43c:	830006b7          	lui	a3,0x83000
     440:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     444:	00a00813          	li	a6,10
     448:	01061663          	bne	a2,a6,454 <_stack_size+0x54>
        UART0->DATA = '\r';
     44c:	00d00813          	li	a6,13
     450:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     454:	01455693          	srli	a3,a0,0x14
     458:	00f6f693          	andi	a3,a3,15
     45c:	00d706b3          	add	a3,a4,a3
     460:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     464:	830006b7          	lui	a3,0x83000
     468:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     46c:	00a00613          	li	a2,10
     470:	00c81663          	bne	a6,a2,47c <_stack_size+0x7c>
        UART0->DATA = '\r';
     474:	00d00613          	li	a2,13
     478:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     47c:	01055693          	srli	a3,a0,0x10
     480:	00f6f693          	andi	a3,a3,15
     484:	00d706b3          	add	a3,a4,a3
     488:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     48c:	830006b7          	lui	a3,0x83000
     490:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     494:	00a00813          	li	a6,10
     498:	01061663          	bne	a2,a6,4a4 <_stack_size+0xa4>
        UART0->DATA = '\r';
     49c:	00d00813          	li	a6,13
     4a0:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     4a4:	00c55693          	srli	a3,a0,0xc
     4a8:	00f6f693          	andi	a3,a3,15
     4ac:	00d706b3          	add	a3,a4,a3
     4b0:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     4b4:	830006b7          	lui	a3,0x83000
     4b8:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     4bc:	00a00613          	li	a2,10
     4c0:	00c81663          	bne	a6,a2,4cc <_stack_size+0xcc>
        UART0->DATA = '\r';
     4c4:	00d00613          	li	a2,13
     4c8:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     4cc:	00855693          	srli	a3,a0,0x8
     4d0:	00f6f693          	andi	a3,a3,15
     4d4:	00d706b3          	add	a3,a4,a3
     4d8:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     4dc:	830006b7          	lui	a3,0x83000
     4e0:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     4e4:	00a00813          	li	a6,10
     4e8:	01061663          	bne	a2,a6,4f4 <_stack_size+0xf4>
        UART0->DATA = '\r';
     4ec:	00d00813          	li	a6,13
     4f0:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     4f4:	00455693          	srli	a3,a0,0x4
     4f8:	00f6f693          	andi	a3,a3,15
     4fc:	00d706b3          	add	a3,a4,a3
     500:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     504:	830006b7          	lui	a3,0x83000
     508:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     50c:	00a00613          	li	a2,10
     510:	00c81663          	bne	a6,a2,51c <_stack_size+0x11c>
        UART0->DATA = '\r';
     514:	00d00613          	li	a2,13
     518:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     51c:	00f57693          	andi	a3,a0,15
     520:	00d706b3          	add	a3,a4,a3
     524:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     528:	830006b7          	lui	a3,0x83000
     52c:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     530:	00a00813          	li	a6,10
     534:	01061663          	bne	a2,a6,540 <_stack_size+0x140>
        UART0->DATA = '\r';
     538:	00d00813          	li	a6,13
     53c:	0106a023          	sw	a6,0(a3)
    UART0->DATA = c;
     540:	830006b7          	lui	a3,0x83000
     544:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     548:	00d00613          	li	a2,13
     54c:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
     550:	00a00613          	li	a2,10
     554:	00c6a023          	sw	a2,0(a3)
     558:	000026b7          	lui	a3,0x2
    while (*p)
     55c:	04900613          	li	a2,73
    UART0->DATA = c;
     560:	4d068693          	addi	a3,a3,1232 # 24d0 <irqCallback+0x24>
    if (c == '\n')
     564:	00a00893          	li	a7,10
    UART0->DATA = c;
     568:	83000837          	lui	a6,0x83000
        UART0->DATA = '\r';
     56c:	00d00313          	li	t1,13
        putchar(*(p++));
     570:	00168693          	addi	a3,a3,1
    if (c == '\n')
     574:	2d160e63          	beq	a2,a7,850 <_stack_size+0x450>
    UART0->DATA = c;
     578:	00c82023          	sw	a2,0(a6) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     57c:	0006c603          	lbu	a2,0(a3)
     580:	fe0618e3          	bnez	a2,570 <_stack_size+0x170>
        print_hex(instns_end - instns_begin, 8);
     584:	41e586b3          	sub	a3,a1,t5
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     588:	01c6d613          	srli	a2,a3,0x1c
     58c:	00c70633          	add	a2,a4,a2
     590:	00064803          	lbu	a6,0(a2)
        if (c == '0' && i >= digits) continue;
     594:	00a00613          	li	a2,10
     598:	00c81863          	bne	a6,a2,5a8 <_stack_size+0x1a8>
        UART0->DATA = '\r';
     59c:	83000637          	lui	a2,0x83000
     5a0:	00d00893          	li	a7,13
     5a4:	01162023          	sw	a7,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     5a8:	0186d613          	srli	a2,a3,0x18
     5ac:	00f67613          	andi	a2,a2,15
     5b0:	00c70633          	add	a2,a4,a2
     5b4:	00064883          	lbu	a7,0(a2)
    UART0->DATA = c;
     5b8:	83000637          	lui	a2,0x83000
     5bc:	01062023          	sw	a6,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     5c0:	00a00813          	li	a6,10
     5c4:	01089663          	bne	a7,a6,5d0 <_stack_size+0x1d0>
        UART0->DATA = '\r';
     5c8:	00d00813          	li	a6,13
     5cc:	01062023          	sw	a6,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     5d0:	0146d613          	srli	a2,a3,0x14
     5d4:	00f67613          	andi	a2,a2,15
     5d8:	00c70633          	add	a2,a4,a2
     5dc:	00064803          	lbu	a6,0(a2)
    UART0->DATA = c;
     5e0:	83000637          	lui	a2,0x83000
     5e4:	01162023          	sw	a7,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     5e8:	00a00893          	li	a7,10
     5ec:	01181663          	bne	a6,a7,5f8 <_stack_size+0x1f8>
        UART0->DATA = '\r';
     5f0:	00d00893          	li	a7,13
     5f4:	01162023          	sw	a7,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     5f8:	0106d613          	srli	a2,a3,0x10
     5fc:	00f67613          	andi	a2,a2,15
     600:	00c70633          	add	a2,a4,a2
     604:	00064883          	lbu	a7,0(a2)
    UART0->DATA = c;
     608:	83000637          	lui	a2,0x83000
     60c:	01062023          	sw	a6,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     610:	00a00813          	li	a6,10
     614:	01089663          	bne	a7,a6,620 <_stack_size+0x220>
        UART0->DATA = '\r';
     618:	00d00813          	li	a6,13
     61c:	01062023          	sw	a6,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     620:	00c6d613          	srli	a2,a3,0xc
     624:	00f67613          	andi	a2,a2,15
     628:	00c70633          	add	a2,a4,a2
     62c:	00064803          	lbu	a6,0(a2)
    UART0->DATA = c;
     630:	83000637          	lui	a2,0x83000
     634:	01162023          	sw	a7,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     638:	00a00893          	li	a7,10
     63c:	01181663          	bne	a6,a7,648 <_stack_size+0x248>
        UART0->DATA = '\r';
     640:	00d00893          	li	a7,13
     644:	01162023          	sw	a7,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     648:	0086d613          	srli	a2,a3,0x8
     64c:	00f67613          	andi	a2,a2,15
     650:	00c70633          	add	a2,a4,a2
     654:	00064883          	lbu	a7,0(a2)
    UART0->DATA = c;
     658:	83000637          	lui	a2,0x83000
     65c:	01062023          	sw	a6,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     660:	00a00813          	li	a6,10
     664:	01089663          	bne	a7,a6,670 <_stack_size+0x270>
        UART0->DATA = '\r';
     668:	00d00813          	li	a6,13
     66c:	01062023          	sw	a6,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     670:	0046d613          	srli	a2,a3,0x4
     674:	00f67613          	andi	a2,a2,15
     678:	00c70633          	add	a2,a4,a2
     67c:	00064803          	lbu	a6,0(a2)
    UART0->DATA = c;
     680:	83000637          	lui	a2,0x83000
     684:	01162023          	sw	a7,0(a2) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     688:	00a00893          	li	a7,10
     68c:	01181663          	bne	a6,a7,698 <_stack_size+0x298>
        UART0->DATA = '\r';
     690:	00d00893          	li	a7,13
     694:	01162023          	sw	a7,0(a2)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     698:	00f6f693          	andi	a3,a3,15
     69c:	00d706b3          	add	a3,a4,a3
     6a0:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     6a4:	830006b7          	lui	a3,0x83000
     6a8:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     6ac:	00a00813          	li	a6,10
     6b0:	01061663          	bne	a2,a6,6bc <_stack_size+0x2bc>
        UART0->DATA = '\r';
     6b4:	00d00813          	li	a6,13
     6b8:	0106a023          	sw	a6,0(a3)
    UART0->DATA = c;
     6bc:	830006b7          	lui	a3,0x83000
     6c0:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     6c4:	00d00613          	li	a2,13
     6c8:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
     6cc:	00a00613          	li	a2,10
     6d0:	00c6a023          	sw	a2,0(a3)
     6d4:	000026b7          	lui	a3,0x2
    while (*p)
     6d8:	04300613          	li	a2,67
    UART0->DATA = c;
     6dc:	4dc68693          	addi	a3,a3,1244 # 24dc <irqCallback+0x30>
    if (c == '\n')
     6e0:	00a00893          	li	a7,10
    UART0->DATA = c;
     6e4:	83000837          	lui	a6,0x83000
        UART0->DATA = '\r';
     6e8:	00d00313          	li	t1,13
        putchar(*(p++));
     6ec:	00168693          	addi	a3,a3,1
    if (c == '\n')
     6f0:	1d160063          	beq	a2,a7,8b0 <_stack_size+0x4b0>
    UART0->DATA = c;
     6f4:	00c82023          	sw	a2,0(a6) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     6f8:	0006c603          	lbu	a2,0(a3)
     6fc:	fe0618e3          	bnez	a2,6ec <_stack_size+0x2ec>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     700:	01c7d693          	srli	a3,a5,0x1c
     704:	00d706b3          	add	a3,a4,a3
     708:	0006c603          	lbu	a2,0(a3)
        if (c == '0' && i >= digits) continue;
     70c:	00a00693          	li	a3,10
     710:	00d61863          	bne	a2,a3,720 <_stack_size+0x320>
        UART0->DATA = '\r';
     714:	830006b7          	lui	a3,0x83000
     718:	00d00813          	li	a6,13
     71c:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     720:	0187d693          	srli	a3,a5,0x18
     724:	00f6f693          	andi	a3,a3,15
     728:	00d706b3          	add	a3,a4,a3
     72c:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     730:	830006b7          	lui	a3,0x83000
     734:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     738:	00a00613          	li	a2,10
     73c:	00c81663          	bne	a6,a2,748 <_stack_size+0x348>
        UART0->DATA = '\r';
     740:	00d00613          	li	a2,13
     744:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     748:	0147d693          	srli	a3,a5,0x14
     74c:	00f6f693          	andi	a3,a3,15
     750:	00d706b3          	add	a3,a4,a3
     754:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     758:	830006b7          	lui	a3,0x83000
     75c:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     760:	00a00813          	li	a6,10
     764:	01061663          	bne	a2,a6,770 <_stack_size+0x370>
        UART0->DATA = '\r';
     768:	00d00813          	li	a6,13
     76c:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     770:	0107d693          	srli	a3,a5,0x10
     774:	00f6f693          	andi	a3,a3,15
     778:	00d706b3          	add	a3,a4,a3
     77c:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     780:	830006b7          	lui	a3,0x83000
     784:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     788:	00a00613          	li	a2,10
     78c:	00c81663          	bne	a6,a2,798 <_stack_size+0x398>
        UART0->DATA = '\r';
     790:	00d00613          	li	a2,13
     794:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     798:	00c7d693          	srli	a3,a5,0xc
     79c:	00f6f693          	andi	a3,a3,15
     7a0:	00d706b3          	add	a3,a4,a3
     7a4:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     7a8:	830006b7          	lui	a3,0x83000
     7ac:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     7b0:	00a00813          	li	a6,10
     7b4:	01061663          	bne	a2,a6,7c0 <_stack_size+0x3c0>
        UART0->DATA = '\r';
     7b8:	00d00813          	li	a6,13
     7bc:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     7c0:	0087d693          	srli	a3,a5,0x8
     7c4:	00f6f693          	andi	a3,a3,15
     7c8:	00d706b3          	add	a3,a4,a3
     7cc:	0006c803          	lbu	a6,0(a3)
    UART0->DATA = c;
     7d0:	830006b7          	lui	a3,0x83000
     7d4:	00c6a023          	sw	a2,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     7d8:	00a00613          	li	a2,10
     7dc:	00c81663          	bne	a6,a2,7e8 <_stack_size+0x3e8>
        UART0->DATA = '\r';
     7e0:	00d00613          	li	a2,13
     7e4:	00c6a023          	sw	a2,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     7e8:	0047d693          	srli	a3,a5,0x4
     7ec:	00f6f693          	andi	a3,a3,15
     7f0:	00d706b3          	add	a3,a4,a3
     7f4:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
     7f8:	830006b7          	lui	a3,0x83000
     7fc:	0106a023          	sw	a6,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     800:	00a00813          	li	a6,10
     804:	01061663          	bne	a2,a6,810 <_stack_size+0x410>
        UART0->DATA = '\r';
     808:	00d00813          	li	a6,13
     80c:	0106a023          	sw	a6,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     810:	00f7f793          	andi	a5,a5,15
     814:	00f707b3          	add	a5,a4,a5
     818:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     81c:	830007b7          	lui	a5,0x83000
     820:	00c7a023          	sw	a2,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     824:	00a00693          	li	a3,10
     828:	00d71663          	bne	a4,a3,834 <_stack_size+0x434>
        UART0->DATA = '\r';
     82c:	00d00693          	li	a3,13
     830:	00d7a023          	sw	a3,0(a5)
    UART0->DATA = c;
     834:	830007b7          	lui	a5,0x83000
     838:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     83c:	00d00713          	li	a4,13
     840:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     844:	00a00713          	li	a4,10
     848:	00e7a023          	sw	a4,0(a5)
    return c;
     84c:	b75ff06f          	j	3c0 <cmd_benchmark+0xac>
        UART0->DATA = '\r';
     850:	00682023          	sw	t1,0(a6)
    UART0->DATA = c;
     854:	00c82023          	sw	a2,0(a6)
    while (*p)
     858:	0006c603          	lbu	a2,0(a3)
     85c:	d0061ae3          	bnez	a2,570 <_stack_size+0x170>
        print_hex(instns_end - instns_begin, 8);
     860:	41e586b3          	sub	a3,a1,t5
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     864:	01c6d613          	srli	a2,a3,0x1c
     868:	00c70633          	add	a2,a4,a2
     86c:	00064803          	lbu	a6,0(a2)
        if (c == '0' && i >= digits) continue;
     870:	00a00613          	li	a2,10
     874:	d2c804e3          	beq	a6,a2,59c <_stack_size+0x19c>
     878:	d31ff06f          	j	5a8 <_stack_size+0x1a8>
        UART0->DATA = '\r';
     87c:	01162023          	sw	a7,0(a2)
    UART0->DATA = c;
     880:	00d62023          	sw	a3,0(a2)
    while (*p)
     884:	00074683          	lbu	a3,0(a4)
     888:	b60692e3          	bnez	a3,3ec <cmd_benchmark+0xd8>
        print_hex(cycles_end - cycles_begin, 8);
     88c:	40550533          	sub	a0,a0,t0
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     890:	00002737          	lui	a4,0x2
     894:	4b070713          	addi	a4,a4,1200 # 24b0 <irqCallback+0x4>
     898:	01c55693          	srli	a3,a0,0x1c
     89c:	00d706b3          	add	a3,a4,a3
     8a0:	0006c803          	lbu	a6,0(a3)
        if (c == '0' && i >= digits) continue;
     8a4:	00a00693          	li	a3,10
     8a8:	b6d80ce3          	beq	a6,a3,420 <_stack_size+0x20>
     8ac:	b81ff06f          	j	42c <_stack_size+0x2c>
        UART0->DATA = '\r';
     8b0:	00682023          	sw	t1,0(a6)
    UART0->DATA = c;
     8b4:	00c82023          	sw	a2,0(a6)
    while (*p)
     8b8:	0006c603          	lbu	a2,0(a3)
     8bc:	e20618e3          	bnez	a2,6ec <_stack_size+0x2ec>
     8c0:	e41ff06f          	j	700 <_stack_size+0x300>

000008c4 <cmd_benchmark_all>:

void cmd_benchmark_all()
{
     8c4:	fe010113          	addi	sp,sp,-32
    uint32_t instns = 0;
     8c8:	00002737          	lui	a4,0x2
{
     8cc:	00112e23          	sw	ra,28(sp)
     8d0:	00812c23          	sw	s0,24(sp)
     8d4:	00912a23          	sw	s1,20(sp)
    uint32_t instns = 0;
     8d8:	00012623          	sw	zero,12(sp)
    while (*p)
     8dc:	06400793          	li	a5,100
    uint32_t instns = 0;
     8e0:	4e870713          	addi	a4,a4,1256 # 24e8 <irqCallback+0x3c>
    if (c == '\n')
     8e4:	00a00613          	li	a2,10
    UART0->DATA = c;
     8e8:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     8ec:	00d00593          	li	a1,13
        putchar(*(p++));
     8f0:	00170713          	addi	a4,a4,1
    if (c == '\n')
     8f4:	7ec78663          	beq	a5,a2,10e0 <cmd_benchmark_all+0x81c>
    UART0->DATA = c;
     8f8:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     8fc:	00074783          	lbu	a5,0(a4)
     900:	fe0798e3          	bnez	a5,8f0 <cmd_benchmark_all+0x2c>
        QSPI0->REG &= ~QSPI_REG_DSPI;
     904:	810007b7          	lui	a5,0x81000
     908:	0007a703          	lw	a4,0(a5) # 81000000 <__global_pointer$+0x40fff800>
     90c:	ffc006b7          	lui	a3,0xffc00
     910:	fff68693          	addi	a3,a3,-1 # ffbfffff <__global_pointer$+0xbfbff7ff>
     914:	00d77733          	and	a4,a4,a3
     918:	00e7a023          	sw	a4,0(a5)
        QSPI0->REG &= ~QSPI_REG_CRM;
     91c:	0007a683          	lw	a3,0(a5)
     920:	fff00637          	lui	a2,0xfff00
     924:	fff60613          	addi	a2,a2,-1 # ffefffff <__global_pointer$+0xbfeff7ff>
     928:	00c6f6b3          	and	a3,a3,a2
     92c:	00002737          	lui	a4,0x2
     930:	00d7a023          	sw	a3,0(a5)
     934:	4f870493          	addi	s1,a4,1272 # 24f8 <irqCallback+0x4c>
    while (*p)
     938:	03a00793          	li	a5,58
        QSPI0->REG &= ~QSPI_REG_CRM;
     93c:	4f870713          	addi	a4,a4,1272
    if (c == '\n')
     940:	00a00613          	li	a2,10
    UART0->DATA = c;
     944:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     948:	00d00593          	li	a1,13
        putchar(*(p++));
     94c:	00170713          	addi	a4,a4,1
    if (c == '\n')
     950:	76c78e63          	beq	a5,a2,10cc <cmd_benchmark_all+0x808>
    UART0->DATA = c;
     954:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     958:	00074783          	lbu	a5,0(a4)
     95c:	fe0798e3          	bnez	a5,94c <cmd_benchmark_all+0x88>

    cmd_set_dspi(0);
    cmd_set_crm(0);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
     960:	00c10593          	addi	a1,sp,12
     964:	00000513          	li	a0,0
     968:	9adff0ef          	jal	314 <cmd_benchmark>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     96c:	00002437          	lui	s0,0x2
     970:	4b040413          	addi	s0,s0,1200 # 24b0 <irqCallback+0x4>
     974:	01c55793          	srli	a5,a0,0x1c
     978:	00f407b3          	add	a5,s0,a5
     97c:	0007c683          	lbu	a3,0(a5)
        if (c == '0' && i >= digits) continue;
     980:	00a00793          	li	a5,10
     984:	00f69863          	bne	a3,a5,994 <cmd_benchmark_all+0xd0>
        UART0->DATA = '\r';
     988:	830007b7          	lui	a5,0x83000
     98c:	00d00713          	li	a4,13
     990:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     994:	01855793          	srli	a5,a0,0x18
     998:	00f7f793          	andi	a5,a5,15
     99c:	00f407b3          	add	a5,s0,a5
     9a0:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     9a4:	830007b7          	lui	a5,0x83000
     9a8:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     9ac:	00a00693          	li	a3,10
     9b0:	00d71663          	bne	a4,a3,9bc <cmd_benchmark_all+0xf8>
        UART0->DATA = '\r';
     9b4:	00d00693          	li	a3,13
     9b8:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     9bc:	01455793          	srli	a5,a0,0x14
     9c0:	00f7f793          	andi	a5,a5,15
     9c4:	00f407b3          	add	a5,s0,a5
     9c8:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     9cc:	830007b7          	lui	a5,0x83000
     9d0:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     9d4:	00a00713          	li	a4,10
     9d8:	00e69663          	bne	a3,a4,9e4 <cmd_benchmark_all+0x120>
        UART0->DATA = '\r';
     9dc:	00d00713          	li	a4,13
     9e0:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     9e4:	01055793          	srli	a5,a0,0x10
     9e8:	00f7f793          	andi	a5,a5,15
     9ec:	00f407b3          	add	a5,s0,a5
     9f0:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     9f4:	830007b7          	lui	a5,0x83000
     9f8:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     9fc:	00a00693          	li	a3,10
     a00:	00d71663          	bne	a4,a3,a0c <cmd_benchmark_all+0x148>
        UART0->DATA = '\r';
     a04:	00d00693          	li	a3,13
     a08:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     a0c:	00c55793          	srli	a5,a0,0xc
     a10:	00f7f793          	andi	a5,a5,15
     a14:	00f407b3          	add	a5,s0,a5
     a18:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     a1c:	830007b7          	lui	a5,0x83000
     a20:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     a24:	00a00713          	li	a4,10
     a28:	00e69663          	bne	a3,a4,a34 <cmd_benchmark_all+0x170>
        UART0->DATA = '\r';
     a2c:	00d00713          	li	a4,13
     a30:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     a34:	00855793          	srli	a5,a0,0x8
     a38:	00f7f793          	andi	a5,a5,15
     a3c:	00f407b3          	add	a5,s0,a5
     a40:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     a44:	830007b7          	lui	a5,0x83000
     a48:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     a4c:	00a00693          	li	a3,10
     a50:	00d71663          	bne	a4,a3,a5c <cmd_benchmark_all+0x198>
        UART0->DATA = '\r';
     a54:	00d00693          	li	a3,13
     a58:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     a5c:	00455793          	srli	a5,a0,0x4
     a60:	00f7f793          	andi	a5,a5,15
     a64:	00f407b3          	add	a5,s0,a5
     a68:	0007c783          	lbu	a5,0(a5)
    UART0->DATA = c;
     a6c:	830006b7          	lui	a3,0x83000
     a70:	00e6a023          	sw	a4,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     a74:	00a00713          	li	a4,10
     a78:	00e79663          	bne	a5,a4,a84 <cmd_benchmark_all+0x1c0>
        UART0->DATA = '\r';
     a7c:	00d00713          	li	a4,13
     a80:	00e6a023          	sw	a4,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     a84:	00f57513          	andi	a0,a0,15
     a88:	00a40533          	add	a0,s0,a0
     a8c:	00054703          	lbu	a4,0(a0)
    UART0->DATA = c;
     a90:	830006b7          	lui	a3,0x83000
     a94:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     a98:	00a00793          	li	a5,10
     a9c:	00f71663          	bne	a4,a5,aa8 <cmd_benchmark_all+0x1e4>
        UART0->DATA = '\r';
     aa0:	00d00793          	li	a5,13
     aa4:	00f6a023          	sw	a5,0(a3)
    UART0->DATA = c;
     aa8:	830007b7          	lui	a5,0x83000
     aac:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     ab0:	00d00713          	li	a4,13
     ab4:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     ab8:	00a00713          	li	a4,10
     abc:	00e7a023          	sw	a4,0(a5)
     ac0:	00002737          	lui	a4,0x2
    while (*p)
     ac4:	06400793          	li	a5,100
    UART0->DATA = c;
     ac8:	4fc70713          	addi	a4,a4,1276 # 24fc <irqCallback+0x50>
    if (c == '\n')
     acc:	00a00613          	li	a2,10
    UART0->DATA = c;
     ad0:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     ad4:	00d00593          	li	a1,13
        putchar(*(p++));
     ad8:	00170713          	addi	a4,a4,1
    if (c == '\n')
     adc:	5cc78e63          	beq	a5,a2,10b8 <cmd_benchmark_all+0x7f4>
    UART0->DATA = c;
     ae0:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     ae4:	00074783          	lbu	a5,0(a4)
     ae8:	fe0798e3          	bnez	a5,ad8 <cmd_benchmark_all+0x214>
    UART0->DATA = c;
     aec:	830007b7          	lui	a5,0x83000
     af0:	03000713          	li	a4,48
     af4:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
     af8:	00002737          	lui	a4,0x2
    while (*p)
     afc:	02000793          	li	a5,32
    UART0->DATA = c;
     b00:	50470713          	addi	a4,a4,1284 # 2504 <irqCallback+0x58>
    if (c == '\n')
     b04:	00a00613          	li	a2,10
    UART0->DATA = c;
     b08:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     b0c:	00d00593          	li	a1,13
        putchar(*(p++));
     b10:	00170713          	addi	a4,a4,1
    if (c == '\n')
     b14:	58c78863          	beq	a5,a2,10a4 <cmd_benchmark_all+0x7e0>
    UART0->DATA = c;
     b18:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     b1c:	00074783          	lbu	a5,0(a4)
     b20:	fe0798e3          	bnez	a5,b10 <cmd_benchmark_all+0x24c>
        QSPI0->REG |= QSPI_REG_DSPI;
     b24:	810006b7          	lui	a3,0x81000
     b28:	0006a703          	lw	a4,0(a3) # 81000000 <__global_pointer$+0x40fff800>
     b2c:	00400637          	lui	a2,0x400
    while (*p)
     b30:	03a00793          	li	a5,58
        QSPI0->REG |= QSPI_REG_DSPI;
     b34:	00c76733          	or	a4,a4,a2
     b38:	00e6a023          	sw	a4,0(a3)
    if (c == '\n')
     b3c:	00a00613          	li	a2,10
        QSPI0->REG |= QSPI_REG_DSPI;
     b40:	00048713          	mv	a4,s1
    UART0->DATA = c;
     b44:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     b48:	00d00593          	li	a1,13
        putchar(*(p++));
     b4c:	00170713          	addi	a4,a4,1
    if (c == '\n')
     b50:	54c78063          	beq	a5,a2,1090 <cmd_benchmark_all+0x7cc>
    UART0->DATA = c;
     b54:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     b58:	00074783          	lbu	a5,0(a4)
     b5c:	fe0798e3          	bnez	a5,b4c <cmd_benchmark_all+0x288>
    print("         ");

    cmd_set_dspi(1);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
     b60:	00c10593          	addi	a1,sp,12
     b64:	00000513          	li	a0,0
     b68:	facff0ef          	jal	314 <cmd_benchmark>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     b6c:	01c55793          	srli	a5,a0,0x1c
     b70:	00f407b3          	add	a5,s0,a5
     b74:	0007c683          	lbu	a3,0(a5)
        if (c == '0' && i >= digits) continue;
     b78:	00a00793          	li	a5,10
     b7c:	00f69863          	bne	a3,a5,b8c <cmd_benchmark_all+0x2c8>
        UART0->DATA = '\r';
     b80:	830007b7          	lui	a5,0x83000
     b84:	00d00713          	li	a4,13
     b88:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     b8c:	01855793          	srli	a5,a0,0x18
     b90:	00f7f793          	andi	a5,a5,15
     b94:	00f407b3          	add	a5,s0,a5
     b98:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     b9c:	830007b7          	lui	a5,0x83000
     ba0:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     ba4:	00a00693          	li	a3,10
     ba8:	00d71663          	bne	a4,a3,bb4 <cmd_benchmark_all+0x2f0>
        UART0->DATA = '\r';
     bac:	00d00693          	li	a3,13
     bb0:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     bb4:	01455793          	srli	a5,a0,0x14
     bb8:	00f7f793          	andi	a5,a5,15
     bbc:	00f407b3          	add	a5,s0,a5
     bc0:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     bc4:	830007b7          	lui	a5,0x83000
     bc8:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     bcc:	00a00713          	li	a4,10
     bd0:	00e69663          	bne	a3,a4,bdc <cmd_benchmark_all+0x318>
        UART0->DATA = '\r';
     bd4:	00d00713          	li	a4,13
     bd8:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     bdc:	01055793          	srli	a5,a0,0x10
     be0:	00f7f793          	andi	a5,a5,15
     be4:	00f407b3          	add	a5,s0,a5
     be8:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     bec:	830007b7          	lui	a5,0x83000
     bf0:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     bf4:	00a00693          	li	a3,10
     bf8:	00d71663          	bne	a4,a3,c04 <cmd_benchmark_all+0x340>
        UART0->DATA = '\r';
     bfc:	00d00693          	li	a3,13
     c00:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     c04:	00c55793          	srli	a5,a0,0xc
     c08:	00f7f793          	andi	a5,a5,15
     c0c:	00f407b3          	add	a5,s0,a5
     c10:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     c14:	830007b7          	lui	a5,0x83000
     c18:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     c1c:	00a00713          	li	a4,10
     c20:	00e69663          	bne	a3,a4,c2c <cmd_benchmark_all+0x368>
        UART0->DATA = '\r';
     c24:	00d00713          	li	a4,13
     c28:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     c2c:	00855793          	srli	a5,a0,0x8
     c30:	00f7f793          	andi	a5,a5,15
     c34:	00f407b3          	add	a5,s0,a5
     c38:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     c3c:	830007b7          	lui	a5,0x83000
     c40:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     c44:	00a00693          	li	a3,10
     c48:	00d71663          	bne	a4,a3,c54 <cmd_benchmark_all+0x390>
        UART0->DATA = '\r';
     c4c:	00d00693          	li	a3,13
     c50:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     c54:	00455793          	srli	a5,a0,0x4
     c58:	00f7f793          	andi	a5,a5,15
     c5c:	00f407b3          	add	a5,s0,a5
     c60:	0007c783          	lbu	a5,0(a5)
    UART0->DATA = c;
     c64:	830006b7          	lui	a3,0x83000
     c68:	00e6a023          	sw	a4,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     c6c:	00a00713          	li	a4,10
     c70:	00e79663          	bne	a5,a4,c7c <cmd_benchmark_all+0x3b8>
        UART0->DATA = '\r';
     c74:	00d00713          	li	a4,13
     c78:	00e6a023          	sw	a4,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     c7c:	00f57513          	andi	a0,a0,15
     c80:	00a40533          	add	a0,s0,a0
     c84:	00054703          	lbu	a4,0(a0)
    UART0->DATA = c;
     c88:	830006b7          	lui	a3,0x83000
     c8c:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     c90:	00a00793          	li	a5,10
     c94:	00f71663          	bne	a4,a5,ca0 <cmd_benchmark_all+0x3dc>
        UART0->DATA = '\r';
     c98:	00d00793          	li	a5,13
     c9c:	00f6a023          	sw	a5,0(a3)
    UART0->DATA = c;
     ca0:	830007b7          	lui	a5,0x83000
     ca4:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     ca8:	00d00713          	li	a4,13
     cac:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     cb0:	00a00713          	li	a4,10
     cb4:	00e7a023          	sw	a4,0(a5)
     cb8:	00002737          	lui	a4,0x2
    while (*p)
     cbc:	06400793          	li	a5,100
    UART0->DATA = c;
     cc0:	51070713          	addi	a4,a4,1296 # 2510 <irqCallback+0x64>
    if (c == '\n')
     cc4:	00a00613          	li	a2,10
    UART0->DATA = c;
     cc8:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     ccc:	00d00593          	li	a1,13
        putchar(*(p++));
     cd0:	00170713          	addi	a4,a4,1
    if (c == '\n')
     cd4:	3ac78463          	beq	a5,a2,107c <cmd_benchmark_all+0x7b8>
    UART0->DATA = c;
     cd8:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     cdc:	00074783          	lbu	a5,0(a4)
     ce0:	fe0798e3          	bnez	a5,cd0 <cmd_benchmark_all+0x40c>
    UART0->DATA = c;
     ce4:	830007b7          	lui	a5,0x83000
     ce8:	03000713          	li	a4,48
     cec:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
     cf0:	00002737          	lui	a4,0x2
    while (*p)
     cf4:	02000793          	li	a5,32
    UART0->DATA = c;
     cf8:	50870713          	addi	a4,a4,1288 # 2508 <irqCallback+0x5c>
    if (c == '\n')
     cfc:	00a00613          	li	a2,10
    UART0->DATA = c;
     d00:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     d04:	00d00593          	li	a1,13
        putchar(*(p++));
     d08:	00170713          	addi	a4,a4,1
    if (c == '\n')
     d0c:	34c78e63          	beq	a5,a2,1068 <cmd_benchmark_all+0x7a4>
    UART0->DATA = c;
     d10:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     d14:	00074783          	lbu	a5,0(a4)
     d18:	fe0798e3          	bnez	a5,d08 <cmd_benchmark_all+0x444>
        QSPI0->REG |= QSPI_REG_CRM;
     d1c:	810006b7          	lui	a3,0x81000
     d20:	0006a703          	lw	a4,0(a3) # 81000000 <__global_pointer$+0x40fff800>
     d24:	00100637          	lui	a2,0x100
    while (*p)
     d28:	03a00793          	li	a5,58
        QSPI0->REG |= QSPI_REG_CRM;
     d2c:	00c76733          	or	a4,a4,a2
     d30:	00e6a023          	sw	a4,0(a3)
    if (c == '\n')
     d34:	00a00613          	li	a2,10
        QSPI0->REG |= QSPI_REG_CRM;
     d38:	00048713          	mv	a4,s1
    UART0->DATA = c;
     d3c:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     d40:	00d00593          	li	a1,13
        putchar(*(p++));
     d44:	00170713          	addi	a4,a4,1
    if (c == '\n')
     d48:	30c78663          	beq	a5,a2,1054 <cmd_benchmark_all+0x790>
    UART0->DATA = c;
     d4c:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     d50:	00074783          	lbu	a5,0(a4)
     d54:	fe0798e3          	bnez	a5,d44 <cmd_benchmark_all+0x480>
    print("     ");

    cmd_set_crm(1);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
     d58:	00c10593          	addi	a1,sp,12
     d5c:	00000513          	li	a0,0
     d60:	db4ff0ef          	jal	314 <cmd_benchmark>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     d64:	01c55793          	srli	a5,a0,0x1c
     d68:	00f407b3          	add	a5,s0,a5
     d6c:	0007c683          	lbu	a3,0(a5)
        if (c == '0' && i >= digits) continue;
     d70:	00a00793          	li	a5,10
     d74:	00f69863          	bne	a3,a5,d84 <cmd_benchmark_all+0x4c0>
        UART0->DATA = '\r';
     d78:	830007b7          	lui	a5,0x83000
     d7c:	00d00713          	li	a4,13
     d80:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     d84:	01855793          	srli	a5,a0,0x18
     d88:	00f7f793          	andi	a5,a5,15
     d8c:	00f407b3          	add	a5,s0,a5
     d90:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     d94:	830007b7          	lui	a5,0x83000
     d98:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     d9c:	00a00693          	li	a3,10
     da0:	00d71663          	bne	a4,a3,dac <cmd_benchmark_all+0x4e8>
        UART0->DATA = '\r';
     da4:	00d00693          	li	a3,13
     da8:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     dac:	01455793          	srli	a5,a0,0x14
     db0:	00f7f793          	andi	a5,a5,15
     db4:	00f407b3          	add	a5,s0,a5
     db8:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     dbc:	830007b7          	lui	a5,0x83000
     dc0:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     dc4:	00a00713          	li	a4,10
     dc8:	00e69663          	bne	a3,a4,dd4 <cmd_benchmark_all+0x510>
        UART0->DATA = '\r';
     dcc:	00d00713          	li	a4,13
     dd0:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     dd4:	01055793          	srli	a5,a0,0x10
     dd8:	00f7f793          	andi	a5,a5,15
     ddc:	00f407b3          	add	a5,s0,a5
     de0:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     de4:	830007b7          	lui	a5,0x83000
     de8:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     dec:	00a00693          	li	a3,10
     df0:	00d71663          	bne	a4,a3,dfc <cmd_benchmark_all+0x538>
        UART0->DATA = '\r';
     df4:	00d00693          	li	a3,13
     df8:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     dfc:	00c55793          	srli	a5,a0,0xc
     e00:	00f7f793          	andi	a5,a5,15
     e04:	00f407b3          	add	a5,s0,a5
     e08:	0007c683          	lbu	a3,0(a5)
    UART0->DATA = c;
     e0c:	830007b7          	lui	a5,0x83000
     e10:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     e14:	00a00713          	li	a4,10
     e18:	00e69663          	bne	a3,a4,e24 <cmd_benchmark_all+0x560>
        UART0->DATA = '\r';
     e1c:	00d00713          	li	a4,13
     e20:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     e24:	00855793          	srli	a5,a0,0x8
     e28:	00f7f793          	andi	a5,a5,15
     e2c:	00f407b3          	add	a5,s0,a5
     e30:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     e34:	830007b7          	lui	a5,0x83000
     e38:	00d7a023          	sw	a3,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     e3c:	00a00693          	li	a3,10
     e40:	00d71663          	bne	a4,a3,e4c <cmd_benchmark_all+0x588>
        UART0->DATA = '\r';
     e44:	00d00693          	li	a3,13
     e48:	00d7a023          	sw	a3,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     e4c:	00455793          	srli	a5,a0,0x4
     e50:	00f7f793          	andi	a5,a5,15
     e54:	00f407b3          	add	a5,s0,a5
     e58:	0007c783          	lbu	a5,0(a5)
    UART0->DATA = c;
     e5c:	830006b7          	lui	a3,0x83000
     e60:	00e6a023          	sw	a4,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     e64:	00a00713          	li	a4,10
     e68:	00e79663          	bne	a5,a4,e74 <cmd_benchmark_all+0x5b0>
        UART0->DATA = '\r';
     e6c:	00d00713          	li	a4,13
     e70:	00e6a023          	sw	a4,0(a3)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     e74:	00f57513          	andi	a0,a0,15
     e78:	00a40533          	add	a0,s0,a0
     e7c:	00054703          	lbu	a4,0(a0)
    UART0->DATA = c;
     e80:	830006b7          	lui	a3,0x83000
     e84:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     e88:	00a00793          	li	a5,10
     e8c:	00f71663          	bne	a4,a5,e98 <cmd_benchmark_all+0x5d4>
        UART0->DATA = '\r';
     e90:	00d00793          	li	a5,13
     e94:	00f6a023          	sw	a5,0(a3)
    UART0->DATA = c;
     e98:	830007b7          	lui	a5,0x83000
     e9c:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        UART0->DATA = '\r';
     ea0:	00d00713          	li	a4,13
     ea4:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
     ea8:	00a00713          	li	a4,10
     eac:	00e7a023          	sw	a4,0(a5)
     eb0:	00002737          	lui	a4,0x2
    while (*p)
     eb4:	06900793          	li	a5,105
    UART0->DATA = c;
     eb8:	51c70713          	addi	a4,a4,1308 # 251c <irqCallback+0x70>
    if (c == '\n')
     ebc:	00a00613          	li	a2,10
    UART0->DATA = c;
     ec0:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
     ec4:	00d00593          	li	a1,13
        putchar(*(p++));
     ec8:	00170713          	addi	a4,a4,1
    if (c == '\n')
     ecc:	16c78a63          	beq	a5,a2,1040 <cmd_benchmark_all+0x77c>
    UART0->DATA = c;
     ed0:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
     ed4:	00074783          	lbu	a5,0(a4)
     ed8:	fe0798e3          	bnez	a5,ec8 <cmd_benchmark_all+0x604>
    putchar('\n');

    print("instns         : ");
    print_hex(instns, 8);
     edc:	00c12683          	lw	a3,12(sp)
        if (c == '0' && i >= digits) continue;
     ee0:	00a00793          	li	a5,10
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     ee4:	01c6d713          	srli	a4,a3,0x1c
     ee8:	00e40733          	add	a4,s0,a4
     eec:	00074603          	lbu	a2,0(a4)
        if (c == '0' && i >= digits) continue;
     ef0:	00f61863          	bne	a2,a5,f00 <cmd_benchmark_all+0x63c>
        UART0->DATA = '\r';
     ef4:	830007b7          	lui	a5,0x83000
     ef8:	00d00713          	li	a4,13
     efc:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     f00:	0186d793          	srli	a5,a3,0x18
     f04:	00f7f793          	andi	a5,a5,15
     f08:	00f407b3          	add	a5,s0,a5
     f0c:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     f10:	830007b7          	lui	a5,0x83000
     f14:	00c7a023          	sw	a2,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     f18:	00a00613          	li	a2,10
     f1c:	00c71663          	bne	a4,a2,f28 <cmd_benchmark_all+0x664>
        UART0->DATA = '\r';
     f20:	00d00613          	li	a2,13
     f24:	00c7a023          	sw	a2,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     f28:	0146d793          	srli	a5,a3,0x14
     f2c:	00f7f793          	andi	a5,a5,15
     f30:	00f407b3          	add	a5,s0,a5
     f34:	0007c603          	lbu	a2,0(a5)
    UART0->DATA = c;
     f38:	830007b7          	lui	a5,0x83000
     f3c:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     f40:	00a00713          	li	a4,10
     f44:	00e61663          	bne	a2,a4,f50 <cmd_benchmark_all+0x68c>
        UART0->DATA = '\r';
     f48:	00d00713          	li	a4,13
     f4c:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     f50:	0106d793          	srli	a5,a3,0x10
     f54:	00f7f793          	andi	a5,a5,15
     f58:	00f407b3          	add	a5,s0,a5
     f5c:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     f60:	830007b7          	lui	a5,0x83000
     f64:	00c7a023          	sw	a2,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     f68:	00a00613          	li	a2,10
     f6c:	00c71663          	bne	a4,a2,f78 <cmd_benchmark_all+0x6b4>
        UART0->DATA = '\r';
     f70:	00d00613          	li	a2,13
     f74:	00c7a023          	sw	a2,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     f78:	00c6d793          	srli	a5,a3,0xc
     f7c:	00f7f793          	andi	a5,a5,15
     f80:	00f407b3          	add	a5,s0,a5
     f84:	0007c603          	lbu	a2,0(a5)
    UART0->DATA = c;
     f88:	830007b7          	lui	a5,0x83000
     f8c:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     f90:	00a00713          	li	a4,10
     f94:	00e61663          	bne	a2,a4,fa0 <cmd_benchmark_all+0x6dc>
        UART0->DATA = '\r';
     f98:	00d00713          	li	a4,13
     f9c:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     fa0:	0086d793          	srli	a5,a3,0x8
     fa4:	00f7f793          	andi	a5,a5,15
     fa8:	00f407b3          	add	a5,s0,a5
     fac:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     fb0:	830007b7          	lui	a5,0x83000
     fb4:	00c7a023          	sw	a2,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     fb8:	00a00613          	li	a2,10
     fbc:	00c71663          	bne	a4,a2,fc8 <cmd_benchmark_all+0x704>
        UART0->DATA = '\r';
     fc0:	00d00613          	li	a2,13
     fc4:	00c7a023          	sw	a2,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     fc8:	0046d793          	srli	a5,a3,0x4
     fcc:	00f7f793          	andi	a5,a5,15
     fd0:	00f407b3          	add	a5,s0,a5
     fd4:	0007c603          	lbu	a2,0(a5)
    UART0->DATA = c;
     fd8:	830007b7          	lui	a5,0x83000
     fdc:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
     fe0:	00a00713          	li	a4,10
     fe4:	00e61663          	bne	a2,a4,ff0 <cmd_benchmark_all+0x72c>
        UART0->DATA = '\r';
     fe8:	00d00713          	li	a4,13
     fec:	00e7a023          	sw	a4,0(a5)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
     ff0:	00f6f793          	andi	a5,a3,15
     ff4:	00f407b3          	add	a5,s0,a5
     ff8:	0007c703          	lbu	a4,0(a5)
    UART0->DATA = c;
     ffc:	830007b7          	lui	a5,0x83000
    1000:	00c7a023          	sw	a2,0(a5) # 83000000 <__global_pointer$+0x42fff800>
        if (c == '0' && i >= digits) continue;
    1004:	00a00693          	li	a3,10
    1008:	00d71663          	bne	a4,a3,1014 <cmd_benchmark_all+0x750>
        UART0->DATA = '\r';
    100c:	00d00693          	li	a3,13
    1010:	00d7a023          	sw	a3,0(a5)
    UART0->DATA = c;
    1014:	830007b7          	lui	a5,0x83000
    1018:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
    putchar('\n');
}
    101c:	01c12083          	lw	ra,28(sp)
    1020:	01812403          	lw	s0,24(sp)
        UART0->DATA = '\r';
    1024:	00d00713          	li	a4,13
    1028:	00e7a023          	sw	a4,0(a5)
    UART0->DATA = c;
    102c:	00a00713          	li	a4,10
    1030:	00e7a023          	sw	a4,0(a5)
}
    1034:	01412483          	lw	s1,20(sp)
    1038:	02010113          	addi	sp,sp,32
    103c:	00008067          	ret
        UART0->DATA = '\r';
    1040:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    1044:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1048:	00074783          	lbu	a5,0(a4)
    104c:	e6079ee3          	bnez	a5,ec8 <cmd_benchmark_all+0x604>
    1050:	e8dff06f          	j	edc <cmd_benchmark_all+0x618>
        UART0->DATA = '\r';
    1054:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    1058:	00f6a023          	sw	a5,0(a3)
    while (*p)
    105c:	00074783          	lbu	a5,0(a4)
    1060:	ce0792e3          	bnez	a5,d44 <cmd_benchmark_all+0x480>
    1064:	cf5ff06f          	j	d58 <cmd_benchmark_all+0x494>
        UART0->DATA = '\r';
    1068:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    106c:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1070:	00074783          	lbu	a5,0(a4)
    1074:	c8079ae3          	bnez	a5,d08 <cmd_benchmark_all+0x444>
    1078:	ca5ff06f          	j	d1c <cmd_benchmark_all+0x458>
        UART0->DATA = '\r';
    107c:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    1080:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1084:	00074783          	lbu	a5,0(a4)
    1088:	c40794e3          	bnez	a5,cd0 <cmd_benchmark_all+0x40c>
    108c:	c59ff06f          	j	ce4 <cmd_benchmark_all+0x420>
        UART0->DATA = '\r';
    1090:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    1094:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1098:	00074783          	lbu	a5,0(a4)
    109c:	aa0798e3          	bnez	a5,b4c <cmd_benchmark_all+0x288>
    10a0:	ac1ff06f          	j	b60 <cmd_benchmark_all+0x29c>
        UART0->DATA = '\r';
    10a4:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    10a8:	00f6a023          	sw	a5,0(a3)
    while (*p)
    10ac:	00074783          	lbu	a5,0(a4)
    10b0:	a60790e3          	bnez	a5,b10 <cmd_benchmark_all+0x24c>
    10b4:	a71ff06f          	j	b24 <cmd_benchmark_all+0x260>
        UART0->DATA = '\r';
    10b8:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    10bc:	00f6a023          	sw	a5,0(a3)
    while (*p)
    10c0:	00074783          	lbu	a5,0(a4)
    10c4:	a0079ae3          	bnez	a5,ad8 <cmd_benchmark_all+0x214>
    10c8:	a25ff06f          	j	aec <cmd_benchmark_all+0x228>
        UART0->DATA = '\r';
    10cc:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    10d0:	00f6a023          	sw	a5,0(a3)
    while (*p)
    10d4:	00074783          	lbu	a5,0(a4)
    10d8:	86079ae3          	bnez	a5,94c <cmd_benchmark_all+0x88>
    10dc:	885ff06f          	j	960 <cmd_benchmark_all+0x9c>
        UART0->DATA = '\r';
    10e0:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    10e4:	00f6a023          	sw	a5,0(a3)
    while (*p)
    10e8:	00074783          	lbu	a5,0(a4)
    10ec:	800792e3          	bnez	a5,8f0 <cmd_benchmark_all+0x2c>
    10f0:	815ff06f          	j	904 <cmd_benchmark_all+0x40>

000010f4 <main>:

#define CLK_FREQ        25175000
#define UART_BAUD       115200

void main()
{
    10f4:	e7010113          	addi	sp,sp,-400
    10f8:	18112623          	sw	ra,396(sp)
    10fc:	18812423          	sw	s0,392(sp)
    1100:	18912223          	sw	s1,388(sp)
    1104:	19212023          	sw	s2,384(sp)
    1108:	17312e23          	sw	s3,380(sp)
    110c:	17412c23          	sw	s4,376(sp)
    1110:	17512a23          	sw	s5,372(sp)
    1114:	17612823          	sw	s6,368(sp)
    1118:	17712623          	sw	s7,364(sp)
    111c:	17812423          	sw	s8,360(sp)
    1120:	17912223          	sw	s9,356(sp)
    1124:	17a12023          	sw	s10,352(sp)
    1128:	15b12e23          	sw	s11,348(sp)
    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;
    112c:	83000737          	lui	a4,0x83000
    1130:	0d800793          	li	a5,216
    1134:	00f72223          	sw	a5,4(a4) # 83000004 <__global_pointer$+0x42fff804>

    GPIO0->OE = 0x3F;
    1138:	03f00693          	li	a3,63
    113c:	820007b7          	lui	a5,0x82000
    1140:	00d7a423          	sw	a3,8(a5) # 82000008 <__global_pointer$+0x41fff808>
    GPIO0->OUT = 0x3F;
    1144:	00d7a023          	sw	a3,0(a5)
        QSPI0->REG |= QSPI_REG_CRM;
    1148:	810007b7          	lui	a5,0x81000
    114c:	0007a683          	lw	a3,0(a5) # 81000000 <__global_pointer$+0x40fff800>
    1150:	00100637          	lui	a2,0x100
    if (c == '\n')
    1154:	00a00593          	li	a1,10
        QSPI0->REG |= QSPI_REG_CRM;
    1158:	00c6e6b3          	or	a3,a3,a2
    115c:	00d7a023          	sw	a3,0(a5)
        QSPI0->REG |= QSPI_REG_DSPI;
    1160:	0007a683          	lw	a3,0(a5)
    1164:	00400637          	lui	a2,0x400
    1168:	00c6e6b3          	or	a3,a3,a2
    116c:	00d7a023          	sw	a3,0(a5)
        UART0->DATA = '\r';
    1170:	00d00793          	li	a5,13
    1174:	00f72023          	sw	a5,0(a4)
    UART0->DATA = c;
    1178:	00a00793          	li	a5,10
    117c:	00f72023          	sw	a5,0(a4)
    while (*p)
    1180:	00002737          	lui	a4,0x2
    1184:	02000793          	li	a5,32
    1188:	53070713          	addi	a4,a4,1328 # 2530 <irqCallback+0x84>
    UART0->DATA = c;
    118c:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
    1190:	00d00613          	li	a2,13
        putchar(*(p++));
    1194:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1198:	72b78c63          	beq	a5,a1,18d0 <main+0x7dc>
    UART0->DATA = c;
    119c:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    11a0:	00074783          	lbu	a5,0(a4)
    11a4:	fe0798e3          	bnez	a5,1194 <main+0xa0>
    11a8:	00002737          	lui	a4,0x2
    11ac:	02000793          	li	a5,32
    11b0:	55870713          	addi	a4,a4,1368 # 2558 <irqCallback+0xac>
    if (c == '\n')
    11b4:	00a00593          	li	a1,10
    UART0->DATA = c;
    11b8:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
    11bc:	00d00613          	li	a2,13
        putchar(*(p++));
    11c0:	00170713          	addi	a4,a4,1
    if (c == '\n')
    11c4:	72b78063          	beq	a5,a1,18e4 <main+0x7f0>
    UART0->DATA = c;
    11c8:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    11cc:	00074783          	lbu	a5,0(a4)
    11d0:	fe0798e3          	bnez	a5,11c0 <main+0xcc>
    11d4:	00002737          	lui	a4,0x2
    11d8:	02000793          	li	a5,32
    11dc:	58070713          	addi	a4,a4,1408 # 2580 <irqCallback+0xd4>
    if (c == '\n')
    11e0:	00a00593          	li	a1,10
    UART0->DATA = c;
    11e4:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
    11e8:	00d00613          	li	a2,13
        putchar(*(p++));
    11ec:	00170713          	addi	a4,a4,1
    if (c == '\n')
    11f0:	70b78463          	beq	a5,a1,18f8 <main+0x804>
    UART0->DATA = c;
    11f4:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    11f8:	00074783          	lbu	a5,0(a4)
    11fc:	fe0798e3          	bnez	a5,11ec <main+0xf8>
    1200:	00002737          	lui	a4,0x2
    1204:	02000793          	li	a5,32
    1208:	5a470713          	addi	a4,a4,1444 # 25a4 <irqCallback+0xf8>
    if (c == '\n')
    120c:	00a00593          	li	a1,10
    UART0->DATA = c;
    1210:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
    1214:	00d00613          	li	a2,13
        putchar(*(p++));
    1218:	00170713          	addi	a4,a4,1
    if (c == '\n')
    121c:	6eb78863          	beq	a5,a1,190c <main+0x818>
    UART0->DATA = c;
    1220:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    1224:	00074783          	lbu	a5,0(a4)
    1228:	fe0798e3          	bnez	a5,1218 <main+0x124>
    122c:	00002737          	lui	a4,0x2
    1230:	02000793          	li	a5,32
    1234:	5cc70713          	addi	a4,a4,1484 # 25cc <irqCallback+0x120>
    if (c == '\n')
    1238:	00a00593          	li	a1,10
    UART0->DATA = c;
    123c:	830006b7          	lui	a3,0x83000
        UART0->DATA = '\r';
    1240:	00d00613          	li	a2,13
        putchar(*(p++));
    1244:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1248:	6eb78863          	beq	a5,a1,1938 <main+0x844>
    UART0->DATA = c;
    124c:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    1250:	00074783          	lbu	a5,0(a4)
    1254:	fe0798e3          	bnez	a5,1244 <main+0x150>
        UART0->DATA = '\r';
    1258:	830007b7          	lui	a5,0x83000
    125c:	00d00713          	li	a4,13
    1260:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
    UART0->DATA = c;
    1264:	00a00713          	li	a4,10
    1268:	00e7a023          	sw	a4,0(a5)
    while (*p)
    126c:	00002737          	lui	a4,0x2
    1270:	02000793          	li	a5,32
    1274:	5f470713          	addi	a4,a4,1524 # 25f4 <irqCallback+0x148>
    if (c == '\n')
    1278:	00a00613          	li	a2,10
        putchar(*(p++));
    127c:	00170713          	addi	a4,a4,1
        UART0->DATA = '\r';
    1280:	830006b7          	lui	a3,0x83000
    if (c == '\n')
    1284:	68c78e63          	beq	a5,a2,1920 <main+0x82c>
    UART0->DATA = c;
    1288:	00f6a023          	sw	a5,0(a3) # 83000000 <__global_pointer$+0x42fff800>
    while (*p)
    128c:	00074783          	lbu	a5,0(a4)
    1290:	fe0796e3          	bnez	a5,127c <main+0x188>
        UART0->DATA = '\r';
    1294:	830007b7          	lui	a5,0x83000
    1298:	00d00713          	li	a4,13
    129c:	00e7a023          	sw	a4,0(a5) # 83000000 <__global_pointer$+0x42fff800>
    UART0->DATA = c;
    12a0:	00a00713          	li	a4,10
    12a4:	00e7a023          	sw	a4,0(a5)
    print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
    print("\n");
    print("        On Lichee Tang Nano-9K\n");
    print("\n");

    for ( i = 0 ; i < 10000; i++);
    12a8:	400007b7          	lui	a5,0x40000
    12ac:	0007a223          	sw	zero,4(a5) # 40000004 <i>
    12b0:	0047a683          	lw	a3,4(a5)
    12b4:	00002737          	lui	a4,0x2
    12b8:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    12bc:	00d74c63          	blt	a4,a3,12d4 <main+0x1e0>
    12c0:	0047a683          	lw	a3,4(a5)
    12c4:	00168693          	addi	a3,a3,1
    12c8:	00d7a223          	sw	a3,4(a5)
    12cc:	0047a683          	lw	a3,4(a5)
    12d0:	fed758e3          	bge	a4,a3,12c0 <main+0x1cc>
    GPIO0->OUT = 0x3F ^ 0x01;
    12d4:	82000737          	lui	a4,0x82000
    12d8:	03e00693          	li	a3,62
    12dc:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    12e0:	0007a223          	sw	zero,4(a5)
    12e4:	0047a683          	lw	a3,4(a5)
    12e8:	00002737          	lui	a4,0x2
    12ec:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    12f0:	00d74c63          	blt	a4,a3,1308 <main+0x214>
    12f4:	0047a683          	lw	a3,4(a5)
    12f8:	00168693          	addi	a3,a3,1
    12fc:	00d7a223          	sw	a3,4(a5)
    1300:	0047a683          	lw	a3,4(a5)
    1304:	fed758e3          	bge	a4,a3,12f4 <main+0x200>
    GPIO0->OUT = 0x3F ^ 0x02;
    1308:	82000737          	lui	a4,0x82000
    130c:	03d00693          	li	a3,61
    1310:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    1314:	0007a223          	sw	zero,4(a5)
    1318:	0047a683          	lw	a3,4(a5)
    131c:	00002737          	lui	a4,0x2
    1320:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    1324:	00d74c63          	blt	a4,a3,133c <main+0x248>
    1328:	0047a683          	lw	a3,4(a5)
    132c:	00168693          	addi	a3,a3,1
    1330:	00d7a223          	sw	a3,4(a5)
    1334:	0047a683          	lw	a3,4(a5)
    1338:	fed758e3          	bge	a4,a3,1328 <main+0x234>
    GPIO0->OUT = 0x3F ^ 0x04;
    133c:	82000737          	lui	a4,0x82000
    1340:	03b00693          	li	a3,59
    1344:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    1348:	0007a223          	sw	zero,4(a5)
    134c:	0047a683          	lw	a3,4(a5)
    1350:	00002737          	lui	a4,0x2
    1354:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    1358:	00d74c63          	blt	a4,a3,1370 <main+0x27c>
    135c:	0047a683          	lw	a3,4(a5)
    1360:	00168693          	addi	a3,a3,1
    1364:	00d7a223          	sw	a3,4(a5)
    1368:	0047a683          	lw	a3,4(a5)
    136c:	fed758e3          	bge	a4,a3,135c <main+0x268>
    GPIO0->OUT = 0x3F ^ 0x08;
    1370:	82000737          	lui	a4,0x82000
    1374:	03700693          	li	a3,55
    1378:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    137c:	0007a223          	sw	zero,4(a5)
    1380:	0047a683          	lw	a3,4(a5)
    1384:	00002737          	lui	a4,0x2
    1388:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    138c:	00d74c63          	blt	a4,a3,13a4 <main+0x2b0>
    1390:	0047a683          	lw	a3,4(a5)
    1394:	00168693          	addi	a3,a3,1
    1398:	00d7a223          	sw	a3,4(a5)
    139c:	0047a683          	lw	a3,4(a5)
    13a0:	fed758e3          	bge	a4,a3,1390 <main+0x29c>
    GPIO0->OUT = 0x3F ^ 0x10;
    13a4:	82000737          	lui	a4,0x82000
    13a8:	02f00693          	li	a3,47
    13ac:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    13b0:	0007a223          	sw	zero,4(a5)
    13b4:	0047a683          	lw	a3,4(a5)
    13b8:	00002737          	lui	a4,0x2
    13bc:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    13c0:	00d74c63          	blt	a4,a3,13d8 <main+0x2e4>
    13c4:	0047a683          	lw	a3,4(a5)
    13c8:	00168693          	addi	a3,a3,1
    13cc:	00d7a223          	sw	a3,4(a5)
    13d0:	0047a683          	lw	a3,4(a5)
    13d4:	fed758e3          	bge	a4,a3,13c4 <main+0x2d0>
    GPIO0->OUT = 0x3F ^ 0x20;
    13d8:	82000737          	lui	a4,0x82000
    13dc:	01f00693          	li	a3,31
    13e0:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    13e4:	0007a223          	sw	zero,4(a5)
    13e8:	0047a683          	lw	a3,4(a5)
    13ec:	00002737          	lui	a4,0x2
    13f0:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    13f4:	00d74c63          	blt	a4,a3,140c <main+0x318>
    13f8:	0047a683          	lw	a3,4(a5)
    13fc:	00168693          	addi	a3,a3,1
    1400:	00d7a223          	sw	a3,4(a5)
    1404:	0047a683          	lw	a3,4(a5)
    1408:	fed758e3          	bge	a4,a3,13f8 <main+0x304>
    GPIO0->OUT = 0x3F;
    140c:	82000737          	lui	a4,0x82000
    1410:	03f00693          	li	a3,63
    1414:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    1418:	0007a223          	sw	zero,4(a5)
    141c:	0047a683          	lw	a3,4(a5)
    1420:	00002737          	lui	a4,0x2
    1424:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    1428:	00d74c63          	blt	a4,a3,1440 <main+0x34c>
    142c:	0047a683          	lw	a3,4(a5)
    1430:	00168693          	addi	a3,a3,1
    1434:	00d7a223          	sw	a3,4(a5)
    1438:	0047a683          	lw	a3,4(a5)
    143c:	fed758e3          	bge	a4,a3,142c <main+0x338>
    GPIO0->OUT = 0x00;
    1440:	82000737          	lui	a4,0x82000
    1444:	00072023          	sw	zero,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    1448:	0007a223          	sw	zero,4(a5)
    144c:	0047a683          	lw	a3,4(a5)
    1450:	00002737          	lui	a4,0x2
    1454:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    1458:	00d74c63          	blt	a4,a3,1470 <main+0x37c>
    145c:	0047a683          	lw	a3,4(a5)
    1460:	00168693          	addi	a3,a3,1
    1464:	00d7a223          	sw	a3,4(a5)
    1468:	0047a683          	lw	a3,4(a5)
    146c:	fed758e3          	bge	a4,a3,145c <main+0x368>
    GPIO0->OUT = 0x3F;
    1470:	82000737          	lui	a4,0x82000
    1474:	03f00693          	li	a3,63
    1478:	00d72023          	sw	a3,0(a4) # 82000000 <__global_pointer$+0x41fff800>
    for ( i = 0 ; i < 10000; i++);
    147c:	0007a223          	sw	zero,4(a5)
    1480:	0047a683          	lw	a3,4(a5)
    1484:	00002737          	lui	a4,0x2
    1488:	70f70713          	addi	a4,a4,1807 # 270f <irqCallback+0x263>
    148c:	00d74c63          	blt	a4,a3,14a4 <main+0x3b0>
    1490:	0047a683          	lw	a3,4(a5)
    1494:	00168693          	addi	a3,a3,1
    1498:	00d7a223          	sw	a3,4(a5)
    149c:	0047a683          	lw	a3,4(a5)
    14a0:	fed758e3          	bge	a4,a3,1490 <main+0x39c>
    14a4:	000029b7          	lui	s3,0x2
    14a8:	61498793          	addi	a5,s3,1556 # 2614 <irqCallback+0x168>
    14ac:	00002937          	lui	s2,0x2
    14b0:	04f12623          	sw	a5,76(sp)
    14b4:	64090793          	addi	a5,s2,1600 # 2640 <irqCallback+0x194>
    14b8:	00f12423          	sw	a5,8(sp)
    14bc:	000027b7          	lui	a5,0x2
    14c0:	65878793          	addi	a5,a5,1624 # 2658 <irqCallback+0x1ac>
    14c4:	00f12623          	sw	a5,12(sp)
    14c8:	000027b7          	lui	a5,0x2
    14cc:	67078793          	addi	a5,a5,1648 # 2670 <irqCallback+0x1c4>
    14d0:	00f12823          	sw	a5,16(sp)
    14d4:	000027b7          	lui	a5,0x2
    14d8:	68878793          	addi	a5,a5,1672 # 2688 <irqCallback+0x1dc>
    14dc:	00f12a23          	sw	a5,20(sp)
    14e0:	000027b7          	lui	a5,0x2
    14e4:	6a078793          	addi	a5,a5,1696 # 26a0 <irqCallback+0x1f4>
    14e8:	00f12c23          	sw	a5,24(sp)
    14ec:	000027b7          	lui	a5,0x2
    14f0:	6b878793          	addi	a5,a5,1720 # 26b8 <irqCallback+0x20c>
    14f4:	00f12e23          	sw	a5,28(sp)
    14f8:	000027b7          	lui	a5,0x2
    14fc:	6d078793          	addi	a5,a5,1744 # 26d0 <irqCallback+0x224>
    1500:	02f12023          	sw	a5,32(sp)
    1504:	000027b7          	lui	a5,0x2
    1508:	6ec78793          	addi	a5,a5,1772 # 26ec <irqCallback+0x240>
    150c:	02f12223          	sw	a5,36(sp)
    1510:	000027b7          	lui	a5,0x2
    1514:	70878793          	addi	a5,a5,1800 # 2708 <irqCallback+0x25c>
    1518:	02f12423          	sw	a5,40(sp)
    151c:	000027b7          	lui	a5,0x2
    1520:	72078793          	addi	a5,a5,1824 # 2720 <irqCallback+0x274>
    1524:	02f12623          	sw	a5,44(sp)
    1528:	000027b7          	lui	a5,0x2
    152c:	73c78793          	addi	a5,a5,1852 # 273c <irqCallback+0x290>
    1530:	02f12823          	sw	a5,48(sp)
    1534:	000027b7          	lui	a5,0x2
    1538:	76078793          	addi	a5,a5,1888 # 2760 <irqCallback+0x2b4>
    153c:	02f12a23          	sw	a5,52(sp)
    1540:	000027b7          	lui	a5,0x2
    1544:	7a478793          	addi	a5,a5,1956 # 27a4 <irqCallback+0x2f8>
    1548:	02f12c23          	sw	a5,56(sp)
    154c:	000027b7          	lui	a5,0x2
    1550:	7b878793          	addi	a5,a5,1976 # 27b8 <irqCallback+0x30c>
    1554:	00002437          	lui	s0,0x2
    1558:	02f12e23          	sw	a5,60(sp)
    155c:	7b040793          	addi	a5,s0,1968 # 27b0 <irqCallback+0x304>
    1560:	00f12223          	sw	a5,4(sp)
    1564:	000027b7          	lui	a5,0x2
    1568:	4c478793          	addi	a5,a5,1220 # 24c4 <irqCallback+0x18>
    156c:	04f12023          	sw	a5,64(sp)
    1570:	000027b7          	lui	a5,0x2
    1574:	4d078793          	addi	a5,a5,1232 # 24d0 <irqCallback+0x24>
    1578:	04f12223          	sw	a5,68(sp)
    157c:	000027b7          	lui	a5,0x2
    1580:	00002f37          	lui	t5,0x2
    1584:	00002bb7          	lui	s7,0x2
    1588:	00002c37          	lui	s8,0x2
    158c:	00002d37          	lui	s10,0x2
    1590:	000022b7          	lui	t0,0x2
    1594:	000024b7          	lui	s1,0x2
    1598:	4dc78793          	addi	a5,a5,1244 # 24dc <irqCallback+0x30>
    159c:	00002e37          	lui	t3,0x2
    15a0:	628f0f13          	addi	t5,t5,1576 # 2628 <irqCallback+0x17c>
    15a4:	4b0b8b93          	addi	s7,s7,1200 # 24b0 <irqCallback+0x4>
    15a8:	78cc0c13          	addi	s8,s8,1932 # 278c <irqCallback+0x2e0>
    15ac:	7c0d0d13          	addi	s10,s10,1984 # 27c0 <irqCallback+0x314>
    15b0:	79828293          	addi	t0,t0,1944 # 2798 <irqCallback+0x2ec>
    15b4:	7ac48493          	addi	s1,s1,1964 # 27ac <irqCallback+0x300>
    15b8:	04f12423          	sw	a5,72(sp)
    15bc:	780e0993          	addi	s3,t3,1920 # 2780 <irqCallback+0x2d4>
        UART0->DATA = '\r';
    15c0:	83000a37          	lui	s4,0x83000
    15c4:	00d00b13          	li	s6,13
    UART0->DATA = c;
    15c8:	00a00a93          	li	s5,10
    15cc:	00a00913          	li	s2,10
        UART0->DATA = '\r';
    15d0:	04c12703          	lw	a4,76(sp)
    15d4:	016a2023          	sw	s6,0(s4) # 83000000 <__global_pointer$+0x42fff800>
    UART0->DATA = c;
    15d8:	012a2023          	sw	s2,0(s4)
    while (*p)
    15dc:	05300793          	li	a5,83
        putchar(*(p++));
    15e0:	00170713          	addi	a4,a4,1
    if (c == '\n')
    15e4:	29578ee3          	beq	a5,s5,2080 <main+0xf8c>
    UART0->DATA = c;
    15e8:	00fa2023          	sw	a5,0(s4)
    while (*p)
    15ec:	00074783          	lbu	a5,0(a4)
    15f0:	fe0798e3          	bnez	a5,15e0 <main+0x4ec>
        UART0->DATA = '\r';
    15f4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    15f8:	015a2023          	sw	s5,0(s4)
    while (*p)
    15fc:	02000793          	li	a5,32
    1600:	000f0713          	mv	a4,t5
        putchar(*(p++));
    1604:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1608:	275782e3          	beq	a5,s5,206c <main+0xf78>
    UART0->DATA = c;
    160c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1610:	00074783          	lbu	a5,0(a4)
    1614:	fe0798e3          	bnez	a5,1604 <main+0x510>
    1618:	00812703          	lw	a4,8(sp)
    161c:	02000793          	li	a5,32
        putchar(*(p++));
    1620:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1624:	23578ae3          	beq	a5,s5,2058 <main+0xf64>
    UART0->DATA = c;
    1628:	00fa2023          	sw	a5,0(s4)
    while (*p)
    162c:	00074783          	lbu	a5,0(a4)
    1630:	fe0798e3          	bnez	a5,1620 <main+0x52c>
    1634:	00c12703          	lw	a4,12(sp)
    1638:	02000793          	li	a5,32
        putchar(*(p++));
    163c:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1640:	215782e3          	beq	a5,s5,2044 <main+0xf50>
    UART0->DATA = c;
    1644:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1648:	00074783          	lbu	a5,0(a4)
    164c:	fe0798e3          	bnez	a5,163c <main+0x548>
    1650:	01012703          	lw	a4,16(sp)
    1654:	02000793          	li	a5,32
        putchar(*(p++));
    1658:	00170713          	addi	a4,a4,1
    if (c == '\n')
    165c:	1d578ae3          	beq	a5,s5,2030 <main+0xf3c>
    UART0->DATA = c;
    1660:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1664:	00074783          	lbu	a5,0(a4)
    1668:	fe0798e3          	bnez	a5,1658 <main+0x564>
    166c:	01412703          	lw	a4,20(sp)
    1670:	02000793          	li	a5,32
        putchar(*(p++));
    1674:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1678:	1b5782e3          	beq	a5,s5,201c <main+0xf28>
    UART0->DATA = c;
    167c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1680:	00074783          	lbu	a5,0(a4)
    1684:	fe0798e3          	bnez	a5,1674 <main+0x580>
    1688:	01812703          	lw	a4,24(sp)
    168c:	02000793          	li	a5,32
        putchar(*(p++));
    1690:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1694:	17578ae3          	beq	a5,s5,2008 <main+0xf14>
    UART0->DATA = c;
    1698:	00fa2023          	sw	a5,0(s4)
    while (*p)
    169c:	00074783          	lbu	a5,0(a4)
    16a0:	fe0798e3          	bnez	a5,1690 <main+0x59c>
    16a4:	01c12703          	lw	a4,28(sp)
    16a8:	02000793          	li	a5,32
        putchar(*(p++));
    16ac:	00170713          	addi	a4,a4,1
    if (c == '\n')
    16b0:	155782e3          	beq	a5,s5,1ff4 <main+0xf00>
    UART0->DATA = c;
    16b4:	00fa2023          	sw	a5,0(s4)
    while (*p)
    16b8:	00074783          	lbu	a5,0(a4)
    16bc:	fe0798e3          	bnez	a5,16ac <main+0x5b8>
    16c0:	02012703          	lw	a4,32(sp)
    16c4:	02000793          	li	a5,32
        putchar(*(p++));
    16c8:	00170713          	addi	a4,a4,1
    if (c == '\n')
    16cc:	215782e3          	beq	a5,s5,20d0 <main+0xfdc>
    UART0->DATA = c;
    16d0:	00fa2023          	sw	a5,0(s4)
    while (*p)
    16d4:	00074783          	lbu	a5,0(a4)
    16d8:	fe0798e3          	bnez	a5,16c8 <main+0x5d4>
    16dc:	02412703          	lw	a4,36(sp)
    16e0:	02000793          	li	a5,32
        putchar(*(p++));
    16e4:	00170713          	addi	a4,a4,1
    if (c == '\n')
    16e8:	1d578ae3          	beq	a5,s5,20bc <main+0xfc8>
    UART0->DATA = c;
    16ec:	00fa2023          	sw	a5,0(s4)
    while (*p)
    16f0:	00074783          	lbu	a5,0(a4)
    16f4:	fe0798e3          	bnez	a5,16e4 <main+0x5f0>
    16f8:	02812703          	lw	a4,40(sp)
    16fc:	02000793          	li	a5,32
        putchar(*(p++));
    1700:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1704:	1b5782e3          	beq	a5,s5,20a8 <main+0xfb4>
    UART0->DATA = c;
    1708:	00fa2023          	sw	a5,0(s4)
    while (*p)
    170c:	00074783          	lbu	a5,0(a4)
    1710:	fe0798e3          	bnez	a5,1700 <main+0x60c>
    1714:	02c12703          	lw	a4,44(sp)
    1718:	02000793          	li	a5,32
        putchar(*(p++));
    171c:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1720:	17578ae3          	beq	a5,s5,2094 <main+0xfa0>
    UART0->DATA = c;
    1724:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1728:	00074783          	lbu	a5,0(a4)
    172c:	fe0798e3          	bnez	a5,171c <main+0x628>
    1730:	03012703          	lw	a4,48(sp)
    1734:	02000793          	li	a5,32
        putchar(*(p++));
    1738:	00170713          	addi	a4,a4,1
    if (c == '\n')
    173c:	1b578ee3          	beq	a5,s5,20f8 <main+0x1004>
    UART0->DATA = c;
    1740:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1744:	00074783          	lbu	a5,0(a4)
    1748:	fe0798e3          	bnez	a5,1738 <main+0x644>
    174c:	03412703          	lw	a4,52(sp)
    1750:	02000793          	li	a5,32
        putchar(*(p++));
    1754:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1758:	195786e3          	beq	a5,s5,20e4 <main+0xff0>
    UART0->DATA = c;
    175c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1760:	00074783          	lbu	a5,0(a4)
    1764:	fe0798e3          	bnez	a5,1754 <main+0x660>
    UART0->DATA = c;
    1768:	00a00c93          	li	s9,10
        
        for (int rep = 10; rep > 0; rep--)
        {
            print("\n");
            print("IO State: ");
            print_hex(GPIO0->IN, 8);
    176c:	82000db7          	lui	s11,0x82000
    while (c == -1) {
    1770:	fff00413          	li	s0,-1
        UART0->DATA = '\r';
    1774:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1778:	012a2023          	sw	s2,0(s4)
    while (*p)
    177c:	04900793          	li	a5,73
    1780:	00098713          	mv	a4,s3
        putchar(*(p++));
    1784:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1788:	77578663          	beq	a5,s5,1ef4 <main+0xe00>
    UART0->DATA = c;
    178c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1790:	00074783          	lbu	a5,0(a4)
    1794:	fe0798e3          	bnez	a5,1784 <main+0x690>
            print_hex(GPIO0->IN, 8);
    1798:	004da783          	lw	a5,4(s11) # 82000004 <__global_pointer$+0x41fff804>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    179c:	01c7d713          	srli	a4,a5,0x1c
    17a0:	00eb8733          	add	a4,s7,a4
    17a4:	00074603          	lbu	a2,0(a4)
    if (c == '\n')
    17a8:	77560863          	beq	a2,s5,1f18 <main+0xe24>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    17ac:	0187d713          	srli	a4,a5,0x18
    17b0:	00f77713          	andi	a4,a4,15
    17b4:	00eb8733          	add	a4,s7,a4
    17b8:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    17bc:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    17c0:	77568a63          	beq	a3,s5,1f34 <main+0xe40>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    17c4:	0147d713          	srli	a4,a5,0x14
    17c8:	00f77713          	andi	a4,a4,15
    17cc:	00eb8733          	add	a4,s7,a4
    17d0:	00074603          	lbu	a2,0(a4)
    UART0->DATA = c;
    17d4:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    17d8:	77560c63          	beq	a2,s5,1f50 <main+0xe5c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    17dc:	0107d713          	srli	a4,a5,0x10
    17e0:	00f77713          	andi	a4,a4,15
    17e4:	00eb8733          	add	a4,s7,a4
    17e8:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    17ec:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    17f0:	77568e63          	beq	a3,s5,1f6c <main+0xe78>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    17f4:	00c7d713          	srli	a4,a5,0xc
    17f8:	00f77713          	andi	a4,a4,15
    17fc:	00eb8733          	add	a4,s7,a4
    1800:	00074603          	lbu	a2,0(a4)
    UART0->DATA = c;
    1804:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1808:	79560063          	beq	a2,s5,1f88 <main+0xe94>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    180c:	0087d713          	srli	a4,a5,0x8
    1810:	00f77713          	andi	a4,a4,15
    1814:	00eb8733          	add	a4,s7,a4
    1818:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    181c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1820:	79568263          	beq	a3,s5,1fa4 <main+0xeb0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1824:	0047d713          	srli	a4,a5,0x4
    1828:	00f77713          	andi	a4,a4,15
    182c:	00eb8733          	add	a4,s7,a4
    1830:	00074703          	lbu	a4,0(a4)
    UART0->DATA = c;
    1834:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1838:	79570463          	beq	a4,s5,1fc0 <main+0xecc>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    183c:	00f7f793          	andi	a5,a5,15
    1840:	00fb87b3          	add	a5,s7,a5
    1844:	0007c783          	lbu	a5,0(a5)
    UART0->DATA = c;
    1848:	00ea2023          	sw	a4,0(s4)
    if (c == '\n')
    184c:	79578663          	beq	a5,s5,1fd8 <main+0xee4>
    UART0->DATA = c;
    1850:	00fa2023          	sw	a5,0(s4)
        UART0->DATA = '\r';
    1854:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1858:	015a2023          	sw	s5,0(s4)
        UART0->DATA = '\r';
    185c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1860:	015a2023          	sw	s5,0(s4)
    while (*p)
    1864:	04300793          	li	a5,67
    1868:	000c0713          	mv	a4,s8
        putchar(*(p++));
    186c:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1870:	77578863          	beq	a5,s5,1fe0 <main+0xeec>
    UART0->DATA = c;
    1874:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1878:	00074783          	lbu	a5,0(a4)
    187c:	fe0798e3          	bnez	a5,186c <main+0x778>
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
    1880:	c00027f3          	rdcycle	a5
        __asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
    1884:	c00027f3          	rdcycle	a5
        c = UART0->DATA;
    1888:	000a2783          	lw	a5,0(s4)
    while (c == -1) {
    188c:	fe878ce3          	beq	a5,s0,1884 <main+0x790>

            print("\n");

            print("Command> ");
            char cmd = getchar();
            if (cmd > 32 && cmd < 127)
    1890:	fdf78713          	addi	a4,a5,-33
    1894:	0ff77713          	zext.b	a4,a4
    1898:	05d00693          	li	a3,93
    189c:	0ff7f793          	zext.b	a5,a5
    18a0:	00e6e663          	bltu	a3,a4,18ac <main+0x7b8>
    if (c == '\n')
    18a4:	0b578463          	beq	a5,s5,194c <main+0x858>
    UART0->DATA = c;
    18a8:	00fa2023          	sw	a5,0(s4)
        UART0->DATA = '\r';
    18ac:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    18b0:	015a2023          	sw	s5,0(s4)
                putchar(cmd);
            print("\n");

            switch (cmd)
    18b4:	fcf78793          	addi	a5,a5,-49
    18b8:	04200713          	li	a4,66
    18bc:	0af76063          	bltu	a4,a5,195c <main+0x868>
    18c0:	00279793          	slli	a5,a5,0x2
    18c4:	00fd07b3          	add	a5,s10,a5
    18c8:	0007a783          	lw	a5,0(a5)
    18cc:	00078067          	jr	a5
        UART0->DATA = '\r';
    18d0:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
    18d4:	00f6a023          	sw	a5,0(a3)
    while (*p)
    18d8:	00074783          	lbu	a5,0(a4)
    18dc:	8a079ce3          	bnez	a5,1194 <main+0xa0>
    18e0:	8c9ff06f          	j	11a8 <main+0xb4>
        UART0->DATA = '\r';
    18e4:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
    18e8:	00f6a023          	sw	a5,0(a3)
    while (*p)
    18ec:	00074783          	lbu	a5,0(a4)
    18f0:	8c0798e3          	bnez	a5,11c0 <main+0xcc>
    18f4:	8e1ff06f          	j	11d4 <main+0xe0>
        UART0->DATA = '\r';
    18f8:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
    18fc:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1900:	00074783          	lbu	a5,0(a4)
    1904:	8e0794e3          	bnez	a5,11ec <main+0xf8>
    1908:	8f9ff06f          	j	1200 <main+0x10c>
        UART0->DATA = '\r';
    190c:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
    1910:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1914:	00074783          	lbu	a5,0(a4)
    1918:	900790e3          	bnez	a5,1218 <main+0x124>
    191c:	911ff06f          	j	122c <main+0x138>
        UART0->DATA = '\r';
    1920:	00d00593          	li	a1,13
    1924:	00b6a023          	sw	a1,0(a3)
    UART0->DATA = c;
    1928:	00f6a023          	sw	a5,0(a3)
    while (*p)
    192c:	00074783          	lbu	a5,0(a4)
    1930:	940796e3          	bnez	a5,127c <main+0x188>
    1934:	961ff06f          	j	1294 <main+0x1a0>
        UART0->DATA = '\r';
    1938:	00c6a023          	sw	a2,0(a3)
    UART0->DATA = c;
    193c:	00f6a023          	sw	a5,0(a3)
    while (*p)
    1940:	00074783          	lbu	a5,0(a4)
    1944:	900790e3          	bnez	a5,1244 <main+0x150>
    1948:	911ff06f          	j	1258 <main+0x164>
        UART0->DATA = '\r';
    194c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1950:	015a2023          	sw	s5,0(s4)
        UART0->DATA = '\r';
    1954:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1958:	015a2023          	sw	s5,0(s4)
        for (int rep = 10; rep > 0; rep--)
    195c:	fffc8c93          	addi	s9,s9,-1
    1960:	e00c9ae3          	bnez	s9,1774 <main+0x680>
    1964:	c6dff06f          	j	15d0 <main+0x4dc>
        UART0->DATA = '\r';
    1968:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    196c:	015a2023          	sw	s5,0(s4)
    while (*p)
    1970:	05300793          	li	a5,83
    1974:	00028713          	mv	a4,t0
        putchar(*(p++));
    1978:	00170713          	addi	a4,a4,1
    if (c == '\n')
    197c:	315784e3          	beq	a5,s5,2484 <main+0x1390>
    UART0->DATA = c;
    1980:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1984:	00074783          	lbu	a5,0(a4)
    1988:	fe0798e3          	bnez	a5,1978 <main+0x884>
    198c:	03812703          	lw	a4,56(sp)
    1990:	02000793          	li	a5,32
        putchar(*(p++));
    1994:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1998:	29578ae3          	beq	a5,s5,242c <main+0x1338>
    UART0->DATA = c;
    199c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    19a0:	00074783          	lbu	a5,0(a4)
    19a4:	fe0798e3          	bnez	a5,1994 <main+0x8a0>
    return QSPI0->REG & QSPI_REG_DSPI;
    19a8:	810007b7          	lui	a5,0x81000
    19ac:	0007a783          	lw	a5,0(a5) # 81000000 <__global_pointer$+0x40fff800>
            case 'F':
            case 'f':
                print("\n");
                print("SPI State:\n");
                print("  DSPI ");
                if ( cmd_get_dspi() )
    19b0:	00979713          	slli	a4,a5,0x9
    while (*p)
    19b4:	04f00793          	li	a5,79
                if ( cmd_get_dspi() )
    19b8:	28075ce3          	bgez	a4,2450 <main+0x135c>
    19bc:	00048713          	mv	a4,s1
        putchar(*(p++));
    19c0:	00170713          	addi	a4,a4,1
    if (c == '\n')
    19c4:	2d578ae3          	beq	a5,s5,2498 <main+0x13a4>
    UART0->DATA = c;
    19c8:	00fa2023          	sw	a5,0(s4)
    while (*p)
    19cc:	00074783          	lbu	a5,0(a4)
    19d0:	fe0798e3          	bnez	a5,19c0 <main+0x8cc>
    19d4:	03c12703          	lw	a4,60(sp)
    19d8:	02000793          	li	a5,32
        putchar(*(p++));
    19dc:	00170713          	addi	a4,a4,1
    if (c == '\n')
    19e0:	73578663          	beq	a5,s5,210c <main+0x1018>
    UART0->DATA = c;
    19e4:	00fa2023          	sw	a5,0(s4)
    while (*p)
    19e8:	00074783          	lbu	a5,0(a4)
    19ec:	fe0798e3          	bnez	a5,19dc <main+0x8e8>
    return QSPI0->REG & QSPI_REG_CRM;
    19f0:	810007b7          	lui	a5,0x81000
    19f4:	0007a783          	lw	a5,0(a5) # 81000000 <__global_pointer$+0x40fff800>
                    print("ON\n");
                else
                    print("OFF\n");
                print("  CRM  ");
                if ( cmd_get_crm() )
    19f8:	00b79713          	slli	a4,a5,0xb
    while (*p)
    19fc:	04f00793          	li	a5,79
                if ( cmd_get_crm() )
    1a00:	72075863          	bgez	a4,2130 <main+0x103c>
    1a04:	00048713          	mv	a4,s1
        putchar(*(p++));
    1a08:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1a0c:	01578c63          	beq	a5,s5,1a24 <main+0x930>
    UART0->DATA = c;
    1a10:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1a14:	00074783          	lbu	a5,0(a4)
    1a18:	f40782e3          	beqz	a5,195c <main+0x868>
        putchar(*(p++));
    1a1c:	00170713          	addi	a4,a4,1
    if (c == '\n')
    1a20:	ff5798e3          	bne	a5,s5,1a10 <main+0x91c>
        UART0->DATA = '\r';
    1a24:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1a28:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1a2c:	00074783          	lbu	a5,0(a4)
    1a30:	fc079ce3          	bnez	a5,1a08 <main+0x914>
        for (int rep = 10; rep > 0; rep--)
    1a34:	fffc8c93          	addi	s9,s9,-1
    1a38:	d20c9ee3          	bnez	s9,1774 <main+0x680>
    1a3c:	b95ff06f          	j	15d0 <main+0x4dc>

                break;

            case 'I':
            case 'i':
                cmd_read_flash_id();
    1a40:	eecfe0ef          	jal	12c <cmd_read_flash_id>
                break;
    1a44:	000027b7          	lui	a5,0x2
    1a48:	79878293          	addi	t0,a5,1944 # 2798 <irqCallback+0x2ec>
        for (int rep = 10; rep > 0; rep--)
    1a4c:	fffc8c93          	addi	s9,s9,-1
                break;
    1a50:	000027b7          	lui	a5,0x2
    1a54:	62878f13          	addi	t5,a5,1576 # 2628 <irqCallback+0x17c>
        for (int rep = 10; rep > 0; rep--)
    1a58:	d00c9ee3          	bnez	s9,1774 <main+0x680>
    1a5c:	b75ff06f          	j	15d0 <main+0x4dc>
        QSPI0->REG &= ~QSPI_REG_DSPI;
    1a60:	810007b7          	lui	a5,0x81000
    1a64:	0007a703          	lw	a4,0(a5) # 81000000 <__global_pointer$+0x40fff800>
    1a68:	ffc006b7          	lui	a3,0xffc00
    1a6c:	fff68693          	addi	a3,a3,-1 # ffbfffff <__global_pointer$+0xbfbff7ff>
    1a70:	00d77733          	and	a4,a4,a3
    1a74:	00e7a023          	sw	a4,0(a5)
        QSPI0->REG &= ~QSPI_REG_CRM;
    1a78:	0007a703          	lw	a4,0(a5)
    1a7c:	fff006b7          	lui	a3,0xfff00
    1a80:	fff68693          	addi	a3,a3,-1 # ffefffff <__global_pointer$+0xbfeff7ff>
    1a84:	00d77733          	and	a4,a4,a3
    1a88:	00e7a023          	sw	a4,0(a5)
        for (int rep = 10; rep > 0; rep--)
    1a8c:	fffc8c93          	addi	s9,s9,-1
    1a90:	ce0c92e3          	bnez	s9,1774 <main+0x680>
    1a94:	b3dff06f          	j	15d0 <main+0x4dc>
        QSPI0->REG &= ~QSPI_REG_CRM;
    1a98:	810007b7          	lui	a5,0x81000
    1a9c:	0007a703          	lw	a4,0(a5) # 81000000 <__global_pointer$+0x40fff800>
    1aa0:	fff006b7          	lui	a3,0xfff00
    1aa4:	fff68693          	addi	a3,a3,-1 # ffefffff <__global_pointer$+0xbfeff7ff>
    1aa8:	00d77733          	and	a4,a4,a3
        QSPI0->REG |= QSPI_REG_CRM;
    1aac:	00e7a023          	sw	a4,0(a5)
        QSPI0->REG |= QSPI_REG_DSPI;
    1ab0:	0007a703          	lw	a4,0(a5)
    1ab4:	004006b7          	lui	a3,0x400
        for (int rep = 10; rep > 0; rep--)
    1ab8:	fffc8c93          	addi	s9,s9,-1
        QSPI0->REG |= QSPI_REG_DSPI;
    1abc:	00d76733          	or	a4,a4,a3
    1ac0:	00e7a023          	sw	a4,0(a5)
        for (int rep = 10; rep > 0; rep--)
    1ac4:	ca0c98e3          	bnez	s9,1774 <main+0x680>
    1ac8:	b09ff06f          	j	15d0 <main+0x4dc>
        QSPI0->REG |= QSPI_REG_CRM;
    1acc:	810007b7          	lui	a5,0x81000
    1ad0:	0007a703          	lw	a4,0(a5) # 81000000 <__global_pointer$+0x40fff800>
    1ad4:	001006b7          	lui	a3,0x100
    1ad8:	00d76733          	or	a4,a4,a3
    1adc:	fd1ff06f          	j	1aac <main+0x9b8>
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
    1ae0:	c0002673          	rdcycle	a2
    __asm__ volatile ("rdinstret %0" : "=r"(instns_begin));
    1ae4:	c0202773          	rdinstret	a4
    uint32_t x32 = 314159265;
    1ae8:	12b9b7b7          	lui	a5,0x12b9b
    __asm__ volatile ("rdinstret %0" : "=r"(instns_begin));
    1aec:	01400893          	li	a7,20
    uint32_t x32 = 314159265;
    1af0:	0a178793          	addi	a5,a5,161 # 12b9b0a1 <_etext+0x12b987d5>
    1af4:	15010513          	addi	a0,sp,336
        for (int k = 0, p = 0; k < 256; k++)
    1af8:	10000813          	li	a6,256
        for (int k = 0; k < 256; k++)
    1afc:	05010313          	addi	t1,sp,80
    1b00:	00030593          	mv	a1,t1
    1b04:	00078693          	mv	a3,a5
            x32 ^= x32 << 13;
    1b08:	00d69793          	slli	a5,a3,0xd
    1b0c:	00d7c7b3          	xor	a5,a5,a3
            x32 ^= x32 >> 17;
    1b10:	0117d693          	srli	a3,a5,0x11
    1b14:	00d7c7b3          	xor	a5,a5,a3
            x32 ^= x32 << 5;
    1b18:	00579693          	slli	a3,a5,0x5
    1b1c:	00d7c6b3          	xor	a3,a5,a3
            data[k] = x32;
    1b20:	00d58023          	sb	a3,0(a1)
        for (int k = 0; k < 256; k++)
    1b24:	00158593          	addi	a1,a1,1
    1b28:	fea590e3          	bne	a1,a0,1b08 <main+0xa14>
    1b2c:	00068793          	mv	a5,a3
    1b30:	05010593          	addi	a1,sp,80
        for (int k = 0, p = 0; k < 256; k++)
    1b34:	00000e93          	li	t4,0
    1b38:	00000693          	li	a3,0
            if (data[k])
    1b3c:	0005ce03          	lbu	t3,0(a1)
    1b40:	000e0c63          	beqz	t3,1b58 <main+0xa64>
                data[p++] = k;
    1b44:	100e8e13          	addi	t3,t4,256
    1b48:	05010f93          	addi	t6,sp,80
    1b4c:	01fe0e33          	add	t3,t3,t6
    1b50:	f0de0023          	sb	a3,-256(t3)
    1b54:	001e8e93          	addi	t4,t4,1
        for (int k = 0, p = 0; k < 256; k++)
    1b58:	00168693          	addi	a3,a3,1 # 100001 <_etext+0xfd735>
    1b5c:	00158593          	addi	a1,a1,1
    1b60:	fd069ee3          	bne	a3,a6,1b3c <main+0xa48>
            x32 = x32 ^ words[k];
    1b64:	00032683          	lw	a3,0(t1)
        for (int k = 0, p = 0; k < 64; k++)
    1b68:	00430313          	addi	t1,t1,4
            x32 = x32 ^ words[k];
    1b6c:	00d7c7b3          	xor	a5,a5,a3
        for (int k = 0, p = 0; k < 64; k++)
    1b70:	fea31ae3          	bne	t1,a0,1b64 <main+0xa70>
    for (int i = 0; i < 20; i++)
    1b74:	fff88893          	addi	a7,a7,-1
    1b78:	f80892e3          	bnez	a7,1afc <main+0xa08>
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_end));
    1b7c:	c00026f3          	rdcycle	a3
    __asm__ volatile ("rdinstret %0" : "=r"(instns_end));
    1b80:	c0202873          	rdinstret	a6
    1b84:	04012503          	lw	a0,64(sp)
    while (*p)
    1b88:	04300593          	li	a1,67
        putchar(*(p++));
    1b8c:	00150513          	addi	a0,a0,1
    if (c == '\n')
    1b90:	7b558863          	beq	a1,s5,2340 <main+0x124c>
    UART0->DATA = c;
    1b94:	00ba2023          	sw	a1,0(s4)
    while (*p)
    1b98:	00054583          	lbu	a1,0(a0)
    1b9c:	fe0598e3          	bnez	a1,1b8c <main+0xa98>
        print_hex(cycles_end - cycles_begin, 8);
    1ba0:	40c686b3          	sub	a3,a3,a2
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1ba4:	01c6d613          	srli	a2,a3,0x1c
    1ba8:	00cb8633          	add	a2,s7,a2
    1bac:	00064503          	lbu	a0,0(a2) # 400000 <_etext+0x3fd734>
    if (c == '\n')
    1bb0:	7b550a63          	beq	a0,s5,2364 <main+0x1270>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1bb4:	0186d613          	srli	a2,a3,0x18
    1bb8:	00f67613          	andi	a2,a2,15
    1bbc:	00cb8633          	add	a2,s7,a2
    1bc0:	00064583          	lbu	a1,0(a2)
    UART0->DATA = c;
    1bc4:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    1bc8:	7b558c63          	beq	a1,s5,2380 <main+0x128c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1bcc:	0146d613          	srli	a2,a3,0x14
    1bd0:	00f67613          	andi	a2,a2,15
    1bd4:	00cb8633          	add	a2,s7,a2
    1bd8:	00064503          	lbu	a0,0(a2)
    UART0->DATA = c;
    1bdc:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1be0:	7b550e63          	beq	a0,s5,239c <main+0x12a8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1be4:	0106d613          	srli	a2,a3,0x10
    1be8:	00f67613          	andi	a2,a2,15
    1bec:	00cb8633          	add	a2,s7,a2
    1bf0:	00064583          	lbu	a1,0(a2)
    UART0->DATA = c;
    1bf4:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    1bf8:	7d558063          	beq	a1,s5,23b8 <main+0x12c4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1bfc:	00c6d613          	srli	a2,a3,0xc
    1c00:	00f67613          	andi	a2,a2,15
    1c04:	00cb8633          	add	a2,s7,a2
    1c08:	00064503          	lbu	a0,0(a2)
    UART0->DATA = c;
    1c0c:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1c10:	7d550263          	beq	a0,s5,23d4 <main+0x12e0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1c14:	0086d613          	srli	a2,a3,0x8
    1c18:	00f67613          	andi	a2,a2,15
    1c1c:	00cb8633          	add	a2,s7,a2
    1c20:	00064583          	lbu	a1,0(a2)
    UART0->DATA = c;
    1c24:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    1c28:	7d558463          	beq	a1,s5,23f0 <main+0x12fc>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1c2c:	0046d613          	srli	a2,a3,0x4
    1c30:	00f67613          	andi	a2,a2,15
    1c34:	00cb8633          	add	a2,s7,a2
    1c38:	00064603          	lbu	a2,0(a2)
    UART0->DATA = c;
    1c3c:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1c40:	7d560663          	beq	a2,s5,240c <main+0x1318>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1c44:	00f6f693          	andi	a3,a3,15
    1c48:	00db86b3          	add	a3,s7,a3
    1c4c:	0006c683          	lbu	a3,0(a3)
    UART0->DATA = c;
    1c50:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1c54:	7d568863          	beq	a3,s5,2424 <main+0x1330>
    UART0->DATA = c;
    1c58:	00da2023          	sw	a3,0(s4)
    1c5c:	04412603          	lw	a2,68(sp)
        UART0->DATA = '\r';
    1c60:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1c64:	015a2023          	sw	s5,0(s4)
    while (*p)
    1c68:	04900693          	li	a3,73
        putchar(*(p++));
    1c6c:	00160613          	addi	a2,a2,1
    if (c == '\n')
    1c70:	4f568e63          	beq	a3,s5,216c <main+0x1078>
    UART0->DATA = c;
    1c74:	00da2023          	sw	a3,0(s4)
    while (*p)
    1c78:	00064683          	lbu	a3,0(a2)
    1c7c:	fe0698e3          	bnez	a3,1c6c <main+0xb78>
        print_hex(instns_end - instns_begin, 8);
    1c80:	40e80733          	sub	a4,a6,a4
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1c84:	01c75693          	srli	a3,a4,0x1c
    1c88:	00db86b3          	add	a3,s7,a3
    1c8c:	0006c583          	lbu	a1,0(a3)
    if (c == '\n')
    1c90:	51558063          	beq	a1,s5,2190 <main+0x109c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1c94:	01875693          	srli	a3,a4,0x18
    1c98:	00f6f693          	andi	a3,a3,15
    1c9c:	00db86b3          	add	a3,s7,a3
    1ca0:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
    1ca4:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1ca8:	51560263          	beq	a2,s5,21ac <main+0x10b8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1cac:	01475693          	srli	a3,a4,0x14
    1cb0:	00f6f693          	andi	a3,a3,15
    1cb4:	00db86b3          	add	a3,s7,a3
    1cb8:	0006c583          	lbu	a1,0(a3)
    UART0->DATA = c;
    1cbc:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1cc0:	51558463          	beq	a1,s5,21c8 <main+0x10d4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1cc4:	01075693          	srli	a3,a4,0x10
    1cc8:	00f6f693          	andi	a3,a3,15
    1ccc:	00db86b3          	add	a3,s7,a3
    1cd0:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
    1cd4:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1cd8:	51560663          	beq	a2,s5,21e4 <main+0x10f0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1cdc:	00c75693          	srli	a3,a4,0xc
    1ce0:	00f6f693          	andi	a3,a3,15
    1ce4:	00db86b3          	add	a3,s7,a3
    1ce8:	0006c583          	lbu	a1,0(a3)
    UART0->DATA = c;
    1cec:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1cf0:	51558863          	beq	a1,s5,2200 <main+0x110c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1cf4:	00875693          	srli	a3,a4,0x8
    1cf8:	00f6f693          	andi	a3,a3,15
    1cfc:	00db86b3          	add	a3,s7,a3
    1d00:	0006c603          	lbu	a2,0(a3)
    UART0->DATA = c;
    1d04:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    1d08:	51560a63          	beq	a2,s5,221c <main+0x1128>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1d0c:	00475693          	srli	a3,a4,0x4
    1d10:	00f6f693          	andi	a3,a3,15
    1d14:	00db86b3          	add	a3,s7,a3
    1d18:	0006c683          	lbu	a3,0(a3)
    UART0->DATA = c;
    1d1c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1d20:	51568c63          	beq	a3,s5,2238 <main+0x1144>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1d24:	00f77713          	andi	a4,a4,15
    1d28:	00eb8733          	add	a4,s7,a4
    1d2c:	00074703          	lbu	a4,0(a4)
    UART0->DATA = c;
    1d30:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1d34:	51570e63          	beq	a4,s5,2250 <main+0x115c>
    UART0->DATA = c;
    1d38:	00ea2023          	sw	a4,0(s4)
    1d3c:	04812683          	lw	a3,72(sp)
        UART0->DATA = '\r';
    1d40:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1d44:	015a2023          	sw	s5,0(s4)
    while (*p)
    1d48:	04300713          	li	a4,67
        putchar(*(p++));
    1d4c:	00168693          	addi	a3,a3,1
    if (c == '\n')
    1d50:	51570463          	beq	a4,s5,2258 <main+0x1164>
    UART0->DATA = c;
    1d54:	00ea2023          	sw	a4,0(s4)
    while (*p)
    1d58:	0006c703          	lbu	a4,0(a3)
    1d5c:	fe0718e3          	bnez	a4,1d4c <main+0xc58>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1d60:	01c7d713          	srli	a4,a5,0x1c
    1d64:	00eb8733          	add	a4,s7,a4
    1d68:	00074603          	lbu	a2,0(a4)
    if (c == '\n')
    1d6c:	51560663          	beq	a2,s5,2278 <main+0x1184>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1d70:	0187d713          	srli	a4,a5,0x18
    1d74:	00f77713          	andi	a4,a4,15
    1d78:	00eb8733          	add	a4,s7,a4
    1d7c:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    1d80:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1d84:	51568863          	beq	a3,s5,2294 <main+0x11a0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1d88:	0147d713          	srli	a4,a5,0x14
    1d8c:	00f77713          	andi	a4,a4,15
    1d90:	00eb8733          	add	a4,s7,a4
    1d94:	00074603          	lbu	a2,0(a4)
    UART0->DATA = c;
    1d98:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1d9c:	51560a63          	beq	a2,s5,22b0 <main+0x11bc>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1da0:	0107d713          	srli	a4,a5,0x10
    1da4:	00f77713          	andi	a4,a4,15
    1da8:	00eb8733          	add	a4,s7,a4
    1dac:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    1db0:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1db4:	51568c63          	beq	a3,s5,22cc <main+0x11d8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1db8:	00c7d713          	srli	a4,a5,0xc
    1dbc:	00f77713          	andi	a4,a4,15
    1dc0:	00eb8733          	add	a4,s7,a4
    1dc4:	00074603          	lbu	a2,0(a4)
    UART0->DATA = c;
    1dc8:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1dcc:	51560e63          	beq	a2,s5,22e8 <main+0x11f4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1dd0:	0087d713          	srli	a4,a5,0x8
    1dd4:	00f77713          	andi	a4,a4,15
    1dd8:	00eb8733          	add	a4,s7,a4
    1ddc:	00074683          	lbu	a3,0(a4)
    UART0->DATA = c;
    1de0:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1de4:	53568063          	beq	a3,s5,2304 <main+0x1210>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1de8:	0047d713          	srli	a4,a5,0x4
    1dec:	00f77713          	andi	a4,a4,15
    1df0:	00eb8733          	add	a4,s7,a4
    1df4:	00074703          	lbu	a4,0(a4)
    UART0->DATA = c;
    1df8:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1dfc:	53570263          	beq	a4,s5,2320 <main+0x122c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1e00:	00f7f793          	andi	a5,a5,15
    1e04:	00fb87b3          	add	a5,s7,a5
    1e08:	0007c783          	lbu	a5,0(a5)
    UART0->DATA = c;
    1e0c:	00ea2023          	sw	a4,0(s4)
    if (c == '\n')
    1e10:	53578463          	beq	a5,s5,2338 <main+0x1244>
    UART0->DATA = c;
    1e14:	00fa2023          	sw	a5,0(s4)
        UART0->DATA = '\r';
    1e18:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1e1c:	015a2023          	sw	s5,0(s4)
        for (int rep = 10; rep > 0; rep--)
    1e20:	fffc8c93          	addi	s9,s9,-1
    1e24:	940c98e3          	bnez	s9,1774 <main+0x680>
    1e28:	fa8ff06f          	j	15d0 <main+0x4dc>
                cmd_benchmark(1, 0);
                break;

            case 'A':
            case 'a':
                cmd_benchmark_all();
    1e2c:	a99fe0ef          	jal	8c4 <cmd_benchmark_all>
                break;
    1e30:	000027b7          	lui	a5,0x2
    1e34:	79878293          	addi	t0,a5,1944 # 2798 <irqCallback+0x2ec>
        for (int rep = 10; rep > 0; rep--)
    1e38:	fffc8c93          	addi	s9,s9,-1
                break;
    1e3c:	000027b7          	lui	a5,0x2
    1e40:	62878f13          	addi	t5,a5,1576 # 2628 <irqCallback+0x17c>
        for (int rep = 10; rep > 0; rep--)
    1e44:	920c98e3          	bnez	s9,1774 <main+0x680>
    1e48:	f88ff06f          	j	15d0 <main+0x4dc>
            case '3':
                GPIO0->OUT ^= 0x00000004;
                break;

            case '4':
                GPIO0->OUT ^= 0x00000008;
    1e4c:	82000737          	lui	a4,0x82000
    1e50:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1e54:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000008;
    1e58:	0087c793          	xori	a5,a5,8
    1e5c:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1e60:	900c9ae3          	bnez	s9,1774 <main+0x680>
    1e64:	f6cff06f          	j	15d0 <main+0x4dc>
                GPIO0->OUT ^= 0x00000004;
    1e68:	82000737          	lui	a4,0x82000
    1e6c:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1e70:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000004;
    1e74:	0047c793          	xori	a5,a5,4
    1e78:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1e7c:	8e0c9ce3          	bnez	s9,1774 <main+0x680>
    1e80:	f50ff06f          	j	15d0 <main+0x4dc>
                GPIO0->OUT ^= 0x00000002;
    1e84:	82000737          	lui	a4,0x82000
    1e88:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1e8c:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000002;
    1e90:	0027c793          	xori	a5,a5,2
    1e94:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1e98:	8c0c9ee3          	bnez	s9,1774 <main+0x680>
    1e9c:	f34ff06f          	j	15d0 <main+0x4dc>
                GPIO0->OUT ^= 0x00000001;
    1ea0:	82000737          	lui	a4,0x82000
    1ea4:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1ea8:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000001;
    1eac:	0017c793          	xori	a5,a5,1
    1eb0:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1eb4:	8c0c90e3          	bnez	s9,1774 <main+0x680>
    1eb8:	f18ff06f          	j	15d0 <main+0x4dc>
            case '5':
                GPIO0->OUT ^= 0x00000010;
                break;

            case '6':
                GPIO0->OUT ^= 0x00000020;
    1ebc:	82000737          	lui	a4,0x82000
    1ec0:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1ec4:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000020;
    1ec8:	0207c793          	xori	a5,a5,32
    1ecc:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1ed0:	8a0c92e3          	bnez	s9,1774 <main+0x680>
    1ed4:	efcff06f          	j	15d0 <main+0x4dc>
                GPIO0->OUT ^= 0x00000010;
    1ed8:	82000737          	lui	a4,0x82000
    1edc:	00072783          	lw	a5,0(a4) # 82000000 <__global_pointer$+0x41fff800>
        for (int rep = 10; rep > 0; rep--)
    1ee0:	fffc8c93          	addi	s9,s9,-1
                GPIO0->OUT ^= 0x00000010;
    1ee4:	0107c793          	xori	a5,a5,16
    1ee8:	00f72023          	sw	a5,0(a4)
        for (int rep = 10; rep > 0; rep--)
    1eec:	880c94e3          	bnez	s9,1774 <main+0x680>
    1ef0:	ee0ff06f          	j	15d0 <main+0x4dc>
        UART0->DATA = '\r';
    1ef4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1ef8:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1efc:	00074783          	lbu	a5,0(a4)
    1f00:	880792e3          	bnez	a5,1784 <main+0x690>
            print_hex(GPIO0->IN, 8);
    1f04:	004da783          	lw	a5,4(s11)
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f08:	01c7d713          	srli	a4,a5,0x1c
    1f0c:	00eb8733          	add	a4,s7,a4
    1f10:	00074603          	lbu	a2,0(a4)
    if (c == '\n')
    1f14:	89561ce3          	bne	a2,s5,17ac <main+0x6b8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f18:	0187d713          	srli	a4,a5,0x18
    1f1c:	00f77713          	andi	a4,a4,15
    1f20:	00eb8733          	add	a4,s7,a4
    1f24:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    1f28:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1f2c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1f30:	89569ae3          	bne	a3,s5,17c4 <main+0x6d0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f34:	0147d713          	srli	a4,a5,0x14
    1f38:	00f77713          	andi	a4,a4,15
    1f3c:	00eb8733          	add	a4,s7,a4
    1f40:	00074603          	lbu	a2,0(a4)
        UART0->DATA = '\r';
    1f44:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1f48:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1f4c:	895618e3          	bne	a2,s5,17dc <main+0x6e8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f50:	0107d713          	srli	a4,a5,0x10
    1f54:	00f77713          	andi	a4,a4,15
    1f58:	00eb8733          	add	a4,s7,a4
    1f5c:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    1f60:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1f64:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1f68:	895696e3          	bne	a3,s5,17f4 <main+0x700>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f6c:	00c7d713          	srli	a4,a5,0xc
    1f70:	00f77713          	andi	a4,a4,15
    1f74:	00eb8733          	add	a4,s7,a4
    1f78:	00074603          	lbu	a2,0(a4)
        UART0->DATA = '\r';
    1f7c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1f80:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1f84:	895614e3          	bne	a2,s5,180c <main+0x718>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1f88:	0087d713          	srli	a4,a5,0x8
    1f8c:	00f77713          	andi	a4,a4,15
    1f90:	00eb8733          	add	a4,s7,a4
    1f94:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    1f98:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1f9c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    1fa0:	895692e3          	bne	a3,s5,1824 <main+0x730>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1fa4:	0047d713          	srli	a4,a5,0x4
    1fa8:	00f77713          	andi	a4,a4,15
    1fac:	00eb8733          	add	a4,s7,a4
    1fb0:	00074703          	lbu	a4,0(a4)
        UART0->DATA = '\r';
    1fb4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1fb8:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    1fbc:	895710e3          	bne	a4,s5,183c <main+0x748>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    1fc0:	00f7f793          	andi	a5,a5,15
    1fc4:	00fb87b3          	add	a5,s7,a5
    1fc8:	0007c783          	lbu	a5,0(a5)
        UART0->DATA = '\r';
    1fcc:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1fd0:	00ea2023          	sw	a4,0(s4)
    if (c == '\n')
    1fd4:	87579ee3          	bne	a5,s5,1850 <main+0x75c>
        UART0->DATA = '\r';
    1fd8:	016a2023          	sw	s6,0(s4)
    1fdc:	875ff06f          	j	1850 <main+0x75c>
    1fe0:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1fe4:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1fe8:	00074783          	lbu	a5,0(a4)
    1fec:	880790e3          	bnez	a5,186c <main+0x778>
    1ff0:	891ff06f          	j	1880 <main+0x78c>
        UART0->DATA = '\r';
    1ff4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    1ff8:	00fa2023          	sw	a5,0(s4)
    while (*p)
    1ffc:	00074783          	lbu	a5,0(a4)
    2000:	ea079663          	bnez	a5,16ac <main+0x5b8>
    2004:	ebcff06f          	j	16c0 <main+0x5cc>
        UART0->DATA = '\r';
    2008:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    200c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2010:	00074783          	lbu	a5,0(a4)
    2014:	e6079e63          	bnez	a5,1690 <main+0x59c>
    2018:	e8cff06f          	j	16a4 <main+0x5b0>
        UART0->DATA = '\r';
    201c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2020:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2024:	00074783          	lbu	a5,0(a4)
    2028:	e4079663          	bnez	a5,1674 <main+0x580>
    202c:	e5cff06f          	j	1688 <main+0x594>
        UART0->DATA = '\r';
    2030:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2034:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2038:	00074783          	lbu	a5,0(a4)
    203c:	e0079e63          	bnez	a5,1658 <main+0x564>
    2040:	e2cff06f          	j	166c <main+0x578>
        UART0->DATA = '\r';
    2044:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2048:	00fa2023          	sw	a5,0(s4)
    while (*p)
    204c:	00074783          	lbu	a5,0(a4)
    2050:	de079663          	bnez	a5,163c <main+0x548>
    2054:	dfcff06f          	j	1650 <main+0x55c>
        UART0->DATA = '\r';
    2058:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    205c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2060:	00074783          	lbu	a5,0(a4)
    2064:	da079e63          	bnez	a5,1620 <main+0x52c>
    2068:	dccff06f          	j	1634 <main+0x540>
        UART0->DATA = '\r';
    206c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2070:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2074:	00074783          	lbu	a5,0(a4)
    2078:	d8079663          	bnez	a5,1604 <main+0x510>
    207c:	d9cff06f          	j	1618 <main+0x524>
        UART0->DATA = '\r';
    2080:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2084:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2088:	00074783          	lbu	a5,0(a4)
    208c:	d4079a63          	bnez	a5,15e0 <main+0x4ec>
    2090:	d64ff06f          	j	15f4 <main+0x500>
        UART0->DATA = '\r';
    2094:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2098:	00fa2023          	sw	a5,0(s4)
    while (*p)
    209c:	00074783          	lbu	a5,0(a4)
    20a0:	e6079e63          	bnez	a5,171c <main+0x628>
    20a4:	e8cff06f          	j	1730 <main+0x63c>
        UART0->DATA = '\r';
    20a8:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    20ac:	00fa2023          	sw	a5,0(s4)
    while (*p)
    20b0:	00074783          	lbu	a5,0(a4)
    20b4:	e4079663          	bnez	a5,1700 <main+0x60c>
    20b8:	e5cff06f          	j	1714 <main+0x620>
        UART0->DATA = '\r';
    20bc:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    20c0:	00fa2023          	sw	a5,0(s4)
    while (*p)
    20c4:	00074783          	lbu	a5,0(a4)
    20c8:	e0079e63          	bnez	a5,16e4 <main+0x5f0>
    20cc:	e2cff06f          	j	16f8 <main+0x604>
        UART0->DATA = '\r';
    20d0:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    20d4:	00fa2023          	sw	a5,0(s4)
    while (*p)
    20d8:	00074783          	lbu	a5,0(a4)
    20dc:	de079663          	bnez	a5,16c8 <main+0x5d4>
    20e0:	dfcff06f          	j	16dc <main+0x5e8>
        UART0->DATA = '\r';
    20e4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    20e8:	00fa2023          	sw	a5,0(s4)
    while (*p)
    20ec:	00074783          	lbu	a5,0(a4)
    20f0:	e6079263          	bnez	a5,1754 <main+0x660>
    20f4:	e74ff06f          	j	1768 <main+0x674>
        UART0->DATA = '\r';
    20f8:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    20fc:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2100:	00074783          	lbu	a5,0(a4)
    2104:	e2079a63          	bnez	a5,1738 <main+0x644>
    2108:	e44ff06f          	j	174c <main+0x658>
        UART0->DATA = '\r';
    210c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2110:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2114:	00074783          	lbu	a5,0(a4)
    2118:	8c0792e3          	bnez	a5,19dc <main+0x8e8>
    return QSPI0->REG & QSPI_REG_CRM;
    211c:	810007b7          	lui	a5,0x81000
    2120:	0007a783          	lw	a5,0(a5) # 81000000 <__global_pointer$+0x40fff800>
                if ( cmd_get_crm() )
    2124:	00b79713          	slli	a4,a5,0xb
    while (*p)
    2128:	04f00793          	li	a5,79
                if ( cmd_get_crm() )
    212c:	8c074ce3          	bltz	a4,1a04 <main+0x910>
    2130:	00412703          	lw	a4,4(sp)
        putchar(*(p++));
    2134:	00170713          	addi	a4,a4,1
    if (c == '\n')
    2138:	01578c63          	beq	a5,s5,2150 <main+0x105c>
    UART0->DATA = c;
    213c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2140:	00074783          	lbu	a5,0(a4)
    2144:	80078ce3          	beqz	a5,195c <main+0x868>
        putchar(*(p++));
    2148:	00170713          	addi	a4,a4,1
    if (c == '\n')
    214c:	ff5798e3          	bne	a5,s5,213c <main+0x1048>
        UART0->DATA = '\r';
    2150:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2154:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2158:	00074783          	lbu	a5,0(a4)
    215c:	fc079ce3          	bnez	a5,2134 <main+0x1040>
        for (int rep = 10; rep > 0; rep--)
    2160:	fffc8c93          	addi	s9,s9,-1
    2164:	e00c9863          	bnez	s9,1774 <main+0x680>
    2168:	c68ff06f          	j	15d0 <main+0x4dc>
        UART0->DATA = '\r';
    216c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2170:	00da2023          	sw	a3,0(s4)
    while (*p)
    2174:	00064683          	lbu	a3,0(a2)
    2178:	ae069ae3          	bnez	a3,1c6c <main+0xb78>
        print_hex(instns_end - instns_begin, 8);
    217c:	40e80733          	sub	a4,a6,a4
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2180:	01c75693          	srli	a3,a4,0x1c
    2184:	00db86b3          	add	a3,s7,a3
    2188:	0006c583          	lbu	a1,0(a3)
    if (c == '\n')
    218c:	b15594e3          	bne	a1,s5,1c94 <main+0xba0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2190:	01875693          	srli	a3,a4,0x18
    2194:	00f6f693          	andi	a3,a3,15
    2198:	00db86b3          	add	a3,s7,a3
    219c:	0006c603          	lbu	a2,0(a3)
        UART0->DATA = '\r';
    21a0:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    21a4:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    21a8:	b15612e3          	bne	a2,s5,1cac <main+0xbb8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    21ac:	01475693          	srli	a3,a4,0x14
    21b0:	00f6f693          	andi	a3,a3,15
    21b4:	00db86b3          	add	a3,s7,a3
    21b8:	0006c583          	lbu	a1,0(a3)
        UART0->DATA = '\r';
    21bc:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    21c0:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    21c4:	b15590e3          	bne	a1,s5,1cc4 <main+0xbd0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    21c8:	01075693          	srli	a3,a4,0x10
    21cc:	00f6f693          	andi	a3,a3,15
    21d0:	00db86b3          	add	a3,s7,a3
    21d4:	0006c603          	lbu	a2,0(a3)
        UART0->DATA = '\r';
    21d8:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    21dc:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    21e0:	af561ee3          	bne	a2,s5,1cdc <main+0xbe8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    21e4:	00c75693          	srli	a3,a4,0xc
    21e8:	00f6f693          	andi	a3,a3,15
    21ec:	00db86b3          	add	a3,s7,a3
    21f0:	0006c583          	lbu	a1,0(a3)
        UART0->DATA = '\r';
    21f4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    21f8:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    21fc:	af559ce3          	bne	a1,s5,1cf4 <main+0xc00>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2200:	00875693          	srli	a3,a4,0x8
    2204:	00f6f693          	andi	a3,a3,15
    2208:	00db86b3          	add	a3,s7,a3
    220c:	0006c603          	lbu	a2,0(a3)
        UART0->DATA = '\r';
    2210:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2214:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    2218:	af561ae3          	bne	a2,s5,1d0c <main+0xc18>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    221c:	00475693          	srli	a3,a4,0x4
    2220:	00f6f693          	andi	a3,a3,15
    2224:	00db86b3          	add	a3,s7,a3
    2228:	0006c683          	lbu	a3,0(a3)
        UART0->DATA = '\r';
    222c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2230:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    2234:	af5698e3          	bne	a3,s5,1d24 <main+0xc30>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2238:	00f77713          	andi	a4,a4,15
    223c:	00eb8733          	add	a4,s7,a4
    2240:	00074703          	lbu	a4,0(a4)
        UART0->DATA = '\r';
    2244:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2248:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    224c:	af5716e3          	bne	a4,s5,1d38 <main+0xc44>
        UART0->DATA = '\r';
    2250:	016a2023          	sw	s6,0(s4)
    2254:	ae5ff06f          	j	1d38 <main+0xc44>
    2258:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    225c:	00ea2023          	sw	a4,0(s4)
    while (*p)
    2260:	0006c703          	lbu	a4,0(a3)
    2264:	ae0714e3          	bnez	a4,1d4c <main+0xc58>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2268:	01c7d713          	srli	a4,a5,0x1c
    226c:	00eb8733          	add	a4,s7,a4
    2270:	00074603          	lbu	a2,0(a4)
    if (c == '\n')
    2274:	af561ee3          	bne	a2,s5,1d70 <main+0xc7c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2278:	0187d713          	srli	a4,a5,0x18
    227c:	00f77713          	andi	a4,a4,15
    2280:	00eb8733          	add	a4,s7,a4
    2284:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    2288:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    228c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    2290:	af569ce3          	bne	a3,s5,1d88 <main+0xc94>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2294:	0147d713          	srli	a4,a5,0x14
    2298:	00f77713          	andi	a4,a4,15
    229c:	00eb8733          	add	a4,s7,a4
    22a0:	00074603          	lbu	a2,0(a4)
        UART0->DATA = '\r';
    22a4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    22a8:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    22ac:	af561ae3          	bne	a2,s5,1da0 <main+0xcac>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    22b0:	0107d713          	srli	a4,a5,0x10
    22b4:	00f77713          	andi	a4,a4,15
    22b8:	00eb8733          	add	a4,s7,a4
    22bc:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    22c0:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    22c4:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    22c8:	af5698e3          	bne	a3,s5,1db8 <main+0xcc4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    22cc:	00c7d713          	srli	a4,a5,0xc
    22d0:	00f77713          	andi	a4,a4,15
    22d4:	00eb8733          	add	a4,s7,a4
    22d8:	00074603          	lbu	a2,0(a4)
        UART0->DATA = '\r';
    22dc:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    22e0:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    22e4:	af5616e3          	bne	a2,s5,1dd0 <main+0xcdc>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    22e8:	0087d713          	srli	a4,a5,0x8
    22ec:	00f77713          	andi	a4,a4,15
    22f0:	00eb8733          	add	a4,s7,a4
    22f4:	00074683          	lbu	a3,0(a4)
        UART0->DATA = '\r';
    22f8:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    22fc:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    2300:	af5694e3          	bne	a3,s5,1de8 <main+0xcf4>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2304:	0047d713          	srli	a4,a5,0x4
    2308:	00f77713          	andi	a4,a4,15
    230c:	00eb8733          	add	a4,s7,a4
    2310:	00074703          	lbu	a4,0(a4)
        UART0->DATA = '\r';
    2314:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2318:	00da2023          	sw	a3,0(s4)
    if (c == '\n')
    231c:	af5712e3          	bne	a4,s5,1e00 <main+0xd0c>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2320:	00f7f793          	andi	a5,a5,15
    2324:	00fb87b3          	add	a5,s7,a5
    2328:	0007c783          	lbu	a5,0(a5)
        UART0->DATA = '\r';
    232c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2330:	00ea2023          	sw	a4,0(s4)
    if (c == '\n')
    2334:	af5790e3          	bne	a5,s5,1e14 <main+0xd20>
        UART0->DATA = '\r';
    2338:	016a2023          	sw	s6,0(s4)
    233c:	ad9ff06f          	j	1e14 <main+0xd20>
    2340:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2344:	00ba2023          	sw	a1,0(s4)
    while (*p)
    2348:	00054583          	lbu	a1,0(a0)
    234c:	840590e3          	bnez	a1,1b8c <main+0xa98>
        print_hex(cycles_end - cycles_begin, 8);
    2350:	40c686b3          	sub	a3,a3,a2
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2354:	01c6d613          	srli	a2,a3,0x1c
    2358:	00cb8633          	add	a2,s7,a2
    235c:	00064503          	lbu	a0,0(a2)
    if (c == '\n')
    2360:	85551ae3          	bne	a0,s5,1bb4 <main+0xac0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2364:	0186d613          	srli	a2,a3,0x18
    2368:	00f67613          	andi	a2,a2,15
    236c:	00cb8633          	add	a2,s7,a2
    2370:	00064583          	lbu	a1,0(a2)
        UART0->DATA = '\r';
    2374:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2378:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    237c:	855598e3          	bne	a1,s5,1bcc <main+0xad8>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    2380:	0146d613          	srli	a2,a3,0x14
    2384:	00f67613          	andi	a2,a2,15
    2388:	00cb8633          	add	a2,s7,a2
    238c:	00064503          	lbu	a0,0(a2)
        UART0->DATA = '\r';
    2390:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2394:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    2398:	855516e3          	bne	a0,s5,1be4 <main+0xaf0>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    239c:	0106d613          	srli	a2,a3,0x10
    23a0:	00f67613          	andi	a2,a2,15
    23a4:	00cb8633          	add	a2,s7,a2
    23a8:	00064583          	lbu	a1,0(a2)
        UART0->DATA = '\r';
    23ac:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    23b0:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    23b4:	855594e3          	bne	a1,s5,1bfc <main+0xb08>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    23b8:	00c6d613          	srli	a2,a3,0xc
    23bc:	00f67613          	andi	a2,a2,15
    23c0:	00cb8633          	add	a2,s7,a2
    23c4:	00064503          	lbu	a0,0(a2)
        UART0->DATA = '\r';
    23c8:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    23cc:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    23d0:	855512e3          	bne	a0,s5,1c14 <main+0xb20>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    23d4:	0086d613          	srli	a2,a3,0x8
    23d8:	00f67613          	andi	a2,a2,15
    23dc:	00cb8633          	add	a2,s7,a2
    23e0:	00064583          	lbu	a1,0(a2)
        UART0->DATA = '\r';
    23e4:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    23e8:	00aa2023          	sw	a0,0(s4)
    if (c == '\n')
    23ec:	855590e3          	bne	a1,s5,1c2c <main+0xb38>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    23f0:	0046d613          	srli	a2,a3,0x4
    23f4:	00f67613          	andi	a2,a2,15
    23f8:	00cb8633          	add	a2,s7,a2
    23fc:	00064603          	lbu	a2,0(a2)
        UART0->DATA = '\r';
    2400:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2404:	00ba2023          	sw	a1,0(s4)
    if (c == '\n')
    2408:	83561ee3          	bne	a2,s5,1c44 <main+0xb50>
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
    240c:	00f6f693          	andi	a3,a3,15
    2410:	00db86b3          	add	a3,s7,a3
    2414:	0006c683          	lbu	a3,0(a3)
        UART0->DATA = '\r';
    2418:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    241c:	00ca2023          	sw	a2,0(s4)
    if (c == '\n')
    2420:	83569ce3          	bne	a3,s5,1c58 <main+0xb64>
        UART0->DATA = '\r';
    2424:	016a2023          	sw	s6,0(s4)
    2428:	831ff06f          	j	1c58 <main+0xb64>
    242c:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2430:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2434:	00074783          	lbu	a5,0(a4)
    2438:	d4079e63          	bnez	a5,1994 <main+0x8a0>
    return QSPI0->REG & QSPI_REG_DSPI;
    243c:	810007b7          	lui	a5,0x81000
    2440:	0007a783          	lw	a5,0(a5) # 81000000 <__global_pointer$+0x40fff800>
                if ( cmd_get_dspi() )
    2444:	00979713          	slli	a4,a5,0x9
    while (*p)
    2448:	04f00793          	li	a5,79
                if ( cmd_get_dspi() )
    244c:	d6074863          	bltz	a4,19bc <main+0x8c8>
    2450:	00412703          	lw	a4,4(sp)
        putchar(*(p++));
    2454:	00170713          	addi	a4,a4,1
    if (c == '\n')
    2458:	01578c63          	beq	a5,s5,2470 <main+0x137c>
    UART0->DATA = c;
    245c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2460:	00074783          	lbu	a5,0(a4)
    2464:	d6078863          	beqz	a5,19d4 <main+0x8e0>
        putchar(*(p++));
    2468:	00170713          	addi	a4,a4,1
    if (c == '\n')
    246c:	ff5798e3          	bne	a5,s5,245c <main+0x1368>
        UART0->DATA = '\r';
    2470:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2474:	00fa2023          	sw	a5,0(s4)
    while (*p)
    2478:	00074783          	lbu	a5,0(a4)
    247c:	fc079ce3          	bnez	a5,2454 <main+0x1360>
    2480:	d54ff06f          	j	19d4 <main+0x8e0>
        UART0->DATA = '\r';
    2484:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    2488:	00fa2023          	sw	a5,0(s4)
    while (*p)
    248c:	00074783          	lbu	a5,0(a4)
    2490:	ce079463          	bnez	a5,1978 <main+0x884>
    2494:	cf8ff06f          	j	198c <main+0x898>
        UART0->DATA = '\r';
    2498:	016a2023          	sw	s6,0(s4)
    UART0->DATA = c;
    249c:	00fa2023          	sw	a5,0(s4)
    while (*p)
    24a0:	00074783          	lbu	a5,0(a4)
    24a4:	d0079e63          	bnez	a5,19c0 <main+0x8cc>
    24a8:	d2cff06f          	j	19d4 <main+0x8e0>

000024ac <irqCallback>:
    }
}

void irqCallback() {

    24ac:	00008067          	ret
    24b0:	3130                	.insn	2, 0x3130
    24b2:	3332                	.insn	2, 0x3332
    24b4:	3534                	.insn	2, 0x3534
    24b6:	3736                	.insn	2, 0x3736
    24b8:	3938                	.insn	2, 0x3938
    24ba:	6261                	.insn	2, 0x6261
    24bc:	66656463          	bltu	a0,t1,2b24 <_etext+0x258>
    24c0:	0000                	.insn	2, 0x
    24c2:	0000                	.insn	2, 0x
    24c4:	6c637943          	.insn	4, 0x6c637943
    24c8:	7365                	.insn	2, 0x7365
    24ca:	203a                	.insn	2, 0x203a
    24cc:	7830                	.insn	2, 0x7830
    24ce:	0000                	.insn	2, 0x
    24d0:	6e49                	.insn	2, 0x6e49
    24d2:	736e7473          	.insn	4, 0x736e7473
    24d6:	203a                	.insn	2, 0x203a
    24d8:	7830                	.insn	2, 0x7830
    24da:	0000                	.insn	2, 0x
    24dc:	736b6843          	.insn	4, 0x736b6843
    24e0:	6d75                	.insn	2, 0x6d75
    24e2:	203a                	.insn	2, 0x203a
    24e4:	7830                	.insn	2, 0x7830
    24e6:	0000                	.insn	2, 0x
    24e8:	6564                	.insn	2, 0x6564
    24ea:	6166                	.insn	2, 0x6166
    24ec:	6c75                	.insn	2, 0x6c75
    24ee:	2074                	.insn	2, 0x2074
    24f0:	2020                	.insn	2, 0x2020
    24f2:	2020                	.insn	2, 0x2020
    24f4:	2020                	.insn	2, 0x2020
    24f6:	0020                	.insn	2, 0x0020
    24f8:	203a                	.insn	2, 0x203a
    24fa:	0000                	.insn	2, 0x
    24fc:	7364                	.insn	2, 0x7364
    24fe:	6970                	.insn	2, 0x6970
    2500:	002d                	.insn	2, 0x002d
    2502:	0000                	.insn	2, 0x
    2504:	2020                	.insn	2, 0x2020
    2506:	2020                	.insn	2, 0x2020
    2508:	2020                	.insn	2, 0x2020
    250a:	2020                	.insn	2, 0x2020
    250c:	0020                	.insn	2, 0x0020
    250e:	0000                	.insn	2, 0x
    2510:	7364                	.insn	2, 0x7364
    2512:	6970                	.insn	2, 0x6970
    2514:	632d                	.insn	2, 0x632d
    2516:	6d72                	.insn	2, 0x6d72
    2518:	002d                	.insn	2, 0x002d
    251a:	0000                	.insn	2, 0x
    251c:	6e69                	.insn	2, 0x6e69
    251e:	736e7473          	.insn	4, 0x736e7473
    2522:	2020                	.insn	2, 0x2020
    2524:	2020                	.insn	2, 0x2020
    2526:	2020                	.insn	2, 0x2020
    2528:	2020                	.insn	2, 0x2020
    252a:	3a20                	.insn	2, 0x3a20
    252c:	0020                	.insn	2, 0x0020
    252e:	0000                	.insn	2, 0x
    2530:	2020                	.insn	2, 0x2020
    2532:	5f5f 5f5f 2020      	.insn	6, 0x20205f5f5f5f
    2538:	205f 2020 2020      	.insn	6, 0x20202020205f
    253e:	2020                	.insn	2, 0x2020
    2540:	2020                	.insn	2, 0x2020
    2542:	5f20                	.insn	2, 0x5f20
    2544:	5f5f 205f 2020      	.insn	6, 0x2020205f5f5f
    254a:	2020                	.insn	2, 0x2020
    254c:	2020                	.insn	2, 0x2020
    254e:	2020                	.insn	2, 0x2020
    2550:	5f5f 5f5f 000a      	.insn	6, 0x000a5f5f5f5f
    2556:	0000                	.insn	2, 0x
    2558:	7c20                	.insn	2, 0x7c20
    255a:	2020                	.insn	2, 0x2020
    255c:	205f 285c 295f      	.insn	6, 0x295f285c205f
    2562:	5f20                	.insn	2, 0x5f20
    2564:	5f5f 5f20 5f5f      	.insn	6, 0x5f5f5f205f5f
    256a:	5f5f202f          	.insn	4, 0x5f5f202f
    256e:	7c5f 2020 5f5f      	.insn	6, 0x5f5f20207c5f
    2574:	205f 2f20 5f20      	.insn	6, 0x5f202f20205f
    257a:	5f5f 0a7c 0000      	.insn	6, 0x0a7c5f5f
    2580:	7c20                	.insn	2, 0x7c20
    2582:	7c20                	.insn	2, 0x7c20
    2584:	295f 7c20 7c20      	.insn	6, 0x7c207c20295f
    258a:	5f5f202f          	.insn	4, 0x5f5f202f
    258e:	205f202f          	.insn	4, 0x205f202f
    2592:	5f5c                	.insn	2, 0x5f5c
    2594:	5f5f 5c20 2f20      	.insn	6, 0x2f205c205f5f
    259a:	5f20                	.insn	2, 0x5f20
    259c:	5c20                	.insn	2, 0x5c20
    259e:	207c                	.insn	2, 0x207c
    25a0:	0a7c                	.insn	2, 0x0a7c
    25a2:	0000                	.insn	2, 0x
    25a4:	7c20                	.insn	2, 0x7c20
    25a6:	2020                	.insn	2, 0x2020
    25a8:	5f5f 7c2f 7c20      	.insn	6, 0x7c207c2f5f5f
    25ae:	2820                	.insn	2, 0x2820
    25b0:	7c5f 2820 295f      	.insn	6, 0x295f28207c5f
    25b6:	7c20                	.insn	2, 0x7c20
    25b8:	5f5f 2029 207c      	.insn	6, 0x207c20295f5f
    25be:	5f28                	.insn	2, 0x5f28
    25c0:	2029                	.insn	2, 0x2029
    25c2:	207c                	.insn	2, 0x207c
    25c4:	5f7c                	.insn	2, 0x5f7c
    25c6:	5f5f 000a 0000      	.insn	6, 0x000a5f5f
    25cc:	7c20                	.insn	2, 0x7c20
    25ce:	7c5f 2020 7c20      	.insn	6, 0x7c2020207c5f
    25d4:	7c5f 5f5c 5f5f      	.insn	6, 0x5f5f5f5c7c5f
    25da:	5f5c                	.insn	2, 0x5f5c
    25dc:	5f5f 5f2f 5f5f      	.insn	6, 0x5f5f5f2f5f5f
    25e2:	2f5f 5c20 5f5f      	.insn	6, 0x5f5f5c202f5f
    25e8:	2f5f 5c20 5f5f      	.insn	6, 0x5f5f5c202f5f
    25ee:	5f5f 0a7c 0000      	.insn	6, 0x0a7c5f5f
    25f4:	2020                	.insn	2, 0x2020
    25f6:	2020                	.insn	2, 0x2020
    25f8:	2020                	.insn	2, 0x2020
    25fa:	2020                	.insn	2, 0x2020
    25fc:	4c206e4f          	.insn	4, 0x4c206e4f
    2600:	6369                	.insn	2, 0x6369
    2602:	6568                	.insn	2, 0x6568
    2604:	2065                	.insn	2, 0x2065
    2606:	6154                	.insn	2, 0x6154
    2608:	676e                	.insn	2, 0x676e
    260a:	4e20                	.insn	2, 0x4e20
    260c:	6e61                	.insn	2, 0x6e61
    260e:	4b392d6f          	jal	s10,952c0 <_etext+0x929f4>
    2612:	000a                	.insn	2, 0x000a
    2614:	656c6553          	.insn	4, 0x656c6553
    2618:	61207463          	bgeu	zero,s2,2c20 <_etext+0x354>
    261c:	206e                	.insn	2, 0x206e
    261e:	6361                	.insn	2, 0x6361
    2620:	6974                	.insn	2, 0x6974
    2622:	0a3a6e6f          	jal	t3,a8ec4 <_etext+0xa65f8>
    2626:	0000                	.insn	2, 0x
    2628:	2020                	.insn	2, 0x2020
    262a:	5b20                	.insn	2, 0x5b20
    262c:	5d31                	.insn	2, 0x5d31
    262e:	5420                	.insn	2, 0x5420
    2630:	6c67676f          	jal	a4,78cf6 <_etext+0x7642a>
    2634:	2065                	.insn	2, 0x2065
    2636:	656c                	.insn	2, 0x656c
    2638:	2064                	.insn	2, 0x2064
    263a:	0a31                	.insn	2, 0x0a31
    263c:	0000                	.insn	2, 0x
    263e:	0000                	.insn	2, 0x
    2640:	2020                	.insn	2, 0x2020
    2642:	5b20                	.insn	2, 0x5b20
    2644:	5d32                	.insn	2, 0x5d32
    2646:	5420                	.insn	2, 0x5420
    2648:	6c67676f          	jal	a4,78d0e <_etext+0x76442>
    264c:	2065                	.insn	2, 0x2065
    264e:	656c                	.insn	2, 0x656c
    2650:	2064                	.insn	2, 0x2064
    2652:	0a32                	.insn	2, 0x0a32
    2654:	0000                	.insn	2, 0x
    2656:	0000                	.insn	2, 0x
    2658:	2020                	.insn	2, 0x2020
    265a:	5b20                	.insn	2, 0x5b20
    265c:	54205d33          	.insn	4, 0x54205d33
    2660:	6c67676f          	jal	a4,78d26 <_etext+0x7645a>
    2664:	2065                	.insn	2, 0x2065
    2666:	656c                	.insn	2, 0x656c
    2668:	2064                	.insn	2, 0x2064
    266a:	00000a33          	add	s4,zero,zero
    266e:	0000                	.insn	2, 0x
    2670:	2020                	.insn	2, 0x2020
    2672:	5b20                	.insn	2, 0x5b20
    2674:	5d34                	.insn	2, 0x5d34
    2676:	5420                	.insn	2, 0x5420
    2678:	6c67676f          	jal	a4,78d3e <_etext+0x76472>
    267c:	2065                	.insn	2, 0x2065
    267e:	656c                	.insn	2, 0x656c
    2680:	2064                	.insn	2, 0x2064
    2682:	0a34                	.insn	2, 0x0a34
    2684:	0000                	.insn	2, 0x
    2686:	0000                	.insn	2, 0x
    2688:	2020                	.insn	2, 0x2020
    268a:	5b20                	.insn	2, 0x5b20
    268c:	5d35                	.insn	2, 0x5d35
    268e:	5420                	.insn	2, 0x5420
    2690:	6c67676f          	jal	a4,78d56 <_etext+0x7648a>
    2694:	2065                	.insn	2, 0x2065
    2696:	656c                	.insn	2, 0x656c
    2698:	2064                	.insn	2, 0x2064
    269a:	0a35                	.insn	2, 0x0a35
    269c:	0000                	.insn	2, 0x
    269e:	0000                	.insn	2, 0x
    26a0:	2020                	.insn	2, 0x2020
    26a2:	5b20                	.insn	2, 0x5b20
    26a4:	5d36                	.insn	2, 0x5d36
    26a6:	5420                	.insn	2, 0x5420
    26a8:	6c67676f          	jal	a4,78d6e <_etext+0x764a2>
    26ac:	2065                	.insn	2, 0x2065
    26ae:	656c                	.insn	2, 0x656c
    26b0:	2064                	.insn	2, 0x2064
    26b2:	0a36                	.insn	2, 0x0a36
    26b4:	0000                	.insn	2, 0x
    26b6:	0000                	.insn	2, 0x
    26b8:	2020                	.insn	2, 0x2020
    26ba:	5b20                	.insn	2, 0x5b20
    26bc:	5d46                	.insn	2, 0x5d46
    26be:	4720                	.insn	2, 0x4720
    26c0:	7465                	.insn	2, 0x7465
    26c2:	6620                	.insn	2, 0x6620
    26c4:	616c                	.insn	2, 0x616c
    26c6:	6d206873          	.insn	4, 0x6d206873
    26ca:	0a65646f          	jal	s0,58770 <_etext+0x55ea4>
    26ce:	0000                	.insn	2, 0x
    26d0:	2020                	.insn	2, 0x2020
    26d2:	5b20                	.insn	2, 0x5b20
    26d4:	5d49                	.insn	2, 0x5d49
    26d6:	5220                	.insn	2, 0x5220
    26d8:	6165                	.insn	2, 0x6165
    26da:	2064                	.insn	2, 0x2064
    26dc:	20495053          	.insn	4, 0x20495053
    26e0:	6c66                	.insn	2, 0x6c66
    26e2:	7361                	.insn	2, 0x7361
    26e4:	2068                	.insn	2, 0x2068
    26e6:	4449                	.insn	2, 0x4449
    26e8:	000a                	.insn	2, 0x000a
    26ea:	0000                	.insn	2, 0x
    26ec:	2020                	.insn	2, 0x2020
    26ee:	5b20                	.insn	2, 0x5b20
    26f0:	53205d53          	.insn	4, 0x53205d53
    26f4:	7465                	.insn	2, 0x7465
    26f6:	5320                	.insn	2, 0x5320
    26f8:	6e69                	.insn	2, 0x6e69
    26fa:	20656c67          	.insn	4, 0x20656c67
    26fe:	20495053          	.insn	4, 0x20495053
    2702:	6f6d                	.insn	2, 0x6f6d
    2704:	6564                	.insn	2, 0x6564
    2706:	000a                	.insn	2, 0x000a
    2708:	2020                	.insn	2, 0x2020
    270a:	5b20                	.insn	2, 0x5b20
    270c:	5d44                	.insn	2, 0x5d44
    270e:	5320                	.insn	2, 0x5320
    2710:	7465                	.insn	2, 0x7465
    2712:	4420                	.insn	2, 0x4420
    2714:	20495053          	.insn	4, 0x20495053
    2718:	6f6d                	.insn	2, 0x6f6d
    271a:	6564                	.insn	2, 0x6564
    271c:	000a                	.insn	2, 0x000a
    271e:	0000                	.insn	2, 0x
    2720:	2020                	.insn	2, 0x2020
    2722:	5b20                	.insn	2, 0x5b20
    2724:	53205d43          	.insn	4, 0x53205d43
    2728:	7465                	.insn	2, 0x7465
    272a:	4420                	.insn	2, 0x4420
    272c:	2b495053          	.insn	4, 0x2b495053
    2730:	204d5243          	.insn	4, 0x204d5243
    2734:	6f6d                	.insn	2, 0x6f6d
    2736:	6564                	.insn	2, 0x6564
    2738:	000a                	.insn	2, 0x000a
    273a:	0000                	.insn	2, 0x
    273c:	2020                	.insn	2, 0x2020
    273e:	5b20                	.insn	2, 0x5b20
    2740:	5d42                	.insn	2, 0x5d42
    2742:	5220                	.insn	2, 0x5220
    2744:	6e75                	.insn	2, 0x6e75
    2746:	7320                	.insn	2, 0x7320
    2748:	6d69                	.insn	2, 0x6d69
    274a:	6c70                	.insn	2, 0x6c70
    274c:	7369                	.insn	2, 0x7369
    274e:	6974                	.insn	2, 0x6974
    2750:	65622063          	.insn	4, 0x65622063
    2754:	636e                	.insn	2, 0x636e
    2756:	6d68                	.insn	2, 0x6d68
    2758:	7261                	.insn	2, 0x7261
    275a:	00000a6b          	.insn	4, 0x0a6b
    275e:	0000                	.insn	2, 0x
    2760:	2020                	.insn	2, 0x2020
    2762:	5b20                	.insn	2, 0x5b20
    2764:	5d41                	.insn	2, 0x5d41
    2766:	4220                	.insn	2, 0x4220
    2768:	6e65                	.insn	2, 0x6e65
    276a:	616d6863          	bltu	s10,s6,2d7a <_etext+0x4ae>
    276e:	6b72                	.insn	2, 0x6b72
    2770:	6120                	.insn	2, 0x6120
    2772:	6c6c                	.insn	2, 0x6c6c
    2774:	6320                	.insn	2, 0x6320
    2776:	69666e6f          	jal	t3,68e0c <_etext+0x66540>
    277a:	000a7367          	.insn	4, 0x000a7367
    277e:	0000                	.insn	2, 0x
    2780:	4f49                	.insn	2, 0x4f49
    2782:	5320                	.insn	2, 0x5320
    2784:	6174                	.insn	2, 0x6174
    2786:	6574                	.insn	2, 0x6574
    2788:	203a                	.insn	2, 0x203a
    278a:	0000                	.insn	2, 0x
    278c:	6d6d6f43          	.insn	4, 0x6d6d6f43
    2790:	6e61                	.insn	2, 0x6e61
    2792:	3e64                	.insn	2, 0x3e64
    2794:	0020                	.insn	2, 0x0020
    2796:	0000                	.insn	2, 0x
    2798:	20495053          	.insn	4, 0x20495053
    279c:	74617453          	.insn	4, 0x74617453
    27a0:	3a65                	.insn	2, 0x3a65
    27a2:	000a                	.insn	2, 0x000a
    27a4:	2020                	.insn	2, 0x2020
    27a6:	5344                	.insn	2, 0x5344
    27a8:	4950                	.insn	2, 0x4950
    27aa:	0020                	.insn	2, 0x0020
    27ac:	000a4e4f          	.insn	4, 0x000a4e4f
    27b0:	0a46464f          	.insn	4, 0x0a46464f
    27b4:	0000                	.insn	2, 0x
    27b6:	0000                	.insn	2, 0x
    27b8:	2020                	.insn	2, 0x2020
    27ba:	204d5243          	.insn	4, 0x204d5243
    27be:	0020                	.insn	2, 0x0020
    27c0:	1ea0                	.insn	2, 0x1ea0
    27c2:	0000                	.insn	2, 0x
    27c4:	1e84                	.insn	2, 0x1e84
    27c6:	0000                	.insn	2, 0x
    27c8:	1e68                	.insn	2, 0x1e68
    27ca:	0000                	.insn	2, 0x
    27cc:	1e4c                	.insn	2, 0x1e4c
    27ce:	0000                	.insn	2, 0x
    27d0:	1ed8                	.insn	2, 0x1ed8
    27d2:	0000                	.insn	2, 0x
    27d4:	1ebc                	.insn	2, 0x1ebc
    27d6:	0000                	.insn	2, 0x
    27d8:	195c                	.insn	2, 0x195c
    27da:	0000                	.insn	2, 0x
    27dc:	195c                	.insn	2, 0x195c
    27de:	0000                	.insn	2, 0x
    27e0:	195c                	.insn	2, 0x195c
    27e2:	0000                	.insn	2, 0x
    27e4:	195c                	.insn	2, 0x195c
    27e6:	0000                	.insn	2, 0x
    27e8:	195c                	.insn	2, 0x195c
    27ea:	0000                	.insn	2, 0x
    27ec:	195c                	.insn	2, 0x195c
    27ee:	0000                	.insn	2, 0x
    27f0:	195c                	.insn	2, 0x195c
    27f2:	0000                	.insn	2, 0x
    27f4:	195c                	.insn	2, 0x195c
    27f6:	0000                	.insn	2, 0x
    27f8:	195c                	.insn	2, 0x195c
    27fa:	0000                	.insn	2, 0x
    27fc:	195c                	.insn	2, 0x195c
    27fe:	0000                	.insn	2, 0x
    2800:	1e2c                	.insn	2, 0x1e2c
    2802:	0000                	.insn	2, 0x
    2804:	1ae0                	.insn	2, 0x1ae0
    2806:	0000                	.insn	2, 0x
    2808:	1acc                	.insn	2, 0x1acc
    280a:	0000                	.insn	2, 0x
    280c:	1a98                	.insn	2, 0x1a98
    280e:	0000                	.insn	2, 0x
    2810:	195c                	.insn	2, 0x195c
    2812:	0000                	.insn	2, 0x
    2814:	1968                	.insn	2, 0x1968
    2816:	0000                	.insn	2, 0x
    2818:	195c                	.insn	2, 0x195c
    281a:	0000                	.insn	2, 0x
    281c:	195c                	.insn	2, 0x195c
    281e:	0000                	.insn	2, 0x
    2820:	1a40                	.insn	2, 0x1a40
    2822:	0000                	.insn	2, 0x
    2824:	195c                	.insn	2, 0x195c
    2826:	0000                	.insn	2, 0x
    2828:	195c                	.insn	2, 0x195c
    282a:	0000                	.insn	2, 0x
    282c:	195c                	.insn	2, 0x195c
    282e:	0000                	.insn	2, 0x
    2830:	195c                	.insn	2, 0x195c
    2832:	0000                	.insn	2, 0x
    2834:	195c                	.insn	2, 0x195c
    2836:	0000                	.insn	2, 0x
    2838:	195c                	.insn	2, 0x195c
    283a:	0000                	.insn	2, 0x
    283c:	195c                	.insn	2, 0x195c
    283e:	0000                	.insn	2, 0x
    2840:	195c                	.insn	2, 0x195c
    2842:	0000                	.insn	2, 0x
    2844:	195c                	.insn	2, 0x195c
    2846:	0000                	.insn	2, 0x
    2848:	1a60                	.insn	2, 0x1a60
    284a:	0000                	.insn	2, 0x
    284c:	195c                	.insn	2, 0x195c
    284e:	0000                	.insn	2, 0x
    2850:	195c                	.insn	2, 0x195c
    2852:	0000                	.insn	2, 0x
    2854:	195c                	.insn	2, 0x195c
    2856:	0000                	.insn	2, 0x
    2858:	195c                	.insn	2, 0x195c
    285a:	0000                	.insn	2, 0x
    285c:	195c                	.insn	2, 0x195c
    285e:	0000                	.insn	2, 0x
    2860:	195c                	.insn	2, 0x195c
    2862:	0000                	.insn	2, 0x
    2864:	195c                	.insn	2, 0x195c
    2866:	0000                	.insn	2, 0x
    2868:	195c                	.insn	2, 0x195c
    286a:	0000                	.insn	2, 0x
    286c:	195c                	.insn	2, 0x195c
    286e:	0000                	.insn	2, 0x
    2870:	195c                	.insn	2, 0x195c
    2872:	0000                	.insn	2, 0x
    2874:	195c                	.insn	2, 0x195c
    2876:	0000                	.insn	2, 0x
    2878:	195c                	.insn	2, 0x195c
    287a:	0000                	.insn	2, 0x
    287c:	195c                	.insn	2, 0x195c
    287e:	0000                	.insn	2, 0x
    2880:	1e2c                	.insn	2, 0x1e2c
    2882:	0000                	.insn	2, 0x
    2884:	1ae0                	.insn	2, 0x1ae0
    2886:	0000                	.insn	2, 0x
    2888:	1acc                	.insn	2, 0x1acc
    288a:	0000                	.insn	2, 0x
    288c:	1a98                	.insn	2, 0x1a98
    288e:	0000                	.insn	2, 0x
    2890:	195c                	.insn	2, 0x195c
    2892:	0000                	.insn	2, 0x
    2894:	1968                	.insn	2, 0x1968
    2896:	0000                	.insn	2, 0x
    2898:	195c                	.insn	2, 0x195c
    289a:	0000                	.insn	2, 0x
    289c:	195c                	.insn	2, 0x195c
    289e:	0000                	.insn	2, 0x
    28a0:	1a40                	.insn	2, 0x1a40
    28a2:	0000                	.insn	2, 0x
    28a4:	195c                	.insn	2, 0x195c
    28a6:	0000                	.insn	2, 0x
    28a8:	195c                	.insn	2, 0x195c
    28aa:	0000                	.insn	2, 0x
    28ac:	195c                	.insn	2, 0x195c
    28ae:	0000                	.insn	2, 0x
    28b0:	195c                	.insn	2, 0x195c
    28b2:	0000                	.insn	2, 0x
    28b4:	195c                	.insn	2, 0x195c
    28b6:	0000                	.insn	2, 0x
    28b8:	195c                	.insn	2, 0x195c
    28ba:	0000                	.insn	2, 0x
    28bc:	195c                	.insn	2, 0x195c
    28be:	0000                	.insn	2, 0x
    28c0:	195c                	.insn	2, 0x195c
    28c2:	0000                	.insn	2, 0x
    28c4:	195c                	.insn	2, 0x195c
    28c6:	0000                	.insn	2, 0x
    28c8:	1a60                	.insn	2, 0x1a60
	...
