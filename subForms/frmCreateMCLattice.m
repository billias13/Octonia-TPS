function varargout = frmCreateMCLattice(varargin)
% FRMCREATEMCLATTICE MATLAB code for frmCreateMCLattice.fig
%      FRMCREATEMCLATTICE, by itself, creates a new FRMCREATEMCLATTICE or raises the existing
%      singleton*.
%
%      H = FRMCREATEMCLATTICE returns the handle to a new FRMCREATEMCLATTICE or the handle to
%      the existing singleton*.
%
%      FRMCREATEMCLATTICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMCREATEMCLATTICE.M with the given input arguments.
%
%      FRMCREATEMCLATTICE('Property','Value',...) creates a new FRMCREATEMCLATTICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmCreateMCLattice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmCreateMCLattice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmCreateMCLattice

% Last Modified by GUIDE v2.5 10-Jan-2013 14:02:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmCreateMCLattice_OpeningFcn, ...
                   'gui_OutputFcn',  @frmCreateMCLattice_OutputFcn, ...
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


% --- Executes just before frmCreateMCLattice is made visible.
function frmCreateMCLattice_OpeningFcn(hObject, eventdata, handles, varargin)
    

% Choose default command line output for frmCreateMCLattice
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(0,'hCreateLatticeGui',gcf);
% UIWAIT makes frmCreateMCLattice wait for user response (see UIRESUME)
% uiwait(handles.hCreateLatticeForm);
set(handles.txtError,'Visible','Off');
set(handles.loadingBar,'Visible','off');
%set(handles.loadingText,'Color','none');
set(handles.loadingText,'Visible','off');
currentPatient = getV('currentPatient');
set(handles.hCreateLatticeForm, 'Name', ['Create Lattice for : ' currentPatient.patientName]);
%set(handles.txtPatientName,'String',currentPatient.patientName);
%set(gcf,'CurrentAxes',handles.axesCTScale);
%axis off;
set(handles.lstResolution,'String',['64 x 64 x ST  '; '128 x 128 x ST'; '256 x 256 x ST'; '512 x 512 x ST']);

    set(handles.btnLoadDefaultScale,'Enable','off');
    defaultCTScale = [-1000 0.001205; 0 1];
    setV('defaultCTScale',[-1000 0.001205; 0 1]);
    set(gcf,'CurrentAxes',handles.axesCTScale);
    plot(defaultCTScale(:,1),defaultCTScale(:,2));

% --- Outputs from this function are returned to the command line.
function varargout = frmCreateMCLattice_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txtPatientName_Callback(hObject, eventdata, handles)
% hObject    handle to txtPatientName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPatientName as text
%        str2double(get(hObject,'String')) returns contents of txtPatientName as a double


% --- Executes during object creation, after setting all properties.
function txtPatientName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPatientName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPatientID_Callback(hObject, eventdata, handles)
% hObject    handle to txtPatientID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPatientID as text
%        str2double(get(hObject,'String')) returns contents of txtPatientID as a double


% --- Executes during object creation, after setting all properties.
function txtPatientID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPatientID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstResolution.
function lstResolution_Callback(hObject, eventdata, handles)

get(hObject,'Value')


% --- Executes during object creation, after setting all properties.
function lstResolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtUsername_Callback(hObject, eventdata, handles)
% hObject    handle to txtUsername (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtUsername as text
%        str2double(get(hObject,'String')) returns contents of txtUsername as a double


% --- Executes during object creation, after setting all properties.
function txtUsername_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtUsername (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtFilename_Callback(hObject, eventdata, handles)
% hObject    handle to txtFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFilename as text
%        str2double(get(hObject,'String')) returns contents of txtFilename as a double


% --- Executes during object creation, after setting all properties.
function txtFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function txtNumOfPatricles_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.txtNumOfPatricles,'String'))
    set(handles.txtStatUncertainty,'Enable','Off');
else
    set(handles.txtStatUncertainty,'Enable','On');
end

% --- Executes during object creation, after setting all properties.
function txtNumOfPatricles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumOfPatricles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStatUncertainty_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.txtStatUncertainty,'String'))
    set(handles.txtNumOfPatricles,'Enable','Off');
else
    set(handles.txtNumOfPatricles,'Enable','On');
end

