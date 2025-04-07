%% The idea here is to use matrix math to figure out the sample plane angle from SMII voltage
%Takes form [R; theta]
% R0 = [1;0]
% M1=[1,0;pi/2,1]
% D1 = [1, 125; 0, 1]
% RF = M1*D1*R0
clear all
clc
%% What if we just start after the mirror. Should have some radius and some angle theta imparted by the beam.
stepsize=100;
index=0;
for k = 0:1/stepsize:3
index=index+1;
   degrees=k;
theta=degrees*pi/180; % MUST BE IN RADIANS
% syms theta
SM2_out = [4; 2*theta]; % Output angle is 2 times mirror angle
SM2_RL1 = [1, 125; 0, 1]; % Transmission through air to first relay mirror
RL1 = [1,0;-1/125, 1]; % Transmission through first relay lens
RL1_ETL = [1, 125; 0, 1]; % Transmission from RL1 to ETL
ETL_RL2 = [1, 125; 0,1];
RL2 = [1, 0; -1/125,1]; % Transmission through second relay lens
RL2_TL = [1, 200; 0, 1]; %Transmission through air to tube lens
TL = [1, 0; -1/200, 1]; % Tube lens
TL_BFP = [1, 200; 0, 1]; % Tube lens (f=200) to objective lens (f=3.33333)
BFP_OBJ = [1, 3.3333; 0, 1];
OBJ = [1, 0; -1/3.3333, 1];

%WARNING: OBJECTIVE DELIBERATELY LEFT OUT CURRENTLY, as does not follow
%approx.
BFP = TL_BFP*TL*RL2_TL*RL2*ETL_RL2*RL1_ETL*RL1*SM2_RL1; % Cumulative transfer matrix
BFP_LS(:,index) = BFP*SM2_out;
M = BFP_OBJ*BFP;
PRE_OBJ_LS(:,index) = M*SM2_out;

%% NOTE CANNOT DO PARAXIAL APPROX AT THIS POINT, SO THEREFORE CANNOT USE SMALL ANGLE and must find manually
  % Also ignores in extant angle
  % NOTE WE USE SINE DUE TO ABBE SINE CONTIDION, WHICH Flat-field
  % objectives obey!
LS_ANGLE(index) = asind(PRE_OBJ_LS(1,index)/(3.333));
LS_WATER(index)=asind(sind(LS_ANGLE(index))*(1.333)/1.54); %asin(sin(oil angle)(n_oil/n_water))
end
angle_index= 0:1/stepsize:3;
SM2angle_LSangle_BFPpostion=real(cat(1,angle_index, LS_ANGLE, LS_WATER, BFP_LS(1,:)))
% LS_simple = simplify(LS_ANGLE)
% format short
% LS_simple

% LS_ANGLE = -atan((406000*theta)/3333)
% This is simply atan(2*(F_TL+F_OBJ)/F_OBJ)
%% SOMETHING IS WRONG!!