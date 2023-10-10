function values = notch_filter(values,fs,varargin)

notch_freq = 60;
if nargin == 3
    notch_freq = varargin{1};
end

f = designfilt('bandstopiir','FilterOrder',4, ...
   'HalfPowerFrequency1',notch_freq-1,'HalfPowerFrequency2',notch_freq+1, ...
   'DesignMethod','butter','SampleRate',fs);
%fvtool(f)
for i = 1:size(values,2) 
    
    eeg = values(:,i);
    
    if sum(~isnan(eeg)) == 0
        continue
    end
    
    eeg(isnan(eeg)) = mean(eeg,'omitnan');
    eeg = filtfilt(f,eeg);   
    values(:,i) = eeg;
end


end