% --- Executes during object creation, after setting all properties.
function txtStatUncertainty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStatUncertainty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function hCreateLatticeForm_ButtonDownFcn(hObject, eventdata, handles)

function showError(handles, txt)
    set(handles.txtError,'String',txt);
    set(handles.txtError,'Visible','On');


% --- Executes on key press with focus on hCreateLatticeForm or any of its controls.
function hCreateLatticeForm_WindowKeyPressFcn(hObject, eventdata, handles)

set(handles.txtError,'Visible','Off');


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function hCreateLatticeForm_WindowButtonDownFcn(hObject, eventdata, handles)

set(handles.txtError,'Visible','Off');


% --- Executes on key press with focus on txtNumOfPatricles and none of its controls.
function txtNumOfPatricles_KeyPressFcn(hObject, eventdata, handles)
get(handles.txtNumOfPatricles,'String')
if ~isempty(get(handles.txtNumOfPatricles,'String'))
    set(handles.txtStatUncertainty,'Enable','Off');
else
    set(handles.txtStatUncertainty,'Enable','On');
end



% --- Executes on button press in btnCreateMCNPInputFile.
function btnCreateMCNPInputFile_Callback(hObject, eventdata, handles)

if isempty(get(handles.txtUsername,'String'))
    showError(handles,'Warning:  You must provide a username for the MCNP input file');
    return;
else 
    username = get(handles.txtUsername,'String');
end
if isempty(get(handles.txtFilename,'String'))
    showError(handles,'Warning:  You must provide a MCNP input filename');
    return;
else 
    filename = get(handles.txtFilename,'String');
end

try
    numofparticles = str2num(get(handles.txtNumOfPatricles,'String'));
    statUncertainty = str2num(get(handles.txtStatUncertainty,'String'));
    if (isempty(numofparticles) && isempty(statUncertainty))
        showError(handles,'Warning: No appropriate num of particles or statistical uncertainty has been provided');
        return;
    end
catch
    showError(handles,'Warning: No appropriate num of particles or statistical uncertainty has been provided');
    return;
end

%Select directory for storing MCNP input file
save_dir = uigetdir('','Please select a directory for the MCNP input file');
    if save_dir==0
        return;
    end
filename = [save_dir '\' filename];

            if    exist(filename, 'file')
                    choice = questdlg('Another file with the same name exists in the current directory', ...
                        'Create lattice input file', ...
                        'Overwrite','Cancel','Cancel');
                    % Handle response
                    switch choice
                        case 'Overwrite'
                            %Do nothing, and continue 
                        case 'Cancel'
                            %Else exit
                            return;
                    end 
            end



    
switch(get(handles.lstResolution,'Value'))
    case 0
        resolution = 64;
    case 1
        resolution = 128;
    case 2
        resolution = 256;
    case 3
        resolution = 512;
end

currentPatient = getV('currentPatient');
defaultCTScale = getV('defaultCTScale');
ctscale = defaultCTScale;
setptr(gcf,'watch');
latticeManager = LatticeManager(username, filename, resolution, numofparticles, handles.loadingBar, handles.loadingText);

%By default, uiwait will crash, since its waiting for a figure, but it will
%do the job of waiting for lattice handler to finish ;)

%try; uiwait(latticeManager); catch; end;
setptr(gcf,'arrow');
clear latticeManager;   
showError(handles,'Input file created. Closing form...');
pause(0.5);
close(getappdata(0,'hCreateLatticeGui'));



% --- Executes when user attempts to close hCreateLatticeForm.
function hCreateLatticeForm_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hCreateLatticeForm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in btnLoadCustomScale.
function btnLoadCustomScale_Callback(hObject, eventdata, handles)

    set(handles.btnLoadDefaultScale,'Enable','on');


% --- Executes on button press in btnLoadDefaultScale.
function btnLoadDefaultScale_Callback(hObject, eventdata, handles)

    set(handles.btnLoadDefaultScale,'Enable','off');
    defaultCTScale = [-1000 0.001205; 0 1];
    setV('defaultCTScale',[-1000 0.001205; 0 1]);
    set(gcf,'CurrentAxes',handles.axesCTScale);
    plot(defaultCTScale(:,1),defaultCTScale(:,2));


% --- Executes during object creation, after setting all properties.
function hCreateLatticeForm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCreateLatticeForm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
