VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

tmds_encoder: src/Video_Driver/tmds_encoder.sv tb/tb_tmds_encoder.sv
	$(VERILATE) $(VERILATE_FLAGS) --top-module tb_tmds_encoder $^ 
	cp obj_dir/Vtb_tmds_encoder .

clean:
	rm -rf obj_dir
	rm -f Vtb_tmds_encoder
	rm -f waveform.fst