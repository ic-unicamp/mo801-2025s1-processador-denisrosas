module memory(
  input clk,
  input [31:0] address,
  input [31:0] data_in,
  output [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória
integer i;

//from 0 (0x0) to 2047 (0x800) - instruction memory 
//from 2048 (0x800) to 4092 (0xFFC) - data memory

assign data_out = mem[address[13:2]];

always @(posedge clk) begin
  if (we) begin
    mem[address[13:2]] = data_in;
  end
end

endmodule