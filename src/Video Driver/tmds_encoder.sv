// Basic module syntax with port list
module <name> (
    input logic clk_pixel,
    input logic n_rst,
    input logic [7:0] data_in,
    input logic [1:0] control_in,
    input logic display_enable,
    input logic blue,
    output logic [9:0] data_out
));
    integer onecount = 4'b0000;
    logic [9:0] data;
    integer cnt = 4'b0000;
    integer currentDisp = 4'b0000;
	
    typedef enum logic { 
        BLANKING,
        ACTIVE_VIDEO
     } state_t;
    state_t current_state, next_state;

    always_comb begin : state_picker
        if (display_enable) begin
            next_state = ACTIVE_VIDEO;
        end else begin
            next_state = BLANKING;
        end
    end

    always_ff @(posedge clk_pixel or negedge n_rst ) begin
        if (!n_rst) begin
            current_state <= BLANKING;
            data_out <= 0;
        end else begin
            current_state <= next_state;
            data_out <= data;
        end
    end

    always_comb begin : Encoding
        data[7:0] = data_in;
        if (current_state == BLANKING) begin
            if(!blue) begin
                data = 9'b000000000;
            end else if (blue) begin
                //Put in control signals for blue
            end
            
        end else if (current_state == ACTIVE_VIDEO) begin
            for (int i = 0; i < 8; i++) begin
                onecount = onecount + data_in[i];
            end

            currentDisp = 8 - 2 * onecount; //Discrepancy count

            //8bit -> 9bit
            if ((onecount > 4) or ((onecount == 4) and (data_in[0] == 0))) begin //XNOR Path
                data[8] = 0;
            end else begin
                 data[8] = 1;
            end


            //9bit -> 10 bit
            if((cnt == 0) or currentDisp == 0) begin
                data[9] = (data[8] == 1) ? 0 : 1 ;
            end else if(cnt > 0) begin
                if(currentDisp > 0) begin
                    data[9] = 0;
                end else begin
                    data[9] = 0;
                end
            end

        end
    end


endmodule
