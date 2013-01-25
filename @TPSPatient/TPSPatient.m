classdef TPSPatient < handle
%  This class is part of the OctoniaTPS GUI for creating
%  input files for the MCNP code.
% 
%  The class handles the information exported by the Treatment Planning
%  System i.e., the CT dicom images describing the Patient geometry
%  the VOIs delineated by the TPS user (RTSS), the plan information (RTPLAN)
%  and the Dose cube calculated by the TPS (RTDOSE)
%
%  Object properties
    properties
       
        patientPath;   % the path to the patient files
        patientID;     % the ID given to the patient by the CT (also used by the TPS)
        patientName;   % the name of the patient
        patientData;   
        patientSex;
        patientBirthDate;
       
        studyDate;    % the date that the CT study was acquired
        seriesDate;  
        stationName; 
   
        
        CTimages;     % the cube with the CTimages of the patient
       
        CTinfo;       % a structure containing information extracted by the CT dicominfo
        CTcoordinates;% the coordinate system of the CT
        hasCT;        % a flag showing that the CTimages were imported
        
        hasRTPLAN;    % a flag showing that the RTPLAN was imported
        RTPLAN = [];       % the RTPLAN
       
        hasRTSS;      % a flag showing that the RTSS was imported
        RTSS = [];         % the RTSS
       
        hasRTDOSE;    % a flag showing that the RTDOSE was imported
        RTDOSE = [];       % the RTDOSE
        RTDOSEinfo = [];   % a structure containing the information relative to the RTDOSE
        RTDOSEcoordinates =[]; % the coordinate system of the RTDOSE cube
       
        progressBar;
       
        contourManager; % a class handling the delineated contours
        dwellPositionManager % a class handling the dwell positions, irradiation times and catheter positions
        sizeOfVois;
    end
   
