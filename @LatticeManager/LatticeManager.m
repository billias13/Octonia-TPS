classdef LatticeManager < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    properties
       
        reducedCube
        DensityLimits 
          
        Universes
        
        Lattice   
        latticeCoordinates

    end
    
    methods
        
        function obj = LatticeManager(username, filename, resolution, numofparticles, loadingBarHandle,loadingTextHandle)
            
 
            currentPatient = getV('currentPatient');
            
            
            disp('Down sample CT images ...');
            obj.reduceVolume(resolution,currentPatient.DensityCube,...
                                        currentPatient.CTcoordinates);      % downsample the CTimages based on selected resolution 
            
            
            disp('Create lattice ...');
            
            obj.DefineDensityLimits();                                      % load density limits 
            obj.createLattice;                                              % create the Lattice based on the imported density limits 
            obj.createUniverses;                                            % create the universe filling the Lattice  
            
            disp('Start writing MCNP input file ...'); 
            tic
            
                fid = fopen(filename,'w');                                  % open file for writing the input file
 
                disp('Writing header ...'); 
                obj.writeHeader(fid,currentPatient,username);               % write the header 

                disp('Writing cell description of used universes ...'); 
                obj.writeUniverses(fid);                                   % write cell description of used universes

                disp('Filling lattice with universes...');
                obj.writeLattice(fid, loadingBarHandle,loadingTextHandle); % write lattice description 

                disp('Writing surface definitions ...');   
                obj.writeSurfaces(fid);                                    % describe used surfaces

                disp('Writing material definitions ...'); 
                obj.writeMaterials(fid);                                   % write material composition 
                
                disp('Wrtiting source definitions ...') 
                obj.writeSource(fid,currentPatient.dwellPositionManager.allDwellPositions) % write source information (phae space)
    
                disp('Writing scoring tallies ....')
                obj.writeScoring(fid,currentPatient.RTDOSEcoordinates);    % write the scoring tally (*FMESH4) 
    
                fprintf(fid,'spdtl on\n');                                 % set speed tally on
                fprintf(fid,'nps %g \n',numofparticles);                   % write nps card     

                disp('Finish writing input file')
                fclose(fid);

           toc
            
