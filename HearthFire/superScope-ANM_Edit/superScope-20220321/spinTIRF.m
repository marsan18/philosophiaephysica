function varargout = spinTIRF(varargin)
% SPINTIRF MATLAB code for spinTIRFData.fig
%      SPINTIRF, by itself, creates a new SPINTIRF or raises the existing
%      singleton*.
%
%      H = SPINTIRF returns the handle to a new SPINTIRF or the handle to
%      the existing singleton*.
%
%      SPINTIRF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in spinTIRFData.M with the given input arguments.
%
%      SPINTIRF('Property','Value',...) creates a new SPINTIRF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spinTIRF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spinTIRF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spinTIRF

% Last Modified by GUIDE v2.5 28-Apr-2017 21:47:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spinTIRF_OpeningFcn, ...
                   'gui_OutputFcn',  @spinTIRF_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before spinTIRF is made visible.
function spinTIRF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spinTIRF (see VARARGIN)

% Choose default command line output for spinTIRF
handles.output = hObject;
% path2MM = 'C:\Program Files\Micro-Manager-2.0beta';
% MMsetup_javaclasspath(path2MM);
MAX_Chs_Num = 4;
try
    spinTIRF_Config = load('spinTIRF_Config.mat');
    spinTIRFData.preDefinedPattern = spinTIRF_Config.spinTIRFData.preDefinedPattern;
catch
    spinTIRFData.preDefinedPattern = struct;
end
try
    spinTIRF_Config = load('spinTIRF_Config.mat');
    spinTIRFData.loadMicromanager = spinTIRF_Config.spinTIRFData.loadMicromanager;
    spinTIRFData.loadImageJ       = spinTIRF_Config.spinTIRFData.loadImageJ;
catch
    spinTIRFData.loadMicromanager = 0;
    spinTIRFData.loadImageJ       = 0;
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);
% Update handles structure
guidata(hObject, handles);
preDefinedPatternNamelist = fieldnames(spinTIRFData.preDefinedPattern);
set(handles.predefinedPatternList, 'String', preDefinedPatternNamelist);

% get pattern value
pattern = getCurrentPattern(handles, 1);
set(handles.currentPatternValue, 'data', pattern);

% setup NI daq board
% create a data acquisition session
try
    S = daq.createSession('ni');
    set(handles.warningText, 'visible', 'off');
    release(S);
catch
    set(handles.warningText, 'visible', 'on');
    set(handles.ni_panel, 'visible', 'off');
end

if spinTIRFData.loadImageJ
    spinTIRFData.ij = ij.ImageJ([], 1);
    if isempty(spinTIRFData.ij)
        msgbox('Open micromanager failed!');
    end
end
if spinTIRFData.loadMicromanager
    addpath('C:\Program Files\Micro-Manager-2.0beta');
    spinTIRFData.MMStudio = StartMMStudio('C:\Program Files\Micro-Manager-2.0beta');
    if isempty(spinTIRFData.MMStudio)
        msgbox('Open micromanager failed!');
    end
end
spinTIRFData.projectFolder = pwd;

% Define channel configuration panel
handles.configChsTab = uitabgroup('Parent', handles.ni_panel, 'Units', 'characters', 'Position', [26 2 36 12]);
for i = 1 : MAX_Chs_Num
    CHsTab{i} = uitab(handles.configChsTab, 'Title', ['CH' num2str(i)]);
