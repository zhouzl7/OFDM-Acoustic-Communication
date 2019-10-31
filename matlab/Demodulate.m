function decode_data = Demodulate(signal_output, snr, base_frequency, carrier_frequency, ...
    sampling_frequency, signal_length, psk_length, ofdm_length)
%     simulate = input("Run in simulate mode: ");
    simulate = 1;
    %% anaSound
    header_length = 32;
    signal_real_length = signal_length + header_length;
    signal_time = signal_real_length / sampling_frequency;
    sampling_span = 1 / sampling_frequency;
    check_length = ofdm_length;

    chirp_u_length = 1024;
    chirp_u_time = chirp_u_length / sampling_frequency;
    chirp_u_begin_frequency = 200;
    chirp_u_end_frequency = 600;
    chirp_d_length = 512;
    chirp_d_time = chirp_d_length / sampling_frequency;
    chirp_d_begin_frequency = 600;
    chirp_d_end_frequency = 1000;
    signal_u_chirp = chirp(0: sampling_span: chirp_u_time - sampling_span, chirp_u_begin_frequency, chirp_u_time, chirp_u_end_frequency);
    signal_d_chirp = chirp(0: sampling_span: chirp_d_time - sampling_span, chirp_d_begin_frequency, chirp_d_time, chirp_d_end_frequency);

    if simulate
        signal_received = signal_output;
        wgn_length1 = randperm(10000, 1) + 5000;
        signal_wgn1 = wgn(1, wgn_length1, snr);
        signal_wgn1 = signal_wgn1 / max(abs(signal_wgn1));
        wgn_length2 = randperm(10000, 1) + 5000;
        signal_wgn2 = wgn(1, wgn_length2, snr);
        signal_wgn2 = signal_wgn2 / max(abs(signal_wgn2));
        signal_received = awgn(signal_received, snr, 'measured');
        signal_received = [signal_wgn1 signal_received signal_wgn2];
    else
        soundFile = 'received.wav';
        [signal_received, ~] = audioread(soundFile);
        signal_received = signal_received(:, 1);
        signal_received = signal_received';
    end
    %% align
    [C, lag] = xcorr(signal_received, signal_u_chirp);
    [~, I] = max(C);
    begin = lag(I) + chirp_u_length;
    signal_received = signal_received(begin: end);
    [C, lag] = xcorr(signal_received, signal_d_chirp);
    [~, I] = max(C);
    finish = round(lag(I) / signal_real_length) * signal_real_length;
    signal_received = signal_received(1: finish);

    content_time = signal_time * length(signal_received) / signal_real_length;
    offset_frequency = 10;
    max_frequency = base_frequency * ofdm_length / psk_length;

%     plot(0: sampling_span: content_time - sampling_span, signal_received, "LineWidth", 0.5);
%     xlabel("Time");
%     ylabel("Received Signal");
%     grid on;

    %% decode
    decode_data = zeros(1, ofdm_length * length(signal_received) / signal_real_length);
    signal_received = DeCarrier(signal_received, sampling_span, carrier_frequency);
    phase = repmat(pi / 4, 1, ofdm_length / psk_length);
    for i = 1: signal_real_length: length(signal_received)
        clip = signal_received(i + header_length: i + signal_real_length - 1);
        clip_filtered = BPassFilter(clip, base_frequency - offset_frequency, max_frequency + offset_frequency, sampling_frequency);
        [decode_clip, phase] = OFDMDecode(clip_filtered, ofdm_length, psk_length, phase);
        pos = (i - 1) * ofdm_length / signal_real_length + 1;
        decode_data(pos: pos + ofdm_length - 1) = decode_clip;
    end
    decode_data = decode_data(check_length + 1: end);
%     decode_data = reshape(decode_data, ofdm_length, []).';
%     value = convertCharsToStrings(char(bi2de(decode_data)));
%     disp(value)
end