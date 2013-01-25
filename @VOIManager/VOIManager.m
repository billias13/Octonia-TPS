classdef VOIManager < handle
    
    % This class takes the RTSS and extracts the coordinates of the
    % delineated Volumes Of Interest (VOIs) in mm as well as additional 
    % information such as default color, geometric type,etc
    % CTinfo provided by TPSpatient is also used to obtain the
    % coordinates of the delineated contours in the indexed coordinate
    % system to be used for plotting purposes as well as to calculate the
    % volumes (in units of cm^3) of the delineated VOIs. For the latter purpose 
    % the CTcoordinates are used provided also from TPSpatient class
    
    properties
       
        VOIs                 % a structure containing the delineated VOIs data 
        
        numOfVOIs;           %The number of VOIs contained in this dataset
        
        voisProperties;      % some properties of VOIs for easy use
        
        method = 'inpolygon'; % a flag defining the mehtod for calculating VOI volumes
        whichInPolygon = 2;   % a flag for chosing between the matlab's 'inpolygon' (slow)
%                               and a much faster function 'inpoly' found in mathworks 
        
        progressBar;
        
    end
    
    methods
    
        
        function obj = VOIManager(RTSS,CTinfo,CTcoordinates,progressBar)  % class constructor 
            
            obj.progressBar = progressBar;
            obj.ExtractVOIsInfoFromRTSS(RTSS)
            obj.CalculateVOIindexedCoordinates(CTinfo)
            obj.CalculateVOIvolumes(CTinfo,CTcoordinates)
            
            
            obj.numOfVOIs  = numel(fieldnames(obj.VOIs));
            
            for i = 1:obj.numOfVOIs
               VOIname = strcat('VOI_',int2str(i));
               obj.voisProperties(i).name = obj.VOIs.(VOIname).ROIName;
               obj.voisProperties(i).visible = 1;
               obj.voisProperties(i).color = obj.VOIs.(VOIname).ROIDisplayColor;
            end
        end
        

        % take RTSS and extract into a structure only the contour 3D
        % coordinates and default color for the delineated VOIs and not
        % for the applicators (the latter is handled by the DwellPositionManager)
        function ExtractVOIsInfoFromRTSS(obj,RTSS)
 
            % import only the VOIs and not the applicators
            k =1 ;  
            for i=1:numel(fieldnames(RTSS.StructureSetROISequence))
                waitbar(i/numel(fieldnames(RTSS.StructureSetROISequence)),...
                               obj.progressBar ,'Extracting volumes of interest (VOIs) ...');
                
                itemName = strcat('Item_',int2str(i));
                if isempty(strfind(RTSS.StructureSetROISequence.(itemName).ROIName,'Applicator'))
        
                    VOIname = strcat('VOI_',int2str(k));
                    obj.VOIs.(VOIname).ROINumber = RTSS.StructureSetROISequence.(itemName).ROINumber;
                    obj.VOIs.(VOIname).ROIName = RTSS.StructureSetROISequence.(itemName).ROIName;
                    k = k + 1;
                   
                end
                
            end
            
            % for the delineated VOIs extract the contourData and chosen color 
            for i=1:numel(fieldnames(obj.VOIs))
            
                waitbar(i/numel(fieldnames(obj.VOIs)),obj.progressBar ,'Extracting contour data...');
                
                VOIname = strcat('VOI_',int2str(i));
                for j = 1:numel(fieldnames(RTSS.ROIContourSequence))
               
                    itemName = strcat('Item_',int2str(j));
                    if obj.VOIs.(VOIname).ROINumber == RTSS.ROIContourSequence.(itemName).ReferencedROINumber
                    
                        obj.VOIs.(VOIname).ROIDisplayColor = RTSS.ROIContourSequence.(itemName).ROIDisplayColor;
                        
                        if ~isempty(cell2mat( strfind(fieldnames(RTSS.ROIContourSequence.(itemName)),'ContourSequence')))
                            
                            obj.VOIs.(VOIname).hasContourData = 1;% for the VOIs that have contourData set the flag = 1 else 0.
                            nn = 1;
                            flag = 0;
                            for k = 1:numel(fieldnames(RTSS.ROIContourSequence.(itemName).ContourSequence))
                                
                                itemName2 = strcat('Item_',int2str(k));
                                obj.VOIs.(VOIname).ContourGeometricType = ...
                                RTSS.ROIContourSequence.(itemName).ContourSequence.(itemName2).ContourGeometricType;
                                zPosition(k) = RTSS.ROIContourSequence.(itemName).ContourSequence.(itemName2).ContourData(3);
                              
                                if k > 1 && zPosition(k) ~= zPosition(k-1)
                                    flag = 1;
                                elseif k == 1
                                    flag = 1; 
                                else
                                    flag = flag + 1;
                                end
                                         
                                    for n=1:3:numel(RTSS.ROIContourSequence.(itemName).ContourSequence.(itemName2).ContourData)

                                        obj.VOIs.(VOIname).ContourData(nn,1:3) = ...
                                        RTSS.ROIContourSequence.(itemName).ContourSequence.(itemName2).ContourData(n:(n+2),1);
                                        obj.VOIs.(VOIname).ContourData(nn,4) = flag;
                                        nn = nn + 1;

                                    end
                               
                            end
                            
                        else
                          obj.VOIs.(VOIname).hasContourData = 0;
                        end
                        
                    end
                    
                end
                
            end
            
             clear VOIname i j k n nn itemNane itemName2
        end
        
        % calculates the coordinates of each VOI contourData in the indexed
        % coordinate system for plotting purposes
         function CalculateVOIindexedCoordinates(obj,CTinfo)
             
             for i=1:numel(fieldnames(obj.VOIs))
                 
                VOIname = strcat('VOI_',int2str(i)); 
                
                if obj.VOIs.(VOIname).hasContourData == 1
                  obj.VOIs.(VOIname).indexedContourData(:,1) = 1 + (obj.VOIs.(VOIname).ContourData(:,1) - CTinfo.ImagePositionPatientAll(1,1))./CTinfo.PixelSpacing(1);
                  obj.VOIs.(VOIname).indexedContourData(:,2) = 1 + (obj.VOIs.(VOIname).ContourData(:,2) - CTinfo.ImagePositionPatientAll(1,2))./CTinfo.PixelSpacing(2);
                  obj.VOIs.(VOIname).indexedContourData(:,3) = 1 + (obj.VOIs.(VOIname).ContourData(:,3) - CTinfo.ImagePositionPatientAll(1,3))./CTinfo.SliceThickness;
                  obj.VOIs.(VOIname).indexedContourData(:,4) = obj.VOIs.(VOIname).ContourData(:,4);
                end
                
            end
            
         end
        
        
