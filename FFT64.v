`timescale 1ns / 1ps


module FFT64(
    
    clk,
    reset,
    data_enable,
    dataReal,
    dataImg,
    out_enable,
    outReal,
    outImg
);

    parameter WIDTH = 16;
    
    input  clk , reset;
    input  data_enable;
    input  [WIDTH-1 : 0] dataReal , dataImg;
    output out_enable;
    output [WIDTH-1 : 0] outReal , outImg;
    
    //wires for SDF stages
    //64-point FFT will require three radix 2^2 stages
    wire sdf1_out_en;
    wire [WIDTH-1 : 0] sdf1_out_real;
    wire [WIDTH-1 : 0] sdf1_out_img;
    wire sdf2_out_en;
    wire [WIDTH-1 : 0] sdf2_out_real;
    wire [WIDTH-1 : 0] sdf2_out_img;
    
    SDF64 sdf1(
        
        .clk(clk),
        .reset(reset),
        .In_en(data_enable),
        .In_real(dataReal),
        .In_img(dataImg),
        .Out_en(sdf1_out_en),
        .Out_real(sdf1_out_real),
        .Out_img(sdf1_out_img)
        
    );
    
    defparam sdf1.WIDTH      = WIDTH;
    defparam sdf1.FFT_POINTS = 64;
    defparam sdf1.RESOLUTION = 64;
    
    SDF64 sdf2(
        
        .clk(clk),
        .reset(reset),
        .In_en(sdf1_out_en),
        .In_real(sdf1_out_real),
        .In_img(sdf1_out_img),
        .Out_en(sdf2_out_en),
        .Out_real(sdf2_out_real),
        .Out_img(sdf2_out_img)
        
    );
    
    defparam sdf2.WIDTH      = WIDTH;
    defparam sdf2.FFT_POINTS = 64;
    defparam sdf2.RESOLUTION = 16;
    
    
    SDF64 sdf3(
        
        .clk(clk),
        .reset(reset),
        .In_en(sdf2_out_en),
        .In_real(sdf2_out_real),
        .In_img(sdf2_out_img),
        .Out_en(out_enable),
        .Out_real(outReal),
        .Out_img(outImg)
        
    );
    
    defparam sdf3.WIDTH      = WIDTH;
    defparam sdf3.FFT_POINTS = 64;
    defparam sdf3.RESOLUTION = 4;
    
    
    
    

endmodule
