module spi_ram_top #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire MOSI,
    input  wire SS_n,
    output wire MISO
);

    // internal SPI-slave <-> RAM bus
    wire [ADDR_SIZE+1:0] rx_data;
    wire       rx_valid;
    wire [ADDR_SIZE-1:0] tx_data;
    wire       tx_valid;

    spi_slave #(
        .ADDR_SIZE (ADDR_SIZE)
    )u_spi_slave (
        .clk      (clk),
        .rst_n    (rst_n),
        .MOSI     (MOSI),
        .SS_n     (SS_n),
        .MISO     (MISO),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .tx_data  (tx_data),
        .tx_valid (tx_valid)
    );

    ram_single_port #(
        .MEM_DEPTH (MEM_DEPTH),
        .ADDR_SIZE (ADDR_SIZE)
    ) u_ram (
        .clk      (clk),
        .rst_n    (rst_n),
        .din      (rx_data),
        .rx_valid (rx_valid),
        .dout     (tx_data),
        .tx_valid (tx_valid)
    );

endmodule
