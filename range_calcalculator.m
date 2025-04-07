function [output_par] = range_calc()
    % Speed of light
    c = 3.0e+8;
    
    % Prompt the user to input parameters
    pt = input('Enter the transmitted power (pt) in Watts:');
    tau = input('Enter the pulse width (tau) in seconds:');
    fr = input('Enter the pulse repetition frequency (fr) in Hz:');
    time_ti = input('Enter the integration time (time_ti) in seconds:');
    gt = input('Enter the transmitter gain (gt) in dB:');
    gr = input('Enter the receiver gain (gr) in dB:');
    freq = input('Enter the frequency (freq) in Hz:');
    sigma = input('Enter the radar cross-section (sigma) in m^2:');
    te = input('Enter the system temperature (te) in Kelvin:');
    nf = input('Enter the noise figure (nf) in dB:');
    loss = input('Enter the system losses (loss) in dB:');
    snro = input('Enter the required SNR for detection (snro) in dB:');
    pcw = input('Enter the pulse compression width (pcw) in seconds:');
    range = input('Enter the range in kilometers:');
    radar_type = input('Enter radar type (0 for CW, 1 for pulsed):');
    out_option = input('Enter output option (0 for SNR plot, 1 for range plot):');

    % Calculate lambda
    lambda = c / freq;

    % Calculate pulse average power (pav) based on radar type
    if (radar_type == 0)
        pav = pcw;
    else
        % Compute the duty cycle
        dt = tau * 0.001 * fr;
        pav = pt * dt;
    end

    pav_db = 10.0 * log10(pav);
    lambda_sqdb = 10.0 * log10(lambda^2);
    sigmadb = 10.0 * log10(sigma);
    for_pi_cub = 10.0 * log10((4.0 * pi)^3);
    k_db = 10.0 * log10(1.38e-23);
    te_db = 10.0 * log10(te);
    ti_db = 10.0 * log10(time_ti);
    range_db = 10.0 * log10(range * 1000.0);

    if (out_option == 0)
        % Compute SNR
        snr_out = pav_db + gt + gr + lambda_sqdb + sigmadb + ti_db - ...
            for_pi_cub - k_db - te_db - nf - loss - 4.0 * range_db;

        index = 0;
        for range_var = 10:10:1000
            index = index + 1;
            rangevar_db = 10.0 * log10(range_var * 1000.0);
            snr(index) = pav_db + gt + gr + lambda_sqdb + sigmadb + ti_db - ...
                for_pi_cub - k_db - te_db - nf - loss - 4.0 * rangevar_db;
        end

        var = 10:10:1000;
        plot(var, snr, 'k');
        xlabel('Range in Km');
        ylabel('SNR in dB');
        grid;
    else
        range4 = pav_db + gt + gr + lambda_sqdb + sigmadb + ti_db - ...
            for_pi_cub - k_db - te_db - nf - loss - snro;
        range = 10.0^(range4 / 40.0) / 1000.0;

        index = 0;
        for snr_var = -20:1:60
            index = index + 1;
            rangedb = pav_db + gt + gr + lambda_sqdb + sigmadb + ti_db - ...
                for_pi_cub - k_db - te_db - nf - loss - snr_var;
            range(index) = 10.0^(rangedb / 40.0) / 1000.0;
        end

        var = -20:1:60;
        plot(var, range, 'k');
        xlabel('Minimum SNR required for detection in dB');
        ylabel('Maximum detection range in Km');
        grid;
    end
end
