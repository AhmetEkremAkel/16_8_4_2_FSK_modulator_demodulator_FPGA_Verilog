`timescale 1ns / 1ps

module fsk_modulator(
    input wire clk,
    input wire reset,
    input wire data_in,  // 3-bit veri girişi
    input wire start,          // Senkronizasyon için başlangıç işareti
    output reg [17:0] sine_out,
    output reg [17:0] cos_out
);

    parameter PHASE_WIDTH = 16; 
    parameter SINE_ROM_ADDR_WIDTH = 16;  
    parameter SINE_ROM_SIZE = 1 << SINE_ROM_ADDR_WIDTH;
    parameter SYNC_LENGTH = 10; // Senkronizasyon süresi (örnek cinsinden)

    reg [PHASE_WIDTH-1:0] phase_accumulator = 16'h0000;
    reg [PHASE_WIDTH-1:0] frequency_increments[0:1]; 
    reg [PHASE_WIDTH-1:0] phase_increment;

    reg [15:0] sine_rom[0:SINE_ROM_SIZE-1]; 

    // Sync moduna ait register'lar
    reg sync_mode;
    reg [31:0] sync_counter;

    integer i;
    initial begin
        // 8 adet örnek frekans (örnek değerler)
        frequency_increments[0] = 16'd655;   // ~1 MHz
        frequency_increments[1] = 16'd1311;  // ~2 MHz



        // SINE ROM'u doldur
        for (i = 0; i < SINE_ROM_SIZE; i = i + 1) begin
            sine_rom[i] = $rtoi(16383 * 
                $sin(2.0 * 3.1415926535 * i / SINE_ROM_SIZE)
            );
        end
    end

    wire [SINE_ROM_ADDR_WIDTH-1:0] sine_addr;
    wire [SINE_ROM_ADDR_WIDTH-1:0] cos_addr;

    assign sine_addr = phase_accumulator[PHASE_WIDTH-1 : PHASE_WIDTH-SINE_ROM_ADDR_WIDTH];
    assign cos_addr  = sine_addr + (SINE_ROM_SIZE >> 2);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_accumulator <= 0;
            phase_increment   <= 0;
            sine_out <= 0;
            cos_out  <= 0;
            sync_mode <= 0;
            sync_counter <= 0;
        end 
        else begin
            if (!sync_mode && start) begin
                // Başlangıçta start=1 ise önce sync moduna gir
                sync_mode <= 1;
                sync_counter <= 0;
            end

            if (sync_mode) begin
                // Sync modunda basit step sinyal
                sine_out <= 16'hFFFF; 
                cos_out  <= 0;
                sync_counter <= sync_counter + 1;

                // bir sonraki frekans
                phase_increment <= frequency_increments[data_in];

                if (sync_counter >= SYNC_LENGTH) begin
                    sync_mode <= 0;
                    phase_increment <= frequency_increments[data_in];
                    phase_accumulator <= phase_accumulator + phase_increment;

                    // İlk çıkışı üret
                    sine_out <= { sine_rom[sine_addr][15],
                                  sine_rom[sine_addr][15],
                                  sine_rom[sine_addr] };
                    cos_out  <= { sine_rom[cos_addr][15],
                                  sine_rom[cos_addr][15],
                                  sine_rom[cos_addr] };
                end
            end
            else begin
                // Normal FSK modülasyonu
                phase_increment   <= frequency_increments[data_in];
                phase_accumulator <= phase_accumulator + phase_increment;

                sine_out <= { sine_rom[sine_addr][15],
                              sine_rom[sine_addr][15],
                              sine_rom[sine_addr] };
                cos_out  <= { sine_rom[cos_addr][15],
                              sine_rom[cos_addr][15],
                              sine_rom[cos_addr] };
            end
        end
    end

endmodule
