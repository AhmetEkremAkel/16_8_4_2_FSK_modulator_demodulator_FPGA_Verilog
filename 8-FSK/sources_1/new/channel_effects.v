`timescale 1ns / 1ps

module channel_effects(
    input  wire                clk,
    input  wire signed [17:0]  input_1,
    input  wire signed [17:0]  input_2,
    output wire signed [17:0]  output_1,
    output wire signed [17:0]  output_2
);

    // Gaussian gürültü ölçek parametresi
    parameter real NOISE_SCALE = 9200.0;
    
    // Geçici register'lar
    reg signed [17:0] temp, temp_2;
    reg signed [17:0] noise_1, noise_2;
    
    real u1, u2;
    real r, theta;
    real gauss_1, gauss_2;
    

    
    always @(posedge clk) begin
        // 1) İki üniform (0..1) rastgele sayı
        u1 = $urandom_range(1, 65535) / 65536.0;
        u2 = $urandom_range(1, 65535) / 65536.0;
        
        // 2) Box-Muller
        r = $sqrt(-2.0 * $ln(u1));
        theta = 2.0 * 3.14159265359 * u2;
        
        gauss_1 = r * $cos(theta);
        gauss_2 = r * $sin(theta);
        
        // Gaussian değerleri -1 ile 1 arasına kırpma
          if (gauss_1 > 3.0) gauss_1 = 3.0;
          else if (gauss_1 < -3.0) gauss_1 = -3.0;
    
          if (gauss_2 > 3.0) gauss_2 = 3.0;
          else if (gauss_2 < -3.0) gauss_2 = -3.0;

        // 3) Sabit nokta formata dönüştürüp ekleme
        noise_1 <= $rtoi(gauss_1 * NOISE_SCALE);
        noise_2 <= $rtoi(gauss_2 * NOISE_SCALE);
        
        temp   <= input_1 + noise_1;
        temp_2 <= input_2 + noise_2;
    end
    
    assign output_1 = temp;
    assign output_2 = temp_2;

endmodule
