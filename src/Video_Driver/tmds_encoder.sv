// Basic TMDS encoder for HDMI/DVI video output
module tmds_encoder (
    input logic clk_pixel,
    input logic n_rst,
    input logic [7:0] data_in,
    input logic [1:0] control_in,
    input logic display_enable,
    output logic [9:0] data_out
);
    integer onecount;
    logic [9:0] data;
    integer cnt = 0;
    integer currentDisp;

    always_ff @(posedge clk_pixel or negedge n_rst ) begin
        if (!n_rst) begin
            data_out <= 0;
            cnt <= 0;
        end else begin
            data_out <= data;
            cnt <= (~display_enable) ? 0 : cnt + currentDisp; //Reset total disparity to 0 when in blanking state
        end
    end

    always_comb begin : Encoding
        data[9:0] = 10'b0000000000;
        currentDisp = 0;
        if (display_enable) begin
            data[0] = data_in[0];
            onecount = $countones(data_in);
            currentDisp =2 * onecount - 8; //Discrepancy count
            
            //8bit -> 9bit
            if ((onecount > 4) || ((onecount == 4) && (data_in[0] == 0))) begin //XNOR Path
                data[8] = 0;
                for (int i = 1; i < 8; i++) begin
                    data[i] = data[i-1] ~^ data_in[i];
                end
            end else begin
                 data[8] = 1;
                 for (int i = 1; i < 8; i++) begin
                    data[i] = data[i-1] ^ data_in[i];
                 end
            end

            currentDisp = 2 * $countones(data[7:0]) - 8; //Discrepancy count
            

            //9bit -> 10 bit
            if((cnt == 0) || currentDisp == 0) begin //If total disparity is 0, or current disparity is 0
                data[9] = (data[8] == 1) ? 0 : 1 ; //If 9th bit is 1, then 10th bit is 0, else 10th bit is 1
            end else if(cnt > 0) begin
                if(currentDisp > 0) begin //Disparities biased in same direction
                    data[9] = 1;
                end else begin
                    data[9] = 0;
                end
            end else if(cnt < 0) begin
                if(currentDisp > 0) begin //Disparities biased in opposite direction
                    data[9] = 0;
                end else begin
                    data[9] = 1;
                end
            end

            //Bit inversion
            if(data[9] == 1) begin
                data[7:0] = ~data[7:0];
            end 

            //Find the new total disparity
            currentDisp = 0;
            currentDisp = 2 * $countones(data[9:0]) - 10; //Discrepancy count
        end else begin
            //Control data encoding
            case(control_in)
                2'b00:   data = 10'b1101010100;
                2'b01:   data = 10'b0010101011;
                2'b10:   data = 10'b0101010100;
                default: data = 10'b1010101011;
            endcase
        end
    end


endmodule
