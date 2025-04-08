module multiplexer_2_inputs (
    input [31:0] in0,    // 32-bit input 0
    input [31:0] in1,    // 32-bit input 1
    input control, // 1-bit control signal
    output reg [31:0] out // 32-bit output
);

    always @(*) begin
        case (control)
            2'b0: out = in0; // Select input 0
            2'b1: out = in1; // Select input 1
            default: out = 32'b0; // Default case to handle unexpected values
        endcase
    end

endmodule
