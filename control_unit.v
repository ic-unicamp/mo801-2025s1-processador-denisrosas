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
    localparam FETCH = 3'b000;
    localparam DECODE = 3'b001;
    localparam EXECUTE_L = 3'b010;
    localparam EXECUTE_S = 3'b011;
    localparam EXECUTE_B = 3'b010;
    localparam MEMORY_ACCESS = 3'b100;
    localparam WRITEBACK = 3'b101;

//    state_t state, next_state;

    // Definição de opcodes e funct3
    localparam OPCODE_LTYPE = 7'b0000011;
    localparam OPCODE_STYPE = 7'b0100011;
    localparam OPCODE_RTYPE = 7'b0110011;
    localparam OPCODE_BTYPE = 7'b1100011;

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
          state = FETCH;
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
            FETCH: begin
                irwrite = 1;
                next_state = DECODE;
            end

            DECODE: begin
                case (opcode)
                    OPCODE_LTYPE: begin
                                  imm_source = 2'b00;
                                  next_state = EXECUTE_L;
                    end
                    OPCODE_STYPE: begin
                                  imm_source = 2'b01;
                                  next_state = EXECUTE_S;
                    end
                    // OPCODE_RTYPE: next_state = EXECUTE_R;
                    // OPCODE_BTYPE: next_state = EXECUTE_B;
                    default: next_state = FETCH;
                endcase
            end

            EXECUTE_L: begin
                alu_source_a = 2'b00; //read from rd1
                alu_source_a = 2'b01; //read from extend
                alu_control  = 3'b010; //srca + srcb
                next_state = MEMORY_ACCESS;
            end

            EXECUTE_S: begin
                alu_source_a = 2'b00; //read from rd1
                alu_source_a = 2'b01; //read from extend
                alu_control  = 3'b010; //srca + srcb
                next_state = MEMORY_ACCESS;
            end

            MEMORY_ACCESS: begin
                case (opcode)
                    OPCODE_LTYPE: begin
                                  adrsource = 1;
                                  next_state = WRITEBACK;
                    end
                    OPCODE_STYPE: next_state = EXECUTE_S;
                default: next_state = FETCH;
                endcase
            end

            WRITEBACK: begin
                regwrite = 1'b1;
                resultsource = 2'b01;
                next_state = FETCH;
            end

            default: next_state = FETCH;
        endcase
    end
endmodule
