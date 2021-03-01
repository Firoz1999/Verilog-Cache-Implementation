module ram();
reg [1:0] [7:0] ram [3:0];
initial
begin
  $readmemh("rram.txt", ram);
end

always@*
	$display("r = %b",ram[3][1]);
endmodule

