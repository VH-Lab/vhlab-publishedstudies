function dirtpsummary(cells,cellnames)


w = []; cv = []; p = []; mr = []; indshere = []; di = []; dif = []; oi=[]; tw = []; otpf=[]; dif2 = [];
vecp = [];trained=[];

otvp = []; vvp = [];

for i=1:length(cells),
    type=findassociate(cells{i},'analyzetpstack type','','');
	width = findassociate(cells{i},'OT Tuning width','','');
	circv = findassociate(cells{i},'OT Circular variance','','');
	otparams = findassociate(cells{i},'OT Carandini Fit Params','','');
	dirp= findassociate(cells{i},'OT Direction index','','');
	dirf= findassociate(cells{i},'OT Fit Direction index','','');
	dirf2= findassociate(cells{i},'OT Direction index 2 peak','','');
	oti= findassociate(cells{i},'OT Orientation index','','');
	twa= findassociate(cells{i},'OT Tuning width 2 Peak','','');
	otp   = findassociate(cells{i},'OT varies p','','');
	vp   = findassociate(cells{i},'OT visual response p','','');
	ot_pref = findassociate(cells{i},'OT Fit Pref','','');
	vecpa = findassociate(cells{i},'OT vec varies p','','');
    tra = findassociate(cells{i},'Rapid Direction Training','','');
    if ~isempty(type),
        if strcmp(type.data,'cell'),
            if ~isempty(otp), otvp(end+1) = otp.data; end;
            if ~isempty(vp), vvp(end+1) = vp.data; end;
            if ~isempty(vecpa),vecp(end+1) = vecpa.data; end;
            if ~isempty(tra), trained(end+1)=tra.data; else, trained(end+1)=0; end;

            if ~isempty(width)&~isempty(circv)&~isempty(otp),
            	w = [w width.data]; cv = [cv circv.data]; mr = [mr max(otparams.data([2 5]))];
        		indshere = [indshere i]; di = [di dirp.data]; dif=[dif dirf.data]; dif2=[dif2 dirf2.data];
                oi=[oi oti.data]; tw = [tw twa.data]; otpf = [otpf; ot_pref.data];
            end;
        end;
    end;
end;


