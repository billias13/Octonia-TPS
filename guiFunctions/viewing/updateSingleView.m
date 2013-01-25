function updateSingleView( handles, currentActiveView )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  %if getV('DEBUG_MODE'); disp('Function : updateViewer'); end
% -------------------------------------------------------------------------
   %If this function is called by accident when no patient data are loaded
   %to the viewer, it will return without doing nothing
   if ~getV('patientDataLoaded')
       return 
   end
   tic
    %Get a handle to the currentPatient 
    currentPatient = getV('currentPatient');
    %Get cross position
    crossPosition  = getV('crossPosition');
    %Get windows and levels
    Window= getV('Window');
    Level= getV('Level');
    
    plotView(currentActiveView)

 
        % ------------------------------------------------------------------------- 
        % Sets the display view (axial - sagital - coronal) of the chosen axes
        % based on the current patient data
       
        function plotView(view)
            %if getV('DEBUG_MODE'); disp('Function : plotView'); end
        % -------------------------------------------------------------------------
         
            switch view
              case 'Axial'
                    % Show dicom image
                    imagesc(currentPatient.CTimages(:,:,crossPosition.z));
                    pbaspect([1 1 1]), colormap gray,caxis([Level-(Window/2)  Level+(Window/2)]); 
                    
                    %If 'showVOIS' is selected, show vois based on current
                    %cross position
                    if(getV('showVOIS'))  
                       % Plot the VOIS 
                       hold on; plotVOIsOnCurrentCrossPosition(3); hold off
                    end
                     
                    %If 'showIsodoses' is selected, show isodose distribution
                    % based on current cross position 
                    if(getV('showIsodoses'))
                       % Plot the isodoses   
                       hold on; plotIsodosesOnCurrentCrossPosition(3); hold off;
                    end
                    
                    % if 'showDwell' is selected plot dwell positions 
                    if getV('showDwell');
                        hold on; plotDwellPositions(3); hold off
                    end
                    
              case 'Sagital' % saggital is for constant x
                    % show the dicom image
                     imagesc([1:512],[1:32],imrotate(squeeze(currentPatient.CTimages(:,crossPosition.y,:)),90));
                     pbaspect([1 0.5 1]),colormap gray,caxis([Level-(Window/2)  Level+(Window/2)]);
                     
                     
                    %If 'showVOIS' is selected, show vois based on current
                    %cross position
                    if(getV('showVOIS'))  
                      % Plot the VOIS
                      hold on; plotVOIsOnCurrentCrossPosition(2); hold off
                    end
                   
                    %If 'showIsodoses' is selected, show isodose distribution
                    % based on current cross position 
                    if(getV('showIsodoses'))
                      % Plot the isodoses  
                      hold on; plotIsodosesOnCurrentCrossPosition(2); hold off;
                    end
                    
                    % if 'showDwell' is selected plot dwell positions 
                    if getV('showDwell');
                        hold on; plotDwellPositions(2); hold off
                    end
                    
                   
              case 'Coronal'   
                    % show the dicom image
                    imagesc(imrotate(squeeze(currentPatient.CTimages(crossPosition.x,:,:)),90));
                    pbaspect([1 1 1]), colormap gray,caxis([Level-(Window/2)  Level+(Window/2)]);
                   
                    %If 'showVOIS' is selected, show vois based on current
                    %cross position
                    if(getV('showVOIS'))  
                      % Plot the VOIS
                      hold on; plotVOIsOnCurrentCrossPosition(1); hold off
                    end
                   
                    %If 'showIsodoses' is selected, show isodose distribution
                    % based on current cross position 
                    if(getV('showIsodoses'))
                      % Plot the isodoses  
                      hold on; plotIsodosesOnCurrentCrossPosition(1); hold off
                    end
                    
                    % if 'showDwell' is selected plot dwell positions 
                    if getV('showDwell');
                        hold on; plotDwellPositions(1); hold off
                    end
                   
            end
            applyZoom(view);  
        end
    

        
       %If 'showVOIS' is selected, show vois based on current cross position
       function plotVOIsOnCurrentCrossPosition(orientation)
       
        voiNames = fieldnames(currentPatient.contourManager.VOIs);
        
        for i = 1:currentPatient.contourManager.numOfVOIs
           selectedVOI = i;
               if currentPatient.contourManager.voisProperties(selectedVOI).visible
                   if currentPatient.contourManager.VOIs.(voiNames{selectedVOI}).hasContourData == 1 
                     ContourData = currentPatient.contourManager.VOIs.(voiNames{selectedVOI}).indexedContourData;


                       if orientation == 1  % coronal
                           
                           ind = find(round(ContourData(:,2)) == crossPosition.x);
                           if numel(ind)>0
                              ContoursInSlice = ContourData(ind,:);
                              for flag=1:max(ContoursInSlice(:,4));
                                  ind2 = find(ContoursInSlice(:,4) == flag);
                                  if numel(ind2)>0
                                      ContourSetInSlice = ContoursInSlice(ind2,1:3);
                                      sliceNumber = size(currentPatient.CTimages,3);
                                      ContourSetInSlice(:,3) = sliceNumber - ContourSetInSlice(:,3);
                                      plot(ContourSetInSlice(:,1),ContourSetInSlice(:,3),'.','Color',currentPatient.contourManager.voisProperties(selectedVOI).color/255,'markersize',5)
                                  end
                              end
                           end 

                       elseif orientation == 2  % sagittal
                           ind = find(round(ContourData(:,1)) == crossPosition.y);
                           if numel(ind)>0
                              ContoursInSlice = ContourData(ind,:);
                              for flag=1:max(ContoursInSlice(:,4));
                                  ind2 = find(ContoursInSlice(:,4) == flag);
                                  if numel(ind2)>0
                                      ContourSetInSlice = ContoursInSlice(ind2,1:3);
                                      sliceNumber = size(currentPatient.CTimages,3);
                                      ContourSetInSlice(:,3) = sliceNumber - ContourSetInSlice(:,3);
                                      