% Object methods
    methods
       
    % The constructor
        function obj = TPSPatient(path, info, data, loadFullStudy)
           
            obj.hasCT =0; obj.hasRTSS = 0; obj.hasRTPLAN = 0; obj.hasRTDOSE = 0;
           
           
            obj.patientPath = path;
            obj.patientName = info{2};
            obj.patientData = data;
           
            %Extract patient info from the dataset
            obj.patientSex = obj.patientData{1,1}.PatientSex;
            obj.patientID = obj.patientData{1,1}.PatientID;
            obj.patientBirthDate = obj.patientData{1,1}.PatientBirthDate;
           
            obj.studyDate = obj.patientData{1,1}.StudyDate;
            obj.seriesDate = obj.patientData{1,1}.SeriesDate;
            obj.stationName = obj.patientData{1,1}.StationName;
           
            obj.progressBar = waitbar(0,'Loading patient CT data...');
           
            %Read CT data. This action is performed always in order to
            %initialize a patient
            if true
                readCTimages(obj);
                readCTcoordinateSystem(obj);
            end
           
            %Get RTDose, RTPlan, RTSS. This actions are performed only if a
            %patient is initialized through the "loadFullStudy" mode
            obj.contourManager = {};
            obj.dwellPositionManager = {};
            
            if loadFullStudy
               
                tic;
                obj.readRTexport();
                
                obj.build_RTDOSEcoordinate_system();
                               
                obj.contourManager = VOIManager(obj.RTSS,obj.CTinfo,obj.CTcoordinates,obj.progressBar);

                obj.dwellPositionManager = DwellPositionManager(obj.RTSS,obj.RTPLAN,obj.CTinfo);
                
                waitbar(1, obj.progressBar ,'Extract source dwell position information...');
                
                toc;
                close(obj.progressBar);
                
            else
               close(obj.progressBar);
            end
            
            %PROBABLY AT THIS POINT, patientData should be deleted!!!
            obj.patientData= {};
        end
       
        
      % Read CT images from patient data
        function readCTimages(obj)
            
            i = 1;
            while i <= size(obj.patientData,2) && strcmp(obj.patientData{1,i}.Modality,'CT') == 1
                 
                waitbar((i/size(obj.patientData,2)), obj.progressBar ,'Loading patient CT data...');
                
                unSorted{i,1} = obj.patientData{1,i}.SliceLocation;
                unSorted{i,2} = obj.patientData{1,i}.Filename;
                i = i + 1;
                
            end
            
              Sorted = sortrows(unSorted);
              for i = 1:size(Sorted,1)
                  
                  waitbar((i/size(Sorted,1)),obj.progressBar,'Sorting patient CT data...');
                  
                  obj.CTimages(:,:,i) = dicomread(Sorted{i,2});
                  info{i} = dicominfo(Sorted{i,2});
                  
              end
            
            try
                
              obj.CTinfo = info{1};  
              for i=1:size(Sorted,1)
                  
                  waitbar((i/size(Sorted,1)),obj.progressBar,'Extracting information from CT dicom series...');
                  
                  ImagePositionPatient(i,:) = double(info{i}.ImagePositionPatient)';
                  
              end
              
              obj.CTinfo.ImagePositionPatientAll = ImagePositionPatient;
              obj.hasCT = 1;
              
            catch err
            
            end
 
        end
        
        
       % create the CT coordinate system
        function readCTcoordinateSystem(obj)
           info = obj.CTinfo;
          
            for i=1:double(info.Columns)
                obj.CTcoordinates.x(i,1) = double(info.ImagePositionPatientAll(1,1)) + ...
                                           (i-1)*double(info.PixelSpacing(1));
            end
            for i=1:double(info.Rows)
               obj.CTcoordinates.y(i,1) = double(info.ImagePositionPatientAll(1,2)) + ...
                                           (i-1)*double(info.PixelSpacing(2));
            end
                obj.CTcoordinates.z= info.ImagePositionPatientAll(:,3);
           

        end
       
        
      % Read RTDOSE exported file
        function readRTDose(obj)

           
           if isempty(obj.RTDOSE)
                [RTDOSEfilename,RTDOSEpathname] = uigetfile({'*.dcm';'*.*'},'Select RTDOSE file of the plan',...
                                             'MultiSelect', 'off');
                 if ischar(RTDOSEfilename) && ischar(RTDOSEpathname)
                 obj.RTDOSEinfo = dicominfo(fullfile(RTDOSEpathname,RTDOSEfilename));
                 obj.RTDOSE = dicomread(obj.RTDOSEinfo);
                 obj.RTDOSE = double(squeeze(obj.RTDOSE)).*obj.RTDOSEinfo.DoseGridScaling;
                
                 build_RTDOSEcoordinate_system(obj);
             
                 obj.hasRTDOSE = 1;
                end
            end
           
        end  
        
        
        % create the RTDOSE coordinate systems (in mm)
        function build_RTDOSEcoordinate_system(obj)
            for i=1:double(obj.RTDOSEinfo.Columns)
                obj.RTDOSEcoordinates.x(i,1) = double(obj.RTDOSEinfo.ImagePositionPatient(1)) + ...
                                                (i-1)*double(obj.RTDOSEinfo.PixelSpacing(1));
            end
            for i=1:double(obj.RTDOSEinfo.Rows)
                obj.RTDOSEcoordinates.y(i,1) = double(obj.RTDOSEinfo.ImagePositionPatient(2)) + ...
                                                (i-1)*double(obj.RTDOSEinfo.PixelSpacing(2));
            end
            for i=1:double(obj.RTDOSEinfo.NumberOfFrames)
                obj.RTDOSEcoordinates.z(i,1) = double(obj.RTDOSEinfo.ImagePositionPatient(3)) + ...
                                               double(obj.RTDOSEinfo.GridFrameOffsetVector(i));
            end
           
           
            % Now calculate RTDOSEcoordinates in the CT indexed coordinate system for plotting the isodose dose distribution 
              obj.RTDOSEcoordinates.xind = 1 + (obj.RTDOSEcoordinates.x - obj.CTinfo.ImagePositionPatientAll(1,1))./obj.CTinfo.PixelSpacing(1);
              obj.RTDOSEcoordinates.yind = 1 + (obj.RTDOSEcoordinates.y - obj.CTinfo.ImagePositionPatientAll(1,2))./obj.CTinfo.PixelSpacing(2);
              obj.RTDOSEcoordinates.zind = 1 + (obj.RTDOSEcoordinates.z - obj.CTinfo.ImagePositionPatientAll(1,3))./obj.CTinfo.SliceThickness;
          
        end
        
        
      % Read RTSS exported file
        function readRTSS(obj)
            
           obj.RTSS  = [];
            if isempty(obj.RTSS)
                
               [RTSSfilename,RTSSpathname] = uigetfile({'*.dcm';'*.*'},'Select RTSTRUCT file of the plan',...
                                             'MultiSelect', 'off');
              
                if ischar(RTSSfilename) && ischar(RTSSpathname)
                    tic;
                    obj.progressBar = waitbar(0,'Generating contours...');
                    obj.RTSS = dicominfo(fullfile(RTSSpathname,RTSSfilename));
