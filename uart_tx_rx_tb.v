

module tx_rx_tb();
reg clk = 0;
reg start = 0;
reg [7:0] txin; 

wire [7:0] rxout;
wire rxdone, txdone; 

wire txrx; /// to connect tx and rx together. // agenda is to compare tx and rxout

top dut (clk, start, txin, txrx, txrx, rxout, rxdone, txdone);

integer i = 0;

initial begin
start = 1;
for(i = 0; i < 10; i = i + 1) begin
txin =  $urandom_range(10, 200); //keep in mind data is 8 bit, so the value in it cant exceed 256. 200 is safe
@(posedge rxdone);
@(posedge txdone);
end
$stop;
end

always #5 clk = ~clk;


endmodule
