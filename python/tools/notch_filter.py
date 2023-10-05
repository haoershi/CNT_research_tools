from scipy.signal import iirnotch, filtfilt, butter



def notch_filter(data,fs,notch_freq = 60):

    b, a = iirnotch(notch_freq, notch_freq/2, fs=fs)
    # b, a = butter(4, [59,61], 'bandstop', fs) 

    y = filtfilt(b, a, data, axis = 0)

    return y

