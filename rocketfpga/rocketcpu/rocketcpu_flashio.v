`default_nettype none
module rocketcpu_flashio
(   
    input wire            reset,

    input wire 		      i_wb_clk,
    input wire [31:0]     i_wb_adr,
    input wire [31:0] 	  i_wb_dat,
    input wire [3:0] 	  i_wb_sel,
    input wire 		      i_wb_we,
    input wire 		      i_wb_cyc,
    output reg [31:0] 	  o_wb_rdt,
    output reg 		      o_wb_ack,

    output flash_csb,
    output flash_clk,

    inout flash_io0,
    inout flash_io1,
    inout flash_io2,
    inout flash_io3,
);

    wire conf_sel  = 1'b0;
    wire flash_sel = i_wb_cyc && !conf_sel;


    // Flash interface
    wire flash_io0_oe, flash_io0_do, flash_io0_di;
    wire flash_io1_oe, flash_io1_do, flash_io1_di;
    wire flash_io2_oe, flash_io2_do, flash_io2_di;
    wire flash_io3_oe, flash_io3_do, flash_io3_di;

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) flash_io_buf [3:0] (
        .PACKAGE_PIN({flash_io3, flash_io2, flash_io1, flash_io0}),
        .OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
        .D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
        .D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
    );

    always @(posedge i_wb_clk) begin
        if (flash_sel) begin
            o_wb_ack <= o_wb_ack_spiflash;
            o_wb_rdt <= o_wb_rdt_spiflash;
        end else if (conf_sel) begin
            o_wb_ack <= o_wb_ack_spiflash;
            o_wb_rdt <= o_wb_rdt_spiflash_conf;
        end else begin
            o_wb_ack <= 0;
            o_wb_rdt <= 0;
        end
    end

    // SPI Memory from 0x0010_0000 to 0x0200_0000
    wire [31:0] 	o_wb_rdt_spiflash;
    wire [31:0] 	o_wb_rdt_spiflash_conf;
    wire          o_wb_ack_spiflash;

    spimemio spimemio (
        .clk    (i_wb_clk),
        .resetn (!reset),
        .valid  (flash_sel),
        .ready  (o_wb_ack_spiflash),
        .addr   (i_wb_adr[23:0]),
        .rdata  (o_wb_rdt_spiflash),

        .flash_csb    (flash_csb),
        .flash_clk    (flash_clk),

        .flash_io0_oe (flash_io0_oe),
        .flash_io1_oe (flash_io1_oe),
        .flash_io2_oe (flash_io2_oe),
        .flash_io3_oe (flash_io3_oe),

        .flash_io0_do (flash_io0_do),
        .flash_io1_do (flash_io1_do),
        .flash_io2_do (flash_io2_do),
        .flash_io3_do (flash_io3_do),

        .flash_io0_di (flash_io0_di),
        .flash_io1_di (flash_io1_di),
        .flash_io2_di (flash_io2_di),
        .flash_io3_di (flash_io3_di),

        .cfgreg_we(conf_sel ? i_wb_sel : 4'b 0000),
        .cfgreg_di(i_wb_dat),
        .cfgreg_do(o_wb_rdt_spiflash_conf)
    );

endmodule
