%input folder
% mytpf = '/users/yeli/documents/Data/minis/2010-01-28';
% myds = dirstruct(mytpf);
% [mycells,mycellnames]=load2celllist(getexperimentfile(myds),'cell*','-mat');
%output folder
tpf = '/users/yeli/documents/Data/minis/2010-02-23';
ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

plotit = 1;
% 'CONT'
% mychangename =  {'250','400','253','039','041','042'};
% 
% for i=1:length(mychangename),
%     myind = find(strcmp(['cell_tp_003_' mychangename{i} '_2010_01_28'],cellnames)==1);
%     %keyboard;
%         cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Contral eye OT test'},'p.angle','otanalysis_compute','TP CONT','plottpresponse(newcell,cellname,''TP CONT Ach OT Fit Pref'',1,1,''usesig'',1)',2);
%         [cellnames{myind} ', ' int2str(myind) ],
% end
%[cellnames{myind} ', ' int2str(myind) ],


%  %  'IPSI ME'
%  cells{69} = tpgenericanalysis2(ds,cells{69},cellnames{69},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',4);
%  cells{232} = tpgenericanalysis2(ds,cells{232},cellnames{232},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',4);
%  cells{292} = tpgenericanalysis2(ds,cells{292},cellnames{292},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',5);
%  
%  %  'CONT ME'
%  cells{103} = tpgenericanalysis2(ds,cells{103},cellnames{103},plotit,{'Contral eye OT recovery test'},'p.angle','otanalysis_compute','TP CONT ME','plottpresponse(newcell,cellname,''TP CONT ME Ach OT Fit Pref'',1,1,''usesig'',1)',4);
%  cells{232} = tpgenericanalysis2(ds,cells{232},cellnames{232},plotit,{'Contral eye OT recovery test'},'p.angle','otanalysis_compute','TP CONT ME','plottpresponse(newcell,cellname,''TP CONT ME Ach OT Fit Pref'',1,1,''usesig'',1)',4);
%  cells{292} = tpgenericanalysis2(ds,cells{292},cellnames{292},plotit,{'Contral eye OT recovery test'},'p.angle','otanalysis_compute','TP CONT ME','plottpresponse(newcell,cellname,''TP CONT ME Ach OT Fit Pref'',1,1,''usesig'',1)',5);

% mychangename =  {'369','378','371','036','013','033','318','382','395','388','066','047','308','063','284','288','278'};
% 
% for i=1:length(mychangename),
%     myind = find(strcmp(['cell_tp_001_' mychangename{i} '_2010_02_23'],cellnames)==1);
% 
%         cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Ipsi eye OT test'},'p.angle','otanalysis_compute','TP IPSI','plottpresponse(newcell,cellname,''TP IPSI Ach OT Fit Pref'',1,1,''usesig'',1)',0);
%         %cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',2);
%         %    [cellnames{myind} ', ' int2str(myind) ],
%         %keyboard;   
% end
% 
% mychangename =  {'378','036','331','314','047','390','056','052','049','320','299','300','301','308','052','094'};
% 
% for i=1:length(mychangename),
%     myind = find(strcmp(['cell_tp_001_' mychangename{i} '_2010_02_23'],cellnames)==1);
%     %keyboard;
%         cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',0);
%         %cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',2);
%         %    [cellnames{myind} ', ' int2str(myind) ],
% end

mychangename =  {'314','325','060','063','278'};%,'405','114','229','107','165','108','232','229','151','110','099','100','111','166'};

for i=1:length(mychangename),
    myind = find(strcmp(['cell_tp_001_' mychangename{i} '_2010_02_23'],cellnames)==1);
    %keyboard;
        cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Contral eye OT recovery test'},'p.angle','otanalysis_compute','TP CONT ME','plottpresponse(newcell,cellname,''TP CONT ME Ach OT Fit Pref'',1,1,''usesig'',1)',5);
        %cells{myind} = tpgenericanalysis2(ds,cells{myind},cellnames{myind},plotit,{'Ipsi eye OT recovery test'},'p.angle','otanalysis_compute','TP IPSI ME','plottpresponse(newcell,cellname,''TP IPSI ME Ach OT Fit Pref'',1,1,''usesig'',1)',2);
        %    [cellnames{myind} ', ' int2str(myind) ],
end

%keyboard;
saveexpvar(ds,cells,cellnames,0);    

%2010-02-23

%cell to change 
%contral after
%Closest cell is cell_tp_001_314_2010_02_23 w/ value 321.3499.
%Closest cell is cell_tp_001_325_2010_02_23 w/ value 343.6086.
%Closest cell is cell_tp_001_060_2010_02_23 w/ value 0.3614.
%Closest cell is cell_tp_001_063_2010_02_23 w/ value 13.5335.
%Closest cell is cell_tp_001_278_2010_02_23 w/ value 10.6769.

%Closest cell is cell_tp_001_107_2010_02_23 w/ value 258.4105.
%Closest cell is cell_tp_001_165_2010_02_23 w/ value 71.5085.
%Closest cell is cell_tp_001_108_2010_02_23 w/ value 250.4673.
%Closest cell is cell_tp_001_232_2010_02_23 w/ value 239.6757.
%Closest cell is cell_tp_001_229_2010_02_23 w/ value 243.2947.
%Closest cell is cell_tp_001_151_2010_02_23 w/ value 258.1997.
%Closest cell is cell_tp_001_110_2010_02_23 w/ value 252.5115.
%Closest cell is cell_tp_001_110_2010_02_23 w/ value 252.5115.
%Closest cell is cell_tp_001_099_2010_02_23 w/ value 256.447.
%Closest cell is cell_tp_001_100_2010_02_23 w/ value 268.3013.
%Closest cell is cell_tp_001_111_2010_02_23 w/ value 244.5733.
%Closest cell is cell_tp_001_165_2010_02_23 w/ value 255.2253.
%Closest cell is cell_tp_001_166_2010_02_23 w/ value 257.0674.
%Closest cell is cell_tp_001_235_2010_02_23 w/ value 46.5747.
%Closest cell is cell_tp_001_407_2010_02_23 w/ value 55.3728.
%Closest cell is cell_tp_001_235_2010_02_23 w/ value 46.5747.

%Closest cell is cell_tp_001_228_2010_02_23 w/ value 59.7474.
%Closest cell is cell_tp_001_235_2010_02_23 w/ value 47.1601.
%Closest cell is cell_tp_001_236_2010_02_23 w/ value 60.1975.
%Closest cell is cell_tp_001_116_2010_02_23 w/ value 56.3725.
%Closest cell is cell_tp_001_407_2010_02_23 w/ value 55.7295.
%Closest cell is cell_tp_001_405_2010_02_23 w/ value 61.2632.
%Closest cell is cell_tp_001_114_2010_02_23 w/ value 68.0537.
%Closest cell is cell_tp_001_229_2010_02_23 w/ value 244.2481.

%cell to kill:
%ipsi before
% Closest cell is cell_tp_001_369_2010_02_23 w/ value 145.4846.
% Closest cell is cell_tp_001_378_2010_02_23 w/ value 170.4655.
% Closest cell is cell_tp_001_371_2010_02_23 w/ value 349.4854.
% Closest cell is cell_tp_001_036_2010_02_23 w/ value 356.117.
% Closest cell is cell_tp_001_013_2010_02_23 w/ value 327.8555.
% Closest cell is cell_tp_001_033_2010_02_23 w/ value 159.3984.
% Closest cell is cell_tp_001_318_2010_02_23 w/ value 150.4347.
% Closest cell is cell_tp_001_382_2010_02_23 w/ value 152.2197.
% Closest cell is cell_tp_001_395_2010_02_23 w/ value 139.8459.
% Closest cell is cell_tp_001_388_2010_02_23 w/ value 139.8449.
% Closest cell is cell_tp_001_066_2010_02_23 w/ value 142.8127.
% Closest cell is cell_tp_001_047_2010_02_23 w/ value 56.2305.
% Closest cell is cell_tp_001_308_2010_02_23 w/ value 34.4026.
% Closest cell is cell_tp_001_063_2010_02_23 w/ value 26.3039.
% Closest cell is cell_tp_001_284_2010_02_23 w/ value 194.6522.
% Closest cell is cell_tp_001_288_2010_02_23 w/ value 191.9801.
% Closest cell is cell_tp_001_278_2010_02_23 w/ value 179.3527.

%ipsi after
% Closest cell is cell_tp_001_378_2010_02_23 w/ value 220.9739.
% Closest cell is cell_tp_001_036_2010_02_23 w/ value 14.1082.
% Closest cell is cell_tp_001_331_2010_02_23 w/ value 267.8088.
% Closest cell is cell_tp_001_314_2010_02_23 w/ value 3.8183.
% Closest cell is cell_tp_001_047_2010_02_23 w/ value 36.2693.
% Closest cell is cell_tp_001_390_2010_02_23 w/ value 120.1801.
% Closest cell is cell_tp_001_056_2010_02_23 w/ value 341.4845.
% Closest cell is cell_tp_001_052_2010_02_23 w/ value 11.7616.
% Closest cell is cell_tp_001_049_2010_02_23 w/ value 147.399.
% Closest cell is cell_tp_001_320_2010_02_23 w/ value 14.3671.
% Closest cell is cell_tp_001_299_2010_02_23 w/ value 228.9638.
% Closest cell is cell_tp_001_300_2010_02_23 w/ value 170.7054.
% Closest cell is cell_tp_001_301_2010_02_23 w/ value 31.3619.
% Closest cell is cell_tp_001_308_2010_02_23 w/ value 30.6521.
% Closest cell is cell_tp_001_052_2010_02_23 w/ value 11.7616.
% Closest cell is cell_tp_001_094_2010_02_23 w/ value 204.0039.



