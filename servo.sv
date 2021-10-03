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
        else if ( q > BASETIME * 20 )
            q <= 0;
        else 
            q <= q + 1;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            pulse <= 0;
        end else begin
            if ( q > BASETIME * 20 ) begin
                pulse <= 0;
            end else if ( q > BASETIME * 2) begin
                pulse <= 0;
            end else begin
                pulse <= ( selector == 8'h0 && q < ( BASETIME / 10 * 10 )  ) ||
                         ( selector == 8'h1 && q < ( BASETIME / 10 * 11 )  ) ||
                         ( selector == 8'h2 && q < ( BASETIME / 10 * 12 )  ) ||
                         ( selector == 8'h3 && q < ( BASETIME / 10 * 13 )  ) ||
                         ( selector == 8'h4 && q < ( BASETIME / 10 * 14 )  ) ||
                         ( selector == 8'h5 && q < ( BASETIME / 10 * 15 )  ) ||
                         ( selector == 8'h6 && q < ( BASETIME / 10 * 16 )  ) ||
                         ( selector == 8'h7 && q < ( BASETIME / 10 * 17 )  ) ||
                         ( selector == 8'h8 && q < ( BASETIME / 10 * 18 )  ) ||
                         ( selector == 8'h9 && q < ( BASETIME / 10 * 19 )  ) ||
                         ( selector == 8'ha && q < ( BASETIME / 10 * 20 )  );
            end
        end
    end
endmodule

`endif

/*

                pulse <= ( selector == 8'h0 && q < 36000  ) ||
                         ( selector == 8'h1 && q < 39600  ) ||
                         ( selector == 8'h2 && q < 43200  ) ||
                         ( selector == 8'h3 && q < 46800  ) ||
                         ( selector == 8'h4 && q < 50400  ) ||
                         ( selector == 8'h5 && q < 54000  ) ||
                         ( selector == 8'h6 && q < 57600  ) ||
                         ( selector == 8'h7 && q < 61200  ) ||
                         ( selector == 8'h8 && q < 64800  ) ||
                         ( selector == 8'h9 && q < 68400  ) ||
                         ( selector == 8'ha && q < 72000  );

*/
/*

                case (selector)
                    8'h0:
                        if ( q < 36000) // ( BASETIME + ( BASETIME / 10) * 0 ) )
                           pulse <= 1;
                    8'h1:
                        if ( q < 39600 ) // ( BASETIME + ( BASETIME / 10) * 1 ) )
                           pulse <= 1;
                    8'h2:
                        if ( q < 43200 ) // ( BASETIME + ( BASETIME / 10) * 2 ) )
                           pulse <= 1;
                    8'h3:
                        if ( q < 46800) // ( BASETIME + ( BASETIME / 10) * 3 ) )
                           pulse <= 1;
                    8'h4:
                        if ( q < 50400) // ( BASETIME + ( BASETIME / 10) * 4 ) )
                           pulse <= 1;
                    8'h5:
                        if ( q < 54000) // ( BASETIME + ( BASETIME / 10) * 5 ) )
                           pulse <= 1;
                    8'h6:
                        if ( q < 57600) // ( BASETIME + ( BASETIME / 10) * 6 ) )
                           pulse <= 1;
                    8'h7:
                        if ( q < 61200) // ( BASETIME + ( BASETIME / 10) * 7 ) )
                           pulse <= 1;
                    8'h8:
                        if ( q < 64800) // ( BASETIME + ( BASETIME / 10) * 8 ) )
                           pulse <= 1;
                    8'h9:
                        if ( q < 68400) // ( BASETIME + ( BASETIME / 10) * 9 ) )
                           pulse <= 1;
                    8'hA:
                        if ( q < 72000) // ( BASETIME + ( BASETIME / 10) * 10 ) )
                           pulse <= 1;
                    default:
                        pulse <= 0;
                endcase


*/
