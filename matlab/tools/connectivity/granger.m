function F = granger(values)%,fs,tw,do_tw)

nchs = size(values,2);

% Number of lags used in the AR model
p = 10;

% Calculate the Granger causality matrix
F = zeros(nchs, nchs);
for i = 1:nchs
    for j = 1:nchs
        if i ~= j
            % Fit AR models to the data
            [A, ~] = arburg(values(:, i), p);
            [B, ~] = arburg(values(:, j), p);
            
            % Calculate the residuals of the AR models
            e = filter(1, A, values(:, i));
            f = filter(1, B, values(:, j));
            
            % Fit AR models to the residuals with and without the influence of the other electrode
            [~, E_e] = arburg(e, p);
            [~, E_ef] = arburg(e - f, p);
            
            % Calculate the improvement in the model's performance
            F(i, j) = log(E_e / E_ef);
        end
    end
end

% Plot the Granger causality matrix
if 1
    imagesc(F);
    colorbar;
    xlabel('Electrode');
    ylabel('Electrode');
    title('Granger Causality Matrix');
end
