function [output]=plotalltptfs(prefix,expernames,M,N)
  % might use 
  % prefix = '/Volumes/Data2/treeshrew/ZabWoodySteve/';
  % expernames = {'2007-09-19','2013-06-03','2013-06-06'}

[cells,cellnames]=readcellsfromexperimentlist(prefix,expernames,1,5);

pref1 = [];
pref2 = [];
pref3 = [];
high = [];
low = [];

all_splinefits = [];
splinefits_x = [];

all_x = [];
all_raw = [];
all_reallyraw = [];
all_stderr = [];

variation_across = [];


fig = figure;
p = 1;

for i=1:length(cells),
	TFp = findassociate(cells{i},'TP Ach TF visual response p','','');
	TFp_ = findassociate(cells{i},'TP Ach TF sig resp p','','');
	TFpref1 = findassociate(cells{i},'TP Ach TF Pref','','');
	TFhigh = findassociate(cells{i},'TP Ach TF High TF','','');
	TFlow = findassociate(cells{i},'TP Ach TF Low TF','','');
	TFpref2 = findassociate(cells{i},'TP Ach TF DOG Pref','','');
	TFpref3 = findassociate(cells{i},'TP Ach TF spline Pref','','');
	TFspline = findassociate(cells{i},'TP Ach TF spline Fit','','');
	TFresp = findassociate(cells{i},'TP Ach TF Response curve','','');
	TFblank = findassociate(cells{i},'TP Ach TF Blank Response','','');
	if ~isempty(TFp),
		if TFp.data<0.05,
            try,
			all_splinefits = [all_splinefits; TFspline.data(2,:)-TFblank.data(1)];
 			splinefits_x = [TFspline.data(1,:)];
            catch, [all_splinefits; [TFspline.data(2,:)-TFblank.data(1) NaN NaN]];
            end;
			if size(TFresp.data,2)==8, 
				INDS = 1:8;
			elseif size(TFresp.data,2)==10,
				INDS = [ 1:5 7 8 10];
            elseif size(TFresp.data,2)==11,
                INDS = [1 2 3 4 6 8 9 11];
            elseif size(TFresp.data,2)==7,
                INDS = [1 2 3 4 5 6 6 7];
			else,
				INDS = 1:size(TFresp.data,2);
			end;
			all_x  = TFresp.data(1,INDS);
            if ~eqlen([0.5 1 2 4 8 16 20 30],all_x) & ~eqlen([0.5 1 2 4 8 16 16 32],all_x);
                disp(['wrong temporal frequencies']);
                all_x,
                [0.5 1 2 4 8 16 20 30]
                keyboard;
            end;
			all_raw = [ all_raw; rectify(TFresp.data(2,INDS)-TFblank.data(1))];
			all_raw(end,:) = rescale(all_raw(end,:),[min(all_raw(end,:)) max(all_raw(end,:))],[0 1]);
			all_reallyraw = [ all_reallyraw; TFresp.data(2,INDS)-TFblank.data(1)];
			all_stderr = [ all_stderr; TFresp.data(4,INDS)];
			supersubplot(fig,M,N,p);
			plottpresponse(cells{i},cellnames{i},...
				'Temporal frequency spline',1,1,'nopushbutton',1);
			ch = get(gca,'children');
			set(ch,'color',[1 0 0]);
			pref1(end+1) = TFpref1.data;
			pref2(end+1) = TFpref2.data;
			pref3(end+1) = TFpref3.data;
			high(end+1) = TFhigh.data;
			low(end+1) = TFlow.data;
			variation_across(end+1) = TFp_.data;
			A=axis;
			axis([0 32 A(3) A(4)]);
			hold on;
			plot([0 32],[0 0],'k--','linewidth',0.98);
			if mod(p,M)~=1, ylabel(''); end;
			if mod(p-1,M*N)<(N-1)*M, xlabel(''); end;
			p = p + 1;
		end;
	end;
end;

output = workspace2struct;
