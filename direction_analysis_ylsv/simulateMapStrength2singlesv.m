function simulateMapStrength2(prefix,expnames, resimulate, traindir)


% output: 

d1 = 0; d2 = 0;

for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
    D = dir([getscratchdirectory(ds) filesep '*_cellbs.mat']);
    
    for j=1:length(D),
        fname = [getscratchdirectory(ds) filesep D(j).name],
        load(fname);
        eyesopen,
        if sqrt(length(mycellstruct))<1, disp(['excluding ' fname ]); break; end;

		%mapstrength = mapstrength(find(mapstrength(:,[10])<=0.2&mapstrength(:,[11])<=0.2),:);
		%if ~isempty(mapstrengtht), mapstrengtht = mapstrengtht(find(mapstrengtht(:,[10])<=0.2&mapstrengtht(:,[11])<=0.2),:); end;
           
        if eyesopen<=Inf,
            if d1==0, mapnaive = mycellstruct; thetraindir = traindir(i)*ones(1,length(mycellstruct)); d1 = 1;
            else, mapnaive = cat(2,mapnaive,mycellstruct);  thetraindir = cat(2,traindir,traindir(i)*ones(1,length(mycellstruct))); end;
        else,    
            if d2==0, mapold = mycellstruct; d2 = 1; 
            else, mapold = cat(2,mapold,mycellstruct);
            end;
        end;
    end;
end;
mapold = [];
nSims = 100;
% do monte carlo sim
  % output is mcsim = [ di dp ]', each column a new cell, 3rd dimension is reps
mcsim = zeros(2,length(mapnaive),nSims);
mcsimt = zeros(2,length(mapnaive),nSims);
mcsimo = zeros(2,length(mapold),nSims);

if resimulate,
    for i=1:nSims,
        for j=1:length(mapnaive),
            n = min(100,round(1+rand*100));
            mcsim(:,j,i) = [fit2fitdibr(mapnaive(j).BSf.data(n,:), mapnaive(j).BSrs.data.blankresp(1)) mapnaive(j).BSf.data(n,3)]';
            if ~isempty(mapnaive(j).BSfme),
                mcsimt(:,j,i) = [fit2fitdibr(mapnaive(j).BSfme.data(n,:), mapnaive(j).BSrsme.data.blankresp(1)) mapnaive(j).BSfme.data(n,3)]';
            else,
                mcsimt(:,j,i) = [NaN NaN]';
            end;
            if ~isempty(mapnaive(j).BSffe),
                mcsimf(:,j,i) = [fit2fitdibr(mapnaive(j).BSffe.data(n,:), mapnaive(j).BSrsfe.data.blankresp(1)) mapnaive(j).BSffe.data(n,3)]';
            else,
                mcsimf(:,j,i) = [NaN NaN]';
            end;
        end;
        for j=1:length(mapold),
            n = min(100,round(1+rand*100));      
            mcsimo(:,j,i) = [fit2fitdibr(mapold(j).BSf.data(n,:), mapold(j).BSrs.data.blankresp(1)) mapold(j).BSf.data(n,3)]';
        end;
    end
    save('e:\svanhooser\newferretmtg\mcMapSim.mat','mcsim','mcsimt','mcsimo','mapnaive','mapold','mcsimf');
else,
    load('e:\svanhooser\newferretmtg\mcMapSim.mat','mcsim','mcsimt','mcsimo','mapnaive','mapold','mcsimf');
end;

% crunch for plots

  % local bias for each cell
  % prct within 45 deg, prct 180+/-45 deg
  % flipping prob

dists = [50 100 150 200 250] * 512/242;

lbb = {}; lbbd = [];
lba = {}; lbad = [];
lbe = {}; lbed = [];
lsb = {}; lsbd = [];
lsa = {}; lsad = [];
lse = {}; lsed = [];
lob = {}; lobd = [];
loa = {}; load_ = [];
loe = {}; loed = [];
lsba = {}; loba = {}; lsbad = []; lobad = [];
fp = [];
ldsbb = {}; ldsbbd = [];
ldsba = {}; ldsbad = [];
ldsbe = {}; ldsbed = [];



  % annuli, direction, local bias, local bias strength
