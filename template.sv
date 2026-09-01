// Basic module syntax with port list
module <name> ([port_list]);
	// Variable declarations (wires, regs, integers, etc.)
	// Dataflow statements (assign, always, initial blocks)
	// Function and task definitions
	// Sub-module instantiations
endmodule

// A module can have an empty portlist (typically for testbenches)
module testbench_top;
	// Testbench logic without external ports
endmodule