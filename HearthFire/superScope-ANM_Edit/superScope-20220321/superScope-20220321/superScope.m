function varargout = superScope(varargin)
% SUPERSCOPE MATLAB code for spinTIRFData.fig
%      SUPERSCOPE, by itself, creates a new SUPERSCOPE or raises the existing
%      singleton*.
%
%      H = SUPERSCOPE returns the handle to a new SUPERSCOPE or the handle to
%      the existing singleton*.
%
%      SUPERSCOPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in spinTIRFData.M with the given input arguments.
%
%      SUPERSCOPE('Property','Value',...) creates a new SUPERSCOPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before superScope_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to superScope_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help superScope

% Last Modified by GUIDE v2.5 02-Nov-2017 15:26:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @superScope_OpeningFcn, ...
                   'gui_OutputFcn',  @superScope_OutputFcn, ...
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


% --- Executes just before superScope is made visible.
function superScope_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to superScope (see VARARGIN)

% Choose default command line output for superScope
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
% guidata(hObject, handles);
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
%     set(handles.ni_panel, 'visible', 'off');
end

if spinTIRFData.loadImageJ
    spinTIRFData.ij = ij.ImageJ([], 1);
    if isempty(spinTIRFData.ij)
        msgbox('Open micromanager failed!');
    end
end
if spinTIRFData.loadMicromanager
%     addpath('C:\Program Files\Micro-Manager-2.0beta');
%     spinTIRFData.MMStudio = StartMMStudio('C:\Program Files\Micro-Manager-2.0beta');  
    addpath('C:\Program Files\Micro-Manager-2.0beta');
    spinTIRFData.MMStudio = StartMMStudio('C:\Program Files\Micro-Manager-2.0beta');
    if isempty(spinTIRFData.MMStudio)
        msgbox('Open micromanager failed!');
    end
end
spinTIRFData.projectFolder = pwd;

TEXT_Pos = 10;
EDIT_Pos = 80;
CH_Name = {'CFP'; 'GFP'; 'YFP'; 'Cherry'; 'Cy5'; 'DIC'; 'Custom'; 'PA'};
% default setting, if not load ETL.mat
spinTIRFData.CH_ETL = struct('CFP', 90, 'GFP', 91, 'YFP', 93, 'Cherry', 98, 'Cy5', 100, 'DIC', 0, 'Costum', [], 'PA', 13);
try
    spinTIRFData.fitResult_spinTIRF = spinTIRF_Config.spinTIRFData.fitResult_spinTIRF;
    spinTIRFData.load_fitResult_spinTIRF = 1;
    set(handles.spinTIRF_Flag, 'ForegroundColor', [1 0 0 ]);
catch
    msgbox('No fit result for spinTIRF found!');
end
try
    spinTIRFData.fitResult_PA = spinTIRF_Config.spinTIRFData.fitResult_PA;
    spinTIRFData.load_fitResult_PA = 1;
    set(handles.PA_Flag, 'ForegroundColor', [1 0 0 ]);
catch
    msgbox('No fit result for PA found!');
end
% Define channel configuration panel
handles.configChsTab = uitabgroup('Parent', handles.ni_panel, 'Units', 'characters', 'Position', [27 1 33 14]);
for i = 1 : MAX_Chs_Num
    CHsTab{i} = uitab(handles.configChsTab, 'Title', ['CH' num2str(i)]);
