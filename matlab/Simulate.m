function bit_error_rate = Simulate(data_length, snr, signal_length, ...
            base_frequency, carrier_frequency, sampling_frequency, ...
            psk_length, ofdm_length)

    %% generate data
%     data_length = (randperm(100, 1) + 20) * ofdm_length;
%     data_length = 200 * ofdm_length;
    data = randi([0, 1], 1, data_length);

    %% modulate
    signal_output = Modulate(data, base_frequency, carrier_frequency, ...
        sampling_frequency, signal_length, psk_length, ofdm_length);

    %% demodulate
    decode_data = Demodulate(signal_output, snr, base_frequency, ...
        carrier_frequency, sampling_frequency, signal_length, psk_length, ofdm_length);

    %% calculate bit error rate
    bit_error_rate = (data_length - sum(data == decode_data)) / data_length;

%     disp("The data length is: ")
%     disp(data_length);
%     disp("The bit error rate is: ")
%     disp(bit_error_rate);
end
