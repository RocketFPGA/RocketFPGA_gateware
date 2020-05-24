
module matrix #(
    parameter BITSIZE = 16,
)(
    input clk,

    input [BITSIZE-1:0] in1,
    input [BITSIZE-1:0] in2,
    input [BITSIZE-1:0] in3,
    input [BITSIZE-1:0] in4,
    input [BITSIZE-1:0] in5,
    input [BITSIZE-1:0] in6,
    input [BITSIZE-1:0] in7,
    input [BITSIZE-1:0] in8,
    input [BITSIZE-1:0] in9,

    output reg [BITSIZE-1:0] out1,
    output reg [BITSIZE-1:0] out2,
    output reg [BITSIZE-1:0] out3,
    output reg [BITSIZE-1:0] out4,
    output reg [BITSIZE-1:0] out5,
    output reg [BITSIZE-1:0] out6,
    output reg [BITSIZE-1:0] out7,
    output reg [BITSIZE-1:0] out8,
    output reg [BITSIZE-1:0] out9,
    output reg [BITSIZE-1:0] out10,
    output reg [BITSIZE-1:0] out11,

    input [3:0] sel_out1,
    input [3:0] sel_out2,
    input [3:0] sel_out3,
    input [3:0] sel_out4,
    input [3:0] sel_out5,
    input [3:0] sel_out6,
    input [3:0] sel_out7,
    input [3:0] sel_out8,
    input [3:0] sel_out9,
    input [3:0] sel_out10,
    input [3:0] sel_out11,

);
always @(posedge clk) begin
   case (sel_out1)
      0: out1 <= 0;
      1: out1 <= in1;
      2: out1 <= in2;
      3: out1 <= in3;
      4: out1 <= in4;
      5: out1 <= in5;
      6: out1 <= in6;
      7: out1 <= in7;
      8: out1 <= in8;
      9: out1 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out2)
      0: out2 <= 0;
      1: out2 <= in1;
      2: out2 <= in2;
      3: out2 <= in3;
      4: out2 <= in4;
      5: out2 <= in5;
      6: out2 <= in6;
      7: out2 <= in7;
      8: out2 <= in8;
      9: out2 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out3)
      0: out3 <= 0;
      1: out3 <= in1;
      2: out3 <= in2;
      3: out3 <= in3;
      4: out3 <= in4;
      5: out3 <= in5;
      6: out3 <= in6;
      7: out3 <= in7;
      8: out3 <= in8;
      9: out3 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out4)
      0: out4 <= 0;
      1: out4 <= in1;
      2: out4 <= in2;
      3: out4 <= in3;
      4: out4 <= in4;
      5: out4 <= in5;
      6: out4 <= in6;
      7: out4 <= in7;
      8: out4 <= in8;
      9: out4 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out5)
      0: out5 <= 0;
      1: out5 <= in1;
      2: out5 <= in2;
      3: out5 <= in3;
      4: out5 <= in4;
      5: out5 <= in5;
      6: out5 <= in6;
      7: out5 <= in7;
      8: out5 <= in8;
      9: out5 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out6)
      0: out6 <= 0;
      1: out6 <= in1;
      2: out6 <= in2;
      3: out6 <= in3;
      4: out6 <= in4;
      5: out6 <= in5;
      6: out6 <= in6;
      7: out6 <= in7;
      8: out6 <= in8;
      9: out6 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out7)
      0: out7 <= 0;
      1: out7 <= in1;
      2: out7 <= in2;
      3: out7 <= in3;
      4: out7 <= in4;
      5: out7 <= in5;
      6: out7 <= in6;
      7: out7 <= in7;
      8: out7 <= in8;
      9: out7 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out8)
      0: out8 <= 0;
      1: out8 <= in1;
      2: out8 <= in2;
      3: out8 <= in3;
      4: out8 <= in4;
      5: out8 <= in5;
      6: out8 <= in6;
      7: out8 <= in7;
      8: out8 <= in8;
      9: out8 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out9)
      0: out9 <= 0;
      1: out9 <= in1;
      2: out9 <= in2;
      3: out9 <= in3;
      4: out9 <= in4;
      5: out9 <= in5;
      6: out9 <= in6;
      7: out9 <= in7;
      8: out9 <= in8;
      9: out9 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out10)
      0: out10 <= 0;
      1: out10 <= in1;
      2: out10 <= in2;
      3: out10 <= in3;
      4: out10 <= in4;
      5: out10 <= in5;
      6: out10 <= in6;
      7: out10 <= in7;
      8: out10 <= in8;
      9: out10 <= in9;
   endcase
end

always @(posedge clk) begin
   case (sel_out11)
      0: out11 <= 0;
      1: out11 <= in1;
      2: out11 <= in2;
      3: out11 <= in3;
      4: out11 <= in4;
      5: out11 <= in5;
      6: out11 <= in6;
      7: out11 <= in7;
      8: out11 <= in8;
      9: out11 <= in9;
   endcase
end

endmodule


//matrix #( 
//   .BITSIZE(BITSIZE),
//) M9x11 (
//   .clk9(),
//   .in1(),
//   .in2(),
//   .in3(),
//   .in4(),
//   .in5(),
//   .in6(),
//   .in7(),
//   .in8(),
//   .in9(),

//   .out1(),
//   .out2(),
//   .out3(),
//   .out4(),
//   .out5(),
//   .out6(),
//   .out7(),
//   .out8(),
//   .out9(),
//   .out10(),
//   .out11(),

//   .sel_out1(),
//   .sel_out2(),
//   .sel_out3(),
//   .sel_out4(),
//   .sel_out5(),
//   .sel_out6(),
//   .sel_out7(),
//   .sel_out8(),
//   .sel_out9(),
//   .sel_out10(),
//   .sel_out11(),
//);