%     eval(sprintf('%s=%s',['handles.ch' num2str(i) '_exp_text'],['uicontrol(''Style'', ''text'', ''parent'', CHsTab{i}, ''String'', ''ch''' num2str(i) ', ''Units'', ''characters'', ''Position'', [5 5 8 8]);']));
   switch i
       case 1
           handles.ch1_exp_text = uicontrol('style', 'text', 'string', 'CH1: ', 'Position', [10 90 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [75 90 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_nspinperexp_text = uicontrol('style', 'text', 'string', 'n_spin: ', 'Position', [10 65 50 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_nspinperexp = uicontrol('style', 'edit', 'string', '5', 'Position', [75 65 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [10 10 120 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_ELT_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [10 40 50 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_ELT = uicontrol('style', 'edit', 'string', '0', 'Position', [75 40 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [10 20 60 20], 'Parent', CHsTab{1}, 'units', 'characters', 'callback', {@ch1_getPattern_Callback, handles});
           
       case 2
           handles.ch2_exp_text = uicontrol('style', 'text', 'string', 'CH2: ', 'Position', [10 90 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [75 90 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_nspinperexp_text = uicontrol('style', 'text', 'string', 'n_spin: ', 'Position', [10 65 50 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_nspinperexp = uicontrol('style', 'edit', 'string', '5', 'Position', [75 65 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_ELT_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [10 40 50 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_ELT = uicontrol('style', 'edit', 'string', '0', 'Position', [75 40 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [10 10 120 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [10 20 60 20], 'Parent', CHsTab{2}, 'units', 'characters', 'callback', {@ch2_getPattern_Callback, handles});
           
       case 3
           handles.ch3_exp_text = uicontrol('style', 'text', 'string', 'CH3: ', 'Position', [10 90 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [75 90 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_nspinperexp_text = uicontrol('style', 'text', 'string', 'n_spin: ', 'Position', [10 65 50 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_nspinperexp = uicontrol('style', 'edit', 'string', '5', 'Position', [75 65 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [10 10 120 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_ELT_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [10 40 50 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_ELT = uicontrol('style', 'edit', 'string', '0', 'Position', [75 40 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [10 20 60 20], 'Parent', CHsTab{3}, 'units', 'characters', 'callback', {@ch3_getPattern_Callback, handles});
           
       case 4
           handles.ch4_exp_text = uicontrol('style', 'text', 'string', 'CH4: ', 'Position', [10 90 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [75 90 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_nspinperexp_text = uicontrol('style', 'text', 'string', 'n_spin: ', 'Position', [10 65 50 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_nspinperexp = uicontrol('style', 'edit', 'string', '5', 'Position', [75 65 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [10 10 120 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_ELT_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [10 40 50 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_ELT = uicontrol('style', 'edit', 'string', '0', 'Position', [75 40 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern', ...
               'Position', [10 20 60 20], 'Parent', CHsTab{4}, 'units', 'characters', 'callback',  {@ch4_getPattern_Callback, handles});
           
   end
end
% % end
spinTIRFData.CHsTab = CHsTab;
spinTIRFData.MAX_Chs_Num = MAX_Chs_Num;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
%% SETUP show circle axes
set(handles.showPatternAxes, 'XLim', [-1200 1200], 'YLim', [-1200 1200]);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spinTIRF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spinTIRF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadCSV.
function loadCSV_Callback(hObject, eventdata, handles)
% hObject    handle to loadCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.csv', 'Pick  a file');

if isequal(filename, 0)
    disp('User selected cancle');
    return;
else
    disp(['User selected: ', fullfile(pathname, filename)]);
end

[frame_ind, x_coord, y_coord] = gen_spot_tracker_coord(fullfile(pathname, filename));

x_volts = [];
y_volts = [];

for ind = frame_ind
%     [xv, yv] = index_to_volts(ind);
    [xv, yv] = index_to_volts(ind, [5 -5 -0.5 0.5]);
    x_volts = [x_volts xv];
    y_volts = [y_volts yv];
end

spinTIRFData = getappdata(gcf, 'spinTIRFData');

spinTIRFData.spinGridCSV.filename = filename;
spinTIRFData.spinGridCSV.pathname = pathname;
spinTIRFData.x_coord = x_coord;
spinTIRFData.y_coord = y_coord;
spinTIRFData.x_volts = x_volts;
spinTIRFData.y_volts = y_volts;
spinTIRFData.projectFolder = pathname;
set(handles.showCSVPath, 'string', fullfile(pathname, filename));
set(handles.status, 'string', 'Load CSV finished!');

setappdata(gcf, 'spinTIRFData', spinTIRFData);

guidata(hObject, handles);



function showCSVPath_Callback(hObject, eventdata, handles)
% hObject    handle to showCSVPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of showCSVPath as text
%        str2double(get(hObject,'String')) returns contents of showCSVPath as a double


% --- Executes during object creation, after setting all properties.
function showCSVPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showCSVPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pix_per_um_Callback(hObject, eventdata, handles)
% hObject    handle to pix_per_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pix_per_um as text
%        str2double(get(hObject,'String')) returns contents of pix_per_um as a double
set(handles.way2definepattern, 'value', 1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pix_per_um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pix_per_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_samples_Callback(hObject, eventdata, handles)
% hObject    handle to n_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_samples as text
%        str2double(get(hObject,'String')) returns contents of n_samples as a double
set(handles.way2definepattern, 'value', 1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function n_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cam_width_x_Callback(hObject, eventdata, handles)
% hObject    handle to cam_width_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_width_x as text
%        str2double(get(hObject,'String')) returns contents of cam_width_x as a double


% --- Executes during object creation, after setting all properties.
function cam_width_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_width_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cam_height_y_Callback(hObject, eventdata, handles)
% hObject    handle to cam_height_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_height_y as text
%        str2double(get(hObject,'String')) returns contents of cam_height_y as a double


% --- Executes during object creation, after setting all properties.
function cam_height_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_height_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_um_Callback(hObject, eventdata, handles)
% hObject    handle to radius_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_um as text
%        str2double(get(hObject,'String')) returns contents of radius_um as a double
set(handles.way2definepattern, 'value', 1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function radius_um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in definePatternDoit.
function definePatternDoit_Callback(hObject, eventdata, handles)
% hObject    handle to definePatternDoit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%center = [907.3125, 1329.8];

spinTIRFData = getappdata(gcf, 'spinTIRFData');

pix_per_um = str2double(get(handles.pix_per_um, 'String'));

centerx = str2double(get(handles.cam_width_x, 'String'))/2;
centery = str2double(get(handles.cam_height_y, 'String'))/2;
samples = str2double(get(handles.n_samples, 'String'));
if get(handles.patternSeq, 'value')
    min_radius = str2double(get(handles.radius_um, 'String')); 
    step_radius = str2double(get(handles.radius_um_1, 'String')); 
    max_radius = str2double(get(handles.radius_um_2, 'String'));    
    radius_um = min_radius:step_radius:max_radius;
else    
    radius_um = str2double(get(handles.radius_um, 'String'));   % 65um ~= 600 pixels
end
% radius_pix = radius_um * pix_per_um;
step = (pi*2)/samples;
if get(handles.chooseSavePatternFolder, 'value')
    pattern_folder = spinTIRFData.projectFolder;   
else
    pattern_folder = uigetdir(spinTIRFData.spinGridCSV.pathname);
end

switch get(handles.way2definepattern, 'value')
    case 1 % Circular, for spinTIRF
        spinTIRFData.patternfile = cell(length(radius_um), 1);       
        ii = 0;
        for i_radius_um = radius_um
            i_radius_pix = i_radius_um * pix_per_um;
            xp = [];
            yp = [];

            for n = 0 : samples-1
                xp = [xp cos(step*n)*i_radius_pix+centerx];
                yp = [yp -sin(step*n)*i_radius_pix+centery];
            end

            outfilename = ['r_', num2str(i_radius_um),'um_s_', num2str(samples)];
%             outfile = fullfile(pattern_folder, outfilename);
%             csvwrite(outfile, [xp.' yp.']);
            ii = ii+1;
            spinTIRFData.patternfile{ii} = outfilename;
            spinTIRFData.preDefinedPatternPos.(outfilename) = [xp.' yp.'];
        end
    case 2 % IJ ROI, for PA
        xp = handles.MMROI.pixList(:, 2);
        yp = handles.MMROI.pixList(:, 1);
        defaultoutfile = fullfile(pattern_folder, 'MMROI.csv');
        [filename, pathname] = uiputfile('*.csv', 'Save pattern file', defaultoutfile);       
         spinTIRFData.patternfile{1} = filename;
         csvwrite(fullfile(pathname, filename), [xp yp]);
         pattern_folder = pathname;
end

spinTIRFData.pattern_folder = pattern_folder;
spinTIRFData.radius_um = radius_um;
disp('Define pattern, finished!');
set(handles.status, 'string', 'Define pattern, finished!');

%% generate Volts for galvo
fittedmodel_xv = spinTIRFData.fitResult{1};
fittedmodel_yv = spinTIRFData.fitResult{2};
if get(handles.chooseSavePatternFolder, 'value')
    pattern_folder = spinTIRFData.pattern_folder;   
else
    pattern_folder = uigetdir(spinTIRFData.spinGridCSV.pathname);
end
for i = 1 : length(spinTIRFData.patternfile)
    
    prefix = spinTIRFData.patternfile{i};
    
%     prefix = './r_300um_s_250';
    
%     pixels = csvread( fullfile(pattern_folder, i_pattern_file));
    pixels = spinTIRFData.preDefinedPatternPos.(prefix);
    output = [];
    for n = 1 : length(pixels)
        volt = [fittedmodel_xv(pixels(n, 1), pixels(n, 2)), ...
                fittedmodel_yv(pixels(n, 1), pixels(n, 2))];
        output = [output;volt];
    end

%     outfile = fullfile(pattern_folder, [prefix '_v.csv']);
%     csvwrite(outfile, output);
    % add to current pattern list
    patternName = [prefix  '_v'];
    spinTIRFData.preDefinedPattern.(patternName)=  output;
end
set(handles.predefinedPatternList, 'string', sort(fieldnames(spinTIRFData.preDefinedPattern)));
set(handles.predefinedPatternList, 'value', length(get(handles.predefinedPatternList, 'String'))); 
% save all various
spinTIRF_result = spinTIRFData;
savefile = fullfile(spinTIRFData.pattern_folder, 'spinTIRF_result.mat');
warning off;
save(savefile, 'spinTIRF_result');
disp('Generate volts, finished!');
set(handles.status, 'string', 'Generate volts, finished!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);

guidata(hObject, handles);


function radius_um_1_Callback(hObject, eventdata, handles)
% hObject    handle to radius_um_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_um_1 as text
%        str2double(get(hObject,'String')) returns contents of radius_um_1 as a double


% --- Executes during object creation, after setting all properties.
function radius_um_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_um_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_um_2_Callback(hObject, eventdata, handles)
% hObject    handle to radius_um_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_um_2 as text
%        str2double(get(hObject,'String')) returns contents of radius_um_2 as a double


% --- Executes during object creation, after setting all properties.
function radius_um_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_um_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in patternSeq.
function patternSeq_Callback(hObject, eventdata, handles)
% hObject    handle to patternSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of patternSeq
if get(hObject, 'value')
    set(handles.radius_um_1, 'enable', 'on');
    set(handles.radius_um_2, 'enable', 'on');
else
    set(handles.radius_um_1, 'enable', 'on');
    set(handles.radius_um_2, 'enable', 'on');
end
set(handles.way2definepattern, 'value', 1);
guidata(hObject, handles);


% --- Executes on button press in fitSurfaceDoit.
function fitSurfaceDoit_Callback(hObject, eventdata, handles)
% hObject    handle to fitSurfaceDoit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spinTIRFData = getappdata(gcf, 'spinTIRFData');

x_coord = spinTIRFData.x_coord;
y_coord = spinTIRFData.y_coord;
x_volts = spinTIRFData.x_volts;
y_volts = spinTIRFData.y_volts;

[fitresult, gof] = createSurfaceFits(x_coord, y_coord, x_volts, y_volts);

spinTIRFData.fitResult = fitresult;
spinTIRFData.gof       = gof;

disp('Fit surface, finished!');
set(handles.status, 'string', 'Fit surface, finished!');
setappdata(findobj('tag', 'figure1'), 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

% --- Executes on button press in generateVoltsDoit.
function generateVoltsDoit_Callback(hObject, eventdata, handles)
% hObject    handle to generateVoltsDoit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');



% --- Executes on button press in chooseSavePatternFolder.
function chooseSavePatternFolder_Callback(hObject, eventdata, handles)
% hObject    handle to chooseSavePatternFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chooseSavePatternFolder


% --- Executes on selection change in way2definepattern.
function way2definepattern_Callback(hObject, eventdata, handles)
% hObject    handle to way2definepattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns way2definepattern contents as cell array
%        contents{get(hObject,'Value')} returns selected item from way2definepattern


% --- Executes during object creation, after setting all properties.
function way2definepattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to way2definepattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadMMROI.
function loadMMROI_Callback(hObject, eventdata, handles)
% hObject    handle to loadMMROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load imagej ROI
try
    [FileName,PathName] = uigetfile({'*.roi'},'ROI (*.roi)', spinTIRFData.spinGridCSV.pathname);
catch
    [FileName,PathName] = uigetfile({'*.roi'},'ROI (*.roi)');
end
spinTIRFData.MMROI.pathname = PathName;
spinTIRFData.MMROI.filename = FileName;
sROI = ReadImageJROI(fullfile(PathName, FileName));

cameraWidth = 2*str2double(get(handles.cam_width_x, 'string'));
cameraHeight = 2*str2double(get(handles.cam_height_y, 'string'));
xp = [];
yp = [];
strType = sROI.strType;
switch strType
    case 'Rectangle'
        vnRec = sROI.vnRectBounds;
        yp = [vnRec(2), vnRec(2), vnRec(4), vnRec(4)];
        xp = [vnRec(1), vnRec(3), vnRec(3), vnRec(1)];
        xp = xp';
        yp = yp';
        roiMask = poly2mask(yp, xp, cameraHeight, cameraWidth);    
    case {'Polygon' , 'Freehand' , 'Traced' , 'PolyLine' , 'Point'}
        xp = sROI.mnCoordinates(:,2);
        yp = sROI.mnCoordinates(:,1);
        roiMask = poly2mask(yp, xp, cameraHeight, cameraWidth);
   
    case 'Oval'
        center_y = (sROI.vnRectBounds(2) + sROI.vnRectBounds(4))/2;
        center_x = (sROI.vnRectBounds(1) + sROI.vnRectBounds(3))/2;
        radius_y = (sROI.vnRectBounds(4) - sROI.vnRectBounds(2))/2;
        radius_x = (sROI.vnRectBounds(3) - sROI.vnRectBounds(1))/2;
        % get perimeter
%         pCir = 3.14*(3*(radius_x+radius_y)-sqrt((3*radius_x+radius_y)*(radius_x+3*radius_y)));
        n_samples = round(4*(radius_x+radius_y));
        xp = []; yp = [];
        step = (2*pi)/n_samples;
        for n = 0 : n_samples-1
            xp = [xp cos(step*n)*radius_x+center_x];
            yp = [yp -sin(step*n)*radius_y+center_y];
        end
        xp = xp'; 
        yp = yp';
        roiMask = poly2mask(yp , xp, cameraHeight, cameraWidth);   
%         roiMask = poly2mask(xp, yp, cameraHeight, cameraWidth);
    case 'Line'
        return;
end

status = regionprops(roiMask, 'PixelList');
if get(handles.scanArea, 'value')
    handles.MMROI.pixList = status.PixelList;
    figure; imshow(roiMask);
else
    handles.MMROI.pixList = cat(2, yp', xp');
    figure; imshow(zeros(cameraHeight, cameraWidth)); 
    hold on;plot([yp' yp(1)], [xp' xp(1)], 'r');hold off;
end
set(handles.showMMROIPath, 'string', fullfile(PathName, FileName));
set(handles.way2definepattern, 'value', 2);

set(handles.status, 'string', 'Load MM ROI finished!');
guidata(hObject, handles);


function showMMROIPath_Callback(hObject, eventdata, handles)
% hObject    handle to showMMROIPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of showMMROIPath as text
%        str2double(get(hObject,'String')) returns contents of showMMROIPath as a double


% --- Executes during object creation, after setting all properties.
function showMMROIPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showMMROIPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scanArea.
function scanArea_Callback(hObject, eventdata, handles)
% hObject    handle to scanArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scanArea


% --- Executes on selection change in predefinedPatternList.
function predefinedPatternList_Callback(hObject, eventdata, handles)
% hObject    handle to predefinedPatternList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
contents = cellstr(get(hObject,'String')) ;
fieldName    =    contents{get(hObject,'Value')} ;
data = spinTIRFData.preDefinedPattern.(fieldName);
set(handles.currentPatternValue, 'data', data);
% set to draw circle
radius = str2double(regexp(fieldName, 'r_(\d+)um', 'tokens', 'once'));
if ~isempty(radius)
    cla(handles.showPatternAxes);
    handles.circlePattern = viscircles(handles.showPatternAxes,[0 0 ], radius,'Color','b');
    axis([-1200 1200 -1200 1200]);    
    grid on
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function predefinedPatternList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to predefinedPatternList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in n_Chs.
function n_Chs_Callback(hObject, eventdata, handles)
% hObject    handle to n_Chs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns n_Chs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from n_Chs
spinTIRFData = getappdata(gcf, 'spinTIRFData');
n_chs = get(handles.n_Chs, 'value') - 1;
CHs = cell(n_chs, 1);
CHsTab = cell(n_chs, 1);
for i = 1 : n_chs
    CHs{i} =  struct('n_samples', [], 'exposure', [],...
                'nspinperexp', [], 'rate', [], 'volts', []);
end
%% this is for uipanel use
% % switch n_chs
% %     case 1
% %         set(handles.ch1_panel, 'visible', 'on');
% %         set(handles.ch2_panel, 'visible', 'off');
% %     case 2
% %         set(handles.ch1_panel, 'visible', 'on');
% %         set(handles.ch2_panel, 'visible', 'on');

%% this is for uitab use
% if n_chs<spinTIRFData.MAX_Chs_Num
%     for i = 1:n_chs
%          set(spinTIRFData.CHsTab{i}, 'visible', 'on');
%     end
%     for i = n_chs+1 :  spinTIRFData.MAX_Chs_Num
%         set(spinTIRFData.CHsTab{i}, 'visible', 'off');
%     end
% end
% % end
spinTIRFData.ChannelSetting = CHs;
spinTIRFData.CHsTab = CHsTab;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function n_Chs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_Chs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function ch1_exp_Callback(hObject, eventdata, handles)
% hObject    handle to ch1_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch1_exp as text
%        str2double(get(hObject,'String')) returns contents of ch1_exp as a double


% --- Executes during object creation, after setting all properties.
function ch1_exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch1_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addPatternOnetime.
function addPatternOnetime_Callback(hObject, eventdata, handles)
% hObject    handle to addPatternOnetime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
[filename, filepath, fillteridx] = uigetfile({'*.mat';'*.xlsx;.xls;*.csv'},'Load pattern');

switch fillteridx
    case 0
        msgbox('User selection cancled!');
        return;
    case 1
        loadMat = load(fullfile(filepath, filename));
        patternData = loadMat.pattern;
    case 2
        loadExcel = xlsread(fullfile(filepath, filename));
        patternData = loadExcel;
end
x = inputdlg('Put a name for your pattern:',...
             'Set pattern name', [1 50]);
patternName = x{:};

spinTIRFData.preDefinedPattern...
    = setfield (spinTIRFData.preDefinedPattern, patternName, patternData );
set(handles.predefinedPatternList, 'string', fieldnames(spinTIRFData.preDefinedPattern));
set(handles.predefinedPatternList, 'value', 1); 
set(handles.status, 'string', 'Pattern added!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

% --- Executes on button press in saveCurrentPatternList.
function saveCurrentPatternList_Callback(hObject, eventdata, handles)
% hObject    handle to saveCurrentPatternList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
% spinTIRFData.preDefinedPattern = spinTIRFData.preDefinedPattern;
save('spinTIRF_Config', 'spinTIRFData');
set(handles.status, 'string', 'Pattern saved!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

function ch2_exp_Callback(hObject, eventdata, handles)
% hObject    handle to ch2_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch2_exp as text
%        str2double(get(hObject,'String')) returns contents of ch2_exp as a double


% --- Executes during object creation, after setting all properties.
function ch2_exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch2_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ch1_nspinperexp_Callback(hObject, eventdata, handles)
% hObject    handle to ch1_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch1_nspinperexp as text
%        str2double(get(hObject,'String')) returns contents of ch1_nspinperexp as a double


% --- Executes during object creation, after setting all properties.
function ch1_nspinperexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch1_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ch2_nspinperexp_Callback(hObject, eventdata, handles)
% hObject    handle to ch2_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch2_nspinperexp as text
%        str2double(get(hObject,'String')) returns contents of ch2_nspinperexp as a double


% --- Executes during object creation, after setting all properties.
function ch2_nspinperexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch2_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ch1_getPattern.
function ch1_getPattern_Callback(src, evnt, handles)
% hObject    handle to ch1_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');


content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
spinTIRFData.ChannelSetting{1}.volts = pattern;
spinTIRFData.ChannelSetting{1}.getPatternDone = 1;
set(handles.ch1_patternName, 'String', patternName);
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(src, handles);

% --- Executes on button press in ch2_getPattern.
function ch2_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch2_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
spinTIRFData.ChannelSetting{2}.volts = pattern;
spinTIRFData.ChannelSetting{2}.getPatternDone = 1;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
set(handles.ch2_patternName, 'String', patternName);

guidata(hObject, handles);

% --- Executes on button press in ch3_getPattern.
function ch3_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch3_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
spinTIRFData.ChannelSetting{3}.volts = pattern;
spinTIRFData.ChannelSetting{3}.getPatternDone = 1;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
set(handles.ch3_patternName, 'String', patternName);

guidata(hObject, handles);

% % % --- Executes on button press in ch3_getPattern.
function ch4_getPattern_Callback(src, evnt, handles)
% hObject    handle to ch1_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
spinTIRFData.ChannelSetting{4}.volts = pattern;
spinTIRFData.ChannelSetting{4}.getPatternDone = 1;
set(handles.ch4_patternName, 'String', patternName);

setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(src, handles);

% --- Executes on button press in configureNI.
function configureNI_Callback(hObject, eventdata, handles)
% hObject    handle to configureNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get daq connection
% S = spinTIRFData.S;
spinTIRFData = getappdata(gcf, 'spinTIRFData');
S = daq.createSession('ni');
S.NotifyWhenScansQueuedBelow = 250;
if S.IsLogging
    msgbox('Pls wait until last operation finished!', 'Error', 'error');
    return;
end
try
    switch (get(handles.pickGalvo, 'value'))    
        case 2 % TIRF
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
                % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'Dev1', 'ao0', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'Dev1', 'ao1', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
        case 3 % PA
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
            % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao2', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'Dev1', 'ao3', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];
        case 1 % release channle, pls pick a galvo first
            msgbox('Pick a galvo first!', 'Error', 'error');
            return;
    end
catch
    msgbox('Setup voltage channle error!', 'Error', 'error');
    return;
end
% make sure pattern has been get
n_chs = get(handles.n_Chs, 'value') - 1;
check = 1;
for iCh = 1 : n_chs
    if ~isfield(spinTIRFData.ChannelSetting{iCh}, 'getPatternDone')
        check = 0;
    end
end
if ~check
    msgbox('Get pattern for each channle first!!');
    return;
end


% setup trigger source
if get(handles.runGalvoMode, 'Value') == 2
    addTriggerConnection(S, 'External', 'Dev1/PFI8', 'StartTrigger');
    S.Connections(1).TriggerCondition = 'RisingEdge';
end


for iCh = 1 : n_chs
    switch iCh
        case 1
            n_samples = size(spinTIRFData.ChannelSetting{1}.volts, 1);
            exposure  = str2double(get(handles.ch1_exp, 'string'));
            nspinperexp = str2double(get(handles.ch1_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));  
            
            spinTIRFData.ChannelSetting{1}.n_samples = n_samples;
            spinTIRFData.ChannelSetting{1}.exposure = exposure;
            spinTIRFData.ChannelSetting{1}.nspinperexp = nspinperexp;
            spinTIRFData.ChannelSetting{1}.rate = rate;

        case 2
            n_samples = size(spinTIRFData.ChannelSetting{2}.volts, 1);
            exposure  = str2double(get(handles.ch2_exp, 'string'));
            nspinperexp = str2double(get(handles.ch2_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));    
            
            spinTIRFData.ChannelSetting{2}.n_samples = n_samples;
            spinTIRFData.ChannelSetting{2}.exposure = exposure;
            spinTIRFData.ChannelSetting{2}.nspinperexp = nspinperexp;
            spinTIRFData.ChannelSetting{2}.rate = rate;
        case 3
            n_samples = size(spinTIRFData.ChannelSetting{3}.volts, 1);
            exposure  = str2double(get(handles.ch3_exp, 'string'));
            nspinperexp = str2double(get(handles.ch3_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));    
            
            spinTIRFData.ChannelSetting{3}.n_samples = n_samples;
            spinTIRFData.ChannelSetting{3}.exposure = exposure;
            spinTIRFData.ChannelSetting{3}.nspinperexp = nspinperexp;
            spinTIRFData.ChannelSetting{3}.rate = rate;
        case 4
            n_samples = size(spinTIRFData.ChannelSetting{4}.volts, 1);
            exposure  = str2double(get(handles.ch4_exp, 'string'));
            nspinperexp = str2double(get(handles.ch4_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));    
            
            spinTIRFData.ChannelSetting{4}.n_samples = n_samples;
            spinTIRFData.ChannelSetting{4}.exposure = exposure;
            spinTIRFData.ChannelSetting{4}.nspinperexp = nspinperexp;
            spinTIRFData.ChannelSetting{4}.rate = rate;
    end
end
set(handles.status, 'String', 'Set NI successfully!!!');

spinTIRFData.S = S;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject,handles);

%% RUN ni
set(handles.status, 'String', 'Start NI!!!');
spinTIRFData.N_frames = str2double(get(handles.n_turns, 'string'));

volts = cell(n_chs, 1);
rates = cell(n_chs, 1);
nspinperexp = cell(n_chs, 1);
for iCh = 1 : n_chs
    volts{iCh} = spinTIRFData.ChannelSetting{iCh}.volts;
    rates{iCh} = spinTIRFData.ChannelSetting{iCh}.rate;
    nspinperexp{iCh} = spinTIRFData.ChannelSetting{iCh}.nspinperexp;
end

setappdata(gcf, 'manuallyStop', 0);
set(handles.configureNI, 'enable', 'off');

if n_chs == 1 && ~(get(handles.runGalvoMode, 'Value') == 2) && get(handles.pickGalvo, 'Value') == 2% can be faster
    spinTIRFData.S.IsContinuous = true;
    spinTIRFData.S.Rate = rates{1};
    data = repmat(volts{1}, nspinperexp{1}, 1);
    queueOutputData(spinTIRFData.S, data);
    lh = addlistener(spinTIRFData.S,'DataRequired', ...
        @(src,event) src.queueOutputData(data));
    spinTIRFData.lh = lh;
    guidata(hObject,handles);
    spinTIRFData.S.startBackground();
    wait(spinTIRFData.S, 120);
elseif get(handles.pickGalvo, 'Value') ==3 % PA Mode
    spinTIRFData.S.IsContinuous = false;
    spinTIRFData.S.Rate = 100;
    data = repmat(volts{1}, nspinperexp{1}, 1);
    queueOutputData(spinTIRFData.S, data);
    lh = addlistener(spinTIRFData.S,'DataRequired', ...
        @(src,event) src.queueOutputData(data));
    spinTIRFData.lh = lh;
    guidata(hObject,handles);
    spinTIRFData.S.startBackground();
    wait(spinTIRFData.S, 120);
else
%     if rates{1} == rates{2} % this is a faster implementation
%         data{1} = repmat(volts{1}, nspinperexp{1}, 1);
%         data{2} = repmat(volts{2}, nspinperexp{2}, 1);
%         nidata.counter = 0;
%         nidata.data = data;
%         S.IsContinuous = true;
%         S.Rate = rates{1};
%         lh = addlistener(S,'DataRequired', ...
%             @(src,event) datacallback(src, event));
%         spinTIRFData.lh = lh;
%         guidata(hObject,handles);
%         queueOutputData(S, data{1});
%         S.startBackground();
%         wait(S, 60);
%     else
        if get(handles.runGalvoMode, 'value') == 3
            for iFrame = 1 : spinTIRFData.N_frames
                if ~getappdata(gcf, 'manuallyStop')
                    for iCh = 1 : n_chs 
                        queueOutputData(spinTIRFData.S, repmat(volts{iCh}, nspinperexp{iCh}, 1));
                        spinTIRFData.S.Rate = rates{iCh};
                        spinTIRFData.S.startBackground();
                        wait(spinTIRFData.S, 120) ; 
                    end
                else
                    break;
                end
            end
        else
            while 1
                if ~getappdata(gcf, 'manuallyStop')
                    for iCh = 1 : n_chs 
                        queueOutputData(spinTIRFData.S, repmat(volts{iCh}, nspinperexp{iCh}, 1));
                        spinTIRFData.S.Rate = rates{iCh};
                        spinTIRFData.S.startBackground();
                        wait(spinTIRFData.S, 120) ; 
                    end
                else
                    break;
                end
            end
        end

%     end
end
set(handles.status, 'string', 'NI Ended!');
set(handles.configureNI, 'enable', 'on');
release(spinTIRFData.S);
setappdata(gcf, 'spinTIRFData', spinTIRFData);

%%
guidata(hObject,handles);

% % function datacallback(src, event)
% % global nidata;
% % % disp(mod(nidata.counter,2)+1)
% % src.queueOutputData(nidata.data{mod(nidata.counter,2)+1});
% % nidata.counter = nidata.counter +1;

% --- Executes on button press in runNI.
function runNI_Callback(hObject, eventdata, handles)
% hObject    handle to runNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of runNI
x_volt = str2double(get(handles.x_volt, 'string'));
y_volt = str2double(get(handles.x_volt, 'string'));

S = daq.createSession('ni');
S.NotifyWhenScansQueuedBelow = 200;
if S.IsLogging
    msgbox('Pls wait until last operation finished!', 'Error', 'error');
    return;
end
try
    switch (get(handles.pickGalvo, 'value'))    
        case 2 % TIRF
            data = [x_volt y_volt];
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
                % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'Dev1', 'ao0', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'Dev1', 'ao1', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
        case 3 % PA
            data = [x_volt y_volt];
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
            % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao2', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'Dev1', 'ao3', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];
        case 1 % release channle, pls pick a galvo first
            msgbox('Pick a galvo first!', 'Error', 'error');
            return;
    end
catch
    msgbox('Setup voltage channle error!', 'Error', 'error');
    return;
end
outputSingleScan(S, data);
release(S);
guidata(hObject, handles);


% --- Executes on selection change in pickGalvo.
function pickGalvo_Callback(hObject, eventdata, handles)
% hObject    handle to pickGalvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pickGalvo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pickGalvo

switch get(hObject, 'value')
    case 1
        try
            S = spinTIRFData.S;
            removeChannel(S,[1 2]);
        catch
            disp('There is no channle to remove!');
        end
%         removeChannel(S,1);
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function pickGalvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pickGalvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_turns_Callback(hObject, eventdata, handles)
% hObject    handle to n_turns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_turns as text
%        str2double(get(hObject,'String')) returns contents of n_turns as a double


% --- Executes during object creation, after setting all properties.
function n_turns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_turns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadImage.
function loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
[FileName,PathName] = uigetfile('*.tif','Load Image Sequence','MultiSelect','on');
spinTIRFData.laserImage.pathName = PathName;
spinTIRFData.laserImage.fileName = FileName;
if isequal(FileName,0)
   errordlg('User selected Cancel !!','Operation Error');
   return;
end
if ~iscell(FileName) % then check if it's multi-frame image
    minfo = imfinfo(fullfile(PathName, FileName));
    if length(minfo) == 1 % if single frame, then quite
        errordlg('You Should Choose at lease Two Files !!','Operation Error');
        return;
    else
        imgWidth = minfo(1).Width; 
        imgHeight = minfo(1).Height; 
        totalFrames = length(minfo);
        spinTIRFData.laserImg = single(zeros(imgHeight, imgWidth, totalFrames));
        h = waitbar(0,['Loading Image Fragment 0 , please wait...']);
        for i=1:totalFrames
            waitbar(i/totalFrames,h,['Loading Image Fragment '  num2str(i) ' , please wait...']);
            iImg =  tiffread([PathName FileName], i); 
            spinTIRFData.laserImg(:,:,i)= single(iImg.data);
        end
        close(h);
    end
else
    FileName = sort(FileName);
    totalFrames = length(FileName);
    FileInfo = imfinfo([PathName FileName{1}]);
    imgWidth = FileInfo(1).Width; 
    imgHeight = FileInfo(1).Height; 
    spinTIRFData.laserImg = zeros(imgHeight, imgWidth, totalFrames);
    h = waitbar(0,['Loading Image Fragment 0 , please wait...']);
    for i=1:length(FileName)
        waitbar(i/length(FileName),h,['Loading Image Fragment '  num2str(i) ' , please wait...']);
        spinTIRFData.laserImg(:,:,i)=imread([PathName FileName{i}]);         
    end
    close(h);
end

spinTIRFData.laserImgAvg = max(spinTIRFData.laserImg, [], 3);
spinTIRFData.projectFolder = PathName;
setappdata(gcf, 'spinTIRFData', spinTIRFData);

guidata(hObject, handles);


% --- Executes on button press in findCentroid.
function findCentroid_Callback(hObject, eventdata, handles)
% hObject    handle to findCentroid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% BW  = atrous(spinTIRFData.laserImg,0,1,5,4);
spinTIRFData = getappdata(gcf, 'spinTIRFData');
BWFile = tiffread();
for i = 1 : length(BWFile)
   BW(:, :, i) = BWFile(i).data;
end
disp('Read Binary Image Finished!');
calibration = [];
constrains = struct('eliminateEdgeFlag',1,'areaMin',5,'areaMax',1000);
spinTIRFData.laserImgPosition = getMovieInfo(single(spinTIRFData.laserImg),single(BW),constrains,calibration);

keepIdx = [];
positionList = [];
for i= 1: length(spinTIRFData.laserImgPosition)
    if ~isempty(spinTIRFData.laserImgPosition(i).xCoord) && size(spinTIRFData.laserImgPosition(i).xCoord, 1) == 1
        keepIdx = cat(1, keepIdx, i);
        xp = spinTIRFData.laserImgPosition(i).xCoord(1, 1);
        yp = spinTIRFData.laserImgPosition(i).yCoord(1, 1);
        positionList = cat(1, positionList, [xp yp]);
    end
end
% [xv, yv] = index_to_volts(keepIdx);
[xv, yv] = index_to_volts(keepIdx, [5 -5 -0.5 0.5]);
spinTIRFData.laserPos = cat(2, xv, yv, positionList);
spinTIRFData.x_coord = positionList(:, 1);
spinTIRFData.y_coord = positionList(:, 2);
spinTIRFData.x_volts = xv;
spinTIRFData.y_volts = yv;

pathName = spinTIRFData.laserImage.pathName;
cvsTitle = {'FrameNumber', 'Spot ID', 'X', 'Y'};
cvsData = cat(2, keepIdx, keepIdx, positionList);
cvsData = num2cell(cvsData);
xlswrite(fullfile(pathName, 'spot_tracking_data.csv'), cat(1, cvsTitle, cvsData));
setappdata(gcf, 'spinTIRFData', spinTIRFData);

figure; imagesc(spinTIRFData.laserImgAvg); colormap(gray); hold on; scatter(positionList(:, 1), positionList(:, 2), 'MarkerEdgeColor',[1 0 0]); hold off;
guidata(hObject, handles);


% --- Executes on button press in removePattern.
function removePattern_Callback(hObject, eventdata, handles)
% hObject    handle to removePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
content = get(handles.predefinedPatternList, 'string');
if iscell(content)
    fieldName = content{get(handles.predefinedPatternList, 'value')};
else
    fieldName = content;
end
spinTIRFData.preDefinedPattern = rmfield(spinTIRFData.preDefinedPattern, fieldName);
content = fieldnames(spinTIRFData.preDefinedPattern);
set(handles.predefinedPatternList, 'string', content);
set(handles.predefinedPatternList, 'value', 1);
set(handles.status, 'string', 'Pattern removed!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);
% --- Executes when selected cell(s) is changed in currentPatternValue.
function currentPatternValue_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to currentPatternValue (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
selIdx = eventdata.Indices;
if isempty(selIdx)
    return;
end
data = get(handles.currentPatternValue, 'data');

if ~isempty(data(selIdx(1),:))
    set(handles.x_volt, 'string', num2str(data(selIdx(1), 1)));
    set(handles.y_volt, 'string', num2str(data(selIdx(1), 2)));
end

guidata(hObject, handles);


function x_volt_Callback(hObject, eventdata, handles)
% hObject    handle to x_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_volt as text
%        str2double(get(hObject,'String')) returns contents of x_volt as a double


% --- Executes during object creation, after setting all properties.
function x_volt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_volt_Callback(hObject, eventdata, handles)
% hObject    handle to y_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_volt as text
%        str2double(get(hObject,'String')) returns contents of y_volt as a double


% --- Executes during object creation, after setting all properties.
function y_volt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pattern = getCurrentPattern(handles, varargin)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
if nargin == 1
    order = get(handles.predefinedPatternList, 'Value');
elseif nargin == 2
    order = varargin{1};
end

content = get(handles.predefinedPatternList, 'String');
if ~isempty(content)
    patternName = content{order};
    pattern = spinTIRFData.preDefinedPattern.(patternName);
else 
    pattern = [];
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% --- Executes on button press in resetNI.
function resetNI_Callback(hObject, eventdata, handles)
% hObject    handle to resetNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
S = daq.createSession('ni');
S.NotifyWhenScansQueuedBelow = 200;
if S.IsLogging
    msgbox('Pls wait until last operation finished!', 'Error', 'error');
    return;
end
try
    switch (get(handles.pickGalvo, 'value'))    
        case 2 % TIRF
            data = [0 0];
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
                % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'Dev1', 'ao0', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'Dev1', 'ao1', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
        case 3 % PA
            data = [0 0];
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
            % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao2', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'Dev1', 'ao3', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];
        case 1 % release channle, pls pick a galvo first
            msgbox('Pick a galvo first!', 'Error', 'error');
            return;
    end
catch
    msgbox('Setup voltage channle error!', 'Error', 'error');
    return;
end
outputSingleScan(S, data);
release(S);
guidata(hObject, handles);

% --------------------------------------------------------------------
function ConnectNI_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% setup NI daq board
% create a data acquisition session
spinTIRFData = getappdata(gcf, 'spinTIRFData');
try
    S = daq.createSession('ni');
    spinTIRFData.S = S;
    set(handles.warningText, 'visible', 'off');
catch
    msgbox('No NI-DAQ board found! Run under simulation mode.');
    set(handles.ni_panel, 'visible', 'off');
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);


% --- Executes on button press in waitTrigger.
function waitTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to waitTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of waitTrigger


% --- Executes on button press in stopNI.
function stopNI_Callback(hObject, eventdata, handles)
% hObject    handle to stopNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
set(handles.configureNI, 'enable', 'on');
setappdata(gcf, 'manuallyStop', 1);
% try
%     delete(spinTIRFData.lh)    
% catch
%     disp('Failed to delete lh');
% end
try
    stop(spinTIRFData.S);
    % spinTIRFData.S.IsContinuous = false;
    release(spinTIRFData.S);
catch
    msgbox('Failure to stop or NI not running')
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);



% --- Executes on button press in getIJROI.
function getIJROI_Callback(hObject, eventdata, handles)
% hObject    handle to getIJROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
import ij.*;
img = IJ.getImage();
roi_ = img.getRoi();
roiType = roi_.getTypeAsString();
if get(handles.scanArea, 'value')% scan whole area
    switch char(roiType)
        case 'Oval'
            rect = roi_.getBounds();
            xp = [];
            yp = [];
            for iRow = rect.y : rect.y+rect.height
                for iCol = rect.x: rect.x+rect.width
                    if roi_.contains(iCol, iRow)
                        xp = cat(2, xp, iRow);
                        yp = cat(2, yp, iCol);
                    end
                end
            end
        case 'Rectangle'
            rect = roi_.getBounds();
           [xx, yy] = meshgrid(rect.y:rect.y+rect.height,...
               rect.x:rect.x+rect.width);
           xp = reshape(xx, 1, []);
           yp = reshape(yy, 1, []);
    end
    
else% scan boundary
    boundary = roi_.getPolygon();
    xp = boundary.xpoints;
    yp = boundary.ypoints;
end
handles.MMROI.pixList = cat(2, yp', xp');
cameraWidth = str2double(get(handles.cam_width_x, 'string'));
cameraHeight = str2double(get(handles.cam_height_y, 'string'));

figure; imshow(zeros(cameraHeight, cameraWidth)); 
hold on;plot([yp' ;yp(1)], [xp' ;xp(1)], 'r');hold off;
set(handles.status, 'string', 'Get MM ROI finished!');
set(handles.way2definepattern, 'value', 2);
guidata(hObject, handles);



function ch3_nspinperexp_Callback(hObject, eventdata, handles)
% hObject    handle to ch3_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch3_nspinperexp as text
%        str2double(get(hObject,'String')) returns contents of ch3_nspinperexp as a double


% --- Executes during object creation, after setting all properties.
function ch3_nspinperexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch3_nspinperexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ch3_exp_Callback(hObject, eventdata, handles)
% hObject    handle to ch3_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch3_exp as text
%        str2double(get(hObject,'String')) returns contents of ch3_exp as a double


% --- Executes during object creation, after setting all properties.
function ch3_exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch3_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in runGalvoMode.
function runGalvoMode_Callback(hObject, eventdata, handles)
% hObject    handle to runGalvoMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runGalvoMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runGalvoMode
switch get(hObject, 'Value')
    case 1 % free run
        set(handles.n_turns, 'enable', 'off');
    case 2 % trigger
        set(handles.n_turns, 'enable', 'off');
    case 3 % n+turns
        set(handles.n_turns, 'enable', 'on');
end
% --- Executes during object creation, after setting all properties.
function runGalvoMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runGalvoMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in setETLMode.
function setETLMode_Callback(hObject, eventdata, handles)
% hObject    handle to setETLMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setETLMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setETLMode


% --- Executes during object creation, after setting all properties.
function setETLMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setETLMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectETL.
function connectETL_Callback(hObject, eventdata, handles)
% hObject    handle to connectETL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% CONNECT ETL
try
    ETL = load('ETL.mat');
    handles.ETL = ETL.ETL;
    if isempty(handle.ETL)
        set(handles.warningText, 'ETL Configuration File Is Empty!!');
    end
catch
    set(handles.warningText, 'string', 'ETL Configuration File Not Found!!');
end
try
    handles.lens = Optotune(handles.ETL.COM);
    handles.lens = handles.lens.Open();
    handles.lens.currentMode('Current');
    minStep = 1/handles.ETL.maxValue;
    set(handles.setETLSlider, 'Min',handles.ETL.minValue,...
                             'Max', handles.ETL.maxValue,...
                             'SliderStep', [minStep minStep*5], ...
                             'Value', 0);
    set(handles.setETLEdit, 'string', num2str(0));
catch
    set(handles.warningText, 'string', 'Connect ETL Error!!');
end
set(handles.ETLStatus, 'string', 'Connection established!!');
guidata(hObject, handles);


% --- Executes on slider movement.
function setETLSlider_Callback(hObject, eventdata, handles)
% hObject    handle to setETLSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
currentValue = get(hObject,'Value')*handles.ETL.maxValue;
if currentValue>=handles.ETL.minValue && currentValue<=handles.ETL.maxValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(round(currentValue));
    end
end
handles = refreshETLInfo(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setETLSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setETLSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function setETLEdit_Callback(hObject, eventdata, handles)
% hObject    handle to setETLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setETLEdit as text
%        str2double(get(hObject,'String')) returns contents of setETLEdit as a double


% --- Executes during object creation, after setting all properties.
function setETLEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setETLEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = refreshETLInfo(handles)
    currentT = handles.lens.temperature;
    currentV = handles.lens.current;
    set(handles.ETLStatus, 'string', ['Current: ', num2str(currentV) '; Temp: ' num2str(currentT)]);
	


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function ETLStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETLStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
