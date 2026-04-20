`timescale 1ns / 1ps

module fsk_demodulator_tb;


    reg clk;
    reg reset;
    reg [1:0] data_in;
    reg start;


    wire [1:0] data_out;


    top_module uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .data_out(data_out)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    integer error_count = 0;
    integer total_count = 0;


    reg [1:0] last_data_in; 

    integer j;

    initial begin

        $srandom($time);
        

    end

    initial begin

        $srandom(32'hDEAD_BEEF);
        

    end

    initial begin
        // Başlangıç değerleri
        reset = 1;
        start = 0;
        // Reset süresi
        #200;
        start = 1;
        reset = 0;
        #20;
        start = 0;
        #80;


        last_data_in = 4'b00; 
        data_in = 4'b00;      
        #20;
        for (j = 0; j < 50; j = j + 1) begin


            // 0)
            #1000 data_in = 4'b00;
            total_count = total_count + 1;
            if (data_out != last_data_in) error_count = error_count + 1;
            last_data_in = data_in;

            // 1) 
            #1000;
            data_in = 4'b01;
            total_count = total_count + 1; 
            
            if (data_out != last_data_in) error_count = error_count + 1; 
            last_data_in = data_in;

            // 2) 
            #1000;
            data_in = 4'b10;
            total_count = total_count + 1;

            if (data_out != last_data_in) error_count = error_count + 1;
            last_data_in = data_in;

            // 3)
            #1000 data_in = 4'b11;
            total_count = total_count + 1;
            if (data_out != last_data_in) error_count = error_count + 1;
            last_data_in = data_in;



        end
        

        #1000;
        $display("Error Count = %d, Total Count = %d, BER = %f",
                 error_count, total_count,
                 error_count*1.0 / total_count);
        
        $finish;
    end

endmodule
