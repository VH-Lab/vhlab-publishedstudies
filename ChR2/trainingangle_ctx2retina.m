function [retina_angle] = trainingangle_ctx2retina(cortex_angle, hemisphere)
% TRAININGANGLE_CTX2RETINA - Convert a cortical training angle to retinal equivalent
%
%  [RETINA_ANGLE] = TRAININGANGLE_CTX2RETINA(CORTEX_ANGLE,HEMISPHERE)
%
%  This converts the VH lab projector coordinate system directional stimulation angle
%  into what we expect is the corresponding retinal coordinates are on the retina.
%
%  The retinal coordinates are expressed in compass coordinates, with stimuli moving
%  upward being 0 degrees and with angles increasing in a clockwise manner.
%
%  The cortical coordinates (which could in principle change if the projector or light path
%  is rotated) assume that 120 degrees corresponds to straight up and angles increase in a 
%  counter-clockwise manner.
%
%  HEMISPHERE should be 'right' or 'left'.
%
%  These angles are in degrees.
%
%  The equation for the right hemisphere is:  RETINA_ANGLE =  CORTEX_ANGLE - 120
%  The equation for the left hemisphere is:   RETINA_ANGLE = -CORTEX_ANGLE + 120
%

if strcmp(lower(hemisphere),'right'),
	retina_angle = mod(cortex_angle-120,360);
elseif strcmp(lower(hemisphere),'left'),
	retina_angle = mod(-cortex_angle+120,360);
else,
	error(['Do not know how to process hemisphere ' hemisphere '.']);
end;


