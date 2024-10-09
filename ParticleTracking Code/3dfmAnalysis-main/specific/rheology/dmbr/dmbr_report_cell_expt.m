function rheo = dmbr_report_cell_expt(filename, excel_name, main_directory, headerheight, plot_select, seq_array, report_params)
%
% Last modified 08/03/12 (stithc)
% Christian Stith <chstith@ncsu.edu> and Jeremy Cribb, 06-28-2012
% dmbr_report_cell_expt.m
% Generates an in-depth analysis and visual HTML and Excel reports of 3DFM
% data. Requires a metadata file as well as a data file to run. Also
% requires a poleloc.txt file in the same directory, containing x, y
% coordinates of the location of the pole tip. [Example: "134, 219"]
% Can be run in conjunction with other similar files through
% dmbr_multi_file_report.
% 
% This code is in great need of refactoring. Keep regression in mind, since
% dmbr_multi_file_report and dmbr_adjust_report both depend greatly on the
% specific return format of this function.
%
% Required Parameters:
%   filename: the name of the file to be analyzed
% Optional Parameters:
%   excel_name: the name of the analysis being created
%   figfolder: the name of the folder for storing images
%   headerheight: the height of the header at the top of the Excel
%       spreadsheet that will be written to
%   seq_array: the array of selected sequences
%   report_params: report parameters (see dmbr_check_input_params)
% Returns:
%   A two-cell array. Cell 1 contains an array (bxs) detailing: the number of beads
%   in the file, the maximum number of sequences in the file, the number of
%   beads used (selected), and the maximum number of sequences used (selected). Cell 2 contains
%   a logical array (inseqs) detaling the usage of individual sequences
%   found in the file.
% 
% Command Line Syntax:
%   dmbr_report_cell_expt(<File_Name_No_Extension>)
% Example:
%   dmbr_report_cell_expt('vid15_Panc1_Control')
%
rheo = 2;
dmbr_constants;                                               

%%%%%%%%%%%% parameter check %%%%%%%%%%%%
[pathname, filename_root, ext] = fileparts(filename);

if(nargin < 2)
    excel_name = filename_root;
end

if(nargin < 3)
    figfolder = [excel_name '_html_images'];
    main_directory = [pwd filesep];
end

[~, excel_root, ~] = fileparts(excel_name);
figfolder = strcat(main_directory, excel_root, '_html_images');
local_figures = [excel_root '_html_images'];

if(nargin < 4)
    headerheight = 1;
end
if(nargin < 5)
    plot_select = cell(9);
    plot_select(1:9) = {1};
    plot_select(3) = {0};
    plot_select(5) = {0};
    plot_select(8) = cellstr('Power Law (Fabry)');
end
fit_type = plot_select{8};
fit_type = fit_type{:};

table_mode = plot_select{9}; % determines G ratio table mode

plot_select = cell2mat(plot_select(1:6));

specific_seqs = 0;
if(nargin > 5)
    specific_seqs = 1;
end




% Three phases: 1) Load the data, 2) Maybe process the data, 3) Report the results

% general
% navigate to directory of file
if(~isempty(pathname))
    cd(pathname);
end;


close all;

% load metadata
metadatafile = strcat(filename_root,  '.vfd.mat');
if strcmp('.vfd.mat', metadatafile)==1 || ~exist(metadatafile);%, 'file')
    fprintf('***The file ');
    fprintf(metadatafile);
    fprintf(' was not found. This file will be skipped.\n');
    return
end

m = load(metadatafile);
a        = m.bead_radius;
pulses   = m.pulse_widths;
voltages = m.voltages;
calib_um = m.calibum;

% load tracking data
trackingfile = tracking_check(filename_root);
if isempty(trackingfile)
    return;
end
% try multiple file extensions

d = load(trackingfile);

if ( plot_select(5) == 1 )
    m.fps = plot_select(6);
else
    m.fps =  0;
end
frame_rate = m.fps;

% fprintf(['HELLO: ' num2str(m.fps) '\n']);

d = load_video_tracking(trackingfile, m.fps, 'pixels', calib_um, 'absolute', 'yes', 'matrix');
beadmax = get_beadmax(d);

