`timescale 1ns/1ps

module tb_simple_2;

    reg  clk   = 0;
    reg  rst_n = 0;
    reg  MOSI  = 0;
    reg  SS_n  = 1;
    wire MISO;

    // temporary variable
    reg [9:0] frame;
    integer   i;

    reg [7:0] received_byte;

    // Instantiate
    spi_ram_top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .MOSI  (MOSI),
        .SS_n  (SS_n),
        .MISO  (MISO)
    );

    always #5 clk = ~clk;

    initial begin

        // Step 0: reset
        rst_n = 0;
        SS_n  = 1;
        MOSI  = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (2) @(negedge clk);


        // Step 1: send "store write-address = 0x10"
        // frame = 00_00010000
        frame = {2'b00, 8'h10};
        SS_n  = 0;             
        @(negedge clk);

        for (i = 9; i >= 0; i = i - 1) begin
            MOSI = frame[i];      // send one bit per clock
            @(negedge clk);
        end

        SS_n = 1;               
        repeat (2) @(negedge clk);

        // Step 2: send "write 0x3C into the stored address"
        // frame = 01_00111100
        frame = {2'b01, 8'h3C};
        SS_n  = 0;
        @(negedge clk);

        for (i = 9; i >= 0; i = i - 1) begin
            MOSI = frame[i];
            @(negedge clk);
        end

        SS_n = 1;
        repeat (2) @(negedge clk);

        // Step 3: send "store read-address = 0x10"
        // frame = 10_00010000
        frame = {2'b10, 8'h10};
        SS_n  = 0;
        @(negedge clk);

        for (i = 9; i >= 0; i = i - 1) begin
            MOSI = frame[i];
            @(negedge clk);
        end

        SS_n = 1;
        repeat (2) @(negedge clk);


        // Step 4: send "give me the data" and capture the reply on MISO
        // frame = 11_00000000 (the last 8 bits are dummy)
        frame = {2'b11, 8'h00};
        SS_n  = 0;
        @(negedge clk);

        for (i = 9; i >= 0; i = i - 1) begin
            MOSI = frame[i];
            @(negedge clk);
        end

        // after sending the frame, the RAM needs one extra clock to
        // register its reply (tx_valid/tx_data)
        @(negedge clk);

        // MISO now starts shifting out 8 bits, capture them one by one
        received_byte = 8'h00;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            received_byte = {received_byte[6:0], MISO};
        end

        SS_n = 1;
        repeat (2) @(negedge clk);

        // Print the result and compare against the expected value
        if (received_byte === 8'h3C)
            $display("PASS: read back 0x%0h from address 0x10 (expected 0x3C)", received_byte);
        else
            $display("FAIL: read back 0x%0h, expected 0x3C", received_byte);

        $stop;
    end

endmodule
