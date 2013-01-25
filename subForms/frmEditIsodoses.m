function varargout = frmEditIsodoses(varargin)
% FRMEDITISODOSES MATLAB code for frmEditIsodoses.fig
%      FRMEDITISODOSES, by itself, creates a new FRMEDITISODOSES or raises the existing
%      singleton*.
%
%      H = FRMEDITISODOSES returns the handle to a new FRMEDITISODOSES or the handle to
%      the existing singleton*.
%
%      FRMEDITISODOSES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMEDITISODOSES.M with the given input arguments.
%
%      FRMEDITISODOSES('Property','Value',...) creates a new FRMEDITISODOSES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmEditIsodoses_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmEditIsodoses_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmEditIsodoses

% Last Modified by GUIDE v2.5 22-Jan-2013 16:41:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmEditIsodoses_OpeningFcn, ...
                   'gui_OutputFcn',  @frmEditIsodoses_OutputFcn, ...
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


% --- Executes just before frmEditIsodoses is made visible.
function frmEditIsodoses_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmEditIsodoses (see VARARGIN)

% Choose default command line output for frmEditIsodoses
handles.output = hObject;

    if getV('showIsodoses')
           value = 1.0;
    else
           value = 0.0;
    end
    set(handles.ckbShowIsodoses,'Value',value);



isodoseProperties = getV('isodoseProperties');

Po =-12;

for i=1:10
        btnShowHide = uicontrol('Style','checkbox',...
                                'Units','pixels',...
                                'Position', [5 (i*25)-15 15 30],...
                                'Min',0,'Max',1,...
                                'Value',isodoseProperties.Status(i),...
                                'Callback',{@showHideIsodose,i});
                            
        btnChangeColor = uicontrol('Style','pushbutton',...
                                   'BackgroundColor',isodoseProperties.Color(i,:),...
                                   'Units','pixels',...
                                   'Position', [20 (i*25)+Po  50 25],...
                                   'Callback',{@changeColorBtn_Callback,i});
                       
        btnIsodoseValue = uicontrol('Style','edit','String',num2str(isodoseProperties.Value(i)),...
                                'Units','pixels',...
                                'Position', [70 (i*25)+Po 75 24],'fontsize',10,...
                                'Callback',{@changeIsodoseLevel_Callback,i});
                            
        btnIsodoseValue = uicontrol('Style','edit','String',num2str(isodoseProperties.LineThickness(i)),...
                                'Units','pixels',...
                                'Position', [145 (i*25)+Po 50 24],'fontsize',10,...
                                'Callback',{@changeLineThickness_Callback,i});       
                            
                
      
end


% Update handles structure
guidata(hObject, handles);



% UIWAIT makes frmEditIsodoses wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function changeColorBtn_Callback(hObject, evt,  isodoseID) %panel,
     color = uisetcolor();
    try
        uiwait(c);
    catch end
    if color==0; return; end;
     set(hObject,'BackgroundColor',color,...
                 'ForegroundColor',color);
     
     isodoseProperties = getV('isodoseProperties');
     isodoseProperties.Color(isodoseID,:) = color;
     setV('isodoseProperties',isodoseProperties);
%     
        %Update main gui
        try
            h = getappdata(0,'hMainGui');
            set(0,'CurrentFigure',h);
            handlesMain = guidata(h);
            updateIsodosePlotInfo(h,handlesMain);
            updateViewer(handlesMain);
        catch end

        
function showHideIsodose(hObject,eventdata, isodoseID)

    if get(hObject,'Value')
        state = 'on';
    else
        state = 'off';
    end
    
    isodoseProperties = getV('isodoseProperties');
    isodoseProperties.Status(isodoseID) = get(hObject,'Value');
    setV('isodoseProperties',isodoseProperties);
    
    %Update main gui
    try
        h = getappdata(0,'hMainGui');
        set(0,'CurrentFigure',h);
        handlesMain = guidata(h);
        updateIsodosePlotInfo(h,handlesMain);
        updateViewer(handlesMain);
    catch end
    
    
    
 function changeIsodoseLevel_Callback(hObject,eventdata, isodoseID)
       
      
        isodoseProperties = getV('isodoseProperties');
        [newIsodoseLevel, status] = str2num(get(hObject,'String'));
        if status==0
            set(hObject,'String',num2str(isodoseProperties.Value(isodoseID)));
        else
                h = getappdata(0,'hMainGui');
                set(0,'CurrentFigure',h);
                handlesMain = guidata(h);
                isodoseProperties.Value(isodoseID) = newIsodoseLevel;
                setV('isodoseProperties',isodoseProperties);
                updateIsodosePlotInfo(h,handlesMain);
                updateViewer(handlesMain);
        end
        
    
    
function changeLineThickness_Callback(hObject,eventdata, isodoseID)
       
      
        isodoseProperties = getV('isodoseProperties');
        [newLineThickness, status] = str2num(get(hObject,'String'));
        if status==0
            set(hObject,'String',num2str(isodoseProperties.LineThickness(isodoseID)));
        else
                h = getappdata(0,'hMainGui');
                set(0,'CurrentFigure',h);
                handlesMain = guidata(h);
                isodoseProperties.LineThickness(isodoseID) = newLineThickness;
                setV('isodoseProperties',isodoseProperties);
                updateViewer(handlesMain);
        end
        
        
        
    
    
% --- Outputs from this function are returned to the command line.
function varargout = frmEditIsodoses_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ckbShowIsodoses.
function ckbShowIsodoses_Callback(hObject, eventdata, handles)

    if get(hObject,'Value')
        state = 'on';
    else
        state = 'off';
    end
    setV('showIsodoses', get(hObject,'Value'));
    
    %Update main gui
    try
        h = getappdata(0,'hMainGui');
        set(0,'CurrentFigure',h);
        handlesMain = guidata(h);
        set(handlesMain.showIsodoses, 'Checked', state);
        updateIsodosePlotInfo(h,handlesMain);
        updateViewer(handlesMain);
    catch end
    
   
%Direct copy of the same function that exists in the mainGui. This function
%updates the legent containing isodoses, depending on color, value and
%visibility.
function updateIsodosePlotInfo(hObject,handles)
   %read isodose properties (updated through frmEditIsodoses)
    showIsodoses = getV('showIsodoses');

   % if getV('showIsodoses')
    isodoseProperties = getV('isodoseProperties');
    visibleIsodoses = 0;
        for i=10:-1:1
            if isodoseProperties.Status(i)*getV('showIsodoses')
                visibleIsodoses = visibleIsodoses + 1; 
                color = [isodoseProperties.Color(i,1) isodoseProperties.Color(i,2) isodoseProperties.Color(i,3)];
                set(handles.isodoseLabel(i),'Position',[660 705 - (visibleIsodoses*20) 45 20]);
                set(handles.isodoseLabel(i),'ForegroundColor',color);
                set(handles.isodoseLabel(i),'Visible','on');
                set(handles.isodoseLabel(i), 'String', isodoseProperties.Value(i));
            else
                set(handles.isodoseLabel(i),'Visible','off');
            end
        end
        
    %end
    guidata(hObject, handles);
