function msdout = pan_video_msd(data_in, metadata)

video_tracking_constants;
pan_video_tracking_constants;

plate_type = '96well';

systemid = 'panoptes';

% metadata = pan_load_metadata(filepath, systemid, plate_type);
% 
% frame_rate = metadata.instr.frame_rate;
% 
% 
% 
% if ischar(filepath)
%     data_in = pan_load_tracking(filepath, systemid, filetype, filt);
% elseif isnumeric(filepath)
%     data_in = filepath;    
% end

pass_list = unique(data_in(:,PANPASS))';

frame_rate = metadata.instr.fps_fluo;
duration = metadata.instr.seconds;
Nframes = floor(frame_rate * duration);

numtaus = 35;
percent_duration = 1;
winout = msd_gen_taus(Nframes, numtaus, percent_duration);


mcuparams = metadata.mcuparams;

msdout.pass = [];
msdout.well = [];
msdout.trackerID = [];
msdout.tau = [];
msdout.msd = [];
msdout.Nestimates = [];
msdout.window = winout;

for p = 1:length(pass_list)
    this_pass = pass_list(p);
    
    idx = find(data_in(:,PANPASS) == this_pass);
    
    this_pass_data = data_in(idx,:);
    
    well_list = unique(this_pass_data(:,PANWELL))';
    
    for w = 1:length(well_list)
        this_well = well_list(w);
        
        idx = find(this_pass_data(:,PANWELL) == this_well);
        

        this_pass_and_well_data = this_pass_data(idx,:);
        
        Ntrackers = length(unique(this_pass_and_well_data(:,PANID)));
        mypass = repmat(this_pass,1,Ntrackers);
        mywell = repmat(this_well,1,Ntrackers);

        nrows = size(this_pass_and_well_data,1);
        ncols = size(NULLTRACK,2);

        vtdata = zeros(nrows, ncols);

        vtdata(:,TIME)    = this_pass_and_well_data(:,PANFRAME) * 1./frame_rate;
        vtdata(:,ID)      = this_pass_and_well_data(:,PANID);
        vtdata(:,FRAME)   = this_pass_and_well_data(:,PANFRAME);
        vtdata(:,X)       = this_pass_and_well_data(:,PANX);
        vtdata(:,Y)       = this_pass_and_well_data(:,PANY);
        vtdata(:,AREA)    = this_pass_and_well_data(:,PANAREA);
        vtdata(:,SENS)    = this_pass_and_well_data(:,PANSENS);
        vtdata(:,PASS)    = this_pass_and_well_data(:,PANPASS);
        vtdata(:,WELL)    = this_pass_and_well_data(:,PANWELL);

        myMCU = mcuparams.mcu((mcuparams.pass == this_pass) & (mcuparams.well == this_well));

        calib_um = pan_mcu2um(myMCU, systemid, this_well, metadata);
        
        vtdata(:,[X Y]) = vtdata(:,[X Y]) * calib_um * 1e-6;
        mymsd = video_msd(vtdata, winout, frame_rate, calib_um, 'n', 'n');
        
        
        msdout.pass       = [msdout.pass       mypass];
        msdout.well       = [msdout.well       mywell];
        msdout.trackerID  = [msdout.trackerID  mymsd.trackerID];        
        msdout.tau        = [msdout.tau        mymsd.tau];
        msdout.msd        = [msdout.msd        mymsd.msd];
        msdout.Nestimates = [msdout.Nestimates mymsd.Nestimates];
        

    end
end

return;

    
    