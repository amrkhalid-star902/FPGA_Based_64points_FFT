`timescale 1ns / 1ps


module DelayFIFO(
    
    clk,
    dataIn_real,
    dataIn_img,
    dataOut_real,
    dataOut_img
    
);

    parameter WIDTH = 16;
    parameter DEPTH = 32;
    
    input clk;
    input [WIDTH-1 : 0] dataIn_real;
    input [WIDTH-1 : 0] dataIn_img;
    output [WIDTH-1 : 0] dataOut_real;
    output [WIDTH-1 : 0] dataOut_img;
    
    
    reg [WIDTH-1 : 0] buffer_real [DEPTH-1 : 0];
    reg [WIDTH-1 : 0] buffer_img  [DEPTH-1 : 0];
    integer i;
    
    always@(posedge clk)
    begin
    
        for(i = DEPTH - 1 ; i > 0 ; i = i - 1)
        begin
        
            buffer_real[i] <= buffer_real[i - 1];
            buffer_img[i]  <= buffer_img[i - 1];
        
        end
        
        buffer_real[0] <= dataIn_real;
        buffer_img[0]  <= dataIn_img;
    
    end
    
    assign dataOut_real = buffer_real[DEPTH - 1];
    assign dataOut_img  = buffer_img[DEPTH - 1];

endmodule
