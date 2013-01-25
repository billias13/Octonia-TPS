%--------------------------------------------------------------------------
%This function calculates the position of the mouse in (x,y) coordinates
%when the mouse is over the central axes (topAxes) of the gui, using the
%bounds of the axes, the cursor position in the gui coordinate system, and
%the axes XDir,YDir,Xlim,Ylim properties.
%--------------------------------------------------------------------------
function [xf yf] = axesToFormCoordinates(handles, x,y)
        

       currentAxes = handles.TopAxes;

       currentBounds =  getV('TopAxesBounds');
        
        % Position of origin in figure [left bottom]
        AxesWidth  = currentBounds(3); %Width of main axes in pixels
        AxesHeight = currentBounds(4); %Height of main axes in pixels
        xDir = get(currentAxes,'XDir'); %Direction of increasing value in x
        yDir = get(currentAxes,'YDir'); %Direction of increasing value in y

        % Get cursor position in gui coordinate system
        cursorPos = get( gcf, 'currentpoint'); % [left bottom]

        %Find cursor position in axes coordinate system
        if strcmp(xDir,'normal')
            originX = currentBounds(1);
        else
            originX = currentBounds(1) + AxesWidth;
        end

        if strcmp(yDir,'normal')
            originY     = currentBounds(2);
        else
            originY = currentBounds(2) + AxesHeight;
        end

        %Width of main axes in metric units (cells actually)
        xlim_axes=get(currentAxes,'XLim');
        axesWidth=xlim_axes(2)-xlim_axes(1);
        %Height of main axes in metric units (cells actually)
        ylim_axes=get(currentAxes,'YLim');
        axesHeight=ylim_axes(2)-ylim_axes(1);

        
         xf = (originX + (x*AxesWidth/axesWidth)) ;
         yf = (originY - (y*AxesHeight/axesHeight)) ;
  

end