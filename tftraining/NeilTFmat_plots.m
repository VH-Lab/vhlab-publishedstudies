function NeilTFmat_plots(TFmat)


AnchorDirColor = [0 1 0];
NonAnchorDirColor = [ 1 0 0];

BSTrialColor = [0.5 0.5 0.5];
default_xaxis = [0 50];
blank_xaxis = [0.1 50];
DirAnchorTFs = [1 2 4];


 % responses, averaged over animals

TF_conditions = [0 1 4]; 
times = 1:4;

figure;
for i=1:length(TF_conditions),
	for j=1:length(times),
		indexes = find(TFmat.groups(:,1)==TF_conditions(i) & TFmat.groups(:,2)==times(j));
		animals = unique(TFmat.groups(indexes,3));
		mat = [];
		for k=1:length(animals),
			sub_indexes = find(TFmat.groups(indexes,3)==animals(k));
			mat = [mat; mean(TFmat.tf_resps(indexes(sub_indexes),:))];
		end;
		mns = mean(mat);
		stde = stderr(mat);
		subplot(length(TF_conditions),length(times),(i-1)*length(times)+j);
		plot([blank_xaxis],0*[blank_xaxis],'k--','linewidth',2);
		hold on;
		anchor = find(TFmat.tf_axis>0);
		nonanchor = find(TFmat.tf_axis<0);
		h=errorbar(-TFmat.tf_axis(nonanchor),mns(nonanchor),stde(nonanchor));
		set(h,'color',NonAnchorDirColor,'linewidth',2);
		h=errorbar(TFmat.tf_axis(anchor),mns(anchor),stde(anchor));
		set(h,'color',AnchorDirColor,'linewidth',2);
		axis([default_xaxis  -0.3 1]);
		set(gca,'xscale','log');
		if j==1,
			ylabel({['Training = ' int2str(TF_conditions(i))], 'norm spikes/sec'});
		end;
		if i==length(TF_conditions),
			xlabel('TF');
		end;
		box off;
		if TF_conditions(i)>0,
			addtrainingangleshade(TF_conditions(i),'width',TF_conditions(i)*0.5,'color',[0.8 0.8 0.8]);
		end;
	end;
end;
		

figure;
for i=1:length(TF_conditions),
	for j=1:length(times),
		indexes = find(TFmat.groups(:,1)==TF_conditions(i) & TFmat.groups(:,2)==times(j));
		animals = unique(TFmat.groups(indexes,3));
		mat = [];
		for k=1:length(animals),
			sub_indexes = find(TFmat.groups(indexes,3)==animals(k));
			mat = [mat; mean(TFmat.dir_dos(indexes(sub_indexes),:))];
		end;
		mns = mean(mat);
		stde = stderr(mat);
		subplot(length(TF_conditions),length(times),(i-1)*length(times)+1);
		plot([blank_xaxis],0*[blank_xaxis],'k--','linewidth',2);
		hold on;
		h=errorbar(TFmat.dir_dos_tfs,mns,stde);
		set(h,'color',(1-j/4)*[1 0 1]+j/4*[0 1 0]);
		axis([default_xaxis  -0.3 1]);
		set(gca,'xscale','log');
		if j==1,
			ylabel({['Training = ' int2str(TF_conditions(i))], 'DS DOS'});
		end;
		if i==length(TF_conditions),
			xlabel('TF');
		end;
		box off;
		if TF_conditions(i)>0,
			addtrainingangleshade(TF_conditions(i),'width',TF_conditions(i)*0.5,'color',[0.8 0.8 0.8]);
		end;
	end;
end;


for i=1:length(TF_conditions),
	for j=1:length(times),
		indexes = find(TFmat.groups(:,1)==TF_conditions(i) & TFmat.groups(:,2)==times(j));
		animals = unique(TFmat.groups(indexes,3));
		mat = [];
		for k=1:length(animals),
			sub_indexes = find(TFmat.groups(indexes,3)==animals(k));
			mat = [mat; mean(TFmat.dir_pop(indexes(sub_indexes),:))];
		end;
		mns = mean(mat);
		stde = stderr(mat);
		subplot(length(TF_conditions),length(times),(i-1)*length(times)+2);
		plot([blank_xaxis],0*[blank_xaxis],'k--','linewidth',2);
		hold on;
		h=errorbar(TFmat.dir_pop_tfs,mns,stde);
		set(h,'color',(1-j/4)*[1 0 1]+j/4*[0 1 0]);
		axis([default_xaxis  -0.3 1]);
		set(gca,'xscale','log');
		if j==1,
			ylabel({['Training = ' int2str(TF_conditions(i))], 'DS POP'});
		end;
		if i==length(TF_conditions),
			xlabel('TF');
		end;
		box off;
		if TF_conditions(i)>0,
			addtrainingangleshade(TF_conditions(i),'width',TF_conditions(i)*0.5,'color',[0.8 0.8 0.8]);
		end;
	end;
end;