%          Calculate the volume of the delineated vois considering the
%          center of each voxel relative to the polygonal surface defined
%          by the vertices saved in indexedContourData. The function 'inpoly' 
%          is used as default to find the voxels lying inside the VOI  
         function CalculateVOIvolumes(obj,CTinfo,CTcoordinates)
         
             
             R = 1:numel(CTcoordinates.y);  % rows => y coordinate
             C = 1:numel(CTcoordinates.x);  % columns => x coordinate
             S = 1:numel(CTcoordinates.z);  % slices => z coordinate
             
             voiNames = fieldnames(obj.VOIs);
              
             switch obj.method
           
                 case 'inpolygon'
             
                     for i = 1:numel(voiNames)
                         
                         waitbar(i/numel(voiNames),obj.progressBar ,'Calculating VOIs volume...');
                         
                         if obj.VOIs.(voiNames{i}).hasContourData == 1 

                            voxelsInsideVoiCounter = 0;
                          
                            for k = find(S == floor(min(obj.VOIs.(voiNames{i}).indexedContourData(:,3)))): ...
                                    find(S ==  ceil(max(obj.VOIs.(voiNames{i}).indexedContourData(:,3))))
                            
                                ind = find(obj.VOIs.(voiNames{i}).indexedContourData(:,3) == S(k));
                                if ~isempty(ind)
                         
                                    countourInSlice = obj.VOIs.(voiNames{i}).indexedContourData(ind,:);
                          
                                    for flag = 1:max(countourInSlice(:,4));
                                        
                                        ind2 = find(countourInSlice(:,4) == flag);
                                        if numel(ind2)>0
                                          
                                           ContourSetData = obj.VOIs.(voiNames{i}).indexedContourData(ind2,1:3);
                                           indXmin = find(C >= floor(min(ContourSetData(:,1))) );
                                           indXmax = find(C <= ceil(max(ContourSetData(:,1))) );
                                           indYmin = find(R >= floor(min(ContourSetData(:,2))) );
                                           indYmax = find(R <= ceil(max(ContourSetData(:,2))) );
                                           [xx,yy] = meshgrid( C(indXmin(1):indXmax(end)),R(indYmin(1):indYmax(end)) );
                                           
                                           switch obj.whichInPolygon
                                               case 1
                                                  mask = inpolygon(xx,yy,ContourSetData(:,1),ContourSetData(:,2));
                                               case 2
                                                  mask = inpoly([xx(:),yy(:)],[ContourSetData(:,1),ContourSetData(:,2)]);
                                           end
                                           voxelsInsideVoiCounter = voxelsInsideVoiCounter + sum(mask(:));
                                           clear mask   
                                        end
                                        
                                    end
                                    
                                end
                                
                            end
                   
                           obj.VOIs.(voiNames{i}).volume = voxelsInsideVoiCounter* ...
                                                           CTinfo.PixelSpacing(1)*CTinfo.PixelSpacing(1)*CTinfo.SliceThickness/1000;

                         end
                         
                     end
                     
                 case 'convhull'  % the function 'inhull' requires data at least in two planes else it hits
                
                     for i=1:numel(voiNames)
                
                        if obj.VOIs.(voiNames{i}).hasContourData == 1 
                    
                            voxelsInsideVoiCounter = 0;

                            for flag = 1:max(obj.VOIs.(voiNames{i}).indexedContourData(:,4))
                                
                                ind = find(obj.VOIs.(voiNames{i}).indexedContourData(:,4) == flag);
                                if numel(ind)>0
                                    
                                     ContourSetData = obj.VOIs.(voiNames{i}).indexedContourData(ind,1:3);
                                     indXmin = find(C >= floor(min(ContourSetData(:,1))) );
                                     indXmax = find(C <= ceil(max(ContourSetData(:,1))) );
                                     indYmin = find(R >= floor(min(ContourSetData(:,2))) );
                                     indYmax = find(R <= ceil(max(ContourSetData(:,2))) );
                                     indZmin = find(S >= floor(min(ContourSetData(:,3))) );
                                     indZmax = find(S <= ceil(max(ContourSetData(:,3))) );
                                   
                                     [xx,yy,zz] = meshgrid( C(indXmin(1):indXmax(end)),...
                                                            R(indYmin(1):indYmax(end)),...
                                                            S(indZmin(1):indZmax(end))  );

                                     mask = inhull([xx(:), yy(:), zz(:)],ContourSetData,tess);
                                     voxelsInsideVoiCounter = voxelsInsideVoiCounter + sum(mask(:));
                                     clear mask;
                                end
                                
                            end
                            
                        end
                        
                     end
                   
                     obj.VOIs.(voiNames{i}).volume = voxelsInsideVoiCounter* ...
                                                     CTinfo.PixelSpacing(1)*CTinfo.PixelSpacing(1)*CTinfo.SliceThickness/1000;
                                               
              end
                
         end % end of function
         
         
    end % end of methods
    
    
end


