classdef DwellPositionManager < handle
    
    %This class extracts information about the used catheters (e.g., 3D
    %position coordinates, times, type, color) and the coordinates, 
    %irradiation time, orientation, etc of the source dwell
    % positions in each catheter
    
    
    properties
         
        dwellPositionsInfo  % for the loaded catheters, the 3D positions, directional cosines, time
        catheterInfo        % for the used catheters the 3D positions, and all available information inside the RTPLAN, RTSS
        allDwellPositions   % all the positions, directional cosines and irradiation times (sos the entries of the dwellPositionsInfo that have irradiation time = 0 are removed)
        indexedDwell3Dpositions % the 3D coordinates of the dwell positions in the indexed coordinate system used for plotting purposes
    
    end
    
    methods
    
        % the constructor
        function obj = DwellPositionManager(RTSS,RTPLAN,CTinfo)
           
            obj.ExtractCatheterInfo(RTPLAN,RTSS)
            obj.ExtractDwellPositionsInfo
            obj.CalculateDirectionalCosinesForEachDwellPosition
            obj.GatherDwellInfoInOneMatrix
            obj.convertDwell3Dposition2indexedSystem(CTinfo)
        end
        
        
        % Take RTSS and RTPLAN dicom files and extract available information (e.g., catheter coordinates)  
        function ExtractCatheterInfo(obj,RTPLAN,RTSS)
            
            % extract catheter information from RTPLAN
            channelSequenceInfo = struct(RTPLAN.ApplicationSetupSequence.Item_1.ChannelSequence);
            itemNames = fieldnames(channelSequenceInfo);

            for i=1:numel(fieldnames(channelSequenceInfo))
                name = channelSequenceInfo.(itemNames{i}).SourceApplicatorID;
                values = struct(channelSequenceInfo.(itemNames{i}));
                obj.catheterInfo.(name) = values;
            end
            
                      
            % extract catheter coordinates,... from RTSS
            ROIContourItems = fieldnames(RTSS.ROIContourSequence);
            
            for i=1:numel(ROIContourItems)
                ReferenceROINumbers(i,1) = RTSS.ROIContourSequence.(ROIContourItems{i}).ReferencedROINumber;
                
            end
            
            catheterNames = fieldnames(obj.catheterInfo);
            
            for i=1:numel(catheterNames)
                
               index = find(ReferenceROINumbers == obj.catheterInfo.(catheterNames{i}).ReferencedROINumber);
               obj.catheterInfo.(catheterNames{i}).ContourGeometricType = RTSS.ROIContourSequence.(ROIContourItems{index}).ContourSequence.Item_1.ContourGeometricType;
               obj.catheterInfo.(catheterNames{i}).NumberOfContourPoints = RTSS.ROIContourSequence.(ROIContourItems{index}).ContourSequence.Item_1.NumberOfContourPoints;
               
               coords = RTSS.ROIContourSequence.(ROIContourItems{index}).ContourSequence.Item_1.ContourData;
                  j = 1; 
                  k = 1;
                  while k < numel(coords)
                        TransformedData(j,1:3) = coords(k:k+2);
                        k = k + 3;
                        j = j + 1;
                  end
                        
               obj.catheterInfo.(catheterNames{i}).ContourData = TransformedData; 
               obj.catheterInfo.(catheterNames{i}).ROIDisplayColor = RTSS.ROIContourSequence.(ROIContourItems{index}).ROIDisplayColor;
                
               clear coords TransformedData
            end
            
            clear itemNames channelSequenceInfo values name index catheterNames ROIContourItems 
            clear ReferenceROINumbers i j k coords TransformedData
            
        end
        
        
        % Use catheterInfo to extract and save in a more usefull method the dwell positions, directional cosines and times   
        function ExtractDwellPositionsInfo(obj)
        
            catheterName = fieldnames(obj.catheterInfo);
            for i=1:numel(catheterName)
                
                if obj.catheterInfo.(catheterName{i}).NumberOfControlPoints > 0 && ...
                   obj.catheterInfo.(catheterName{i}).FinalCumulativeTimeWeight > 0
                   
                       obj.dwellPositionsInfo.(catheterName{i}).FinalCumulativeTimeWeight = ...
                                           obj.catheterInfo.(catheterName{i}).FinalCumulativeTimeWeight ;
                       obj.dwellPositionsInfo.(catheterName{i}).NumberOfDwellPositions = ...
                                           obj.catheterInfo.(catheterName{i}).NumberOfControlPoints/2;
                      
                       d = 1;
                       for j = 2:obj.catheterInfo.(catheterName{i}).NumberOfControlPoints
                           items = fieldnames(obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence);
                           cpRelativePositions(1) = obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence.(items{j-1}).ControlPointRelativePosition;
                           cpRelativePositions(2) = obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence.(items{j}).ControlPointRelativePosition;
                           
                           if cpRelativePositions(2) == cpRelativePositions(1)
                                dwellname = strcat('dwell',int2str(d));
                                
                                cp3DPositions(1,1:3) = obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence.(items{j-1}).ControlPoint3DPosition;
                                cp3DPositions(2,1:3) = obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence.(items{j-1}).ControlPoint3DPosition;
                                obj.dwellPositionsInfo.(catheterName{i}).(dwellname).ControlPoint3DPosition = (cp3DPositions(1,:) + cp3DPositions(2,:))/2;
                                obj.dwellPositionsInfo.(catheterName{i}).(dwellname).ControlPointRelativePosition = cpRelativePositions(2);
                                obj.dwellPositionsInfo.(catheterName{i}).(dwellname).CumulativeTimeWeight = obj.catheterInfo.(catheterName{i}).BrachyControlPointSequence.(items{j}).CumulativeTimeWeight;
                                
                                    if d > 1 % calculate the absolute irradiation time (min) 
                                        obj.dwellPositionsInfo.(catheterName{i}).(dwellname).IrradiationTime = obj.dwellPositionsInfo.(catheterName{i}).(dwellname).CumulativeTimeWeight - ...
                                                                                                               obj.dwellPositionsInfo.(catheterName{i}).(strcat('dwell',int2str(d-1))).CumulativeTimeWeight;
                                    elseif d == 1
                                         obj.dwellPositionsInfo.(catheterName{i}).(dwellname).IrradiationTime = obj.dwellPositionsInfo.(catheterName{i}).(dwellname).CumulativeTimeWeight ;
                                    end
                                    
                                d = d + 1;
                           end
                               
                       end
                       
                end
                
            end 
            
        end
        
        
        % Calculate the directional cosines for each source dwell position
        % and update the dwellPositionInfo structure. The function
        % calculates the distance of each dwellposition from the points
        % delineated for the corresponding catheter and finds the closests 
        % two points. These points are used to obtain the directional cosines
        % of the studied dwell position. 
        function CalculateDirectionalCosinesForEachDwellPosition(obj)
            
             loadedCatheters = fieldnames(obj.dwellPositionsInfo);
            
             for i=1:numel(loadedCatheters) 
                
                 catheter3Dcoordinates = obj.catheterInfo.(loadedCatheters{i}).ContourData;
          
                 for j=1:obj.dwellPositionsInfo.(loadedCatheters{i}).NumberOfDwellPositions
                     fieldname = strcat('dwell',int2str(j));
                     dwell3DPosition = obj.dwellPositionsInfo.(loadedCatheters{i}).(fieldname).ControlPoint3DPosition;
                     
                         for k=1:size(catheter3Dcoordinates,1)
                             distance(k,1) = norm( catheter3Dcoordinates(k,:) - dwell3DPosition);
                         end
                         sortedDistances = sortrows(distance);
                         Pointer1 = find(distance == sortedDistances(1));
                         Pointer2 = find(distance == sortedDistances(2));
                         
                         %distance of selected catheter Point1 from tip
                         Point1_to_tip = norm(catheter3Dcoordinates(Pointer1,:) - catheter3Dcoordinates(1,:) );
                         
                         %distance of selected catheter Point2 from tip
                         Point2_to_tip = norm(catheter3Dcoordinates(Pointer2,:) - catheter3Dcoordinates(1,:) );
                         
                         % choose which point is closest to the tip. The
                         % source tip is towards the catheter tip
                            if Point1_to_tip > Point2_to_tip
                                Point1 = catheter3Dcoordinates(Pointer2,:);
                                Point2 = catheter3Dcoordinates(Pointer1,:);
                            else
                                Point1 = catheter3Dcoordinates(Pointer1,:);
                                Point2 = catheter3Dcoordinates(Pointer2,:);
                            end
                                
                         obj.dwellPositionsInfo.(loadedCatheters{i}).(fieldname).directionalCosines = (Point1 - Point2)./norm( (Point1 - Point2) ); 
                         
                    
                 end
             end
             
        end
        
        % Gather all the information for the dwell positions in one matrix
        % and remove the entries for which irradiation time = 0
        function GatherDwellInfoInOneMatrix(obj)
            
            catheterName = fieldnames(obj.dwellPositionsInfo);
            k = 1;
            for i = 1:numel(catheterName) 
                
                for j=1:obj.dwellPositionsInfo.(catheterName{i}).NumberOfDwellPositions
                    dwellname = strcat('dwell',int2str(j));
                    if obj.dwellPositionsInfo.(catheterName{i}).(dwellname).IrradiationTime > 0
                        obj.allDwellPositions(k,1:3) = obj.dwellPositionsInfo.(catheterName{i}).(dwellname).ControlPoint3DPosition;
                        obj.allDwellPositions(k,4:6) = obj.dwellPositionsInfo.(catheterName{i}).(dwellname).directionalCosines;
                        obj.allDwellPositions(k,7)   = obj.dwellPositionsInfo.(catheterName{i}).(dwellname).IrradiationTime;
                        k = k + 1;
                    end
                end
                
            end
            
        end
        
        % Calculate the 3D coordinates of the source dwell positions in the
        % indexed coordinate system for plotting the dwell positions in the gui 
        % SOS only the dwell positions that have irradiation time > 0 are
        % included in the indexedDwell3Dpositions and will be plotted
        function convertDwell3Dposition2indexedSystem(obj,CTinfo)
          
            DwellPositions = obj.allDwellPositions(:,1:3);
            obj.indexedDwell3Dpositions(:,1) = 1 + (DwellPositions(:,1) - CTinfo.ImagePositionPatientAll(1,1))./CTinfo.PixelSpacing(1);
            obj.indexedDwell3Dpositions(:,2) = 1 + (DwellPositions(:,2) - CTinfo.ImagePositionPatientAll(1,2))./CTinfo.PixelSpacing(2); 
            obj.indexedDwell3Dpositions(:,3) = 1 + (DwellPositions(:,3) - CTinfo.ImagePositionPatientAll(1,3))./CTinfo.SliceThickness;
                        
            
        end
        
        
    end  % end of methods
    
    
    
end
    


