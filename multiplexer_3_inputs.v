module multiplexer_3_inputs (
    input [31:0] in0,    // 32-bit input 0
    input [31:0] in1,    // 32-bit input 1
    input [31:0] in2,    // 32-bit input 2
    input [1:0] control, // 2-bit control signal
    output reg [31:0] out // 32-bit output
);

    always @(*) begin
        case (control)
            2'b00: out = in0; // Select input 0
            2'b01: out = in1; // Select input 1
            2'b10: out = in2; // Select input 2
            default: out = 32'b0; // Default case to handle unexpected values
        endcase
    end

endmodule
