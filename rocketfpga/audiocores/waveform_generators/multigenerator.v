`default_nettype none

module sinetable #(
    parameter BITSIZE = 24,
    parameter PHASESIZE = 16,
    parameter TABLESIZE = 9,
)( 
    input wire clk,
    output reg [BITSIZE-1:0] out,
    input wire [TABLESIZE-1:0] index,
);
    reg	[BITSIZE-1:0] quartertable [0:((2**TABLESIZE)-1)];

    if (BITSIZE == 24) begin
        if (TABLESIZE == 12) begin
            initial	$readmemh("quartersinetable_24bits_depth12.hex", quartertable);
        end else if (TABLESIZE == 10) begin
            initial	$readmemh("quartersinetable_24bits_depth10.hex", quartertable);
        end else if (TABLESIZE == 9) begin
            initial	$readmemh("quartersinetable_24bits_depth9.hex", quartertable);
        end
    end else if (BITSIZE == 16) begin
        if (TABLESIZE == 12) begin
            initial	$readmemh("quartersinetable_16bits_depth12.hex", quartertable);
        end else if (TABLESIZE == 11) begin
            initial	$readmemh("quartersinetable_16bits_depth11.hex", quartertable);
        end else if (TABLESIZE == 10) begin
            initial	$readmemh("quartersinetable_16bits_depth10.hex", quartertable);
        end else if (TABLESIZE == 9) begin
            initial	$readmemh("quartersinetable_16bits_depth9.hex", quartertable);
        end
    end

    always @(posedge clk) begin
        out <= quartertable[index];
    end
endmodule

module multigenerator #(
	parameter BITSIZE = 24,
    parameter PHASESIZE = 16,
    parameter TABLESIZE = 9,
)(	
    input wire lrclk,
    input wire bclk,
    input wire osc,

	input wire enable_1,
	input wire enable_2,
	input wire enable_3,
	input wire enable_4,

    input wire [1:0]    type_1,
    input wire [1:0]    type_2,
    input wire [1:0]    type_3,
    input wire [1:0]    type_4,

    input wire [PHASESIZE-1:0]	freq_1,
    input wire [PHASESIZE-1:0]	freq_2,
    input wire [PHASESIZE-1:0]	freq_3,
    input wire [PHASESIZE-1:0]	freq_4,

	output reg [BITSIZE-1:0] out_1,
	output reg [BITSIZE-1:0] out_2,
	output reg [BITSIZE-1:0] out_3,
	output reg [BITSIZE-1:0] out_4,
);

wire [BITSIZE-1:0] table_out;
reg [TABLESIZE-1:0] table_index;
sinetable #(
    .BITSIZE(BITSIZE),
    .PHASESIZE(PHASESIZE),
    .TABLESIZE(TABLESIZE),
) T1 (
    .clk(osc),
    .out(table_out),
    .index(table_index),
);

reg [PHASESIZE-1:0]	phase_1;
reg [PHASESIZE-1:0]	phase_2;
reg [PHASESIZE-1:0]	phase_3;
reg [PHASESIZE-1:0]	phase_4;

reg	[1:0] negate_1;
reg	[1:0] negate_2;
reg	[1:0] negate_3;
reg	[1:0] negate_4;

reg signed [BITSIZE-1:0] val_1;
reg signed [BITSIZE-1:0] val_2;
reg signed [BITSIZE-1:0] val_3;
reg signed [BITSIZE-1:0] val_4;

reg [4:0] counter;

always @(posedge lrclk) begin
	phase_1 <= phase_1 + freq_1;
	phase_2 <= phase_2 + freq_2;
	phase_3 <= phase_3 + freq_3;
	phase_4 <= phase_4 + freq_4;
end

always @(posedge bclk) begin
    
    if (lrclk) begin
        counter <= 0;
    end 
    
    if (counter == 0) begin
        if (type_1 == 0) begin
            // Sine generation part 1
            negate_1[0] <= phase_1[(PHASESIZE-1)];
            if (phase_1[(PHASESIZE-2)])
                table_index <= ~phase_1[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            else
                table_index <=  phase_1[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            counter <= counter + 1;
        end else if (type_1 == 1) begin
            // Ramp generation
            out_1 <= phase_1[PHASESIZE-1 -: BITSIZE];
            counter <= counter + 2;
        end else if (type_1 == 2) begin
            // Square generation
            out_1 <= {phase_1[PHASESIZE-1],{(BITSIZE-1){~phase_1[PHASESIZE-1]}}};
            counter <= counter + 2;
        end else if (type_1 == 3) begin
            // Triangle generation
            if (phase_1[PHASESIZE-1] && phase_1[PHASESIZE-2])
                out_1 <= {1'b0, ~phase_1[PHASESIZE-3 -: BITSIZE-1]};
            else if (phase_1[PHASESIZE-1] && !phase_1[PHASESIZE-2])
                out_1 <= {1'b0, phase_1[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_1[PHASESIZE-1] && phase_1[PHASESIZE-2])
                out_1 <= {1'b1, phase_1[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_1[PHASESIZE-1] && !phase_1[PHASESIZE-2])
                out_1 <= {1'b1, ~phase_1[PHASESIZE-3 -: BITSIZE-1]};
        end   
    end else if (counter == 1) begin
        val_1 <= table_out;

        negate_1[1] <= negate_1[0];

        if (negate_1[1])
            out_1 <= enable_1 ? -val_1 : 0;
        else
            out_1 <= enable_1 ? val_1 : 0;
        
        counter <= counter + 1;
    end else if (counter == 2) begin
        if (type_2 == 0) begin
            negate_2[0] <= phase_2[(PHASESIZE-1)];
            if (phase_2[(PHASESIZE-2)])
                table_index <= ~phase_2[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            else
                table_index <=  phase_2[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            counter <= counter + 1;
        end else if (type_2 == 1) begin
            // Ramp generation
            out_2 <= phase_2[PHASESIZE-1 -: BITSIZE];
            counter <= counter + 2;
        end else if (type_2 == 2) begin
            // Square generation
            out_2 <= {phase_2[PHASESIZE-1],{(BITSIZE-1){~phase_2[PHASESIZE-1]}}};
            counter <= counter + 2;
        end else if (type_2 == 3) begin
            // Triangle generation
            if (phase_2[PHASESIZE-1] && phase_2[PHASESIZE-2])
                out_2 <= {1'b0, ~phase_2[PHASESIZE-3 -: BITSIZE-1]};
            else if (phase_2[PHASESIZE-1] && !phase_2[PHASESIZE-2])
                out_2 <= {1'b0, phase_2[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_2[PHASESIZE-1] && phase_2[PHASESIZE-2])
                out_2 <= {1'b1, phase_2[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_2[PHASESIZE-1] && !phase_2[PHASESIZE-2])
                out_2 <= {1'b1, ~phase_2[PHASESIZE-3 -: BITSIZE-1]};
        end   
    end else if (counter == 3) begin
        val_2 <= table_out;

        negate_2[1] <= negate_2[0];

        if (negate_2[1])
            out_2 <= enable_2 ? -val_2 : 0;
        else
            out_2 <= enable_2 ? val_2 : 0;
        
        counter <= counter + 1;
    end else if (counter == 4) begin
        if (type_3 == 0) begin
            negate_3[0] <= phase_3[(PHASESIZE-1)];
            if (phase_3[(PHASESIZE-2)])
                table_index <= ~phase_3[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            else
                table_index <=  phase_3[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
            counter <= counter + 1;
        end else if (type_3 == 1) begin
            // Ramp generation
            out_3 <= phase_3[PHASESIZE-1 -: BITSIZE];
            counter <= counter + 2;
        end else if (type_3 == 2) begin
            // Square generation
            out_3 <= {phase_3[PHASESIZE-1],{(BITSIZE-1){~phase_3[PHASESIZE-1]}}};
            counter <= counter + 2;
        end else if (type_3 == 3) begin
            // Triangle generation
            if (phase_3[PHASESIZE-1] && phase_3[PHASESIZE-2])
                out_3 <= {1'b0, ~phase_3[PHASESIZE-3 -: BITSIZE-1]};
            else if (phase_3[PHASESIZE-1] && !phase_3[PHASESIZE-2])
                out_3 <= {1'b0, phase_3[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_3[PHASESIZE-1] && phase_3[PHASESIZE-2])
                out_3 <= {1'b1, phase_3[PHASESIZE-3 -: BITSIZE-1]};
            else if (!phase_3[PHASESIZE-1] && !phase_3[PHASESIZE-2])
                out_3 <= {1'b1, ~phase_3[PHASESIZE-3 -: BITSIZE-1]};
        end   
    end else if (counter == 5) begin
        val_3 <= table_out;

        negate_3[1] <= negate_3[0];

        if (negate_3[1])
            out_3 <= enable_3 ? -val_3 : 0;
        else
            out_3 <= enable_3 ? val_3 : 0;
        
        counter <= counter + 1;

    end
    // end else if (counter == 6) begin
    //     if (type_4 == 0) begin
    //         negate_4[0] <= phase_4[(PHASESIZE-1)];
    //         if (phase_4[(PHASESIZE-2)])
    //             table_index <= ~phase_4[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
    //         else
    //             table_index <=  phase_4[PHASESIZE-3:PHASESIZE-TABLESIZE-2];
    //         counter <= counter + 1;
    //     end else if (type_4 == 1) begin
    //         // Ramp generation
    //         out_4 <= phase_4[PHASESIZE-1 -: BITSIZE];
    //         counter <= counter + 2;
    //     end else if (type_4 == 2) begin
    //         // Square generation
    //         out_4 <= {phase_4[PHASESIZE-1],{(BITSIZE-1){~phase_4[PHASESIZE-1]}}};
    //         counter <= counter + 2;
    //     end else if (type_4 == 3) begin
    //         // Triangle generation
    //         if (phase_4[PHASESIZE-1] && phase_4[PHASESIZE-2])
    //             out_1 <= {1'b0, ~phase_4[PHASESIZE-3 -: BITSIZE-1]};
    //         else if (phase_4[PHASESIZE-1] && !phase_4[PHASESIZE-2])
    //             out_1 <= {1'b0, phase_4[PHASESIZE-3 -: BITSIZE-1]};
    //         else if (!phase_4[PHASESIZE-1] && phase_4[PHASESIZE-2])
    //             out_1 <= {1'b1, phase_4[PHASESIZE-3 -: BITSIZE-1]};
    //         else if (!phase_4[PHASESIZE-1] && !phase_4[PHASESIZE-2])
    //             out_1 <= {1'b1, ~phase_4[PHASESIZE-3 -: BITSIZE-1]};
    //     end   
    // end else if (counter == 7) begin
    //     val_4 <= table_out;

    //     negate_4[1] <= negate_4[0];

    //     if (negate_4[1])
    //         out_4 <= enable_4 ? -val_4 : 0;
    //     else
    //         out_4 <= enable_4 ? val_4 : 0;
        
    //     counter <= counter + 1;
    // end
end


endmodule