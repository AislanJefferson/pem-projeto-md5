class bvm_comparator #( type T = int ) extends uvm_scoreboard;

  typedef bvm_comparator #(T) this_type;
  `uvm_component_param_utils(this_type)

  const static string type_name = "bvm_comparator #(T)";

  uvm_put_imp #(T, this_type) from_refmod;
  uvm_analysis_imp #(T, this_type) from_dut;

  typedef uvm_built_in_converter #( T ) convert; 

  int m_matches, m_mismatches;
  T exp;
  bit free;
  event compared;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    from_refmod = new("from_refmod", this);
    from_dut = new("from_dut", this);
    m_matches = 0;
    m_mismatches = 0;
    exp = new("exp");
    free = 1;
  endfunction

  virtual function string get_type_name();
    return type_name;
  endfunction

  virtual task put(T t);
    uvm_report_info("Comparator gets from refmod",
                    $sformatf("{%s}.",t.convert2string()), UVM_HIGH);
    if(!free) begin
       uvm_report_warning("Comparator blocking refmod",
                           $sformatf("refmod transaction {%s} must wait for {%s} to get compared.",
                                     t.convert2string(),
                                     exp.convert2string()));
       @compared;
    end
    exp.copy(t);
    free = 0;
  endtask

  virtual function bit try_put(T t);
    if(free) begin
      exp.copy(t);
      free = 0;
      return 1;
    end
    else return 0;
  endfunction

  virtual function bit can_put();
    return free;
  endfunction

  virtual function void write(T rec);

    if (free)
      uvm_report_error("Comparator no Expect", 
                        $sformatf("No refmod transaction to compare with DUT transaction {%s}.",
                                  rec.convert2string()));
    else if(!exp.compare(rec)) begin
      uvm_report_error("Comparator Mismatch",
                       $sformatf("DUT transaction {%s} differs from refmod {%s}",
                                  rec.convert2string(),
                                  exp.convert2string() ));
      m_mismatches++;
    end
    else begin
      uvm_report_info("Comparator Match",
                      $sformatf("{%s}", rec.convert2string()),
                      UVM_HIGH);
      m_matches++;
    end

    free = 1;
    -> compared;
  endfunction
 
endclass


