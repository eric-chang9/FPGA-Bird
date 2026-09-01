// Basic module syntax with port list
module dvi_top ([port_list]);
	tmds_encoder red_encoder (
        .clk_pixel(clk_pixel),
        .n_rst(n_rst),
        .data_in(data_in_red),
        .data_out(data_out_red)
    );

    tmds_encoder green_encoder (
        .clk_pixel(clk_pixel),
        .n_rst(n_rst),
        .data_in(data_in_green),
        .data_out(data_out_green)
    );

    tmds_encoder blue_encoder (
        .clk_pixel(clk_pixel),
        .n_rst(n_rst),
        .data_in(data_in_blue),
        .data_out(data_out_blue)
    );

endmodule
