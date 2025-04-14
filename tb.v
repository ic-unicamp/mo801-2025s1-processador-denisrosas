module tb();

reg clk, resetn;
wire we;
wire [31:0] address, data_out, data_in;

core dut(
  .clk(clk),
  .resetn(resetn),
  .address(address),
  .data_out(data_out),
  .data_in(data_in),
  .we(we)
);

memory m(
  .clk(clk),
  .address(address),
  .data_in(data_out),
  .data_out(data_in),
  .we(we) 
);

// Clock generator
always #1 clk = (clk===1'b0);

// Inicia a simulação e executa até 2000 unidades de tempo após o reset
initial begin
  $dumpfile("saida.vcd");
  $dumpvars(0, tb);
  resetn = 1'b0;
  #11 resetn = 1'b1;
  $display("*** Starting simulation. ***");
  //$monitor("Time: %0t | Address: 0x%h | Data Out: 0x%h | Data In: 0x%h | WE: %b", $time, address, data_out, data_in, we);
  #4000 $finish;
end

// Verifica se o endereço atingiu 4092 (0xFFC) e encerra a simulação
always @(negedge clk) begin
  if (address == 'hFFC) begin
    $display("Address reached 4092 (0xFFC). Stopping simulation.");
    $finish;
  end
end

always @(negedge clk) begin
  if (address[11] == 1)
    if (we == 1)
      $display("=== M[0x%h] <- 0x%h", address, data_out);
    // else
    //   $display("=== M[0x%h] -> 0x%h", address, data_in);
end
endmodule
