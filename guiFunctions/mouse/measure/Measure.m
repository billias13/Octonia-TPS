% ------------------------------------------------------------------------- 
function Measure(src, eventdata)
% -------------------------------------------------------------------------  
set(gcf,'Pointer','crosshair');
    if  getV('measureIsOn')==1
         tic;
         %disp('snapping');
            handles = guidata(src);
            refreshCurrentMousePos(gcf);
         if strcmp(getV('currentMousePos'), 'TopAxes')
 
          drawMeasureLine(handles)
          [xc yc] = mouseToAxesCoordinates(handles);
   
          setV('measureStopPos', [xc yc]);
         else
            % stopCrop(src, eventdata);
         end
         toc;
     end
end

