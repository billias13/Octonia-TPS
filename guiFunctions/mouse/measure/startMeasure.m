function startMeasure(src, eventdata)
% -------------------------------------------------------------------------  

handles = guidata(src);

try; delete(handles.measureLine);catch;end;
try; delete(handles.measureText);catch;end;
    
if getV('measureIsOn')
    stopMeasure(src,eventdata);
else
    %disp('snapon');
    %disp(get(gcf,'Selectiontype'));
        if strcmp(get(gcf,'Selectiontype'),'normal')
            handles=guidata(src);
            updateViewer(handles);
            axes(handles.TopAxes);
            refreshCurrentMousePos(gcf);
             if strcmp(getV('currentMousePos'),'TopAxes')    

                  setptr(gcf, 'crosshair');
                  [x y] = mouseToAxesCoordinates(handles);
                  setV('measureStartPos',[x y]);
                  setV('measureStopPos',[x+0.1 y+0.1]);
                  initMeasureLine(handles)

                  setV('measureIsOn',1);
                  set(gcf,'WindowButtonMotionFcn',@Measure);    
                  set(gcf,'WindowButtonUpFcn',@stopMeasure);
             else
                 stopMeasure(src,eventdata);
             end
        elseif strcmp(get(gcf,'Selectiontype'),'open')
            setV('measureIsOn',0);
            handles = guidata(src);
            setptr(gcf, 'arrow'); 
            set(gcf,'WindowButtonUpFcn',@noCallbackMeasure);
            set(gcf,'WindowButtonMotionFcn',@noCallbackMeasure);
            updateViewer(handles);
        end
end
end

