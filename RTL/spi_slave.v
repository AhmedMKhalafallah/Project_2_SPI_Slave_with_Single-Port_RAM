module spi_slave #(
    parameter ADDR_SIZE = 8
)(
    input  wire        clk,
    input  wire        rst_n,    
    input  wire        MOSI,
    input  wire        SS_n,
    output wire         MISO,

    //interface to the RAM
    output reg  [ADDR_SIZE+1:0]   rx_data,
    output reg           rx_valid,
    input  wire [ADDR_SIZE-1:0]   tx_data,
    input  wire          tx_valid
);
    localparam CNT_W = $clog2(ADDR_SIZE);
    // State encoding
    // one_hot / gray / sequential
    localparam [2:0]
        S_IDLE      = 3'd0,
        S_CHK_CMD   = 3'd1,
        S_WRITE     = 3'd2,
        S_READ_ADD  = 3'd3,
        S_READ_DATA = 3'd4;

    (* fsm_encoding = "one_hot" *) 
    reg [2:0] state, next_state;

    reg [ADDR_SIZE+1:0] shift_in;    // serial -> parallel (MOSI) shift register
    reg [ADDR_SIZE-1:0] shift_out;   // parallel -> serial (MISO) shift register
    reg [CNT_W:0] bit_cnt;   
    reg [1:0] rd_phase;  
    reg       addr_ready;
    reg       rx_done; 

    // 1) STATE MEMORY (sequential)
    always @(posedge clk) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // 2) NEXT-STATE LOGIC (combinational)
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (!SS_n)
                    next_state = S_CHK_CMD;
            end

            S_CHK_CMD: begin
                if (SS_n)
                    next_state = S_IDLE;
                else if (MOSI == 1'b0)
                    next_state = S_WRITE;
                else
                    next_state = addr_ready ? S_READ_DATA : S_READ_ADD;
            end
            S_WRITE, S_READ_ADD, S_READ_DATA: begin
                if (SS_n)
                    next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // 3) OUTPUT
    always @(posedge clk) begin
        if (!rst_n) begin
            shift_in   <= {(ADDR_SIZE+2){1'b0}};
            shift_out  <= {ADDR_SIZE{1'b0}};
            bit_cnt    <= 'd0;
            rd_phase   <= 2'd0;
            rx_done    <= 1'b0;
            addr_ready <= 1'b0;
            rx_data    <= {(ADDR_SIZE+2){1'b0}};
            rx_valid   <= 1'b0;
        end else begin
            rx_valid <= 1'b0; 

            case (state)
                
                S_IDLE: begin
                    bit_cnt  <= 'd0;
                    rd_phase <= 2'd0;
                    rx_done  <= 1'b0; 
                end

                S_CHK_CMD: begin
                    if (!SS_n) begin
                        shift_in <= {{(ADDR_SIZE+1){1'b0}}, MOSI};
                        bit_cnt  <= 'd0;
                        rd_phase <= 2'd0;
                    end
                end

                S_WRITE, S_READ_ADD: begin
                    if (!SS_n && !rx_done) begin
                        shift_in <= {shift_in[ADDR_SIZE:0], MOSI};
                        if (bit_cnt == ADDR_SIZE) begin
                            rx_data  <= {shift_in[ADDR_SIZE:0], MOSI};
                            rx_valid <= 1'b1;
                            rx_done  <= 1'b1;  
                            bit_cnt  <= 'd0;
                            if (state == S_READ_ADD)
                                addr_ready <= 1'b1;   // address now pending in RAM
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end

                // -----------------------------------------------------
                S_READ_DATA: begin
                    case (rd_phase)
                        2'd0: begin 
                            if (!SS_n) begin
                                shift_in <= {shift_in[ADDR_SIZE:0], MOSI};
                                if (bit_cnt == ADDR_SIZE) begin
                                    rx_data    <= {shift_in[ADDR_SIZE:0], MOSI};
                                    rx_valid   <= 1'b1;
                                    addr_ready <= 1'b0;  // address now consumed
                                    bit_cnt    <= 'd0;
                                    rd_phase   <= 2'd1;
                                end else begin
                                    bit_cnt <= bit_cnt + 1'b1;
                                end
                            end
                        end
                        2'd1: begin // waiting for the RAM to return the data
                            if (tx_valid) begin
                                shift_out <= tx_data;
                                bit_cnt   <= 'd0;
                                rd_phase  <= 2'd2;
                            end
                        end
                        2'd2: begin // shifting the byte out on MISO, MSB first
                            if (!SS_n && bit_cnt < ADDR_SIZE) begin
                                shift_out <= {shift_out[ADDR_SIZE-2:0], 1'b0};
                                bit_cnt   <= bit_cnt + 1'b1;
                            end
                        end
                        default: ;
                    endcase
                end

                default: ;
            endcase
        end
    end

    assign MISO = (state == S_READ_DATA && rd_phase == 2'd2) ? shift_out[ADDR_SIZE-1] : 1'b0;

endmodule