calibfile = 'NULL';
if(plot_select(2) || plot_select(3) || plot_select(4))
    % load calibration 
    filelist = dir('*.vfc.mat');
    if isempty(filelist);
        error('No calibration file found.');
    end
    calibfile = filelist.name;
    c = load(calibfile);
end

% load poleloc file
filelist2 = dir('poleloc.txt');
try
    polelocfile = filelist2.name;
catch
    warning ('Poleloc file not found');
end
try
    p = load(polelocfile);
catch
    warning ('Poleloc file not found');
end

% obtain input parameters
input_params.metafile = metadatafile;
input_params.trackfile = trackingfile;
input_params.calibfile = calibfile;
input_params.poleloc = p;
input_params.force_type = 'disp';
input_params.tau = 6.25;
input_params.fit_type = fit_type;
input_params.scale = 0.5;
input_params.fps = frame_rate;






if(plot_select(2) || plot_select(3) || plot_select(4))
    if(specific_seqs)
        rheo = dmbr_run(input_params, seq_array);
    else
        rheo = dmbr_run(input_params);
    end
    rheo_table = rheo.raw.rheo_table;
else
    m.poletip_radius = 0;
    m.fps = frame_rate;
    [vid_table,  junk] = dmbr_init(m);
    rheo_table = vid_table;
end

beads  = unique(rheo_table(:,ID))';
seqs   = unique(rheo_table(:,SEQ))';


% create plot folder
if ~exist(figfolder, 'dir')
        mkdir(figfolder);
end
figfolder = [figfolder filesep];

% Loop start variables

lastradial = 0; % stores radial displacement of last pull
lastcompliance = 0; % stores compliance of last pull
delay = 0; % the time delay at beginning of data file
maxseqs = 0; % the maximum number of sequences plotted
plots(length(beads)) = 0; % logical array, true if bead is used

% Parse out identifying file number from file name
vidID = ['vid' num2str(sscanf(filename_root, 'vid%f'))];
% Stores the number of sequences used on each bead
inseqs = zeros(length(beads),1);


