function computeMapStrength(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

for I=1:length(expnames),
	tpf = [prefix expnames{I}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	stacknames = findallstacks(ds);
	eyesopen = findassociate(cells{1},'Eyes open','','');
	eyesopen = eyesopen.data;

	for J=1:length(stacknames),
		mycells = selectstackcells(ds,stacknames{J});
		di = []; ot = []; dp = [];
	        incl = []; 
		trained = []; dit = []; ott = []; dpt = [];
        fracgood = []; fracgoodt = [];
        BSfits = {}; BSfitst = {};
		mapstrength = []; mapstrengtht = [];
		pixellocs = {};
		pixellocst = {};
		for z=1:length(mycells),
			pvalasoc = findassociate(mycells{z},'TP Ach OT vec varies p','','');
			if ~isempty(pvalasoc),
				if pvalasoc.data<0.05,
					incl(end+1)=z;
					diassoc = findassociate(mycells{z},'TP Ach OT Carandini Fit Params','','');
                    dirassoc = findassociate(mycells{z},'TP Ach OT Fit Direction index blr','','');
                    BS = findassociate(mycells{z},'TP Ach OT Bootstrap Individual Responses','','');
                    BSf = findassociate(mycells{z},'TP Ach OT Bootstrap Carandini Fit Params','','');
                    BSrs = findassociate(mycells{z},'TP Ach OT Response struct','','');
                    BSfits{end+1} = BSf.data(:,3);
					di(end+1) = dirassoc.data;
					dp(end+1) = diassoc.data(3);
                    DIS = calc_bootstrap_di(BSf.data,BSrs.data.blankind);
                    fracgood(end+1) = sum(DIS>0)/sum(DIS>-Inf);
					otassoc = findassociate(mycells{z},'TP Ach OT Orientation index','','');
					ot(end+1) = newferretoi(mycells{z},1);
					pixassoc = findassociate(mycells{z},'pixellocs','','');
					pixellocs{end+1} = pixassoc.data;
					recov = findassociate(mycells{z},'TP ME Ach OT vec varies p','','');
					if ~isempty(recov)&recov.data<0.05,
						trained(end+1) = z;
						diassoc = findassociate(mycells{z},'TP ME Ach OT Carandini Fit Params','','');
                        dirassoc = findassociate(mycells{z},'TP ME Ach OT Fit Direction index blr','','');
						dit(end+1) = dirassoc.data;
						dpt(end+1) = diassoc.data(3);
                   		otassoc = findassociate(mycells{z},'TP ME Ach OT Orientation index','','');
						ott(end+1) = newferretoi(mycells{z},0);
						pixellocst{end+1} = pixassoc.data;
                        BSme = findassociate(mycells{z},'TP ME Ach OT Bootstrap Individual Responses','','');
                        BSfme = findassociate(mycells{z},'TP ME Ach OT Bootstrap Carandini Fit Params','','');
                        BSfitst{end+1} = BSfme.data(:,3);
                        BSrsme = findassociate(mycells{z},'TP ME Ach OT Response struct','','');                        
                        DIS = calc_bootstrap_di(BSfme.data,BSrsme.data.blankind);
                        fracgoodt(end+1) = sum(DIS>0)/sum(DIS>-Inf);
					end;
				end;
			end;
		end;
		for i=1:length(incl),
			dv = di(i)*exp(-sqrt(-1)*(dp(i)*pi/180)); dirvec = [real(dv) imag(dv)];
			ov = ot(i)*exp(-sqrt(-1)*(mod(dp(i),180)*2*pi/180)); otvec = [real(ov) imag(ov)];
			for j=i:length(incl),
				dv2 = di(j)*exp(-sqrt(-1)*(dp(j)*pi/180)); dirvec2 = [real(dv2) imag(dv2)];
				ov2 = ot(j)*exp(-sqrt(-1)*(mod(dp(j),180)*2*pi/180)); otvec2 = [real(ov2) imag(ov2)];
				dx = sqrt((mean(pixellocs{i}.x)-mean(pixellocs{j}.x))^2 + (mean(pixellocs{i}.y)-mean(pixellocs{j}.y))^2);
				mapstrength(end+1,:) = [dx dot(otvec,otvec2) dot(dirvec,dirvec2) angdiffwrap(mod(dp(i),180)-mod(dp(j),180),180) angdiffwrap(dp(i)-dp(j),360) abs(ot(i)-ot(j)) abs(di(i)-di(j)) ot(i) ot(j) di(i) di(j) dp(i) dp(j) ot(i)*ot(j) di(i)*di(j) dot(otvec,otvec2)/(ot(i)*ot(j)) dot(dirvec,dirvec2)/(di(i)*di(j)) fracgood(i) fracgood(j)];
			end;
		end;
		for i=1:length(trained),
			dv = dit(i)*exp(-sqrt(-1)*(dpt(i)*pi/180)); dirvec = [real(dv) imag(dv)];
			ov = ott(i)*exp(-sqrt(-1)*(mod(dpt(i),180)*2*pi/180)); otvec = [real(ov) imag(ov)];
			for j=i:length(trained),
				dv2 = dit(j)*exp(-sqrt(-1)*(dpt(j)*pi/180)); dirvec2 = [real(dv2) imag(dv2)];
				ov2 = ott(j)*exp(-sqrt(-1)*(mod(dpt(j),180)*2*pi/180)); otvec2 = [real(ov2) imag(ov2)];
				dx = sqrt((mean(pixellocst{i}.x)-mean(pixellocst{j}.x))^2 + (mean(pixellocst{i}.y)-mean(pixellocst{j}.y))^2);
				mapstrengtht(end+1,:) = [dx dot(otvec,otvec2) dot(dirvec,dirvec2) angdiffwrap(mod(dpt(i),180)-mod(dpt(j),180),180) angdiffwrap(dpt(i)-dpt(j),360) abs(ott(i)-ott(j)) abs(dit(i)-dit(j)) ott(i) ott(j) dit(i) dit(j) dpt(i) dpt(j) ott(i)*ott(j) dit(i)*dit(j) dot(otvec,otvec2)/(ott(i)*ott(j)) dot(dirvec,dirvec2)/(dit(i)*dit(j)) fracgoodt(i) fracgoodt(j)];
			end;
		end;
	        save([getscratchdirectory(ds) filesep stacknames{J} '_mapstrength.mat'],'mapstrength','mapstrengtht','eyesopen');
	end;
end;