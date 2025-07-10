`timescale 1ns / 1ps


module top(
input clk,
input start,
input [7:0] txin, // the 8 bit data that is to be transmitted
output reg tx, //output transmitter
input rx,
output [7:0] rxout,
output rxdone, txdone  /// flags to mark completion of an operation
);

parameter clk_value = 100_000, baud = 9600;
parameter wait_count = clk_value/baud; //determines when to trigger the trigger signal

reg bitDone = 0;
integer count = 0;
parameter idle = 0, send = 1, check = 2;
reg[1:0] state = idle;


//generating trigger for baud rate

always@(posedge clk) begin
    if(state == idle) begin
        count <= 0;
    end
    
    else begin
        if(count ==  wait_count) begin
            bitDone <= 1; // trigger generated
            count <= 0; //count is reset
        end
        
        else begin
            count <= count + 1;
            bitDone <= 0;
        
        end
    end

end

////transmission TX Logic ///

reg [9:0] txData;  /// | 1 start bit | 8 data bits | 1 stop bit | = 10 bits
integer bitIndex = 0; //track of no of data bits sent so far
reg[9:0] shifttx = 0; //only for debugging, not needed if code is working fine

always@(posedge clk) begin
    case(state) 
        idle: begin
                tx <= 1'b1;  ///idle state holds logic 1 forever until start bit
                txData <= 0; //no data from user yet
                bitIndex <= 0; //obv no bits sent yet so bitIndex = 0
                shifttx <= 0;
         
                if(start == 1) begin
                    txData <= {1'b1, txin, 1'b0}; ///whole 10 bits now updated, first the 0 is sent, then the txin, then 1: which completes the transmission
                    state <= send;
                end
                
                else begin
                    state <= idle; //if start isnt asserted, stay in idle
                end
              end


        send: begin
                tx <= txData[bitIndex]; //when u start, bitIndex is 0, hence txData[0] is sent first, then bitIndex would be updated to 1, and so on...
                state <= check;
                shifttx <= {txData[bitIndex], shifttx[9:1]};        
              end
              
              
        check: begin
                if(bitIndex <= 9) /// i.e. full transmission hasnt completed yet 
                    begin
                        if(bitDone == 1'b1) 
                            begin
                                state <= send;
                                bitIndex = bitIndex + 1;
                            end
                    end
                else begin    //bitIndex = 10, so go back to idle, where tx will be made HIGH again
                    state <= idle;
                    bitIndex <= 0;
                end
                
               
               end
        
        default: state <= idle;

    endcase

end

assign txdone = (bitIndex == 9 && bitDone == 1'b1) ? 1 : 0; //self explanatory


////Receiver RX Logic//
integer rcount = 0; //tells us when we reach the middle of bit duration
integer rindex = 0; //counts no of bits received so far

parameter ridle = 0, rwait = 1, recv = 2, rcheck = 3;
reg [1:0] rstate;
reg [9:0] rxdata;

always@(posedge clk) begin
    case(rstate)
        ridle: begin
                    rxdata <= 0;
                    rindex <= 0;
                    rcount <= 0;
                    
                        if(rx == 0) //signals start of transmission
                        begin
                            rstate <= rwait; 
                        end
                        
                        else begin
                            rstate <= ridle;
                        end
                        
                end     
                

        rwait: begin
                
                if(rcount < wait_count / 2) //waiting until middle of bit duration
                    begin
                        rcount <= rcount + 1;
                        rstate <= rwait;
                    end
            
                    else begin
/*data sampling  */     rcount <= 0;
                        rstate <= recv;
                        rxdata <= {rx, rxdata[9:1]}; //once we get to the middle, rxdata is updated with the data that is on rx bit, and the data is shifted one bit to right
                                                     // after ten cycles, the bit that is stored first(rx), will move to lsb side
                    end
                
                end
                

        recv: begin
                if(rindex <= 9) begin
                    if(bitDone == 1) begin
                        rindex <= rindex + 1;
                        rstate <= rwait;  //go back to rwait to sample the next data
                    end
                
                end
        
                else begin
                    rstate <= ridle;
                    rindex <= 0;
                end
             
              end
        
        
        default: rstate <= idle;
        
    endcase      

end

assign rxout = rxdata[8:1]; // 0 is start condn, 9 is stop condn
assign rxdone = (rindex == 9 && bitDone == 1) ? 1 : 0;


endmodule

///
