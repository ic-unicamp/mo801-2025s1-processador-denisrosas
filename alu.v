module alu (
    input [2:0] alu_control,
    input [31:0] source1,
    input [31:0] source2,
    output reg [31:0] result,
    output reg carry_out,
    output reg zero
);

  always @(alu_control, source1, source2) begin
    case (alu_control)
        3'b000: {carry_out,result} = source1 + source2;
        3'b001: result = source1 - source2;
        3'b010: result = source1 & source2;
        3'b011: result = source1 | source2;
        3'b101: result = (source1 < source2) ? 32'h00000001 : 32'h00000000;
        default: result = 32'h00000000;
    endcase
    zero = (result == 32'h00000000) ? 1'b1 : 1'b0;
  end

endmodule