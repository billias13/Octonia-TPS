function tempWindow = adjustWindow(val,totalWidth)

        Window = getV('lastWindow');
        WindowLimits = getV('WindowLimits');
         adjustment = -(WindowLimits.max - WindowLimits.min)*(val*getV('WindowAdjustSpeed')/totalWidth);
        %If new adjustment falls within limits, apply it, else maintain top or
        %bottom limit according to the direction of change
         if (Window + adjustment) > WindowLimits.min && (Window + adjustment) <  WindowLimits.max
            tempWindow =  Window + adjustment;
         else
            if (Window + adjustment) <= WindowLimits.min
                tempWindow = WindowLimits.min;
            elseif (Window + adjustment) >=  WindowLimits.max
                tempWindow = WindowLimits.max;
            end   
         end
end
