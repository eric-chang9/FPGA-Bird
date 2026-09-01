// Basic module syntax with port list
module serializer (
    input logic clk_pixel, //Pixel Clock
    input logic clk_serial, //Serial Clock whihc 5x the speed
    input logic n_rst,
    input logic [9:0] data_in,
    output logic [9:0] serial_p,
    output logic [9:0] serial_n
);



endmodule
