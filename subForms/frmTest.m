function varargout = frmTest(varargin)
% FRMTEST M-file for frmTest.fig
%      FRMTEST, by itself, creates a new FRMTEST or raises the existing
%      singleton*.
%
%      H = FRMTEST returns the handle to a new FRMTEST or the handle to
%      the existing singleton*.
%
%      FRMTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMTEST.M with the given input arguments.
%
%      FRMTEST('Property','Value',...) creates a new FRMTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmTest

% Last Modified by GUIDE v2.5 04-Nov-2012 23:32:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmTest_OpeningFcn, ...
                   'gui_OutputFcn',  @frmTest_OutputFcn, ...
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


% --- Executes just before frmTest is made visible.
function frmTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmTest (see VARARGIN)
   setappdata(0,'hTestGui',gcf);
   ak = actionKeeper(handles.txtTest);
   setappdata(getappdata(0,'hTestGui'),'actionKeeper',ak);
   

% Choose default command line output for frmTest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes frmTest wait for user response (see UIRESUME)
% uiwait(handles.frmTest);


% --- Outputs from this function are returned to the command line.
function varargout = frmTest_OutputFcn(hObject, eventdata, handles) 
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

    ac = {'crop','test',1,'tes12332132132t'};
    
    h = getappdata(0,'hTestGui');
    ak = getappdata(h,'actionKeeper');
    ak.addAction(ac);
    setappdata(h,'actionKeeper',ak);
