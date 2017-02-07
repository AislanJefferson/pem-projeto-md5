/** @brief Differentiator.
 *
 * Receives a sequence of signed integers via an AMBA AXI interface
 * and outputs its discrete derivative via another AMBA AXI interface.
 *
 * Reset is synchronous. After reset, behaves as if last input was 0.
 */
module diff #(INPUT_WIDTH = 16) (
  valid_ready_if.source out,
  valid_ready_if.sink in);

  enum logic {GET, PUT} state;

  logic signed[INPUT_WIDTH-1:0] previous;
  logic signed[INPUT_WIDTH:0] result;

  always_comb
    result = in.data - previous;

  always_comb begin
    out.valid = (state == PUT);
    in.ready = (state == GET);
  end

  always_ff @(posedge out.clk)
  if (out.reset) begin
    state <= GET;
    previous <= '0;
    out.data <= '0;
  end
  else case (state)
    GET:
    if (in.valid) begin
      state <= PUT;
      previous <= in.data;
      out.data <= result;
    end
    PUT:
    if (out.ready)
      state <= GET;
  endcase
endmodule

