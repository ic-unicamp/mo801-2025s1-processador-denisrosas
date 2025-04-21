module extend (
    input [31:0] instr,       // Instruction bits 31:0 - only 31:7 will be used
    input [1:0] imm_src,      // Immediate format selector
    output reg [31:0] imm_ext  // Sign-extended immediate
);

always @(*) begin
    case (imm_src)
        // I-type immediate (12 bits: instr[31:20])
        3'b00: imm_ext = {{20{instr[31]}}, instr[31:20]};
        
        // S-type immediate (12 bits: {instr[31:25], instr[11:7]})
        3'b01: imm_ext = { {20{instr[31]} }, instr[31:25], instr[11:7]};
        
        // B-type immediate (13 bits: {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0})
        3'b10: imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

        // J-type immediate (20 bits: {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0})
        3'b11: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

        // R-type has no immediate (output 0)
        default: imm_ext = 32'b0;  // Default case covers R-type and undefined codes
    endcase
end

endmodule