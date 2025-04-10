module register_file(
input clk,
input [4:0] a1, //rs1
input [4:0] a2, //rs2
input [4:0] a3, //rd
input [31:0] wd3,
input we,
output reg [31:0] read_data1,
output reg [31:0] read_data2
);

  reg [31:0] registers [31:0]; // Array of 32 registers, each 32 bits wide

  // Read registers
  always @(negedge clk)
    begin
      if (we)
        registers[a3] <= wd3;
      read_data1 = registers[a1];
      read_data2 = registers[a2];
    end
endmodule
