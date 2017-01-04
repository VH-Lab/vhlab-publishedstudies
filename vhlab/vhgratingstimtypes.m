function [gst] = vhgratingstimtypes(addtest)
% VHGRATINGSTIMTYPES Returns known grating stimulus types (VHlab)
%
%  [GRATINGSTIMTYPES] = VHGRATINGSTIMTYPES( ... );
% 
%  This function returns the the tags that can be used for
%  T directories for grating stimuli.
%
%  GRATINGSTIMTYPES is 
%
%  If one uses a nonzero input argument, then the string ' test' is appended to all
%  the names.
% 
%


gst.type = '';
gst.parameter = '';
gst.periodicgenericanalysisfunc = '';

gst = gst([]);

[dirtestnamelist,velocitytestnamelist] = vhdirectiontrainingtypes(0);

for i=1:length(dirtestnamelist),
	gst_here.type= dirtestnamelist{i};
	gst_here.parameter = 'angle';
	gst_here.periodicgenericanalysisfunc = 'otanalysis_compute';
	gst(end+1) = gst_here;
end;

brightnessNames = {'PreOPBrGr'; 'PreOPBrWhFld'; 'PreOPBrBlGr'; 'PreOPBrBlFld'; 'PostOPBrWhGr'; 'PostOPBrWhFld'; 'PostOPBrBlGr'; 'PostOPBrBlFld';...
			'OPBrWhGr1';'OPBrWhGr2';'OPBrWhGr3';'OPBrWhGr4';'OPBrWhGr5';'OPBrWhGr6';'OPBrWhGr7';'OPBrWhGr8';'OPBrWhGr9';'OPBrWhGr10';...
			'OPBrBlGr1';'OPBrBlGr2';'OPBrBlGr3';'OPBrBlGr4';'OPBrBlGr5';'OPBrBlGr6';'OPBrBlGr7';'OPBrBlGr8';'OPBrBlGr9';'OPBrBlGr10';...
			'OPBrWhFld1';'OPBrWhFld2';'OPBrWhFld3';'OPBrWhFld4';'OPBrWhFld5';'OPBrWhFld6';'OPBrWhFld7';'OPBrWhFld8';'OPBrWhFld9';'OPBrWhFld10';...
			'OPBrBlFld1';'OPBrBlFld2';'OPBrBlFld3';'OPBrBlFld4';'OPBrBlFld5';'OPBrBlFld6';'OPBrBlFld7';'OPBrBlFld8';'OPBrBlFld9';'OPBrBlFld10'};


for i=1:length(brightnessNames),
	gst_here.type= brightnessNames{i};
	gst_here.parameter = 'brightness';
	gst_here.periodicgenericanalysisfunc = 'ctanalysis_compute';
	gst(end+1) = gst_here;
end;

tfnames = {'TF1','TF2','TF3','TF4','TF5','TF6','TFOP1','TFOP2','TFOP3','TFOP4','TFOP5','TFOP6'};

for i=1:length(tfnames),
	gst_here.type= tfnames{i};
	gst_here.parameter = 'tFrequency';
	gst_here.periodicgenericanalysisfunc = 'tfanalysis_compute';
	gst(end+1) = gst_here;
end;

sfnames = { 'SFOP1Hz1','SFOP1Hz2','SFOP1Hz3','SFOP1Hz4','SFOP1Hz5','SFOP1Hz6','SFOP1Hz7','SFOP1Hz8',...
                'SFOP2Hz1','SFOP2Hz2','SFOP2Hz3','SFOP2Hz4','SFOP2Hz5','SFOP2Hz6','SFOP2Hz7','SFOP2Hz8',...
                'SFOP4Hz1','SFOP4Hz2','SFOP4Hz3','SFOP4Hz4','SFOP4Hz5','SFOP4Hz6','SFOP4Hz7','SFOP4Hz8',...
                'SFOP8Hz1','SFOP8Hz2','SFOP8Hz3','SFOP8Hz4','SFOP8Hz5','SFOP8Hz6','SFOP8Hz7','SFOP8Hz8'};

for i=1:length(sfnames),
	gst_here.type = sfnames{i};
	gst_here.parameter = 'sFrequency';
	gst_here.periodicgenericanalysisfunc = 'sfanalysis_compute';
	gst(end+1) = gst_here;
end;

singlenames = {'SingleOP4Hz1','SingleOP4Hz2','SingleOP4Hz3','SingleOP4Hz4','SingleOP4Hz5','SingleOP4Hz6',...
	'SingleOP4Hz7','SingleOP4Hz8'};
for i=1:length(singlenames),
	gst_here.type = singlenames{i};
	gst_here.parameter = 'angle';
	gst_here.periodicgenericanalysisfunc = '';
	gst(end+1) = gst_here;
end;

if nargin>0,
	if addtest~=0,
		for i=1:length(gst),
			gst(i).type = [gst(i).type ' test'];
		end;
	end;
end;

