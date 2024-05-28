% Reorganizes the displacement information inputted in Node Property into
% the correctly sized matrix and place them at the correct location
% according to the DOF
function [d] = dAssembly(nodeTable, dofTable)
d = zeros((size(dofTable, 1))*(size(dofTable, 2) - 1), 1);
% Finds the specified displacement for each restrained global DOF
for nodeTableRow = 1:size(nodeTable, 1)
   for nodeCol = 1:6
       nodeNum = nodeTable(nodeTableRow, 1);
       if nodeTable(nodeTableRow, nodeCol + 4) == 1
           dofTableRow = find(dofTable(:, 1) == nodeNum);
           d(dofTable(dofTableRow, nodeCol + 1)) = nodeTable(nodeTableRow, nodeCol + 10);
       end    
   end
end