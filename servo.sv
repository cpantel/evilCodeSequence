`ifndef SERVO
`define SERVO

module servo #( parameter BASETIME) (
    input clk,
    input reset,
    output pwm,
    output [7:0]monitor,
    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    //input read_in,
    //output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);

    logic [20:0]q;
    logic pulse;
    logic [7:0] selector;

    assign ready_out = sel_in;

    assign pwm = pulse;
    assign monitor = selector;

    always_ff @(posedge clk) begin
        if (reset) begin
            selector <= 0;
//            read_value_out <= 0;
        end else begin
//            read_value_out <= {23'b0, sel_in ? pwm : 1'b0, selector};
            if (sel_in && write_mask_in[0])
                selector[7:0] <= write_value_in[7:0];
        end
    end

    always_ff @(posedge clk) begin
        if (reset)
            q <= 0;
        else if ( q > ( BASETIME / 1000 * 20 ) )
            q <= 0;
        else 
            q <= q + 1;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            pulse <= 0;
        end else begin
            if ( q > ( BASETIME / 1000 * 20 ) )begin
                pulse <= 0;
            end else if ( q > ( BASETIME / 1000 * 2) ) begin
                pulse <= 0;
            end else begin
                pulse <= ( selector == 8'h0 && q < ( BASETIME / 10000 * 10 )  ) ||
                         ( selector == 8'h1 && q < ( BASETIME / 10000 * 11 )  ) ||
                         ( selector == 8'h2 && q < ( BASETIME / 10000 * 12 )  ) ||
                         ( selector == 8'h3 && q < ( BASETIME / 10000 * 13 )  ) ||
                         ( selector == 8'h4 && q < ( BASETIME / 10000 * 14 )  ) ||
                         ( selector == 8'h5 && q < ( BASETIME / 10000 * 15 )  ) ||
                         ( selector == 8'h6 && q < ( BASETIME / 10000 * 16 )  ) ||
                         ( selector == 8'h7 && q < ( BASETIME / 10000 * 17 )  ) ||
                         ( selector == 8'h8 && q < ( BASETIME / 10000 * 18 )  ) ||
                         ( selector == 8'h9 && q < ( BASETIME / 10000 * 19 )  ) ||
                         ( selector == 8'ha && q < ( BASETIME / 10000 * 20 )  );
            end
        end
    end
endmodule

`endif
