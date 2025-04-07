%% Matrix Guide
% Lenses: [1, -D; 0,1] where D is refractive power. In the thin lens
% approximation, D=1/f, for focal length f.
% Mirrors: [-1,0;0,1] (flat, ideal mirror in air if it is perpendicular to the
% optical axis.
% Distance Transforms: f= [1, 0; d, 1] for distance covered d.
% All units are currently scaled in mm
%% Formulas
    % Mirror: [-1,-2n/R; 0, 1]
        %Here I assume that all mirrors are flat, i.e. R=inf, so that we
        %end up with: [-1, 0; 0, 1]
    % Idealized thin lens: [1, -1/f; 0, 1]
    % Transform matrix for a distance travelled in air with an optical
    % index of 1: [1, 0; dist, 1]
    % Ray orientation is given by 
    
%% MODULE 1 {Deliberately left unimplemented due to unknown perameters}
    % Half Wave Plate  -- not sure what to do about this. I need more specs
    % on this.
    % Beam Expander -- [M, B; 0, 1/M] for M is beam magnification, B is
    % optical propogation distance of prisms
    % Beam Expander -- [M, B; 0, 1/M] for M is beam magnification, B is
    % optical propogation distance of prisms.
    z_mod1 = 500
    n=1;
    %% MODULE 2 LP1 (assume all mirrors flat, including PBS)
    % PBS 1 has no focus, so I guess we will assume it behaves as a flat
    % mirror in this case.
    PBS1 = [-1, 0; 0,1]; %Ideal Mirror
    Component_stack(:,:,n) = PBS1;
    n=n+1
    M1 = [1, 0; 0, 1]; %Ideal Mirror
    Component_stack(:,:,n) = M1;
    n=n+1
    ETL1 = [1, -1/125; 0, 1]; %Thin Lens with f=125mm
    Component_stack(:,:,n) = ETL1;
    n=n+1
    M2 = [1, 0; 0,1];
    Component_stack(:,:,n) = M2;
    n=n+1
    PBS2 = [1, 0; 0, 1];
    Component_stack(:,:,n) = PBS2;
    n=n+1
    %Distance along otpical axis is positive because there are two mirrors.
%     F_ETL1_SM1 = [1, 0; 125, 1];
%     Component_stack(:,:,n) = F_ETL1_SM1;
%     n=n+1
    %Grants 0 width slanted beam as anticipated going into mod3
    
%% Module 2 LP2 (Ignored for now)
    %Assume PBSs are inert for non-affective wavelenghts
    %Confocal Lens (CL) works like regular lens? Or do I just need to use a
    %different matrix? Not sure.
    CL1 = [1, -1/125; 0, 1];
    Component_stack(:,:,n) = CL1;
    n=n+1
    
    
%% Module 3
    %"ETL is adjusted to 125mm effective focal length to focus beam to SM1"
    
    SM1 = [1, 0; 0, 1];
    Component_stack(:,:,n) = SM1;
    n=n+1
%     F_SM1_L1 = [1, 0; 125, 1]; 
%     Component_stack(:,:,n) =F_SM1_L1;
%     n=n+1
    L1 = [1, -1/125; 0, 1];
    Component_stack(:,:,n) = L1;
    n=n+1
%     F_L1_SM2 = [1, 0; 125, 1];
%     Component_stack(:,:,n) = F_L1_SM2;
%     n=n+1
    SM2 = [1, 0; 0, 1];
    Component_stack(:,:,n) = SM2;
    n=n+1
    % Grants full width tiltless beam exiting module 3 as anticipated= 
%% Module 4
%     F_SM2_L2 = [1,0;125,1];
%     Component_stack(:,:,n) = F_SM2_L2;
%     n=n+1
    L2 = [1, -1/125; 0, 1];
    Component_stack(:,:,n) = L2;
    n=n+1
%     F_L2_ETL2 = [1, 0; 125, 1];
%     Component_stack(:,:,n) = F_L2_ETL2;
%     n=n+1
    ETL2 = [1, 0; 0, 1]; %Modify. as necessary. This is assuming default value of F=inf. Should have no effect on geometric optics.
    Component_stack(:,:,n) = ETL2;
    n=n+1
%     F_ETL2_L3 = [1, 0; 125, 1];
%     Component_stack(:,:,n) = F_ETL2_L3;
%     n=n+1
    L3 = [1, -1/125; 0, 1];
    Component_stack(:,:,n) = L3;
    n=n+1
%     F_L3_M3 = [1, 0; 125, 1];
%     Component_stack(:,:,n) = F_L3_M3;
%     n=n+1
    % Grants  full width beam but with tilt. Should be tiltless!
%% Intra-Modular Path 1: Module 4 -> Imaging Plane
    fprintf("IMP_1")
    M3 = [-1, 0; 0, 1];
    Component_stack(:,:,n) = M3;
    n=n+1
    % 50/50? Assumed to be ideal, i.e. inert for Green light.
    % Mercury lamp should likewise have no effect?
    L4 = [1, -1/200; 0, 1];
    Component_stack(:,:,n) = L4;
    n=n+1
%     F_L4_DM1 = [1, 0; 1, 1];
%     Component_stack(:,:,n) = F_L4_DM1;
%     n=n+1
    % Dichroic? I'm treating it as a typical mirror here.
    DM1_green = [1, 0; 0, 1];
    Component_stack(:,:,n) = DM1_green;
    n=n+1
%     F_DM1_obj =  [1, 0; 1, 1]; %Negative b/c of mirror transform - is now going "opposite direction" on optical axis.
%     Component_stack(:,:,n) = F_DM1_obj;
%     n=n+1
    %OBJ = ???
    %{Output}

  %%Computation
  endstep = 2075;
ray_top_record = zeros(1, endstep);
ray_bot_record = zeros(1, endstep);

%% Top Ray
 %units of arbitrary thickness. I choose milimeters for my setup.
component_num = 1;
component_coords = [500, 625, 750, 790, 830, 875, 1000, 1125, 1250, 1375, 1500, 1625, 1750, 1875, 1975, -1]; %Gives the step number location of the component. After final component, set it to 0 so it won't trigger again.
F_step = [1, 0; 1, 1];
R_top = [0; 1];
for z = 1:1:endstep
    if z == component_coords(component_num) 
        z=z
        Component_stack(:,:,component_num)
        R_out = Component_stack(:,:,component_num) * R_top;
        component_num = component_num + 1;
        R_out=R_out
    else
        
        R_out = F_step * R_top;
    end
    R_top=R_out;
    ray_top_record(:, z) = R_out(2);
end

%% Bottom Ray
%units of arbitrary thickness. I choose centimeters for my setup.
component_num = 1; %Gives the step number location of the component. After final component, set it to 0 so it won't trigger again.
F_step = [1, 0; 1, 1];
R_bot = [0;-1];
for z = 1:1:endstep
    if z == component_coords(component_num) 
        component_num=component_num
        z=z
        R_out = Component_stack(:,:,component_num) * R_bot
        component_num = component_num + 1;
    else
        
        R_out = F_step * R_bot;
    end
    R_bot=R_out;
    ray_bot_record(:, z) = R_out(2);
end
%% Analysis and Visualization
offset_height = 600;
ray_record_img_ = zeros((offset_height*2), endstep);
m=1
for pix_col = 1:endstep
      if pix_col==component_coords(m)
            ray_record_img(:,  pix_col-5:pix_col+5) = 150;
            m=m+1
      end
    for pix_row = 1:1:(offset_height*2)
        if 100*ray_top_record(pix_col) + offset_height >= pix_row && 100*ray_bot_record(pix_col) + offset_height <= pix_row
            ray_record_img(pix_row, pix_col) = 255;
        elseif 100*ray_top_record(pix_col) + offset_height <= pix_row && 100*ray_bot_record(pix_col) + offset_height >= pix_row
            ray_record_img(pix_row, pix_col) = 255;
        end
        
    end
end
%image(ray_top_record*255)
image(ray_record_img)
       