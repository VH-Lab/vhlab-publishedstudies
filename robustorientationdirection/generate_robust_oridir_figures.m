function generate_robust_oridir_figures
% GENERATE_ROBUST_ORIDIR_FIGURES
%
%  Generates all the data figures from Mazurek, Kager, Van Hooser et al. 2012
%



 %%%%% figure 2: OSI and tuning curves AND
 %%%%% figure 3: vector representations in orientation and direction space

robustoridir_plotexamplecells



 %%%%% figure 4  OSI vs. Circular variance in orientation space

sTestCircularVarianceOS('num_repeats_per_stim',10000);




 %%%%% figure 5  DSI vs. DirCircular Variance in direction space

sTestCircularVarianceDS('num_repeats_per_stim',10000);


 %%%%% figure 6 Circular variance robustness to various types of noise / measurements

TestCircularVarianceStddev
 
 %%%%% Table 1: Power analysis

r = toupper(input('Do you want to perform power analysis? It takes weeks because we have not optimized it for time. Y/N'));

if strcmp(r,'N'),

	measure11 = repmat({'OSI'},3,3);
	measure12 = repmat({'1-CirVar'},3,3);
	measure21 = repmat({'DSI'},3,3);
	measure22 = repmat({'1-DirCirVar'},3,3);
	base1 = repmat(0.5,3,3);
	change1 = repmat([0.1 0.2 0.3]',1,3);
	confidence1 = repmat([0.95 0.99 0.999],3,1);
	base21 = repmat(0.15,3,3);
	base22 = repmat(0.3,3,3);

	pop_inc = 1;

	table11_____ = robustoridir_poweranalysis2(measure11,base1,change1,confidence1,'population_increment',pop_inc,'population_size',table11__-5);
	table12_____ = robustoridir_poweranalysis2(measure12,base1,change1,confidence1,'population_increment',pop_inc,'population_size',table12__-5);

	table21_____ = robustoridir_poweranalysis(measure21,base1,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',1,'population_size',pop_size);
	table22__ = robustoridir_poweranalysis(measure22,base1,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',1,'population_size',table22__-5);

	table211____s = robustoridir_poweranalysis(measure21,base21,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',50);
	table221_____ = robustoridir_poweranalysis(measure22,base21,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',1,'population_size',table221__-5);

	table212___s = robustoridir_poweranalysis(measure21,base22,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',50);
	table222_____ = robustoridir_poweranalysis(measure22,base22,change1,confidence1,'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',1,'population_size',table222__-5);
end;


table211____s13 = robustoridir_poweranalysis(measure21(1,3),base21(1,3),change1(1,3),confidence1(1,3),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',500,'population_size',1000);

table211____s2_3_ = robustoridir_poweranalysis(measure21(2:3,:),base21(2:3,:),change1(2:3,:),confidence1(2:3,:),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',25,'population_size',10);

table211____s1_2_a = robustoridir_poweranalysis(measure21(1,2),base21(1,2),change1(1,2),confidence1(1,2),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',200,'population_size',2000);

table211____s1_2_b = robustoridir_poweranalysis(measure21(1,2),base21(1,2),change1(1,2),confidence1(1,2),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',200,'population_size',2200);

table211____s1_2_c = robustoridir_poweranalysis(measure21(1,2),base21(1,2),change1(1,2),confidence1(1,2),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',200,'population_size',2400);

table211____s1_2_d = robustoridir_poweranalysis(measure21(1,2),base21(1,2),change1(1,2),confidence1(1,2),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',200,'population_size',2600);

table211____s1_2_e = robustoridir_poweranalysis(measure21(1,2),base21(1,2),change1(1,2),confidence1(1,2),'population_increment',pop_inc,'noise_level',[2 1],'noise_method',2,'population_increment',200,'population_size',2800);

