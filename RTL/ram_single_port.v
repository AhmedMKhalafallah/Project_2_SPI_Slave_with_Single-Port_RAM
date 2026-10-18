module ram_single_port(din,rx_valid,clk,rst_n,dout,tx_valid);
    parameter ADDER_SIZE = 8;
    parameter MEM_DEPTH = 256;
    localparam IN_WIDTH = ADDER_SIZE +2;
    input [IN_WIDTH-1:0] din;
    input rx_valid,clk,rst;
    output reg [ADDER_SIZE-1:0] dout;
    output reg tx_valid;
    reg [ADDER_SIZE-1:0] mem [MEM_DEPTH-1:0];
    reg [ADDER_SIZE-1:0] addr_r;
    reg [ADDER_SIZE-1:0] addr_w;
    always @(posedge clk) begin
        if(~rst_n) begin
            addr_w <= 'b0;
            addr_r <= 'b0;
            dout   <= 'b0;
            tx_valid <= 1'b0;
        end else begin
            tx_valid <= 1'b0;
            if (rx_valid)
            case (din[IN_WIDTH-1:IN_WIDTH-2])
                2'b00:addr_w <= din[IN_WIDTH-3:0];
                2'b01:mem[addr_w] <= din[IN_WIDTH-3:0]; 
                2'b10:addr_r <= din[IN_WIDTH-3:0];
                2'b11: begin 
                    dout <= mem[addr_r];
                    tx_valid <= 1'b1;
                end
                default: ;
            endcase
        end
    end
endmodule //ram