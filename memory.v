module memory(
  input [31:0] address,
  input [31:0] data_in,
  output reg [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória
integer i;

always @(address or data_in or we) begin
  if (we) begin
    mem[address[13:2]] = data_in;
  end
  data_out = mem[address[13:2]];
end

//from 0 (0x0) to 2047 (0x800) - instruction memory 
//from 2048 (0x800) to 4092 (0xFFC) - data memory

initial begin
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i] = 32'h00000000;
  end
  $readmemh("memory.mem", mem);
end

endmodule