% process each bead
for b = 1 : length(beads)
    
    colorindex = length(seqs)*(b-1)+1;
    pcolor = length(seqs)+1;
    if(specific_seqs)
        temp_c = find(cell2mat(seq_array(colorindex:end))==0, 1, 'first');
        if ~isnan(temp_c)
            pcolor = min(pcolor, temp_c);
        end
    end
    
    % Assume bead is needed
    plots(b) = 1;
    
    ti1 = 0;
    ti2 = pulses(1);
    
    %
    gaps = [0, 0; 0, 0; 0, 0];
    
    fitc = 0;
    xstart = 0;
    ystart = 0;
    Jstart = 0;
    Jlast = 0;
    
    % process each sequence. adapted from dmbr_report.
    for s = 1 : length(seqs)
        
        plot_color = 0;
        switch pcolor
            case 1
                plot_color = 0;
            case 2
                plot_color = 1;
            otherwise
                plot_color = (s-1)/(pcolor-2);
        end
        
        % Sequence index
        index = length(seqs)*(b-1) + s;
        % Check if sequence/bead is not needed (box not checked in Sequence Selector) (See dmbr_adjust_report)
        if(specific_seqs && index <= length(seq_array) && ~seq_array{index})
            if s==1
                plots(b) = 0;
            end
            break;
        end
        
        clear filtx_on;
        
        ftable = dmbr_filter_table(rheo_table, beads(b), seqs(s), []);
        
        % break if no data
        if size(ftable,1) <= 0
            break;
        end
        % update max sequences
        if(s > maxseqs)
            maxseqs = s;
        end
        % update individual sequence
        inseqs(b) = s;
        
        tcont = ftable(:,TIME);
        t = tcont - tcont(1);

        %subtract delay: the initial delay before the sequences begin
        
        x1 = ftable(:,X);
        y1 = ftable(:, Y);
        
        if s==1
            delay = tcont(1) - t(1);
            xstart = x1(1);
            ystart = y1(1);
        end        
        tcont = tcont - delay;        
        x = x1-xstart;
        y = y1-ystart;
        
        % calculate displacement from x and y
        radial = magnitude(x, y);
        x1 = x1 - x1(1);
        y1 = y1 - y1(1);
        radialdiff = magnitude(x1, y1);
        
        
        % compliance
        if(plot_select(2) || plot_select(3))
            Jx = ftable(:,J);
            if s==1
                Jstart = Jx(1);
            end
            Jx = Jx - Jstart;
            Jxdiff = Jx - Jx(1);
            Jx = Jx + Jlast;
            Jlast = Jx(end);
        end

        
        idx = find(ftable(:,VOLTS) > 0);
        
        fprintf('s= %g\n', s);
        
        % displacement vs. time plot: stacked
        if(plot_select(1))
            
            
            if ~isgraphics('txFig');    txFig   = figure; end
            if ~isgraphics('txFig2');   txFig2  = figure; end
            if ~isgraphics('txcFig');   txcFig  = figure; end
            if ~isgraphics('txcFig2');  txcFig2  = figure; end
            
            figure(txFig);
            hold on;
            plot(t,radialdiff*1e6, 'Color', [0 plot_color 0]);

            title([vidID ': Radial displacement stack, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('displacement [\mum]');
            pretty_plot;
            hold off;
            drawnow;

            figure(txFig2); 
            hold on;
            plot(t,radialdiff*1e6, 'Color', [0 plot_color 0]);
            title([vidID ': Radial displacement stack, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('displacement [\mum]');
            pretty_plot;
            hold off;
            drawnow;

            % displacement vs. time plot: cumulative
            
            radial = vertcat(gaps(1,1), radial);
            tcont = vertcat(gaps(1,2), tcont);
            
            figure(txcFig);
            hold on;
            set(gcf, 'Position', [300, 300, 1000, 400]);
            % scale all cumulative plots by the maximum number of sequences in
            % their bead
            xlim([0 length(seqs)*sum(pulses)]);
            plot(tcont,radial*1e6, 'Color', [0 plot_color 0]);
            title([vidID ': Radial displacement, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('displacement [\mum]');
            pretty_plot;
            hold off;
            drawnow;

            figure(txcFig2); 
            hold on;
            plot(tcont,radial*1e6, 'Color', [0 plot_color 0]);
            title([vidID ': Radial displacement, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('displacement [\mum]');
            pretty_plot;
            hold off;
            drawnow;

            tcont(1) = [];
            gaps(1, 1:2) = [radial(end), tcont(end)];
        end

        if(plot_select(2))
            if ~isgraphics('tJxFig');   tJxFig  = figure; end        
            if ~isgraphics('tJxFig2');  tJxFig2 = figure; end
            if ~isgraphics('tJxcFig');  tJxcFig  = figure; end
            if ~isgraphics('tJxcFig2'); tJxcFig2  = figure; end
            

            
            % compliance vs. time plot: stacked
            figure(tJxFig); 
            hold on;
            plot(t,Jxdiff, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance stack, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;

            figure(tJxFig2); 
            hold on;
            plot(t,Jxdiff, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance stack, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;

            % compliance vs. time plot: cumulative
            
            Jx = vertcat(gaps(2,1), Jx);
            tcont = vertcat(gaps(2,2), tcont);
            
            figure(tJxcFig); 
            hold on;
            set(gcf, 'Position', [300, 300, 1000, 400]);
            % scale all cumulative plots by the maximum number of sequences in
            % their bead
            xlim([0 length(seqs)*sum(pulses)]);
            plot(tcont, Jx, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;

            figure(tJxcFig2); 
            hold on;
            plot(tcont,Jx, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;
            


        end
        % Fit plot (Jeffrey)
        if(plot_select(3))
            
            if ~isgraphics('tJxcfFig');  tJxcfFig  = figure; end
            if ~isgraphics('tJxcfFig2'); tJxcfFig2  = figure; end
            
            Jx = vertcat(gaps(2,1), Jx);
            tcont = vertcat(gaps(3,2), tcont);
            
            idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(1));
            switch fit_type
                case 'Jeffrey'
                    G = rheo.G(idx);
                    eta1 = rheo.eta(idx, 1);
                    eta2 = rheo.eta(idx, 2);
                    fit = (1/G + (tcont-ti1)/eta2 - 1/G*exp(-G*(tcont-ti1)/eta1)).*(heavi(tcont,ti1)') - (1/G + (tcont-ti2)/eta2 - 1/G*exp(-G*(tcont-ti2)/eta1)).*(heavi(tcont,ti2)');
                case 'Power Law (Fabry)'
                    G = rheo.G(idx);
                    beta = rheo.eta(idx);
                    fit = ((1/G).*(tcont-ti1).^beta).*(heavi(tcont, ti1)') - ((1/G).*(tcont-ti2).^beta).*(heavi(tcont, ti2)');
            end
            
            ti1 = ti1 + sum(pulses);
            ti2 = ti2 + sum(pulses);
            fit = fit + fitc;
%            fit = vertcat(gaps(3,1), fit);
            gaps(3, 1) = fit(end);
            
            figure(tJxcfFig);
            hold on;
            set(gcf, 'Position', [300, 300, 1000, 400]);
            % scale all cumulative plots by the maximum number of sequences in
            % their bead
            xlim([0 length(seqs)*sum(pulses)]);
            plot(tcont, fit, 'Color', [0 0 1]);
            xlim([0 length(seqs)*sum(pulses)]);
            plot(tcont,Jx, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance of ' fit_type ' model, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;
            

            
            figure(tJxcfFig2); 
            hold on;
            plot(tcont, fit, 'Color', [0 0 1]);
            xlim([0 length(seqs)*sum(pulses)]);
            plot(tcont,Jx, 'Color', [plot_color 0 0]);
            title([vidID ': Compliance of ' fit_type ' model, bead ' num2str(beads(b))]);
            xlabel('time [s]');
            ylabel('compliance [Pa^{-1}]');
            pretty_plot;
            hold off;
            drawnow;
            
            tcont(1) = [];
            Jx(1) = [];
            gaps(2, 1:2) = [Jx(end), tcont(end)];
            
            gaps(3, 1:2) = [fit(end), tcont(end)];
            fitc = gaps(3, 1);
            gaps(2, 1) = Jx(end);
            tcont(1) = [];
            fit(1) = [];
            Jx(1) = [];
        end
        
    end    
    
    % save and close all figures
    
    if(plots(b))
        
        
        txFigfilename   = [figfolder filename_root '.disp_stack.bead'  num2str(beads(b)) '.png'];
        txFigfilename2  = [figfolder filename_root '.disp_stack.bead'  num2str(beads(b)) '.fig'];
        txcFigfilename  = [figfolder filename_root '.disp_seq.bead'  num2str(beads(b)) '.png'];
        txcFigfilename2  = [figfolder filename_root '.disp_seq.bead'  num2str(beads(b)) '.fig'];

        tJxFigfilename  = [figfolder filename_root '.comp_stack.bead' num2str(beads(b)) '.png'];
        tJxFigfilename2  = [figfolder filename_root '.comp_stack.bead' num2str(beads(b)) '.fig'];
        tJxcFigfilename  = [figfolder filename_root '.comp_seq.bead' num2str(beads(b)) '.png'];
        tJxcFigfilename2  = [figfolder filename_root '.comp_seq.bead' num2str(beads(b)) '.fig'];
        
        tJxcfFigfilename  = [figfolder filename_root '.comp_seq_fit.bead' num2str(beads(b)) '.png'];
        tJxcfFigfilename2  = [figfolder filename_root '.comp_seq_fit.bead' num2str(beads(b)) '.fig'];
        
        

        if(plot_select(1))
            exportfig(txFig, txFigfilename, 'Format', 'png', 'height', 4.5, 'Color', 'cmyk', 'fontmode', 'fixed', 'fontsize', 13);
            exportfig(txcFig, txcFigfilename, 'Format', 'png', 'height', 4.5, 'Color', 'cmyk', 'fontmode', 'fixed', 'fontsize', 13);
            saveas(  txFig2,  txFigfilename2, 'fig');
            saveas(  txcFig2,  txcFigfilename2, 'fig');
            close(txFig);
            close(txcFig);
            close(txFig2);
            close(txcFig2);
        end
        if(plot_select(2))
            exportfig(tJxFig, tJxFigfilename, 'Format', 'png', 'height', 4.5, 'Color', 'cmyk', 'fontmode', 'fixed', 'fontsize', 13);
            exportfig(tJxcFig, tJxcFigfilename, 'Format', 'png', 'height', 4.5, 'Color', 'cmyk', 'fontmode', 'fixed', 'fontsize', 13);
            saveas( tJxFig2, tJxFigfilename2, 'fig');
            saveas( tJxcFig2, tJxcFigfilename2, 'fig');
            close(tJxFig);
            close(tJxcFig);
            close(tJxFig2);
            close(tJxcFig2);
        end
        
        if(plot_select(3))
            exportfig(tJxcfFig, tJxcfFigfilename, 'Format', 'png', 'height', 4.5, 'Color', 'cmyk', 'fontmode', 'fixed', 'fontsize', 13);
            saveas( tJxcfFig2, tJxcfFigfilename2, 'fig');
            close(tJxcfFig);
            close(tJxcfFig2);
        end
    
    end

end


% report
outfile = [excel_name '.html'];
% append information (NOT write)
fid = fopen(outfile, 'a+');

nametag = filename_root;
% HTML section header
fprintf(fid, ['<title>' excel_root '</title>\n']);
fprintf(fid, '<hr>\n');
fprintf(fid, '<a name="%s"><h2>%s</h2></a><br/>', filename_root, nametag);
fprintf(fid, ' <b>Path:</b>  %s <br/>\n', pathname);
fprintf(fid, '<a href="#Contents">Back to Top</a></p>\n');

% check to see if file is used; if so, write reports
info = 0;
for b=1:length(beads)
    if(plots(b))
        info = 1;
    end
end

rowsused = 0;

if info

    

    % Table 1: Identifying information
    fprintf(fid, '<b>General Parameters</b><br/>\n');
    fprintf(fid, '<table border="2" cellpadding="6"> \n');
    fprintf(fid, '<tr> \n');
    fprintf(fid, ' <td align="left"><b>File:</b> %s </td> \n', filename_root);
    fprintf(fid, ' <td align="left"><b>Pulse Voltages (V):</b> [%s] </td> \n', num2str(voltages));
    fprintf(fid, ' <td align="left" width=250><b>Bead Diameter (um):</b> %g </td> \n', a*2);
    fprintf(fid, ' <td align="left"><b>Pulse Widths (s):</b> [%s]</td> \n', num2str(pulses));
    fprintf(fid, ' <td align="left"><b>Number of Trackers:</b> %i </td> \n', beadmax);
    fprintf(fid, '</tr> \n');
    fprintf(fid, '</table> \n'); 

    fprintf(fid, '<br/>');

    % Table 3: G, R^2, and eta1 & eta2 for each bead/sequence

    G1 = 0;
    
    if(plot_select(2) || plot_select(3))
    
        fprintf(fid, '<table border="2" cellpadding="6"> \n');
        fprintf(fid, '<tr> \n');
        fprintf(fid, '<td><b>Summary<br/>of Results</b></td> \n');
        
        G_buffer = '';
        
        % two fit types: Fabry and Jeffrey
        switch fit_type
            case 'Power Law (Fabry)'
                numvars = 3;
                for s = 1 : maxseqs
                    if ( table_mode == 1 )
                        fprintf(fid, '   <td align="center" colspan="3"><b>Sequence #%d</b> </td> \n', s);
                    end
                    if ( s == 1 )
                        G_buffer = [G_buffer '   <td align="center" colspan="1"><b>G1</b> </td> \n'];
                    else
                        G_buffer = [G_buffer '   <td align="center" colspan="1"><b>G' num2str(s) '/G1</b> </td> \n'];
                    end
                end
                fprintf(fid, '   <td align="center" colspan="4"><b>G Ratios</b> </td> \n');
                fprintf(fid, '</tr> \n');
                fprintf(fid, '   <td align="center"><b>Tracker ID</b> </td> \n');
                
                if ( table_mode == 1 )
                    for s = 1 : maxseqs
                        fprintf(fid, '   <td align="center"><b>G</b> </td> \n');
                        fprintf(fid, '   <td align="center"><b>beta</b> </td> \n');
                        fprintf(fid, '   <td align="center"><b>R^2</b> </td> \n');
                    end
                end
                fprintf(fid, G_buffer);
                fprintf(fid, '</tr> \n\n');
                
                printed = 1;
                for b = 1 : length(beads)    
                    if(printed) fprintf(fid, '<tr> \n'); end
                    if(plots(b))
                        fprintf(fid, '<td align="center"> %i </td> \n', b);  
                    end
                    printed = 0;
                    G_buffer = '';
                    for s = 1 : maxseqs
                        index = length(seqs)*(b-1) + s;
                        idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
                        if(specific_seqs && index > length(seq_array))
                            if ( table_mode == 1 )
                                fprintf(fid, '<td colspan="%i" />', numvars*(maxseqs-s+1));
                            end
                            break;
                        end
                        if(specific_seqs && (~seq_array{index}))  || isnan(rheo.G(idx))
                            if ( table_mode == 1 )
                                fprintf(fid, '<td colspan="%i" />', numvars*(maxseqs-s+1));                            
                            end
                            break;
                        end
                        printed = 1;
                        if(s==1)
                            G1 = rheo.G(idx);
                        	% G1 for the first bead/sequence
                            G_buffer = [G_buffer '<td align="center"> ' num2str(G1) ' </td> \n'];                            
                        else
                        	% GX/G1 for this bead/sequence
                            G_buffer = [G_buffer '<td align="center"> ' num2str(rheo.G(idx)/G1) ' </td> \n'];
                        end
                        if ( table_mode == 1 )
                            % G for this bead/sequence
                            fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.G(idx));
                            % beta for this bead/sequence
                            fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx));
                            % R^2
                            fprintf(fid, '<td align="center"> %0.4f </td> \n', rheo.Rsquare(idx));
                        end
                    end
                    if(printed)
                        fprintf(fid, G_buffer);
                        fprintf(fid, '</tr> \n');
                    end
                end
                
                
                
                
            case 'Jeffrey'
                numvars = 4;
                for s = 1 : maxseqs
                    if ( table_mode == 1 )
                        fprintf(fid, '   <td align="center" colspan="4"><b>Sequence #%d</b> </td> \n', s);
                    end
                    if ( s == 1 )
                        G_buffer = [G_buffer '   <td align="center" colspan="1"><b>G1</b> </td> \n'];
                    else
                        G_buffer = [G_buffer '   <td align="center" colspan="1"><b>G' num2str(s) '/G1</b> </td> \n'];
                    end
                end
                fprintf(fid, '   <td align="center" colspan="4"><b>G Ratios</b> </td> \n');
                fprintf(fid, '</tr> \n');
                fprintf(fid, '   <td align="center"><b>Tracker ID</b> </td> \n');
                
                if ( table_mode == 1 )
                    for s = 1 : maxseqs
                        fprintf(fid, '   <td align="center"><b>G</b> </td> \n');
                        fprintf(fid, '   <td align="center"><b>eta1</b> </td> \n');
                        fprintf(fid, '   <td align="center"><b>eta2</b> </td> \n');
                        fprintf(fid, '   <td align="center"><b>R^2</b> </td> \n');
                    end
                end
                fprintf(fid, G_buffer);
                fprintf(fid, '</tr> \n\n');

                printed = 1;
                for b = 1 : length(beads)    
                    if(printed) fprintf(fid, '<tr> \n'); end
                    if(plots(b))
                        fprintf(fid, '<td align="center"> %i </td> \n', b);  
                    end
                    G_buffer = '';
                    printed = 0;
                    for s = 1 : maxseqs
                        index = length(seqs)*(b-1) + s;
                        idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
                        if(specific_seqs && index > length(seq_array))
                            % Fill with blanks to G Ratios
                            if ( table_mode == 1 )
                                fprintf(fid, '<td colspan="%i" />', numvars*(maxseqs-s+1));
                            end
                            break;
                        end
                        if(specific_seqs && (~seq_array{index}))  || isnan(rheo.G(idx))
                            % Fill with blanks to G Ratios
                            if ( table_mode == 1 )
                                fprintf(fid, '<td colspan="%i" />', numvars*(maxseqs-s+1));
                            end
                            break;
                        end
                        printed = 1;
                        if(s==1)
                            G1 = rheo.G(idx);
                        	% G1 for the first bead/sequence
                            G_buffer = [G_buffer '<td align="center"> ' num2str(G1) ' </td> \n'];                            
                        else
                        	% GX/G1 for this bead/sequence
                            G_buffer = [G_buffer '<td align="center"> ' num2str(rheo.G(idx)/G1) ' </td> \n'];
                        end
                        if ( table_mode == 1 )
                            % G for this bead sequence
                            fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.G(idx));
                            % eta1 for this bead/sequence
                            fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx, 1));
                            % eta2 for this bead/sequence
                            fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx, 2));
                            % R^2
                            fprintf(fid, '<td align="center"> %0.4f </td> \n', rheo.Rsquare(idx));
                        end
                    end
                    if(printed)
                        fprintf(fid, G_buffer);
                        fprintf(fid, '</tr> \n');
                    end
                end
        end
        fprintf(fid, '</table> \n\n');

        fprintf(fid, '<br/> \n\n');
    end


    % Plots
    for b = 1:length(beads)
        if(~plots(b))
            continue;
        end
        txFigfilename   = [local_figures filesep filename_root '.disp_stack.bead'  num2str(beads(b)) '.png'];
        txcFigfilename   = [local_figures filesep filename_root '.disp_seq.bead'  num2str(beads(b)) '.png'];
        tJxFigfilename  = [local_figures filesep filename_root '.comp_stack.bead' num2str(beads(b)) '.png'];
        tJxcFigfilename   = [local_figures filesep filename_root '.comp_seq.bead'  num2str(beads(b)) '.png'];
        tJxcfFigfilename = [local_figures filesep filename_root '.comp_seq_fit.bead' num2str(beads(b)) '.png']; 
        
        if(plot_select(1))
            fprintf(fid, '<img src= "%s" border=2 > \t', txFigfilename);
            fprintf(fid, '<img src= "%s" border=2 > \t', txcFigfilename);
        end
        if(plot_select(2))
            fprintf(fid, '<br/> \n');
            fprintf(fid, '<img src= "%s" border=2 > \t', tJxFigfilename);
            fprintf(fid, '<img src= "%s" border=2 > \n', tJxcFigfilename);
        end
        if(plot_select(3))
            %print the compliance fit
            spaces = repmat('&nbsp', 1, 154);
            fprintf(fid, ['<br/> \n' spaces]);
            fprintf(fid, '<img src= "%s" border=2 > \t', tJxcfFigfilename);
        end
        
        fprintf(fid, '<br/> \n');


    end

    fprintf(fid, '<br/> \n\n');

    
    spaces = repmat('&nbsp', 1, 114);
    fprintf(fid, [' <p><b>Pole tip image' spaces 'SpotTracker video screenshot</b><br/>\n']);
    
    % Image of pole tip
    poleimage = [filename_root, '.MIP.bmp'];
    if(exist(poleimage, 'file'))
        copyfile(poleimage,[figfolder filesep poleimage]);
    end
    % Video screenshot
    vidID = ['vid' num2str(sscanf(filename_root, 'vid%f'))];
    scrnshot = [vidID, '.png'];
    if(exist(scrnshot, 'file'))
        crop(scrnshot, 1, [figfolder], 0);
    end
    scrnshot = [figfolder filesep vidID '_crop.png'];
    cd(main_directory);
    
    fprintf(fid, '<img src= "%s" width=520 height=400 border=2> \n', poleimage);
    fprintf(fid, '<img src= "%s" width=520 height=400 border=2> \n', scrnshot);

    fclose(fid);


%%%%%%%%%%%%%%%%% Printing to Excel Spreadsheet %%%%%%%%%%%%%%%%%
    if(plot_select(4))
    % data matrix
        % initial columns
        numcol = 4;
        videocolumn = cell(length(beads), 1);
        beadcolumn = cell(length(beads), 1);
        voltagecolumn = cell(length(beads), 1);
        sequencecolumn = cell(length(beads), 1);

        for b = 1:length(beads)
            videocolumn(b, 1) = cellstr(filename_root);
            beadcolumn(b, 1) = cellstr(num2str(b));
            voltagecolumn(b, 1) = cellstr(num2str(voltages(1)));
            sequencecolumn(b, 1) = cellstr(num2str(inseqs(b)));
        end
        data = 0;
        header = 0; 
        
        if strcmp(fit_type, 'Jeffrey');
            numvars = 4;
            data = cell(length(beads),numvars*maxseqs);
            header = cell(2, maxseqs*numvars+numcol);
            % fill data
            for b = 1 : length(beads)
                for s = 1 : length(seqs)
                    index = length(seqs)*(b-1) + s;
                    idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
                    if(specific_seqs && index > length(seq_array))
                        break;
                    end
                    if(specific_seqs && ~seq_array{index}) || isnan(rheo.G(idx))
                        break;
                    end
                    data(b, (4*s-numvars+1)) = cellstr(num2str(rheo.G(idx)));
                    data(b, (4*s-numvars+2)) = cellstr(num2str(rheo.eta(idx, 1)));
                    data(b, (4*s-numvars+3)) = cellstr(num2str(rheo.eta(idx, 2)));
                    data(b, (4*s-numvars+4)) = cellstr(num2str(rheo.Rsquare(idx)));
                end
            end
            % create data header
            for b = 1:maxseqs
                header(1, 4*b+numvars-3) = cellstr(['Pull', num2str(b)]);
                header(2, 4*b+numvars-3) = cellstr('G');
                header(2, 4*b+numvars-2) = cellstr('eta1');
                header(2, 4*b+numvars-1) = cellstr('eta2');
                header(2, 4*b+numvars-0) = cellstr('R^2');
            end
            
        elseif strcmp(fit_type, 'Power Law (Fabry)')
            numvars = 3;
            data = cell(length(beads),numvars*maxseqs);
            header = cell(2, maxseqs*numvars+numcol);
            % fill data
            for b = 1 : length(beads)
                for s = 1 : length(seqs)
                    index = length(seqs)*(b-1) + s;
                    idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
                    if(specific_seqs && index > length(seq_array))
                        break;
                    end
                    if(specific_seqs && ~seq_array{index}) || isnan(rheo.G(idx))
                        break;
                    end
                    data(b, (numvars*s-numcol+2)) = cellstr(num2str(rheo.G(idx)));
                    data(b, (numvars*s-numcol+3)) = cellstr(num2str(rheo.eta(idx)));
                    data(b, (numvars*s-numcol+4)) = cellstr(num2str(rheo.Rsquare(idx)));
                end
            end
            % create data header
            for b = 1:maxseqs
                header(1, numvars*b+numcol-2) = cellstr(['Pull', num2str(b)]);
                header(2, numvars*b+numcol-2) = cellstr('G');
                header(2, numvars*b+numcol-1) = cellstr('beta');
                header(2, numvars*b+numcol-0) = cellstr('R^2');
            end
        end
        
        header(2, 1) = cellstr('video file');
        header(2, 2) = cellstr('bead id');
        header(2, 3) = cellstr('voltage');
        header(2, 4) = cellstr('sequences');        
        % concatenate tables
        results = [videocolumn, beadcolumn, voltagecolumn, sequencecolumn, data];
        % Delete empty rows
        rowsused = 0;
        for b=1:length(beads)
            rowsused = rowsused + 1;
            if(~plots(b))
                results(rowsused,:) = [];
                rowsused = rowsused - 1;
            end
        end

        xlfilename = strcat(excel_name, '.xlsx');
        cd(main_directory);
        if ~exist(xlfilename, 'file')
            results = vertcat(header, results);
            xlswrite(xlfilename, results);
        else
            xlswrite(xlfilename, header, 1, ['A' num2str(headerheight)]);
            xlsappend(xlfilename, results);
        end
    end
    
else
    fclose(fid);
end

% Return results
bxs = [length(beads), length(seqs), rowsused, maxseqs];
temp{1} = bxs;
temp{2} = inseqs;
rheo = temp;

return;

end


function fname = tracking_check(filename_root)
% finds a matching tracking file in the current directory
    fname_array = [...
        cellstr('.raw.vrpn.evt.mat')...
        cellstr('.raw.vrpn.mat'),...
        cellstr('.avi.vrpn.evt.mat'),...
        cellstr('.avi.vrpn.mat'),...
        cellstr('.vrpn.evt.mat'),...
        cellstr('.vrpn.mat')...
    ];
        
    for i=1:length(fname_array)
        filen = strcat(filename_root, fname_array{i});
        if exist(filen, 'file')
            fname = filen;
            return;
        end
    end
    warning('Tracking file not found');
    fname = 'NULL';
    return;
end
