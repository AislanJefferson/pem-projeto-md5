class valid_ready_source_uniform_tx #(int DATA_WIDTH = 32) extends
  valid_ready_source_tx #(DATA_WIDTH);

  const static string type_name = "valid_ready_source_uniform_tx #(DATA_WIDTH)";

  // knobs
  int unsigned valid_prob = 50; // percentage
  int unsigned max_delay_valid = 10;
  int unsigned min_delay_valid = 0;

  constraint valid_dist {
    valid dist {1'b0 := (100 - valid_prob), 1'b1 := valid_prob};
  }

  constraint delay_valid_dist {
    delay_valid inside {[min_delay_valid : max_delay_valid]};
  }
  
  `uvm_object_param_utils_begin(valid_ready_source_uniform_tx #(DATA_WIDTH))
    `uvm_field_int(valid_prob, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(max_delay_valid, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(min_delay_valid, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = type_name);
    super.new(name);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction
endclass: valid_ready_source_uniform_tx


class valid_ready_source_simple_seq #(int DATA_WIDTH = 32) extends
  uvm_sequence #(valid_ready_source_uniform_tx #(DATA_WIDTH));

  typedef valid_ready_source_uniform_tx #(DATA_WIDTH) transaction_type;

  const static string type_name = "valid_ready_source_simple_seq #(DATA_WIDTH)";

  rand int unsigned length;

  int unsigned valid_prob = 50; // percentage
  int unsigned max_delay_valid = 10;
  int unsigned min_delay_valid = 0;

  int unsigned max_length = 1000;
  int unsigned min_length = 0;

  constraint length_distribution {
    length inside {[min_length : max_length]};
  }

  `uvm_object_param_utils_begin(valid_ready_source_simple_seq #(DATA_WIDTH))
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(valid_prob, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_delay_valid, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(min_delay_valid, UVM_DEFAULT | UVM_DEC)
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
      req.valid_prob = valid_prob;
      req.max_delay_valid = max_delay_valid;
      req.min_delay_valid = min_delay_valid;
      assert( req.randomize() );
      finish_item(req);
    end
  endtask: body
endclass: valid_ready_source_simple_seq

