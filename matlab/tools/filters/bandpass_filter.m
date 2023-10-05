function values = bandpass_filter(values,fs,varargin)

low_freq = 1;
high_freq = 120;
if nargin == 3
    low_freq = varargin{1};
elseif nargin == 4
    high_freq = varargin{2};
end

d = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',low_freq,'HalfPowerFrequency2',min(floor(fs/2),high_freq), ...
    'SampleRate',fs);

for i = 1:size(values,2)
    eeg = values(:,i);
    
    if sum(~isnan(eeg)) == 0
        continue
    end
    
    eeg(isnan(eeg)) = mean(eeg,'omitnan');
    eeg = filtfilt(d,eeg);   
    values(:,i) = eeg;
end


end