module extend (
    input [31:0] instr,       // Instruction bits 31:0
    input [1:0] imm_src,      // Immediate format selector
                              // 000: R-type (no immediate)
                              // 001: I-type
                              // 010: S-type
                              // 011: B-type
                              // 100: U-type (not used here)
                              // 101: J-type (not used here)
    output reg [31:0] imm_ext  // Sign-extended immediate
);

always @(*) begin
    case (imm_src)
        // I-type immediate (12 bits: instr[31:20])
        3'b00: imm_ext = {{20{instr[31]}}, instr[31:20]};
        
        // B-type immediate (13 bits: {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0})
        3'b01: imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        
        // S-type immediate (12 bits: {instr[31:25], instr[11:7]})
        3'b10: imm_ext = { {20{instr[31]} }, instr[31:25], instr[11:7]};
        
        // R-type has no immediate (output 0)
        default: imm_ext = 32'b0;  // Default case covers R-type and undefined codes
    endcase
end

endmodule