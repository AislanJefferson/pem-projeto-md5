class valid_ready_sink_agent #(int DATA_WIDTH = 32) extends uvm_agent;
  const static string type_name = "valid_ready_sink_agent #(DATA_WIDTH)";
  `uvm_component_param_utils(valid_ready_sink_agent #(DATA_WIDTH))

  typedef valid_ready_sink_tx #(DATA_WIDTH) driver_transaction_type;
  typedef uvm_sequencer #(driver_transaction_type) sequencer_type;
  typedef valid_ready_sink_driver #(DATA_WIDTH) driver_type;
  typedef valid_ready_source_monitor #(DATA_WIDTH) monitor_type;
  typedef monitor_type::transaction_type transaction_type;

  uvm_analysis_port #(transaction_type) ap;

  sequencer_type sequencer;
  driver_type driver;
  monitor_type monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    sequencer = sequencer_type::type_id::create("sequencer", this);
    driver = driver_type::type_id::create("driver", this);
    monitor = monitor_type::type_id::create("monitor", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap.connect(ap);
  endfunction
endclass

