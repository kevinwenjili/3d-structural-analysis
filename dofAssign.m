% Automatically assign DOF number based on node type
function[dofTable, freeDOF, restrainedDOF, dGlobal, freeJoint, restrainedJoint] = dofAssign(nodeTable)
% Node restrain type reading starts at column 5 in nodeInfo
rowReadOffset = 0; colReadOffset = 4;   

% Node DOF placement starts at column 2 in dofTable
rowPlaceOffset = 0; colPlaceOffset = 1;

% Initial DOF number
dofNum = 0;

% Number of node in structure
totNode = size(nodeTable, 1);

% Initialize dof assignment matrixies
% Space frame has 6 dof + 1 column for node reference
dofTable = zeros(totNode, 7);
restrainedLoc = [];
freeDOFTable = [];
freeJoint = [];
restrainedDOFTable = [];
restrainedJoint = [];
dGlobal = [];

% This for loop finds all free DOFs and assign them with the lowest number
% starting from 1. Restrained DOF location index are recorded
for dofTableRow = 1:totNode;
    dofTable(dofTableRow, 1) = nodeTable(dofTableRow, 1);
    for dofTableCol = 1:6
        if nodeTable(dofTableRow, dofTableCol + colReadOffset) == 0
            dofNum = dofNum + 1;
            dofTable(dofTableRow, dofTableCol + colPlaceOffset) = dofNum;
            freeDOFTable = [freeDOFTable; dofNum];
            freeJoint = [freeJoint; nodeTable(dofTableRow, 1)];
        elseif nodeTable(dofTableRow, dofTableCol + colReadOffset) == 1
            restrainedLoc = [restrainedLoc; dofTableRow, dofTableCol + colPlaceOffset];
            restrainedJoint = [restrainedJoint; nodeTable(dofTableRow, 1)];
        end
    end
end

% This for loop finds all unassigned (restrained) DOFs and assign them with
% the lowest number after all free DOFs has been assigned a number
for restrainedNum = 1:size(restrainedLoc, 1);
    dofNum = dofNum + 1;
    dofTable(restrainedLoc(restrainedNum, 1), restrainedLoc(restrainedNum, 2)) = dofNum;
    restrainedDOFTable = [restrainedDOFTable; dofNum];
end

% Extra information summarizing the free DOF and restrained DOF. May be
% useful later
freeDOF = freeDOFTable;
restrainedDOF = restrainedDOFTable;
freeJoint = unique(freeJoint);
restrainedJoint = unique(restrainedJoint);