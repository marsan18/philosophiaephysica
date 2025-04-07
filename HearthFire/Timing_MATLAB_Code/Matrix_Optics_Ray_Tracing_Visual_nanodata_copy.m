%% Ray Transfer Matricies Testing
% Assuming Ray optics in a medium of constant index of refraction n=1.
foc = 100; %Arbitrary, but lets say its in cm.
L1=[1, -1/foc; 0, 1];
R1 = [0;1];
R2 = L1*R1;
F1 = [1,0;foc,1];
R3 = F1*R2;
F2 = [1,0; foc,1];
R4 =  F2 * R3;
L2 = [1, -1/foc; 0, 1];
R5 = L2*R4;

endstep = 400; %units of arbitrary thickness. I choose centimeters for my setup.
Component_stack(:,:,1) = L1;
Component_stack(:,:,2) = L2;
ray_top_record = zeros(1, endstep);
ray_bot_record = zeros(1, endstep);

%% Top Ray
z = 0;

component_num = 1;
component_coords = [100, 300, -1]; %Gives the step number location of the component. After final component, set it to 0 so it won't trigger again.
z_transform_step = [1, 0; 1, 1];
R_top = [0; 1];
for z = 1:1:endstep
    if z == component_coords(component_num) 
        R_out = Component_stack(:,:,component_num) * R_top
        component_num = component_num + 1;
    else
        
        R_out = z_transform_step * R_top;
    end
    R_top=R_out;
    ray_top_record(:, z) = R_out(2);
end

%% Bottom Ray
z = 0;
endstep = 400; %units of arbitrary thickness. I choose centimeters for my setup.
component_num = 1;
component_coords = [100, 300, -1]; %Gives the step number location of the component. After final component, set it to 0 so it won't trigger again.
z_transform_step = [1, 0; 1, 1];
R_bot = [0;-1];
for z = 1:1:endstep
    if z == component_coords(component_num) 
        R_out = Component_stack(:,:,component_num) * R_bot;
        component_num = component_num + 1;
    else
        
        R_out = z_transform_step * R_bot;
    end
    R_bot=R_out;
    ray_bot_record(:, z) = R_out(2);
end
%% Analysis and Visualization
ray_record_img_ = zeros(400, endstep);
for pix_col = 1:endstep
    for pix_row = 1:1:400
        if 100*ray_top_record(pix_col) + 200 >= pix_row && 100*ray_bot_record(pix_col) + 200 <= pix_row
            ray_record_img(pix_row, pix_col) = 255;
        elseif 100*ray_top_record(pix_col) + 200 <= pix_row && 100*ray_bot_record(pix_col) + 200 >= pix_row
            ray_record_img(pix_row, pix_col) = 255;
        else
            ray_record_img(pix_row, pix_col) = 0;
        end
        
    end
end
%image(ray_top_record*255)
image(ray_record_img)
       