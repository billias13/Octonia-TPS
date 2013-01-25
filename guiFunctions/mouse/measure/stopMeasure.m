% ------------------------------------------------------------------------- 
function stopMeasure(src, eventdata)
% -------------------------------------------------------------------------  
    if getV('measureIsOn') ==1
        setptr(gcf, 'arrow'); 
        setV('measureIsOn',0);
        %disp('snap off');
        handles = guidata(src); 
     %  delete(handles.measureLine); delete(handles.measureText);
       
    end
    set(gcf,'WindowButtonMotionFcn',@noCallbackMeasure);
    set(gcf,'WindowButtonUpFcn',@noCallbackMeasure);
end

