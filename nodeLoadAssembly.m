% Assigns the node loads to the global DOFs to create P matrix
function [nodeP, nodeDOF] = nodeLoadAssembly(nodeNum, nodeLoadTable, dofTable)     
dofTableLoc = dofTable(:, 1) == nodeNum;   
nodeDOF = dofTable(dofTableLoc, 2:7);
if isempty(nodeLoadTable) == 0
    nodeLoadTableLoc = nodeLoadTable(:, 1) == nodeNum;
        if sum(nodeLoadTableLoc) ~= 0
             loadFactor = nodeLoadTable(nodeLoadTableLoc, 2);
             allP = loadFactor*nodeLoadTable(nodeLoadTableLoc, 3:8);
             PT = sum(allP, 1);
        else
             PT = zeros(1, 6);
        end
    nodeP = transpose(PT);
else
    PT = zeros(1,6);
    nodeP = transpose(PT);
end


