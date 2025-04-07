%The primary purpose of this program is to create a multi-layer matrix,
%each layer of which represents the voltage values of each device.
clear all
close all
channels=2
step=1;
SMX_max=10;
SMX_min=-10;
SMY_max=10;
SMY_min=-10;



SMX_row=[SMX_min:step:SMY_max];
SMY_row=[SMY_min:step: SMY_max];
SM_test_3D = zeros(size(SMX_row,2),size(SMY_row,2),channels);
SM_test_3D(:,:,1)=meshgrid(SMX_row, SMY_row);
SM_test_3D(:,:,2)=transpose(meshgrid(SMY_row, SMX_row));
disp("Number of Tics:")
numtics= size(SM_test_3D,1)*size(SM_test_3D,2);
disp(numtics)
% Compress 3D matrix into 2D matrix
SM_test=[];
SM_test = vertcat(SM_test, reshape(SM_test_3D(:,:,1), 1, []));
for k=2:channels
    SM_test = vertcat(SM_test, reshape(SM_test_3D(:,:,k), 1, []));
end

time = (0:1:size(SM_test,2)-1);
plot(time,SM_test(1,:))
hold on
plot(time, SM_test(2,:))
ylim([-10.5 10.5])
xlim ([0,size(SM_test,2)])
xticklabels({})
yticklabels({})
xticks(0:300:2000)
ylabel('Voltage')
xlabel('time')

writematrix(SM_test, "SM_test_20V.txt")
% Add ETL1, ETL2, SM1.