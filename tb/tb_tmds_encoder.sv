module tb_tmds_encoder;
    logic clk_pixel;
    logic n_rst;
    logic [7:0] data_in;
    logic [1:0] control_in;
    logic display_enable;
    logic [9:0] data_out;

    tmds_encoder dut (
        .clk_pixel(clk_pixel),
        .n_rst(n_rst),
        .data_in(data_in),
        .control_in(control_in),
        .display_enable(display_enable),
        .data_out(data_out)
    );

    always #5 clk_pixel = ~clk_pixel;

    task reset();
        begin
            n_rst = 0;
            repeat (2) @(posedge clk_pixel);
            n_rst = 1;
        end
    endtask

    task reset_signals();
        begin
            data_in = 8'b00000000;
            control_in = 2'b00;
            display_enable = 0;
        end
    endtask

    task send_data(input [7:0] data, input [1:0] control, input logic display);
        begin
            data_in = data;
            control_in = control;
            display_enable = display;
            @(posedge clk_pixel);
        end
    endtask

    task check_output(input [9:0] expected_data);
        begin
            if (data_out !== expected_data) begin
                $display("FAIL: expected %b got %b", expected_data, data_out);
            end else begin
                $display("PASS: output = %b", data_out);
            end
        end
    endtask

    task test_case(input [7:0] data, input [1:0] control, input logic display, input [9:0] expected_output);
        begin
            send_data(data, control, display);
            #1;
            check_output(expected_output);
        end
    endtask

    initial begin
        clk_pixel = 0;
        reset_signals();
        reset();

        // Basic data cases
        test_case(8'h00, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h01, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h02, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h03, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h04, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h05, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h07, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h08, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h0F, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h10, 2'b00, 1'b1, 10'b0000000000);

        // Edge/alternating patterns
        test_case(8'h55, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'hAA, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'hA5, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h5A, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'hF0, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'h0F, 2'b00, 1'b1, 10'b0000000000);
        test_case(8'hFF, 2'b00, 1'b1, 10'b0000000000);

        // Control/display states
        test_case(8'h00, 2'b00, 1'b0, 10'b0000000000);
        test_case(8'hAA, 2'b01, 1'b1, 10'b0000000000);
        test_case(8'h55, 2'b10, 1'b1, 10'b0000000000);
        test_case(8'hFF, 2'b11, 1'b1, 10'b0000000000);

        $display("All TMDS test cases complete");
        $finish;
    end
endmodule
