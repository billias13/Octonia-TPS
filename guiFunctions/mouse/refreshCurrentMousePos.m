function refreshCurrentMousePos( hObject )
%REFRESHCURRENTMOUSEPOS Summary of this function goes here
%   Detailed explanation goes here
  MousePos = get(hObject,'currentpoint');
      
      %Read the bounds of ui elements to identify if the mouse if over a
      %certain ui element
      TopAxesBounds         = getV('TopAxesBounds');
      BottomRAxesBounds     = getV('BottomRAxesBounds');
      BottomLAxesBounds     = getV('BottomLAxesBounds');
  %Refresh the currentMousePos which is used throughout the form
  %Usage : setV('currentMousePos', 'UiElementName' );
  %This way, you can identify over which element the mouse cursor is at any
  %given time during the program execution!
  
  if isWithinBounds(MousePos, TopAxesBounds)
        setV('currentMousePos','TopAxes');
  elseif isWithinBounds(MousePos, BottomRAxesBounds)
        setV('currentMousePos','BottomRAxes');
  elseif isWithinBounds(MousePos, BottomLAxesBounds)
        setV('currentMousePos','BottomLAxes');
  else
       setV('currentMousePos','Form');
  end
  
  if getV('DEBUG_MODE'); disp(['Mouse is over ' getV('currentMousePos')]);
  end

end

