function startAdjustLW(hObject, eventdata, handles)
% -------------------------------------------------------------------------
        refreshCurrentMousePos(hObject);
        if strcmp(get(gcf,'Selectiontype'),'normal')
             if strcmp(getV('currentMousePos'),'TopAxes') || strcmp(getV('currentMousePos'),'BottomRAxes') ...
                                                          || strcmp(getV('currentMousePos'),'BottomLAxes');
                  setptr(gcf, 'cross');
                  setV('adjustLWState',1);
                  setV('adjustStartPos',get(hObject,'currentpoint'));
                  setV('lastLevel',getV('Level'));
                  setV('lastWindow',getV('Window'));
                  set(gcf,'WindowButtonUpFcn',@stopAdjustLW);
                  set(gcf,'WindowButtonMotionFcn',@adjustLW);
            end
        end
end