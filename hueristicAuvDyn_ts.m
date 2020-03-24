%%  Params



load('auvDataMat.mat')
load('AUV.mat')



%% constants
bat  = auv.initBat.Value;
time = auv.timeStart.Value;
startKiteCost = auv.startKiteCost.Value;
batTracker = [];
fsDisc = auv.fsDisc.Value;
Bme = auv.Bme.Value;
posSP = auv.posSP.Value;
AUVmass = auv.AUVmass.Value;
aRef = auv.aRef.Value ;
cD = auv.cD.Value;
rho  = auv.rho.Value;
posOffset = auv.posOffset.Value;
stageMap = auv.stageMap.Value;
timeToChargePF = auv.timeToChargePF.Value;

%% simulate


for i = 1:length(auv.stageMap.Value)% stageMap
    
    % match time into the time varying flow matrix
    time4flow = ceil(time/3600);
    
    fsMax     = maxFData(time4flow,stageMap(i));
    fsMaxTracker(i) = fsMax;
    
    fsInd     = find([1:length(fsDisc)].*(fsDisc > (fsMax - .01) & fsDisc < (fsMax + .01)),1);
    
    
    
    % if you cannot make it to the next stage, charge to full
    
    
    
    
    floorFlow =  data{stageMap(i)}(time4flow,end);
    if floorFlow >.5
        floorFlow = .5;
        
    end
    % move forward
    
    bBC = bat; 
    sim('auvDyn')
    parseLogsout
    bat      =  bat - ceil(100*(sum(tsc.energy.Data(end,:))/Bme));
%     disp(ceil(100*(sum(tsc.energy.Data(end,:))/Bme)))
    time     =  time +  tsc.timeR.Data(end);
    
    
    if bat <= 11
        time  = time  + timeToChargePF(fsInd)*(100-bat) + startKiteCost;
        bat   = 100;
        if i>1
        charTok(i-1) = bBC; % charge token
        end
    else 
        if i>1
        charTok(i-1) = NaN; % charge token
        end
    end
    
%     if i == length(auv.stageMap.Value)
%         time  = time  + timeToChargePF(fsInd)*(100-bat) + startKiteCost;
%         bat   = 100;
%         charTok(i-1) = bBC;
%     end
    
    batTracker(i) = bat;
end




