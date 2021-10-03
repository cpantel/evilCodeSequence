`include "bus_arbiter.sv"
`include "flash.sv"
`include "ram.sv"
`include "rv32.sv"
`include "timer.sv"
`include "uart.sv"
`include "rtc.sv"
`include "servo.sv"

`ifdef ECP5
`define RAM_SIZE 8192
`else
`define RAM_SIZE 2048
`endif

`ifdef SPI_FLASH
`define RESET_VECTOR 32'h01100000
`else
`define RESET_VECTOR 32'h00000000
`endif


`define FREQ 36000000

module icicle #( parameter LEDCOUNT, parameter BUTTONCOUNT) (
    input clk,
    input reset,

`ifdef SPI_FLASH
    /* serial flash */
    output logic flash_clk,
    output logic flash_csn,

    output logic flash_io0_en,
    input flash_io0_in,
    output logic flash_io0_out,

    output logic flash_io1_en,
    input flash_io1_in,
    output logic flash_io1_out,
`endif

    /* LEDs */
    output logic [LEDCOUNT -1 :0] leds,

    /* BUTTONS */
    input [BUTTONCOUNT - 1:0] buttons,

    /* PMOD0 */
    output logic [7:0] pmod0,

    /* PMOD1 */
    input [7:0] pmod1,

    /* ARDUINO */
    output logic [31:0] arduino,

    /* UART */
    input uart_rx,
    output logic uart_tx
);
    /* instruction memory bus */
    logic [31:0] instr_address;
    logic instr_read;
    logic [31:0] instr_read_value;
    logic instr_ready;
    logic instr_fault;

    /* data memory bus */
    logic [31:0] data_address;
    logic data_read;
    logic data_write;
    logic [31:0] data_read_value;
    logic [3:0] data_write_mask;
    logic [31:0] data_write_value;
    logic data_ready;
    logic data_fault;

    /* memory bus */
    logic [31:0] mem_address;
    logic mem_read;
    logic mem_write;
    logic [31:0] mem_read_value;
    logic [3:0] mem_write_mask;
    logic [31:0] mem_write_value;
    logic mem_ready;
    logic mem_fault;

    assign mem_read_value = ram_read_value | leds_read_value | buttons_read_value | pmod0_read_value | pmod1_read_value | arduino_read_value | rtc_read_value | /*servo_read_value | */ uart_read_value | timer_read_value | flash_read_value;
    assign mem_ready = ram_ready | leds_ready | buttons_ready | pmod0_ready | pmod1_ready | arduino_ready | rtc_ready | servo_ready | uart_ready | timer_ready | flash_ready | mem_fault;

    bus_arbiter bus_arbiter (
        .clk(clk),
        .reset(reset),

        /* instruction memory bus */
        .instr_address_in(instr_address),
        .instr_read_in(instr_read),
        .instr_read_value_out(instr_read_value),
        .instr_ready_out(instr_ready),
        .instr_fault_out(instr_fault),

        /* data memory bus */
        .data_address_in(data_address),
        .data_read_in(data_read),
        .data_write_in(data_write),
        .data_read_value_out(data_read_value),
        .data_write_mask_in(data_write_mask),
        .data_write_value_in(data_write_value),
        .data_ready_out(data_ready),
        .data_fault_out(data_fault),

        /* common memory bus */
        .address_out(mem_address),
        .read_out(mem_read),
        .write_out(mem_write),
        .read_value_in(mem_read_value),
        .write_mask_out(mem_write_mask),
        .write_value_out(mem_write_value),
        .ready_in(mem_ready),
        .fault_in(mem_fault)
    );

    logic [63:0] cycle;

    rv32 #(
        .RESET_VECTOR(`RESET_VECTOR)
    ) rv32 (
        .clk(clk),
        .reset(reset),

        /* instruction memory bus */
        .instr_address_out(instr_address),
        .instr_read_out(instr_read),
        .instr_read_value_in(instr_read_value),
        .instr_ready_in(instr_ready),
        .instr_fault_in(instr_fault),

        /* data memory bus */
        .data_address_out(data_address),
        .data_read_out(data_read),
        .data_write_out(data_write),
        .data_read_value_in(data_read_value),
        .data_write_mask_out(data_write_mask),
        .data_write_value_out(data_write_value),
        .data_ready_in(data_ready),
        .data_fault_in(data_fault),

        /* timer */
        .cycle_out(cycle)
    );

    logic ram_sel;
    logic leds_sel;
    logic buttons_sel;
    logic pmod0_sel;
    logic pmod1_sel;
    logic arduino_sel;
    logic rtc_sel;
    logic servo_sel;
    logic uart_sel;
    logic timer_sel;
    logic flash_sel;

    always_comb begin
        ram_sel = 0;
        leds_sel = 0;
        buttons_sel = 0;
        pmod0_sel = 0;
        pmod1_sel = 0;
        arduino_sel = 0;
        rtc_sel = 0;
        servo_sel = 0;
        uart_sel = 0;
        timer_sel = 0;
        flash_sel = 0;
        mem_fault = 0;

        casez (mem_address)
            32'b00000000_00000000_????????_????????: ram_sel     = 1;
            32'b00000000_00000001_00000000_000000??: leds_sel    = 1; // 0x00010000
            32'b00000000_00000001_00000000_000001??: buttons_sel = 1; // 0x00010004
            32'b00000000_00000001_00000000_000010??: pmod0_sel   = 1; // 0x00010008
            32'b00000000_00000001_00000000_000011??: pmod1_sel   = 1; // 0x0001000c
            32'b00000000_00000001_00000000_000100??: arduino_sel = 1; // 0x00010010
            32'b00000000_00000001_00000000_000101??: rtc_sel     = 1; // 0x00010014
            32'b00000000_00000001_00000000_000110??: servo_sel   = 1; // 0x00010018
            32'b00000000_00000010_00000000_0000????: uart_sel    = 1; // 0x00020000
            32'b00000000_00000011_00000000_0000????: timer_sel   = 1; // 0x00030000
            32'b00000001_????????_????????_????????: flash_sel   = 1;
            default:                                 mem_fault   = 1;
        endcase
    end

    /* RAM */

    logic [31:0] ram_read_value;
    logic ram_ready;

    ram #(
        .SIZE(`RAM_SIZE)
    ) ram (
        .clk(clk),
        .reset(reset),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(ram_sel),
        .read_value_out(ram_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(ram_ready)
    );

    /* LEDs */

    logic [31:0] leds_read_value;
    logic leds_ready;

    assign leds_read_value = {(32-LEDCOUNT)'b0, leds_sel ? leds : LEDCOUNT'b0};
    assign leds_ready = leds_sel;

    always_ff @(posedge clk) begin
        if (leds_sel && mem_write_mask[0])
            leds <= mem_write_value[LEDCOUNT -1:0];
    end

    /* BUTTONS */

    logic [31:0] buttons_read_value;
    logic buttons_ready;
   
    assign buttons_read_value = {(32-BUTTONCOUNT)'b0, buttons_sel ? buttons : BUTTONCOUNT'b0}; 
    assign buttons_ready = buttons_sel;

    /* PMOD0 */

    logic [31:0] pmod0_read_value;
    logic pmod0_ready;

`ifdef PMOD0_DEV
    assign pmod0_read_value = {24'b0, pmod0_sel ? pmod0 : 8'b0};
    assign pmod0_ready = pmod0_sel;

    always_ff @(posedge clk) begin
        if (pmod0_sel && mem_write_mask[0])
            pmod0 <= mem_write_value[7:0];
    end
`else
    assign pmod0_read_value = 0;
    assign pmod0_ready = pmod0_sel;
`endif

    /* PMOD1 */

    logic [31:0] pmod1_read_value;
    logic pmod1_ready;

`ifdef PMOD1_DEV
    assign pmod1_read_value = {24'b0, pmod1_sel ? pmod1 : 8'b0};
    assign pmod1_ready = pmod1_sel;
`else
    assign pmod1_read_value = 0;
    assign pmod1_ready = pmod1_sel;
`endif

    /* ARDUINO */

    logic [31:0] arduino_read_value;
    logic arduino_ready;

`ifdef ARDUINO_DEV
    assign arduino_read_value = {arduino_sel ? arduino : 32'b0};
    assign arduino_ready = arduino_sel;

    always_ff @(posedge clk) begin
        if (arduino_sel && mem_write_mask[0])
            arduino[7:0] <= mem_write_value[7:0];
        if (arduino_sel && mem_write_mask[1])
            arduino[15:8] <= mem_write_value[15:8];
        if (arduino_sel && mem_write_mask[2])
            arduino[23:16] <= mem_write_value[23:16];
        if (arduino_sel && mem_write_mask[3])
            arduino[31:24] <= mem_write_value[31:24];
    end

`else
    assign arduino_read_value = 0;
    assign arduino_ready = arduino_sel;
`endif

    /* RTC */

    logic [31:0] rtc_read_value;
    logic rtc_ready;
`ifdef RTC_DEV
    rtc #(.COUNT(`FREQ)) rtc (
        .clk_in(clk),
        .reset(reset),
        /* memory bus */
        .address_in(mem_address),
        .sel_in(rtc_sel),
//        .read_in(mem_read),
        .read_value_out(rtc_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(rtc_ready)
    );
`else
    assign rtc_read_value = 0;
    assign rtc_ready = rtc_sel;
`endif

    /* SERVO */

//    logic [31:0] servo_read_value;
    logic servo_ready;
`ifdef SERVO_DEV
    servo #(.BASETIME(`FREQ)) servo (
        .clk(clk),
        .reset(reset),
        .pwm(arduino[0]),
        .monitor(arduino[23:16]),
        /* memory bus */
        .address_in(mem_address),
        .sel_in(servo_sel),
        //.read_in(mem_read),
       // .read_value_out(servo_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(servo_ready)
    );