%              obj.ExportMCNPinput_lattice(currentPatient,filename,username,numofparticles, loadingBarHandle,loadingTextHandle)
        
            clear currentPatient;
            clear obj.HUcube;
            clear obj.DensityCube;
        end
        
        
        % this functions reduces the relusotion of the CT images 
        function reduceVolume(obj,resolution,DensityCube,coordinateSystem)
            
            reduceFactor = [size(DensityCube,1)./resolution,...
                            size(DensityCube,2)./resolution,1];
            
            [xx,yy,zz,obj.reducedCube] = reducevolume(coordinateSystem.x,...
                                                      coordinateSystem.y,...
                                                      coordinateSystem.z,...
                                                      DensityCube,reduceFactor);
            obj.latticeCoordinates.x = xx(1,1:size(xx,2))';
            obj.latticeCoordinates.y = yy(1,1:size(yy,2))';
            obj.latticeCoordinates.z = zz(1,1:size(zz,3))';
        
        end
                
           
        
        % Obtain a logical number depending on the density value of each voxel 
        % based on predefined density limits 
        function createLattice(obj)
            
           obj.reducedCube(obj.reducedCube > obj.DensityLimits(end)) = obj.DensityLimits(end); 
           obj.Lattice = zeros(size(obj.reducedCube),'uint8');

           for i=1:numel(obj.DensityLimits)
               if i == 1 
                  obj.Lattice = obj.Lattice + uint8((obj.reducedCube <= obj.DensityLimits(i)));
               else
                  obj.Lattice = obj.Lattice + uint8((obj.reducedCube > obj.DensityLimits(i-1) & ...
                                                     obj.reducedCube <= obj.DensityLimits(i))*i);
               end
           end
           
        end

        
        % create the universe numbers for the lattice elements
        function createUniverses(obj)
           
            UniqueUniverses = unique(obj.Lattice);
            load Elemental_composition.mat
            
            for i=1:numel(UniqueUniverses)
                 % choose material number
                  obj.Universes(i,1) = find(Composition.DensityRange >= obj.DensityLimits(UniqueUniverses(i)),1);

                 % choose density    
                  if UniqueUniverses(i) == 1
                     obj.Universes(i,2) = 0.0012;
                  else
                     obj.Universes(i,2) = obj.DensityLimits(UniqueUniverses(i));
                  end
            end
                
            obj.Universes(:,3) = -1;                 % inside surface rpp 1
            obj.Universes(:,4) = UniqueUniverses;    % universe No.
            
        end
       
        % write a header in the input file 
        function writeHeader(obj,fid,currentPatient,username)

            fprintf(fid,'c -------------------------------------------------------------------------------- \n');
            fprintf(fid,'c -----  This is an input file for the MCNP Monte Carlo code created         ----- \n'); 
            fprintf(fid,'c -----                 using the OKTONIA TPS Software                       ----- \n');  
            fprintf(fid,'c -------------------------------------------------------------------------------- \n');
            fprintf(fid,'c ---------------------  INPUT FILE CREATION DETAILS ----------------------------- \n');
            fprintf(fid,'c  1.  Patient Name : %s \n',currentPatient.patientName);  
            fprintf(fid,'c  2.  Patient ID   : %s \n',currentPatient.patientID);
            fprintf(fid,'c  3.  CT study ID  : %s \n',currentPatient.CTinfo.StudyID);  
            fprintf(fid,'c  4.  CT scan date : %s \n',currentPatient.CTinfo.StudyDate);  
            fprintf(fid,'c  5.  Plan name    : %s\n',currentPatient.RTPLAN.RTPlanLabel);
            fprintf(fid,'c  6.  Plan date    : %s\n',currentPatient.RTPLAN.RTPlanDate);
            fprintf(fid,'c  7.  TPS          : %s\n',currentPatient.RTPLAN.StationName);
            fprintf(fid,'c  8.  Brachy Treatment Technique : %s\n',currentPatient.RTPLAN.BrachyTreatmentTechnique);
            fprintf(fid,'c  9.  Brachy Treatment Type      : %s\n',currentPatient.RTPLAN.BrachyTreatmentType);
            fprintf(fid,'c  10. Geometry creation method   : LATTICE \n');  
            fprintf(fid,'c  11. Resolution                 : %g x %g x %g\n',size(obj.Lattice,2),size(obj.Lattice,1),size(obj.Lattice,3));  
            fprintf(fid,'c  12. Input file created by      : %s\n',username); 
            fprintf(fid,'c  13. Input file creation date   : %s\n',date); 
            fprintf(fid,'c -------------------------------------------------------------------------------- \n');
            fprintf(fid,'c\n');

    
        end

        % Cell description of used universes
        function writeUniverses(obj,fid)

            fprintf(fid,'c ----------------- START WRITING CELL DEFINITIONS  ----------------------------- \n');
            
            fprintf(fid,'c start universe definitions\n');
            
            ii = 0;
            for i = 1:size(obj.Universes,1)
                ii = ii + 1;
                fprintf(fid,'%g  %g  -%g  %g  u = %g   imp:p = 1\n',ii,obj.Universes(i,1),obj.Universes(i,2),obj.Universes(i,3),obj.Universes(i,4));
                ii = ii + 1;
                fprintf(fid,'%g  0           %g  u = %g   imp:p = 0\n',ii,-obj.Universes(i,3),obj.Universes(i,4));
            end

            fprintf(fid,'c finish universe definitions\n');
            
        end
        
        % define and fill the lattice with the defined universes
        function writeLattice(obj,fid, loadingBarHandle, loadingTextHandle)

            fprintf(fid,'150  0 -2  fill = 100 imp:p = 1  $fill space with lattice\n');
            fprintf(fid,'151  0 -1  u = 100 lat = 1 fill = 0:%g 0:%g 0:%g $ fill lattice with universes \n',size(obj.Lattice,2)-1,size(obj.Lattice,1)-1,size(obj.Lattice,3)-1);
            fprintf(fid,'       ');

                sizeZ = size(obj.Lattice,3);
                sizeX = size(obj.Lattice,1);
                sizeY = size(obj.Lattice,2);

                loadingProgress = ones(1, sizeZ);
                set(gcf,'CurrentAxes',loadingBarHandle);
                imshow(loadingProgress);
                set(loadingBarHandle,'Visible','on');
                set(loadingTextHandle,'Visible','on');

                NumRepeats = 0;
                m = 0;

                totalEntries = 1;
                a = cell(1,sizeY);

                    for k = 1:sizeZ

                         loadingProgress(1,k) = 0;
                         imshow(loadingProgress,'Colormap',jet(255));
                         set(loadingTextHandle,'String', num2str(k));
                         pause(0.001);

                         for j = 1:sizeX

                             totalEntries = 1;
                             for i = 1:sizeY 

                                if m > 12
                                    %DON'T CHANGE LINE EXEPT WHEN m == 11
                                    m = 0;
                                    a{1,totalEntries} = sprintf('\n        ');
                                    totalEntries = totalEntries + 1;
                                end

                                if i > 1 && obj.Lattice(j,i,k) == obj.Lattice(j,i-1,k) 
                                    repeat = 'y';
                                    NumRepeats = NumRepeats + 1;
                                else 
                                   repeat = 'n';
                                   a{1,totalEntries} = sprintf('%g ',obj.Lattice(j,i,k));
                                   totalEntries = totalEntries + 1;
                                   m = m + 1 ;
                                   continue;
                                end
            
                                if repeat == 'y'
                                   if i == sizeY
                                        a{1,totalEntries} = sprintf('%gr ',NumRepeats);
                                        totalEntries = totalEntries + 1;
                                        m = m + 1   ;
                                        NumRepeats = 0;
                                   elseif (obj.Lattice(j,i,k) ~= obj.Lattice(j,i+1,k))              
                                        a{1,totalEntries} = sprintf('%gr ',NumRepeats);
                                        totalEntries = totalEntries + 1;
                                        m = m + 1;
                                        NumRepeats = 0;
                                   end
                                end
                     
                             end  % end i for loop
                     
                             fprintf(fid,'%s',a{1,1:totalEntries-1});
                   
                         end   % end j for loop
                 
                    end  % end k for loop
                    
                    set(loadingBarHandle,'Visible','off');

                    fprintf(fid,'imp:p = 1\n');
                    fprintf(fid,'c\n');
                    fprintf(fid,'200     0                2      imp:p = 0    $ outside void space\n');  
                    fprintf(fid,'c ----------------- FINISH WRITTING CELL DEFINITIONS  ------------------------------ c\n');
                    fprintf(fid,'\n');
       
        end  
        
        % Calculate and write surface definitions in the input file
        function writeSurfaces(obj,fid)

            
           % Round the latticeCoordinates to the 5th decimal digit to avoid
           % incomplete filling of FOV (containing the lattice) with voxels
           roundedCoordinates.x = (round(obj.latticeCoordinates.x*1E5))./1E5;
           roundedCoordinates.y = (round(obj.latticeCoordinates.y*1E5))./1E5;
           roundedCoordinates.z = (round(obj.latticeCoordinates.z*1E5))./1E5;
           
           
           % calculate the planes for the RPP describing the voxels (MCNP
           % manual : RPP xmin xmax ymin ymax zmin zmax)
           voxelRPP = [roundedCoordinates.x(1) - (roundedCoordinates.x(2)-roundedCoordinates.x(1))/2,...
                       roundedCoordinates.x(1) + (roundedCoordinates.x(2)-roundedCoordinates.x(1))/2,...
                       roundedCoordinates.y(1) - (roundedCoordinates.y(2)-roundedCoordinates.y(1))/2,...
                       roundedCoordinates.y(1) + (roundedCoordinates.y(2)-roundedCoordinates.y(1))/2,...
                       roundedCoordinates.z(1) - (roundedCoordinates.z(2)-roundedCoordinates.z(1))/2,...
                       roundedCoordinates.z(1) + (roundedCoordinates.z(2)-roundedCoordinates.z(1))/2];
           
           
           % calculate the planes for the RPP describing the FOV (MCNP
           % manual : RPP xmin xmax ymin ymax zmin zmax)
           fovRPP = [voxelRPP(1),roundedCoordinates.x(end) + (roundedCoordinates.x(2)-roundedCoordinates.x(1))/2,...
                     voxelRPP(3),roundedCoordinates.y(end) + (roundedCoordinates.y(2)-roundedCoordinates.y(1))/2,...
                     voxelRPP(5),roundedCoordinates.z(end) + (roundedCoordinates.z(2)-roundedCoordinates.z(1))/2];
           

           fprintf(fid,'c ----------------- START WRITTING SURFACE DEFINITIONS  ---------------------------- c\n');

           % write the RPP for the voxel
           for i=1:6
               if i == 1
                   fprintf(fid,'1 rpp  %g \n',voxelRPP(i));
               else
                   fprintf(fid,'       %g \n',voxelRPP(i));
               end
           end
           
           % write the RPP for the FOV
           for i=1:6
               if i == 1
                   fprintf(fid,'2 rpp  %g \n',fovRPP(i));
               else
                   fprintf(fid,'       %g \n',fovRPP(i));
               end
           end                                           
                         
           fprintf(fid,'20 cz  0.03\n');           
           fprintf(fid,'21 pz -0.3505\n'); 
           fprintf(fid,'22 pz  0.3505\n'); 
   
           fprintf(fid,'c ---------------- FINISH WRITTING SURFACE DEFINITIONS  -------------------------- c\n');
           fprintf(fid,'\n');

        end
        
        % Write used material compositions 
        function writeMaterials(obj,fid)


            fprintf(fid,'c ----------------- START WRITTING MATERIAL DEFINITIONS ----------------------------\n');

            load Elemental_composition.mat

            UsedElements = obj.Universes(:,1); 

            for i=1:size(Composition.HUrange,2)

             if ~isempty(find(UsedElements, i)) 
                 w = -cell2mat(Composition.Weights(i,:));
                 NonZeroElements = sum(w~=0);
                 counter = 1;

                 for j=1:12

                     if w(j) ~= 0
                        if counter == 1  
                          fprintf(fid,'%s  %g000.04p %g&', strcat('M',int2str(i)),cell2mat(Composition.AtomicNumbers(j)),w(j));
                          fprintf(fid,'\n');
                          counter = counter + 1;
                        elseif counter > 0 && counter < NonZeroElements
                           fprintf(fid,'    %g000.04p %g&', cell2mat(Composition.AtomicNumbers(j)),w(j));
                           fprintf(fid,'\n');
                           counter = counter + 1;
                        elseif counter == NonZeroElements
                           fprintf(fid,'    %g000.04p %g', cell2mat(Composition.AtomicNumbers(j)),w(j));
                           fprintf(fid,'\n');
                           counter = counter + 1;
                        end
                     end
                 end
             end

            end

            fprintf(fid,'c -------------- FINISH WRITTING MATERIAL DEFINITIONS ------------------------------ c\n');


        end

        % write source information        
        function writeSource(obj,fid,allDwellPositions)

            fprintf(fid,'c\n');
            fprintf(fid,'c  Only photons will be tracked. Scoring is performed using kerma aproximation\n');
            fprintf(fid,'mode p\n');
            fprintf(fid,'c\n');
    
            fprintf(fid,'c ---------------------- START SOURCE DEFINITION --------------------------------- \n');
            fprintf(fid,'SSR  OLD 20 21 22 NEW 20 21 22 PTY = 2 COl = 0 TR = D1\n');

            % the TR matrices that will be sampled with a probability distribution
            % SI1 - SP1. SI1 are the bins which are lines.  
            fprintf(fid,'SI1  L ');

            entry_counter = 0;
                for i=1:size(allDwellPositions,1) 
                    fprintf(fid,'%g ',i);
                    entry_counter = entry_counter + 1;
                    if entry_counter > 5 && i < size(allDwellPositions,1)
                        entry_counter = 0;
                        fprintf(fid,'\n');
                        fprintf(fid,'      ');
                    end
                end
            fprintf(fid,'\n');

            % the Probabilities are the irradiation times of each dwell position normalized
            % to the total irradiation time.
            fprintf(fid,'SP1  ');
            entry_counter = 0;
                for i=1:size(allDwellPositions,1) 
                    fprintf(fid,'%g ',allDwellPositions(i,7)./sum(allDwellPositions(:,7)));
                    entry_counter = entry_counter + 1;
                    if entry_counter > 5 && i < size(allDwellPositions,1)
                        entry_counter = 0;
                        fprintf(fid,'\n');
                        fprintf(fid,'      ');
                    end
                end
            fprintf(fid,'\n');

                % the Transformation matrices defined at SI1
                for i=1:size(allDwellPositions,1) 
                    fprintf(fid,'TR%g  ',i);
                    for j=1:6
                        fprintf(fid,'%g  ',allDwellPositions(i,j));
                    end
                    fprintf(fid,'\n');
                end
            fprintf(fid,'c --------------------- FINISH SOURCE DEFINITION -------------------------------- \n');
    
        end
        
        % write scoring tallies. Water kerma in medium will be scored
        function writeScoring(obj,fid,RTDOSEcoordinates)
    
                x = RTDOSEcoordinates.x*10;
                y = RTDOSEcoordinates.y*10;
                z = RTDOSEcoordinates.z*10;

                fprintf(fid,'c ------------------------ START SCORING CARDS ----------------------------------\n');
                fprintf(fid,'*fmesh4:p   geom = rec \n');
                fprintf(fid,'          origin = %g %g %g \n',x(1),y(1),z(1));   
                fprintf(fid,'           imesh = %g iints = %g \n',x(end),numel(x));
                fprintf(fid,'           jmesh = %g jints = %g \n',y(end),numel(y));
                fprintf(fid,'           kmesh = %g kints = %g \n',z(end),numel(z));
                fprintf(fid,'           out = ij \n');
                fprintf(fid,'c -------------------------------------------------------------------\n');
                fprintf(fid,'c    Energy(MeV) - men_ro (cm²/g)  for water (taken from www.nist.gov)\n');
                fprintf(fid,'c -------------------------------------------------------------------\n');
                fprintf(fid,'DE4  0.001  0.0015 0.002  0.003  0.004 \n');
                fprintf(fid,'     0.005  0.006  0.008  0.010  0.015 \n');
                fprintf(fid,'     0.020  0.030  0.040  0.050  0.060 \n');
                fprintf(fid,'     0.080  0.100  0.150  0.200  0.300 \n');
                fprintf(fid,'     0.400  0.500  0.600  0.800  1.000 \n');
                fprintf(fid,'DF4  4064.718 1372.3140 615.1740 191.67100 81.89900 \n');
                fprintf(fid,'     41.87800   24.0520   9.9130   4.94339  1.37335 \n');
                fprintf(fid,'      0.55027    0.15564  0.06946  0.04223  0.03190 \n');
                fprintf(fid,'      0.02597    0.02546  0.02764  0.02967  0.03192 \n');
                fprintf(fid,'      0.03278    0.03299  0.03284  0.03206  0.03103 \n');
                fprintf(fid,'c ------------------------- FINISH SCORING CARDS --------------------------------\n');

        end
        
        
    end % end of methods
    
end



