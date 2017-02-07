class valid_ready_sink_driver #(int DATA_WIDTH = 32) extends
  uvm_driver #(valid_ready_sink_tx #(DATA_WIDTH));

  const static string type_name = "valid_ready_sink_driver #(DATA_WIDTH)";
  `uvm_component_param_utils(valid_ready_sink_driver #(DATA_WIDTH))

  typedef valid_ready_sink_tx #(DATA_WIDTH) transaction_type;
  typedef virtual valid_ready_if #(DATA_WIDTH) vif_type;

  vif_type vif;

  transaction_type tx;
  bit item_done;
  int unsigned counter_to_ready;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(vif_type)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "virtual interface not set")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    logic reset;

    forever begin
      @(posedge vif.clk);

      if (tx) ++tx.delay_total;

      // default
      item_done = 1'b0;

      reset = vif.reset;

      if (vif.reset) begin
        vif.ready <= 1'b0;
        item_done = (tx != null); // abort
      end
      else if (tx) begin
        if (tx.delay_total > tx.timeout) begin
          // abort
          vif.ready <= 1'b0;
          tx.valid = vif.valid;
          tx.data = vif.data;
          item_done = 1'b1;
        end
        else if (!tx.wait_valid || vif.valid) begin
          if (counter_to_ready == tx.delay_ready) begin
            assert( !vif.ready ) else begin
              `uvm_error("DEBUG", "failed precondition. ready != 1'b0.")
            end

            vif.ready <= 1'b1;
          end
          else if (counter_to_ready > tx.delay_ready) begin
            assert( vif.ready ) else begin
              `uvm_error("DEBUG", "failed precondition. ready != 1'b1.")
            end

            if (vif.valid) begin
              vif.ready <= 1'b0;
              tx.valid = 1'b1;
              tx.data = vif.data;
              item_done = 1'b1;
            end
          end

          ++counter_to_ready;
        end
      end

      if (item_done) begin
        seq_item_port.item_done();
      end
      if ((item_done || !tx) && !reset) begin
        seq_item_port.try_next_item(tx);
        if (tx) begin
          counter_to_ready = tx.wait_valid ? 0 : tx.delay_total;
          if (!tx.wait_valid) begin
            if (counter_to_ready >= tx.delay_ready) begin
              vif.ready <= 1'b1;
            end
            ++counter_to_ready;
          end
        end
      end
    end
  endtask
endclass