%                                       bw = poly2mask(ContourSetInSlice(:,2),ContourSetInSlice(:,3),32,512) ;                                   
%                                       contour(bw,1,'-r')
                                      
                                      plot(ContourSetInSlice(:,2),ContourSetInSlice(:,3),...
                                           '.','Color',currentPatient.contourManager.voisProperties(selectedVOI).color/255,'markersize',5)
                                  end
                              end
                           end 
                           

                       elseif orientation == 3
                           ind = find(round(ContourData(:,3)) == crossPosition.z);
                           if numel(ind)>0
                              ContoursInSlice = ContourData(ind,:);
                              for flag=1:max(ContoursInSlice(:,4));
                                  ind2 = find(ContoursInSlice(:,4) == flag);
                                  if numel(ind2)>0
                                      ContourSetInSlice = ContoursInSlice(ind2,1:3);
                                      plot(ContourSetInSlice(:,1),ContourSetInSlice(:,2),'-','Color',currentPatient.contourManager.voisProperties(selectedVOI).color/255,'linewidth',2)
                                  end
                              end
                           end

                       end
                   end %if hasContourData
               end %if contour visible property is on
        end %for
           
       end %function
    
        
        % plot the isodoses on the current cross position based on the
       % chosen orientation
       function plotIsodosesOnCurrentCrossPosition(orientation)
           
              isodoseProperties = getV('isodoseProperties');
              isodoseLevels = isodoseProperties.Value.*isodoseProperties.Status;
              if orientation == 2
                  if crossPosition.x >= currentPatient.RTDOSEcoordinates.xind(1) && ...
                     crossPosition.x <= currentPatient.RTDOSEcoordinates.xind(end)
                 
                    dmap = squeeze(interp3(currentPatient.RTDOSEcoordinates.xind,....
                                           currentPatient.RTDOSEcoordinates.yind,...
                                           currentPatient.RTDOSEcoordinates.zind,...
                                           currentPatient.RTDOSE,double(crossPosition.x),...
                                           currentPatient.RTDOSEcoordinates.yind,...
                                           currentPatient.RTDOSEcoordinates.zind,'nearest'));
                                       
                    [c,hcont] = contour(currentPatient.RTDOSEcoordinates.yind,...
                                        currentPatient.RTDOSEcoordinates.zind,dmap',...
                                        isodoseLevels,'-');
                              
                    cc = get(hcont,'children'); 
                   
                    for ic = 1:numel(cc)
                       ind = find(isodoseProperties.Value == get(cc(ic),'UserData'));
                       set(cc(ic),'EdgeColor',isodoseProperties.Color(ind,:), ...
                                  'LineStyle','-','LineWidth',isodoseProperties.LineThickness(ind))
                    end
                   
                    clear dmap
                  end
                  
              elseif orientation == 1
                 if crossPosition.y >= currentPatient.RTDOSEcoordinates.yind(1) && ...
                    crossPosition.y <= currentPatient.RTDOSEcoordinates.yind(end)
                
                     dmap = squeeze(interp3(currentPatient.RTDOSEcoordinates.xind,....
                                           currentPatient.RTDOSEcoordinates.yind,...
                                           currentPatient.RTDOSEcoordinates.zind,...
                                           currentPatient.RTDOSE,...
                                           currentPatient.RTDOSEcoordinates.xind,...
                                           double(crossPosition.y),...
                                           currentPatient.RTDOSEcoordinates.zind,'nearest'));
                                       
                   [c, hcont] = contour(currentPatient.RTDOSEcoordinates.xind,....
                                        currentPatient.RTDOSEcoordinates.zind,dmap',...
                                        isodoseLevels,'-');
                              
                   cc = get(hcont,'children'); 
                   
                   for ic = 1:numel(cc)
                       ind = find(isodoseProperties.Value == get(cc(ic),'UserData'));
                       set(cc(ic),'EdgeColor',isodoseProperties.Color(ind,:), ...
                                  'LineStyle','-','LineWidth',isodoseProperties.LineThickness(ind))
                   end
                
                    clear dmap
                    
                 end
                 
              elseif orientation == 3
                 if crossPosition.z >= currentPatient.RTDOSEcoordinates.zind(1) && ...
                    crossPosition.z <= currentPatient.RTDOSEcoordinates.zind(end)

                   [c, hcont]= contour(currentPatient.RTDOSEcoordinates.xind,...
                               currentPatient.RTDOSEcoordinates.yind,...
                               currentPatient.RTDOSE(:,:,crossPosition.z),...
                               isodoseLevels,'-');
                              
                   cc = get(hcont,'children'); 
                   
                   for ic = 1:numel(cc)
                       ind = find(isodoseProperties.Value == get(cc(ic),'UserData'));
                       set(cc(ic),'EdgeColor',isodoseProperties.Color(ind,:), ...
                                  'LineStyle','-','LineWidth',isodoseProperties.LineThickness(ind))
                   end
                
                 end
                 
              end
              
                        
       end
        
    
        % plot dwell positions
        function plotDwellPositions(orientation)
              dwellMarkerProperties = getV('dwellMarkerProperties');
              
              if orientation == 1   % coronal 
                 % plot only the dwell positions laying on the plotted slice 
                 ind = find(round(currentPatient.dwellPositionManager.indexedDwell3Dpositions(:,2)) == crossPosition.x);
                 if numel(ind)>0
                     dwPositionsInSlice = currentPatient.dwellPositionManager.indexedDwell3Dpositions(ind,:);
                     sliceNumber = size(currentPatient.CTimages,3);
                     plot(dwPositionsInSlice(:,1),sliceNumber-dwPositionsInSlice(:,3),'o',...
                            'MarkerEdgeColor',dwellMarkerProperties.Color,...
                            'MarkerFaceColor',dwellMarkerProperties.Color,...
                            'markersize',dwellMarkerProperties.Size);
                 end 
                 clear ind dwPositionsInSlice 
                 
              elseif orientation == 2  % sagital 
                
                 % plot only the dwell positions laying on the plotted slice 
                 ind = find(round(currentPatient.dwellPositionManager.indexedDwell3Dpositions(:,1)) == crossPosition.y);
                 if numel(ind)>0
                     dwPositionsInSlice = currentPatient.dwellPositionManager.indexedDwell3Dpositions(ind,:);
                     sliceNumber = size(currentPatient.CTimages,3);
                     plot(dwPositionsInSlice(:,2),sliceNumber-dwPositionsInSlice(:,3),'o',...
                            'MarkerEdgeColor',dwellMarkerProperties.Color,...
                            'markerfacecolor',dwellMarkerProperties.Color,...
                            'markersize',dwellMarkerProperties.Size);
                 end 
                 
                  
              elseif orientation == 3
                 
                 % plot only the dwell positions laying on the plotted slice 
                 ind = find(round(currentPatient.dwellPositionManager.indexedDwell3Dpositions(:,3)) == crossPosition.z);
                 if numel(ind)>0
                     dwPositionsInSlice = currentPatient.dwellPositionManager.indexedDwell3Dpositions(ind,:);
                     plot(dwPositionsInSlice(:,1),dwPositionsInSlice(:,2),'o',...
                            'MarkerEdgeColor',dwellMarkerProperties.Color,...
                            'markerfacecolor',dwellMarkerProperties.Color,...
                            'markersize',dwellMarkerProperties.Size);
                 end 
              
              end
          
        end

    
    
        function applyZoom(view)
        
            currentZoom =getV(strcat(view,'Zoom'))
            try
            set(gca,'XLim',[currentZoom(1) currentZoom(2)],...
                    'YLim',[currentZoom(3) currentZoom(4)],...
                    'ZLim',[currentZoom(5) currentZoom(6)]);
            catch e
%                 disp(e.message);
%                 disp('update single viewer');
            end
        end
      toc
   

end

