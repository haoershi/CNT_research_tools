function inds = get_ind(labels)
% this function get the index within 1-36 for a set of labels

[chan, elec, num] = clean_labels(labels);
inds = [];
for i = 1:length(labels)
    elecName = elec{i};
    elecName = elecName(2:end);
    if strcmp(elecName,'DA')|strcmp(elecName,'AD')|strcmp(elecName,'A')
        inds = [inds num(i)];
    elseif strcmp(elecName,'DH')|strcmp(elecName,'HD')|strcmp(elecName,'B')|strcmp(elecName,'AH')
        inds = [inds 1*12 + num(i)];
    elseif strcmp(elecName,'C')|strcmp(elecName,'PH')
        inds = [inds 2*12 + num(i)];
    end
end
