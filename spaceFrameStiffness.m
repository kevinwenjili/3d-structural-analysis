% Generate full sized stiffness matrix k(i) and reduced sized stiffness matrix s(i) for member (i)
function [kFree, memberDOF, T, s, L, memCoord] = spaceFrameStiffness(memberNum, memberTable, nodeTable, dofTable)
% Find member information by combining information inputted in memberTable
% and jointTable together

% Location(row) of member(i) within memberTable
memberLoc = find(memberTable(:, 1) == memberNum);

% Properties of member(i)
A = memberTable(memberLoc, 2); 
E = memberTable(memberLoc, 3); 
G = memberTable(memberLoc, 4);
Iy = memberTable(memberLoc, 5); 
Iz = memberTable(memberLoc, 6); 
J = memberTable(memberLoc, 7); 
Psi = memberTable(memberLoc, 8);

% Near and far node of member(i)
nodeNear = memberTable(memberLoc, 9); 
nodeFar = memberTable(memberLoc, 10);

% Location(row) of nodes within nodeTable and dofTable
nNodeLoc = find(nodeTable(:, 1) == nodeNear);
fNodeLoc = find(nodeTable(:, 1) == nodeFar);
nDOFLoc = find(dofTable(:, 1) == nodeNear);
fDOFLoc = find(dofTable(:, 1) == nodeFar);

% Automatically determines the near joint and far joint
nX = nodeTable(nNodeLoc, 2); fX = nodeTable(fNodeLoc, 2);
nY = nodeTable(nNodeLoc, 3); fY = nodeTable(fNodeLoc, 3);
nZ = nodeTable(nNodeLoc, 4); fZ = nodeTable(fNodeLoc, 4);

memCoord = [nX, fX, nY, fY, nZ, fZ];

% Length and angle calculation
L = sqrt((fX - nX)^2 + (fY - nY)^2 + (fZ - nZ)^2);

% For column members, angle Beta assumed to be zero. Member rotation
% completely handled by angle Psi which is defined by the user
if fX == nX && fZ == nZ
    cosBeta = 1;
    sinBeta = 0;
else
    cosBeta = (fX - nX)/sqrt((fX - nX)^2 + (fZ - nZ)^2);
    sinBeta = -(fZ - nZ)/sqrt((fX - nX)^2 + (fZ - nZ)^2);
end
cosGamma = sqrt((fX - nX)^2 + (fZ - nZ)^2)/sqrt((fX - nX)^2 + (fY - nY)^2 + (fZ - nZ)^2);
sinGamma = (fY - nY)/sqrt((fX - nX)^2 + (fY - nY)^2 + (fZ - nZ)^2);
cosPsi = cos(deg2rad(Psi));
sinPsi = sin(deg2rad(Psi));

% Rotation and transformation matrix
r3 = [1, 0, 0; 0, cosPsi, sinPsi; 0, -sinPsi, cosPsi];
r2 = [cosGamma, sinGamma, 0; -sinGamma, cosGamma, 0; 0, 0, 1];
r1 = [cosBeta, 0, -sinBeta; 0, 1, 0; sinBeta, 0, cosBeta];
r = r3*r2*r1; 
T = blkdiag(r, r, r, r);

% Local stiffness matrix s for member(i)
s = (E/(L^3))*[ A*L^2,      0,       0,          0,        0,        0, -A*L^2,       0,      0,          0,        0,        0;
                    0,  12*Iz,       0,          0,        0,   6*L*Iz,      0,  -12*Iz,      0,          0,        0,   6*L*Iz;
                    0,      0,   12*Iy,          0,  -6*L*Iy,        0,      0,       0, -12*Iy,          0,  -6*L*Iy,        0;
                    0,      0,       0,  G*J*L^2/E,        0,        0,      0,       0,      0, -G*J*L^2/E,        0,        0;
                    0,      0, -6*L*Iy,          0, 4*L^2*Iy,        0,      0,       0, 6*L*Iy,          0, 2*L^2*Iy,        0;
                    0, 6*L*Iz,       0,          0,        0, 4*L^2*Iz,      0, -6*L*Iz,      0,          0,        0, 2*L^2*Iz;
               -A*L^2,      0,       0,          0,        0,        0,  A*L^2,       0,      0,          0,        0,        0;
                    0, -12*Iz,       0,          0,        0,  -6*L*Iz,      0,   12*Iz,      0,          0,        0,  -6*L*Iz;
                    0,      0,  -12*Iy,          0,   6*L*Iy,        0,      0,       0,  12*Iy,          0,   6*L*Iy,        0;
                    0,      0,       0, -G*J*L^2/E,        0,        0,      0,       0,      0,  G*J*L^2/E,        0,        0;
                    0,      0, -6*L*Iy,          0, 2*L^2*Iy,        0,      0,       0, 6*L*Iy,          0, 4*L^2*Iy,        0;
                    0, 6*L*Iz,       0,          0,        0, 2*L^2*Iz,      0, -6*L*Iz,      0,          0,        0, 4*L^2*Iz];

% Global stiffness matrix k for free dof for member(i)
kFree = transpose(T)*s*T;

% Determines the associated GCS DOF with the member(i)
nDOFOrder = dofTable(nDOFLoc, 2:7);
fDOFOrder = dofTable(fDOFLoc, 2:7);
memberDOF = [nDOFOrder, fDOFOrder];

