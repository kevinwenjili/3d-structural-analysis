function [spanMovingLoadTable] = movingLoadSpanLoad(axleLoads, axleLoc, axleOnMem, pathMemProp, La, absL, rowPlace, totFactor)

for axlei = 1:size(axleLoads, 2)

    if axleLoc(axlei) >= 0 && axleLoc(axlei) <= pathMemProp(2, end)
        memberNum = axleOnMem(axlei);
        if memberNum ~= 0,
            loadType = 1;
            L1 = (axleLoc(axlei) + La{memberNum} - absL{memberNum})/La{memberNum} ;
            projType = 1;
            yLoad = axleLoads(2, axlei);
            spanMovingLoadTable(rowPlace, :) = ...
                [memberNum, totFactor, loadType, L1, nan, projType, 0, yLoad, 0];
            rowPlace = rowPlace + 1;
        end
    end
end