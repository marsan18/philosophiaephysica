function v = get_bead(data, IDNum)
% GET_BEAD Retrieve a tracker's data from a video_tracking structure.
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
%  
% Extracts a bead's video tracking data from load_video_tracking.
%  
%  [v] = get_bead(data, IDNum);  
%   
%  where "data" is the output matrix from load_video_tracking
%        "IDNum" is the bead's ID Number 
%   
%  05/09/05 - created; jcribb.
%  05/22/05 - modified to accomodate table or stucture of vectors format

video_tracking_constants;

% determine whether the input data is in the table or structure of vectors
% format...
if isfield(data, 'id')
    idx = find(data.id == IDNum);
    
    v.id= data.id(idx);    
    v.t = data.t(idx);
    v.frame = data.frame(idx);
    v.x = data.x(idx);
    v.y = data.y(idx);
    v.z = data.z(idx);
    if isfield(data,'roll');    v.roll = data.roll(idx);    end;
    if isfield(data,'pitch');   v.pitch= data.pitch(idx);   end;
    if isfield(data,'yaw');     v.yaw  = data.yaw(idx);     end;                    
else
    this_bead = find(data(:,ID) == IDNum);
    v = data(this_bead,:);
end

return