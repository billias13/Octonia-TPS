function [ out ] = loadPatientData( dataTag )

    switch dataTag
       
        case 'Full Patient Data'
            if notifyForLossOfCurrentData()
                disp('Loading Full Patient Data');
                out = loadTreatmentPlan(1);
                return;
            else
                out = 0;
                return;
            end
        
        case 'CT Data'
            if notifyForLossOfCurrentData()
                disp('Loading CT Data');
                out = loadTreatmentPlan(0);
                return;
            else
                out = 0;
                return;
            end
             
        case 'RTPlan'
            disp('Loading RTPlan');
            out = loadRTPlan();
            return;
        
        case 'RTDose'
            disp('Loading RTDose');
            out = loadRTDose();
            return;
        
        case 'RTSS'
            disp('Loading RTSS');
            out = loadRTSS();
            return;          
    end

    %%
    function [full] = loadTreatmentPlan(FullPlan)  
        try
            [searchResult patientPath patientInfo patientData] = SearchForDicomInDirectory(getV('patientfiles'));
    
            %If patient is found, loadfulltreatmentplan patient info etc...
            if searchResult>0

            %Create an instance of TPSPatient
            currentPatient = TPSPatient(patientPath,  patientInfo,patientData, FullPlan);
            %Set as current patient
            setV('currentPatient', currentPatient);
            %Update cross limits
            crossLimits.x = size(currentPatient.CTimages,1);
            crossLimits.y = size(currentPatient.CTimages,2);
            crossLimits.z = size(currentPatient.CTimages,3);
            %Store cross limits
            setV('crossLimits',crossLimits);
                %return success
                full = 1; 
                %Return to parent folder (gui folder);
                cd(getV('parentfolder'));
                return;
            else
                %return failure
                full = 0;
                %Return to parent folder (gui folder);
                cd(getV('parentfolder'));
                return;
            end
            

        catch e
            disp(e.message);
            full = 0;
            return;
        end
    end
    
 
    
    
    %%
    function [rtss] = loadRTSS()
        try
            currentPatient = getV('currentPatient');
            if isempty(currentPatient)==0
                    currentPatient.readRTSS();
                    setV('currentPatient',currentPatient);
                    cd(getV('parentfolder'));
                    rtss =1;
                    return;
            end
        catch e
            disp(e.message);
            cd(getV('parentfolder'));
            rtss =0;
            return;
        end
        
    end
  
    %%
    function [rtplan] = loadRTPlan()
        try
            currentPatient = getV('currentPatient');
            if isempty(currentPatient)==0
                    currentPatient.readRTPlan();
                    setV('currentPatient',currentPatient);
                    cd(getV('parentfolder'));
                    rtplan =1;
                    return;
            end
        catch e
            disp(e.message);
            cd(getV('parentfolder'));
            rtplan =0;
            return;
        end
        
    end

    %%
    function [rtdose] = loadRTDose()
        try
            currentPatient = getV('currentPatient');
            if isempty(currentPatient)==0
                    currentPatient.readRTDose();
                    setV('currentPatient',currentPatient);
                    cd(getV('parentfolder'));
                    rtdose =1;
                    return;
            end
        catch e
            disp(e.message);
            cd(getV('parentfolder'));
            rtdose =0;
            return;
        end
        
    end


    %%
    function [procceed] = notifyForLossOfCurrentData()
      if getV('patientDataLoaded')||getV('patientPlanLoaded')
         r = questionDialogs('clearPatientAndLoadNew');
            if r == 2 || r ==0
                procceed = 0;
                return;
            end
      end
      procceed = 1;
    end
     
end

