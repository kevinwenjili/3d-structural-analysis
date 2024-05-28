function [pathMemProp, L, absL] = movingLoadPathProp(nodeTable, memberTable, pathMem)
% This function locates each member and forms a path for the moving load.
% Creates the member reference for axle load
absDistance = [];
for memi = 1:size(pathMem, 2)
    memberNum = pathMem(memi);
    memberLoc = find(memberTable(:, 1) == memberNum);
    nodeNear = memberTable(memberLoc, 9); 
    nodeFar = memberTable(memberLoc, 10);    
    nNodeLoc = find(nodeTable(:, 1) == nodeNear);
    fNodeLoc = find(nodeTable(:, 1) == nodeFar);
    nX = nodeTable(nNodeLoc, 2); fX = nodeTable(fNodeLoc, 2);
    nY = nodeTable(nNodeLoc, 3); fY = nodeTable(fNodeLoc, 3);
    nZ = nodeTable(nNodeLoc, 4); fZ = nodeTable(fNodeLoc, 4);
    L{memberNum} = sqrt((fX - nX)^2 + (fY - nY)^2 + (fZ - nZ)^2);
    if memi == 1
        absDistance(memi) = L{memberNum};
        absL{memberNum} = absDistance(memi);
    else
        absDistance(memi) = L{memberNum} + absDistance(memi-1);
        absL{memberNum} = absDistance(memi);
    end
end
pathMemProp = [pathMem; absDistance];