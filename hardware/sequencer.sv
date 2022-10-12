`ifndef SEQUENCER
`define SEQUENCER

module sequencer #(
    parameter SIZE = 32 * 4
) (
    input clk,
    input reset,
    output [7:0] display_out,

    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);
    logic [31:0] mem [SIZE-1:0];
    logic [31:0] read_value;
    logic ready;

    logic [31:0]q;
    logic [7:0]display;
    logic [4:0]idx;

    assign display_out = display;

    initial 
        $readmemh("programs/fulldemo/sequence.hex.txt", mem);
  
    assign read_value_out = sel_in ? read_value : 0;
    assign ready_out = sel_in ? ready : 0;

    always_ff @(posedge clk) begin
//        read_value <= {mem[address_in[31:2]][7:0], mem[address_in[31:2]][15:8], mem[address_in[31:2]][23:16], mem[address_in[31:2]][31:24]};
        read_value <= {mem[address_in[4:2]][7:0], mem[address_in[4:2]][15:8], mem[address_in[4:2]][23:16], mem[address_in[4:2]][31:24]};

        if (sel_in && !reset) begin
            ready <= !ready;

            if (write_mask_in[3])
                mem[address_in[6:2]][7:0] <= write_value_in[31:24];

            if (write_mask_in[2])
                mem[address_in[6:2]][15:8] <= write_value_in[23:16];

            if (write_mask_in[1])
                mem[address_in[6:2]][23:16] <= write_value_in[15:8];

            if (write_mask_in[0])
                mem[address_in[6:2]][31:24] <= write_value_in[7:0];
        end else begin
            ready <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            display <= 8'haa;
//                direction <= 1;
            q <= 0;
            idx <= 0 ;
        end else if ( q >  { mem[30][7:0], mem[30][15:8], mem[30][23:16], mem[30][31:24] } ) begin
            q <= 0;
            if ( mem[31] != 0 ) begin
                if ( idx == mem[31][7:0] )
                    idx <= 0;
                else
                    idx <= idx + 1;
                display <= mem[idx][31:24];
            end
        end else begin
            q <= q + 1;
            display <= display;
        end
    end


endmodule

`endif
