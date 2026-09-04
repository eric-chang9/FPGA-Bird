// Basic module syntax with port list
module serializer (
    input logic clk_pixel, //Pixel Clock
    input logic clk_serial, //Serial Clock whihc 5x the speed
    input logic n_rst,
    input logic [9:0] data_in,
    output logic serial_out
);

    logic [3:0] bit_count;
    logic [9:0] shift_reg;

    always_ff @(posedge clk_pixel or negedge n_rst ) begin : tmds_signal_shift
        if(!n_rst) begin
            shift_reg <= 10'b0;
        end else begin
            shift_reg <= data_in;
        end
    end

    always_ff @(posedge clk_serial or negedge clk_serial or negedge n_rst) begin : serial_output
        if(!n_rst) begin
            serial_out <= 1'b0;
        end else if(bit_count < 10) begin
            serial_out <= shift_reg[bit_count];
            bit_count <= bit_count + 1;
        end
    end
endmodule
