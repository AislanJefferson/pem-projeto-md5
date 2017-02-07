class valid_ready_sink_uniform_tx #(int DATA_WIDTH = 32) extends
  valid_ready_sink_tx #(DATA_WIDTH);

  const static string type_name = "valid_ready_sink_uniform_tx #(DATA_WIDTH)";

  // knobs
  int unsigned wait_valid_prob = 50; // percentage
  int unsigned max_delay_ready = 10;
  int unsigned min_delay_ready = 0;
  int unsigned max_timeout = 20;
  int unsigned min_timeout = 0;

  constraint wait_valid_dist {
    wait_valid dist {1'b0 := (100 - wait_valid_prob), 1'b1 := wait_valid_prob};
  }

  constraint reasonable_timeout {
    timeout >= delay_ready;
  }

  constraint delay_ready_dist {
    delay_ready inside {[min_delay_ready : max_delay_ready]};
  }
  
  constraint timeout_dist {
    timeout inside {[min_timeout : max_timeout]};
  }

  `uvm_object_param_utils_begin(valid_ready_sink_uniform_tx #(DATA_WIDTH))
    `uvm_field_int(wait_valid_prob, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(max_delay_ready, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(min_delay_ready, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(max_timeout, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(min_timeout, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = type_name);
    super.new(name);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction
endclass: valid_ready_sink_uniform_tx


class valid_ready_sink_simple_seq #(int DATA_WIDTH = 32) extends
  uvm_sequence #(valid_ready_sink_uniform_tx #(DATA_WIDTH));

  typedef valid_ready_sink_uniform_tx #(DATA_WIDTH) transaction_type;

  const static string type_name = "valid_ready_sink_simple_seq #(DATA_WIDTH)";

  rand int unsigned length;

  int unsigned wait_valid_prob = 50; // percentage
  int unsigned max_delay_ready = 10;
  int unsigned min_delay_ready = 0;
  int unsigned max_timeout = 20;
  int unsigned min_timeout = 0;

  int unsigned max_length = 1000;
  int unsigned min_length = 0;

  constraint length_distribution {
    length inside {[min_length : max_length]};
  }

  `uvm_object_param_utils_begin(valid_ready_sink_simple_seq #(DATA_WIDTH))
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(wait_valid_prob, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_delay_ready, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(min_delay_ready, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_timeout, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(min_timeout, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(min_length, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end

  function new(string name = type_name);
    super.new(name);
  endfunction

  virtual task body();
    repeat (length) begin
      req = transaction_type::type_id::create("req");
      start_item(req);
      req.wait_valid_prob = wait_valid_prob;
      req.max_delay_ready = max_delay_ready;
      req.min_delay_ready = min_delay_ready;
      req.max_timeout = max_timeout;
      req.min_timeout = min_timeout;
      assert( req.randomize() );
      finish_item(req);
    end
  endtask: body
endclass: valid_ready_sink_simple_seq

