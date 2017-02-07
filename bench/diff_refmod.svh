/**
 * @brief Diff reference model.
 */
class diff_refmod #(int WIDTH = 32) extends uvm_component;
   typedef diff_refmod #(WIDTH) this_t;
   `uvm_component_param_utils(this_t)

   typedef valid_ready_source_tx #(WIDTH + 1) out_t;
   typedef valid_ready_source_tx #(WIDTH) in_t;

   localparam int MIN_IN = -(2**(WIDTH-1));
   localparam int MAX_IN = -MIN_IN-1;
   localparam int MIN_OUT = MIN_IN-MAX_IN;
   localparam int MAX_OUT = -MIN_OUT;

   uvm_put_port #(out_t) out;
   uvm_get_port #(in_t) in;

   in_t current, previous;
   out_t result;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      out = new("out", this);
      in = new("in", this);
   endfunction

   virtual function int diff(int cur, int prev);
      diff = cur - prev;
   endfunction

   virtual task run_phase(uvm_phase phase);
      previous = new;
      previous.data = 0;

      forever begin
         in.get(current);

         result = new;
         result.data = diff(current.data, previous.data);
         result.valid = 1'b1;
         previous = current;

         out.put(result);
      end
   endtask
endclass

