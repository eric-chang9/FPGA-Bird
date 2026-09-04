module tb_serializer;
	logic [9:0] input;
    logic serial_out;
    logic clk_pixel;
    logic clk_serial;
    logic n_rst;

    always #5 clk_pixel = ~clk_pixel
    always #1 clk_serial = ~clk_serial;

    serializer dut (
        .clk_pixel(clk_pixel),
        .clk_serial(clk_serial),
        .n_rst(n_rst),
        .data_in(input),
        .serial_out(serial_out)
    );

    task reset();
        begin
            n_rst = 0;
            @(negedge clk_pixel);
            input = 0;
            n_rst = 1;
        end
    endtask

    task send_data(input [9:0] data);
        begin
            input = data;
        end
    endtask

    task check_output(input expected_data);
        begin
            if (serial_out !== expected_data) begin
                $display("FAIL: expected %b got %b", expected_data, serial_out);
            end else begin
                $display("PASS: output = %b", serial_out);
            end
        end
    endtask

    task run_test(input [9:0] data);
        begin
            send_data(data);
            for(int i = 0; i<10; i++) begin
                @(posedge clk_serial)
            end
        end
    endtask

endmodule