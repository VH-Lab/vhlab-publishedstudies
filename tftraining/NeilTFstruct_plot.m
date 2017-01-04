function out = NeilTFstruct_plot(entry,Mode,varargin)
% NEILTFSTRUCT_PLOT - Plot TF tuning from TFstruct data
%
%   OUT = NEILTFSTRUCT_PLOT(ENTRY, MODE, ...)
%
%   Plot the TF tuning data from TFstruct
%
%   The parameter MODE describes the plot to be created:
%
%   MODE value:                    |  Description
%   ----------------------------------------------------------------
%   'Norm_average'                 |  Plots the normed response of all entries averaged
%   'Single_Mean'                  |  Plots the mean responses (blank subtracted) of a single entry
% 
%   This function takes extra arguments and name/value pairs
%   Argument (default):            | Description
%   ----------------------------------------------------------------
%   AnchorDirColor ([0 1 0])       |  Color of the anchor direction
%   OppositeDirColor ([1 0 0])     |  Color of the direction opposite to anchor direction
%   BSTrialColor ([0.5 0.5 0.5])   |  Color of Bootstrap trials
%   default_xaxis ([0 50])         |  X axis to use (in temporal frequency)
%   blank_xaxis ([0.1 50])         |  X coordinates to use to plot 'blank' response
%   UseErrorBars ([1])             |  Should we show error bars (if applicable?)
%   f ([])                         |  Figure to plot in
%   axes_handles ([])              |  Axes handles to plot in


AnchorDirColor = [0 1 0];
OppositeDirColor = [1 0 0];
BSTrialColor = [0.5 0.5 0.5];
default_xaxis = [0 50];
blank_xaxis = [0.1 50];
UseErrorBars = 1;
DirAnchorTFs = [1 2 4];

f = [];
axes_handles = [];

assign(varargin{:});

out.input_parameters = workspace2struct;

if isempty(f),
	f = figure;
end;

