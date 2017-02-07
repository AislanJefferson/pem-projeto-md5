class diff_sink_test extends uvm_test;
  `uvm_component_utils(diff_sink_test)

  localparam int INPUT_WIDTH = 4;
  
  typedef valid_ready_source_simple_seq #(INPUT_WIDTH) source_seq_type;
  
  diff_env env;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_int::set(this, "env.sink_agent", "is_active", UVM_PASSIVE);
    env = diff_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    source_seq_type source_seq;
    source_seq = source_seq_type::type_id::create("source_seq");

    assert( source_seq.randomize() );
    source_seq.length = 10;
    
    phase.raise_objection(this);
    source_seq.start(env.source_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass
