

% First, open a directory structure object that will allow you to explore
% the experimental data

ds = dirstruct('W:\2photon\ferretdirection\2006-11-30')

% to see what methods are available
methods('dirstruct'),

% for example, to see a list of all test directories in the experiment
tests = getalltests(ds),

% for example, to see a list of all references in the experiment
nameref = getallnamerefs(ds)

% to load cells, use the following:

filename = getexperimentfile(ds);

[cells,cellnames] = load2celllist(filename,'cell*','-mat');

% now we have cells

cells{55},

% how can we find out what variables are stored in the cell
%  these variables are called associates

A=findassociate(cells{55},'','','');

% to look at all available variables, use

A.type,

% For example, to look at the orientation response curve, we can do

OTresp = findassociate(cells{55},'OT Response curve','','');
data = OTresp.data;

figure;
plot(data(1,:),data(2,:));

% or we can plot standard error in addition

figure
errorbar(data(1,:),data(2,:),data(4,:))


% Find orientation response curve for cells120 before and after training
OTrespi = findassociate(cells{55},'OT Response curve','','');
data = OTrespi.data;

figure;
errorbar(data(1,:),data(2,:),data(4,:))

OTrespt = findassociate(cells{55},'Recovery OT Response curve','','');
data = OTrespt.data;
hold
errorbar(data(1,:),data(2,:),data(4,:),'r')

%initial and trained cells position
addpath(['C:\users\tools\FitzLabTools\colorposition_analysis_ejmmsv'])
colposstimid

% close multiple windwows
 for i=5:500, try, close(i); end; end;
 
%  Example of calling:
% 
% where directions is the list of directions you used
% sponthint is a hint for the spontaneous rate
% maxresp is a hint for the maximum response
% otpref is a hint for the ot preference
% 90 is a width hint
% then there are variable arguments
% 'widthint' is the range of widths that can be returned
%         here I have computed da = diff(directions); da = da(1);
% tuneresps are the actual data responses

[Rsp,Rp,Ot,sigm,Rn,fitcurve,er] = otfit_carandini2(directions,sponthint,maxresp,otpref,90,'widthint',[da/2 180], 'data',tuneresps);

%1) Make sure all cells are marked appropriately as cell or glia and all desired cells are drawn
%2) For each slice that is good and should be included, select it in list and click "Add slice to DB"
%3) At the end of experiment, run
analyzedirtpexper(PATHNAME, 1)

%For example, 
PATHNAME = 'C:\Users\Fitz_lab\2006-11-29'

% If you accidentally add a slice to the DB that you don't want, you have to start over.
% First, delete the file PATHNAME/analysis/experiment.mat
% Then re-add your slices to the database

