function saveSnap_Callback(hObject, evt,handles)
    
    setV('snapIsOn',0);
%     handles = guidata(hObject);
%     try delete(handles.btnCancelSnap);catch end;   
%     set(handles.btnSaveSnap,'Visible','off');
%     destroyOverlays(handles);
    
% function cancelSnap_Callback(hObject, evt,handles)
% 
%      setV('snapIsOn',0);
%      handles = guidata(hObject);
%      try delete(handles.btnSaveSnap);catch end;
%      set(handles.btnCancelSnap,'Visible','off');
%      destroyOverlays(handles);

F = getframe(gcf,hObject);
[X,Map] = frame2im(F);
end