`else
//    assign servo_read_value = 0;
    assign servo_ready = rtc_sel;
`endif

    /* UART */

    logic [31:0] uart_read_value;
    logic uart_ready;
`ifdef UART_DEV
    uart uart (
        .clk(clk),
        .reset(reset),

        /* serial port */
        .rx_in(uart_rx),
        .tx_out(uart_tx),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(uart_sel),
        .read_in(mem_read),
        .read_value_out(uart_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(uart_ready)
    );
`else
    assign uart_read_value = 0;
    assign uart_ready = rtc_sel;
`endif

    /* TIMER */

    logic [31:0] timer_read_value;
    logic timer_ready;

    timer timer (
        .clk(clk),
        .reset(reset),

        /* cycle count (from the CPU core) */
        .cycle_in(cycle),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(timer_sel),
        .read_in(mem_read),
        .read_value_out(timer_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(timer_ready)
    );

    /* FLASH */

    logic [31:0] flash_read_value;
    logic flash_ready;

`ifdef SPI_FLASH
    flash flash (
        .clk(clk),
        .reset(reset),

        /* SPI bus */
        .clk_out(flash_clk),
        .csn_out(flash_csn),
        .io0_in(flash_io0_in),
        .io1_in(flash_io1_in),
        .io0_en(flash_io0_en),
        .io1_en(flash_io1_en),
        .io0_out(flash_io0_out),
        .io1_out(flash_io1_out),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(flash_sel),
        .read_in(mem_read),
        .read_value_out(flash_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(flash_ready)
    );
`else
    assign flash_read_value = 0;
    assign flash_ready = flash_sel;
`endif
endmodule
