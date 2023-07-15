function [out_values,car_labels] = common_average_reference(values,labels)

out_values = values - nanmean(values,2); 
car_labels = strcat(labels,'-CAR');

end