function varargout = spinTIRF(varargin)
% SPINTIRF MATLAB code for spinTIRF.fig
%      SPINTIRF, by itself, creates a new SPINTIRF or raises the existing
%      singleton*.
%
%      H = SPINTIRF returns the handle to a new SPINTIRF or the handle to
%      the existing singleton*.
%
%      SPINTIRF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPINTIRF.M with the given input arguments.
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

% Last Modified by GUIDE v2.5 07-Jun-2016 16:02:08

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

spinTIRF_Config = load('spinTIRF_Config.mat');

handles.spinTIRF.preDefinedPattern = spinTIRF_Config.spinTIRF.preDefinedPattern;

preDefinedPatternNamelist = fieldnames(handles.spinTIRF.preDefinedPattern);
set(handles.predefinedPatternList, 'String', preDefinedPatternNamelist);

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
    [xv, yv] = index_to_volts(ind);
    x_volts = [x_volts xv];
    y_volts = [y_volts yv];
end

handles.spinTIRF.spinGridCSV.filename = filename;
handles.spinTIRF.spinGridCSV.pathname = pathname;
handles.spinTIRF.x_coord = x_coord;
handles.spinTIRF.y_coord = y_coord;
handles.spinTIRF.x_volts = x_volts;
handles.spinTIRF.y_volts = y_volts;
handles.spinTIRF.projectFolder = pathname;
set(handles.showCSVPath, 'string', fullfile(pathname, filename));
set(handles.status, 'string', 'Load CSV finished!');
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



function cam_center_x_Callback(hObject, eventdata, handles)
% hObject    handle to cam_center_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_center_x as text
%        str2double(get(hObject,'String')) returns contents of cam_center_x as a double


% --- Executes during object creation, after setting all properties.
function cam_center_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_center_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cam_center_y_Callback(hObject, eventdata, handles)
% hObject    handle to cam_center_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_center_y as text
%        str2double(get(hObject,'String')) returns contents of cam_center_y as a double


% --- Executes during object creation, after setting all properties.
function cam_center_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_center_y (see GCBO)
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
pix_per_um = str2double(get(handles.pix_per_um, 'String'));

centerx = str2double(get(handles.cam_center_x, 'String'));
centery = str2double(get(handles.cam_center_y, 'String'));
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
    pattern_folder = handles.spinTIRF.projectFolder;   
else
    pattern_folder = uigetdir(handles.spinTIRF.spinGridCSV.pathname);
end

switch get(handles.way2definepattern, 'value')
    case 1
        handles.spinTIRF.patternfile = cell(length(radius_um), 1);
        
        ii = 0;
        for i_radius_um = radius_um
            i_radius_pix = i_radius_um * pix_per_um;
            xp = [];
            yp = [];

            for n = 0 : samples-1
                xp = [xp cos(step*n)*i_radius_pix+centerx];
                yp = [yp -sin(step*n)*i_radius_pix+centery];
            end

            outfile = ['r_', num2str(i_radius_um),'um_s_', num2str(samples), '.csv'];
            outfile = fullfile(pattern_folder, outfile);
            csvwrite(outfile, [xp.' yp.']);
            ii = ii+1;
            handles.spinTIRF.patternfile{ii} = outfile;
        end
    case 2
        xp = handles.MMROI.pixList(:, 2);
        yp = handles.MMROI.pixList(:, 1);
        outfile = fullfile(pattern_folder, 'MMROI.csv');
         handles.spinTIRF.patternfile{1} = 'MMROI.csv';
        csvwrite(outfile, [xp yp]);
end

handles.spinTIRF.pattern_folder = pattern_folder;
handles.spinTIRF.radius_um = radius_um;
disp('Define pattern, finished!');
set(handles.status, 'string', 'Define pattern, finished!');
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
guidata(hObject, handles);


% --- Executes on button press in fitSurfaceDoit.
function fitSurfaceDoit_Callback(hObject, eventdata, handles)
% hObject    handle to fitSurfaceDoit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x_coord = handles.spinTIRF.x_coord;
y_coord = handles.spinTIRF.y_coord;
x_volts = handles.spinTIRF.x_volts;
y_volts = handles.spinTIRF.y_volts;

