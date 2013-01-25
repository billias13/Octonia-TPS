function [ status, path, dirPatients, dirPatientsInfo ] = SearchForDicomInDirectory(inputpath)
%% SearchForDicomInDirectory
%   out >0   : Number of patients in directory
%   out = 0  : No directory
%   out = -1 : Empty directory
%   out = -2 : No dicom files

% If out>0 (at least a patient exists) the ouputs are:
% 
% - path = the selected path
% 
% - dirPatients = A cell array containing the following columns
%   PatientID - PatientName - NumberOfPatientFiles(number of dicom slices) 
% 
% - diPatientsInfo = A cell array containing dicom files of each patient from 
%   the dirPatients table. (each datarow corresponds to a patient, in the
%   same order that are stored in the dirPatients table)
%%
    dirPatientsInfo = [];
    dirPatients = [];
    
    if strcmp(inputpath,'')
        path = uigetdir(' ','Please, select the directory where patient files (CT images and RT export) are stored');
    else
        path = inputpath;
    end
    if isequal(path, 0)
        status = 0; 
        return;
    end
    
   
    cd(path);
    [stat, struct] = fileattrib('*.*');

    if isequal(stat,0) 
        status = -1;
        return;
    else
        %Number of total files in the selected folder
        totalFilesInFolder = size(struct,2);
        
        dcmInfo = [];
        dicomSlices = 1;
        
        %Current patientID and number
        patientID  = 0;
        patientNum = 0;       
        
        totalPatientsInDirectory = 0; %Number of patients that exist in the current folder
        
       %Loop through all files in the selected folder
       h = waitbar(0,'Searching directory for DICOM files...');
       
       for i = 1:totalFilesInFolder
       patientNum = 0;
       waitbar(i/totalFilesInFolder,h,'Searching directory for DICOM files...');
       
          try
             
            %Extract a dicom slice
            dcmInfo{dicomSlices,1} = dicominfo(struct(i).Name);
            
            %Read the patientID of the current dicom slice
            patientID = str2double(dcmInfo{dicomSlices}.PatientID);
            
            %If no patient has been registered yet, store current patient
            if totalPatientsInDirectory == 0
                  totalPatientsInDirectory = totalPatientsInDirectory+1;
                  patientNum = totalPatientsInDirectory;
                  dirPatients{patientNum,1} = patientID;
                  dirPatients{patientNum,2} = dcmInfo{dicomSlices,1}.PatientName.FamilyName;
                  dirPatients{patientNum,3} = 1;
                  dirPatientsInfo{patientNum, 1} = dcmInfo{dicomSlices,1};
            else
            %Else...
                %Check if this id is already registered in the dirPatients List
                for index=1:size(dirPatients,1)
                    if dirPatients{index,1} == patientID  
                        patientNum = index;
                        break;
                    end
                end

                %If the id is registered, store data accordingly
                if patientNum>0
                    dirPatients{patientNum,3} = dirPatients{patientNum,3} + 1; 
                    dirPatientsInfo{patientNum, dirPatients{patientNum,3}} = dcmInfo{dicomSlices,1};
                %Else, first register the new patient id and then store data
                %accordingly
                else
                    totalPatientsInDirectory = totalPatientsInDirectory+1;
                    patientNum = totalPatientsInDirectory;
                    dirPatients{patientNum,1} = patientID;
                    dirPatients{patientNum,2} = dcmInfo{dicomSlices,1}.PatientName.FamilyName;%dcmInfo{dicomSlices,1}.PatientName.FamilyName;
                    dirPatients{patientNum,3} = 1;
                    dirPatientsInfo{patientNum, 1} = dcmInfo{dicomSlices,1};
                end
            end
          
            
            dicomSlices = dicomSlices + 1; 
            
         catch exception
            msgString = getReport(exception,'basic', 'hyperlinks', 'default');
         end
    

            if isempty(dcmInfo)
                %The selected directory does not contain dicom files
                status = -2;
                close(h);
                return
            end
    end
    
    %Return the number of patients that where found in the selected
    %directory
    waitbar(1,h,'Finished searching');
    close(h);
    
    %% After the patients dicom data have been loaded, search in the same directory for rtdata
    
    
    
    
    
    %% If more than on patient exist, create a subform to choose patient
    
    
    status = size(dirPatients,1);
end

