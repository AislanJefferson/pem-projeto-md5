class diff_env extends uvm_env;
  `uvm_component_utils(diff_env)

  localparam INPUT_WIDTH = 4;

  typedef valid_ready_source_agent #(INPUT_WIDTH) source_agent_type;
  typedef valid_ready_sink_agent #(INPUT_WIDTH + 1) sink_agent_type;
  typedef valid_ready_source_tx #(INPUT_WIDTH) source_transaction_type;
  typedef valid_ready_source_tx #(INPUT_WIDTH + 1) sink_transaction_type;
  typedef diff_refmod #(INPUT_WIDTH) refmod_type;
  typedef bvm_comparator #(sink_transaction_type) comparator_type;

  source_agent_type source_agent;
  sink_agent_type sink_agent;
  
  uvm_tlm_analysis_fifo #(source_transaction_type) source_refmod;
  refmod_type refmod;
  comparator_type comparator;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    source_agent = source_agent_type::type_id::create("source_agent", this);
    sink_agent = sink_agent_type::type_id::create("sink_agent", this);
    source_refmod = new("source_refmod", this);
    refmod = refmod_type::type_id::create("refmod", this);
    comparator = comparator_type::type_id::create("comparator", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    source_agent.ap.connect(source_refmod.analysis_export);
    refmod.in.connect(source_refmod.get_export);
    refmod.out.connect(comparator.from_refmod);
    sink_agent.ap.connect(comparator.from_dut);
  endfunction
endclass
