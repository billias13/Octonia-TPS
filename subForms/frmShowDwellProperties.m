function varargout = frmShowDwellProperties(varargin)
% FRMSHOWDWELLPROPERTIES MATLAB code for frmShowDwellProperties.fig
%      FRMSHOWDWELLPROPERTIES, by itself, creates a new FRMSHOWDWELLPROPERTIES or raises the existing
%      singleton*.
%
%      H = FRMSHOWDWELLPROPERTIES returns the handle to a new FRMSHOWDWELLPROPERTIES or the handle to
%      the existing singleton*.
%
%      FRMSHOWDWELLPROPERTIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMSHOWDWELLPROPERTIES.M with the given input arguments.
%
%      FRMSHOWDWELLPROPERTIES('Property','Value',...) creates a new FRMSHOWDWELLPROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmShowDwellProperties_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmShowDwellProperties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmShowDwellProperties

% Last Modified by GUIDE v2.5 25-Jan-2013 08:50:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmShowDwellProperties_OpeningFcn, ...
                   'gui_OutputFcn',  @frmShowDwellProperties_OutputFcn, ...
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


% --- Executes just before frmShowDwellProperties is made visible.
function frmShowDwellProperties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmShowDwellProperties (see VARARGIN)

% Choose default command line output for frmShowDwellProperties
handles.output = hObject;
 
    if getV('showDwell')
           value = 1.0;
    else
           value = 0.0;
    end
    set(handles.chkShowDwellPositions,'Value',value);
    
currentPatient = getV('currentPatient');

fnames = fieldnames(currentPatient.dwellPositionManager.dwellPositionsInfo);
for i=1:numel(fnames)
    showDwellinfoMatrix{i,1} = fnames{i};
    dnames = fieldnames(currentPatient.dwellPositionManager.dwellPositionsInfo.(fnames{i}));
    jj = 2;
    for j=1:currentPatient.dwellPositionManager.dwellPositionsInfo.(fnames{i}).NumberOfDwellPositions
        if currentPatient.dwellPositionManager.dwellPositionsInfo.(fnames{i}).(strcat('dwell',int2str(j))).IrradiationTime ~= 0
            showDwellinfoMatrix{i,jj} = currentPatient.dwellPositionManager.dwellPositionsInfo.(fnames{i}).(strcat('dwell',int2str(j))).IrradiationTime;
            jj = jj + 1;
        end
    end
end
columnsNames{1} = '';
for i=2:size(showDwellinfoMatrix,2)
    columnsNames{i} = strcat('dwell',sprintf('%g',i-1),' (s)');
end

set(handles.Dwellinfo,'Data',showDwellinfoMatrix,'ColumnFormat',{'short'},'ColumnName',columnsNames)

dwellMarkerProperties = getV('dwellMarkerProperties');

set(handles.dwellMarkerSize,'String',num2str(dwellMarkerProperties.Size));

set(handles.dwellMarkerColor,'BackgroundColor',dwellMarkerProperties.Color,...
                             'ForegroundColor',dwellMarkerProperties.Color);
             

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes frmShowDwellProperties wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = frmShowDwellProperties_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chkShowDwellPositions.
function chkShowDwellPositions_Callback(hObject, eventdata, handles)

    if get(hObject,'Value')
        state = 'on';
    else
        state = 'off';
    end
    
    setV('showDwell',get(hObject,'Value'));
    %Update main gui
    try
        h = getappdata(0,'hMainGui');
        set(0,'CurrentFigure',h);
        handlesMain = guidata(h);
        set(handlesMain.showDwell, 'Checked', state);
        updateViewer(handlesMain);
    catch end


% --- Executes on button press in dwellMarkerColor.
function dwellMarkerColor_Callback(hObject, eventdata, handles)

  color = uisetcolor();
    try
        uiwait(c);
    catch end
     if color==0; return; end;
     set(hObject,'BackgroundColor',color,...
                 'ForegroundColor',color);
     
     dwellMarkerProperties = getV('dwellMarkerProperties');
     dwellMarkerProperties.Color = color;
     setV('dwellMarkerProperties',dwellMarkerProperties);
%     
        %Update main gui
        try
            h = getappdata(0,'hMainGui');
            set(0,'CurrentFigure',h);
            handlesMain = guidata(h);
            updateViewer(handlesMain);
        catch end
        
        
        

function dwellMarkerSize_Callback(hObject, eventdata, handles)

dwellMarkerProperties = getV('dwellMarkerProperties');
        [newMarkerSize, status] = str2num(get(hObject,'String'));
        if status==0
            set(hObject,'String',num2str(dwellMarkerProperties.Size));
        else
                h = getappdata(0,'hMainGui');
                set(0,'CurrentFigure',h);
                handlesMain = guidata(h);
                dwellMarkerProperties.Size = newMarkerSize;
                setV('dwellMarkerProperties',dwellMarkerProperties);
                updateViewer(handlesMain);
        end


% --- Executes during object creation, after setting all properties.
function dwellMarkerSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwellMarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
