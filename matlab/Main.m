close all;
clear;
clc;

psk_length = 2; % qpsk encode per 2 bits
ofdm_length = 16; % ofdm encode per 8 bits
base_frequency = 400;
signal_length = 1024;
carrier_frequency = 5000;
sampling_frequency = 40960;
snr = 1;

snr_list = [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1];
signal_length_list = [512, 1024, 1536, 2048];
sampling_frequency_list = [2560, 4096, 5120, 6400, 8192, 10240, 12800, 20480, 25600, 40960, 51200, 81920];
carrier_frequency_list = [500, 1000, 5000, 10000, 15000, 18000, 19000, 20000, 21000, 22000, 25000, 30000];
base_frequency_list = [40, 120, 200, 280, 360, 400, 2000, 3800, 3840, 3880, 4000, 5000];
ofdm_length_list = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48];
psk_length_list = [2, 4, 8, 16];

for k = 1 : length(psk_length_list)
    psk_length = psk_length_list(k);
    disp("The psk_length is: ")
    disp(psk_length);
    
    sampling_length = 100;
    data_length = (1 : sampling_length) * ofdm_length * 2 + ofdm_length * 15;
    rates = [];
    bit_error_amount = 0;
    total_data_length = 0;
    for i = 1 : sampling_length
        bit_error_rate = Simulate(data_length(i), snr, signal_length, ...
            base_frequency, carrier_frequency, sampling_frequency, ...
            psk_length, ofdm_length);
        bit_error_amount = bit_error_amount + bit_error_rate * data_length(i);
        total_data_length = total_data_length + data_length(i);
        rates = [rates bit_error_rate];
    end
    disp("The total data length is: ")
    disp(total_data_length);
    disp("The average bit error rate is: ")
    disp(bit_error_amount / total_data_length);

    subplot_number = 4;
    figure(fix((k-1)/subplot_number) + 1);
    subplot(subplot_number, 1, mod(k-1, subplot_number)+1);
    plot(data_length, rates);
    str_title = sprintf("PSK Length: %.2d", psk_length);
    title(str_title);
    xlabel('Data Length');
    ylabel('Bit Error Rate');
    hold on;
end
