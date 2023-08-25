`timescale 1ns / 1ps
/*
*  Single Path Feedback Delay Unit 
*/

module SDF64(
    
    clk,
    reset,
    In_en,
    In_real,
    In_img,
    Out_en,
    Out_real,
    Out_img
    
);

    parameter WIDTH       = 16;
    parameter FFT_POINTS  = 64;
    parameter RESOLUTION  = 64;
    
    input clk;
    input reset;
    input In_en;
    input [WIDTH-1 : 0] In_real;
    input [WIDTH-1 : 0] In_img;
    output Out_en;
    output [WIDTH-1 : 0] Out_real;
    output [WIDTH-1 : 0] Out_img;
    
    localparam N = $clog2(FFT_POINTS);       //Bit length of FFT points
    localparam M = $clog2(RESOLUTION);       //Bit length of Twidle Resolution
    
     
     // First Butterfly
     reg [N-1 : 0]       dataIn_count;    //Counter to keep track of input data
     wire                bf1_en;          //enable add/sub operations of butterfly
     wire [WIDTH-1 : 0]  bf1_x0_real;     //real part of first input to the butterfly
     wire [WIDTH-1 : 0]  bf1_x0_img;      //imaginary part of first input to the butterfly
     wire [WIDTH-1 : 0]  bf1_x1_real;     //real part of second input to the butterfly
     wire [WIDTH-1 : 0]  bf1_x1_img;      //imaginary part of second input to the butterfly   
     wire [WIDTH-1 : 0]  bf1_y0_real;     //real part of first output data of butterfly
     wire [WIDTH-1 : 0]  bf1_y0_img;      //imaginary part of first output data of butterfly
     wire [WIDTH-1 : 0]  bf1_y1_real;     //real part of second output data of butterfly
     wire [WIDTH-1 : 0]  bf1_y1_img;      //imaginary part of second output data of butterfly
     wire [WIDTH-1 : 0]  bufferIn1_real;  //real part of input data to Delay buffer
     wire [WIDTH-1 : 0]  bufferIn1_img;   //imaginary part of input data to Delay buffer
     wire [WIDTH-1 : 0]  bufferOut1_real; //real part of output data from Delay buffer
     wire [WIDTH-1 : 0]  bufferOut1_img;  //imaginary part of output data from Delay buffer
     wire [WIDTH-1 : 0]  bf1_sp_real;     //real part of Single-Path Data Output
     wire [WIDTH-1 : 0]  bf1_sp_img;      //imaginary part of Single-Path Data Output
     reg                 bf1_sp_en;       //enable signal for the output of single path data
     reg  [N-1 : 0]      bf1_count;       //count of the single path data
     wire                bf1_start;       //trigger signal
     wire                bf1_end;         //end of the stream of single path data
     wire                bf1_mult_j;      //enable multplying by imaginary number j
     reg  [WIDTH-1 : 0]  bf1_dataOut_real;//real part of output data of the first butterfly
     reg  [WIDTH-1 : 0]  bf1_dataOut_img; //real part of output data of the first butterfly


     // second Butterfly
     reg                 bf2_en;          //enable add/sub operations of butterfly
     wire [WIDTH-1 : 0]  bf2_x0_real;     //real part of first input to the butterfly
     wire [WIDTH-1 : 0]  bf2_x0_img;      //imaginary part of first input to the butterfly
     wire [WIDTH-1 : 0]  bf2_x1_real;     //real part of second input to the butterfly
     wire [WIDTH-1 : 0]  bf2_x1_img;      //imaginary part of second input to the butterfly   
     wire [WIDTH-1 : 0]  bf2_y0_real;     //real part of first output data of butterfly
     wire [WIDTH-1 : 0]  bf2_y0_img;      //imaginary part of first output data of butterfly
     wire [WIDTH-1 : 0]  bf2_y1_real;     //real part of second output data of butterfly
     wire [WIDTH-1 : 0]  bf2_y1_img;      //imaginary part of second output data of butterfly
     wire [WIDTH-1 : 0]  bufferIn2_real;  //real part of input data to Delay buffer
     wire [WIDTH-1 : 0]  bufferIn2_img;   //imaginary part of input data to Delay buffer
     wire [WIDTH-1 : 0]  bufferOut2_real; //real part of output data from Delay buffer
     wire [WIDTH-1 : 0]  bufferOut2_img;  //imaginary part of output data from Delay buffer
     wire [WIDTH-1 : 0]  bf2_sp_real;     //real part of Single-Path Data Output
     wire [WIDTH-1 : 0]  bf2_sp_img;      //imaginary part of Single-Path Data Output
     reg                 bf2_sp_en;       //enable signal for the output of single path data
     reg  [N-1 : 0]      bf2_count;       //count of the single path data
     wire                bf2_start;       //trigger signal
     wire                bf2_end;         //end of the stream of single path data
     reg  [WIDTH-1 : 0]  bf2_dataOut_real;//real part of output data of the second butterfly
     reg  [WIDTH-1 : 0]  bf2_dataOut_img; //real part of output data of the second butterfly
     
     
     // Multplication
     wire [1 : 0]         tw_sel;         //Twiddle select
     wire [N-3 : 0]       tw_num;         //Twiddle number is less than the bit width of fft points by 2 due to the devision of inputs to 4 groups 
     wire [WIDTH-1 : 0]   tw_addr;        //Twiddle address in the lookup tables;
     wire [WIDTH-1 : 0]   tw_real;        //Real part of the twiddle factor
     wire [N-1 : 0]       tw_img;         //Imaginary part of the twiddle factor
     reg                  MultIn_en;      //Multiplay enable
     wire [WIDTH-1 : 0]   MultIn_real;    //Real part of the multiplyer input         
     wire [WIDTH-1 : 0]   MultIn_img;     //Imaginary part of the multiplyer input         
     wire [WIDTH-1 : 0]   MultOut_real;   //Real part of the multiplyer output         
     wire [WIDTH-1 : 0]   MultOut_img;    //Imaginary part of the multiplyer output
     reg  [WIDTH-1 : 0]   MultData_real;  //Real part of final multplication output data
     reg  [WIDTH-1 : 0]   MultData_img;   //Imaginary part of final multplication output data
     reg                  MulOut_en;      //Enable the output of mu;tplication data
     reg                  bf2_dataOut_en;
     
     
     /*
     *  First Butterfly
     */
     always@(posedge clk , posedge reset)
     begin
     
        if(reset)
        begin
        
            dataIn_count <= {N{1'b0}};
        
        end
        
        else
        begin
        
            dataIn_count <= In_en ? (dataIn_count + 1'b1) : {N{1'b0}};
        
        end
     
     end
     
     //Enable the first butter fly after half of the inputs is finished entering the delay fifo      
     assign bf1_en = dataIn_count[M - 1];
     
     //After the first half of the inputs entered the delay buffer 
     //the first butterfly is enabled to do complex add/sub operations
     //between the remaining half of the inputs and the inputs presemt 
     //in the delay buffer 
     
     assign bf1_x0_real = bf1_en ? bufferOut1_real : {WIDTH{1'bx}};
     assign bf1_x0_img  = bf1_en ? bufferOut1_img  : {WIDTH{1'bx}};
     assign bf1_x1_real = bf1_en ? In_real         : {WIDTH{1'bx}};
     assign bf1_x1_img  = bf1_en ? In_img          : {WIDTH{1'bx}};
    
     
     Butterfly BF1(
         
         .x0_real(bf1_x0_real),
         .x0_img(bf1_x0_img),
         .x1_real(bf1_x1_real),
         .x1_img(bf1_x1_img),
         .y0_real(bf1_y0_real),
         .y0_img(bf1_y0_img),
         .y1_real(bf1_y1_real),
         .y1_img(bf1_y1_img)
         
     );
     
     defparam BF1.WIDTH = WIDTH;
     defparam BF1.RH    = 0;
     
     DelayFIFO DF1(
         
         .clk(clk),
         .dataIn_real(bufferIn1_real),
         .dataIn_img(bufferIn1_img),
         .dataOut_real(bufferOut1_real),
         .dataOut_img(bufferOut1_img)
         
     );
     
     defparam DF1.WIDTH = WIDTH;
     defparam DF1.DEPTH = 2**(M - 1);
     
     assign bufferIn1_real = bf1_en ? bf1_y1_real : In_real;
     assign bufferIn1_img  = bf1_en ? bf1_y1_img  : In_img;
     
     //When we reach the last quarter of data indicated by the value 'bf2_mult_j' signal
     //the output of the first butter fly will be multplyed by -j , so the real and imaginary
     //part are interchanged with filiping the sign of the real part
     //(a + bj)*-j = b - aj
     assign bf1_sp_real    = bf1_en ? bf1_y0_real : bf1_mult_j ? bufferOut1_img   : bufferOut1_real;
     assign bf1_sp_img     = bf1_en ? bf1_y0_img  : bf1_mult_j ? -bufferOut1_real : bufferOut1_img;
     
     always@(posedge clk or posedge reset)
     begin
     
        if(reset)
        begin
        
            bf1_sp_en <= 1'b0;
            bf1_count <= {N{1'b0}};
        
        end
        
        else
        begin
        
            bf1_sp_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_sp_en;
            bf1_count <= bf1_sp_en ? (bf1_count + 1'b1) : {N{1'b0}};

            
        end
     
     end
     
    assign bf1_start = (dataIn_count == (2**(M - 1) - 1));
    assign bf1_end   = (bf1_count == 2**(M) - 1);
    assign bf1_mult_j = (bf1_count[M-1 : M-2] == 2'd3);
    
    
    always@(posedge clk)
    begin
    
        bf1_dataOut_real <= bf1_sp_real;
        bf1_dataOut_img  <= bf1_sp_img;

    end
    
    
    /*
    *  Second Butterfly
    */
    
    always@(posedge clk)
    begin
    
        bf2_en <= bf1_count[M-2];
    
    end
    
    assign bf2_x0_real = bf2_en ? bufferOut2_real      : {WIDTH{1'bx}};
    assign bf2_x0_img  = bf2_en ? bufferOut2_img       : {WIDTH{1'bx}};
    assign bf2_x1_real = bf2_en ? bf1_dataOut_real     : {WIDTH{1'bx}};
    assign bf2_x1_img  = bf2_en ? bf1_dataOut_img      : {WIDTH{1'bx}};
    
    
    Butterfly BF2(
        
        .x0_real(bf2_x0_real),
        .x0_img(bf2_x0_img),
        .x1_real(bf2_x1_real),
        .x1_img(bf2_x1_img),
        .y0_real(bf2_y0_real),
        .y0_img(bf2_y0_img),
        .y1_real(bf2_y1_real),
        .y1_img(bf2_y1_img)
        
    );
    
    defparam BF2.WIDTH = WIDTH;
    defparam BF2.RH    = 0;
    
    assign bufferIn2_real = bf2_en ? bf2_y1_real : bf1_dataOut_real;
    assign bufferIn2_img  = bf2_en ? bf2_y1_img  : bf1_dataOut_img;
    assign bf2_sp_real    = bf2_en ? bf2_y0_real : bufferOut2_real;
    assign bf2_sp_img     = bf2_en ? bf2_y0_img  : bufferOut2_img;
    

    DelayFIFO DF2(
         
         .clk(clk),
         .dataIn_real(bufferIn2_real),
         .dataIn_img(bufferIn2_img),
         .dataOut_real(bufferOut2_real),
         .dataOut_img(bufferOut2_img)
         
     );
     
    defparam DF2.WIDTH = WIDTH;
    defparam DF2.DEPTH = 2**(M - 2);
     
     
    always@(posedge clk , posedge reset)
    begin
     
        if(reset)
        begin
        
            bf2_sp_en <= 1'b0;
            bf2_count <= {N{1'b0}};
        
        end
        
        else
        begin
        
            bf2_sp_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_sp_en;
            bf2_count <= bf2_sp_en ? (bf2_count + 1'b1) : {N{1'b0}};
        
        end
     
    end
     
    assign bf2_start = (bf1_count == (2**(M-2) - 1)) & bf1_sp_en;
    assign bf2_end   = (bf1_count == 2**(M) - 1);
    
    always@(posedge clk)
    begin
    
        bf2_dataOut_real <= bf2_sp_real;
        bf2_dataOut_img  <= bf2_sp_img;

    
    end

    always@(posedge clk , posedge reset)
    begin
    
        if(reset)
        begin
        
            bf2_dataOut_en <= 1'b0;
        
        end
        
        else
        begin
        
            bf2_dataOut_en <= bf2_sp_en;
        
        end
    
    end
    
    
    /*
    *   Complex Multiplication Unit
    */
        
    assign tw_sel[1] = bf2_count[M - 2];
    assign tw_sel[0] = bf2_count[M - 1];
    assign tw_num    = bf2_count <<< (N - M);
    assign tw_addr   = tw_num * tw_sel;
    
    Twiddle64 TW(
    
        .clock(clk),  
        .addr(tw_addr),   
        .tw_re(tw_real),  
        .tw_im(tw_img)   
        
    );
    
    defparam TW.WIDTH = WIDTH; 
    
    always@(posedge clk)
    begin
    
        MultIn_en <= (tw_addr != {N{1'b0}});
    
    end
    
    assign MultIn_real = MultIn_en ? bf2_dataOut_real : {WIDTH{1'bx}};
    assign MultIn_img  = MultIn_en ? bf2_dataOut_img  : {WIDTH{1'bx}};

    
    ComplexMultiply CM(
        
        .In1_real(MultIn_real),
        .In1_img(MultIn_img),
        .In2_real(tw_real),
        .In2_img(tw_img),
        .Out_real(MultOut_real),
        .Out_img(MultOut_img)
        
    );
    
    defparam CM.WIDTH = WIDTH;
    
    always@(posedge clk)
    begin
    
        MultData_real <= MultIn_en ? MultOut_real : bf2_dataOut_real;
        MultData_img  <= MultIn_en ? MultOut_img  : bf2_dataOut_img;
    
    end
    
    always@(posedge clk , posedge reset)
    begin
    
        if(reset)
        begin
        
            MulOut_en     <= 1'b0;
        
        end
        
        else
        begin
        
            MulOut_en     <= bf2_dataOut_en;
        
        end
    
    end
    
    
    assign Out_en   = (M == 2) ? bf2_dataOut_en   : MulOut_en;
    assign Out_real = (M == 2) ? bf2_dataOut_real : MultData_real;
    assign Out_img  = (M == 2) ? bf2_dataOut_img  : MultData_img;

    
endmodule
