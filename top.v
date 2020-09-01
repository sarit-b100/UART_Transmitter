module top(
input [7:0]sw,
input btn0,
input btn1,
input clk,
output TxD
//output TxD_debug,
//output transmit_debug,
//output button_debug, 
//output clk_debug
); 

wire transmit;
/*assign TxD_debug = TxD;
assign transmit_debug = transmit;
assign button_debug = btn1;
assign clk_debug = clk;*/

//generating slow_clk for debouncing T=500 us
//the baud rate is 9600 Hz which for transfering 10 bits takes 1.042 ms
//thus the transmit signal(input from push button) should have a pulse less than
//1.042 ms so that the character is transmitted only once 

reg [14:0]counter=0;
reg slow_clk=1'b0;
always @(posedge clk)
begin
    if(counter < 25000)
        counter <= counter + 1'b1;
    else begin
        counter <= 0;
        slow_clk <= ~slow_clk;
    end
end


Debounce D2(btn1,slow_clk,transmit);
transmitter T1(.clk(clk), .reset(btn0),.transmit(transmit),.TxD(TxD),.data(sw));


endmodule