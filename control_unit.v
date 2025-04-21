module control_unit(
    input reset,
    input clk,
    input func7_bit5,
    input [2:0] funct3,
    input [6:0] opcode,
    input zero,
    input negative,

    output reg pcwrite,
    output reg adrsource,
    output reg memwrite,
    output reg irwrite,
    output reg regwrite,
    output reg [1:0] imm_source,
    output reg [1:0] alu_source_a,
    output reg [1:0] alu_source_b,
    output reg [2:0] alu_control,
    output reg [1:0] resultsource
);

    reg [3:0] state, next_state;

    // Estados da máquina de estados
    localparam STATE_RESET = 0; //3'b0000;
    localparam FETCH = 1; //3'b0001;
    localparam DECODE =  2; //3'b0010;
    localparam EXECUTE =  3; //3'b0011;
    localparam MEMORY_ACCESS = 4; //3'b0100; 
    localparam WRITEBACK =  5; //3'b0101;
    localparam PC_PLUS_4 =  6; //3'b0110;
    localparam CALCULATE_BRANCH = 7; //3'b0111;
    localparam JUMP = 8; //3'b1000;

    // Definição de opcodes
    localparam INT_REG_IMM_SHIFT_INSTR = 7'b0010011;
    localparam MEMORY_LOAD_INSTR = 7'b0000011;
    localparam MEMORY_STORE_INSTR = 7'b0100011;
    localparam INT_REG_REG_INSTR = 7'b0110011;
    localparam BRANCH_INSTR = 7'b1100011;
    localparam JUMP_AND_LINK_INSTR = 7'b1101111;

    //imm source types
    localparam IMMSRC_ITYPE = 2'b00;
    localparam IMMSRC_STYPE = 2'b01;
    localparam IMMSRC_BTYPE = 2'b10;
    localparam IMMSRC_JTYPE = 2'b11;

    //alu A source
    localparam ALUSRCA_PC = 2'b00;
    localparam ALUSRCA_OLDPC = 2'b01;
    localparam ALUSRCA_RD1 = 2'b10;

    //alu B source
    localparam ALUSRCB_RD2 = 2'b00;
    localparam ALUSRCB_IMMEXT = 2'b01;
    localparam ALUSRCB_4 = 2'b10;

    // alu control
    localparam ALUCTRL_AND  = 3'b010;
    localparam ALUCTRL_OR   = 3'b011;
    localparam ALUCTRL_ADD  = 3'b000;
    localparam ALUCTRL_SUB  = 3'b001;
    localparam ALUCTRL_SLT  = 3'b101;

    // Result source
    localparam RESSRC_ALUOUT = 2'b10; //from register
    localparam RESSRC_MEM = 2'b01; //from memory
    localparam RESSRC_ALURESULT = 2'b00;
    localparam RESSRC_ZERO = 2'b11;

    // Funct3 valores para instruções R-type
    localparam FUNCT3_ADD_SUB = 3'b000;
    localparam FUNCT3_AND = 3'b111;
    localparam FUNCT3_OR = 3'b110;
    localparam FUNCT3_SLT = 3'b010;

    // Funct3 valores para instruções I-type
    localparam FUNCT3_ADDI = 3'b000;
    localparam FUNCT3_SLTI = 3'b010;
    localparam FUNCT3_XORI = 3'b100;
    localparam FUNCT3_ORI = 3'b110;
    localparam FUNCT3_ANDI = 3'b111;

    // Funct3 valores para instruções B-type
    localparam FUNCT3_BEQ = 3'b000;
    localparam FUNCT3_BNE = 3'b001;
    localparam FUNCT3_BLT = 3'b100;
    localparam FUNCT3_BGE = 3'b101;
    localparam FUNCT3_BLTU = 3'b110;
    localparam FUNCT3_BGEU = 3'b111;

    // Transição de estados na borda de subida do clock
    always @(posedge clk) begin
        if(reset == 1'b0)
          state = STATE_RESET;
        else
          state = next_state;
    end

    // Máquina de estados
    always @(*) begin
        // Resetando todos os sinais de controle para evitar comportamento indefinido
        pcwrite = 0;
        adrsource = 0;
        memwrite = 0;
        irwrite = 0;
        resultsource = 2'b11;
        alu_control = 3'b000;
        alu_source_a = 2'b11;
        alu_source_b = 2'b11;
        imm_source = 2'b00;
        regwrite = 0;

        case (state)
            STATE_RESET: begin //000
                next_state = FETCH;
            end

            FETCH: begin //001
                adrsource = 0;
                next_state = DECODE;
            end

            DECODE: begin //010
                irwrite = 1;
                next_state = EXECUTE;
            end

            EXECUTE: begin //011
                case (opcode)
                    INT_REG_IMM_SHIFT_INSTR: begin //addi
                        case (funct3)
                            FUNCT3_ADDI: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b000; //add
                                  next_state = WRITEBACK;
                            end
                            FUNCT3_SLTI: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b101; //slt
                                  next_state = WRITEBACK;
                            end
                            FUNCT3_ORI: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b011; //or
                                  next_state = WRITEBACK;
                            end
                            FUNCT3_ANDI: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b010; //and
                                  next_state = WRITEBACK;
                            end
                            default: next_state = FETCH;
                        endcase
                    end
                    MEMORY_STORE_INSTR: begin
                                  imm_source = IMMSRC_STYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b000; //add
                                  next_state = MEMORY_ACCESS;
                    end
                    MEMORY_LOAD_INSTR: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b000; //add
                                  resultsource = RESSRC_ALURESULT;
                                  adrsource = 1'b1;
                                  next_state = WRITEBACK;
                    end
                    BRANCH_INSTR: begin
                        alu_source_a = ALUSRCA_RD1;
                        alu_source_b = ALUSRCB_RD2;
                        case (funct3)
                            FUNCT3_BEQ: begin
                                alu_control = ALUCTRL_SUB; //sub
                                if (zero) 
                                    next_state = CALCULATE_BRANCH;
                                else 
                                    next_state = PC_PLUS_4;
                            end
                            FUNCT3_BNE: begin
                                alu_control = ALUCTRL_SUB; //sub
                                if (!zero) 
                                    next_state = CALCULATE_BRANCH;
                                else 
                                    next_state = PC_PLUS_4;
                            end
                            FUNCT3_BLT: begin
                                alu_control = ALUCTRL_SUB; //sub
                                if (negative) 
                                    next_state = CALCULATE_BRANCH;
                                else 
                                    next_state = PC_PLUS_4;
                            end
                            FUNCT3_BGE: begin
                                alu_control = ALUCTRL_SUB; //sub
                                if (!negative) 
                                    next_state = CALCULATE_BRANCH;
                                else 
                                    next_state = PC_PLUS_4;
                            end
                            default: next_state = FETCH;
                        endcase
                    end
                    JUMP_AND_LINK_INSTR: begin
                        alu_source_a = ALUSRCA_OLDPC;
                        alu_source_b = ALUSRCB_4;
                        alu_control = ALUCTRL_ADD; //add
                        next_state = WRITEBACK;
                    end
                    INT_REG_REG_INSTR: begin
                        imm_source = IMMSRC_ITYPE;
                        alu_source_a = ALUSRCA_RD1;
                        alu_source_b = ALUSRCB_RD2;
                        case (funct3)
                            FUNCT3_ADD_SUB: begin
                                if (func7_bit5 == 1'b0) begin
                                    alu_control = ALUCTRL_ADD; //add
                                end else begin
                                    alu_control = ALUCTRL_SUB; //sub
                                end
                            end
                            FUNCT3_AND: begin
                                alu_control = ALUCTRL_AND; //and
                            end
                            FUNCT3_OR: begin
                                alu_control = ALUCTRL_OR; //or
                            end
                            FUNCT3_SLT: begin
                                alu_control = ALUCTRL_SLT; //slt
                            end
                            default: next_state = FETCH;
                        endcase
                        next_state = WRITEBACK;
                    end
                    BRANCH_INSTR: begin
                        alu_source_a = ALUSRCA_RD1; //calcu
                        alu_source_b = ALUSRCB_RD2;
                        case (funct3)
                            FUNCT3_BEQ: begin
                                alu_control = ALUCTRL_SUB; //sub
                                resultsource = RESSRC_ZERO;
                                if (zero) 
                                    next_state = CALCULATE_BRANCH;
                                else 
                                    next_state = PC_PLUS_4;
                            end
                            default: next_state = FETCH;
                        endcase
                    end
                    JUMP_AND_LINK_INSTR: begin
                        imm_source = IMMSRC_BTYPE;
                        alu_source_a = ALUSRCA_OLDPC;
                        alu_source_b = ALUSRCB_IMMEXT;
                        alu_control = ALUCTRL_ADD; //add
                        resultsource = RESSRC_ALURESULT;
                        pcwrite = 1'b1;
                        next_state = WRITEBACK;
                    end
                    default: next_state = FETCH;
                endcase
            end

            CALCULATE_BRANCH: begin //111
                imm_source = IMMSRC_BTYPE;
                alu_source_a = ALUSRCA_OLDPC;
                alu_source_b = ALUSRCB_IMMEXT;
                alu_control = ALUCTRL_ADD; //add
                resultsource = RESSRC_ALURESULT;
                pcwrite = 1'b1;
                next_state = FETCH;
            end

            MEMORY_ACCESS: begin //100
                case (opcode)
                    MEMORY_STORE_INSTR:
                        begin
                            resultsource = RESSRC_ALUOUT;
                            adrsource = 1'b1;
                            memwrite = 1'b1;
                            next_state = PC_PLUS_4;
                        end
                default: next_state = FETCH;
                endcase
            end

            WRITEBACK: begin //101
                case (opcode)
                    MEMORY_LOAD_INSTR: begin //lw
                        resultsource = RESSRC_MEM;
                        regwrite = 1'b1;
                        next_state = PC_PLUS_4;
                    end
                    INT_REG_IMM_SHIFT_INSTR: begin //addi, slti, andi, ori
                        resultsource = RESSRC_ALUOUT;
                        regwrite = 1'b1;
                        next_state = PC_PLUS_4;
                    end
                    INT_REG_REG_INSTR: begin //add, sub, and, or, slt
                        resultsource = RESSRC_ALUOUT;
                        regwrite = 1'b1;
                        next_state = PC_PLUS_4;
                    end
                    JUMP_AND_LINK_INSTR: begin //jal
                        resultsource = RESSRC_ALUOUT;
                        regwrite = 1'b1;
                        next_state = JUMP;
                    end
                    default: next_state = FETCH;
                endcase
            end

            PC_PLUS_4: begin
                alu_source_a = ALUSRCA_OLDPC;
                alu_source_b = ALUSRCB_4;
                alu_control = ALUCTRL_ADD;
                resultsource = RESSRC_ALURESULT;
                pcwrite = 1'b1;
                next_state = FETCH;
            end

            JUMP: begin
                imm_source = IMMSRC_JTYPE;
                alu_source_a = ALUSRCA_OLDPC;
                alu_source_b = ALUSRCB_IMMEXT;
                alu_control = ALUCTRL_ADD; 
                resultsource = RESSRC_ALURESULT;
                pcwrite = 1'b1;
                next_state = FETCH;
            end

            default: next_state = FETCH;
        endcase
    end
endmodule
