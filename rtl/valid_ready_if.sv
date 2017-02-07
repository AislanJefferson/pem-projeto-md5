interface valid_ready_if
  #(
    int DATA_WIDTH = 32
  )(
    input logic clk,
    input logic reset
  );

  logic[DATA_WIDTH-1:0] data;
  logic valid;
  logic ready;

  modport source(
    output data,
    output valid,
    input ready,
    input clk,
    input reset
  );

  modport sink(
    input data,
    input valid,
    output ready,
    input clk,
    input reset
  );

  modport monitor(
    input data,
    input valid,
    input ready,
    input clk,
    input reset
  );
endinterface

