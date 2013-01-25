 function snapRectangle_Callback(pos, handles)

         setV('snapPos',pos);
         newPos = getV('snapPos');

         [btnPos(1) btnPos(2)] = axesToFormCoordinates(handles, newPos(1), newPos(2));

         set(handles.btnSaveSnap,'Position',[btnPos(1)+4 btnPos(2)-34 40 30]);
         %set(handles.btnCancelSnap,'Position',[btnPos(1)+46 btnPos(2)-34 60 30]);
end

