clear all

load('2014_new.mat')

% command is called chol
% number of distances
numDist =11;
numDepths = 15;
lenTime = 1500; %length of time in hrs
lonRad = deg2rad(lon(1:numDist));
latRad = deg2rad(lat(1:numDist));
radiusE  = 6.371e6;
[X,Y,Z] = sph2cart(lonRad',latRad',radiusE);
arcLengths  = sqrt((X(2:end) - X(1:end-1)).^2 +   (Y(2:end) - Y(1:end-1)).^2 + (Z(2:end) - Z(1:end-1)).^2 );
msrDist =.001* [0, cumsum(arcLengths)];




U = u(1:lenTime,1:numDist,1:numDepths); %time by x position by depths
V = v(1:lenTime,1:numDist,1:numDepths); %time by x position by depths
msrMag = sqrt((U.^2) + (V.^2)); %reshape(U(1:100),[size(x)])


x = msrDist';
t = [1:lenTime]';

h = [.2151   6.9032  11.8196 ] ; %signal variance length scale time scale


sigX = 1*exp( -.5*(((x-x').^2)/(h(2)^2)) );
sigT = 1*exp( -.5*(((t-t').^2)/(h(3)^2)) );




sigX = .001*eye(size(sigX,1)) + sigX ;

sigT = .001*eye(size(sigT,1)) + sigT ;


Lt = chol(sigT);
Lx = chol(sigX);
clear msrNewData
for ii  = 1 : length(z)
    noise   = randn( size(msrMag(:,:,1)));
    
    msrNewData(:,:,ii)  = h(1)*(Lx*(Lt*noise)')' + msrMag(:,:,ii);
    
    
end

msrNewDist = linspace(0,msrDist(end),14);
numBatteryDisc = 100;
numSt = length(msrNewDist);

for i = 1:length(t)
    for j = 1:length(z)
        newData            = interp1(msrDist, squeeze(msrNewData(i,:,j)) ,msrNewDist);
        fData(i,:,j)       = newData;
        
    end
end

fData = permute(fData,[1,3,2]);

newZ = 0:25:1000;

for i = 1:numSt
    
    for j = 1:lenTime
        
        newData      = interp1(z,squeeze(fData(j,:,i)),newZ);
        newData            = .1*ceil(newData*10);
        newData(newData>2) = 2;
        newData(newData<0) = 0;
        fsData(j,:,i)      = newData;
        
    end
    
end



%% getting rid of NANs
data = cell(numSt,1);

for i = 1:numSt
    
    
    numAccDep  = sum(~isnan(fsData(1,:,i))); % number of acceptable depths
    tempDD = fsData(:,:,i); % times by depths
    tempDD = tempDD(~isnan(tempDD));
    data{i}= reshape(tempDD,[lenTime,numAccDep]);
    
    
    
end

%% finding the max flow speed in the water column by allowable tether length
allTL = 400;

for i = 1:numSt
    
    fCT = data{i}; % flow column with Time dimensions time by allowable depths
        
        if (size(fCT,2) < (allTL/25) )
            maxFSWC = max(fCT,[],2); % max flowspeed in the water column at a given time
        else
            fCT = fliplr(fCT);
            fCT = fCT(:,allTL/25);
            maxFSWC = max(fCT,[],2);
        end
   
        maxFData(:,i) = maxFSWC;   % max flowspeed at each time for all the depths, rows time depths columns
end



%% Count the number of times the flow speed changes from one discretization to another discretization when location changes

fsDisc = [0:.1:2];
mat = zeros(length(fsDisc),length(fsDisc));

% back and forth data: This may be incorrect
 maxFDataBAF = [maxFData,fliplr(maxFData)];


    for i = 1:lenTime
        wd =    maxFDataBAF(i,:);
        for k = 1: length(wd)-1
            
            old =  wd(k);
            oldIdx =  find([1:length(fsDisc)].*(fsDisc > (old - .01) & fsDisc < (old + .01)),1);
            
            if isempty(oldIdx)
                b = 1;
            end
            new =  wd(k+1);
            newIdx =  find([1:length(fsDisc)].*(fsDisc > (new - .01) & fsDisc < (new + .01)),1);
            
            if isempty(newIdx)
                b = 1;
            end
            mat(oldIdx,newIdx) = mat(oldIdx,newIdx) + 1 ; %size fsDisc by fsDisc
        end
    end




mc = dtmc(mat);

%% Forming the gigantic look up table

% based on what battery discretization I am at, and based on my current
% wind speed what do I do next

%cost function J =  expected time to travel + expected time to charge + penalty for kite
%deployment at each location.

%%  constants
load('AUV.mat')

%battery max energy
Bme =  auv.Bme.Value; %400 kwh
% possible battery life
pBL =  auv.pBL.Value; % percent

% position interval

posInt = msrNewDist(2) - msrNewDist(1);

% COST TO REEL IN AN OUT THE KITE
startKiteCost = 1000000;%auv.startKiteCost.Value; %seconds

EnergySpentToMove = 1e+06;
EnergyPercent = ceil(100*EnergySpentToMove/Bme ); % KWH

% Determining the energy needed to charge 1 percent of the batter
energyInOnePercent =Bme/100;
x1 =  auv.x1.Value;
x2 =  auv.x2.Value;
flowForPower = 0:.1:2;
interpolatedPower = interp1(x1,x2,flowForPower,'pchip');
timeToChargePF =  energyInOnePercent./interpolatedPower;

% chargeOnePercentPerFlowSpeed = [];
% format long
% for q = 1:length(fsDisc)
%
%     tempFlow = fsDisc(q);
%     [num,ind]=find(abs(10000000000*(flowForPower-tempFlow))<1);
%
%     indOfTTC = timeToChargePF(ind);
%     chargeOnePercentPerFlowSpeed = [chargeOnePercentPerFlowSpeed,indOfTTC ];
%
% end
% format short

TT = 1000 ; % travel time

%% look up table creation

markov = mc.P;
markov(isnan(markov)) = 0;
markov = markov.^(1);

terminalCost = [];
% cost to finish at the final stage
for j = length(fsDisc): -1 : 1
    terminalCostPerFsDisc = [];
    for k = numBatteryDisc:-1:1
        
        batteryStart = pBL(k);
        
        percentToFull = 100 - pBL(k);
        
        % if you must charge to make it to the next state
        if ( percentToFull > 0)
            chargeTime = startKiteCost + percentToFull*timeToChargePF(j) ;
        else
            chargeTime = 0;
        end
        terminalCost(j,k) = chargeTime;
        
    end
    
end


stageMap = auv.stageMap.Value;

newNumSt = length(stageMap); % new number of stages
totInd = cell(newNumSt,1);
clear costM
for i =  newNumSt:-1:1%numSt*2:-1:1
    
    
    
    
    
    indBest = cell(length(fsDisc),numBatteryDisc);
    %% current Flow speed and current battery life
    for j = length(fsDisc): -1 : 1
        
        
        for k = numBatteryDisc:-1:1
            %if you cant make it to the next stage with your current
            %battery life
            currentBat = pBL(k);
            batLifeRemaining = currentBat - EnergyPercent;
            
            if (batLifeRemaining <0)
                
                addedStageCost = timeToChargePF(j)*( -batLifeRemaining) + 10000000000000;
            else
                addedStageCost = 0;
                
            end
            costM = [];
            % Basically I am an idiot and i should have been totalling the
            % rows instead of doing what ever the fuck shit I was doing 
            for q = length(fsDisc): -1 : 1
                
%                 expctMultiplier = flowProb(j,q).^3;
                
                for p = numBatteryDisc:-1:1
                    
                    nextBat = pBL(p);
                    amountToCharge = nextBat - batLifeRemaining;% amount to charge to reach the next stages battery life
                    
                    if amountToCharge < 0
                        
                        timePenaltyCharging = NaN;
                        
                    elseif amountToCharge == 0
                        
                        timePenaltyCharging = 0;
                        
                    else
                        timePenaltyCharging = startKiteCost + timeToChargePF(q)*(amountToCharge); %*expctMultiplier;
                        
                    end
                    
                    % cost = cost by next flow speed and next battery life
                    %take the min here
                    % once you have taken the min of cost then you can
                    % build each element of initialCostLastStage matrix
                    
                    if i == newNumSt
                        costM(q,p) = timePenaltyCharging + addedStageCost + TT + terminalCost(q,p );
                        
                    else
                        
                        costM(q,p) = timePenaltyCharging + addedStageCost + TT + initialCostLastStage(q,p,i+1);
                        
                    end
                    
                    % initial state cost is the cost associated with going to the p battery discretization
                    
                end
                
            end
            
            
                 costM(isnan(costM)) = 10^10;
                 costM(isinf(costM))= 0;
                 format long
                 costPerBat = costM'*markov(j,:)'; %summing the expected values
                 
                [minC,indC] = min(costPerBat);
            format short
%             minMatrix = min(costM(:));
%             [row,col] = find(costM == minMatrix,1);
%              if ( isempty([row,col]))
%                  b = 1;
%              end
            indBest{j,k}  = indC;
            initialCostLastStage(j,k,i) = minC;
        
            
        end
        
    end
    
    
    
    totInd{i} = indBest;
    
    
    
    
end




for i = 1:newNumSt
    
    for j = 1:numBatteryDisc
        
        
        for k = 1:length(fsDisc)
            try
            totIndMat( k,j,i) = totInd{i}{k,j};
            catch
                b = 1;
                
            end
            
        end
        
    end
    
    
end




save('auvDataMat.mat','maxFData','totIndMat','data','msrNewDist','numSt','numBatteryDisc','lenTime')



















