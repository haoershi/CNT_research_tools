function [out_values,car_labels] = car(values,labels)

out_values = values - mean(values,2,'omitnan'); 
car_labels = strcat(labels,'-CAR');

end