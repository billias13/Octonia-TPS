function varargout = frmEditVOIs2(varargin)
% FRMEDITVOIS2 MATLAB code for frmEditVOIs2.fig
%      FRMEDITVOIS2, by itself, creates a new FRMEDITVOIS2 or raises the existing
%      singleton*.
%
%      H = FRMEDITVOIS2 returns the handle to a new FRMEDITVOIS2 or the handle to
%      the existing singleton*.
%
%      FRMEDITVOIS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMEDITVOIS2.M with the given input arguments.
%
%      FRMEDITVOIS2('Property','Value',...) creates a new FRMEDITVOIS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmEditVOIs2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmEditVOIs2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmEditVOIs2

% Last Modified by GUIDE v2.5 15-Jan-2013 18:29:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmEditVOIs2_OpeningFcn, ...
                   'gui_OutputFcn',  @frmEditVOIs2_OutputFcn, ...
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


% --- Executes just before frmEditVOIs2 is made visible.
function frmEditVOIs2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmEditVOIs2 (see VARARGIN)


% Choose default command line output for frmEditVOIs2
handles.output = hObject;

c = getV('currentPatient');

%c.contourManager.numOfVOIs = 10;
%Read the total number of vois to be added
handles.totalNumOfVois = c.contourManager.numOfVOIs;
handles.numOfVois = 0;

%Set the heigh of each voi subpanel
handles.subPanelHeight = 80;
handles.subPanelWidth = 251;
handles.scrollBarWidth = 20;
%Calculate the total heigh of all vois subpanels
handles.totalHeight = handles.totalNumOfVois*handles.subPanelHeight;

handles.headerHeight = 34;


%Find out if the total number of vois exceeds the current form heigh. if so
%add a scrollbar and a callback for the scroll bar, else create the form
%without scrollbar.
formSize = get(hObject,'Position');
formHeight = formSize(4) - handles.headerHeight;
handles.heightDifference = handles.totalHeight - formHeight;

if handles.heightDifference > 0
    
%If the height of total vois is larger than the height of the form, then add a
%scrollbar and se the position of the mainPanel(the panel that contains all
%vois subpanels) accordingly, so that the top will be aligned to the form
%top.
    handles.scrollBarIsEnabled = 1; %Flag that indicates the existence of scrollbar
    handles.leftMargin = handles.scrollBarWidth; %Left margin indicates the width of the scrollbar
    
    %Change the size of the form to fit the width of subpanel+scrollbar
    set(hObject,'Position', [formSize(1) formSize(2) formSize(3)+ handles.leftMargin formSize(4)]);

    % Create main panel aligned with the top of the form 
    handles.mainPanel = uipanel( 'BackgroundColor','white',...
                                 'Units','pixels',...
                                 'Position',[handles.leftMargin -handles.heightDifference 250 handles.totalHeight]);  
else
%Else if the height of total vois is smaller than the height of the form, 
%then resize the form to fit exactly the size of its contents.
    handles.scrollBarIsEnabled = 0;
    handles.leftMargin = 0;
    set(hObject,'Position', [formSize(1) formSize(2) formSize(3) handles.totalHeight]);
    
    % Create main panel aligned with the top of the form 
    handles.mainPanel = uipanel( 'BackgroundColor','white',...
                     'Units','pixels',...
                     'Position',[handles.leftMargin 0 250 handles.totalHeight]);  
