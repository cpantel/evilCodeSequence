`ifndef RTC
`define RTC

module rtc #(
    parameter COUNT
) (
    input clk_in,
    input reset,
    output attack_rtc_enable,
    /* memory bus */
    input [31:0] address_in,
    input sel_in,
//    input read_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out

);
    logic [31:0] counter;
    logic [3:0] secondsLo;
    logic [3:0] secondsHi;
    logic [3:0] minutesLo;
    logic [3:0] minutesHi;

    assign ready_out = sel_in;
    assign read_value_out = {16'b0, sel_in ? {minutesHi,minutesLo,secondsHi,secondsLo} : 16'b0};
    assign attack_rtc_enable = secondsHi[1];
    always_ff @(posedge clk_in) begin
        if (reset) begin
            secondsLo <= 0;
            secondsHi <= 0;
            minutesLo <= 0;
            minutesHi <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == COUNT ) begin
                counter <= 0;
                secondsLo <= secondsLo + 1;
                if (secondsLo == 9) begin
                    secondsLo <= 0;
                    secondsHi <= secondsHi + 1;
                    if (secondsHi == 5) begin
                        secondsHi <= 0;
                        minutesLo <= minutesLo + 1;
                        if (minutesLo == 9) begin
                           minutesLo <= 0;
                           minutesHi <= minutesHi + 1;
                            if (minutesHi == 5) begin
                               minutesHi <= 0;
                            end
                        end
                    end
               end
           end
        end
    end
endmodule

`endif
