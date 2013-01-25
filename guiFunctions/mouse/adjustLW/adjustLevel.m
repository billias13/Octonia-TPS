function tempLevel = adjustLevel(val,totalHeight)
    
        Level = getV('lastLevel');
        LevelLimits = getV('LevelLimits');
        adjustment = (LevelLimits.max - LevelLimits.min)*(val*getV('LevelAdjustSpeed')/totalHeight);
        %If new adjustment falls within limits, apply it, else maintain top or
        %bottom limit according to the direction of change
         if (Level + adjustment) > LevelLimits.min && (Level + adjustment) <  LevelLimits.max
            tempLevel =  Level + adjustment;
         else
            if (Level + adjustment) <= LevelLimits.min
                tempLevel = LevelLimits.min;
            elseif (Level + adjustment) >=  LevelLimits.max
                tempLevel = LevelLimits.max;
            end   
         end
end