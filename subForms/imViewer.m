function varargout = imViewer(varargin)
% IMVIEWER M-file for imViewer.fig
%      IMVIEWER, by itself, creates a new IMVIEWER or raises the existing
%      singleton*.
%
%      H = IMVIEWER returns the handle to a new IMVIEWER or the handle to
%      the existing singleton*.
%
%      IMVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMVIEWER.M with the given input arguments.
%
%      IMVIEWER('Property','Value',...) creates a new IMVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imViewer

% Last Modified by GUIDE v2.5 24-Oct-2012 17:21:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @imViewer_OutputFcn, ...
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


% --- Executes just before imViewer is made visible.
function imViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imViewer (see VARARGIN)

% Choose default command line output for imViewer
handles.output = hObject;

setappdata(0,'imViewer',gcf);
hMainGui = getappdata(0,'hMainGui');
snapshot = getappdata(hMainGui,'snapshot');
level = getappdata(hMainGui,'Level');
window = getappdata(hMainGui,'Window');

    setappdata(gcf,'image',imagesc(snapshot));
    pbaspect([1 1 1]), colormap gray,caxis([level-(window/2)  level+(window/2)]);
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imsave( getappdata(gcf,'image'));
g = getappdata(0,'imViewer');
close(g);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g = getappdata(0,'imViewer');
close(g);
