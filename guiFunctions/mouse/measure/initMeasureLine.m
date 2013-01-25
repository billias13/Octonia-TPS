function initMeasureLine(handles)
    measureStartPos = getV('measureStartPos');
    handles.measureLine = line([measureStartPos(1) measureStartPos(1)], [measureStartPos(2)  measureStartPos(2)],'Color','Green');
    handles.measureText = uicontrol('Style','text','String','','ForegroundColor','Green','BackgroundColor','Black','Position',[measureStartPos(1) measureStartPos(2) 1 1],'Visible','off');
    guidata(gcf,handles); 
end