%                     obj.contourManager = VOIManager(obj.RTSS,obj.CTinfo);
                    
                    waitbar(0.33, obj.progressBar ,'Generating contours...');
%                     obj.contourManager = ContoursHandler(obj.RTSS);
                    waitbar(0.42, obj.progressBar ,'Generating contours...');
%                     obj.generateVOIs();
                    waitbar(0.666, obj.progressBar ,'Generating contours...');
%                     obj.sizeOfVois = size(obj.contourManager.indexedVOIs);
                    waitbar(1, obj.progressBar ,'Generating contours...');
                    toc;
                    close(obj.progressBar);

                    obj.hasRTSS = 1;
                end
            end
        end
       
        
      % Read RTPLAN exported file
        function readRTPlan(obj)

            if isempty(obj.RTPLAN)
               [RTPLANfilename,RTPLANpathname] = uigetfile({'*.dcm';'*.*'},'Select RTPLAN file of the plan',...
                                             'MultiSelect', 'off');
              
                if ischar(RTPLANfilename) && ischar(RTPLANpathname)
                    obj.RTPLAN = dicominfo(fullfile(RTPLANpathname,RTPLANfilename));
                    obj.hasRTPLAN = 1;
                end
            end
        end  
        
        
     % Read RTDOSE, RTPLAN and RTSS exporteed files all at once
        function readRTexport(obj)

            for i=1:size(obj.patientData,2)
            waitbar(0.8 + (0.2*(i/size(obj.patientData,2))), obj.progressBar ,'Loading patient RT data...');
           
                if strcmp(obj.patientData{i}.Modality,'RTDOSE') == 1
                     obj.RTDOSEinfo = dicominfo(obj.patientData{i}.Filename);
                     rtdose = dicomread(obj.RTDOSEinfo);
                     obj.RTDOSE = double(squeeze(rtdose)).*obj.RTDOSEinfo.DoseGridScaling;
                     obj.hasRTDOSE = 1;
                    
                elseif strcmp(obj.patientData{i}.Modality,'RTPLAN') == 1
                     obj.RTPLAN = dicominfo(obj.patientData{i}.Filename);
                     obj.hasRTPLAN = 1;
                    
                elseif strcmp(obj.patientData{i}.Modality,'RTSTRUCT') == 1
                     obj.RTSS = dicominfo(obj.patientData{i}.Filename);
                     obj.hasRTSS = 1;
                end
            end
%            close(obj.progressBar);
        end
       
     
        
%         function generateVOIs(obj)
%             disp('Generating VOIs');
%             tic
%             obj.contourManager.fcreateVOIs(obj.CTinfo);
%             obj.sizeOfVois = size(obj.contourManager.indexedVOIs);
%             toc
%         end
%   end of methods
    end
   
    
% end of functions
end