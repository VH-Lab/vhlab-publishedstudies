
function sl_speed

prefix = '/Volumes/Data2/singlelayermodel/tf/';

fname_fast = 'ml4i.mat';
fname_slow = 'ml5i.mat';

g1 = load([prefix fname_fast],'-mat');
g2 = load([prefix fname_slow],'-mat');

dsi_g1 = (g1.out.r_up-g1.out.r_down)./(g1.out.r_up+g1.out.r_down);
dsi_g2 = (g2.out.r_up-g2.out.r_down)./(g2.out.r_up+g2.out.r_down);

 % DSI_train_test

r_up_fast_initial = g1.out.r_up(1);
r_down_fast_initial = g1.out.r_up(2);
r_up_slow_initial = g2.out.r_up(1);
r_down_slow_initial = g2.out.r_up(2);

DSI_fast_fast = dsi_g1(end);
DSI_slow_slow = dsi_g2(end);

disp(['Before training, fast rup is ' num2str(g1.out.r_up(1)) ' and rdown is ' num2str(g1.out.r_down(1)) '.']);
disp(['Before training, slow rup is ' num2str(g2.out.r_up(1)) ' and rdown is ' num2str(g2.out.r_down(1)) '.']);

N = 5; R = 9; isi = 2*0.2750; mask=sl_tfinit; lag=0.025; latency=0.025; dt = 1e-3;
synapseparams = {'tau2',0.020}; intfireparams = {}; intfireparams_inhib = {}; synapseparams_inhib = {'V_rev',-0.080};

slow = 1;
ISyn_Gmax_initial = g1.out.ctx_inhib(end);
Syn_Gmax_initial = g1.out.gmaxes(:,end)';
Syn_Gmax_initial_inhib = g1.out.inhib_gmaxes(:,end)';

[dummy,dummy,r_up_fast_slow,r_down_fast_slow] = directionselectivityNcelldemo_inhib('dt',dt,...
        'latency',latency,'lag',lag,'slow',slow,'mask',sl_tfinit,...
        'N',N,'R',R,...
        'isi',isi,...
        'Syn_Gmax_initial',Syn_Gmax_initial, 'Syn_Gmax_initial_inhib',Syn_Gmax_initial_inhib, 'plotit',1,...
        'synapseparams',synapseparams,'intfireparams',intfireparams,...
        'intfireparams_inhib',intfireparams_inhib,'synapseparams_inhib',synapseparams_inhib,...
        'ISyn_Gmax_initial',ISyn_Gmax_initial);

DSI_fast_slow = (r_up_fast_slow-r_down_fast_slow)./(r_up_fast_slow+r_down_fast_slow);


slow = 0;
ISyn_Gmax_initial = g2.out.ctx_inhib(end);
Syn_Gmax_initial = g2.out.gmaxes(:,end)';
Syn_Gmax_initial_inhib = g2.out.inhib_gmaxes(:,end)';

[dummy,dummy,r_up_slow_fast,r_down_slow_fast] = directionselectivityNcelldemo_inhib('dt',dt,...
        'latency',latency,'lag',lag,'slow',slow,'mask',sl_tfinit,...
        'N',N,'R',R,...
        'isi',isi,...
        'Syn_Gmax_initial',Syn_Gmax_initial, 'Syn_Gmax_initial_inhib',Syn_Gmax_initial_inhib, 'plotit',1,...
        'synapseparams',synapseparams,'intfireparams',intfireparams,...
        'intfireparams_inhib',intfireparams_inhib,'synapseparams_inhib',synapseparams_inhib,...
        'ISyn_Gmax_initial',ISyn_Gmax_initial);

DSI_slow_fast = (r_up_slow_fast-r_down_slow_fast)./(r_up_slow_fast+r_down_slow_fast);

disp(['After fast training, fast DSI is ' num2str(DSI_fast_fast) '.']);
disp(['After fast training, slow DSI is ' num2str(DSI_fast_slow) '.']);
disp(['After slow training, slow DSI is ' num2str(DSI_slow_slow) '.']);
disp(['After slow training, fast DSI is ' num2str(DSI_slow_fast) '.']);

disp(['After fast training, fast rup is ' num2str(g1.out.r_up(end)) ' and rdown is ' num2str(g1.out.r_down(end)) '.']);
disp(['After fast training, slow rup is ' num2str(r_up_fast_slow) ' and rdown is ' num2str(r_down_fast_slow) '.']);
disp(['After slow training, slow rup is ' num2str(g2.out.r_up(end)) ' and rdown is ' num2str(g2.out.r_down(end)) '.']);
disp(['After slow training, fast rup is ' num2str(r_up_slow_fast) ' and rdown is ' num2str(r_down_slow_fast) '.']);

