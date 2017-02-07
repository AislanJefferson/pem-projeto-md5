class valid_ready_sink_tx #(int DATA_WIDTH = 32) extends uvm_sequence_item;
  const static string type_name = "valid_ready_sink_tx #(DATA_WIDTH)";

  rand bit wait_valid; // Whether to wait for valid.
  rand int unsigned delay_ready; // Delay before raising ready.
  rand int unsigned timeout; // Transaction timeout.

  // Response
  bit valid;
  bit[DATA_WIDTH-1:0] data;
  int unsigned delay_total; // Total transaction delay.

  `uvm_object_param_utils_begin(valid_ready_sink_tx #(DATA_WIDTH))
    `uvm_field_int(wait_valid, UVM_DEFAULT)
    `uvm_field_int(delay_ready, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(timeout, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(valid, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_int(delay_total, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end

  function new(string name = type_name);
    super.new(name);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction

  function string convert2string();
    return
      $sformatf("{wait_valid = %b, delay_ready = %0d, timeout = %0d, valid = %b, data = %h, delay_total = %0d}",
        wait_valid, delay_ready, timeout, valid, data, delay_total);
  endfunction
endclass