%     eval(sprintf('%s=%s',['handles.ch' num2str(i) '_exp_text'],['uicontrol(''Style'', ''text'', ''parent'', CHsTab{i}, ''String'', ''ch''' num2str(i) ', ''Units'', ''characters'', ''Position'', [5 5 8 8]);']));
   switch i
       case 1
           handles.ch1_CH = uicontrol('style', 'popupmenu', 'string', CH_Name, 'Position', [TEXT_Pos 120 70 20], 'Parent', CHsTab{1}, 'units', 'characters',...
               'Tag', 'ch1_CH', 'callback', {@ch1_SetCH_Callback, handles});
           handles.ch1_exp_text = uicontrol('style', 'text', 'string', 'Exposure: ', 'Position', [TEXT_Pos 90 50 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [EDIT_Pos 90 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_nspinperexp_text = uicontrol('style', 'text', 'string', 'N_Turns : ', 'Position', [TEXT_Pos 65 50 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_nspinperexp = uicontrol('style', 'edit', 'string', '1', 'Position', [EDIT_Pos 65 30 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_ETL_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [4 40 50 20], 'Parent', CHsTab{1}, 'units', 'characters');
           handles.ch1_ETL = uicontrol('style', 'edit', 'string', '0', 'Position', [EDIT_Pos 40 30 20], 'Parent', CHsTab{1}, 'Tag', 'ch1_ETL','units', 'characters', 'Enable', 'off');
           handles.ch1_EnableETL = uicontrol('style', 'checkbox', 'string', '', 'Tag', 'ch1_EnableETL',...
               'value', 0, 'Position', [125 40 50 20], 'Parent', CHsTab{1}, 'units', 'characters', 'Enable', 'on');
           handles.ch1_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [TEXT_Pos 15 60 20], 'Parent', CHsTab{1}, 'units', 'characters', 'callback', {@ch1_getPattern_Callback, handles});
           handles.ch1_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [TEXT_Pos .5 120 15], 'Tag', 'ch1_patternName', 'Parent', CHsTab{1}, 'units', 'characters');

       case 2
           handles.ch2_CH = uicontrol('style', 'popupmenu', 'string', CH_Name, 'Position', [TEXT_Pos 120 70 20], 'Parent', CHsTab{2}, 'units', 'characters',...
               'Tag', 'ch2_CH','callback', {@ch2_SetCH_Callback, handles});
           handles.ch2_exp_text = uicontrol('style', 'text', 'string', 'Exposure: ', 'Position', [TEXT_Pos 90 50 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [EDIT_Pos 90 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_nspinperexp_text = uicontrol('style', 'text', 'string', 'N_Turns : ', 'Position', [TEXT_Pos 65 50 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_nspinperexp = uicontrol('style', 'edit', 'string', '1', 'Position', [EDIT_Pos 65 30 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_ETL_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [4 40 50 20], 'Parent', CHsTab{2}, 'units', 'characters');
           handles.ch2_ETL = uicontrol('style', 'edit', 'string', '0', 'Position', [EDIT_Pos 40 30 20], 'Parent', CHsTab{2},'Tag', 'ch2_ETL', 'units', 'characters', 'Enable', 'off');
           handles.ch2_EnableETL = uicontrol('style', 'checkbox', 'string', '', 'Tag', 'ch2_EnableETL',...
               'value', 0, 'Position', [125 40 50 20], 'Parent', CHsTab{2}, 'units', 'characters', 'Enable', 'on');
           handles.ch2_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [TEXT_Pos 15 60 20], 'Parent', CHsTab{2}, 'units', 'characters', 'callback', {@ch2_getPattern_Callback, handles});
           handles.ch2_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [TEXT_Pos .5 120 15], 'Tag', 'ch2_patternName','Parent', CHsTab{2}, 'units', 'characters');

       case 3
           handles.ch3_CH = uicontrol('style', 'popupmenu', 'string', CH_Name, 'Position', [TEXT_Pos 120 70 20], 'Parent', CHsTab{3}, 'units', 'characters',...
               'Tag', 'ch3_CH','callback', {@ch3_SetCH_Callback, handles});
           handles.ch3_exp_text = uicontrol('style', 'text', 'string', 'Exposure: ', 'Position', [TEXT_Pos 90 50 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [EDIT_Pos 90 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_nspinperexp_text = uicontrol('style', 'text', 'string', 'N_Turns : ', 'Position', [TEXT_Pos 65 50 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_nspinperexp = uicontrol('style', 'edit', 'string', '1', 'Position', [EDIT_Pos 65 30 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_ETL_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [4 40 50 20], 'Parent', CHsTab{3}, 'units', 'characters');
           handles.ch3_ETL = uicontrol('style', 'edit', 'string', '0', 'Position', [EDIT_Pos 40 30 20], 'Parent', CHsTab{3}, 'Tag', 'ch3_ETL', 'units', 'characters', 'Enable', 'off');
           handles.ch3_EnableETL = uicontrol('style', 'checkbox', 'string', '', 'Tag', 'ch3_EnableETL',...
               'value', 0, 'Position', [125 40 50 20], 'Parent', CHsTab{3}, 'units', 'characters', 'Enable', 'on');
           handles.ch3_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern',...
               'Position', [TEXT_Pos 15 60 20], 'Parent', CHsTab{3}, 'units', 'characters', 'callback', {@ch3_getPattern_Callback, handles});
           handles.ch3_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [TEXT_Pos .5 120 15], 'Tag', 'ch3_patternName','Parent', CHsTab{3}, 'units', 'characters');

       case 4
           handles.ch4_CH = uicontrol('style', 'popupmenu', 'string', CH_Name, 'Position', [TEXT_Pos 120 70 20], 'Parent', CHsTab{4}, 'units', 'characters',...
               'Tag', 'ch4_CH','callback', {@ch4_SetCH_Callback, handles});
           handles.ch4_exp_text = uicontrol('style', 'text', 'string', 'Exposure: ', 'Position', [TEXT_Pos 90 50 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_exp = uicontrol('style', 'edit', 'string', '400', 'Position', [EDIT_Pos 90 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_nspinperexp_text = uicontrol('style', 'text', 'string', 'N_Turns : ', 'Position', [TEXT_Pos 65 50 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_nspinperexp = uicontrol('style', 'edit', 'string', '1', 'Position', [EDIT_Pos 65 30 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_ETL_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [4 40 50 20], 'Parent', CHsTab{4}, 'units', 'characters');
           handles.ch4_ETL = uicontrol('style', 'edit', 'string', '0', 'Position', [EDIT_Pos 40 30 20], 'Parent', CHsTab{4}, 'Tag', 'ch4_ETL', 'units', 'characters', 'Enable', 'off');
           handles.ch4_EnableETL = uicontrol('style', 'checkbox', 'string', '', 'Tag', 'ch4_EnableETL',...
               'value', 0, 'Position', [125 40 50 20], 'Parent', CHsTab{4}, 'units', 'characters', 'Enable', 'on');
           handles.ch4_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern', ...
               'Position', [TEXT_Pos 15 60 20], 'Parent', CHsTab{4}, 'units', 'characters', 'callback',  {@ch4_getPattern_Callback, handles});
           handles.ch4_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [TEXT_Pos .5 120 15], 'Tag', 'ch4_patternName', 'Parent', CHsTab{4}, 'units', 'characters');

   end
end

% SETUP PA CH tab
CHsTab{MAX_Chs_Num + 1} = uitab(handles.configChsTab, 'Title', 'PA');
handles.PA_Loop = uicontrol('style', 'checkbox', 'string', 'Loop PA', ...
   'value', 0, 'Position', [85 120 70 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_Enable = uicontrol('style', 'checkbox', 'string', 'Enable PA', ...
   'value', 0, 'Position', [TEXT_Pos 120 70 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_Duration_Text = uicontrol('style', 'text', 'string', 'Duration: ', 'Position', [TEXT_Pos 90 50 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_Duration = uicontrol('style', 'edit', 'string', '1000', 'Position', [EDIT_Pos 90 50 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_patternName = uicontrol('style', 'text', 'string', ' ', 'Position', [TEXT_Pos 2 120 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_startFrame_text = uicontrol('style', 'text', 'string', 'StartFrame: ', 'Position', [TEXT_Pos 70 50 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_startFrame = uicontrol('style', 'edit', 'string', '30', 'Position', [EDIT_Pos 70 30 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_endFrame_text = uicontrol('style', 'text', 'string', 'EndFrame : ', 'Position', [TEXT_Pos 50 50 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_endFrame = uicontrol('style', 'edit', 'string', '90', 'Position', [EDIT_Pos 50 30 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_ETL_text = uicontrol('style', 'text', 'string', 'ETL: ', 'Position', [4 30 50 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_ETL = uicontrol('style', 'edit', 'string', '0', 'Position', [EDIT_Pos 30 30 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters');
handles.PA_getPattern = uicontrol('style', 'pushbutton', 'string', 'Get Pattern', ...
   'Position', [TEXT_Pos 10 60 20], 'Parent', CHsTab{MAX_Chs_Num + 1}, 'units', 'characters', 'callback',  {@PA_getPattern_Callback, handles});
handles.CH_Name = CH_Name;

% % end
spinTIRFData.CHsTab = CHsTab;
spinTIRFData.MAX_Chs_Num = MAX_Chs_Num;
spinTIRFData.load_fitResult_spinTIRF = 0;
spinTIRFData.load_fitResult_PA = 0;
spinTIRFData.CH_Name = CH_Name;

setappdata(gcf, 'spinTIRFData', spinTIRFData);
%% SETUP show circle axes
set(handles.showPatternAxes, 'XLim', [-1200 1200], 'YLim', [-1200 1200], 'YTickLabel', '');
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes superScope wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = superScope_OutputFcn(hObject, eventdata, handles) 
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

if  str2double(get(hObject,'String')) == 1
    set(handles.setThetaEnd, 'String', get(handles.setThetaStart, 'String'));
end

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
if ~isfield(spinTIRFData,'preDefinedPatternPos')
    spinTIRFData.preDefinedPatternPos = struct();
end

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
if get(handles.chooseSavePatternFolder, 'value')
    pattern_folder = spinTIRFData.projectFolder;   
else
    pattern_folder = uigetdir(spinTIRFData.spinGridCSV.pathname);
end

switch get(handles.way2definepattern, 'value')
    case 1 % Circular, for spinTIRF
        spinTIRFData.patternfile = cell(length(radius_um), 1);     
        
        if str2double(get(handles.n_samples, 'string')) == 1
            theta = str2double(get(handles.setThetaStart, 'string'))*pi/180;
        else
            theta_start = str2double(get(handles.setThetaStart, 'string'))*pi/180;
            theta_end = str2double(get(handles.setThetaEnd, 'string'))*pi/180;
%             step = (pi*2)/samples;
%             nn = 1:samples;
            theta = linspace(theta_start, theta_end, samples);
        end
        ii = 0;
        for i_radius_um = radius_um
            i_radius_pix = i_radius_um * pix_per_um;
            
            xp = cos(theta)*i_radius_pix+centerx;
            yp = sin(theta)*i_radius_pix+centery;
% %             if length(theta) == 1;
% %                 outfilename = ['r_', num2str(i_radius_um),'um_theta_', get(handles.setThetaStart, 'string')];
% %             else
% %                 outfilename = ['r_', num2str(i_radius_um),'um_s_', num2str(samples)];
% %             end
            outfilename = sprintf('r%d_n%d_theta%d_%d', i_radius_um, samples, ...
                                  str2double(get(handles.setThetaStart, 'string')), ...
                                  str2double(get(handles.setThetaEnd, 'string')));
            ii = ii+1;
%             spinTIRFData.patternfile{ii} = outfilename;
            newPatternName{ii} = outfilename; 
            spinTIRFData.preDefinedPatternPos.(newPatternName{ii}) = [xp.' yp.'];
        end
        fittedmodel_xv = spinTIRFData.fitResult_spinTIRF{1};
        fittedmodel_yv = spinTIRFData.fitResult_spinTIRF{2};
    case 2 % IJ ROI, for PA
        if get(handles.PA_ROI_Mode_MM, 'value')
            xp = handles.MMROI.pixList(:, 2);
            yp = handles.MMROI.pixList(:, 1);
            defaultoutfile = fullfile(pattern_folder, 'MMROI.csv');
            [filename, pathname] = uiputfile('*.csv', 'Save pattern file', defaultoutfile);       
            spinTIRFData.patternfile{1} = filename;
            csvwrite(fullfile(pathname, filename), [xp yp]);
            pattern_folder = pathname;
            newPatternName = {fielname};
            spinTIRFData.preDefinedPatternPos.(newPatternName{1}) = [xp yp];
        elseif get(handles.PA_ROI_Mode_Manual, 'value')
            xp = str2double(get(handles.PA_Manual_X, 'string'));
            yp = str2double(get(handles.PA_Manual_Y, 'string'));
            newPatternName = inputdlg('Enter pattern name:',...
             'Pattern Name', 1, {'PA_Pattern_1'});
            spinTIRFData.preDefinedPatternPos.(newPatternName{1}) = [xp yp];
        elseif get(handles.PA_ROI_Mode_Grids, 'value')
            x = 700:10:1000;
            y = 700:10:1000;
            [xx, yy] = meshgrid(x, y);
            pos = cat(2, xx(:), yy(:));
            for i = 1 : size(pos, 1)
                newPatternName{i, 1} = ['v' num2str(i)];
                spinTIRFData.preDefinedPatternPos.(newPatternName{i}) = pos(i, :);
            end
        end
        fittedmodel_xv = spinTIRFData.fitResult_PA{1};
        fittedmodel_yv = spinTIRFData.fitResult_PA{2};
end

% generate pattern for individle points
spinTIRFData.pattern_folder = pattern_folder;
spinTIRFData.radius_um = radius_um;
set(handles.status, 'string', 'Define pattern, finished!');

%% generate Volts for galvo

% % if get(handles.chooseSavePatternFolder, 'value')
% %     pattern_folder = spinTIRFData.pattern_folder;   
% % else
% %     pattern_folder = uigetdir(spinTIRFData.spinGridCSV.pathname);
% % end
for i = 1 : length(newPatternName)
    
    pixels = spinTIRFData.preDefinedPatternPos.(newPatternName{i});

    volt = [fittedmodel_xv(pixels(:, 1), pixels(:, 2)),...
        fittedmodel_yv(pixels(:, 1), pixels(:, 2))];
    patternName = [newPatternName{i}  '_v'];
    if any(volt(:)<-10) || any(volt(:)>10)
        set(handles.status, 'string', 'Volts out of range!');
        return;
    else
        spinTIRFData.preDefinedPattern.(patternName)=  volt;
    end
    
end
set(handles.predefinedPatternList, 'string', fieldnames(spinTIRFData.preDefinedPattern));
set(handles.predefinedPatternList, 'value', length(get(handles.predefinedPatternList, 'String'))); 
handles = updatePatterListInfo(handles);
% save all various
% % spinTIRF_result = spinTIRFData;
% % savefile = fullfile(spinTIRFData.pattern_folder, 'spinTIRF_result.mat');
% % save(savefile, 'spinTIRF_result');
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
    set(handles.radius_um_1, 'enable', 'off');
    set(handles.radius_um_2, 'enable', 'off');
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

if get(handles.assignFittingTo, 'value') == 1
    spinTIRFData.fitResult_spinTIRF = fitresult;
    spinTIRFData.gof_spinTIRF       = gof;
    spinTIRFData.load_fitResult_spinTIRF = 1;
    set(handles.spinTIRF_Flag, 'ForegroundColor', [1 0 0 ]);
else
    spinTIRFData.fitResult_PA = fitresult;
    spinTIRFData.gof_PA       = gof;
    spinTIRFData.load_fitResult_PA = 1;
    set(handles.PA_Flag, 'ForegroundColor', [1 0 0 ]);
end

disp('Fit surface, finished!');

if isfield(spinTIRFData, 'projectFolder')
    [FileName,PathName,~] = uiputfile('*.mat','Save fit result', ...
        fullfile(spinTIRFData.projectFolder, 'fitResult.mat'));
else
    [FileName,PathName,~] = uiputfile('*.mat','Save fit result','fitResult.mat');
end
if isfield(spinTIRFData, 'S')
    spinTIRFData = rmfield(spinTIRFData, {'S'});
end
if isfield(spinTIRFData, 'lh')
    spinTIRFData = rmfield(spinTIRFData, {'lh'});
end
if isfield(spinTIRFData, 'CHsTab')
    spinTIRFData = rmfield(spinTIRFData, {'CHsTab'});
end
save(fullfile(PathName, FileName),  'spinTIRFData');
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
tokens  = regexp(fieldName, 'r(\d+)_n(\d+)_theta(\d+)_(\d+)_v', 'tokens', 'once');
if ~isempty(tokens)
    radius  = str2double(tokens{1});
    n       = str2double(tokens{2});
    theta_0 = str2double(tokens{3})*pi/180;
    theta_1 = str2double(tokens{4})*pi/180;
    thetaList = linspace(theta_0, theta_1, n);
else
    radius = [];
end
if ~isempty(radius)
    cla(handles.showPatternAxes);
%     handles.circlePattern = viscircles(handles.showPatternAxes,[0 0], radius,'Color','b');
    pos_x = cos(thetaList)*radius;
    pos_y = sin(thetaList)*radius;
    if length(pos_x) == 1
        handles.circlePattern = scatter(handles.showPatternAxes, pos_x, pos_y, 6, 'o', 'linewidth', 2);
    elseif length(pos_x) <= 20
        handles.circlePattern = plot(handles.showPatternAxes, pos_x, pos_y, 'b-o', 'linewidth', 2);
    else
        handles.circlePattern = plot(handles.showPatternAxes, pos_x, pos_y, 'b-', 'linewidth', 2);
    end
    axis([-1200 1200 -1200 1200]);  
    set(gca, 'YTickLabel', []);
    grid on
end
handles = updatePatterListInfo(handles);
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
                'nspinperexp', [], 'rate', [], 'volts', [], 'etl', [], ...
                'getPatternDone', 0);
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
spinTIRFData.ChannelspinTIRF = CHs;
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
[filename, filepath, fillteridx] = uigetfile({'*.mat';'*.xlsx;.xls;*.csv'; '*.rgn'},'Load pattern');

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
    = setfield(spinTIRFData.preDefinedPattern, patternName, patternData );
set(handles.predefinedPatternList, 'string', fieldnames(spinTIRFData.preDefinedPattern));
set(handles.predefinedPatternList, 'value', 1); 
set(handles.status, 'string', 'Pattern added!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
handles = updatePatterListInfo(handles);
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
exposure  = str2double(get(handles.ch1_exp, 'string'));
n_samples = size(pattern, 1);
nspinperexp = str2double(get(handles.ch1_nspinperexp, 'string'));
rate = round(n_samples*nspinperexp/(exposure/1000));  

spinTIRFData.ChannelspinTIRF{1}.volts = pattern;
spinTIRFData.ChannelspinTIRF{1}.n_samples = n_samples;
spinTIRFData.ChannelspinTIRF{1}.exposure = exposure;
spinTIRFData.ChannelspinTIRF{1}.rate = rate;
spinTIRFData.ChannelspinTIRF{1}.nspinperexp = nspinperexp;
h_ch1_ETL = findobj('Tag', 'ch1_ETL');
spinTIRFData.ChannelspinTIRF{1}.etl = str2double(h_ch1_ETL.String);
% if get(handles.ch1_EnableETL, 'value')
%     spinTIRFData.ChannelspinTIRF{1}.etl = str2double(get(handles.setETLEdit, 'String'));
%     set(handles.ch1_ETL, 'string', get(handles.setETLEdit, 'String'));
% else
%     spinTIRFData.ChannelspinTIRF{1}.etl = [];
% end
h_ch1_patternName = findobj('Tag', 'ch1_patternName');
h_ch1_patternName.String = patternName;
spinTIRFData.ChannelspinTIRF{1}.getPatternDone = 1;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
% guidata(src, handles);

% --- Executes on button press in ch2_getPattern.
function ch2_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch2_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
exposure  = str2double(get(handles.ch2_exp, 'string'));
n_samples = size(pattern, 1);
nspinperexp = str2double(get(handles.ch2_nspinperexp, 'string'));
rate = round(n_samples*nspinperexp/(exposure/1000));  

spinTIRFData.ChannelspinTIRF{2}.volts = pattern;
spinTIRFData.ChannelspinTIRF{2}.n_samples = n_samples;
spinTIRFData.ChannelspinTIRF{2}.exposure = exposure;
spinTIRFData.ChannelspinTIRF{2}.rate = rate;
spinTIRFData.ChannelspinTIRF{2}.nspinperexp = nspinperexp;

h_ch2_ETL = findobj('Tag', 'ch2_ETL');
spinTIRFData.ChannelspinTIRF{2}.etl = str2double(h_ch2_ETL.String);
h_ch2_patternName = findobj('Tag', 'ch2_patternName');
h_ch2_patternName.String = patternName;
% % if get(handles.ch2_EnableETL, 'value')
% %     spinTIRFData.ChannelspinTIRF{2}.etl = str2double(get(handles.setETLEdit, 'String'));
% %     set(handles.ch2_ETL, 'string', get(handles.setETLEdit, 'String'));
% % else
% %     spinTIRFData.ChannelspinTIRF{2}.etl = [];
% % end
spinTIRFData.ChannelspinTIRF{2}.getPatternDone = 1;
% set(handles.ch2_patternName, 'String', patternName);
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% guidata(hObject, handles);% add this line will cause the loss of some
% variable

% --- Executes on button press in ch3_getPattern.
function ch3_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch3_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
n_samples = size(pattern, 1);
exposure  = str2double(get(handles.ch3_exp, 'string'));
nspinperexp = str2double(get(handles.ch3_nspinperexp, 'string'));
rate = round(n_samples*nspinperexp/(exposure/1000));  

spinTIRFData.ChannelspinTIRF{3}.volts = pattern;
spinTIRFData.ChannelspinTIRF{3}.n_samples = n_samples;
spinTIRFData.ChannelspinTIRF{3}.exposure = exposure;
spinTIRFData.ChannelspinTIRF{3}.rate = rate;
spinTIRFData.ChannelspinTIRF{3}.nspinperexp = nspinperexp;

h_ch3_ETL = findobj('Tag', 'ch3_ETL');
spinTIRFData.ChannelspinTIRF{3}.etl = str2double(h_ch3_ETL.String);
h_ch3_patternName = findobj('Tag', 'ch3_patternName');
h_ch3_patternName.String = patternName;

% if get(handles.ch3_EnableETL, 'value')
%     spinTIRFData.ChannelspinTIRF{3}.etl = str2double(get(handles.setETLEdit, 'String'));
%     set(handles.ch3_ETL, 'string', get(handles.setETLEdit, 'String'));
% else
%     spinTIRFData.ChannelspinTIRF{3}.etl = [];
% end

spinTIRFData.ChannelspinTIRF{3}.getPatternDone = 1;
% set(handles.ch3_patternName, 'String', patternName);
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% guidata(hObject, handles); % add this line will cause the loss of some
% variable

% % % --- Executes on button press in ch3_getPattern.
function ch4_getPattern_Callback(src, evnt, handles)
% hObject    handle to ch1_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
n_samples = size(pattern, 1);
exposure  = str2double(get(handles.ch4_exp, 'string'));
nspinperexp = str2double(get(handles.ch4_nspinperexp, 'string'));
rate = round(n_samples*nspinperexp/(exposure/1000));  

spinTIRFData.ChannelspinTIRF{4}.volts = pattern;
spinTIRFData.ChannelspinTIRF{4}.n_samples = n_samples;
spinTIRFData.ChannelspinTIRF{4}.exposure = exposure;
spinTIRFData.ChannelspinTIRF{4}.rate = rate;
spinTIRFData.ChannelspinTIRF{4}.nspinperexp = nspinperexp;

h_ch4_ETL = findobj('Tag', 'ch4_ETL');
spinTIRFData.ChannelspinTIRF{4}.etl = str2double(h_ch4_ETL.String);
h_ch4_patternName = findobj('Tag', 'ch4_patternName');
h_ch4_patternName.String = patternName;

% if get(handles.ch4_EnableETL, 'value')
%     spinTIRFData.ChannelspinTIRF{4}.etl = str2double(get(handles.setETLEdit, 'String'));
%     set(handles.ch4_ETL, 'string', get(handles.setETLEdit, 'String'));
% else
%     spinTIRFData.ChannelspinTIRF{4}.etl = [];
% end
% set(handles.ch4_patternName, 'String', patternName);
spinTIRFData.ChannelspinTIRF{4}.getPatternDone = 1;
setappdata(gcf, 'spinTIRFData', spinTIRFData);

function ch1_SetCH_Callback(src,  evnt, handles)

spinTIRFData = getappdata(gcf, 'spinTIRFData');

h_ch1_CH = findobj('Tag', 'ch1_CH');
h_ch1_ETL = findobj('Tag', 'ch1_ETL');

content = h_ch1_CH.String;
CH_Name = content{h_ch1_CH.Value};
spinTIRFData.ChannelspinTIRF{1}.CH_Name = CH_Name;
if get(findobj('Tag', 'ch1_EnableETL'), 'value')
    switch CH_Name
        case 'Custom'
            % get ETL value from manual settings
            h_ch1_ETL.String =  num2str(handles.setETLEdit.String);
            spinTIRFData.ChannelspinTIRF{1}.etl = str2double(h_ch1_ETL.String);
        otherwise
            spinTIRFData.ChannelspinTIRF{1}.etl = spinTIRFData.CH_ETL.(CH_Name);
            h_ch1_ETL.String = num2str(spinTIRFData.ChannelspinTIRF{1}.etl);
            set(handles.setETLSlider, 'value', spinTIRFData.ChannelspinTIRF{1}.etl);
%             refreshETLInfo(handles);
    end
else
    spinTIRFData.ChannelspinTIRF{1}.etl = [];
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% guidata(src, handles);

function ch2_SetCH_Callback(src,  evnt, handles)

spinTIRFData = getappdata(gcf, 'spinTIRFData');

h_ch2_CH = findobj('Tag', 'ch2_CH');
h_ch2_ETL = findobj('Tag', 'ch2_ETL');

content = h_ch2_CH.String;
CH_Name = content{h_ch2_CH.Value};
spinTIRFData.ChannelspinTIRF{2}.CH_Name = CH_Name;
if get(findobj('Tag', 'ch2_EnableETL'), 'value')
    switch CH_Name
        case 'Custom'
            % get ETL value from manual settings
            h_ch2_ETL.String =  num2str(handles.setETLEdit.String);
            spinTIRFData.ChannelspinTIRF{2}.etl = str2double(h_ch2_ETL.String);
        otherwise
            spinTIRFData.ChannelspinTIRF{2}.etl = spinTIRFData.CH_ETL.(CH_Name);
            h_ch2_ETL.String = num2str(spinTIRFData.ChannelspinTIRF{2}.etl);
    end
else
    spinTIRFData.ChannelspinTIRF{2}.etl = [];
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% guidata(src, handles);

function ch3_SetCH_Callback(src,  evnt, handles)

spinTIRFData = getappdata(gcf, 'spinTIRFData');

h_ch3_CH = findobj('Tag', 'ch3_CH');
h_ch3_ETL = findobj('Tag', 'ch3_ETL');

content = h_ch3_CH.String;
CH_Name = content{h_ch3_CH.Value};
spinTIRFData.ChannelspinTIRF{3}.CH_Name = CH_Name;
if get(findobj('Tag', 'ch3_EnableETL'), 'value')
    switch CH_Name
        case 'Custom'
            % get ETL value from manual settings
            h_ch3_ETL.String =  num2str(handles.setETLEdit.String);
            spinTIRFData.ChannelspinTIRF{3}.etl = str2double(h_ch3_ETL.String);
        otherwise
            spinTIRFData.ChannelspinTIRF{3}.etl = spinTIRFData.CH_ETL.(CH_Name);
            h_ch3_ETL.String = num2str(spinTIRFData.ChannelspinTIRF{3}.etl);
    end
else
    spinTIRFData.ChannelspinTIRF{3}.etl = [];
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);
% 
% guidata(src, handles);

function ch4_SetCH_Callback(src,  evnt, handles)

spinTIRFData = getappdata(gcf, 'spinTIRFData');

h_ch4_CH = findobj('Tag', 'ch4_CH');
h_ch4_ETL = findobj('Tag', 'ch4_ETL');

content = h_ch4_CH.String;
CH_Name = content{h_ch4_CH.Value};
spinTIRFData.ChannelspinTIRF{4}.CH_Name = CH_Name;
if get(findobj('Tag', 'ch4_EnableETL'), 'value')
    switch CH_Name
        case 'Custom'
            % get ETL value from manual settings
            h_ch4_ETL.String =  num2str(handles.setETLEdit.String);
            spinTIRFData.ChannelspinTIRF{4}.etl = str2double(h_ch4_ETL.String);
        otherwise
            spinTIRFData.ChannelspinTIRF{4}.etl = spinTIRFData.CH_ETL.(CH_Name);
            h_ch4_ETL.String = num2str(spinTIRFData.ChannelspinTIRF{4}.etl);
    end
else
    spinTIRFData.ChannelspinTIRF{4}.etl = [];
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);

% guidata(src, handles);
% 

% % % --- Executes on button press in ch3_getPattern.
function PA_getPattern_Callback(src, evnt, handles)
% hObject    handle to ch1_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~get(handles.PA_Enable, 'value')
    msgbox('Enable PA first!!');
    return;
end

spinTIRFData = getappdata(gcf, 'spinTIRFData');

spinTIRFData.ChannelPA.etl = str2double(get(handles.setETLEdit, 'String'));
set(handles.PA_ETL, 'string', get(handles.setETLEdit, 'String'));

content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = spinTIRFData.preDefinedPattern.(patternName);
n_samples = size(pattern, 1);
exposure  = str2double(get(handles.PA_Duration, 'string'));
startFrame = str2double(get(handles.PA_startFrame, 'string'));
nspinperexp = 1;
rate = round(n_samples*nspinperexp/(exposure/1000));  

spinTIRFData.ChannelPA.volts = pattern;
spinTIRFData.ChannelPA.getPatternDone = 1;
spinTIRFData.ChannelPA.exposure = exposure;
spinTIRFData.ChannelPA.n_samples = n_samples;
spinTIRFData.ChannelPA.startFrame = startFrame;
spinTIRFData.ChannelPA.rate = rate;
set(handles.PA_patternName, 'String', patternName);
spinTIRFData.ChannelPA.getPatternDone = 1;
setappdata(gcf, 'spinTIRFData', spinTIRFData);


% --- Executes on button press in ScanMirror.
function ScanMirror_Callback(hObject, eventdata, handles)
% hObject    handle to ScanMirror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get daq connection
% S = spinTIRFData.S;
spinTIRFData = getappdata(gcf, 'spinTIRFData');
S = daq.createSession('ni');
if S.IsLogging
    msgbox('Pls wait until last operation finished!', 'Error', 'error');
    return;
end
try
    switch (get(handles.pickGalvo, 'value')) 
        case 1 % release channle, pls pick a galvo first
            msgbox('Pick a galvo first!', 'Error', 'error');
            return;
        case 2 % TIRF
            if ~isempty(S.Channels)
                removeChannel(S,1:length(S.Channels));
            end
                % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao0', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao1', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];
        case 3 % PA
            if ~isempty(S.Channels)
                removeChannel(S,1:length(S.Channels));
            end
            % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao2', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao3', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
        case 4 % both PA and TIRF
            if ~isempty(S.Channels)
                removeChannel(S,1:length(S.Channels));
            end
            ch_ao0 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao0', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao1', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];
            
            % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao2', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao3', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
            
            
    end
catch
    msgbox('Setup voltage channle error!', 'Error', 'error');
    return;
end
% make sure pattern has been get
n_chs = get(handles.n_Chs, 'value') - 1;
check = 1;
for iCh = 1 : n_chs
    if ~spinTIRFData.ChannelspinTIRF{iCh}.getPatternDone
        check = 0;
    end
end
% % if get(handles.PA_Enable, 'value')
% %     if ~isfield(spinTIRFData, 'ChannelPA')
% %         check = 0;
% %     end
% % end
if ~check
    msgbox('Get pattern for each channle first!!');
    return;
end


% setup trigger source
if get(handles.runGalvoMode, 'Value') == 2 || ...% Trigger mode
        get(handles.runGalvoMode, 'Value') == 4 ||...% Auto scan
        get(handles.runGalvoMode, 'Value') == 5 ||...% prescandefined pattern
        get(handles.runGalvoMode, 'Value') == 6 ||...% trigger TIRF and PA
        get(handles.runGalvoMode, 'Value') == 8      % scan points in selected pattern
        
    addTriggerConnection(S, 'External', 'cDAQ1Mod2/PFI0', 'StartTrigger');
    S.Connections(1).TriggerCondition = 'RisingEdge';
    S.ExternalTriggerTimeout = 300;
elseif get(handles.runGalvoMode, 'Value') == 7 % trigger PA calibration
    addTriggerConnection(S, 'External', 'cDAQ1Mod2/PFI0', 'StartTrigger');
    S.Connections(1).TriggerCondition = 'FallingEdge';
    S.ExternalTriggerTimeout = 300;
end

% check ETL settings
ETLconnected = 0;
if isfield(handles, 'lens')
    if strcmp(handles.lens.status, 'open')
        ETLconnected = 1;
    end
end

set(handles.status, 'String', 'Wait NI to start...');

spinTIRFData.S = S;
setappdata(gcf, 'spinTIRFData', spinTIRFData);
%% RUN ni
set(handles.status, 'String', 'Start NI!!!');
spinTIRFData.N_frames = str2double(get(handles.n_turns, 'string'));

volts = cell(n_chs, 1);
rates = cell(n_chs, 1);
nspinperexp = cell(n_chs, 1);
etls = cell(n_chs, 1);
enableETL = cell(n_chs, 1);
for iCh = 1 : n_chs
    volts{iCh} = spinTIRFData.ChannelspinTIRF{iCh}.volts;
    rates{iCh} = spinTIRFData.ChannelspinTIRF{iCh}.rate;
    nspinperexp{iCh} = spinTIRFData.ChannelspinTIRF{iCh}.nspinperexp;   
    etls{iCh} = spinTIRFData.ChannelspinTIRF{iCh}.etl;
    enableETL{iCh} = get(handles.(sprintf('ch%d_EnableETL', iCh)), 'value');
end

setappdata(gcf, 'manuallyStop', 0);
set(handles.ScanMirror, 'enable', 'off');
if n_chs == 1 && get(handles.pickGalvo, 'Value') ==2 && (get(handles.runGalvoMode, 'Value') == 1) % TIRF,single channle, freerun mode, can be faster
    if ETLconnected && enableETL{1}
        handles.lens.setCurrent(etls{1});
    end
% %     selTabName =  handles.configChsTab.SelectedTab.Title;
% %     selTabNum = str2double(selTabName(3));
% %     if ~spinTIRFData.ChannelspinTIRF{selTabNum}.getPatternDone
% %         msgbox(sprintf('Get pattern for CHd% first!!', selTabNum));
% %         return;
% %     end
    tic
    spinTIRFData.S.IsContinuous = true;
    spinTIRFData.S.Rate = rates{1};
    data = repmat(volts{1}, nspinperexp{1}, 1);
    spinTIRFData.S.NotifyWhenScansQueuedBelow = size(data, 1);
    queueOutputData(spinTIRFData.S, data);  
    lh = addlistener(spinTIRFData.S,'DataRequired', ...
        @(src,event) src.queueOutputData(data));
    spinTIRFData.lh = lh;
    guidata(hObject,handles);
    spinTIRFData.S.startBackground();
    toc
    wait(spinTIRFData.S, 120);
elseif get(handles.pickGalvo, 'Value') ==3 && get(handles.runGalvoMode, 'Value')==1 % PA Mode, freerun
    spinTIRFData.S.IsContinuous = true;
    spinTIRFData.S.Rate = min(rates{1}, 1000);%% ?? mark to change later
    data = repmat(volts{1}, nspinperexp{1}, 1);
    data = cat(1, data, [0 0]); % ??direct beam off screen [-9 -9]
    spinTIRFData.S.NotifyWhenScansQueuedBelow = size(data, 1);
    queueOutputData(spinTIRFData.S, data);
    lh = addlistener(spinTIRFData.S,'DataRequired', ...
        @(src,event) src.queueOutputData(data));
    spinTIRFData.lh = lh;
    guidata(hObject,handles);
    spinTIRFData.S.startBackground();
    wait(spinTIRFData.S, 120);
elseif get(handles.pickGalvo, 'Value') ==3 && get(handles.runGalvoMode, 'Value')==2 % PA Mode, trigger
    spinTIRFData.S.IsContinuous = false;
    spinTIRFData.S.Rate = rates{1};%% ?? mark to change later
    data = repmat(volts{1}, nspinperexp{1}, 1);
    queueOutputData(spinTIRFData.S, data);
    lh = addlistener(spinTIRFData.S,'DataRequired', ...
        @(src,event) src.queueOutputData(data));
    spinTIRFData.lh = lh;
    guidata(hObject,handles);
    spinTIRFData.S.startBackground();
    wait(spinTIRFData.S, 120);
elseif get(handles.runGalvoMode, 'Value') == 4% Autoscan mode
    try
        fittedmodel_xv = spinTIRFData.fitResult_spinTIRF{1};
        fittedmodel_yv = spinTIRFData.fitResult_spinTIRF{2};
    catch
        set(handles.status, 'string', 'Load fitting results first!!');
        return;
    end
    centerx = str2double(get(handles.cam_width_x, 'String'))/2;
    centery = str2double(get(handles.cam_height_y, 'String'))/2;
    samples = spinTIRFData.ChannelspinTIRF{1}.n_samples;
    nspinperexp = spinTIRFData.ChannelspinTIRF{1}.nspinperexp;
    step = (pi*2)/samples;
    radiusRange = 600:5:850;
    NScan = length(radiusRange);
    scanPattern = cell(NScan, 1);
    spinTIRFData.S.Rate = rates{1};
    i = 1;
    for iRadius = radiusRange
        nn = 0 : samples - 1;
        xp = cos(step*nn)*iRadius+centerx;
        yp = -sin(step*nn)*iRadius+centery;
        volts = [fittedmodel_xv(xp, yp)', fittedmodel_yv(xp, yp)'];
        scanPattern{i} = volts;
        i = i + 1;
    end
    spinTIRFData.S.Rate = rates{1};
    for iScan = 1 : NScan
        if ~getappdata(gcf, 'manuallyStop')
            queueOutputData(spinTIRFData.S, repmat(scanPattern{iScan}, nspinperexp, 1));  
            spinTIRFData.S.startBackground();
            wait(spinTIRFData.S, 120) ; 
        else
            set(handles.status, 'string', 'Manually Stopped!!');
            break;
        end
    end
elseif get(handles.runGalvoMode, 'Value') == 5% scan predefined pattern list mode
    patternListName = cellstr(get(handles.predefinedPatternList,'String')) ;
    NPatterns = length(patternListName);
    nspinperexp = spinTIRFData.ChannelspinTIRF{1}.nspinperexp;
    scanPattern = cell(NPatterns, 1);
    spinTIRFData.S.Rate = rates{1};
    for iPatternCount = 1 : NPatterns
        fieldName    =    patternListName{iPatternCount} ;
        volts = spinTIRFData.preDefinedPattern.(fieldName);
        scanPattern{iPatternCount} = volts;
    end
    spinTIRFData.S.Rate = rates{1};
    for iScan = 1 : NPatterns
        for iCh = 1 : n_chs
            if ETLconnected && enableETL{iCh}
                handles.lens.setCurrent(etls{iCh});
            end
            if ~getappdata(gcf, 'manuallyStop')
                queueOutputData(spinTIRFData.S, repmat(scanPattern{iScan}, nspinperexp, 1));
                
                spinTIRFData.S.startBackground();
                wait(spinTIRFData.S, 120) ; 
            else
                set(handles.status, 'string', 'Manually Stopped!!');
                break;
            end
        end
        str = sprintf('Scanning pattern %d/%d', iScan, NPatterns);
        set(handles.status, 'string', str);
    end
    set(handles.status, 'string', 'Scanning Done!!');
elseif get(handles.runGalvoMode, 'value') == 6 % TIRF_PA mode
    counter = 1;
%     loopPA = get(handles.PA_Loop, 'value');
    PA_startFrame = str2double(get(handles.PA_startFrame, 'string'));
    PA_endFrame = str2double(get(handles.PA_endFrame, 'string')); % Loop PA each turn
%     PA_RepeatCounter = 1;
    while ~getappdata(gcf, 'manuallyStop')    
            % set PA mirror to [0 0]; TIRF mirror to the first lication of
            % first channle
        volt_first_ch = volts{1};
        volts_to_set = [volt_first_ch(1,:) 0 0];
        spinTIRFData.S.Rate = rates{iCh};
        outputSingleScan(S, volts_to_set);
        %%%%%%%%%%%%%%%%%%
        %%%%%%%
        %%%%%%%%%%%%%%%%%%%%
        %%%%%%%Joe Tic
        
        for iCh = 1 : n_chs 
            % run ETL
            if ETLconnected && enableETL{iCh}
                handles.lens.setCurrent(etls{iCh});
            end
            data = cat(2, repmat(volts{iCh}, nspinperexp{iCh}, 1),...
                repmat(zeros(size(volts{iCh})), nspinperexp{iCh}, 1));% 4 channles
            queueOutputData(spinTIRFData.S, data);
            spinTIRFData.S.startBackground();
            wait(spinTIRFData.S, 120) ; 
            disp('TIRF');
        end
        tic
        if counter>=PA_startFrame && counter<=PA_endFrame
%             if PA_RepeatCounter < repeatTimes
%                   PA_RepeatCounter = PA_RepeatCounter + 1;
%                   counter = counter - 1;
%                   disp('PA_RepeatCounter + 1');
%             else
%                 if loopPA
%                     counter = 0;
%                 else
%                     counter = counter + 1;
%                 end
%                 PA_RepeatCounter = 1;
%                 disp('Reset PA_RepeatCounter');
%             end
            handles.lens.setCurrent(spinTIRFData.ChannelPA.etl);
            paVolts = spinTIRFData.ChannelPA.volts;
            data = cat(2, zeros(size(paVolts)), paVolts);% 4 channles
            spinTIRFData.S.Rate = spinTIRFData.ChannelPA.rate;
            queueOutputData(spinTIRFData.S, data);
            
            spinTIRFData.S.startBackground();
            wait(spinTIRFData.S, 120) ; 
            disp('pa');
            
        end
        toc
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%JOE ADDED TOC HERE
       %%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%
       %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%
       disp(num2str(counter));
        counter = counter + 1;
        
    end
%or n_rounds
elseif get(handles.runGalvoMode, 'value') == 7 % Trigger calibration PA
    scanVolts = volts{1};
    nPoints = size(scanVolts, 1);
    spinTIRFData.S.Rate = rates{iCh};

    for i = 1 : nPoints
        if ~getappdata(gcf, 'manuallyStop')
            queueOutputData(spinTIRFData.S, repmat(scanVolts(i, :), 10, 1));
            spinTIRFData.S.startBackground();
            wait(spinTIRFData.S, 120) ; 
        else
            set(handles.status, 'string', 'Manually Stopped!!');
            break;
        end
    end

elseif get(handles.runGalvoMode, 'value') == 3 % n_rounds; add delay now
    if spinTIRFData.n_turns_delay
        set(handles.status, 'string', sprintf('Delay excution for %d seconds', spinTIRFData.n_turns_delay));
        pause(spinTIRFData.n_turns_delay);
        set(handles.status, 'string' , 'Delay ends');
    end
    for iFrame = 1 : spinTIRFData.N_frames
        if ~getappdata(gcf, 'manuallyStop')
            for iCh = 1 : n_chs 
                % run ETL
                if ETLconnected && enableETL{iCh}
                    handles.lens.setCurrent(etls{iCh});
                end
                queueOutputData(spinTIRFData.S, repmat(volts{iCh}, nspinperexp{iCh}, 1));
                spinTIRFData.S.Rate = rates{iCh};
                spinTIRFData.S.startBackground();
                wait(spinTIRFData.S, 120) ; 
            end
        else
            set(handles.status, 'string', 'Manually Stopped!!');
            break;
        end
    end
elseif get(handles.runGalvoMode, 'value') == 8 % scan points list in selected patterns, by trigger
    patternListName = cellstr(get(handles.predefinedPatternList,'String')) ;
    selPatternName = patternListName{get(handles.predefinedPatternList,'Value')};
    voltsList = spinTIRFData.preDefinedPattern.(selPatternName);
    scanPattern = mat2cell(voltsList, ones(size(voltsList, 1), 1), 2);
    
    for iScan = 1 : length(voltsList) %scan points sequentially per trigger
        for iCh = 1 : n_chs
            if ETLconnected && enableETL{iCh}
                handles.lens.setCurrent(etls{iCh});
            end
            if ~getappdata(gcf, 'manuallyStop')
                queueOutputData(spinTIRFData.S, repmat(scanPattern{iScan}, nspinperexp{iCh}, 1));
                spinTIRFData.S.Rate = rates{1};
                spinTIRFData.S.startBackground();
                wait(spinTIRFData.S, 120) ; 
            else
                set(handles.status, 'string', 'Manually Stopped!!');
                break;
            end
        end
        str = sprintf('Scanning pattern %d/%d', iScan, length(voltsList) );
        set(handles.status, 'string', str);
    end
    set(handles.status, 'string', 'Scanning Done!!');
else% n_chs~=1, or trigger-mode, 
    spinTIRFData.S.IsContinuous = false;
    while ~getappdata(gcf, 'manuallyStop')   
        for iCh = 1 : n_chs 
            spinTIRFData.S.Rate = rates{iCh};

             % run ETL
            if ETLconnected && enableETL{iCh}
                handles.lens.setCurrent(etls{iCh});
            end
            data2send = repmat(volts{iCh}, nspinperexp{iCh}, 1);
            queueOutputData(spinTIRFData.S,data2send);
            spinTIRFData.S.startBackground();
            wait(spinTIRFData.S, 120) ;
        end
    end

end

set(handles.status, 'string', 'NI Ended!');
set(handles.ScanMirror, 'enable', 'on');
release(spinTIRFData.S);
setappdata(gcf, 'spinTIRFData', spinTIRFData);

%%
guidata(hObject,handles);

% % function datacallback(src, event)
% % global nidata;
% % % disp(mod(nidata.counter,2)+1)
% % src.queueOutputData(nidata.data{mod(nidata.counter,2)+1});
% % nidata.counter = nidata.counter +1;

% --- Executes on button press in setNI.
function setNI_Callback(hObject, eventdata, handles)
% hObject    handle to setNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of setNI
x_volt = str2double(get(handles.x_volt, 'string'));
y_volt = str2double(get(handles.y_volt, 'string'));

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
            ch_ao2 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao0', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao1', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];
        case 3 % PA
            data = [x_volt y_volt];
            if ~isempty(S.Channels)
                removeChannel(S,1);
                removeChannel(S,1);
            end
            % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao2', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao3', 'Voltage'); 
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
    case 4
        set(handles.runGalvoMode, 'value', 6);
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
        nTotalTestImg = length(1:20:totalFrames);
        laserImg = single(zeros(imgHeight, imgWidth, nTotalTestImg));
%         laserImgBW = laserImg;
        warning off;
        h = waitbar(0,'Loading Image Fragment 0 , please wait...');
        tifLink = Tiff(fullfile(PathName, FileName), 'r');
        icount = 1;
        for i=1:20:totalFrames
            waitbar(i/totalFrames,h,['Loading Image Fragment '  num2str(i) ' , please wait...']);
            tifLink.setDirectory(i);
%             iImg =  tiffread([PathName FileName], i); 
%             laserImg(:,:,i)= single(iImg.data);
            laserImg(:, :, icount) = single(tifLink.read());
            icount = icount + 1;
        end
        close(h);
        maxImg = max(laserImg, 3);
        thres = max(maxImg(:))*0.1;
%         thres = 25000;1`
        h = waitbar(0,'Extracting laser positions , please wait...');
        for i=1:totalFrames
            waitbar(i/totalFrames,h,['Extracting laser positions '  num2str(i) '/441 , please wait...']);
            tifLink.setDirectory(i);
            iLaserImg = single(tifLink.read());
            iLaserImgBW = iLaserImg>thres;
            stats = regionprops(iLaserImgBW,iLaserImg,'centroid', 'area');
            imgSize = size(iLaserImgBW);
            if isempty(stats)
                spinTIRFData.laserImgPosition(i) = struct('xCoord', [], 'yCoord', []);
            else
                [~, idx] = max([stats.Area]);
                try
                    ct = stats(idx).Centroid;
                    if ct(1)>10 && ct(1)< (imgSize(2)-10) && ct(2)>10 && ct(2)< (imgSize(1)-10)
                        spinTIRFData.laserImgPosition(i) = struct('xCoord', ct(1), 'yCoord', ct(2));
                    else
                        spinTIRFData.laserImgPosition(i) = struct('xCoord', [], 'yCoord', []);
                    end
                catch
                    disp('err');
                end
            end
        end
        close(h);
    end
else
    FileName = sort(FileName);
    totalFrames = length(FileName);
    FileInfo = imfinfo([PathName FileName{1}]);
    imgWidth = FileInfo(1).Width; 
    imgHeight = FileInfo(1).Height; 
    laserImg = zeros(imgHeight, imgWidth, totalFrames,'single');
    laserImgBW = laserImg;
    h = waitbar(0,'Loading Image Fragment 0 , please wait...');
    for i=1:length(FileName)
        waitbar(i/length(FileName),h,['Loading Image Fragment '  num2str(i) ' , please wait...']);
        laserImg(:,:,i)= single(imread([PathName FileName{i}]));   
        laserImgBW(:, :, i) = imbinarize(laserImg(:, :, i), 2500);
    end
    close(h);
end

spinTIRFData.laserImgAvg = max(laserImg, [], 3);
spinTIRFData.projectFolder = PathName;

% calibration = [];
% constrains = struct('eliminateEdgeFlag',1,'areaMin',5,'areaMax',1000);
% spinTIRFData.laserImgPosition = getMovieInfo(single(laserImg),single(laserImgBW),constrains,calibration);

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
if get(handles.scanVoltsSettings, 'value') == 1
    [xv, yv] = index_to_volts(keepIdx, [10 -10 -1 1]);
else
    [xv, yv] = index_to_volts(keepIdx, [5 -5 -0.5 0.5]);
end
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


% --- Executes on button press in findCentroid.
function findCentroid_Callback(hObject, eventdata, handles)
% hObject    handle to findCentroid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% BW  = atrous(spinTIRFData.laserImg,0,1,5,4);



% --- Executes on button press in removePattern.
function removePattern_Callback(hObject, eventdata, handles)
% hObject    handle to removePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
content = get(handles.predefinedPatternList, 'string');
if iscell(content)
    currentV = get(handles.predefinedPatternList, 'value');
    fieldName = content{currentV};
else
    fieldName = content;
end
spinTIRFData.preDefinedPattern = rmfield(spinTIRFData.preDefinedPattern, fieldName);
content = fieldnames(spinTIRFData.preDefinedPattern);
set(handles.predefinedPatternList, 'string', content);
if currentV>=length(content)
    set(handles.predefinedPatternList, 'value', length(content));
else
    set(handles.predefinedPatternList, 'value', currentV);
end
handles = updatePatterListInfo(handles);
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
        % reset TIRF
            data = [0 0 0 0];
            if ~isempty(S.Channels)
                removeChannel(S,1:length(S.Channels));
            end
            % add a analog output channel
            ch_ao0 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao0', 'Voltage'); 
            ch_ao0.Range = [-10.0 10.0];

            ch_ao1 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao1', 'Voltage'); 
            ch_ao1.Range = [-10.0 10.0];

            % add a analog output channel
            ch_ao2 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao2', 'Voltage'); 
            ch_ao2.Range = [-10.0 10.0];

            ch_ao3 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao3', 'Voltage'); 
            ch_ao3.Range = [-10.0 10.0];

            outputSingleScan(S, data);
            release(S);
            set(handles.status, 'string', 'Reset NI done!');

catch
    msgbox('Setup voltage channle error!', 'Error', 'error');
    return;
end

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
set(handles.ScanMirror, 'enable', 'on');
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
spinTIRFData = getappdata(gcf, 'spinTIRFData');

switch get(hObject, 'Value')
    case 1 % free run
        set(handles.n_turns, 'enable', 'off');
        set(handles.n_Chs, 'value', 2);
    case 2 % trigger
        set(handles.n_turns, 'enable', 'off');
    case 3 % n+turns
        set(handles.n_turns, 'enable', 'on');
        prompt = {'Need a delay? (s)'};
        dlg_title = 'Input a delay';
        num_lines = 1;
        defaultans = {'0'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        spinTIRFData.n_turns_delay = str2double(answer{1});
    case 4 % Autoscan
        set(handles.n_Chs, 'value', 2); % only allow 1 channle
        set(handles.n_turns, 'enable', 'off');
    case 5 % ScanPredefinedPattern
        set(handles.n_Chs, 'value', 2); % only allow 1 channle       
        set(handles.n_turns, 'enable', 'off');
    case 6 % mixed TIRF and PA mode
        set(handles.n_turns, 'enable', 'off');
        set(handles.pickGalvo, 'value', 4);
        if isfield(handles, 'lens')
            if ~strcmp(handles.lens.status, 'open')
                set(hObject, 'Value', 1);
                msgbox('Connect ETL to access this mode!!', 'error', 'error');
            end
        else
            set(hObject, 'Value', 1);
            msgbox('Connect ETL to access this mode!!', 'error', 'error');
        end
    case 7 % calibration PA
        set(handles.n_turns, 'enable', 'off');
        set(handles.pickGalvo, 'value', 3);
        set(handles.n_Chs, 'value', 2); % only allow 1 channle
    case 8
       set(handles.n_turns, 'enable', 'off');
       set(handles.pickGalvo, 'value', 2); 
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);

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


% --------------------------------------------------------------------
function loadFittingResult_Callback(hObject, eventdata, handles)
% hObject    handle to loadFittingResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

[filename, filepath, ~] = uigetfile('*.mat','Load fitting results');

if filename == 0
    msgbox('User selection cancled!');
    return;
end
loadMat = load(fullfile(filepath, filename), 'spinTIRFData');
if get(handles.assignFittingTo, 'value')== 1      
    try  
        fitResult_spinTIRF = loadMat.spinTIRFData.fitResult_spinTIRF;
        spinTIRFData.fitResult_spinTIRF = fitResult_spinTIRF;
        spinTIRFData.load_fitResult_spinTIRF = 1;
        set(handles.spinTIRF_Flag, 'ForegroundColor', [1 0 0 ]);
    catch
        msgbox('No fitting result for spinTIRF!')
        return;
    end
else
    try  
        fitResult_PA = loadMat.spinTIRFData.fitResult_PA;
        spinTIRFData.fitResult_PA = fitResult_PA;
        spinTIRFData.load_fitResult_PA = 1;
        set(handles.PA_Flag, 'ForegroundColor', [1 0 0 ]);
    catch
        msgbox('No fitting result for pa!')
        return;
    end
end
setappdata(gcf, 'spinTIRFData', spinTIRFData);
set(handles.status, 'string', 'Load fitting result finished!!');
guidata(hObject, handles);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setByClick.
function setByClick_Callback(hObject, eventdata, handles)
% hObject    handle to setByClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
try
    fittedmodel_xv = spinTIRFData.fitResult_spinTIRF{1};
    fittedmodel_yv = spinTIRFData.fitResult_spinTIRF{2};
catch
    set(handles.status, 'string', 'Load fitting results first!!');
    return;
end
h = impoint(handles.showPatternAxes,[]);
position = wait(h);
output = [fittedmodel_xv(position(1), position(2)),...
    fittedmodel_yv(position(1), position(2))];
set(handles.x_volt, 'string', num2str(output(1)));
set(handles.y_volt, 'string', num2str(output(2)));

guidata(hObject, handles);


% --- Executes on selection change in setETLMode.
function setETLMode_Callback(hObject, eventdata, handles)
% hObject    handle to setETLMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setETLMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setETLMode


% --- Executes during object creation, after setting all properties.
function setETLMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to se   tETLMode (see GCBO)
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
spinTIRFData = getappdata(gcf, 'spinTIRFData');

switch get(hObject, 'Value')
    case 1 %
        %% CONNECT ETL
        try
            ETL = load('ETL.mat');
            handles.ETL = ETL.ETL;
            if isempty(handles.ETL)
                set(handles.ETLStatus, 'ETL Configuration File Is Empty!!');
            end
        catch
            set(handles.ETLStatus, 'string', 'ETL Configuration File Not Found!!');
            return;
        end
        try
            handles.lens = Optotune(handles.ETL.COM);
            handles.lens = handles.lens.Open();
%             handles.lens = handles.lens.currentMode('Current');
            handles.lens = handles.lens.setModeUpperCurrent(handles.ETL.maxValue);
            handles.lens = handles.lens.setModeLowerCurrent(handles.ETL.minValue);
            minStep = 1/(handles.ETL.maxValue-handles.ETL.minValue);
            set(handles.setETLSlider, 'Min',handles.ETL.minValue,...
                                     'Max', handles.ETL.maxValue,...
                                     'SliderStep', [minStep 5*minStep], ...
                                     'Value', 0, 'enable', 'on');
            set(handles.setETLEdit, 'string', num2str(0), 'enable', 'on');
            % UPDATE ETL settings for each channles
            spinTIRFData.CH_ETL = ETL.ETL.CH_ETL;
            setappdata(gcf, 'spinTIRFData', spinTIRFData);
        catch
            set(handles.ETLStatus, 'string', 'Connect ETL Error!!');
            return;
        end
        if strcmp (handles.lens.status, 'open')
            set(handles.ETLStatus, 'string', 'Connection established!!');
        else
            set(handles.ETLStatus, 'string', 'Failed to open ETL!!');
            return;
        end
        set(hObject,'String', 'Disconnect');
        
    case 0
        if isfield(handles, 'lens')
            if strcmp(handles.lens.status, 'open')
                handles.lens.Close();
            end
        end
        set(hObject, 'String', 'Connect');
        set(handles.setETLSlider, 'enable', 'off');
        set(handles.setETLEdit, 'string', num2str(0), 'enable', 'off');
        set(handles.ETLStatus, 'string', 'Lens disconnected!!');
end


guidata(hObject, handles);

% --- Executes on slider movement.
function setETLSlider_Callback(hObject, eventdata, handles)
% hObject    handle to setETLSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% currentValue = handles.ETL.minValue + get(hObject,'Value')*(handles.ETL.maxValue - handles.ETL.minValue);
currentValue = get(hObject,'Value');
if currentValue>=handles.ETL.minValue && currentValue<=handles.ETL.maxValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(round(currentValue));
    end
elseif currentValue<handles.ETL.minValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(handles.ETL.minValue);
    end
elseif currentValue<handles.ETL.maxValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(handles.ETL.maxValue);
    end
end
set(handles.setETLEdit, 'string', int2str(round(currentValue)));
% get current tab
selTabName =  handles.configChsTab.SelectedTab.Title;
selTabNum = str2double(selTabName(3));
CHsETL = sprintf('ch%d_ETL', selTabNum);
handles.(CHsETL).String = int2str(round(currentValue));

refreshETLInfo(handles);
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

setValue =  str2double(get(hObject,'String'));

if setValue>=handles.ETL.minValue && setValue<=handles.ETL.maxValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(round(setValue));
    end
elseif setValue<handles.ETL.minValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(handles.ETL.minValue);
    end
elseif setValue>handles.ETL.maxValue
    if strcmp(handles.ETL.MODE, 'Current')
        handles.lens.setCurrent(handles.ETL.maxValue);
    end
end
set(handles.setETLEdit, 'string', int2str(round(setValue)));
% set(handles.setETLSlider, 'value', (setValue-handles.ETL.minValue)/(handles.ETL.maxValue-handles.ETL.minValue));
set(handles.setETLSlider, 'value',setValue)
refreshETLInfo(handles);
guidata(hObject, handles);

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

function refreshETLInfo(handles)

    currentT = handles.lens.temperature;
    currentV = handles.lens.current;
    set(handles.ETLStatus, 'string', ['Current: ', num2str(currentV) '; Temp: ' num2str(currentT)]);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isfield(handles, 'lens')
    if strcmp(handles.lens.status, 'open')
        try
            handles.lens.Close();
        catch
            error('Lens not connected');
        end
    end
end
delete(hObject);


% --- Executes on button press in clearPattern.
function clearPattern_Callback(hObject, eventdata, handles)
% hObject    handle to clearPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');

spinTIRFData.preDefinedPattern = struct();
content = fieldnames(spinTIRFData.preDefinedPattern);
set(handles.predefinedPatternList, 'string', content);
set(handles.predefinedPatternList, 'value', 1);
handles = updatePatterListInfo(handles);
set(handles.status, 'string', 'Pattern cleared!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

function handles = updatePatterListInfo(handles)

totalPattern = length(get(handles.predefinedPatternList, 'string'));
if totalPattern
    currentPattern = get(handles.predefinedPatternList, 'value');
else
    currentPattern = 0;
end
str = sprintf('%d/%d', currentPattern, totalPattern);
set(handles.patternListInfo, 'string',str );
guidata(handles.predefinedPatternList, handles);


% --- Executes on button press in loadMetamorphRegion.
function loadMetamorphRegion_Callback(hObject, eventdata, handles)
% hObject    handle to loadMetamorphRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
if spinTIRFData.load_fitResult_PA
    fittedmodel_xv = spinTIRFData.fitResult_PA{1};
    fittedmodel_yv = spinTIRFData.fitResult_PA{2};
else
    msgbox('Load fitting result for PA first!!');
    return;
end
[filename, filepath, ~] = uigetfile({'*.rgn'},'Load pattern');

prompt = {'Put a name for your pattern:','Camera Size_Width:', 'Camera Size_Height:'};
dlg_title = 'Input region information';
num_lines = 1;
defaultans = {'Pattern_1','1024', '1024'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
patternName = answer{1};
cameraSizeWidth = str2double(answer{2});
cameraSizeHeight = str2double(answer{3});
patternData = parseMetaRgn(fullfile(filepath, filename), [cameraSizeWidth cameraSizeHeight]);
patternDataVolts = [fittedmodel_xv(patternData(:, 1), patternData(:, 2)),...
        fittedmodel_yv(patternData(:, 1), patternData(:, 2))];
spinTIRFData.preDefinedPattern...
    = setfield (spinTIRFData.preDefinedPattern, patternName, patternDataVolts );
set(handles.predefinedPatternList, 'string', fieldnames(spinTIRFData.preDefinedPattern));
set(handles.predefinedPatternList, 'value', 1); 
set(handles.status, 'string', 'Pattern added!');
setappdata(gcf, 'spinTIRFData', spinTIRFData);
guidata(hObject, handles);

% --- Executes on selection change in scanVoltsSettings.
function scanVoltsSettings_Callback(hObject, eventdata, handles)
% hObject    handle to scanVoltsSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scanVoltsSettings contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scanVoltsSettings


% --- Executes during object creation, after setting all properties.
function scanVoltsSettings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanVoltsSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in assignFittingTo.
function assignFittingTo_Callback(hObject, eventdata, handles)
% hObject    handle to assignFittingTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns assignFittingTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from assignFittingTo


% --- Executes during object creation, after setting all properties.
function assignFittingTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to assignFittingTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PA_Manual_X_Callback(hObject, eventdata, handles)
% hObject    handle to PA_Manual_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PA_Manual_X as text
%        str2double(get(hObject,'String')) returns contents of PA_Manual_X as a double


% --- Executes during object creation, after setting all properties.
function PA_Manual_X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PA_Manual_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PA_Manual_Y_Callback(hObject, eventdata, handles)
% hObject    handle to PA_Manual_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PA_Manual_Y as text
%        str2double(get(hObject,'String')) returns contents of PA_Manual_Y as a double


% --- Executes during object creation, after setting all properties.
function PA_Manual_Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PA_Manual_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PA_ROI_Mode_Manual.
function PA_ROI_Mode_Manual_Callback(hObject, eventdata, handles)
% hObject    handle to PA_ROI_Mode_Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PA_ROI_Mode_Manual


% --------------------------------------------------------------------'
function SaveCurrentSetting_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCurrentSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spinTIRFData = getappdata(gcf, 'spinTIRFData');
[FileName,PathName,~] = uiputfile('*.mat','Save current settings', 'spinTIRF_Config.mat');
svFile = fullfile(PathName, FileName);
% spinTIRFData.CHsTab = [];
spinTIRFDataNew = struct('preDefinedPattern', spinTIRFData.preDefinedPattern, ...
                          'loadMicromanager', spinTIRFData.loadMicromanager, ...
                          'loadImageJ', spinTIRFData.loadImageJ, ...
                          'projectFolder', spinTIRFData.projectFolder, ...
                          'MAX_Chs_Num', spinTIRFData.MAX_Chs_Num, ...
                          'load_fitResult_spinTIRF', 0, ...
                          'load_fitResult_PA', 0, ...
                          'fitResult_spinTIRF', {spinTIRFData.fitResult_spinTIRF},...
                          'fitResult_PA', {spinTIRFData.fitResult_PA}, ...
                          'CH_ETL', spinTIRFData.CH_ETL);
                      
                      
spinTIRFData = spinTIRFDataNew;
save(svFile, 'spinTIRFData');
set(handles.status, 'string', 'Saved successfully!!');



function setThetaStart_Callback(hObject, eventdata, handles)
% hObject    handle to setThetaStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setThetaStart as text
%        str2double(get(hObject,'String')) returns contents of setThetaStart as a double

if str2double(get(hObject,'String'))<0 || str2double(get(hObject,'String'))>360
    set(hObject, 'String', '0');
    msgbox('angle should between 0-360');
end
if str2double(get(handles.n_samples, 'String')) == 1
    set(handles.setThetaEnd, 'String', get(hObject, 'String'));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function setThetaStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setThetaStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setThetaEnd_Callback(hObject, eventdata, handles)
% hObject    handle to setThetaEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setThetaEnd as text
%        str2double(get(hObject,'String')) returns contents of setThetaEnd as a double
if str2double(get(hObject,'String'))<0 || str2double(get(hObject,'String'))>360
    set(hObject, 'String', '0');
    msgbox('angle should between 0-360');
end
if str2double(get(handles.n_samples, 'String')) == 1
    set(handles.setThetaStart, 'String', get(hObject, 'String'));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setThetaEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setThetaEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
