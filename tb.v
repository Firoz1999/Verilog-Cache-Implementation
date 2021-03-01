`include "cache.v"
module top;

reg clk;

////
reg dc_is_read;
reg [15:0] dc_read_address,dc_write_address,dc_data_in;
wire [15:0] dc_data_out;
wire dc_is_read_hit,dc_is_write_hit;
/////

/////
reg [15:0] ic_read_address;
wire ic_is_read_hit;
wire [15:0] ic_inst_out;
/////

cache c1(clk,dc_is_read_hit,dc_is_write_hit,dc_is_read,dc_read_address,dc_write_address,dc_data_in,dc_data_out,
        ic_read_address,ic_is_read_hit,ic_inst_out);

initial
  begin
    clk <= 0;
    forever #10 clk <= ~clk;
  end
initial #130 $finish;

initial
begin
#10 dc_is_read=1; dc_read_address=16'd9; $monitor("%2t dc_is_read = %b  dc_read_address = %b  dc_is_read_hit = %b  dc_data_out = %h",$time,dc_is_read,dc_read_address,dc_is_read_hit,dc_data_out);
#20 dc_is_read=1; dc_read_address=16'd9; $monitor("%2t dc_is_read = %b  dc_read_address = %b  dc_is_read_hit = %b  dc_data_out = %h",$time,dc_is_read,dc_read_address,dc_is_read_hit,dc_data_out);
#20 dc_is_read=0; dc_write_address=16'd9; dc_data_in=16'd0; $monitor("%2t dc_is_read = %b  dc_write_address = %b  dc_is_write_hit = %b  dc_data_in = %h",$time,dc_is_read,dc_write_address,dc_is_write_hit,dc_data_in);
#20 dc_is_read=1; dc_read_address=16'b01_00000000001_001; $monitor("%2t dc_is_read = %b  dc_read_address = %b  dc_is_read_hit = %b  dc_data_out = %h",$time,dc_is_read,dc_read_address,dc_is_read_hit,dc_data_out);
#20 dc_is_read=1; dc_read_address=16'd9; $monitor("%2t dc_is_read = %b  dc_read_address = %b  dc_is_read_hit = %b  dc_data_out = %h\n--------------------",$time,dc_is_read,dc_read_address,dc_is_read_hit,dc_data_out);

#20 ic_read_address=16'd20; $monitor("%2t ic_read_address =%b  ic_is_read_hit = %b  ic_inst_out = %h",$time,ic_read_address,ic_is_read_hit,ic_inst_out);
#20 ic_read_address=16'd20; $monitor("%2t ic_read_address =%b  ic_is_read_hit = %b  ic_inst_out = %h\n--------------------",$time,ic_read_address,ic_is_read_hit,ic_inst_out);

#20 dc_is_read=1; dc_read_address=16'd5; ic_read_address=16'd28; $monitor("%2t dc_is_read = %b  dc_read_address = %b  dc_is_read_hit = %b  dc_data_out = %h\n  ic_read_address =%b   ic_is_read_hit = %b  ic_inst_out = %h",$time,dc_is_read,dc_read_address,dc_is_read_hit,dc_data_out,ic_read_address,ic_is_read_hit,ic_inst_out);

end

endmodule
