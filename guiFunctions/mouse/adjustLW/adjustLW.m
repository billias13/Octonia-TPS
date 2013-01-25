function adjustLW(src, eventdata)
    % -------------------------------------------------------------------------    
        handles=guidata(src);

        if getV('adjustLWState')

            refreshCurrentMousePos(gcf);

            CurrentAdjustPos = get(gcf,'currentpoint');

            if strcmp(getV('currentMousePos'),'TopAxes') || strcmp(getV('currentMousePos'),'BottomRAxes')...
                                                         || strcmp(getV('currentMousePos'),'BottomLAxes');

                TopAxesBounds = getV('TopAxesBounds');
                TopAxesWidth =  TopAxesBounds(3);
                TopAxesHeight = TopAxesBounds(4);

                adjustStartPos = getV('adjustStartPos');
                distX = CurrentAdjustPos(1) - adjustStartPos(1);
                distY = CurrentAdjustPos(2) - adjustStartPos(2);
                try
                    tempLevel  = uint32(adjustLevel(distY,TopAxesHeight));
                    set(handles.txtLevelS,'String',tempLevel);

                    tempWindow = uint32(adjustWindow(distX,TopAxesWidth));
                    set(handles.txtWindowS,'String',tempWindow);
                    setV('Level',tempLevel);
                    setV('Window',tempWindow);
                catch err
                    disp(err.message);
                end
                updateViewer(handles);


            else
                stopAdjustLW(src);
                return
            end
        end
end