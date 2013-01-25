[c, hcont]= contourf(currentPatient.RTDOSEcoordinates.xind,...
                    currentPatient.RTDOSEcoordinates.yind,...
                    currentPatient.RTDOSE(:,:,10),[0.5, 1],'-k');
%%                              
                   cc = get(hcont,'LineColor')            
                   set(cc,'LineColor','children')           
                              
                    cMatrix = get(hcont,'Children') ;
                    
                    
                     get(hcont,'Color')
                    
                    ic = 1;
                    while ic <= 11
                         set(cMatrix(ic,1),'FaceColor',isodoseColorMap(ic,:))
                         ic = ic + 1;
                    end
                    clear hcont cMatrix