function [axleLoc, axleOnMem] = movingLoadAxleLoc(pathMemProp, axleDisplacement, axleLoads)

axleLoc = [];
% This for loop finds the near and far absolute distance of a member in
% pathMemProp. To prevent access of zero index, if memi == 1, the near
% absolute distance for the first member will be set to zero.
for memi = 1:size(pathMemProp, 2)
    if memi == 1
        memberNearDist = 0;
    else 
        memberNearDist = pathMemProp(2, memi-1);
    end
    memberFarDist = pathMemProp(2, memi);
    % This for loop cycles through each axles. For the given member
    % defined by the outer for loop, if the axle location is within the
    % member distance range, assign the axle to that member. If not,
    % zero member is assigned. If the axle load is on a member, the
    % outer for loop will eventually assign a member to the axle load.
    % If the axle load is off all the members, the member assigned to
    % the axle load will remain zero.
    for axlei = 1:size(axleLoads, 2)
         axleLoc(axlei) = axleDisplacement - axleLoads(1, axlei);
         if axleLoc(axlei) <= memberFarDist && axleLoc(axlei) >= memberNearDist
             axleOnMem(axlei) = pathMemProp(1, memi);
         elseif axleLoc(axlei) < 0 || axleLoc(axlei) > pathMemProp(2, end)
             axleOnMem(axlei) = 0;
         end
    end  
end 