ladbb = {}; ladbbd = [];
ladba = {}; ladbad = [];
ladbe = {}; ladbed = [];
ladsbb = {}; ladsbbd = [];
ladsba = {}; ladsbad = [];
ladsbe = {}; ladsbed = [];
  % annuli, orientation, local bias, local bias strength
laobb = {}; laobbd = [];
laoba = {}; laobad = [];
laobe = {}; laobed = [];
laosbb = {}; laosbbd = [];
laosba = {}; laosbad = [];
laosbe = {}; laosbed = [];
lsorib = {}; lsoribd = [];
looria = {}; looriad = [];

% change in DI vs. local bias

ddiLB = {}; ddiLBd = [];
ddiLBf = {}; ddiLBdf = [];
unclist = []; uncmod = [];

if 0, % randomly shuffle directions
    for i=1:length(mapnaive),
        if ~isnan(mcsimt(2,i,1)),
            mcsimt(2,i,:) = 360*rand*ones(size(mcsimt(2,i,:)));
        end;
        if ~isnan(mcsimf(2,i,1)),
            mcsimf(2,i,:) = 360*rand*ones(size(mcsimf(2,i,:)));
        end
        if ~isnan(mcsim(2,i,1)),
            mcsim(2,i,:) = 360*rand*ones(size(mcsimt(2,i,:)));
        end;
    end;
end;
    
if 0,  % add uncertainty to direction
    for i=1:length(mapnaive),
        uncb = dpuncertainty(squeeze(mcsim(2,i,:)));
        [unca,I,J] = dpuncertainty(squeeze(mcsimt(2,i,:)));
        if ~isempty(unca),
            J = randperm(length(I));
            if uncb>unca,
                J = J(1:(round(100*(uncb-unca))));
                mcsimt(2,i,I(J)) = mod(mcsimt(2,i,I(J))+180,360);
            elseif unca>uncb,
                [uncb,I,J] = dpuncertainty(squeeze(mcsim(2,i,:)));
                J = randperm(length(I));
                J = J(1:(round(100*(unca-uncb))));
                mcsim(2,i,I(J)) = mod(mcsim(2,i,I(J))+180,360);
                [uncb,I,J] = dpuncertainty(squeeze(mcsim(2,i,:)));
            end;
            unclist(i) = uncb;
            uncmod(i) = dpuncertainty(squeeze(mcsimt(2,i,:)));
        else uncmod(i) = NaN;
        end;
    end;
end;

if 0,
    for i=1:length(mapold),
        uncb = unclist(1+fix(rand*length(unclist)));    % draw one randomly
        [unca,I,J] = dpuncertainty(squeeze(mcsimo(2,i,:)));
        if ~isempty(unca),
            J = randperm(length(I));
            if uncb>unca,
                J = J(1:(round(100*(uncb-unca))));
                mcsimo(2,i,I(J)) = mod(mcsimo(2,i,I(J))+180,360);
            else,
                [uncb,I,J] = dpuncertainty(squeeze(mcsim(2,i,:)));
                J = randperm(length(I));                
                J = J(1:(round(100*(unca-uncb))));
                mcsim(2,i,I(J)) = mod(mcsim(2,i,I(J))+180,360);
                [uncb,I,J] = dpuncertainty(squeeze(mcsim(2,i,:)));
            end;
        end;
    end;
end;

unclistb = []; unclista = []; unclisto = []; unclistf = [];

distdb=[]; diasta=[]; distdf=[]; distdo=[];
dimnb=[]; dimna=[]; dimnf=[]; dimno=[];

