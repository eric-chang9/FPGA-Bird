VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

tmds_encoder: src/video_out/tmds_encoder.sv tb/tb_tmds_encoder.sv
	$(VERILATE) $(VERILATE_FLAGS) --top-module tb_tmds_encoder $^ 
	cp obj_dir/Vtb_tmds_encoder .

clean:
	rm -rf obj_dirx
	rm -f Vtb_tmds_encoder
	rm -f waveform.fst