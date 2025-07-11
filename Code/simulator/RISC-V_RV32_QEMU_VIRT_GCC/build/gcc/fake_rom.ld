OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY
{
	/* Fake ROM area */
	rom (rxa) : ORIGIN = 0x80000000, LENGTH = 512K
	ram (wxa) : ORIGIN = 0x80080000, LENGTH = 1024K
}

/* Default stack size if not defined externally */
__stack_size = DEFINED(__stack_size) ? __stack_size : 0x2000;

SECTIONS
{
	.init :
	{
		_text = .;
		KEEP (*(SORT_NONE(.init)))
	} >rom AT>rom
	
	.text :
	{
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*)
		*(.gnu.linkonce.t.*)
	} >rom AT>rom
	
	.fini :
	{
		KEEP (*(SORT_NONE(.fini)))
		_etext = .;
	} >rom AT>rom

	.rodata.align ALIGN(4):
	{
		_rodata = .;
	} >rom AT>rom

	.rodata.start :
	{
		_rodata_lma = LOADADDR(.rodata.start);
	} >rom AT>rom

	.rodata :
	{
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)

		. = ALIGN(4);
		_erodata = .;
	} >rom AT>rom

	.tdata : {
		*(.tdata .tdata.*)
	} >rom AT>rom

	.tbss (NOLOAD) : {
		*(.tbss .tbss.* .gnu.linkonce.tb.*)
		*(.tcommon)
		PROVIDE( __tbss_end = . );
		PROVIDE( __tls_end = . );
	} >rom AT>rom
	PROVIDE( __tdata_source = LOADADDR(.tdata) );
	PROVIDE( __tdata_source_end = LOADADDR(.tdata) + SIZEOF(.tdata) );
	PROVIDE( __tdata_size = SIZEOF(.tdata) );
	PROVIDE( __tbss_offset = ADDR(.tbss) - ADDR(.tdata) );
	PROVIDE( __tbss_start = ADDR(.tbss) );
	PROVIDE( __tbss_size = SIZEOF(.tbss) );
	PROVIDE( __tls_size = __tls_end - ADDR(.tdata) );
	PROVIDE( __tls_align = MAX(ALIGNOF(.tdata), ALIGNOF(.tbss)) );

	.data.align :
	{
		. = ALIGN(4);
		_data = .;
	} >ram AT>rom

	.data.start :
	{
		_data_lma = LOADADDR(.data.start);
	} >ram AT>rom

	.data :
	{
		*(.data .data.*)
		*(.gnu.linkonce.d.*)
		. = ALIGN(8);
		PROVIDE( __global_pointer$ = . + 0x800 );
		*(.sdata .sdata.*)
		*(.sdata2 .sdata2.*)
		*(.gnu.linkonce.s.*)
		. = ALIGN(8);
		*(.srodata.cst16)
		*(.srodata.cst8)
		*(.srodata.cst4)
		*(.srodata.cst2)
		*(.srodata .srodata.*)

		. = ALIGN(4);
		_edata = .;
	} >ram AT>rom

	.bss.align :
	{
		. = ALIGN(4);
		_bss = .;
	} >ram AT>rom

	.bss.start :
	{
		_bss_lma = LOADADDR(.bss.start);
	} >ram AT>rom

	.bss :
	{
		*(.sbss*)
		*(.gnu.linkonce.sb.*)
		*(.bss .bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
	} >ram AT>rom

	. = ALIGN(8);
	_end = .;

	.stack :
	{
		. = ALIGN(16);
		. += __stack_size;
		_stack_top = .;
	} >ram AT>ram
}
