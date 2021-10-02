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
    input read_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);

    logic [20:0]q;
    logic pulse;
    logic [7:0] selector;

    assign ready_out = sel_in;
    assign read_value_out = {22'b0, sel_in ? pwm : 1'b0, selector};
    assign pwm = pulse;
    assign monitor = selector;

    always_ff @(posedge clk) begin
        if (reset) 
            selector = 0;
        else if (sel_in && write_mask_in[0])
           selector <= write_value_in[7:0];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            q = 0;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            q = 0;
        end else begin
            if ( q > BASETIME * 20 ) begin
                pulse <= 0;
                q <= 0;
            end else if ( q > BASETIME * 2) begin
                pulse <= 0;
                q <= q + 1;
            end else if ( q < BASETIME) begin
                pulse <= 1;
                q <= q + 1;
            end else begin
                q <= q + 1;
                pulse <= selector[2];
                
/*               
                case (selector)
                    4'b0000: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 0 ) )
                           pulse <= 1;
                    end
                    4'b0001: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 1 ) )
                           pulse <= 1;
                    end 
                    4'b0010: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 2 ) )
                           pulse <= 1;
                    end 
                    4'b0011: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 3 ) )
                           pulse <= 1;
                    end 
                    4'b0100: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 4 ) )
                           pulse <= 1;
                    end 
                    4'b0101: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 5 ) )
                           pulse <= 1;
                    end 
                    4'b0110: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 6 ) )
                           pulse <= 1;
                    end 
                    4'b0111: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 7 ) )
                           pulse <= 1;
                    end 
                    4'b1000: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 8 ) )
                           pulse <= 1;
                    end 
                    4'b1001: begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 9 ) )
                           pulse <= 1;
                    end 
                    default:  begin
                        if ( q < ( BASETIME + ( BASETIME / 10) * 10 ) )
                           pulse <= 1;
                    end
                endcase
*/
            end
        end
    end
endmodule

`endif
