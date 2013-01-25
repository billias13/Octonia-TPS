function traverseSliceInView( handles,val )
% -------------------------------------------------------------------------
% Traverse through CT data
% -------------------------------------------------------------------------               
currentMousePos = getV('currentMousePos');

    %Find out what is the current active view base on mouse position.If for
    %example the mouse is over TopAxes and the TopAxes is now showing
    %sagital view, then the current activeView will be set to sagital, and
    %only this view will updated to earn some speed, since the remaining
    %two views won't be affected.
    switch currentMousePos
        case 'TopAxes' 
            %axes(handles.TopAxes);
            set(gcf,'CurrentAxes',handles.TopAxes);
            activeView = getV('currentTopView');
        case 'BottomLAxes'
            %axes(handles.BottomLAxes);
             set(gcf,'CurrentAxes',handles.BottomLAxes);
             activeView = getV('currentBottomLView');
        case 'BottomRAxes'
            %axes(handles.BottomRAxes);
             set(gcf,'CurrentAxes',handles.BottomRAxes);
            activeView = getV('currentBottomRView');
    end

    % activeView now points at the view that will be updated and it is used
    % The x, y OR z position of the cross will be changed based on which
    % view is currently active
    switch activeView
        case 'Axial'
            updateCross(handles,0,0,val);
        case 'Sagital'
            updateCross(handles,0,val,0);        
        case 'Coronal'
            updateCross(handles,val,0,0);   
    end

    %Update only the current activeView (axial-sagital-coronal) using the
    %current patient data, cross position, level, width and contours.
    updateSingleView(handles, activeView);
    axis off;
    

end