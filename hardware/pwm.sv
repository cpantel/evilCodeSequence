`ifndef PWM
`define PWM

module pwm #( parameter BASETIME) (
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

    logic [7:0]q;
    logic pulse;
    logic [7:0] selector;
    logic [25:0] prescaler;

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
        if (reset) begin
            q <= 0;
            prescaler <= 0;
        end else begin
            prescaler <= prescaler + 1;
	    if (prescaler == ( BASETIME / 10000) ) begin
               prescaler <= 0;
               q <= q + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            pulse <= 0;
        end else begin
	    pulse <= q < selector ;
        end
    end
endmodule

`endif
