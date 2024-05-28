function [] = structureView(memberTable, nodeTable)
clf
hold on
for memberNum = 1:size(memberTable, 1)
    % Finds the member in memberTable to determine near and far node
    memberLoc = find(memberTable(:, 1) == memberNum);    
    nodeNear = memberTable(memberLoc, 9); 
    nodeFar = memberTable(memberLoc, 10);
    nNodeLoc = find(nodeTable(:, 1) == nodeNear);
    fNodeLoc = find(nodeTable(:, 1) == nodeFar);
    nX = nodeTable(nNodeLoc, 2); fX = nodeTable(fNodeLoc, 2);
    nY = nodeTable(nNodeLoc, 3); fY = nodeTable(fNodeLoc, 3);
    nZ = nodeTable(nNodeLoc, 4); fZ = nodeTable(fNodeLoc, 4);
    % 3D plot a single member
    plot3([nX fX], [nZ fZ], [nY fY], '-k', 'LineWidth', 2);
    % Plot until all members are plotted
end
hold off
% Controls the aspect ratio of the 3D plot, set the axis and default view
daspect([1 1 1]);
xlabel('X');
ylabel('Z');
zlabel('Y');
view(3);
