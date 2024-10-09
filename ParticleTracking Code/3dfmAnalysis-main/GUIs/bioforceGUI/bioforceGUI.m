function varargout = bioforceGUI(varargin)
% BIOFORCEGUI M-file for bioforceGUI.fig
%      BIOFORCEGUI, by itself, creates a new BIOFORCEGUI or raises the existing
%      singleton*.
%
%      H = BIOFORCEGUI returns the handle to a new BIOFORCEGUI or the handle to
%      the existing singleton*.
%
%      BIOFORCEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIOFORCEGUI.M with the given input arguments.
%
%      BIOFORCEGUI('Property','Value',...) creates a new BIOFORCEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bioforceGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bioforceGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bioforceGUI

% Last Modified by GUIDE v2.5 28-Jun-2008 14:49:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bioforceGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @bioforceGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before bioforceGUI is made visible.
function bioforceGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bioforceGUI (see VARARGIN)

% Choose default command line output for bioforceGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bioforceGUI wait for user response (see UIRESUME)
% uiwait(handles.CISMM_BioforceGUI);


% --- Outputs from this function are returned to the command line.
function varargout = bioforceGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    


% --- Executes on button press in pushbutton_Select_Data_In_Box.
function pushbutton_Select_Data_In_Box_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Select_Data_In_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fig = str2num(get(handles.edit_ActiveFigure, 'String')); %#ok<ST2NM>
    
	[xout, yout, idx, serh] = select_data_in_box(fig);    
    
    handles.x = xout;
    handles.y = yout;
    handles.idx = idx;
    handles.serh = serh;
    
    assignin('base', 'xout', xout);
    assignin('base', 'yout', yout);
    
	guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_ActiveFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ActiveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_ActiveFigure_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ActiveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ActiveFigure as text
%        str2double(get(hObject,'String')) returns contents of edit_ActiveFigure as a double


% --- Executes on button press in pushbutton_relaxtime.
function pushbutton_relaxtime_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_relaxtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    x = handles.x;
    y = handles.y;
    n = str2num(get(handles.edit_num_modes, 'String'));

    [J,tau,R_square] = relaxation_time(x, y, n);

    set(handles.text_relaxtime, 'String', num2str(tau));
    set(handles.text_relaxtime_r2, 'String', num2str(R_square));


% --- Executes on button press in pushbutton_percent_recovery.
function pushbutton_percent_recovery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_percent_recovery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    x = handles.x;
    y = handles.y;
    
    [pr, xmax, xrec] = percent_recovery(y);

    set(handles.text_maximum_displacement, 'String', num2str(xmax));
    set(handles.text_recovered_displacement, 'String', num2str(xrec));
    set(handles.text_percent_recovery, 'String', num2str(pr));


% --- Executes on button press in pushbutton_slope.
function pushbutton_slope_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fig = get(handles.edit_ActiveFigure, 'String');
    fig = str2num(fig);
    
    x = handles.x;
    y = handles.y;

	fit  = polyfit(x, y, 1);
	fity = polyval(fit, x);
	err = uncertainty_in_linefit(x, y, fit);
 
	slope = fit(1);
	icept = fit(2);
    R2 = corrcoef(x, y);
    R2 = R2(1,2);
    
    set(handles.text_slope, 'String', num2str(slope));
    set(handles.text_slope_R2, 'String', num2str(R2));
    set(handles.text_lblR2_1, 'Visible', 'on');
    set(handles.text_lblR2_2, 'Visible', 'on');
    
    
    fprintf('\nStatistics\n');
	fprintf('x-range: %d \ny-range: %d \n', range(x), range(y));
	fprintf('slope = %g, icept = %g \n', slope, icept);
    fprintf('error in slope = %g, intercep = %g \n', err(1), err(2));
    fprintf('R = %g \n', R2);
    figure(fig);
    hold on;
	    plot(x, fity, 'r');
	hold off;

% --- Executes on button press in pushbutton_range.
function pushbutton_range_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fig = get(handles.edit_ActiveFigure, 'String');
    fig = str2num(fig);

    y = handles.y;
    
    set(handles.text_range, 'String', range(y));
    
    
	fprintf('y-range: %d \n', range(y));
    
%     figure(fig);
%     drawlines(gca, [], [], [], [min(y) max(y)], 'r')
    



function edit_num_modes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_num_modes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_num_modes as text
%        str2double(get(hObject,'String')) returns contents of edit_num_modes as a double


% --- Executes during object creation, after setting all properties.
function edit_num_modes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_modes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_relaxtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_relaxtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text_slope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_range.
function pushbutton_range_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_delete_selection.
function pushbutton_delete_selection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(handles.serh)
        serh = handles.serh;
        
        x = get(serh, 'XData');
        y = get(serh, 'YData');
        
        idx = handles.idx;

        x(idx) = [];
        y(idx) = [];

        set(serh, 'XData', x);
        set(serh, 'YData', y);
        
        handles.x = [];
        handles.y = [];
        handles.idx = [];
        guidata(hObject, handles);
        
        ax = get(serh, 'Parent');
        fig = get(ax, 'Parent');
        
        refresh(fig);
        
        logentry('Removed selected data.');
    else
        logentry('No data deleted.');
    end

    
function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'bioforcegui: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;