function [Pstart_Manip] = iontophoresis_approach(T,Ppos_Mic, Ppos_Manip, Offset_Mic);

% IONTOPHORESIS_APPROACH - Calculate iontophoresis approach position
%
%   [Pstart_Manip] = IONTOPHORESIS_APPROACH(T_Mic, Ppos_Mic, Ppos_Manip, Offset_Mic)
%
%  Helps calculate the best starting position (Pstart_Manip) for a pipette
%  that will hit target location T_Mic = [ Tx Ty Tz] that is measured in microscope
%  coordinates.  The user provides at least two measurements of the pipette tip
%  position as it travels along its entry axis.  These measurements must be
%  made in microscope coordinates and manipulator coordinates as follows:
%  Ppos_Mic   =  [P0x P0y P0z; P1x P1y P1z; ... ]
%  Ppos_Manip =  [PM0x PM0y PM0z; PM1x PM1y PM1z; ... ]
%  
%  The final parameter is the desired starting offset.  The user must
%  specify one dimension of the offset relative to the target location,
%  and set the other dimensions equal to NaN.  For example, 
%  Offset_Mic = [5 NaN NaN] specifies that the pipette starting location
%  should be offset 5 units in X from the target location.
%
%  The function returns the starting location PStart_Manip in manipulator
%  coordinates ([PstartX PstartY PstartZ]).
%

D = diff(Ppos_Mic);
dim = find(~isnan(Offset_Mic)); % find desired offset dimension

M = mean(D./repmat(D(:,dim),1,3)),
B = T - M.*T,

%M = mean([D(:,dim12)./D(:,dim)]); % M = [Mxy Mxz] if dim==1
%B = T(dim12) - M*T(dim) ];        % B = [Bxy Bxz] if dim==1

Pstart_Mic = M*(T(dim)+Offset_Mic(dim)) + B;

  % find projection from microscope to manipulator

P = [];
W = warning('query');
warning off;
for k=1:3,
	P(k,[1 2]) = polyfit(Ppos_Mic(:,k),Ppos_Manip(:,k),1);
end;
warning(W);

Pstart_Manip = P(:,1)'.*Pstart_Mic + P(:,2)';
