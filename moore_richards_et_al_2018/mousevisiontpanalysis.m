function [output] = mousevisiontpanalysis(prefix,expnames)  % filename where results should be saved


    %1=all significant

params = {};
    
for k=1:7,
    DI{k} = [];   % Direction index (Rp-Rn)/Rp
    OI{k} = [];   % Orientation index (Pref-Orth)/Pref
    DIsp{k} = []; % Direction index w/ spontaneous corrected (Rp-Rn)/(Rp-Sp)
    OIsp{k} = []; % Orientation index w/ spontaneous corrected (Pref-Orth)/(Pref-Sp)
    DIbr{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    OIbr{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    blr{k} = [];  % blank response
    DIr{k} = [];  % Direction index, raw data
    OIr{k} = [];  % Orientation index, raw data
    CV{k} = [];
    DI_be{k} = [];   % Direction index (Rp-Rn)/Rp
    OI_be{k} = [];   % Orientation index (Pref-Orth)/Pref
    DIsp_be{k} = []; % Direction index w/ spontaneous corrected (Rp-Rn)/(Rp-Sp)
    OIsp_be{k} = []; % Orientation index w/ spontaneous corrected (Pref-Orth)/(Pref-Sp)
    DIbr_be{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    OIbr_be{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    blr_be{k} = [];  % blank response
    DIr_be{k} = [];  % Direction index, raw data
    OIr_be{k} = [];  % Orientation index, raw data
    CV_be{k} = [];
    DImod{k} = [];
    DImod2{k} = [];
    totals{k} = [];
    totalsi{k} = {};
    totalsir{k} = {};
    params{k} = [];

    
    orth{k} = []; % orthogonal response
    drift{k} = [];% median drift of cell
    pref{k} = [];
    null{k} = [];
    anim{k} = [];
    cellnamevar{k} = {};
    experindex{k} = [];
    pos{k} = zeros(2,1);
    pos{k} = pos{k}(:,[]);

    contmax{k} = [];
    ipsimax{k} = [];
    CI{k} = [];
    CIgood{k} = [];
end;


for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	genotype_code = findassociate(cells{1},'Genotype code','','');
	disp(['Genotype code: ' int2str(genotype_code.data) '.']);
	K = genotype_code.data;

	totalsi{K}{i} = [];
	totalsir{K}{i} = [];

	for j=1:length(cells),
		di_ = findassociate(cells{j},'TP Ach OT Fit Direction index','','');
		ot_ = findassociate(cells{j},'TP Ach OT Fit Orientation index','','');
		di_s = findassociate(cells{j},'TP Ach OT Fit Direction index sp','','');
		ot_s = findassociate(cells{j},'TP Ach OT Fit Orientation index sp','','');
		di_bl = findassociate(cells{j},'TP Ach OT Fit Direction index blr','','');
		ot_bl = findassociate(cells{j},'TP Ach OT Fit Orientation index blr','','');        
		di_r = findassociate(cells{j},'TP Ach OT Direction index','','');
		ot_r = findassociate(cells{j},'TP Ach OT Orientation index','','');        

 % contra
		di_cc = findassociate(cells{j},'TP CONT Ach OT Fit Direction index','','');
		ot_cc = findassociate(cells{j},'TP CONT Ach OT Fit Orientation index','','');
		di_scc = findassociate(cells{j},'TP CONT Ach OT Fit Direction index sp','','');
		ot_scc = findassociate(cells{j},'TP CONT Ach OT Fit Orientation index sp','','');
		di_blcc = findassociate(cells{j},'TP CONT Ach OT Fit Direction index blr','','');
		ot_blcc = findassociate(cells{j},'TP CONT Ach OT Fit Orientation index blr','','');        
		di_rcc = findassociate(cells{j},'TP CONT Ach OT Direction index','','');
		ot_rcc = findassociate(cells{j},'TP CONT Ach OT Orientation index','','');        
		cv__cc = findassociate(cells{j},'TP CONT Ach OT Circular variance','','');
		blr_cc = findassociate(cells{j},'TP CONT Ach OT Blank Response','','');

 % ipsi

		di_ii = findassociate(cells{j},'TP IPSI Ach OT Fit Direction index','','');
		ot_ii = findassociate(cells{j},'TP IPSI Ach OT Fit Orientation index','','');
		di_sii = findassociate(cells{j},'TP IPSI Ach OT Fit Direction index sp','','');
		ot_sii = findassociate(cells{j},'TP IPSI Ach OT Fit Orientation index sp','','');
		di_blii = findassociate(cells{j},'TP IPSI Ach OT Fit Direction index blr','','');
		ot_blii = findassociate(cells{j},'TP IPSI Ach OT Fit Orientation index blr','','');        
		di_rii = findassociate(cells{j},'TP IPSI Ach OT Direction index','','');
		ot_rii = findassociate(cells{j},'TP IPSI Ach OT Orientation index','','');        
		cv__ii = findassociate(cells{j},'TP IPSI Ach OT Circular variance','','');
		blr_ii = findassociate(cells{j},'TP IPSI Ach OT Blank Response','','');

		max_resp = findassociate(cells{j},'TP Ach OT Max Response','','');
		max_resp_c = findassociate(cells{j},'TP CONT Ach OT Max Response','','');
		max_resp_i = findassociate(cells{j},'TP IPSI Ach OT Max Response','','');
		pvalasoc = findassociate(cells{j},'TP Ach OT vec varies p','','');
		resppvalasoc = findassociate(cells{j},'TP Ach OT visual response p','','');
		pvalasoc_c = findassociate(cells{j},'TP CONT Ach OT vec varies p','','');
		resppvalasoc_c = findassociate(cells{j},'TP CONT Ach OT visual response p','','');
		pvalasoc_i = findassociate(cells{j},'TP IPSI Ach OT vec varies p','','');
		resppvalasoc_i = findassociate(cells{j},'TP IPSI Ach OT visual response p','','');
		cv__ = findassociate(cells{j},'TP Ach OT Circular variance','','');
		blr_ = findassociate(cells{j},'TP Ach OT Blank Response','','');
		fitv = findassociate(cells{j},'TP Ach OT Carandini Fit','','');
		fitv_p = findassociate(cells{j},'TP Ach OT Carandini Fit Params','','');
		blrcont = findassociate(cells{j},'TP CONT Ach OT Blank Response','','');
		blripsi = findassociate(cells{j},'TP IPSI Ach OT Blank Response','','');

		pixelassoc = findassociate(cells{j},'pixellocs','','');


		A = 0;
		B = 0;
		C = 0;
		if ~isempty(pvalasoc),
			A = pvalasoc.data<0.05;
		end;
		if ~isempty(pvalasoc_c),
			B = pvalasoc_c.data<0.05;
		end;
		if ~isempty(pvalasoc_i),
			C = pvalasoc_i.data<0.05;
		end;

		if A|B|C,
			if K<inf,
				totals{K}(end+1) = j;
				if ~isempty(pvalasoc_c),
					totalsi{K}{i}(end+1) = pvalasoc_c.data;
	    				totalsir{K}{i}(end+1) = resppvalasoc_c.data;
				else,
					totalsi{K}{i}(end+1) = NaN;
	    				totalsir{K}{i}(end+1) = NaN;
				end;
				try,
					CV{K}(end+1) = cell2circular_variance(cells{j},'TP Ach');
				catch,
					CV{K}(end+1) = NaN;
				end;
				try,
					DImod{K}(end+1) = cell2modifiedvectorDI(cells{j},'TP Ach');
				catch,
					DImod{K}(end+1) = NaN;
				end;
				try,
					DImod2{K}(end+1) = cell2dircircular_variance(cells{j},'TP Ach');
				catch,
					DImod2{K}(end+1) = NaN;
				end;

				if A,
				params{K} = cat(1,params{k},fitv_p.data);
				DI{K}(end+1) = di_.data(1);
				OI{K}(end+1) = ot_.data;
				DIsp{K}(end+1) = di_s.data;
				OIsp{K}(end+1) = ot_s.data;
				DIbr{K}(end+1) = di_bl.data;
				OIbr{K}(end+1) = ot_bl.data;
				blr{K}(end+1) = blr_.data(1);
				DIr{K}(end+1) = di_r.data;
				OIr{K}(end+1) = ot_r.data;
				pref{K}(end+1) = fit2pref(fitv.data);
				null{K}(end+1) = fit2null(fitv.data);
				orth{K}(end+1) = fit2orth(fitv.data);
				else,
				params{K} = cat(1,params{k},{''});
				DI{K}(end+1) = NaN;
				OI{K}(end+1) = NaN;
				DIsp{K}(end+1) = NaN;
				OIsp{K}(end+1) = NaN;
				DIbr{K}(end+1) = NaN;
				OIbr{K}(end+1) = NaN;
				blr{K}(end+1) = NaN;
				DIr{K}(end+1) = NaN;
				OIr{K}(end+1) = NaN;
				pref{K}(end+1) = NaN;
				null{K}(end+1) = NaN;
				orth{K}(end+1) = NaN;

				end;
				drift{K}(end+1) = getdriftcorrection(cells{j},ds,1);
				anim{K}(end+1) = i;
				cellnamevar{K}{end+1} = cellnames{j};
				experindex{K}(end+1) = i;
				pos{K}(:,end+1) = [mean(pixelassoc.data.x) mean(pixelassoc.data.y)];
				if ~isempty(max_resp_c),
					contmax{K}(end+1) = rectify(max_resp_c.data(1)-blrcont.data(1));
				else,
					contmax{K}(end+1) = NaN;
				end;
				if ~isempty(max_resp_i),
					ipsimax{K}(end+1) = rectify(max_resp_i.data(1)-blripsi.data(1));
				else,
					ipsimax{K}(end+1) = NaN;
				end;
				CI{K}(end+1) = (contmax{K}(end)-ipsimax{K}(end))/(contmax{K}(end)+ipsimax{K}(end));
				if ~isempty(max_resp_c) & ~isempty(max_resp_i),
					if contmax{K}(end)>ipsimax{K}(end), % contra is bigger
						DI_be{K}(end+1) = di_cc.data(1);   % Direction index (Rp-Rn)/Rp
						OI_be{K}(end+1) = ot_cc.data(1);   % Orientation index (Pref-Orth)/Pref
						DIsp_be{K}(end+1) = di_scc.data; % Direction index w/ spontaneous corrected (Rp-Rn)/(Rp-Sp)
						OIsp_be{K}(end+1) = ot_scc.data; % Orientation index w/ spontaneous corrected (Pref-Orth)/(Pref-Sp)
						DIbr_be{K}(end+1) = di_blcc.data; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
						OIbr_be{K}(end+1) = ot_blcc.data; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
						blr_be{K}(end+1) = blr_cc.data(1);  % blank response
						DIr_be{K}(end+1) = di_rcc.data;  % Direction index, raw data
						OIr_be{K}(end+1) = ot_rcc.data;  % Orientation index, raw data
						CV_be{K}(end+1) = cell2circular_variance(cells{j},'TP CONT Ach');
					else,
						DI_be{K}(end+1) = di_ii.data(1);   % Direction index (Rp-Rn)/Rp
						OI_be{K}(end+1) = ot_ii.data(1);   % Orientation index (Pref-Orth)/Pref
						DIsp_be{K}(end+1) = di_sii.data; % Direction index w/ spontaneous corrected (Rp-Rn)/(Rp-Sp)
						OIsp_be{K}(end+1) = ot_sii.data; % Orientation index w/ spontaneous corrected (Pref-Orth)/(Pref-Sp)
						DIbr_be{K}(end+1) = di_blii.data; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
						OIbr_be{K}(end+1) = ot_blii.data; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
						blr_be{K}(end+1) = blr_ii.data(1);  % blank response
						DIr_be{K}(end+1) = di_rii.data;  % Direction index, raw data
						OIr_be{K}(end+1) = ot_rii.data;  % Orientation index, raw data
						CV_be{K}(end+1) = cell2circular_variance(cells{j},'TP IPSI Ach');
					end;
				else,
						DI_be{K}(end+1) = NaN;
						OI_be{K}(end+1) = NaN;
						DIsp_be{K}(end+1) = NaN;
						OIsp_be{K}(end+1) = NaN;
						DIbr_be{K}(end+1) = NaN;
						OIbr_be{K}(end+1) = NaN;
						blr_be{K}(end+1) = NaN;
						DIr_be{K}(end+1) = NaN;
						OIr_be{K}(end+1) = NaN;
						CV_be{K}(end+1) = NaN;
				end;
			end;
		end;
	end;
end;

output = workspace2struct;