end

  %Define the folder that holds gui icons
    iconsFolder = fullfile(pwd,'/img/');
    
    %Add custom icons to the gui buttons
    colorIconPath = strrep(['file:/' iconsFolder 'color26.png'],'\','/');
    colorIconUrl = ['<html><img src="' colorIconPath '"/></html>'];
   
    
for i = 1:handles.totalNumOfVois
    
    %%============================================ OLD VERSION =====================================================
    handles.numOfVois = handles.numOfVois + 1;
    color = c.contourManager.voisProperties(1,i).color/255;           
    %For each of the vois, create a subpanel containing all vois controls, and add it to the mainPanel.    
        subPanel = uipanel('Parent', handles.mainPanel,...
                           'BorderType','line',...
                           'HighlightColor','Black',...
                           'Units','pixels','Position',[0 handles.totalHeight  - i*handles.subPanelHeight 251 handles.subPanelHeight]...
                   );
        color = c.contourManager.voisProperties(i).color/255;
        colorPanel = uipanel('Parent', subPanel,'BackgroundColor',[color(1) color(2) color(3)],...
                           'BorderType','line',...
                           'HighlightColor','Black',...
                           'Units','pixels','Position',[80 10 60 60]...
                   );
          
               
       btnChangeColor = uicontrol('Parent', subPanel,'Style','pushbutton','String',colorIconUrl,...
                                   'Tag',num2str(handles.numOfVois),...
                                   'Units','pixels',...
                                   'Position', [149 40 30 30],...
                                   'Callback',{@changeColorBtn_Callback, colorPanel});  
                               
        if c.contourManager.voisProperties(i).visible
            btnShowHideString = 'On';
        else
            btnShowHideString = 'Off';            
        end
        btnShowHide = uicontrol('Parent',subPanel,'Style','togglebutton','String', btnShowHideString,...
                                'Units','pixels',...
                                'Position', [149 10 30 30],...
                                'Min',0,'Max',1,...
                                'Value',c.contourManager.voisProperties(i).visible,...
                                'Callback',{@showHideVOI,num2str(i)});
    
    %c.contourManager.voisProperties(i).name
    if length(c.contourManager.voisProperties(i).name)<=8
        lblPos =  [2 30 68 20];
    elseif length(c.contourManager.voisProperties(i).name)<=16
        lblPos =  [2 20 68 40];
    else
        lblPos =  [2 10 68 60];
    end
        lblVOIsName = uicontrol('Parent', subPanel, 'style','text','FontSize',11.0,'FontWeight','bold', 'String', c.contourManager.voisProperties(i).name,...
                                'Position', lblPos);
    %%============================================================================================================        
end

%If the flag scrollBarIsEnabled is true, then add a scrollbar and set its
%callback to move the mainPanel up and down
if handles.scrollBarIsEnabled
    handles.scrollBar = uicontrol('style','slider','Units','pixels','position',...
        [0 0 20 formHeight],'Min',1,'Max',handles.heightDifference,'Value',handles.heightDifference,...
        'Callback',{@moveMainPanel,handles.mainPanel, handles.heightDifference}); 
end



if handles.heightDifference > 0
    topPanelWidth = 269;
else
    topPanelWidth = 249;
end
   
    % Create main panel aligned with the top of the form 
    handles.topPanel = uipanel(  'BorderType','line',...
                                 'BackgroundColor','Blue',...
                                 'HighlightColor','Black',...
                                 'Units','pixels',...
                                 'Position',[2 402 topPanelWidth 36]);  
%      handles.lblShowHideAll = uicontrol('Parent', handles.topPanel, 'style','text','FontSize',12.0, 'String', 'Show/Hide all VOIs',...
%                                 'Position', [32 6 172 21]);
   if getV('showVOIS')
       btnShowHideAllVal = 1.0;
   else
       btnShowHideAllVal = 0.0;
   end
   %'Position', [0 0 topPanelWidth 36],...
     handles.btnShowHideAll = uicontrol('Parent',handles.topPanel,'Style','checkbox','String', 'Show/Hide all VOIs','FontSize',12.0,...
                                 'Units','pixels',...
                                'Position', [0 0 topPanelWidth 36],...
                                'Value',btnShowHideAllVal,...
                                'Callback',{@showHideAllVOIs});


%uistack(handles.topPanel,'top');

guidata(hObject, handles);
% UIWAIT makes frmEditVOIs2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

        
function moveMainPanel(src, eventdata, panel, heightDifference)
    
    val = get(src,'Value');
    maxVal = get(src,'Max');
    pos = get(panel,'Position');
    set(panel,'Position',[pos(1) -heightDifference + (maxVal - val) pos(3) pos(4)]);
    %uistack(handles.topPanel,'top');
    %uistack(src, 'bottom');
%guidata(src, handles);


% --- Outputs from this function are returned to the command line.
function varargout = frmEditVOIs2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function showHideAllVOIs(hObject,eventdata)
    c = getV('currentPatient');
    for i = 1:c.contourManager.numOfVOIs
        c.contourManager.voisProperties(i).visible = get(hObject,'Value');
    end
    setV('currentPatient',c);
    if get(hObject,'Value')
        state = 'on';
    else
        state = 'off';
    end
    setV('showVOIS', get(hObject,'Value'));
    
    %Update main gui
    try
        h = getappdata(0,'hMainGui');
        set(0,'CurrentFigure',h);
        handlesMain = guidata(h);
        set(handlesMain.showVOIS, 'Checked', state);
        updateViewer(handlesMain);
    catch end

    
    
    
function showHideVOI(hObject,eventdata, voiID)
    c = getV('currentPatient');
    if get(hObject,'Value')
       set(hObject,'String','On'); 
    else
       set(hObject,'String','Off'); 
    end
    c.contourManager.voisProperties(str2num(voiID)).visible = get(hObject,'Value');
    setV('currentPatient',c);
    disp(['Changing visibility status for voi with id :' voiID ' to :'  num2str(get(hObject,'Value'))]);
        %Update main gui
        try
            h = getappdata(0,'hMainGui');
            set(0,'CurrentFigure',h);
            handlesMain = guidata(h);
            updateViewer(handlesMain);
        catch end
    
function changeColorBtn_Callback(hObject, evt, panel)
    color = uisetcolor();
    try
        uiwait(c);
    catch
    end
    if color==0; return; end;
    disp(['Setting color of voi ' get(hObject,'Tag') ' to : (' num2str(color(1)) ',' num2str(color(2)) ',' num2str(color(3)) ')' ]);   
    set(panel,'BackgroundColor',color);
    c = getV('currentPatient');
    c.contourManager.voisProperties(str2num(get(hObject,'Tag'))).color = color*255;
    setV('currentPatient',c);
    
        %Update main gui
        try
            h = getappdata(0,'hMainGui');
            set(0,'CurrentFigure',h);
            handlesMain = guidata(h);
            updateViewer(handlesMain);
        catch end

%If scrollBarIsEnabled flag is enabled, then bind the mouse scroll to the
%scrollbar and manually change the position of the main panel, as if the
%scrollbar event was raised.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)

if handles.scrollBarIsEnabled
     if eventdata.VerticalScrollCount>0
        val = get(handles.scrollBar,'Value');
        if val-handles.subPanelHeight>= get(handles.scrollBar,'Min')
            set(handles.scrollBar,'Value',val-handles.subPanelHeight);   
        else
            set(handles.scrollBar,'Value',get(handles.scrollBar,'Min')); 
        end
     else
        val = get(handles.scrollBar,'Value');
        if val+handles.subPanelHeight<= get(handles.scrollBar,'Max')
            set(handles.scrollBar,'Value',val+handles.subPanelHeight);
        else
            set(handles.scrollBar,'Value',get(handles.scrollBar,'Max'));
        end
     end
     
      val = get(handles.scrollBar,'Value');
            maxVal = get(handles.scrollBar,'Max');
            pos = get(handles.mainPanel,'Position');
            set(handles.mainPanel,'Position',[pos(1) -handles.heightDifference + (maxVal - val) pos(3) pos(4)]);
     guidata(hObject, handles);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