for i=1:length(mapnaive),
    myinds = strmatch({mapnaive(i).expername},{mapnaive.expername},'exact');
    inds = setdiff(myinds,i);
    xyothers = cell2mat({mapnaive(inds).pos}');
    unclistb(i) = dpuncertainty(squeeze(mcsim(2,i,:)));
    distdb(i) = std(mcsim(1,i,:));
    distmnb(i) = mean(mcsim(1,i,:));
    dib(i,1:3) = prctile(mcsim(1,i,:),[33 50 66]);
    dia(i,1:3) = prctile(mcsimt(1,i,:),[33 50 66]);

    laobb{i} = localdirbias(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,0,1);
    laosbb{i} = localdirstrengthbias(mcsim(2,i,:),mcsim(1,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',reshape(mcsim(1,inds,:),length(inds),100)',xyothers, dists,0,1);
    ladbb{i} = localdirbias(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    ladsbb{i} = localdirstrengthbias(mcsim(2,i,:),mcsim(1,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',reshape(mcsim(1,inds,:),length(inds),100)',xyothers, dists,1,1);
    lbb{i} = localdirbias(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,1,0);
    ldsbb{i} = localdirstrengthbias(mcsim(2,i,:),mcsim(1,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',reshape(mcsim(1,inds,:),length(inds),100)',xyothers, dists,1,0);
    lsb{i} = localdirsimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    lob{i} = localdirdissimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    lsorib{i} = localdirsimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,0,1);
    loorib{i} = localdirdissimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsim(2,inds,:),length(inds),100)',xyothers, dists,0,1);
    for k=1:length(lbb{i}),
        laobbd(i,1:3,k) = prctile(laobb{i}{k},[33 50 66]);
        laosbbd(i,1:3,k) = prctile(laosbb{i}{k},[33 50 66]);
        ladbbd(i,1:3,k) = prctile(ladbb{i}{k},[33 50 66]);
        ladsbbd(i,1:3,k) = prctile(ladsbb{i}{k},[33 50 66]);
        lbbd(i,1:3,k) = prctile(lbb{i}{k},[33 50 66]);
        ldsbbd(i,1:3,k) = prctile(ldsbb{i}{k},[33 50 66]);
        lsbd(i,1:3,k) = prctile(lsb{i}{k},[33 50 66]);
        lobd(i,1:3,k) = prctile(lob{i}{k},[33 50 66]);
        lsoribd(i,1:3,k) = prctile(lsorib{i}{k},[33 50 66]);
        looribd(i,1:3,k) = prctile(loorib{i}{k},[33 50 66]);
    end;
    if ~isnan(mcsimt(2,i,1)),
        unclista(i) = dpuncertainty(squeeze(mcsimt(2,i,:)));
        distda(i) = std(mcsimt(1,i,:));
        distmna(i) = mean(mcsimt(1,i,:));
        ddiLB{i} = deltaDI(squeeze(mcsim(2,i,:)),squeeze(mcsim(1,i,:)),squeeze(mcsimt(2,i,:)),squeeze(mcsimt(1,i,:)));        
        laoba{i} = localdirbias(mcsimt(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,0,1);
        laosba{i} = localdirstrengthbias(mcsimt(2,i,:),mcsimt(1,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',reshape(mcsimt(1,inds,:),length(inds),100)',xyothers, dists,0,1);
        ladba{i} = localdirbias(mcsimt(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        ladsba{i} = localdirstrengthbias(mcsimt(2,i,:),mcsimt(1,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',reshape(mcsimt(1,inds,:),length(inds),100)',xyothers, dists,1,1);
        lba{i} = localdirbias(mcsimt(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,0);
        ldsba{i} = localdirstrengthbias(mcsimt(2,i,:),mcsimt(1,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',reshape(mcsimt(1,inds,:),length(inds),100)',xyothers, dists,1,0);
        lsa{i} = localdirsimilarity(mcsimt(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        loa{i} = localdirdissimilarity(mcsimt(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        lsba{i} = localdirsimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        loba{i} = localdirdissimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsimt(2,inds,:),length(inds),100)',xyothers, dists,1,1); 
    else,
        unclista(i) = NaN;
        distda(i) = NaN;
        distmna(i) = NaN;
        ddiLB{i} = NaN;
        laoba{i} = {NaN NaN NaN NaN NaN};
        laosba{i} = {NaN NaN NaN NaN NaN};
        ladba{i} = {NaN NaN NaN NaN NaN};
        ladsba{i} = {NaN NaN NaN NaN NaN};
        lba{i} = {NaN NaN NaN NaN NaN};
        lsa{i} = {NaN NaN NaN NaN NaN};
        loa{i} = {NaN NaN NaN NaN NaN};
        lsba{i} = {NaN NaN NaN NaN NaN};
        loba{i} = {NaN NaN NaN NaN NaN};
        ldsba{i} = {NaN NaN NaN NaN NaN};
    end;
    if ~isnan(mcsimf(2,i,1)),
        unclistf(i) = dpuncertainty(squeeze(mcsimf(2,i,:)));
        distdf(i) = std(mcsimf(1,i,:));
        distmnf(i) = mean(mcsimf(1,i,:));
        ddiLBf{i} = deltaDI(squeeze(mcsim(2,i,:)),squeeze(mcsim(1,i,:)),squeeze(mcsimf(2,i,:)),squeeze(mcsimf(1,i,:)));        
        laobaf{i} = localdirbias(mcsimf(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,0,1);
        laosbaf{i} = localdirstrengthbias(mcsimf(2,i,:),mcsimf(1,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',reshape(mcsimf(1,inds,:),length(inds),100)',xyothers, dists,0,1);
        ladbaf{i} = localdirbias(mcsimf(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        ladsbaf{i} = localdirstrengthbias(mcsimf(2,i,:),mcsimf(1,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',reshape(mcsimf(1,inds,:),length(inds),100)',xyothers, dists,1,1);
        lbaf{i} = localdirbias(mcsimf(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,0);
        ldsbaf{i} = localdirstrengthbias(mcsimf(2,i,:),mcsimf(1,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',reshape(mcsimf(1,inds,:),length(inds),100)',xyothers, dists,1,0);
        lsaf{i} = localdirsimilarity(mcsimf(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        loaf{i} = localdirdissimilarity(mcsimf(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        lsbaf{i} = localdirsimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,1);
        lobaf{i} = localdirdissimilarity(mcsim(2,i,:),mapnaive(i).pos,reshape(mcsimf(2,inds,:),length(inds),100)',xyothers, dists,1,1); 
    else,
        unclistf(i) = NaN;
        ddiLBf{i} = NaN;
        laobaf{i} = {NaN NaN NaN NaN NaN};
        laosbaf{i} = {NaN NaN NaN NaN NaN};
        ladbaf{i} = {NaN NaN NaN NaN NaN};
        ladsbaf{i} = {NaN NaN NaN NaN NaN};
        lbaf{i} = {NaN NaN NaN NaN NaN};
        lsaf{i} = {NaN NaN NaN NaN NaN};
        loaf{i} = {NaN NaN NaN NaN NaN};
        lsbaf{i} = {NaN NaN NaN NaN NaN};
        lobaf{i} = {NaN NaN NaN NaN NaN};
        ldsbaf{i} = {NaN NaN NaN NaN NaN};
    end;
    for k=1:length(lba{i}),
        try, laobad(i,1:3,k) = prctile(laoba{i}{k},[33 50 66]); catch, keyboard; end;
        laosbad(i,1:3,k) = prctile(laosba{i}{k},[33 50 66]);
        ladbad(i,1:3,k) = prctile(ladba{i}{k},[33 50 66]);
        ladsbad(i,1:3,k) = prctile(ladsba{i}{k},[33 50 66]);
        lbad(i,1:3,k) = prctile(lba{i}{k},[33 50 66]);
        ldsbad(i,1:3,k) = prctile(ldsba{i}{k},[33 50 66]);
        lsad(i,1:3,k) = prctile(lsa{i}{k},[33 50 66]);
        load_(i,1:3,k) = prctile(loa{i}{k},[33 50 66]);
        lobad(i,1:3,k) = prctile(loba{i}{k},[33 50 66]);
        lsbad(i,1:3,k) = prctile(lsba{i}{k},[33 50 66]);
    end;
    fp(i) = flippingprob(squeeze(mcsim(2,i,:)),squeeze(mcsimt(2,i,:)));
    ddiLBd(i) = median(ddiLB{i});
    for k=1:length(lba{i}),
        try, laobadf(i,1:3,k) = prctile(laobaf{i}{k},[33 50 66]); catch, keyboard; end;
        laosbadf(i,1:3,k) = prctile(laosbaf{i}{k},[33 50 66]);
        ladbadf(i,1:3,k) = prctile(ladbaf{i}{k},[33 50 66]);
        ladsbadf(i,1:3,k) = prctile(ladsbaf{i}{k},[33 50 66]);
        lbadf(i,1:3,k) = prctile(lbaf{i}{k},[33 50 66]);
        ldsbadf(i,1:3,k) = prctile(ldsbaf{i}{k},[33 50 66]);
        lsadf(i,1:3,k) = prctile(lsaf{i}{k},[33 50 66]);
        load_f(i,1:3,k) = prctile(loaf{i}{k},[33 50 66]);
        lobadf(i,1:3,k) = prctile(lobaf{i}{k},[33 50 66]);
        lsbadf(i,1:3,k) = prctile(lsbaf{i}{k},[33 50 66]);
    end;    
    fpf(i) = flippingprob(squeeze(mcsim(2,i,:)),squeeze(mcsimf(2,i,:)));
    ddiLBdf(i) = median(ddiLBf{i});

end;

for i=1:length(mapold),
    die(i,1:3) = prctile(mcsimo(1,i,:),[33 50 66]);
    myinds = strmatch({mapold(i).expername},{mapold.expername},'exact');
    inds = setdiff(myinds,i);
    xyothers = cell2mat({mapold(inds).pos}');
    unclisto(i) = dpuncertainty(squeeze(mcsimo(2,i,:)));
    distdo(i) = std(mcsimo(1,i,:));
    dimno(i) = mean(mcsimo(1,i,:));
    loabe{i} = localdirbias(mcsimo(2,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',xyothers, dists,0,1);
    loasbe{i} = localdirstrengthbias(mcsimo(2,i,:),mcsimo(1,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',reshape(mcsimo(1,inds,:),length(inds),100)',xyothers, dists,0,1);
    ldabe{i} = localdirbias(mcsimo(2,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    ldasbe{i} = localdirstrengthbias(mcsimo(2,i,:),mcsimo(1,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',reshape(mcsimo(1,inds,:),length(inds),100)',xyothers, dists,1,1);
    
    lbe{i} = localdirbias(mcsimo(2,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',xyothers, dists,1,0);
    ldsbe{i} = localdirstrengthbias(mcsimo(2,i,:),mcsimo(1,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',reshape(mcsimo(1,inds,:),length(inds),100)',xyothers, dists,1,0);
    lse{i} = localdirsimilarity(mcsimo(2,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    loe{i} = localdirdissimilarity(mcsimo(2,i,:),mapold(i).pos,reshape(mcsimo(2,inds,:),length(inds),100)',xyothers, dists,1,1);
    for k=1:length(lba{i}),
        loabed(i,1:3,k) = prctile(loabe{i}{k},[33 50 66]);
        loasbed(i,1:3,k) = prctile(loasbe{i}{k},[33 50 66]);
        ldabed(i,1:3,k) = prctile(ldabe{i}{k},[33 50 66]);
        ldasbed(i,1:3,k) = prctile(ldasbe{i}{k},[33 50 66]);
        lbed(i,1:3,k) = prctile(lbe{i}{k},[33 50 66]);
        ldsbed(i,1:3,k) = prctile(ldsbe{i}{k},[33 50 66]);
        lsed(i,1:3,k) = prctile(lse{i}{k},[33 50 66]);
        loed(i,1:3,k) = prctile(loe{i}{k},[33 50 66]);
    end;
end;

save('e:\svanhooser\newferretmtg\mcMapSimCompute_2010single.mat');
