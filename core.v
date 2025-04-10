module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  input [31:0] data_in, // data_out da memoria
  output reg [31:0] data_out, // data_in da memoria
  output reg [31:0] address, // endereço passado para a memoria
  output reg we // write enable
);

//wires output of control_unit
wire wire_pcwrite, wire_adrsource, wire_memwrite, wire_irwrite, wire_regwrite;
wire [1:0] wire_imm_source, wire_alu_source_a, wire_alu_source_b, wire_resultsource;
wire [2:0] wire_alu_control;

//wires de entrada e saida da memoria
wire [31:0] wire_adress; //input mem
wire [31:0] wire_write_data; //input mem
wire wire_write_enable; //input mem
wire [31:0] wire_read_data_mem; //output mem

//wires input of control_unit
wire wire_funct7_bit5, wire_zero;
wire [2:0] wire_funct3;
wire [6:0] wire_opcode;

//wires da instruction que vao para o register file
wire [4:0] wire_rs1, wire_rs2, wire_rd; //input of register file
wire [31:7] wire_extend_input;
wire [31:0] wire_read_data1, wire_read_data2; //output of register file

//wires na regiao dos multiplexadores e alu
wire [31:0] wire_imm_extend;
wire [31:0] wire_alu_source_a_out, wire_alu_source_b_out;
wire [31:0] wire_alu_result;
wire [31:0] wire_alu_out;
wire [31:0] wire_result;
wire [31:0] wire_pc_next;

//assigning the wires of the control unit
assign wire_funct7_bit5 = instruction[30]; //verifica se a instrução é sub
assign wire_funct3 = instruction[14:12]; 
assign wire_opcode = instruction[6:0];

//assigning the wires of the register file
assign wire_rs1 = instruction[19:15];
assign wire_rs2 = instruction[24:20];
assign wire_rd = instruction[11:7];

//assigning the wires of the extend
assign wire_extend_input = instruction[31:7];

//other assigns
assign wire_pc_next = wire_result;
assign wire_write_data = wire_read_data2;


//criando os registradores
reg  [31:0] pc, old_pc, instruction, data_mem, alu_out;

//                            INSTANCIANDO MODULOS

//multiplexer to select the next memory address
multiplexer_2_inputs mux_pc(
  .in0(pc),
  .in1(wire_result),
  .control(wire_adrsource),
  .out(wire_adress)
);

//instanciando a control unit
control_unit ctr_unit(
  //inputs
  .reset(resetn),
  .clk(clk),
  .func7_bit5(wire_funct7_bit5),
  .funct3(wire_funct3),
  .opcode(wire_opcode),
  .zero(wire_zero),

  //outputs
  .pcwrite(wire_pcwrite),
  .adrsource(wire_adrsource),
  .memwrite(wire_memwrite),
  .irwrite(wire_irwrite),
  .regwrite(wire_regwrite),
  .imm_source(wire_imm_source),
  .alu_source_a(wire_alu_source_a),
  .alu_source_b(wire_alu_source_b),
  .alu_control(wire_alu_control),
  .resultsource(wire_resultsource)
);

//instanciando o register file
register_file reg_file(
  //inputs
  .clk(clk),
  .a1(wire_rs1),
  .a2(wire_rs2),
  .a3(wire_rd),
  .wd3(wire_result),
  .we(wire_regwrite),
  //outputs
  .read_data1(wire_read_data1),
  .read_data2(wire_read_data2)
);

//instanciando o extend
extend extend(
  .instr(wire_extend_input),
  .imm_src(wire_imm_source),
  .imm_ext(wire_imm_extend)
);

//instanciando o multiplexer para selecionar a srcA da ALU
multiplexer_3_inputs mux_alu_src_a(
  .in0(pc),
  .in1(old_pc),
  .in2(wire_read_data1),
  .control(wire_alu_source_a),
  .out(wire_alu_source_a_out)
);

//instanciando o multiplexer para selecionar a srcB da ALU
multiplexer_3_inputs mux_alu_src_b(
  .in0(wire_read_data2),
  .in1(wire_imm_extend),
  .in2(32'h00000004),
  .control(wire_alu_source_b),
  .out(wire_alu_source_b_out)
);

//instanciando a ALU
alu alu(
  .alu_control(wire_alu_control),
  .source1(wire_alu_source_a_out),
  .source2(wire_alu_source_b_out),
  .result(wire_alu_result),
  .carry_out(),
  .zero(wire_zero)
);

//instanciando o multiplexer para selecionar de 3 inputs para selecionar o resultado
multiplexer_3_inputs mux_result(
  .in0(alu_out),
  .in1(data_mem),
  .in2(32'h00000000),
  .control(wire_resultsource),
  .out(wire_result)
);

//always que reseta o PC
always @(posedge clk) begin
  if (resetn == 1'b0) begin
    pc = 32'h00000000;
  end
end

always @(posedge clk) begin

  if (wire_pcwrite == 1'b1) begin
    pc = wire_pc_next;
  end

  address = wire_adress;
  data_out = wire_write_data;
  we = wire_memwrite;
  data_mem = data_in;

  if (wire_irwrite == 1'b1) begin
    old_pc = pc;
    instruction = data_in;
  end


  alu_out = wire_alu_result;

end

endmodule
