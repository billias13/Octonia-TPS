function [ out ] = questionDialog(in)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

out = 0;
switch in
    case 'clearPatientAndLoadNew'
        out = clearPatientAndLoadNew();
        return;
end


    function out  = clearPatientAndLoadNew()
        out = 0;
        % Construct a questdlg with two options
        choice = questdlg('Loading new data will clear the currently loaded patient. Would you like to continue?', ...
            'Load new data', ...
            'Yes','Cancel','Cancel');
        % Handle response
        switch choice
            case 'Yes'
                out = 1;
            case 'Cancel'
                out = 2;
        end
    end
    
 

end

