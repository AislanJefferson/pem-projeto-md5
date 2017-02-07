class valid_ready_source_driver #(int DATA_WIDTH = 32) extends
  uvm_driver #(valid_ready_source_tx #(DATA_WIDTH));
  const static string type_name = "valid_ready_source_driver #(DATA_WIDTH)";
  `uvm_component_param_utils(valid_ready_source_driver #(DATA_WIDTH))

  typedef valid_ready_source_tx #(DATA_WIDTH) transaction_type;
  typedef virtual valid_ready_if #(DATA_WIDTH) vif_type;

  vif_type vif;

  transaction_type tx;
  bit item_done;

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
        vif.valid <= 1'b0;
        vif.data <= '0;
        item_done = (tx != null); // abort
      end
      else if (tx) begin
        if (tx.delay_total == tx.delay_valid) begin
          assert( !vif.valid ) else begin
            `uvm_error("DEBUG", "failed precondition. valid != 1'b0.")
          end

          vif.valid <= tx.valid;
          vif.data <= tx.valid ? tx.data : 'x;
        end
        else if (tx.delay_total > tx.delay_valid) begin
          assert( !tx.valid || vif.valid ) else begin
            `uvm_error("DEBUG", "failed precondition. valid != 1'b1.")
          end

          item_done = !tx.valid || vif.ready;
          // see below for signals update if item_done.
        end
        else begin
          vif.valid <= 1'b0;
          vif.data <= 'x;
        end
      end
      else begin
        vif.valid <= 1'b0;
        vif.data <= 'x;
      end

      if (item_done) begin
        seq_item_port.item_done();
      end
      if ((item_done || !tx) && !reset) begin
        seq_item_port.try_next_item(tx);
        if (tx &&
            (tx.delay_total >= tx.delay_valid)) begin
          vif.valid <= tx.valid;
          vif.data <= tx.valid ? tx.data : 'x;
        end
        else begin
          vif.valid <= 1'b0;
          vif.data <= 'x;
        end
      end
    end
  endtask
endclass

