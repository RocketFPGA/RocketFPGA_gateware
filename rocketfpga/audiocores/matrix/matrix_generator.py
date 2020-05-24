import math

ins = 9
outs = 11

v = """
module matrix #(
    parameter BITSIZE = 16,
)(
    input clk,\n
"""

for i in range(ins):
    v = v + "    input [BITSIZE-1:0] in{:d},\n".format(i+1)
v = v + "\n"

for o in range(outs):
    v = v + "    output reg [BITSIZE-1:0] out{:d},\n".format(o+1)
v = v + "\n"

sel_width = math.ceil(math.log(ins+1,2))
# sel_width = 8
for o in range(outs):
    v = v + "    input [{:d}:0] sel_out{:d},\n".format(sel_width-1, o+1)
v = v + "\n"

v = v + ");\n"

for o in range(outs):
    v = v + "always @(posedge clk) begin\n"
    v = v + "   case (sel_out{:d})\n".format(o+1)
    v = v + "      0: out{:d} <= 0;\n".format(o+1)
    for i in range(ins):
        v = v + "      {:d}: out{:d} <= in{:d};\n".format(i+1, o+1, i+1)
    v = v + "   endcase\n"
    v = v + "end\n\n"


v = v + "endmodule\n"

print(v)

# Instantiation

v = """
//matrix #( 
//   .BITSIZE(BITSIZE),
//) M{:d}x{:d} (\n""".format(ins,outs)

v = v + "//   .clk{:d}(),\n".format(i+1)

for i in range(ins):
    v = v + "//   .in{:d}(),\n".format(i+1)
v = v + "\n"

for o in range(outs):
    v = v + "//   .out{:d}(),\n".format(o+1)
v = v + "\n"

sel_width = math.ceil(math.log(ins,2))
for o in range(outs):
    v = v + "//   .sel_out{:d}(),\n".format(o+1)
v = v + "//);\n"

# //		.enable(triggers[5]),
# //		.bclk (BCLK), 
# //		.lrclk (ADCLRC),
# //		.offset(echo_offset),
# //		.in (mult_out),
# //		.out (echo_out),
# //	);

print(v)

