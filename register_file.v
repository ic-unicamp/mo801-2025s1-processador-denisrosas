module register_file(
input clk,
input [4:0] a1,
input [4:0] a2,
input [4:0] write_data,
input [31:0] data_in,
input we,
output reg [31:0] read_data1,
output reg [31:0] read_data2
);

  reg [31:0] registers [31:0]; // Array of 32 registers, each 32 bits wide

  // Read registers
  always @(negedge clk)
    begin
      if (we)
        registers[write_data] <= data_in;
        read_data1 = registers[a1];
        read_data2 = registers[a2];
    end
endmodule
