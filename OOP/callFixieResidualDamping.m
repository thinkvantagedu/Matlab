% this is the original callFixie with damping.

clear; clc;
trialName = 'l9h2SingleInc';
rvSVDswitch = 0;
callPreliminary;
noPm = 2;
nConsEnd = 2;
nDofPerNode = 2;
fNode = 9;
tic
%% trial solution
% use subclass: fixbeam to create beam.
fixie = fixbeam(abaInpFile, mas, dam, sti, locStartCons, locEndCons, ...
    INPname, domLengi, domBondi, domMid, trial, noIncl, noStruct, noPm, ...
    noMas, noDam, tMax, tStep, errLowBond, errMaxValInit, ...
    errRbCtrl, errRbCtrlThres, errRbCtrlTNo, cntInit, refiThres, ...
    drawRow, drawCol, fNode, ftime, fRange, nConsEnd);

% read mass matrix.
fixie.readMasMTX2DOF(nDofPerNode);

% read constraint infomation.
fixie.readINPconsFixie(nDofPerNode);

% read geometric information.
fixie.readINPgeoMultiInc(nDofPerNode);

% generate parameter space.
fixie.generatePmSpaceSingleDim(randomSwitch, structSwitch, sobolSwitch, ...
    haltonSwitch, latinSwitch);

% generate damping coefficient space, the combination is stiffness then damping.
fixie.generateDampingSpace(damLeng, damBond, randomSwitch, sobolSwitch, ...
    haltonSwitch, latinSwitch);

% read stiffness matrices.
fixie.readStiMTX2DOFBCMod(nDofPerNode);

% extract parameter infomation for trial point.
fixie.pmTrial(1);

% initialise damping, velocity, displacement input.
fixie.damMtx;
fixie.velInpt;
fixie.disInpt;

% generate nodal force.
fixie.generateNodalFce(nDofPerNode, 0.3, debugMode);

% quantity of interest.
fixie.qoiSpaceTime(qoiSwitchSpace, qoiSwitchTime, nDofPerNode);
fixie.errPrepareRemainOriginal;

% compute initial exact solution.
fixie.exactSolutionDynamic('initial', AbaqusSwitch, trialName, 1);

% compute initial reduced basis from trial solution. There are different
% approaches.
fixie.rbInitialDynamic(nPhiInitial, reductionRatio, ratioSwitch, 'original', 1);
fixie.reducedMatricesStatic;
fixie.reducedMatricesDynamic;

while fixie.err.max.realVal > fixie.err.lowBond
    
    if fixie.countGreedy == drawRow * drawCol
        % put here to stop any uncessary computations.
        disp('iterations reach maximum plot number')
        break
    end
    
    %% ONLINE
    fixie.errPrepareSetZeroOriginal;
    
    nIter = domLengi * damLeng;
    for iIter = 1:nIter
        
        fixie.pmIter(iIter, 1);
        
        fixie.reducedVar(1);
        
        fixie.residual0(1);
        
        fixie.residualAsError(1);
        
        fixie.errStoreSurfs('original', 1);
        
        CmdWinTool('statusText', ...
            sprintf('Greedy Online stage progress: %d of %d', iIter, nIter));
        
    end
    
    fixie.extractMaxErrorInfo('original', greedySwitch, randomSwitch,...
        sobolSwitch, haltonSwitch, latinSwitch, 1); % greedy + 1
    disp({'Greedy iteration no' fixie.countGreedy})
    
    fixie.extractMaxPmInfo('original');    
    fixie.greedyInfoDisplay('original', structSwitch);
    fixie.storeErrorInfoOriginal;
    fixie.errStoreAllSurfs('original');
    
%     fixie.plotSurfGrid('original', '-.k', 1);
    
    if fixie.countGreedy == drawRow * drawCol
        % put here to stop any uncessary computations.
        disp('iterations reach maximum plot number')
        break
    end
    
    fixie.exactSolutionDynamic('Greedy', AbaqusSwitch, trialName, 1);
    % rbEnrichment set the indicators.
    fixie.rbEnrichmentDynamic(nPhiEnrich, reductionRatio, ratioSwitch, ...
        'original', 1, structSwitch);
    fixie.reducedMatricesStatic;
    fixie.reducedMatricesDynamic;
    
end
fixie.savePhi;
toc
%%
if randomSwitch == 0
    lineWidth = 2;
    lineColor = 'b-*';
elseif randomSwitch == 1
    lineWidth = 1;
    lineColor = 'k--';
end

% fixie.plotMaxErrorDecayVal('original', lineColor, lineWidth, randomSwitch);
% fixie.plotMaxErrorDecayLoc('original', lineColor, lineWidth, 1);