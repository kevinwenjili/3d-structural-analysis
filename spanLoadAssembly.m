% Outputs the member end forces in GCS for each member
function [spanF] = spanLoadAssembly(memberNum, spanLoadTable, L, T)
% Checks to ensure no error if spanLoadTable is empty. If it is empty,
% create an empty matrix so other portions of the program don't break.
if isempty(spanLoadTable) == 0
    checkSum = sum(spanLoadTable(:, 1) == memberNum);     
    if checkSum > 0
        spanLoadTableLoc = find(spanLoadTable(:, 1) == memberNum); 
        % This loop runs through all loading rows defined in Span Load
        % worksheet
        for i = 1:length(spanLoadTableLoc)
            % Accessing data for the specific row
            loadFactor = spanLoadTable(spanLoadTableLoc(i), 2);
            loadType = spanLoadTable(spanLoadTableLoc(i), 3);
            loadPlacement1 = spanLoadTable(spanLoadTableLoc(i), 4);
            loadPlacement2 = spanLoadTable(spanLoadTableLoc(i), 5); % Not used
            loadProj = spanLoadTable(spanLoadTableLoc(i), 6);
            % The following if statement determines the project type of the
            % force. If global, the force will need to be converted to
            % local forces before being applied to the member.
            if loadProj == 1          % Global Projection
                % Reading global load values
                loadMagX = loadFactor*spanLoadTable(spanLoadTableLoc(i), 7);
                loadMagY = loadFactor*spanLoadTable(spanLoadTableLoc(i), 8);
                loadMagZ = loadFactor*spanLoadTable(spanLoadTableLoc(i), 9);
                % Converting global force to local force
                loadG = [loadMagX; loadMagY; loadMagZ; 0; 0; 0; 0; 0; 0; 0; 0; 0];
                loadL = T*loadG;
                loadMagx = loadL(1, 1);
                loadMagy = loadL(2, 1);
                loadMagz = loadL(3, 1);
                if loadType == 1      % Point Load
                    L1 = loadPlacement1*L;
                    L2 = (1-loadPlacement1)*L;                
                    spanQT(i, :) = [-(loadMagx*L2)/L,
                                    -(loadMagy*L2^2/L^3)*(3*L1 + L2),
                                    -(loadMagz*L2^2/L^3)*(3*L1 + L2),
                                    0,
                                    -loadMagz*L1*L2^2/L^2,
                                    -loadMagy*L1*L2^2/L^2,
                                    -(loadMagx*L1)/L,
                                    -(loadMagy*L1^2/L^3)*(L1 + 3*L2),
                                    -(loadMagz*L1^2/L^3)*(L1 + 3*L2),
                                    0,
                                    loadMagz*L1^2*L2/L^2,
                                    loadMagy*L1^2*L2/L^2];                    
                elseif loadType == 2  % UDL
                    spanQT(i, :) = [-(loadMagx*L)/2,
                                    -(loadMagy*L)/2,
                                    -(loadMagz*L)/2,
                                    0,
                                    -loadMagz*L^2/12,
                                    -loadMagy*L^2/12,
                                    -(loadMagx*L)/2,
                                    -(loadMagy*L)/2,
                                    -(loadMagz*L)/2,
                                    0,
                                    loadMagz*L^2/12,
                                    loadMagy*L^2/12];
                end
%                 spanQGCS = transpose(sum(spanQT, 1));
                spanQ = transpose(sum(spanQT, 1));
                spanF = transpose(T)*spanQ;
            elseif loadProj == 2      % Local Projection
                loadMagx = loadFactor*spanLoadTable(spanLoadTableLoc(i), 7);
                loadMagy = loadFactor*spanLoadTable(spanLoadTableLoc(i), 8);
                loadMagz = loadFactor*spanLoadTable(spanLoadTableLoc(i), 9);
                if loadType == 1      % Point Load
                    L1 = loadPlacement1*L;
                    L2 = (1-loadPlacement1)*L;                
                    spanQT(i, :) = [-(loadMagx*L2)/L,
                                    -(loadMagy*L2^2/L^3)*(3*L1 + L2),
                                    -(loadMagz*L2^2/L^3)*(3*L1 + L2),
                                    0,
                                    -loadMagz*L1*L2^2/L^2,
                                    -loadMagy*L1*L2^2/L^2,
                                    -(loadMagx*L1)/L,
                                    -(loadMagy*L1^2/L^3)*(L1 + 3*L2),
                                    -(loadMagz*L1^2/L^3)*(L1 + 3*L2),
                                    0,
                                    loadMagz*L1^2*L2/L^2,
                                    loadMagy*L1^2*L2/L^2];
                elseif loadType == 2  % UDL
                    spanQT(i, :) = [-(loadMagx*L)/2,
                                    -(loadMagy*L)/2,
                                    -(loadMagz*L)/2,
                                    0,
                                    -loadMagz*L^2/12,
                                    -loadMagy*L^2/12,
                                    -(loadMagx*L)/2,
                                    -(loadMagy*L)/2,
                                    -(loadMagz*L)/2,
                                    0,
                                    loadMagz*L^2/12,
                                    loadMagy*L^2/12];
                end
                % Converts all member end forces in LCS to GCS
                spanQ = transpose(sum(spanQT, 1));
                spanF = transpose(T)*spanQ;
            end
        end
    else
        spanQT = zeros(1, 12);
        spanQ = transpose(spanQT);
        spanF = transpose(T)*spanQ;
    end
else
    spanQT = zeros(1, 12);
    spanQ = transpose(spanQT);
    spanF = transpose(T)*spanQ;
end