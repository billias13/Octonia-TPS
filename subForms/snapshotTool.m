function [ out ] = snapshotTool( array, level, window )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    figure;
    imagesc(array);
    pbaspect([1 1 1]), colormap gray,caxis([level-(window/2)  level+(window/2)]);

end

