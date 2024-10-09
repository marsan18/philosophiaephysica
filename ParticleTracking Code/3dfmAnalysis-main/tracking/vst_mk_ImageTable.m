function outs = vst_mk_ImageTable(VidTable)

N = size(VidTable,1);

video_files = fullfile(VidTable.Path, VidTable.VideoFiles);
fframe_files = fullfile(VidTable.Path, VidTable.FirstFrameFiles);
mip_files = fullfile(VidTable.Path, VidTable.MipFiles);

for f = 1:N
    
        Fid(f,1) = VidTable.Fid(f);
        
        if ~isempty(dir(fframe_files{f}))
            FirstFrames{f,1} = imread(fframe_files{f});
        else
            FirstFrames{f,1} = [];
        end
        
        if ~isempty(dir(mip_files{f}))
            Mips{f,1} = imread(mip_files{f});
        else
            Mips{f,1} = [];
        end
        
end

% Fid = categorical(Fid);

outs = table(Fid, FirstFrames, Mips);

% Table properties
outs.Properties.Description = '';

% Variable Properties
outs.Properties.VariableDescriptions{'Fid'} = VidTable.Properties.VariableDescriptions{'Fid'};
outs.Properties.VariableDescriptions{'FirstFrames'} = 'First image in collected video.';
outs.Properties.VariableDescriptions{'Mips'} = 'Intensity projections for collected video.';

return