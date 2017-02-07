class valid_ready_source_tx #(int DATA_WIDTH = 32) extends uvm_sequence_item;
  const static string type_name = "valid_ready_source_tx #(DATA_WIDTH)";

  rand bit valid; // If 0, transaction is just a delay.
  rand bit[DATA_WIDTH-1:0] data;
  rand int unsigned delay_valid; // Delay before raising valid.

  // Response
  int unsigned delay_total; // Total transaction delay.

  `uvm_object_param_utils_begin(valid_ready_source_tx #(DATA_WIDTH))
    `uvm_field_int(valid, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_int(delay_valid, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(delay_total, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = type_name);
    super.new(name);
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction

  function string convert2string();
    return
      $sformatf("{valid = %b, data = %h, delay_valid = %0d, delay_total = %0d}",
        valid, data, delay_valid, delay_total);
  endfunction
endclass

