`default_nettype none

module rocketcpu_random_generator (
   input wire        i_wb_clk,
   output reg [31:0] o_wb_rdt,
);
   reg [31:0] data = 32'hFFFFFFFF;
   wire feedback = data[20] ^ data[1] ;

   always @(posedge i_wb_clk) begin
      data <= {data[31:0], feedback};
      o_wb_rdt <= data;
   end

endmodule
