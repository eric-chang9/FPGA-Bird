module tb_tmds_encoder;
    logic clk_pixel;
    logic n_rst;
    logic [7:0] data_in;
    logic [1:0] control_in;
    logic display_enable;
    logic [9:0] data_out;
    integer test_num = 0;

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
            @(posedge clk_pixel);
            check_output(expected_output);
            test_num++;
        end
    endtask

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars(0, tb_tmds_encoder);

        clk_pixel = 0;
        reset_signals();
        reset();

        // ----------------------------------------------------
        // Test 1: Blanking / Control Tokens (display_enable = 0)
        // ----------------------------------------------------
        $display("\n--- Testing Control Tokens ---");
        test_case(8'h00, 2'b00, 1'b0, 10'b1101010100);
        test_case(8'h00, 2'b01, 1'b0, 10'b0010101011);
        test_case(8'h00, 2'b10, 1'b0, 10'b0101010100);
        test_case(8'h00, 2'b11, 1'b0, 10'b1010101011);

        reset_signals();

        // ----------------------------------------------------
        // Test 2: Active Video - Edge Pattern: 0x00 (All Zeros)
        // q_m = 9'b100000000 (ones=1, zero-disparity rule applies)
        // ----------------------------------------------------
        $display("\n--- Testing 0x00 Data ---");
        test_case(8'h00, 2'b00, 1'b1, 10'b0100000000);

        reset();

        // ----------------------------------------------------
        // Test 3: Active Video - Edge Pattern: 0xFF (All Ones)
        // onecount > 4 -> XNOR path -> q_m = 9'b011111111
        // Disparity is non-zero, triggers DC balance invert
        // ----------------------------------------------------
        $display("\n--- Testing 0xFF Data ---");
        test_case(8'hFF, 2'b00, 1'b1, 10'b1000000000);

        reset();

        // ----------------------------------------------------
        // Test 4: XOR Path vs XNOR Path Decision Boundary
        // ----------------------------------------------------
        $display("\n--- Testing XOR / XNOR Selection ---");
        // 4 ones, LSB=1 -> XOR path (q_m[8] = 1)
        test_case(8'b0000_1111, 2'b00, 1'b1, 10'b0101010101);

        // 4 ones, LSB=0 -> XNOR path (q_m[8] = 0)
        test_case(8'b1111_0000, 2'b00, 1'b1, 10'b1000001111);

        reset();
        // ----------------------------------------------------
        // Test 5: Running Disparity Tracking (Consecutive Biased Data)
        // ----------------------------------------------------
        $display("\n--- Testing Disparity Inversion Stream ---");
        // Feed consecutive 0x01 bytes to verify DC balance flipping
        test_case(8'h01, 2'b00, 1'b1, 10'b0111111111); // Initial transmission
        test_case(8'h01, 2'b00, 1'b1, 10'b1100000000); // Inverted to correct positive bias
        test_case(8'h01, 2'b00, 1'b1, 10'b0111111111); // Non-inverted
        test_case(8'h01, 2'b00, 1'b1, 10'b1100000000); // Inverted


        reset();
        // ----------------------------------------------------
        // Test 6: Disparity Reset via Blanking
        // ----------------------------------------------------
        $display("\n--- Testing Blanking Disparity Reset ---");
        test_case(8'h00, 2'b00, 1'b0, 10'b1101010100); // Reset cnt to 0
        test_case(8'h01, 2'b00, 1'b1, 10'b0111111111); // Should start fresh with non-inverted token

        $display("All TMDS test cases complete");
        $finish;
    end
endmodule
