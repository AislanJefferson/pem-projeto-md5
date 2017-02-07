class valid_ready_source_monitor #(int DATA_WIDTH = 32) extends uvm_monitor;
  const static string type_name = "valid_ready_source_monitor #(DATA_WIDTH)";
  `uvm_component_param_utils(valid_ready_source_monitor #(DATA_WIDTH))

  typedef valid_ready_source_tx #(DATA_WIDTH) transaction_type;
  typedef virtual valid_ready_if #(DATA_WIDTH) vif_type;

  uvm_analysis_port #(transaction_type) ap;

  vif_type vif;

  transaction_type tx;

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
    ap = new("ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (vif.reset) begin
        tx = null; // abort
      end
      else begin
        if (!tx) begin
          tx = transaction_type::type_id::create("tx");
        end

        if (!vif.valid) begin
          ++tx.delay_valid;
          ++tx.delay_total;
        end
        else if (!vif.ready) begin
          ++tx.delay_total;
        end
        else begin
          tx.valid = 1'b1;
          tx.data = vif.data;
          ap.write(tx);
          tx = null;
        end
      end
    end
  endtask
endclass

