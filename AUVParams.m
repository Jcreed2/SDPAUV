classdef AUVParams < dynamicprops
    
    %STATION Class definition for a ground station
    
    properties (SetAccess = private)
        allTL %allowable tether length
        rho
        cD % drag coefficiant
        AUVmass
        posSP % position set point
        motorForce
        posOffset % position off set to end the simulation
        fsDisc % flow speed discretizations
        pBL  % possible battery life
        initBat 
        timeStart
        Bme % battery maximum energy
        startKiteCost % cost of deployinh the kite
        energyInOnePercent % energy in one percent of the battery
        x1 % flow speeds for power interpolation
        x2 % power per flow speeds
        interpolatedPower
        timeToChargePF % time to charge based on the flow speed
        stageMap  % stages for flow speed
        numSt
        aRef
    end
    
    methods
        function obj = AUVParams
            
            
            obj.allTL                     = SIM.parameter('Unit','');
            obj.rho                       = SIM.parameter('Unit','');
            obj.cD                        = SIM.parameter('Unit','');
            obj.AUVmass                   = SIM.parameter('Unit','');
            obj.posSP                     = SIM.parameter('Unit','');
            obj.motorForce                = SIM.parameter('Unit','');
            obj.posOffset                 = SIM.parameter('Unit','');
            obj.fsDisc                    = SIM.parameter('Unit','');
            obj.pBL                       = SIM.parameter('Unit','');
            obj.initBat                   = SIM.parameter('Unit','');
            obj.timeStart                 = SIM.parameter('Unit','');
            obj.Bme                       = SIM.parameter('Unit','');
            obj.startKiteCost             = SIM.parameter('Unit','');
            obj.energyInOnePercent        = SIM.parameter('Unit','');
            obj.x1                        = SIM.parameter('Unit','');
            obj.x2                        = SIM.parameter('Unit','');
            obj.interpolatedPower         = SIM.parameter('Unit','');
            obj.timeToChargePF            = SIM.parameter('Unit','');
            obj.stageMap                  = SIM.parameter('Unit','');
            obj.numSt                     = SIM.parameter('Unit','');
            obj.aRef                      = SIM.parameter('Unit','');
        end
        
        function setAllTL(obj,val,units)
            obj.allTL.setValue(val,units)
        end
        
        function setRho(obj,val,units)
            obj.rho.setValue(val,units)
        end
        
        function setCD(obj,val,units)
            obj.cD.setValue(val,units)
        end
        
        function setAUVmass(obj,val,units)
            obj.AUVmass.setValue(val,units)
        end
        
        function setPosSP(obj,val,units)
            obj.posSP.setValue(val,units)
        end
        
        function setMotorForce(obj,val,units)
            obj.motorForce.setValue(val,units)
        end
        
        function setPosOffset(obj,val,units)
            obj.posOffset.setValue(val,units)
        end
        
        function setFsDisc(obj,val,units)
            obj.fsDisc.setValue(val,units)
        end
        
        function setPBL(obj,val,units)
            obj.pBL.setValue(val,units)
        end
        
        function setInitBat(obj,val,units)
            obj.initBat.setValue(val,units)
        end
        
        function setTimeStart(obj,val,units)
            obj.timeStart.setValue(val,units)
        end
        
        function setBme(obj,val,units)
            obj.Bme.setValue(val,units)
        end
        
        function setStartKiteCost(obj,val,units)
            obj.startKiteCost.setValue(val,units)
        end
        
        function setEnergyInOnePercent(obj,val,units)
            obj.energyInOnePercent.setValue(val,units)
        end
        
        function setX1(obj,val,units)
            obj.x1.setValue(val,units)
        end
        
        function setX2(obj,val,units)
            obj.x2.setValue(val,units)
        end
        
        function setInterpolatedPower(obj,val,units)
            obj.interpolatedPower.setValue(val,units)
        end
        
        function setTimeToChargePF(obj,val,units)
            obj.timeToChargePF.setValue(val,units)
        end
        
        function setStageMap(obj,val,units)
            obj.stageMap.setValue(val,units)
        end
        
        function setNumSt(obj,val,units)
            obj.numSt.setValue(val,units)
        end
        
        function setARef(obj,val,units)
            obj.aRef.setValue(val,units)
        end
        
        
        
        % Function to scale the object
        
        
        function val = struct(obj,className)
            % Function returns all properties of the specified class in a
            % 1xN struct useable in a for loop in simulink
            % Example classnames: OCT.turb, OCT.aeroSurf
            props = sort(obj.getPropsByClass(className));
            if numel(props)<1
                return
            end
            subProps = properties(obj.(props{1}));
            for ii = 1:length(props)
                for jj = 1:numel(subProps)
                    val(ii).(subProps{jj}) = obj.(props{ii}).(subProps{jj}).Value;
                end
            end
        end
        
        
        % Function to get properties according to their class
        % May be able to vectorize this somehow
        function val = getPropsByClass(obj,className)
            props = properties(obj);
            val = {};
            for ii = 1:length(props)
                if isa(obj.(props{ii}),className)
                    val{end+1} = props{ii};
                end
            end
        end
        
        
    end
end


