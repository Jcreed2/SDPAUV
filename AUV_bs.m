clear all;clc;format compact

%% Set up AUV 
% Create
        auv = AUVParams;
        auv.allTL.setValue(400,'');
        auv.aRef.setValue(10,'');
        auv.rho.setValue(1000,'');
        auv.cD.setValue(.08,'');
        auv.AUVmass.setValue(800,'');
        auv.posSP.setValue(1.12*10^3,'');
        auv.motorForce.setValue(1*10^3,'');
        auv.posOffset.setValue(50,'');
        auv.fsDisc.setValue([0:.1:2],'');
        auv.pBL.setValue([1:100],'');
        auv.initBat.setValue(100,'');
        auv.timeStart.setValue(1*3600,'');
        auv.Bme.setValue(1e7,'');
        auv.startKiteCost.setValue(1000,'');
        auv.energyInOnePercent.setValue(auv.Bme.Value/100,'');
        auv.x1.setValue([0,.1,.5,1,1.5,2],'');
        auv.x2.setValue([0,7,1268,9390,30400,63000],'');
        auv.interpolatedPower.setValue(interp1(auv.x1.Value,auv.x2.Value,auv.fsDisc.Value,'pchip'),'');
        auv.numSt.setValue(14,'');
        auv.stageMap.setValue([1: auv.numSt.Value,  auv.numSt.Value-1:-1:1  ,2:auv.numSt.Value, auv.numSt.Value-1:-1:1],'');
        auv.timeToChargePF.setValue(auv.energyInOnePercent.Value./auv.interpolatedPower.Value,'');

saveBuildFile('auv',mfilename);