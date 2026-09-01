// Basic module syntax with port list
module test_pattern_gen (
    input logic [9:0] pixel_x,
    input logic [9:0] pixel_y,
    input logic display_enable,
    output logic [7:0] red_out,
    output logic [7:0] green_out,
    output logic [7:0] blue_out,
);

always_comb begin : Pattern 
    if (~display_enable) begin
        red_out = 0;
        green_out = 0;
        blue_out = 0;
    end else if(pixel_x == 0 || pixel_x == 639 || pixel_y == 0 || pixel_y == 479) begin
        red   = 8'hFF;
        green = 8'hFF;
        blue  = 8'hFF;
    end else begin
        case(pixel_x / 80)
            3'd0: begin red = 8'hFF; green = 8'hFF; blue = 8'hFF; end // White
            3'd1: begin red = 8'hFF; green = 8'hFF; blue = 8'h00; end // Yellow
            3'd2: begin red = 8'h00; green = 8'hFF; blue = 8'hFF; end // Cyan
            3'd3: begin red = 8'h00; green = 8'hFF; blue = 8'h00; end // Green
            3'd4: begin red = 8'hFF; green = 8'h00; blue = 8'hFF; end // Magenta
            3'd5: begin red = 8'hFF; green = 8'h00; blue = 8'h00; end // Red
            3'd6: begin red = 8'h00; green = 8'h00; blue = 8'hFF; end // Blue
            3'd7: begin red = 8'h00; green = 8'h00; blue = 8'h00; end // Black
            default: begin red = 8'h00; green = 8'h00; blue = 8'h00; end
        endcase
    end
end

	
endmodule
