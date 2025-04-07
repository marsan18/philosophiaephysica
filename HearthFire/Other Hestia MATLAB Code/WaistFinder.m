% The purpose of this function is to compute the beam waist of a Gaussian
% Beam. It should take an aperture radius, an unrestricted power, and a 
% restricted power, and from these compute the radius of the aperture.
% This uses a formula for the power of a gaussian beam passing thorugh a
% centered aperture.
function[BeamWaist] = WaistFinder(R, Input_Power, Output_Power)
    arguments
        R (1,1) double {mustBePositive, mustBeFinite, mustBeNumeric}
        Input_Power (1,1) double {mustBePositive, mustBeFinite, mustBeNumeric}
        Output_Power (1,1) double {mustBePositive, mustBeFinite, mustBeNumeric}
    end
    if Output_Power>=Input_Power
        error("Input Power Must Be Greater Than Output (transmitted) power")
    end
    BeamWaist = sqrt((-2*R^2)/log(1-Output_Power/Input_Power));
end