function initializeGui(handles)

    h = getappdata(0,'hMainGui');

     setappdata(h,'parentfolder',pwd);
     setappdata(h,'patientfiles','');
           
    %Set the data loaded flag to 0
    setappdata(h,'patientDataLoaded', 0);
    setappdata(h,'patientPlanLoaded', 0);
    %Enable/Disable debug mode
    setappdata(h,'DEBUG_MODE', 0);
    
    %Set initial orientation to Axial-Sagital-Coronal
    setappdata(h,'orientationMode', 'ASC');
    %Store the view that each axis shows, and update the legends accordingly
    setappdata(h,'currentTopView','Axial');       set(handles.TopLegent, 'String', 'Axial');
    setappdata(h,'currentBottomLView','Sagital'); set(handles.BottomLLegent, 'String', 'Sagital');
    setappdata(h,'currentBottomRView','Coronal'); set(handles.BottomRLegent, 'String', 'Coronal');

    set(handles.btnGroupOrientation,'SelectedObject',handles.btnASC);
    
    %Set initial cross position to something. It will refresh when patient
    %data are loaded
    crossPosition.x = 5;
    crossPosition.y = 5;
    crossPosition.z = 5;
    %Store cross position
    setappdata(h,'crossPosition',crossPosition);

    %Set current mouse position to 'form'
    setappdata(h,'currentMousePos','Form');

    %Set initial level
    setappdata(h,'Level',1000);
    setappdata(h,'InitialLevel',getappdata(h,'Level'));
    %Define and store level range
    LevelLimits.min = 0;
    LevelLimits.max = 3000;
    %Set level adjustment speed
    setappdata(h,'LevelAdjustSpeed',0.25);
    setappdata(h,'LevelLimits',LevelLimits);
    
    %Set initial window
    setappdata(h,'Window',300);
    setappdata(h,'InitialWindow',getappdata(h,'Window'));
    %Define and store window range
    WindowLimits.min = 100;
    WindowLimits.max = 500;
    %Set window adjustment speed
    setappdata(h,'WindowAdjustSpeed',0.25) ;
    setappdata(h,'WindowLimits',WindowLimits);
    %Deactivate window and level text boxes until data are loaded
    set(handles.txtWindowS,'Enable','inactive');
    set(handles.txtLevelS,'Enable','inactive');
    
    %Set default scroll action to slice traversing
    setappdata(h,'currentScrollAction','traverseSlices');
    
    %Remove ticks from axes
    set(handles.TopAxes,'xTick',[],'yTick',[]);
    set(handles.BottomLAxes,'xTick',[],'yTick',[]);
    set(handles.BottomRAxes,'xTick',[],'yTick',[]);
    
    %Calculate and store axes bounds;
    topBounds = get(handles.TopAxes,'position');
    bottomRBounds = get(handles.BottomRAxes,'position');
    bottomLBounds = get(handles.BottomLAxes,'position');
    setappdata(h,'TopAxesBounds',topBounds);
    setappdata(h,'BottomRAxesBounds',bottomRBounds);
    setappdata(h,'BottomLAxesBounds',bottomLBounds);   
    
    %Move gui to the centerscreen
    movegui(h,'center');
    
    
    
        %Define the folder that holds gui icons
    iconsFolder = fullfile(pwd,'/img/icons/');
    
    %Add custom icons to the gui buttons
    zoomIconPath = strrep(['file:/' iconsFolder 'zoom42.png'],'\','/');
    zoomIconUrl = ['<html><img src="' zoomIconPath '"/></html>'];
    set(handles.btnZoom, 'String',zoomIconUrl);
    
    adjustIconPath = strrep(['file:/' iconsFolder 'adjust42.png'],'\','/');
    adjustIconUrl = ['<html><img src="' adjustIconPath '"/></html>'];
    set(handles.btnAdjustLW,'String',adjustIconUrl);
   
    infoIconPath = strrep(['file:/' iconsFolder 'info42.png'],'\','/');
    infoIconUrl = ['<html><img src="' infoIconPath '"/></html>'];
    set(handles.btnInfo,'String',infoIconUrl); 
   
    cropIconPath = strrep(['file:/' iconsFolder 'crop42.png'],'\','/');
    cropIconUrl = ['<html><img src="' cropIconPath '"/></html>'];
    set(handles.btnCrop,'String',cropIconUrl); 
   
    snapIconPath = strrep(['file:/' iconsFolder 'snap42.png'],'\','/');
    snapIconUrl = ['<html><img src="' snapIconPath '"/></html>'];
    set(handles.btnSnapshot,'String',snapIconUrl); 
   
    measureIconPath = strrep(['file:/' iconsFolder 'measure42.png'],'\','/');
    measureIconUrl = ['<html><img src="' measureIconPath '"/></html>'];
    set(handles.btnMeasure,'String',measureIconUrl); 
    
    voisIconPath = strrep(['file:/' iconsFolder 'VOIs_button.png'],'\','/');
    voisIconUrl = ['<html><img src="' voisIconPath '"/></html>'];
    set(handles.btnEditVOIs,'String',voisIconUrl);
    
    editIsodosesIconPath = strrep(['file:/' iconsFolder 'btnEditIsodoses.png'],'\','/');
    editIsodosesIconUrl = ['<html><img src="' editIsodosesIconPath '"/></html>'];
    set(handles.btnEditIsodoses,'String',editIsodosesIconUrl);

    showDwellPropertiesIconPath = strrep(['file:/' iconsFolder 'btnShowDwellProperties.png'],'\','/');
    showDwellPropertiesIconUrl = ['<html><img src="' showDwellPropertiesIconPath '"/></html>'];
    set(handles.btnShowDwellProperties,'String',showDwellPropertiesIconUrl);

    
    
    %Define tooltip string for each gui element
    strZoom = '<html>Right click adjusts zoom levels<html>';
        set(handles.btnZoom,'ToolTipString',strZoom); 
    strLW = '<html>Right click adjusts level and width';
        set(handles.btnAdjustLW,'ToolTipString',strLW);
    strASC = '<html>Axial - Sagital - Coronal';
        set(handles.btnASC,'ToolTipString',strASC);
    strCAS = '<html>Coronal - Axial - Sagital';
        set(handles.btnCAS,'ToolTipString',strCAS);
    strSAC = '<html>Sagital - Axial - Coronal';
        set(handles.btnSAC,'ToolTipString',strSAC);
    strResetLevel = '<html>Reset level';
        set(handles.btnResetLevel,'ToolTipString',strResetLevel);
    strResetWindow = '<html>Reset window';
        set(handles.btnResetWindow,'ToolTipString',strResetWindow);
    
    
    % initialize default isodose line properties
    isodoseProperties.Color = jet(10);
    isodoseProperties.Status = ones(10,1);
    isodoseProperties.Value = (1:10)';
    isodoseProperties.LineThickness = ones(10,1);
    setV('isodoseProperties',isodoseProperties);
    
    
    % initialize default source dwell marker and color
    dwellMarkerProperties.Color = [0 0 1]; 
    dwellMarkerProperties.Size = 5;
    setV('dwellMarkerProperties',dwellMarkerProperties);
    
    
    
    clc;
end