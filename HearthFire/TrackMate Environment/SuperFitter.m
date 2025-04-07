function [fullfit] = SuperFitter(SuperStruct, tau, shoulders, tophat)
% This function accepts a SuperStruct v1.1.
% It calls multifits on SuperScripts van Hove data for each tau value
% indicated by the tau input arugements.
% It outputs fullfit, a cell containing one cell per each tau value with
% the outputs of multifits.
arguments
    SuperStruct {isstruct}
    tau {isrow}= []
    shoulders {isrow} = [-1, 1] % typically depends on tau
    tophat {isrow} = [-0.2, 0.2] % usually doesn't need to be changed
end
tic()
if SuperStruct.version ~= 1.1
    warning("SuperStruct is not latest version")
end

if isempty(tau)
    tau = SuperStruct.VanHoveData.tau;
end

fullfit = {};
%% Calling multifits() on van Hove for every tau value
for k=tau
    % figure()
    % title(strcat('Van Hove Distribution of qdots in PAAm at 200fps for \tau=', string(k)))
    dx = transpose(SuperStruct.VanHoveData.CenterPoint{k});
    pdx = SuperStruct.VanHoveData.EquiProb{k};
    if sum(isnan(pdx))>0
        error(strcat('Broken VanHove Data for \tau=', string(k)))
    else
        [fitCell] =multifits(dx,pdx, shoulders, tophat);
    end
    fullfit{k} = fitCell; %#ok<AGROW> No need to preallocate, it's small.
    % title(strcat('Van Hove Distribution of qdots in PAAm at 200fps for \tau=', string(k)))
    centerFigures()
end
toc()
end