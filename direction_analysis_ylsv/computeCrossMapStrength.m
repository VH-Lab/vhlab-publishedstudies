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
		trained = []; dit = []; ott = []; dpt = []; sigdirp = [];
		mapstrength = []; mapstrengtht = [];
		pixellocs = {};
		pixellocst = {};
		for z=1:length(mycells),
			pvalasoc = findassociate(mycells{z},'OT vec varies p','','');
			if ~isempty(pvalasoc),
				if pvalasoc.data<0.05,
					diassoc = findassociate(mycells{z},'OT Carandini Fit Params','','');
					otassoc = findassociate(mycells{z},'OT Orientation index','','');
					pixassoc = findassociate(mycells{z},'pixellocs','','');
					recov = findassociate(mycells{z},'Recovery OT vec varies p','','');
					if ~isempty(recov)&recov.data<0.05,
						incl(end+1)=z;
						di(end+1) = (diassoc.data(2)-diassoc.data(5))/(diassoc.data(2));
						dp(end+1) = diassoc.data(3);
						ot(end+1) = otassoc.data;
						pixellocs{end+1} = pixassoc.data;
						trained(end+1) = z;
						diassoc = findassociate(mycells{z},'Recovery OT Carandini Fit Params','','');
						dit(end+1) = (diassoc.data(2)-diassoc.data(5))/(diassoc.data(2));
						dpt(end+1) = diassoc.data(3);
                   		otassoc = findassociate(mycells{z},'Recovery OT Orientation index','','');
						ott(end+1) = otassoc.data;
						pixellocst{end+1} = pixassoc.data;
						dirpassoc = findassociate(mycells{z},'OT Significant Direction p','','');
						sigdirp(end+1) = dirpassoc.data;
					end;
				end;
			end;
		end;
		for i=1:length(incl),
			dv = di(i)*exp(-sqrt(-1)*(dp(i)*pi/180)); dirvec = [real(dv) imag(dv)];
			ov = ot(i)*exp(-sqrt(-1)*(mod(dp(i),180)*2*pi/180)); otvec = [real(ov) imag(ov)];
			for j=1:length(incl),
				dv2 = dit(j)*exp(-sqrt(-1)*(dpt(j)*pi/180)); dirvec2 = [real(dv2) imag(dv2)];
				ov2 = ott(j)*exp(-sqrt(-1)*(mod(dpt(j),180)*2*pi/180)); otvec2 = [real(ov2) imag(ov2)];
				dx = sqrt((mean(pixellocs{i}.x)-mean(pixellocs{j}.x))^2 + (mean(pixellocs{i}.y)-mean(pixellocs{j}.y))^2);
				mapstrength(end+1,:) = [dx dot(otvec,otvec2) dot(dirvec,dirvec2) angdiffwrap(mod(dp(i),180)-mod(dpt(j),180),180) angdiffwrap(dp(i)-dpt(j),360) abs(ot(i)-ott(j)) abs(di(i)-dit(j)) otvec otvec2 dirvec dirvec2 sigdirp(i) sigdirp(j)];
			end;
		end;
        save([getscratchdirectory(ds) filesep stacknames{J} '_mapstrengthcross.mat'],'mapstrength','mapstrengtht','eyesopen');
	end;
end;

