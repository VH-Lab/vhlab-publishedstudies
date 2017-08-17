function plotfullcycleavgplaid(cellinfo, mycell,mycellname, varargin)

testname = 'ContrastPlaid test';
dirname = '';
param = '';
numstims = 12;

Np = 4;
Mp = 3;

axis_min = Inf;
axis_max = -Inf;
rescale_axes = 1;

if nargin>2,
    assign(varargin{:});    
end;


myassoc=findassociate(mycell,testname,'','');
if ~isempty(myassoc) | ~isempty(dirname),
	if isempty(dirname),
		dirname = myassoc.data;
	end;
	ds = dirstruct([cellinfo.prefix filesep cellinfo.experdate]);

	[dummy,dummy,dummy,params,dummy,dummy,co]=singleunitgrating2(ds, mycell, mycellname, dirname, 'angle', 0, 'stimnumber');
	g = load([cellinfo.prefix filesep cellinfo.experdate filesep dirname filesep 'stims.mat']);

	figure;
	ro = getoutput(co.cycg_rast{1});
	bl.data = co.blank.f0curve{1}(2);

	for i=1:numstims,

		subplot(Np,Mp,i);

		df = diff(ro.bins{i}(1:2));
		norm = 1/(ro.N(i)*df); % divide by bin width to get spikes/sec
		tf = params{i}.tFrequency;
    
		values = sort(ro.rast{i}(1,:));
		values = [values-1/tf values values+1/tf];
    
		[Yn,Xn] = slidingwindowfunc(values, values, -0.050/2, 0.001, 1/tf+0.050, 0.050,'length',0);
		plot(Xn,Yn/(0.050*ro.N(i))-bl.data(1),'k-');
    
		A=axis;
		%[ro.bins{i}(1) ro.bins{i}(end)],
		axis([0 1/tf A(3) A(4)]);
		axis_min = min(A(3), axis_min);
		axis_max = max(A(4), axis_max);
		hold on;
		f1 = mean(co.f1vals{1}(:,i));
		f0=mean(co.f0vals{1}(:,i));
		t = 0:0.001:1/tf;
		plot([t],0*t,'k--');
		box off;
		plot([.05 .05],[0 10],'k-','linewidth',2); % scale bar

		myparameters = getparameters(get(g.saveScript,i));
		anglestring = num2str(myparameters.angle);
		if isfield(myparameters,'ps_add'), anglestring = 'plaid'; end;
		contraststring = num2str(myparameters.contrast);
		titlestr = ['ct=' contraststring ', theta = ' anglestring];
		if i==1,
			titlestr = {mycellname ; titlestr}; 
		end;
		if i==2,
			codestr = [];
			if strcmp(cellinfo.rearing,'dark'),
				codestr = [codestr 'DR'];
			else,
				codestr = [codestr 'TR'];
			end;
			if strcmp(cellinfo.training_type,'multidirectional'),
				codestr = [codestr 't'];
			end;
			codestr = [codestr ' p' int2str(cellinfo.agegroup)];
			titlestr = {codestr ; titlestr};
		end;

		if i==Mp
			titlestr = {'scalebar=10sp/s'; titlestr};
		end;
		title(titlestr,'interp','none');
		axis off
	end;

	for i=1:numstims,
		if rescale_axes,
			subplot(Np,Mp,i);
			A=axis;
			axis([A(1) A(2) axis_min axis_max]);
		end;
	end;
end;

