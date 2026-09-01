// Basic module syntax with port list
module video_timing (
    input logic clk_pixel,
    input logic n_rst,
    output logic [9:0] pixel_x,
    output logic [9:0] pixel_y,
    output logic h_sync,         // Horizontal sync pulse
    output logic v_sync,         // Vertical sync pulse
    output logic display_enable, // High only in active display area
    output logic frame_tick      // Single-cycle pulse once per frame (60 Hz)
);
	
    localparam H_ACTIVE = 640, H_FP = 16, H_SYNC = 96, H_BP = 48, H_TOTAL = 800;
    localparam V_ACTIVE = 480, V_FP = 10, V_SYNC = 2,  V_BP = 33, V_TOTAL = 525;

    logic [9:0] h_count;
    logic [9:0] v_count;

    always_ff @(posedge clk_pixel or negedge n_rst ) begin  : counter 
        if(!n_rst) begin
            //Reset Counter
            h_count <= 0; 
            v_count <= 0;
        end else begin
            if(h_count == H_TOTAL - 1) begin //Check if end of line
                h_count <= 0;
                if (v_count == V_TOTAL - 1) begin //Check if end of frame
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1; //Increment vertical counter
                end
            end else begin
                h_count <= h_count + 1; //Increment horizontal counter
            end
        end 
    end

    always_ff @(posedge clk_pixel ) begin : Signal Gen
        if(!n_rst) begin
            //Reset all output signals
            pixel_x <= 0;
            pixel_y <= 0;
            h_sync <= 0;
            v_sync <= 0;
            display_enable <= 0;
            frame_tick <= 0;
        end else begin
            pixel_x <= (h_count < H_ACTIVE) ? h_count : 10'd0; //Reset pixel_x to 0 when in blanking state
            pixel_y <= (v_count < V_ACTIVE) ? v_count : 10'd0; //Reset pixel_y to 0 when in blanking state
            h_sync <= (h_count >= H_ACTIVE + H_FP && h_count < H_ACTIVE + H_FP + H_SYNC); //Generate horizontal sync pulse
            v_sync <= (v_count >= V_ACTIVE + V_FP && v_count < V_ACTIVE + V_FP + V_SYNC); //Generate vertical sync pulse
            display_enable <= (h_count < H_ACTIVE && v_count < V_ACTIVE); //High only in active display area
            frame_tick <= (h_count == 0 && v_count == 0); //Single-cycle pulse once per frame (60 Hz)
        end
    end

endmodule
