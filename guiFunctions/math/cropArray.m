function [ croppedArray ] = cropArray( initialArray,xmin,xmax,ymin,ymax,zmin,zmax )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    croppedArray = initialArray(xmin:xmax,ymin:ymax,zmin:zmax);
 
end

