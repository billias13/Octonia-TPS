function initSnap(handles)
        
   if getV('snapIsOn') ~= 1
  % try delete(handles.btnSaveSnap); delete(handles.btnCancelSnap); catch; end;
        set(gcf,'WindowScrollWheelFcn',@noCallbackMeasure);    
        
        currentAxesLimits = [get(gca,'XLim') get(gca,'YLim') get(gca,'ZLim')];
        rectMinX = (currentAxesLimits(2)-currentAxesLimits(1))*0.25;
        rectMaxX = (currentAxesLimits(2)-currentAxesLimits(1))*0.5;   
        rectMinY = (currentAxesLimits(4)-currentAxesLimits(3))*0.25;
        rectMaxY = (currentAxesLimits(4)-currentAxesLimits(3))*0.5;    
        
        handles.snapRectangle = imrect(gca, [rectMinX rectMinY rectMaxX rectMaxY]);
        
        setV('snapPos',[rectMinX rectMinY rectMaxX rectMaxY]);
        pos = [rectMinX rectMinY rectMaxX rectMaxY];
                    
        [btnPos(1) btnPos(2)] = axesToFormCoordinates(handles, pos(1), pos(2));
                 
        
        %Define the folder that holds gui icons
        iconsFolder = fullfile(pwd,'/img/icons/');

        %Add custom icons to the gui buttons
        camIconPath = strrep(['file:/' iconsFolder 'camera26.png'],'\','/');
        camIconUrl = ['<html><img src="' camIconPath '"/></html>'];
      
        handles.btnSaveSnap = uicontrol('Style','pushbutton','String',camIconUrl,...
            'Units','pixels',...
            'Position', [btnPos(1)+4 btnPos(2)-34 40 30],...
            'Callback',{@saveSnap_Callback, handles}); 
                                                   
%         handles.btnCancelSnap = uicontrol('Style','pushbutton','String','Cancel',...
%             'Units','pixels',...
%             'Position', [btnPos(1)+46 btnPos(2)-34 60 30],...
%             'Callback',{@cancelSnap_Callback, handles}); 
                                                   
        addNewPositionCallback(handles.snapRectangle,@(pos)snapRectangle_Callback(pos, handles));
        fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
        setPositionConstraintFcn(handles.snapRectangle,fcn); 
        guidata(gcf, handles);
        setV('snapIsOn',1);

   end
end

