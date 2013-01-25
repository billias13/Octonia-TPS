function drawMeasureLine(handles)
        measureStartPos = getV('measureStartPos');
           [xc yc] = mouseToAxesCoordinates(handles);
              set(handles.measureLine,'XData',[measureStartPos(1) xc],'YData',[measureStartPos(2) yc]);
              distSquare = double((measureStartPos(1)-xc)^2+(measureStartPos(2)-yc)^2);
              distance =  sqrt(distSquare);%((measureStartPos(1)-xc)^2+(measureStartPos(2)-yc)^2);
              cursorPos = get( gcf, 'currentpoint'); % [left bottom]
              set(handles.measureText,'String',strcat(num2str(distance),' pixels'),'Position',[cursorPos(1)+5 cursorPos(2)-20 60 15],'Visible','on'); %Calculate distance
        guidata(gcf, handles);
end

