
import sys
import struct

if len(sys.argv) != 3:
    print("usage: python3 progmem.py <firmware.bin> <output-progmem.v>")
    sys.exit(2)

try:
    with open(sys.argv[1], 'rb') as bin_file:
        bin_contents = bin_file.read()
except Exception as e:
    print(f"Open bin file Exception: {e}")
    sys.exit(-1)

print(f"Bin file size: {len(bin_contents)} bytes")

while len(bin_contents) % 4:
    bin_contents += b'\x00'

progmem_text = ''
hex_values = []
while len(bin_contents) != 0:
    hex_values.append(struct.unpack("<I", bin_contents[0:4])[0])
    bin_contents = bin_contents[4:]

addr = 0
try:
    with open(sys.argv[2], 'w') as prog_mem_file:

        for value in hex_values:
            progmem_text += f"    mem[\'h{addr:04X}] <= 32\'h{value:08X};\n"
            addr += 1
    

        progmem_body = f"""
module progmem (
    // Clock & reset
    input wire clk,
    input wire rstn,

    // PicoRV32 bus interface
    input  wire        valid,
    output wire        ready,	
    input  wire [31:0] addr,
    output wire [31:0] rdata,
	// Rewrite firmware
    input  wire        wen,
	input  wire [31:0] waddr,
	input  wire [31:0] wdata
);

  // ============================================================================

  localparam MEM_SIZE_BITS = 13;  // In 32-bit words
  localparam MEM_SIZE = 1 << MEM_SIZE_BITS;
  localparam MEM_ADDR_MASK = 32'h0010_0000;

  // ============================================================================

  wire [MEM_SIZE_BITS-1:0] mem_addr;
  reg  [             31:0] mem_data;
  reg  [             31:0] mem      [0:MEM_SIZE];

  initial begin
{progmem_text}
  end

  always @(posedge clk) mem_data <= mem[mem_addr];

  // ============================================================================

  reg o_ready;

  always @(posedge clk or negedge rstn)
    if (!rstn) o_ready <= 1'd0;
    else o_ready <= valid && ((addr & MEM_ADDR_MASK) != 0);

  // Output connectins
  assign ready    = o_ready;
  assign rdata    = mem_data;
  assign mem_addr = addr[MEM_SIZE_BITS+1:2];

  always @(posedge clk) begin    
    if (wen) mem[waddr] <= wdata;				
  end

endmodule
"""

        prog_mem_file.write(progmem_body)
        print(f"Wrote {sys.argv[2]} with {addr} words")

except Exception as e:
    print(f"Write file Exception: {e}")
    sys.exit(-1)
