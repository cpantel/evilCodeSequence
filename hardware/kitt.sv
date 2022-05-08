`ifndef KITT
`define KITT

module kitt #( parameter BASETIME) (
    input clk,
    input reset,
    output [4:0]display_out,
    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    //input read_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);

    logic [31:0]q;
    logic direction;
    logic [4:0]display;

    logic [31:0] prescaler;

    assign ready_out = sel_in;
    assign display_out = display;

    always_ff @(posedge clk) begin
        if (reset) begin
            prescaler <= 1;
//            read_value_out <= 0;
        end else begin
//            read_value_out <= sel_in ? 32'b0 : prescaler;  // to be verified
            if (sel_in ) begin                                // to be verified
                if (write_mask_in[3])
                    prescaler[7:0] <= write_value_in[31:24];
                if (write_mask_in[2])
                    prescaler[15:8] <= write_value_in[23:16];
                if (write_mask_in[1])
                    prescaler[23:16] <= write_value_in[15:8];
                if (write_mask_in[0])
                    prescaler[31:24] <= write_value_in[7:0];
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            display <= 1;
            direction <= 1;
            q <= 0;
        end else if ( q >  BASETIME ) begin
            q <= 0;
            if (direction ) begin
                 if ( display[4] ) begin
                     direction = ~ direction;
                     display <= display >> 1;
                 end else
                     display <= display << 1;
            end else begin
                 if ( display[0] ) begin
                     direction = ~ direction;
                     display <= display << 1;
                 end else
                     display <= display >> 1;
            end 
       end else begin
            q <= q + prescaler;
            display <= display;
       end
    end

endmodule

`endif
