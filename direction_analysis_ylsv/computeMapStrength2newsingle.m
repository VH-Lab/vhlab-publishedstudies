function computeMapStrength2(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};


for I=1:length(expnames),
	tpf = [prefix expnames{I}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	stacknames = findallstacks(ds),
	eyesopen = findassociate(cells{1},'Eyes open','','');
	eyesopen = eyesopen.data;

	for J=1:length(stacknames),
		[mycells,mycellinds] = selectstackcells(ds,stacknames{J});
        mycellnames = cellnames(mycellinds);
        disp(['Total cells:' num2str(length(mycells))]);

		di = []; ot = []; dp = [];
	        incl = []; 
		trained = []; dit = []; ott = []; dpt = [];
        fracgood = []; fracgoodt = [];
        BSfits = {}; BSfitst = {};
		mapstrength = []; mapstrengtht = [];
		pixellocs = {};
		pixellocst = {};
        mycellstruct = struct('DI',[],'BSf',[],'BSrs',[],'DIme',[],'BSfme','','BSrsme',[],'DIfe',[],'BSffe',[],'BSrsfe',[],'pos',[],'expername','','stack','','cellname',[]);
        mycellstruct = mycellstruct([]);
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
                    DIS = calc_bootstrap_di(BSf.data,BSrs.data.blankind,BS.data);
                    fracgood(end+1) = sum(DIS>0)/sum(DIS>-Inf);
					otassoc = findassociate(mycells{z},'TP Ach OT Orientation index','','');
					ot(end+1) = newferretoi(mycells{z},1);
					pixassoc = findassociate(mycells{z},'pixellocs','','');
					pixellocs{end+1} = pixassoc.data;
                    mycs = struct('DI',di(end),'BSf',BSf,'BSrs',BSrs,'DIme',[],'BSfme',[],'BSrsme',[],'DIfe',[],'BSffe',[],'BSrsfe',[],'pos',[mean(pixellocs{end}.x) mean(pixellocs{end}.y)],'expername',expnames{I},'stack',stacknames{J},'cellname',mycellnames{z});
					recov = findassociate(mycells{z},'TP ME Ach OT vec varies p','','');
					recov2 = findassociate(mycells{z},'TP FE Ach OT vec varies p','','');
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
                        DIS = calc_bootstrap_di(BSfme.data,BSrsme.data.blankind,BSme.data);
                        fracgoodt(end+1) = sum(DIS>0)/sum(DIS>-Inf);
                        mycs.DIme = dit(end); mycs.BSfme = BSfme; mycs.BSrsme = BSrsme;
					end;
                    if ~isempty(recov2)&recov2.data<0.05,
                        dirassoc = findassociate(mycells{z},'TP FE Ach OT Fit Direction index blr','','');
                        BSfe = findassociate(mycells{z},'TP FE Ach OT Bootstrap Individual Responses','','');
                        BSffe = findassociate(mycells{z},'TP FE Ach OT Bootstrap Carandini Fit Params','','');
                        BSrsfe = findassociate(mycells{z},'TP FE Ach OT Response struct','','');
                        mycs.DIfe = dirassoc.data;
                        mycs.BSffe = BSffe; mycs.BSrsfe = BSrsfe;
                    end;
                   %mycellstruct, mycs,
                    mycellstruct(end+1) = mycs;
				end;
			end;
		end;
	    save([getscratchdirectory(ds) filesep stacknames{J} '_cellbs_newsingle.mat'],'mycellstruct','eyesopen');
	end;
end;