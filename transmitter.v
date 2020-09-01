module transmitter(input clk,reset,transmit,input [7:0] data,output reg TxD);

reg [3:0] bitcounter=0;
reg [13:0] counter=0;
reg state,next_state;
reg [9:0] right_sh_reg=0;
reg shift,load,clear;

//clock divider to generate clock of 9600 Hz
reg baud_clk = 1'b0;
always@(posedge clk)
begin
    if(counter<10415) begin
        counter <= counter + 1'b1;
    end
    else begin
        counter <= 0;
        baud_clk <= ~baud_clk;
    end        
end

//Mealy FSM
parameter IDLE=1'b0,TRANSMIT=1'b1;
always@(state or transmit or bitcounter)
begin
    case(state)
    IDLE:begin
            if(transmit==1'b1)
                next_state = TRANSMIT;
            else
                next_state = IDLE;
         end
    TRANSMIT:begin
                if(bitcounter<9)
                   next_state = TRANSMIT; 
                else
                    next_state = IDLE;
             end
     endcase
end

always@(posedge clk or negedge reset)
begin
    if(reset==1'b0)
        state = IDLE;
    else if(counter==10415)
        state = next_state;
end

always@(state or transmit or bitcounter)
begin
    case(state)
    IDLE:begin
            if(transmit==1'b0)
                {shift,load,clear} <= 3'b000;
            else
                {shift,load,clear} <= 3'b010;
            
            TxD <= 1'b1;
         end
    TRANSMIT:begin
                if(bitcounter < 9)
                    {shift,load,clear} <= 3'b100;
                else
                    {shift,load,clear} <= 3'b001;
                    
                TxD <= right_sh_reg[0];
             end
     endcase
end

always@(posedge clk)
begin
    if(counter==10415)
    begin
        if({shift,load,clear}==3'b010)
        begin
            right_sh_reg = {1'b1,data,1'b0};
            bitcounter = 0;
        end
        else if({shift,load,clear}==3'b100)
        begin
            right_sh_reg = right_sh_reg>>1;
            bitcounter = bitcounter + 1;
        end
        else if({shift,load,clear}==3'b001)
        begin
            //right_sh_reg <= 10'b1;
            bitcounter = 0;
        end
    end
end


endmodule        







/*
genvar i;
generate
for(i=8;i>0;i=i-1)
begin
    always@(posedge baud_clk)
    begin
        right_sh_reg[i] <= right_sh_reg[i+1];
    end
end
endgenerate
*/