[fitresult, gof] = createSurfaceFits(x_coord, y_coord, x_volts, y_volts);

handles.spinTIRF.fitResult = fitresult;
handles.spinTIRF.gof       = gof;

disp('Fit surface, finished!');
set(handles.status, 'string', 'Fit surface, finished!');
guidata(hObject, handles);

% --- Executes on button press in generateVoltsDoit.
function generateVoltsDoit_Callback(hObject, eventdata, handles)
% hObject    handle to generateVoltsDoit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fittedmodel_xv = handles.spinTIRF.fitResult{1};
fittedmodel_yv = handles.spinTIRF.fitResult{2};

for i = 1 : length(handles.spinTIRF.patternfile)
    
    i_pattern_file = handles.spinTIRF.patternfile{i};
    
    prefix = i_pattern_file(1:end-4);
%     prefix = './r_300um_s_250';
    
    pixels = csvread(i_pattern_file);

    output = [];
    for n = 1 : length(pixels)
        volt = [fittedmodel_xv(pixels(n, 1), pixels(n, 2)), ...
                fittedmodel_yv(pixels(n, 1), pixels(n, 2))];
        output = [output;volt];
    end

    outfile = [prefix '_v.csv'];
    csvwrite(outfile, output);
end
% save all various
spinTIRF_result = handles.spinTIRF;
savefile = fullfile(handles.spinTIRF.pattern_folder, 'spinTIRF_result.mat');
save(savefile, 'spinTIRF_result');
disp('Generate volts, finished!');
set(handles.status, 'string', 'Generate volts, finished!');
guidata(hObject, handles);


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
    [FileName,PathName] = uigetfile({'*.roi'},'ROI (*.roi)', handles.spinTIRF.spinGridCSV.pathname);
catch
    [FileName,PathName] = uigetfile({'*.roi'},'ROI (*.roi)');
end
handles.spinTIRF.MMROI.pathname = PathName;
handles.spinTIRF.MMROI.filename = FileName;
sROI = ReadImageJROI(fullfile(PathName, FileName));

cameraWidth = 2*str2double(get(handles.cam_center_x, 'string'));
cameraHeight = 2*str2double(get(handles.cam_center_y, 'string'));
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

% Hints: contents = cellstr(get(hObject,'String')) returns predefinedPatternList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from predefinedPatternList


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
n_chs = get(handles.n_Chs, 'value') - 1;
CHs = cell(n_chs, 1);
for i = 1 : n_chs
    CHs{i} =  struct('n_samples', [], 'exposure', [],...
                'nspinperexp', [], 'rate', [], 'volts', []);
end
switch n_chs
    case 1
        set(handles.ch1_panel, 'visible', 'on');
    case 2
        set(handles.ch1_panel, 'visible', 'on');
        set(handles.ch2_panel, 'visible', 'on');
end
handles.spinTIRF.ChannelSetting = CHs;

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
[finename, filepath, fillteridx] = uigetfile({'*.mat';'*.xlsx', '*.xls', '*.csv'},'Load pattern');

switch filteridx
    case 0
        msgbox('User selection cancled!');
        return;
    case 1
        loadMat = load(fullfile(filepath, filename));
        pattern = loadMat.pattern;
    case 2
        loadExcel = xlsread(fullfile(filepath, filename));
        pattern = loadExcel;
end
x = inputdlg('Put a name for your pattern:',...
             'Set pattern name', [1 50]);
patternName = x{:};

currentPatternList = get(handles.predefinedPatternList, 'string');
currentPatternList = [currentPatternList patternName];
set(handles.predefinedPatternList, 'string', currentPatternList);
handles.spinTIRF.preDefinedPattern(patternName) = pattern;

guidata(hObject, handles);

% --- Executes on button press in addSavePattern.
function addSavePattern_Callback(hObject, eventdata, handles)
% hObject    handle to addSavePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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