disp(['----------------------------------------------']);
disp([int2str(length(find(tw<65))) ' of ' int2str(length(tw)) ' cells have tuning width < 65 deg']);
disp([int2str(length(find(tw<90))) ' of ' int2str(length(tw)) ' cells have tuning width < 90 deg']);
disp([int2str(length(find(otvp<0.05))) ' of ' int2str(length(otvp)) ' cells show variation across orientation (P<0.05)']);
disp([int2str(length(find(vvp<0.05))) ' of ' int2str(length(vvp)) ' cells show variation across stims and blank (P<0.05)']);
disp([int2str(length(find(vecp<0.05))) ' of ' int2str(length(vecp)) ' cells show vector variation across orientation (P<0.05)']);
disp(['----------------------------------------------']);
disp(['Analyzing only cells w/ significant variation:']);
SV = find(vvp<0.05);
disp([int2str(length(find(tw(SV)<65))) ' of ' int2str(length(tw(SV))) ' cells have tuning width < 65 deg']);
disp([int2str(length(find(tw(SV)<90))) ' of ' int2str(length(tw(SV))) ' cells have tuning width < 90 deg']);
disp([int2str(length(find(dif(SV)>0.5))) ' of ' int2str(length(dif(SV))) ' cells have DI fit >0.5']);
disp([int2str(length(find(dif2(SV)>0.5))) ' of ' int2str(length(dif2(SV))) ' cells have DI 2 peak fit >0.5']);
disp([int2str(length(find(di(SV)>0.5))) ' of ' int2str(length(di(SV))) ' cells have DI (no fit) >0.5']);
disp(['Median DI w/ fit: ' num2str(median(dif(SV))) '.']);
disp(['Median DI w/ 2 peak fit: ' num2str(median(dif2(SV))) '.']);
disp(['Median DI ' num2str(median(di(SV))) '.']);
disp(['----------------------------------------------']);
disp(['Analyzing only cells w/ OT < 65:']);
OT = find(tw<65);
disp([int2str(length(find(otvp(OT)<0.05))) ' of ' int2str(length(otvp(OT))) ' cells show variation across orientation (P<0.05)']);
disp([int2str(length(find(vvp(OT)<0.05))) ' of ' int2str(length(vvp(OT))) ' cells show variation across stims and blank (P<0.05)']);
disp([int2str(length(find(dif(OT)>0.5))) ' of ' int2str(length(dif(OT))) ' cells have DI fit >0.5']);
disp([int2str(length(find(dif2(OT)>0.5))) ' of ' int2str(length(dif2(OT))) ' cells have DI 2 peak fit >0.5']);
disp([int2str(length(find(di(OT)>0.5))) ' of ' int2str(length(di(OT))) ' cells have DI (no fit) >0.5']);
disp(['Median DI w/ fit: ' num2str(median(dif(OT))) '.']);
disp(['Median DI w/ 2 peak fit: ' num2str(median(dif2(OT))) '.']);
disp(['Median DI ' num2str(median(di(OT))) '.']);
disp(['----------------------------------------------']);
disp(['Analyzing only cells w/ sig. vector variation:']);
OT = find(vecp<0.05);
disp([int2str(length(find(otvp(OT)<0.05))) ' of ' int2str(length(otvp(OT))) ' cells show variation across orientation (P<0.05)']);
disp([int2str(length(find(vvp(OT)<0.05))) ' of ' int2str(length(vvp(OT))) ' cells show variation across stims and blank (P<0.05)']);
disp([int2str(length(find(tw(OT)<65))) ' of ' int2str(length(tw(OT))) ' cells have tuning width < 65 deg']);
disp([int2str(length(find(tw(OT)<90))) ' of ' int2str(length(tw(OT))) ' cells have tuning width < 90 deg']);
disp([int2str(length(find(dif(OT)>0.5))) ' of ' int2str(length(dif(OT))) ' cells have DI fit >0.5']);
disp([int2str(length(find(dif2(OT)>0.5))) ' of ' int2str(length(dif2(OT))) ' cells have DI 2 peak fit >0.5']);
disp([int2str(length(find(di(OT)>0.5))) ' of ' int2str(length(di(OT))) ' cells have DI (no fit) >0.5']);
disp(['Median DI w/ fit: ' num2str(median(dif(OT))) '.']);
disp(['Median DI w/ 2 peak fit: ' num2str(median(dif2(OT))) '.']);
disp(['Median DI ' num2str(median(di(OT))) '.']);
disp(['----------------------------------------------']);
if length(find(trained))>0,
    SV = find(vvp<0.05&trained==0);
    disp([int2str(length(find(tw(SV)<65))) ' of ' int2str(length(tw(SV))) ' untrained cells have tuning width < 65 deg']);
    disp([int2str(length(find(tw(SV)<90))) ' of ' int2str(length(tw(SV))) ' untrained cells have tuning width < 90 deg']);
    disp([int2str(length(find(dif(SV)>0.5))) ' of ' int2str(length(dif(SV))) ' untrained cells have DI fit >0.5']);
    disp([int2str(length(find(dif2(SV)>0.5))) ' of ' int2str(length(dif2(SV))) ' untrained cells have DI 2 peak fit >0.5']);
    disp([int2str(length(find(di(SV)>0.5))) ' of ' int2str(length(di(SV))) ' untrained cells have DI (no fit) >0.5']);
    disp(['Median untrained DI w/ fit: ' num2str(median(dif(SV))) '.']);
    disp(['Median untrained DI w/ 2 peak fit: ' num2str(median(dif2(SV))) '.']);
    disp(['Median untrained DI ' num2str(median(di(SV))) '.']);
    SV = find(vvp<0.05&trained==1);
    disp([int2str(length(find(tw(SV)<65))) ' of ' int2str(length(tw(SV))) ' trained cells have tuning width < 65 deg']);
    disp([int2str(length(find(tw(SV)<90))) ' of ' int2str(length(tw(SV))) ' trained cells have tuning width < 90 deg']);
    disp([int2str(length(find(dif(SV)>0.5))) ' of ' int2str(length(dif(SV))) ' trained cells have DI fit >0.5']);
    disp([int2str(length(find(dif2(SV)>0.5))) ' of ' int2str(length(dif2(SV))) ' trained cells have DI 2 peak fit >0.5']);
    disp([int2str(length(find(di(SV)>0.5))) ' of ' int2str(length(di(SV))) ' trained cells have DI (no fit) >0.5']);
    disp(['Median trained DI w/ fit: ' num2str(median(dif(SV))) '.']);
    disp(['Median trained DI w/ 2 peak fit: ' num2str(median(dif2(SV))) '.']);
    disp(['Median trained DI ' num2str(median(di(SV))) '.']);    
end;
