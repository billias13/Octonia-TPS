    % -------------------------------------------------------------------------
    function updateCross(handles,x,y,z)
    % -------------------------------------------------------------------------
        %Get cross position and limits
        crossPosition = getV('crossPosition');
        crossLimits   = getV('crossLimits');
        %Check if cross reached its limits to the defined direction, and if
        %not, change its value, else do nothing...
        if crossPosition.x + x > 0 && crossPosition.x + x <= crossLimits.x
            crossPosition.x = crossPosition.x + x;
        end
        if crossPosition.y + y > 0 && crossPosition.y + y <= crossLimits.y
            crossPosition.y = crossPosition.y + y;
        end
        if crossPosition.z + z > 0 && crossPosition.z + z <= crossLimits.z
            crossPosition.z = crossPosition.z + z;
        end
        %Store new cross position
        setV('crossPosition',crossPosition);
        %Change the text on the relative gui elements    
        set(handles.txtCrossZS,'String',['Axial : ' num2str(crossPosition.z) '/' num2str(crossLimits.z)]);
        set(handles.txtCrossYS,'String',['Sagital : ' num2str(crossPosition.y) '/' num2str(crossLimits.y)]);
        set(handles.txtCrossXS,'String',['Coronal : ' num2str(crossPosition.x) '/' num2str(crossLimits.x)]);

    end 