% --- Executes on button press in ch2_getPattern.
function ch2_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch2_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = handles.spinTIRF.preDefinedPattern.(patternName);
handles.spinTIRF.ChannelSetting{2}.volts = pattern;
handles.spinTIRF.ChannelSetting{2}.getPatternDone = 1;
guidata(hObject, handles);


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
function ch1_getPattern_Callback(hObject, eventdata, handles)
% hObject    handle to ch1_getPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
content = get(handles.predefinedPatternList, 'String');
patternName = content{get(handles.predefinedPatternList, 'Value')};

pattern = handles.spinTIRF.preDefinedPattern.(patternName);
handles.spinTIRF.ChannelSetting{1}.volts = pattern;
handles.spinTIRF.ChannelSetting{1}.getPatternDone = 1;
guidata(hObject, handles);

% --- Executes on button press in configureNI.
function configureNI_Callback(hObject, eventdata, handles)
% hObject    handle to configureNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% make sure pattern has been get
n_chs = get(handles.n_Chs, 'value') - 1;
check = 1;
for iCh = 1 : n_chs
    if ~isfield(handles.spinTIRF.ChannelSetting{iCh}, 'getPatternDone')
        check = 0;
    end
end
if ~check
    msgbox('Get pattern for each channle first!!');
    return;
end
% create a data acquisition session
S = daq.createSession('ni');

switch get(handles.pickGalvo, 'value') % 'TIRF' galvo
    case 1
    % add a analog output channel
    ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao0', 'Voltage'); 
    ch_ao0.Range = [-10.0 10.0];

    ch_ao1 = addAnalogOutputChannel(S, 'Dev1', 'ao1', 'Voltage'); 
    ch_ao1.Range = [-10.0 10.0];
    case 2
        % add a analog output channel
    ch_ao2 = addAnalogOutputChannel(S, 'Dev1', 'ao2', 'Voltage'); 
    ch_ao2.Range = [-10.0 10.0];

    ch_ao3 = addAnalogOutputChannel(S, 'Dev1', 'ao3', 'Voltage'); 
    ch_ao3.Range = [-10.0 10.0];
end

% setup trigger source
addTriggerConnection(S, 'External', 'Dev1/PFI8', 'StartTrigger');
S.Connections(1).TriggerCondition = 'RisingEdge';
% S.Connections(2).TriggerCondition = 'RisingEdge';


for iCh = 1 : n_chs
    switch iCh
        case 1
            n_samples = size(handles.spinTIRF.ChannelSetting{1}.volts, 1);
            exposure  = str2double(get(handles.ch1_exp, 'string'));
            nspinperexp = str2double(get(handles.ch1_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));  
            
            handles.spinTIRF.ChannelSetting{1}.n_samples = n_samples;
            handles.spinTIRF.ChannelSetting{1}.exposure = exposure;
            handles.spinTIRF.ChannelSetting{1}.nspinperexp = nspinperexp;
            handles.spinTIRF.ChannelSetting{1}.rate = rate;

        case 2
            n_samples = size(handles.spinTIRF.ChannelSetting{2}.volts, 1);
            exposure  = str2double(get(handles.ch2_exp, 'string'));
            nspinperexp = str2double(get(handles.ch2_nspinperexp, 'string'));
            rate = round(n_samples*nspinperexp/(exposure/1000));    
            
            handles.spinTIRF.ChannelSetting{2}.n_samples = n_samples;
            handles.spinTIRF.ChannelSetting{2}.exposure = exposure;
            handles.spinTIRF.ChannelSetting{2}.nspinperexp = nspinperexp;
            handles.spinTIRF.ChannelSetting{2}.rate = rate;
    end
end
handles.spinTIRF.S = S;
set(handles.status, 'String', 'Set NI successfully!!!');

%% RUN ni
set(handles.status, 'String', 'Start NI!!!');
handles.spinTIRF.N_frames = str2double(get(handles.n_turns, 'string'));
n_chs = get(handles.n_Chs, 'value') - 1;

