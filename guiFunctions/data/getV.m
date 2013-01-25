% -------------------------------------------------------------------------
function value = getV(name)
 
    hMainGui = getappdata(0,'hMainGui');
    value = getappdata(hMainGui,name);


