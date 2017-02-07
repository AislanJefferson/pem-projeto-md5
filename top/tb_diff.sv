module top;
  import uvm_pkg::*;
  
  localparam int INPUT_WIDTH = 4;

  typedef virtual valid_ready_if #(INPUT_WIDTH) input_vif_type;
  typedef virtual valid_ready_if #(INPUT_WIDTH + 1) output_vif_type;

  logic clk;
  logic reset;

  valid_ready_if #(.DATA_WIDTH(INPUT_WIDTH)) input_if(.clk(clk), .reset(reset));
  valid_ready_if #(.DATA_WIDTH(INPUT_WIDTH + 1)) output_if(.clk(clk), .reset(reset));
  diff #(.INPUT_WIDTH(INPUT_WIDTH)) dut(.out(output_if), .in(input_if));
  sink dut_sink(.in(output_if));

  initial begin
    uvm_config_db #(input_vif_type)::set(
      null, "uvm_test_top.env.source_agent.*",
      "vif", input_if);
    uvm_config_db #(output_vif_type)::set(
      null, "uvm_test_top.env.sink_agent.*",
      "vif", output_if);
    run_test();
  end
  
  
  initial begin
    clk = 1'b0;
    reset = 1'b1;
    #5 clk = 1'b1;
    reset <= 1'b0;
    forever #5 clk = !clk;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
endmodule
