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
    //output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);

    logic [25:0]q;
    logic direction;
    logic [4:0]display;

    assign ready_out = sel_in;
    assign display_out = display;

    always_ff @(posedge clk) begin
        if (reset) begin
            display <= 1;
            direction <= 1;
        end else if ( q > ( BASETIME / 1000 * 300 ) ) begin
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
            q <= q + 1;
            display <= display;
       end
    end

endmodule

`endif
