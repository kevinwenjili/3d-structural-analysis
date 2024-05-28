% - CIVE 403 FINAL PROJECT ---------------------------------------------- %
%   KEVIN LI      20553865
%   University of Waterloo

% - Setup --------------------------------------------------------------- %
clc, clear, format shortEng

% - Excel Sheet Reference ----------------------------------------------- %
inputSheet = 'inputSheetTest.xlsx';
outputSheet = 'outputSheetTest.xlsx';

% - Stuctural Analysis -------------------------------------------------- %

% - Static Load Analysis ------------------------------------------------ %

% Access excel information
nodeInfo = xlsread(inputSheet, 'Node Property');
memberInfo = xlsread(inputSheet, 'Member Property');
nodeLoadInfo = xlsread(inputSheet, 'Node Load');
spanLoadInfo = xlsread(inputSheet, 'Span Load');

% Running elastic analysis
[fulld, fullP, spanPf, k, T, s, L, nodeDOF, memberDOF, ...
    memCoord, dofGlobalFree, dofGlobalRestrained] = ...
    elasticAnalysis(nodeInfo, memberInfo, nodeLoadInfo, spanLoadInfo);

% Graphical display of structure
structureView(memberInfo, nodeInfo);

% Member end forces result generation
for memberNum = 1:size(memberInfo, 1);
    v{memberNum} = fulld(transpose(memberDOF{memberNum}));
    u{memberNum} = T{memberNum}*v{memberNum};
    Qf{memberNum} = T{memberNum}*spanPf{memberNum};
    Q{memberNum} = s{memberNum}*u{memberNum} + Qf{memberNum};   
end

for memberNum = 1:size(memberInfo, 1);
    resultMemberProp(memberNum, :) = [memberNum, L{memberNum}];
    resultSLMemberEndFM(memberNum, :) = ...
        [memberNum, transpose(Q{memberNum})];
    resultSLMemberEndDisp(memberNum, :) = ...
        [memberNum, transpose(u{memberNum})];
end

totdP = [[dofGlobalFree; dofGlobalRestrained], fulld, fullP];
fulldT = fulld';
fullPT = fullP';
for nodeNum = 1:size(nodeInfo, 1);
    nodedP(nodeNum, :) = [nodeNum, fulldT(nodeDOF{nodeNum}), fullPT(nodeDOF{nodeNum})];
end
        
% - Moving Load Analysis ------------------------------------------------ %

% Access excel information
nodeTable = xlsread(inputSheet, 'Node Property');
memberTable = xlsread(inputSheet, 'Member Property');    
movingLoadTable = xlsread(inputSheet, 'Moving Load');

% Check if moving load analysis is required
movingLoadEnabled = movingLoadTable(9, 1); 
if movingLoadEnabled == 1               % Enable if == 1
    
% Moving load parameters
axleLoads = movingLoadTable(1:2, :);
alphaF = movingLoadTable(7, 1);         % Load factor for LL
DLA = movingLoadTable(8, 1);            % Dynamic load allowance 1 + 0.25
pathIncrement = movingLoadTable(6, 1);
girderMem = movingLoadTable(3, :);

% This loop organizes the moving load path specified in the input sheet
% The location of each member are determined
% Load distribution to each girder and design load factors are combined
for lanei = 1:length(girderMem(~isnan(girderMem)));
    pathMem = movingLoadTable(3, lanei):movingLoadTable(4, lanei);
    loadDistribution = movingLoadTable(5, lanei);
    totFactor{lanei} = alphaF*DLA*loadDistribution;
    [pathMemProp{lanei}, La{lanei}, absL{lanei}] = ...
        movingLoadPathProp(nodeTable, memberTable, pathMem);
end