switch Mode,
	case 'Norm_average',

	if isempty(entry), return; end;
	for i=1:length(entry),

	end;

	case 'Single_Mean',
		for j=1:length(entry.TF_responses_mean),
			if length(axes_handles)<j,
				axes_handles(end+1)=subplot(1,4,j);
			else,
				axes(axes_handles(j));
			end;
			anchor_inds = find(entry.TF_responses_mean{j}(1,:)>0);
			opposite_inds = find(entry.TF_responses_mean{j}(1,:)<0);
			if UseErrorBars,
				out.anchor_plot_handle_pref(j) = errorbar(entry.TF_responses_mean{j}(1,anchor_inds),...
					entry.TF_responses_mean{j}(2,anchor_inds), entry.TF_responses_mean{j}(4,anchor_inds));
				set(out.anchor_plot_handle_pref(j),'color',AnchorDirColor);
			else,
				out.anchor_plot_handle_pref(j) = plot(entry.TF_responses_mean{j}(1,anchor_inds),...
					entry.TF_responses_mean{j}(2,anchor_inds),'color',AnchorDirColor);
			end;
			hold on;
			if UseErrorBars,
				out.anchor_plot_handle_opp(j) = errorbar(-entry.TF_responses_mean{j}(1,opposite_inds),...
					entry.TF_responses_mean{j}(2,opposite_inds), entry.TF_responses_mean{j}(4,opposite_inds));
				set(out.anchor_plot_handle_opp(j),'color',OppositeDirColor);
			else,
				out.anchor_plot_handle_opp(j) = plot(-entry.TF_responses_mean{j}(1,opposite_inds),...
					entry.TF_responses_mean{j}(2,opposite_inds), 'color',OppositeDirColor);
			end;
			out.blank_plot_handle(j,1) = plot(blank_xaxis,0*blank_xaxis,'k--');
			set(gca,'xlim',default_xaxis);
			set(gca,'xscale','log');
			ylabel('spikes/sec');
			xlabel('TF');
			sig_str = '*';
			if entry.TF_vis_significance{j}>0.05, sig_str = ['']; end;
			title([sig_str entry.TF_cellname],'interp','none');
			box off;
		end;
		ymin = Inf; ymax = -Inf;
		for j=1:length(entry.TF_responses_mean),
			axes(axes_handles(j));
			A = axis;
			ymin = min(ymin,A(3));
			ymax = max(ymax,A(4));
		end;
		for j=1:length(entry.TF_responses_mean),
			set(axes_handles(j),'ylim',[ymin ymax]);
		end;

	case 'Single_Norm',
		for j=1:length(entry.TF_responses_norm),
			if length(axes_handles)<j,
				axes_handles(end+1)=subplot(1,4,j);
			else,
				axes(axes_handles(j));
			end;
			anchor_inds = find(entry.TF_responses_norm{j}(1,:)>0);
			opposite_inds = find(entry.TF_responses_norm{j}(1,:)<0);
			if UseErrorBars,
				out.anchor_plot_handle_pref(j) = errorbar(entry.TF_responses_norm{j}(1,anchor_inds),...
					entry.TF_responses_norm{j}(2,anchor_inds), entry.TF_responses_norm{j}(4,anchor_inds));
				set(out.anchor_plot_handle_pref(j),'color',AnchorDirColor);
			else,
				out.anchor_plot_handle_pref(j) = plot(entry.TF_responses_norm{j}(1,anchor_inds),...
					entry.TF_responses_norm{j}(2,anchor_inds), 'color',AnchorDirColor);
			end;
			hold on;
			if UseErrorBars,
				out.anchor_plot_handle_opp(j) = errorbar(-entry.TF_responses_norm{j}(1,opposite_inds),...
					entry.TF_responses_norm{j}(2,opposite_inds),entry.TF_responses_norm{j}(4,opposite_inds));
				set(out.anchor_plot_handle_opp(j),'color',OppositeDirColor);
			else,
				out.anchor_plot_handle_opp(j) = plot(-entry.TF_responses_norm{j}(1,opposite_inds),...
					entry.TF_responses_norm{j}(2,opposite_inds), 'color',OppositeDirColor);
			end;
			out.blank_plot_handle(j,1) = plot(blank_xaxis,0*blank_xaxis,'k--');
			sig_str = '*';
			if entry.TF_vis_significance{j}>0.05, sig_str = ['']; end;
			set(gca,'xlim',default_xaxis);
			set(gca,'xscale','log');
			ylabel('Normalized spikes/sec');
			xlabel('TF');
			title([sig_str entry.TF_cellname],'interp','none');
			box off;
		end;
		ymin = 0; ymax = 1;
		for j=1:length(entry.TF_responses_mean),
			axes(axes_handles(j));
			A = axis;
			ymin = min(ymin,A(3));
			ymax = max(ymax,A(4));
		end;
		for j=1:length(entry.TF_responses_mean),
			set(axes_handles(j),'ylim',[ymin ymax]);
		end;

	case 'Single_DS_dos',
		for j=1:length(entry.TF_responses_norm),
			if length(axes_handles)<j,
				axes_handles(end+1)=subplot(1,4,j);
			else,
				axes(axes_handles(j));
			end;
			out.anchor_plot_handle_ds(j) = plot(entry.TF_DS_dos{j}(1,:), ...
					entry.TF_DS_dos{j}(2,:),'k','linewidth',2);
			hold on;
			out.blank_plot_handle(j,1) = plot(blank_xaxis,0*blank_xaxis,'k--');
			sig_str = '*';
			if entry.TF_vis_significance{j}>0.05, sig_str = ['']; end;
			set(gca,'xlim',default_xaxis,'ylim',[-1 1]);
			set(gca,'xscale','log');
			ylabel('DS_dos','interp','none');
			xlabel('TF');
			title([sig_str entry.TF_cellname],'interp','none');
			box off;
		end;

	case 'Single_Workup',
		% plot all non-BS values in single figure
		figure(f);

		plot_types = {'Single_Mean','Single_Norm','Single_DS_dos','Single_BS_DS_dos'};
		for i=1:length(plot_types),
			for j=1:4, ax{i}(j) = subplot(length(plot_types),4,(i-1)*4+j); end;
			NeilTFstruct_plot(entry,plot_types{i},varargin{:},'f',f,'axes_handles',ax{i});
		end;

	case 'Single_BSMeanNormWorkup',
		% plot all non-BS values in single figure
		figure(f);

		plot_types = {'Single_BS_pref_Mean','Single_BS_pref_Norm','Single_BS_opp_Mean','Single_BS_opp_Norm'};
		for i=1:length(plot_types),
			for j=1:4, ax{i}(j) = subplot(length(plot_types),4,(i-1)*4+j); end;
			NeilTFstruct_plot(entry,plot_types{i},varargin{:},'f',f,'axes_handles',ax{i});
		end;

	case {'Single_BS_pref_Mean','Single_BS_pref_Norm','Single_BS_opp_Mean','Single_BS_opp_Norm'},
		for j=1:length(entry.TF_responses_mean),
			if length(axes_handles)<j,
				axes_handles(end+1)=subplot(1,4,j);
			else,
				axes(axes_handles(j));
			end;

			% plot all the bootstrap trials 
			for z=1:size(entry.TF_responses_BS_raw{j},1),
				TFs = entry.TF_responses_mean{j}(1,:);
				TF_sign = neiltf_dirsign(TFs,entry.TF_responses_BS_norm{j}(z,:),DirAnchorTFs);
				if strcmp(Mode,'Single_BS_pref_Mean') | strcmp(Mode,'Single_BS_pref_Norm'),
					anchor_or_opp_inds = find(TF_sign*TFs>0);
					thesign = 1;
				else,
					anchor_or_opp_inds = find(TF_sign*TFs<0);
					thesign = -1;
				end;
				switch Mode,
					case {'Single_BS_pref_Mean','Single_BS_opp_Mean'},
						dataout = entry.TF_responses_BS_raw{j}(z,anchor_or_opp_inds)-entry.TF_responses_BS_blank{j}(z);
					case {'Single_BS_pref_Norm','Single_BS_opp_Norm'},
						dataout = entry.TF_responses_BS_norm{j}(z,anchor_or_opp_inds);
				end;
				out.anchor_plot_handle(j,1+z) = plot(thesign*TF_sign*TFs(anchor_or_opp_inds), dataout, ...
					'color',BSTrialColor);
				hold on;
			end;
			if strcmp(Mode,'Single_BS_pref_Mean') | strcmp(Mode,'Single_BS_pref_Norm'),
				anchor_or_opp_inds = find(entry.TF_responses_mean{j}(1,:)>0);
				thesign = 1;
				Color = AnchorDirColor;
			else,
				anchor_or_opp_inds = find(entry.TF_responses_mean{j}(1,:)<0);
				thesign = -1;
				Color = OppositeDirColor;
			end;
			switch Mode,
				case {'Single_BS_pref_Mean','Single_BS_opp_Mean'},
					dataout = entry.TF_responses_mean{j}(2,anchor_or_opp_inds);
					dataout_ste = entry.TF_responses_mean{j}(4,anchor_or_opp_inds);
				case {'Single_BS_pref_Norm','Single_BS_opp_Norm'},
					dataout = entry.TF_responses_norm{j}(2,anchor_or_opp_inds);
					dataout_ste = entry.TF_responses_norm{j}(4,anchor_or_opp_inds);
			end;
			if UseErrorBars,
				out.anchor_plot_handle(j,1) = errorbar(thesign*entry.TF_responses_mean{j}(1,anchor_or_opp_inds),...
					dataout, dataout_ste);
				set(out.anchor_plot_handle(j,1),'color',Color,'linewidth',2);
			else,
				out.anchor_plot_handle(j,1) = plot(thesign*entry.TF_responses_mean{j}(1,anchor_or_opp_inds),...
					dataout, 'color',Color,'linewidth',2);
			end;
			hold on;
			out.blank_plot_handle(j,1) = plot(blank_xaxis,0*blank_xaxis,'k--');
			set(gca,'xlim',default_xaxis);
			set(gca,'xscale','log');
			ylabel('spikes/sec');
			xlabel('TF');
			title(entry.TF_cellname,'interp','none');
			box off;
		end;
		ymin = Inf; ymax = -Inf;
		for j=1:length(entry.TF_responses_mean),
			axes(axes_handles(j));
			A = axis;
			ymin = min(ymin,A(3));
			ymax = max(ymax,A(4));
		end;
		for j=1:length(entry.TF_responses_mean),
			set(axes_handles(j),'ylim',[ymin ymax]);
		end;

	case 'Single_BS_DS_dos',
		for j=1:length(entry.TF_responses_mean),
			if length(axes_handles)<j,
				axes_handles(end+1)=subplot(1,4,j);
			else,
				axes(axes_handles(j));
			end;
			out.plot_prctile80 = plot(entry.TF_DS_TFlist{j}, prctile(entry.TF_DS_dos_BS_raw{j},80),'-','color',[0.3 0.3 0.3]);
			hold on;
			out.plot_prctile50 = plot(entry.TF_DS_TFlist{j}, prctile(entry.TF_DS_dos_BS_raw{j},50),'-','color',[0 0 0],'linewidth',2);
			out.plot_prctile20 = plot(entry.TF_DS_TFlist{j}, prctile(entry.TF_DS_dos_BS_raw{j},20),'-','color',[0.5 0.5 0.5]);
			hold on;
			plot(blank_xaxis,0*blank_xaxis,'k--');
			set(gca,'xlim',default_xaxis,'ylim',[-1 1]);
			set(gca,'xscale','log');
			ylabel('DS dos');
			xlabel('TF','interp','none');
			sig_str = '*';
			if entry.TF_vis_significance{j}>0.05, sig_str = ['']; end;
			title([sig_str entry.TF_cellname],'interp','none');
			box off;
		end;
end;

out.axes_handles = axes_handles;
out.f = f;


