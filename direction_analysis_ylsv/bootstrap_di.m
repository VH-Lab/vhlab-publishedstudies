function [pbefore,pafterme,pafterfe,pchangeme,pchangefe,beforeCI,aftermeCI,afterfeCI, changeorime, changeorife]=bootstrap_di(cell)

pbefore = []; pafterme = []; pafterfe = []; pchangeme = []; pchangefe = [];
beforeCI = []; aftermeCI = []; afterfeCI = []; changeorime = []; changeorife = [];

BS = findassociate(cell,'TP Ach OT Bootstrap Individual Responses','','');
BSf = findassociate(cell,'TP Ach OT Bootstrap Carandini Fit Params','','');
BSrs = findassociate(cell,'TP Ach OT Response struct','','');

BSme = findassociate(cell,'TP ME Ach OT Bootstrap Individual Responses','','');
BSfme = findassociate(cell,'TP ME Ach OT Bootstrap Carandini Fit Params','','');
BSrsme = findassociate(cell,'TP ME Ach OT Response struct','','');

BSfe = findassociate(cell,'TP FE Ach OT Bootstrap Individual Responses','','');
BSffe = findassociate(cell,'TP FE Ach OT Bootstrap Carandini Fit Params','','');
BSrsfe = findassociate(cell,'TP FE Ach OT Response struct','','');

if ~isempty(BS),
	pbefore = 1;
	DIs = calc_bootstrap_di(BSf.data,BSrs.data.blankind,BS.data);
	Y = prctile(DIs,[5 95]);
	if (Y(1)>0&Y(2)>0)|(Y(1)<0&Y(2)<0), pbefore = 0; end;
    beforeCI = prctile(DIs,50+68/2)-prctile(DIs,50-68/2);
end;

if ~isempty(BSme),
	pafterme = 1;
	[DIsme,angme] = calc_bootstrap_di(BSfme.data,BSrsme.data.blankind,BSme.data);
	Y = prctile(DIsme,[5 95]);
	if (Y(1)>0&Y(2)>0)|(Y(1)<0&Y(2)<0), pafterme = 0; end;
    aftermeCI = prctile(DIsme,50+68/2)-prctile(DIsme,50-68/2);
end;

if ~isempty(BSfe),
	pafterfe = 1;
	[DIsfe,angfe] = calc_bootstrap_di(BSffe.data,BSrsfe.data.blankind,BSfe.data);
	Y = prctile(DIsfe,[5 95]);
	if (Y(1)>0&Y(2)>0)|(Y(1)<0&Y(2)<0), pafterfe = 0; end;
    afterfeCI = prctile(DIsfe,50+68/2)-prctile(DIsfe,50-68/2);    
end;

X = -1:0.01:1;

if ~isempty(BS)&~isempty(BSme),
	DIs = abs(DIs);
	I = find(angdiff(angme-BSf.data(:,3))>90);
	DIs(I) = - DIs(I);
	hDIs = histc(DIs,X);
	hDIsme = histc(DIsme,X);
	pchangeme = sum((hDIs./sum(hDIs)).*cumsum(hDIsme./sum(hDIsme)));  % 1-prob DIsme > DIs
	if median(DIs)>median(DIsme),
		pchangeme = -sum((hDIsme./sum(hDIsme)).*cumsum(hDIs./sum(hDIs)));  % 1-prob DIs > DIsme
	end;
     
    distoforidiffs = angdiffwrapsign(mod(BSfme.data(:,3),180)-mod(BSf.data(:,3),180),180);
    bfd=0;
    if min(BSf.data(:,4))<11, disp(['error, bad fitting data before.']); bfd=1; end;
    if min(BSfme.data(:,4))<11, disp(['error, bad fitting data after.']); bfd=1; end;


    %subplot(2,1,2); hist(distoforidiffs);
    changeorime = 1;
    Y=prctile(distoforidiffs,[5 95]);
    if (Y(1)>0&Y(2)>0)|(Y(1)<0&Y(2)<0),
        changeorime = 0;
    else,
    end;
    %if bfd, changeorime, end;
end;

if ~isempty(BS)&~isempty(BSfe),
	DIs = abs(DIs);
	I = find(angdiff(angfe-BSf.data(:,3))>90);
	DIs(I) = - DIs(I);
	hDIs = histc(DIs,X);
	hDIsfe = histc(DIsfe,X);
	pchangefe = sum((hDIs./sum(hDIs)).*cumsum(hDIsfe./sum(hDIsfe)));  % prob DIsfe > DIs
	if median(DIs)>median(DIsfe),
		pchangefe = -sum((hDIsfe./sum(hDIsfe)).*cumsum(hDIs./sum(hDIs)));  % prob DIs > DIsfe
	end;
    distoforidiffs = angdiffwrapsign(mod(BSffe.data(:,3),180)-mod(BSf.data(:,3),180),180);
    changeorife = 1;
    Y=prctile(distoforidiffs,[5 95]);
    if (Y(1)>0&Y(2)>0)|(Y(1)<0&Y(2)<0),
        changeorife = 0;
    end;    
    bfd=0;
    if min(BSf.data(:,4))<11, disp(['error, bad fitting data before.']); bfd=1; end;
    if min(BSffe.data(:,4))<11, disp(['error, bad fitting data after.']); bfd=1; end;
    %if bfd, changeorife, end;
end;
