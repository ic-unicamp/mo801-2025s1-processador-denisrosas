module control_unit(
    input reset,
    input clk,
    input func7_bit5,
    input [2:0] funct3,
    input [6:0] opcode,
    input zero,

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

    reg [2:0] state, next_state;

    // Estados da máquina de estados
    localparam STATE_RESET = 3'b000;
    localparam FETCH = 3'b001;
    localparam DECODE = 3'b010;
    localparam EXECUTE = 3'b011;
    localparam MEMORY_ACCESS = 3'b100;
    localparam WRITEBACK = 3'b101;
    localparam PC_PLUS_4 = 3'b110;

    // Definição de opcodes e funct3
    localparam OPCODE_ITYPE = 7'b0010011;
    localparam OPCODE_LTYPE = 7'b0000011;
    localparam OPCODE_STYPE = 7'b0100011;
    localparam OPCODE_RTYPE = 7'b0110011;
    localparam OPCODE_BTYPE = 7'b1100011;

    //imm source types
    localparam IMMSRC_ITYPE = 2'b00;
    localparam IMMSRC_STYPE = 2'b01;
    localparam IMMSRC_BTYPE = 2'b10;

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
    localparam RESSRC_ALUOUT = 2'b10;
    localparam RESSRC_MEM = 2'b01;
    localparam RESSRC_PC4 = 2'b00;
    localparam RESSRC_ZERO = 2'b11;

    // Funct3 valores para instruções R-type
    localparam FUNCT3_ADD_SUB = 3'b000;
    localparam FUNCT3_AND = 3'b111;
    localparam FUNCT3_OR = 3'b110;
    localparam FUNCT3_SLT = 3'b010;

    // Funct3 valores para instruções B-type
    localparam FUNCT3_BEQ = 3'b000;

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
            STATE_RESET: begin
                next_state = FETCH;
            end

            FETCH: begin
                adrsource = 0;
                next_state = DECODE;
            end

            //mais um ciclo pra dar tempo de armazenar a instrucao no 
            DECODE: begin
                irwrite = 1;
                next_state = EXECUTE;
            end

            EXECUTE: begin
                case (opcode)
                    OPCODE_ITYPE: begin
                                  imm_source = IMMSRC_ITYPE;
                                  alu_source_a = ALUSRCA_RD1;
                                  alu_source_b = ALUSRCB_IMMEXT;
                                  alu_control = 3'b000; //add
                                  next_state = WRITEBACK;
                    end
                    default: next_state = FETCH;
                endcase
            end

            // MEMORY_ACCESS: begin
            //     case (opcode)
            //         OPCODE_LTYPE: begin
            //                       adrsource = 1;
            //                       next_state = WRITEBACK;
            //         end
            //         OPCODE_STYPE: next_state = EXECUTE_S;
            //     default: next_state = FETCH;
            //     endcase
            // end

            WRITEBACK: begin
                regwrite = 1'b1;
                resultsource = RESSRC_ALUOUT;
                next_state = PC_PLUS_4;
            end

            PC_PLUS_4: begin
                alu_source_a = ALUSRCA_PC;
                alu_source_b = ALUSRCB_4;
                alu_control = ALUCTRL_ADD;
                resultsource = RESSRC_PC4;
                pcwrite = 1'b1;
                next_state = FETCH;
            end

            default: next_state = FETCH;
        endcase
    end
endmodule