volts = cell(n_chs, 1);
rates = cell(n_chs, 1);
nspinperexp = cell(n_chs, 1);
for iCh = 1 : n_chs
    volts{iCh} = handles.spinTIRF.ChannelSetting{iCh}.volts;
    rates{iCh} = handles.spinTIRF.ChannelSetting{iCh}.rate;
    nspinperexp{iCh} = handles.spinTIRF.ChannelSetting{iCh}.nspinperexp;
end


for iFrame = 1 : handles.spinTIRF.N_frames
    for iCh = 1 : n_chs     
        queueOutputData(S, repmat(volts{iCh}, nspinperexp{iCh}, 1));
        S.Rate = rates{iCh};
        S.startBackground();
        wait(S)       
    end
end
set(handles.status, 'string', 'NI Ended!');
release(S);
%%
guidata(hObject,handles);

% --- Executes on button press in runNI.
function runNI_Callback(hObject, eventdata, handles)
% hObject    handle to runNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runNI

% --- Executes on selection change in pickGalvo.
function pickGalvo_Callback(hObject, eventdata, handles)
% hObject    handle to pickGalvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pickGalvo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pickGalvo


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
[FileName,PathName] = uigetfile('*.tif','Load Image Sequence','MultiSelect','on');
handles.spinTIRF.laserImage.pathName = PathName;
handles.spinTIRF.laserImage.fileName = FileName;
if isequal(FileName,0)
   errordlg('User selected Cancel !!','Operation Error');
   return;
end
if ~iscell(FileName)
    errordlg('You Should Choose at lease Two Files !!','Operation Error');
    return;
end
FileName = sort(FileName);
totalFrames = length(FileName);
FileInfo = imfinfo([PathName FileName{1}]);
imgWidth = FileInfo(1).Width; 
imgHeight = FileInfo(1).Height; 
handles.spinTIRF.laserImg = zeros(imgHeight, imgWidth, totalFrames);
h = waitbar(0,['Loading Image Fragment 0 , please wait...']);
for i=1:length(FileName)
    waitbar(i/length(FileName),h,['Loading Image Fragment '  num2str(i) ' , please wait...']);
    handles.spinTIRF.laserImg(:,:,i)=imread([PathName FileName{i}]);         
end
close(h);
handles.spinTIRF.laserImgAvg = max(handles.spinTIRF.laserImg, [], 3);
handles.spinTIRF.projectFolder = PathName;
guidata(hObject, handles);


% --- Executes on button press in findCentroid.
function findCentroid_Callback(hObject, eventdata, handles)
% hObject    handle to findCentroid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BW  = atrous(handles.spinTIRF.laserImg,0,1,5,4);
calibration = [];
constrains = struct('eliminateEdgeFlag',1,'areaMin',5,'areaMax',100);
handles.spinTIRF.laserImgPosition = getMovieInfo(single(handles.spinTIRF.laserImg),single(BW),constrains,calibration);

keepIdx = [];
positionList = [];
for i= 1: length(handles.spinTIRF.laserImgPosition)
    if ~isempty(handles.spinTIRF.laserImgPosition(i).xCoord) && size(handles.spinTIRF.laserImgPosition(i).xCoord, 1) == 1
        keepIdx = cat(1, keepIdx, i);
        xp = handles.spinTIRF.laserImgPosition(i).xCoord(1, 1);
        yp = handles.spinTIRF.laserImgPosition(i).yCoord(1, 1);
        positionList = cat(1, positionList, [xp yp]);
    end
end
[xv, yv] = index_to_volts(keepIdx);
handles.spinTIRF.laserPos = cat(2, xv, yv, positionList);
handles.spinTIRF.x_coord = positionList(:, 1);
handles.spinTIRF.y_coord = positionList(:, 2);
handles.spinTIRF.x_volts = xv;
handles.spinTIRF.y_volts = yv;

figure; imagesc(handles.spinTIRF.laserImgAvg); colormap(gray); hold on; scatter(positionList(:, 1), positionList(:, 2), 'MarkerEdgeColor',[1 0 0]); hold off;
guidata(hObject, handles);


% --- Executes on button press in removePattern.
function removePattern_Callback(hObject, eventdata, handles)
% hObject    handle to removePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
