function [AvgSteps] = AvgVH(VanHoveData, dt)
    for i=1:length(VanHoveData)
        if not(isempty(VanHoveData{i}))
            AvgSteps(i,2) = std(VanHoveData{i}(:,1));
            AvgSteps(i,3) = std(VanHoveData{i}(:,2));
            AvgSteps(i,1) = dt*i;
        else
            AvgSteps(i, 2:3)= NaN;
        end
    end
end

