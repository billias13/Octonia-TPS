function stopAdjustLW(src, eventdata)

         setV('lastLevel',getV('Level'));
         setV('lastWindow',getV('Window'));    
         setptr(gcf, 'arrow');
         setV('adjustLWState',0);
         updateViewer(guidata(src));
end