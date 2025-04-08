module tb();

reg clk, resetn;
reg  [31:0] pc, old_pc, data_from_mem, read_data_a, read_data_b, alu_out;
wire wire_we;

//wires of core and memory
wire [31:0] address, data_out, data_in;

//wires to be used in control_unit
wire wire_funct7_bit5;
wire [2:0] wire_funct3;
wire [6:0] wire_opcode;
wire [4:0] wire_rs1, wire_rs2, wire_rd;
wire wire_pcwrite, wire_adrsource, wire_irwrite, wire_regwrite;
wire [1:0] wire_imm_source, wire_alu_source_a, wire_alu_source_b, wire_resultsource;
wire [2:0] wire_alu_control;

// Instanciando os módulos
core dut(
  .clk(clk),
  .resetn(resetn),
  .data_in(data_in),
  .data_out(data_out),
  .address(address),
  .we(wire_we)
);

memory m(
  .address(address),
  .data_in(data_out),
  .data_out(data_in), //saida da memoria / entrada do register file
  .we(wire_we) 
);

//connecting the wires with data_in
assign wire_funct7_bit5 = data_in[30]; //verifica se a instrução é sub
assign wire_funct3 = data_in[14:12]; 
assign wire_opcode = data_in[6:0];
assign wire_rs1 = data_in[19:15];
assign wire_rs2 = data_in[24:20];
assign wire_rd = data_in[11:7];

control_unit cu(
  //inputs
  .reset(resetn),
  .clk(clk),
  .func7_bit5(wire_funct7_bit5),
  .funct3(wire_funct3),
  .opcode(wire_opcode),

  //outputs
  .adrsource(wire_adrsource),
  .pcwrite(wire_pcwrite),
  .memwrite(wire_we),
  .irwrite(wire_irwrite),
  .regwrite(wire_regwrite),
  .imm_source(wire_imm_source),
  .alu_source_a(wire_alu_source_a),
  .alu_source_b(wire_alu_source_b),
  .alu_control(wire_alu_control),
  .resultsource(wire_resultsource)
);

// register_file rf(
//   .clk(clk),
//   .a1(wire_rs1),
//   .a2(wire_rs2),
//   .write_data(wire_rd),
//   .data_in(data_in),
//   .we(wire_regwrite),
//   .read_data1(read_data_a),
//   .read_data2(read_data_b)
// );

// Clock generator
always #1 clk = (clk===1'b0);

// Inicia a simulação e executa até 2000 unidades de tempo após o reset
initial begin
  $dumpfile("saida.vcd");
  $dumpvars(0, tb);
  resetn = 1'b0;
  #11 resetn = 1'b1;
  $display("*** Starting simulation. ***");
  #4000 $finish;
end

// Verifica se o endereço atingiu 4092 (0xFFC) e encerra a simulação
always @(posedge clk) begin
  if (address == 'hFFC) begin
    $display("Address reached 4092 (0xFFC). Stopping simulation.");
    $finish;
  end
  else if (address[11] == 1) //accessing position >= 2048 which is the memory, not an instruction
    if (wire_we == 1)
      $display("Write: M[0x%h] <- 0x%h", address, data_out);
    else
      $display("Read: M[0x%h] -> 0x%h", address, data_in);
end

endmodule
