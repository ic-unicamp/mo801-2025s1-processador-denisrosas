module alu (
    input [2:0] ula_control,
    input [31:0] source1,
    input [31:0] source2,
    output reg [31:0] result,
    output reg carry_out
);

  always @* begin
    case (ula_control)
        3'b000: result = source1 & source2;
        3'b001: result = source1 | source2;
        3'b010: {carry_out,result} = source1 + source2;
        3'b110: result = source1 - source2;
        3'b111: result = (source1 < source2) ? 32'h00000001 : 32'h00000000;
        default: result = 32'h00000000;
    endcase
  end

endmodule