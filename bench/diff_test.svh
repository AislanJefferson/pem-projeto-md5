class diff_test extends uvm_test;
  `uvm_component_utils(diff_test)

  localparam int INPUT_WIDTH = 4;
  
  typedef valid_ready_source_simple_seq #(INPUT_WIDTH) source_seq_type;
  typedef valid_ready_sink_simple_seq #(INPUT_WIDTH + 1) sink_seq_type;

  diff_env env;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = diff_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    source_seq_type source_seq;
    sink_seq_type sink_seq;
    source_seq = source_seq_type::type_id::create("source_seq");
    sink_seq = sink_seq_type::type_id::create("sink_seq");

    assert( source_seq.randomize() );
    assert( sink_seq.randomize() );
    
    phase.raise_objection(this);
    fork
      source_seq.start(env.source_agent.sequencer);
      sink_seq.start(env.sink_agent.sequencer);
    join_any
    phase.drop_objection(this);
  endtask
endclass
