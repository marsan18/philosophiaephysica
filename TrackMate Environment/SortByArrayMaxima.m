%% Sort Cell by column A in sub-arrays
function [OutputStruct] = SortByArrayMaxima(InputStruct, index)
    InputMaxima=cellfun(@max, InputStruct, 'UniformOutput', false);
        for k=1:numel(InputMaxima)
            InputMatrixMaxima(k,1) = InputMaxima{k}(:,index);
        end
    [~, center_id]=sort(InputMatrixMaxima);
    InputStruct=InputStruct(center_id);
    OutputStruct=cellfun(@max, InputStruct, 'UniformOutput', false);
end