% This is the main moving load analysis loop, the axle loads are moved by
% increment defined by the input spreadsheet until all axle loads are off
% the members
for axleDisplacement = ...
        0:pathIncrement:pathMemProp{lanei}(2, end) + axleLoads(1, end)
    movingLoadNodeLoadTable = [];
    movingLoadSpanLoadTable = [];

    for lanei = 1:length(girderMem(~isnan(girderMem)));       
        % This function assign each axle to a member
        [axleLoc{lanei}, axleOnMem{lanei}] = ...
            movingLoadAxleLoc(pathMemProp{lanei}, ...
            axleDisplacement, axleLoads);
        % After the previous function assigned the axle loads to each
        % member, span loads can now be generated.
        
        % Since the member each axle is on is now known, the span load
        % table will now be generated
        movingLoadSpanLoadi = [];              
        [movingLoadSpanLoadi] = movingLoadSpanLoad(axleLoads, ...
            axleLoc{lanei}, axleOnMem{lanei}, pathMemProp{lanei}, ...
            La{lanei}, absL{lanei}, 1, totFactor{lanei});       
        movingLoadSpanLoadTable = ...
            [movingLoadSpanLoadTable; movingLoadSpanLoadi];
    end
        
    % Inputting the generated span load into elastic analysis program and
    % running the elastic analysis
    [fulldML, fullPML, spanQfML, kKL, TML, sML, LML] = ...
        elasticAnalysis(nodeTable, memberTable, ...
        movingLoadNodeLoadTable, movingLoadSpanLoadTable);
    
    % Results are generated for each member at the each moving load
    % increment
    for memberNum = 1:size(memberTable, 1)
        vML{memberNum} = fulldML(transpose(memberDOF{memberNum}));
        uML{memberNum} = TML{memberNum}*vML{memberNum};
        QfML{memberNum} = TML{memberNum}*spanQfML{memberNum};
        QML{memberNum} = sML{memberNum}*uML{memberNum} + QfML{memberNum};   
    end
    
    % On the first increment, the max and min load and displacement result
    % table will be created
    if exist('criticalQ') == 0
        criticalQ = QML;
    end    
    if exist('criticalu') == 0
        criticalu = uML;
    end
    if exist('criticalP') == 0
        criticalP = fullPML;
    end
    if exist('criticald') == 0
        criticald = fulldML;
    end    
    % In subsequent increments, the existing load results will be
    % compared with the new results to determine which has higher load
    % effects    
    for memberNum = 1:size(memberTable, 1)
        signQ{memberNum} = sign(QML{memberNum});
        magQ{memberNum} = abs(QML{memberNum});
        magCriticalQ{memberNum} = abs(criticalQ{memberNum});
        for dofi = 1:12
            if signQ{memberNum}(dofi) ~= 0
                criticalQ{memberNum}(dofi) = signQ{memberNum}(dofi)* ...
                    max(magCriticalQ{memberNum}(dofi), magQ{memberNum}(dofi));
            end
        end        
        signu{memberNum} = sign(uML{memberNum});
        magu{memberNum} = abs(uML{memberNum});
        magCriticalu{memberNum} = abs(criticalu{memberNum});
        for dofi = 1:12
            if signu{memberNum}(dofi) ~= 0
                criticalu{memberNum}(dofi) = signu{memberNum}(dofi)* ...
                    max(magCriticalu{memberNum}(dofi), magu{memberNum}(dofi));
            end
        end        
    end
    
    for dofNum = 1:size([dofGlobalFree; dofGlobalRestrained], 1)
        signd(dofNum, 1) = sign(fulldML(dofNum, 1));
        magd(dofNum, 1) = abs(fulldML(dofNum, 1));
        magCriticald(dofNum, 1) = abs(criticald(dofNum, 1));
        if signd(dofNum, 1) ~= 0
            criticald(dofNum) = signd(dofNum, 1)* ...
                max(magCriticald(dofNum, 1), magd(dofNum, 1));
        end
        
        signP(dofNum, 1) = sign(fullPML(dofNum, 1));
        magP(dofNum, 1) = abs(fullPML(dofNum, 1));
        magCriticalP(dofNum, 1) = abs(criticalP(dofNum, 1));
        if signP(dofNum, 1) ~= 0
            criticalP(dofNum) = signP(dofNum, 1)* ...
                max(magCriticalP(dofNum, 1), magP(dofNum, 1));
        end
        
    end
% Moving load will now be moved forward by 1 increment    
end

% Result table for the moving load is created
for memberNum = 1:size(memberTable, 1)
    resultMLCriticalFM(memberNum, :) = ...
        [memberNum, transpose(criticalQ{memberNum})];
    resultMLCriticalDisp(memberNum, :) = ...
        [memberNum, transpose(criticalu{memberNum})];
end

% Moving load results are presented separately for review

% Clears output worksheet of pre-existing data
existingMLMemberEndFM = xlsread(outputSheet, 'moving load critical fm');
existingMLMemberEndDisp = xlsread(outputSheet, 'moving load critical disp');
existingMLMemberEndFM(:, :) = nan;
existingMLMemberEndDisp(:, :) = nan;
xlswrite(outputSheet, existingMLMemberEndFM, 'moving load critical fm', 'A2');
xlswrite(outputSheet, existingMLMemberEndDisp, 'moving load critical disp', 'A2');

% Output moving load results to outputSheet
xlswrite(outputSheet, resultMLCriticalFM, 'moving load critical fm', 'A2');
xlswrite(outputSheet, resultMLCriticalDisp, 'moving load critical disp', 'A2');

% Combines the effect of static load with moving load
resultSLMemberEndFM(:, 2:13) = resultSLMemberEndFM(:, 2:13) + ...
    resultMLCriticalFM(:, 2:13);
resultSLMemberEndDisp(:, 2:13) = resultSLMemberEndDisp(:, 2:13) + ...
    resultMLCriticalDisp(:, 2:13);
fulld = fulld + criticald;
fullP = fullP + criticalP;
totdP = [[dofGlobalFree; dofGlobalRestrained], fulld, fullP];

fulldT = fulld';
fullPT = fullP';
for nodeNum = 1:size(nodeInfo, 1);
    nodedP(nodeNum, :) = [nodeNum, fulldT(nodeDOF{nodeNum}), fullPT(nodeDOF{nodeNum})];
end

end % End of moving load analysis module


% The program run-time is increased by the amount of time external Excel
% sheet is accessed. The core functionality resolves relatively quickly
% compared to the time spent on reading and writing data to an Excel file

% Clears output worksheet of pre-existing data
existingMemberProp = xlsread(outputSheet, 'member prop');
existingMemberEndFM = xlsread(outputSheet, 'member end fm');
existingMemberEndDisp = xlsread(outputSheet, 'member end disp');
existingNodeDP = xlsread(outputSheet, 'node dP');
existingMemberProp(:, :) = nan;
existingMemberEndFM(:, :) = nan;
existingMemberEndDisp(:, :) = nan;
existingNodeDP(:, :) = nan;
xlswrite(outputSheet, existingMemberProp, 'member prop', 'A2');
xlswrite(outputSheet, existingMemberEndFM, 'member end fm', 'A2');
xlswrite(outputSheet, existingMemberEndDisp, 'member end disp', 'A2');
xlswrite(outputSheet, existingNodeDP, 'node dP', 'A2');

% Output combined results to output sheet
xlswrite(outputSheet, resultMemberProp, 'member prop', 'A2');
xlswrite(outputSheet, resultSLMemberEndFM, 'member end fm', 'A2');
xlswrite(outputSheet, resultSLMemberEndDisp, 'member end disp', 'A2');
xlswrite(outputSheet, nodedP, 'node dP', 'A2');










