segmentation_size = 384; %length of training message(bits)
number_data = 50000;

% Generate #number_data random numbers between [0, 1]
random_bits = randi([0, 1], number_data, segmentation_size);

% Display the generated random numbers
% disp('Generated Random Numbers:');
% disp(random_numbers);
for i = 1:number_data
    


end




% Specify the Excel file name
excel_file = 'dataset.xlsx';

% Write the random numbers to the Excel file
writematrix(random_numbers, excel_file);

disp(['Random numbers have been written to ' excel_file]);