% Outputs d and P for each DOF
% Outputs member end forces due to span load in LCS for each member
% Outputs k, T, s, L for each member
% Outputs nodeDOF which relates each DOF to a node
% Outputs memberDOF which relates each DOF to a member
% Outputs memCoord which gives the near and far coordinate of a member
% Outputs dofGlobalFree which stores the DOF number of all free DOFs
% Outputs dofGlobalRestrained which stores the DOF number for all
% restrained DOFs
function [fulld, fullP, spanPf, k, T, s, L, nodeDOF, memberDOF,...
    memCoord, dofGlobalFree, dofGlobalRestrained] = ...
    elasticAnalysis(nodeInfo, memberInfo, nodeLoadInfo, spanLoadInfo)

% Assigning DOF numbers to each node
[dofGlobal, dofGlobalFree, dofGlobalRestrained] = dofAssign(nodeInfo);

% Assembly of structure stiffness matrix S and storage of T and s for
% individual member(i)
% Creation of member stiffness matrix handled by spaceFrameStiffness
% function
S = zeros(size(dofGlobal, 1)*(size(dofGlobal, 2) - 1));
for memberNum = 1:size(memberInfo, 1)
    [k{memberNum}, memberDOF{memberNum}, T{memberNum}, s{memberNum}, ...
        L{memberNum}, memCoord{memberNum}] = ...
        spaceFrameStiffness(memberNum, memberInfo, nodeInfo, dofGlobal);
    S(memberDOF{memberNum}, memberDOF{memberNum}) = ...
        S(memberDOF{memberNum}, memberDOF{memberNum}) + k{memberNum};
end

% Assembly of P* (values in P only effective for free DOFs, restrained DOFs
% value are placeholders)
fullP = zeros((size(dofGlobal, 1))*(size(dofGlobal, 2) - 1), 1);
for nodeNum = 1:size(nodeInfo, 1);
    [nodeP{nodeNum}, nodeDOF{nodeNum}] = nodeLoadAssembly(nodeNum, nodeLoadInfo, dofGlobal);
    fullP(nodeDOF{nodeNum}, 1) = fullP(nodeDOF{nodeNum}, 1) + nodeP{nodeNum};        
end

% Assembly of Pf*
fullPf = zeros((size(dofGlobal, 1))*(size(dofGlobal, 2) - 1), 1);
for memberNum = 1:size(memberInfo, 1)
    spanPf{memberNum} = spanLoadAssembly(memberNum, spanLoadInfo, ...
        L{memberNum}, T{memberNum});
    fullPf(memberDOF{memberNum}, 1) = ...
        fullPf(memberDOF{memberNum}, 1) + spanPf{memberNum};
end

% Assembly of d
fulld = dAssembly(nodeInfo, dofGlobal);

% Partitioning
SFF = S(dofGlobalFree, dofGlobalFree);
SFR = S(dofGlobalFree, dofGlobalRestrained);
SRF = S(dofGlobalRestrained, dofGlobalFree);
SRR = S(dofGlobalRestrained, dofGlobalRestrained);
dR = fulld(dofGlobalRestrained);
Pf = fullPf(dofGlobalFree);
Rf = fullPf(dofGlobalRestrained);
P = fullP(dofGlobalFree);

% Calculating for dF and reactions
dF = SFF\(P - Pf - SFR*dR);
R = SRF*dF + SRR*dR + Rf;

% Completing partitioned matrices
fullP = [P; R];
fullPf = [Pf; Rf];
fulld = [dF; dR];

