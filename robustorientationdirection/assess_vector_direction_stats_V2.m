

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 3: Apply tool to data

load data4mark_1
load data4mark_2
cellnames = cat(2,cellnames_1,cellnames_2);
structlist = cat(2,structlist_1,structlist_2);

click = [];
ncells = length(structlist);

% For each cell, I'll extract the p value obtained from the bootstrap procedure for the probability that the cell's direction preference is
% opposite that obtained from the Carandini fit; save it as 'p_reverse_bs'
p_reverse_bs = nan*ones(ncells,1);

% Next I'll use the new vector tool to calculate three things:
% (1) The preferred direction for that cell as determined by the average vector obtained in individual trials. Save as 'prefdir_vect'.
% (2) A p value for direction selectivity, obtained from Hotelling's T^2 test performed . Save as 'p_selective_vect'.
% (3) A p value for the probability of direction reversal. Save as 'p_reverse_vect'.
prefdir_vect = nan*ones(ncells,1);
p_dirselective_vect = nan*ones(ncells,1);
p_reverse_vect = nan*ones(ncells,1);
p_oriselective_vect = nan*ones(ncells,1);
cellnum = nan*ones(ncells,1);

all_response_curves = {};

for i_cell = 1:ncells
  cell2analyze = i_cell;
  cellnum(i_cell) = i_cell;

  cell = structlist{cell2analyze};
  if(length(cell)==0)
    continue;
  end
  
  beforeResponse = find(strcmp({structlist{cell2analyze}.type},'TP Ach OT Response struct'));
  if (length(beforeResponse)==0)
    continue;
  end;
 
  q = cell(beforeResponse);
  angles = q.data.curve(1,:);  
  
  response_mtx = cell2mat(q.data.ind);
  spont = q.data.spont(1);
  nanind = any(isnan(response_mtx'))';
  response_mtx(nanind,:) = [];

  if(size(response_mtx,1)<3)
    continue;
  end
  
  [prefdir_vect(i_cell) p_dirselective_vect(i_cell) p_reverse_vect(i_cell) p_oriselective_vect(i_cell)] = calc_direction_stats_vectormethod(angles,response_mtx,spont);
  
  all_response_curves{i_cell} = q.data.curve;

  % calculate the 'direction uncertainty', or the chance the direction is opposite the best fit
  beforeBS = find(strcmp({structlist{cell2analyze}.type},'TP Ach OT Bootstrap Carandini Fit Params'));
  if ~isempty(beforeBS)
     beforeBSangles = structlist{cell2analyze}(beforeBS).data(:,3);
     p_reverse_bs(i_cell) = dpuncertainty(beforeBSangles);
  else
     p_reverse_bs(i_cell) = NaN;
  end;
  

  % calculate the chance that the cell reversed as a consequence of training
  afterBS = find(strcmp({structlist{cell2analyze}.type},'TP ME Ach OT Bootstrap Carandini Fit Params'));
  if ~isempty(beforeBS) & ~isempty(afterBS),
     afterBSangles = structlist{cell2analyze}(afterBS).data(:,3);
     p_trainingreverse_bs(i_cell) = flippingprob(beforeBSangles,afterBSangles);
  else
     p_trainingreverse_bs(i_cell) = NaN;
  end;
    
end

% Lgood = ~isnan(p_dirselective_vect);

figure;
plot(p_dirselective_vect,p_reverse_bs,'ko');
ylabel('DP uncertainty BS');
xlabel('P value of Hotelling''s T^2 test');
title('All cells');
box off;

alpha = 0.05;
ori_selective = find(p_oriselective_vect<alpha); % find subset of orientation-selective cells
cellnum_orisel = cellnum(ori_selective);
figure;
plot(p_dirselective_vect(ori_selective),p_reverse_bs(ori_selective),'bo');
ylabel('DP uncertainty BS');
xlabel('P value of Hotelling''s T^2 test');
title('Cells that pass Hotelling''s T^2 test in orientation space');
set(gca,'ButtonDownFcn','[click,clickpt]=findclosestpointclick([p_dirselective_vect(ori_selective) p_reverse_bs(ori_selective)]); plotcurve=all_response_curves{ori_selective(click)}; figure; EB=errorbar(plotcurve(1,:),plotcurve(2,:),plotcurve(4,:),plotcurve(4,:));box off;title([''Cell number '' int2str(cellnum_orisel(click)) ''; Hotelling '' num2str(clickpt(1)) '', BS '' num2str(clickpt(2))]);');
box off;

fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing orientation selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_oriselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_dirselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_vect<alpha)),1)
prev_orisel = p_reverse_vect(p_oriselective_vect<alpha);
fprintf(sprintf('\nVECTOR METHOD: Fraction of ORI-SELECTIVE cells showing direction selectivity by direction reversal test = %.2f\n',mean(prev_orisel<alpha)),1)

fprintf(sprintf('\nBOOTSTRAP: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_bs<alpha)),1)

return
cell2inspect = 775
cell = structlist{cell2inspect};
beforeResponse = find(strcmp({structlist{cell2inspect}.type},'TP Ach OT Response struct'));
q = cell(beforeResponse);
if(~isempty(q))
  angles = q.data.curve(1,:);
  response_mtx = cell2mat(q.data.ind);
  spont = q.data.spont(1);
  nanind = any(isnan(response_mtx'))';
  response_mtx(nanind,:) = [];
  
  all_response_curves = q.data.curve;
  plotcurve = all_response_curves;

  figure(100),hold on;
  plot(angles,response_mtx,'k.-')
  EB=errorbar(plotcurve(1,:),plotcurve(2,:),plotcurve(4,:),plotcurve(4,:));
  box off
  
  [q q q q vectors vectormags] = calc_direction_stats_vectormethod(angles,response_mtx,spont);
  figure(101),hold on
  plot(vectors(:,1),vectors(:,2),'o')
  plot(get(gca,'XLim'),[0 0],'k-')
  plot([0 0],get(gca,'YLim'),'k-')
  title('Trial vectors')
  set(gca,'ButtonDownFcn','[click,clickpt]=findclosestpointclick([vectors(:,1) vectors(:,2)]);figure(102),clf;plot(angles,response_mtx(click,:));title(''Responses from the selected trial'');')
end

