function [OD,locinds,loc,ODdata] = newferretOD(cell, property)

bor_assoc = {'Best orientation resp','Best OT recovery resp'};

%BSf_assoc = {'TP Ach OT Bootstrap Carandini Fit Params','TP ME Ach OT Bootstrap Carandini Fit Params'};

OD= []; ODdata = [];
for i = 1:2
    di = findassociate(cell,['TP ' property{i} 'Ach OT Fit Direction index blr'],'','');
    loc=findassociate(cell,'pixellocs','','');
    locinds=findassociate(cell,'pixelinds','','');
    bor=findassociate(cell,bor_assoc{i},'','');
    dp = findassociate(cell,['TP ' property{i} 'Ach OT Fit Pref'],'','');
    f=findassociate(cell,['TP ' property{i} 'Ach OT Carandini Fit Params'],'','');
    fi=findassociate(cell,['TP ' property{i} 'Ach OT Carandini Fit'],'','');
    %BSf = findassociate(cell,BSf_assoc{i},'','');
    rs = findassociate(cell,['TP ' property{i} 'Ach OT Response struct'],'','');

    if isempty(di)|isempty(loc)|isempty(dp)|isempty(fi), 
        di = []; dp = []; BSdi = []; BSdp = []; Rp = []; Rpbl = []; Rm = []; Rmbl = []; Rn = []; Ro = []; Rt = []; x = []; y = [];
        Rpraw = []; Rmraw = []; dpraw = []; Rprawbl = []; Rmrawbl = []; return; 
    end;

    if isfield(rs(1).data,'blankresp'),
        blankresp = min(0,rs(1).data.blankresp(1));
    else, blankresp = 0;
    end;
   
    OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));
    OtO1i = findclosest(0:359,mod(f(1).data(3)+90,360)); OtO2i = findclosest(0:359,mod(f(1).data(3)-90,360));

    %keyboard;
    Rpraw = max(rs.data.curve(2,:));
    R2praw = sort(rs.data.curve(2,:),'descend');R2praw = R2praw(2); 
    Rmraw = sum(rs.data.curve(2,:))/length(rs.data.curve(1,:));
    dpraw = rs.data.curve(1,(find(rs.data.curve(2,:)==Rpraw)));
    Rprawbl = Rpraw-blankresp;
    Rmrawbl = Rmraw-blankresp;
    Rp2praw = (Rpraw+R2praw)/2;
    Rp2prawbl = Rp2praw-blankresp;
    di= di.data;
    dp = dp.data;
    x = mean(loc.data.x);
    y = mean(loc.data.y);
    locinds = locinds.data;
    loc = [x y];
%    BSdp = BSf.data(:,3);
    %BSdi = calc_bootstrap_di(BSf.data,BSrs.data.blankind);
    Rp = fi.data(2,OtPi);
    Rpbl = fi.data(2,OtPi)-min(fi.data(2,OtNi),blankresp);
    Rn = fi.data(2,OtNi);
    Rnbl = fi.data(2,OtNi)-min(fi.data(2,OtNi),blankresp);
    Rm = sum (fi.data(2,:))/length(fi.data(1,:)); 
    Rmbl = Rm-min(fi.data(2,OtNi),blankresp); % same as area under curve
    Rp2p = (Rp+Rn)/2;
    Rp2pbl = Rp2p-min(fi.data(2,OtNi),blankresp);
    
    Ro = max(0,mean([fi.data(2,OtO1i) fi.data(2,OtO2i)])-blankresp);
    
    ODdata(i,:) = [Rpraw Rp2praw Rmraw Rprawbl Rp2prawbl Rmrawbl Rp Rm Rp2p Rpbl Rmbl Rp2pbl];
    %OD(1) OD(5) OD(6)


%     if isempty(traindir), Rt = [];return;end;
%     base = 180; mydiff = mod(angdiff(dp-traindir),base);
%     if mydiff<45, Rt1 = Rp; else Rt1 = Rn; end;
% 
%     %another way to calculate Rt
%     Otti = findclosest (0:359,traindir);
%     Rt2 = fi.data(2,Otti)-min(fi.data(2,OtNi),blankresp);
end;
for i = 1: length(ODdata(1,:))
    OD(end+1) = ODdata(1,i)/sum(ODdata(:,i));
end;
%keyboard;
