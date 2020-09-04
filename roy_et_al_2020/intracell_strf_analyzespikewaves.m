function intracell_strf_analyzespikewaves(app, sharpprobe, varargin)
% INTRACELL_STRF_ANALYZESPIKEWAVES - compute binned spike rate, vm
%
% INTRACELL_STRF_ANALYZESPIKEWAVES(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
% debug_plot (0)             | Display debugging information

displayresults = 1;
debug_plot = 0;

assign(varargin{:});

E = app.session;
sapp = ndi_app_spikeextractor(E);
element_vmcorrected = E.getelements('element.type','Vm_corrected','element.name',sharpprobe.elementstring());
element_vmcorrected = celloritem(element_vmcorrected,1);

et = epochtable(element_vmcorrected);
N = numel(et);

for n=1:N,
 
	extract_p_name = ['manually_selected ' sharpprobe.id() '.' et(n).epoch_id];
	[w,wp,spikewaves_doc] = sapp.loaddata_appdoc('spikewaves',element_vmcorrected,et(n).epoch_id,extract_p_name); %load waveforms
	st = sapp.loaddata_appdoc('spiketimes',element_vmcorrected,et(n).epoch_id,extract_p_name); %load spike times
    
	z = squeeze(w); %this is a squeezed matrix of columns, one column per spike wave
    
	t = (wp.S0:wp.S1)/wp.samplerate;
	spike_peak_index = findclosest(t,0);
    
	indexes = 1+find(diff(st)>0.100); % look at spikes that have a preceeding inter-spike-interval of at least 100ms
	gz = z(:,indexes); %new array of z values as columns only specificed by indexes (which is what we plot later) 
	spike_trim_times = NaN(size(gz,2),3);

	%search database for exisiting .json files
	ndi_element_obj = element_vmcorrected;
	element_doc = ndi_element_obj.load_element_doc();

	if ~isempty(element_doc), % search for an existing document; if it exists, remove it so we can replace it with our new one
		q_spikestats = ndi_query('','isa','vmspikesummary.json','');
		q_element = ndi_query('','depends_on','element_id',element_doc.id());
		q_spikewave = ndi_query('','depends_on','spike_extraction_id',spikewaves_doc.id());
		q_epoch = ndi_query('epochid','exact_string',et(n).epoch_id,'');
		sq = (q_spikestats & q_element & q_epoch);
		docs = E.database_search(sq);
		E.database_rm(docs);
        end;
       
	sk_index = [];
	slope_criterion = [];
	n_skwaves = [];
	spike_summary_doc = [];
    
	for c = 1:size(gz,2) %runs spikekink down every column in gz
		[spikewave_Vtrim, spikewave_NZ_start, spikepeak_trim_loc, spikewave_NZ_end] = spikewavetrimmer(gz(:,c), spike_peak_index);
        
		spike_trim_times(c,:) = [spikewave_NZ_start,spikepeak_trim_loc, spikewave_NZ_end];
		t_trim = (spike_trim_times(c,1:3));
		t_index = t_trim(1):t_trim(3);

		n_skwaves = 1:size(gz,2);
        
		[kink_vm, max_dvdt, kink_index, slope_criterion] = spikekink(spikewave_Vtrim, ...
			t(t_index), t_trim(2),'search_interval', t(t_trim(1)), 'slope_criterion', 0.033);
            
		if isempty(kink_vm), %stops the code to debug if no kink_vm value is returned
			disp(['No kink_vm returned; debug']);
			keyboard;
		end
        
		[FWHM, hm_presk_loc, hm_postsk_loc, V_hm,presk_WHM, postsk_WHM] = spikeFWHM(spikewave_Vtrim,max(spikewave_Vtrim), ...
				spikepeak_trim_loc, kink_vm, kink_index, wp.samplerate, t(t_index));
        
		if isempty(V_hm), %stops the code to debug if no V_hm value is returned
			disp(['No V_hm value was returned. Need to debug and figure out why.']); 
			keyboard;
		end
        
		sk_index(c,:) = [kink_vm, max_dvdt, kink_index, FWHM, V_hm, presk_WHM, postsk_WHM, max_dvdt];

		if debug_plot,
			if rand<0.0001, %plots 1% of the annotated spike waves as a sanity check
				figure;
				plot(t(t_index),spikewave_Vtrim,'b-', 'LineWidth', 3); %make plot of time vs wavepoints of current iteration
				hold on;
				plot(t(t_index(sk_index(c,3))),sk_index(c,1),'bx'); %plot the spike kink of the current iteration
				if isnan(hm_postsk_loc)
				continue
				plot([t(t_index(hm_presk_loc)) t(t_index(hm_postsk_loc))], [sk_index(c,5), sk_index(c,5)], 'r-');
				end
				plot([t(t_index(hm_presk_loc)) t(t_index(hm_postsk_loc))], [sk_index(c,5), sk_index(c,5)], 'r-', 'LineWidth',2);
				xlabel('Time (s)');
				ylabel('Voltage (V)');
				hold off;
			end; % rand plotting
		end; % debug_plot
	end; % 'for' loop over spikes
    
	if isempty(w) | isempty(n_skwaves),
		displayresults = 0;
	end
    
	if displayresults == 1,

		avg_sw = mean(gz,2); %average each epoch
		std_sw = std(gz,0,2);

		figure;
		subplot(3,4,[1,2,3,4]);
		plot(t,gz); 
		hold on;
		plot(t,avg_sw,'color',[0 0 0],'linewidth',2);
		title([sharpprobe.elementstring() ' | ' et(n).epoch_id]);
		xlabel('Time (s)')
		ylabel('Voltage (V)')
		box off;
		
		subplot(3,4,[5,6,7]);
		if 0, % plot average waves and standard dev
			errorbar(t,avg_sw,std_sw,'-s','MarkerSize',4,'MarkerEdgeColor','red','MarkerFaceColor','red')
			%axis([t(1) t(end) 0 max(avg_sw)+0.05]);
			title('Averaged Spikewaves');
			xlabel('Time (s)')
			ylabel('Voltage (V)')
		else,   % plot spike phase diagram
			dt = t(2)-t(1);
			[dummy,gz_grad] = gradient(gz,dt);
			plot(gz(15:end-15,:),gz_grad(15:end-15,:));
			title('Phase diagram');
			xlabel('Voltage (V)')
			ylabel('V dot')
		end;
		box off;
		
		subplot(3,4,8);
		plot(n_skwaves,sk_index(:,1));
		xlabel('Wave Number');
		ylabel('Kink Voltage');
		title('Kink Voltage Across Spikewaves');
		ylim([0 0.05])
		box off;
		
		subplot(3,4,9);
		plot(n_skwaves,sk_index(:,2));
		xlabel('Wave Number');
		ylabel('Max dV/dt');
		title('Max dV/dt Across Spikewaves');
		ylim([0 500])
		box off;
		
		subplot(3,4,10);
		plot(n_skwaves,sk_index(:,4));
		xlabel('Wave Number');
		ylabel('FWHM');
		title('FWHM Across Spikewaves');
		ylim([0 0.012]);
		box off;
		
		subplot(3,4,11);
		plot(n_skwaves,sk_index(:,6));
		xlabel('Wave Number');
		ylabel('Half-Width, Half-Maximum before Spike Peak');
		title('Pre-Spike HWHM Across Spikewaves');
		ylim([0 0.001]);
		box off;
		
		subplot(3,4,12);
		plot(n_skwaves,sk_index(:,7));
		xlabel('Wave Number');
		ylabel('Half-Width, Half-Maximum after Spike Peak');
		title('Post-Spike HWHM Across Spikewaves');
		ylim([0.008 0.01]);
		box off;
	end;
    
	%create structs to feed into spike_summary_.json file

	spike_stats.mean_spikewave = mean(gz,2);
	spike_stats.sample_times = t;
	spike_stats.number_of_spikes = size(gz,2);
	if numel(sk_index) <2,
		spike_stats.median_spikekink_vm = NaN;
		spike_stats.median_voltageofhalfmaximum = NaN;
		spike_stats.median_fullwidthhalfmaximum = NaN;
		spike_stats.median_presk_halfwidthmaximum = NaN;
		spike_stats.median_postsk_halfwidthmaximum = NaN;
		spike_stats.median_max_dvdt = NaN;
		spike_stats.median_kink_index = NaN;
	else,
		spike_stats.median_spikekink_vm = median(sk_index(:,1));
		spike_stats.median_voltageofhalfmaximum = median(sk_index(:,5));
		spike_stats.median_fullwidthhalfmaximum = median(sk_index(:,4));
		spike_stats.median_presk_halfwidthmaximum = median(sk_index(:,6));
		spike_stats.median_postsk_halfwidthmaximum = median(sk_index(:,7));
		spike_stats.median_max_dvdt = median(sk_index(:,8));
		spike_stats.median_kink_index = median(sk_index(:,3));
	end;
	spike_stats.slope_criterion = slope_criterion;

	%create a summary ndi_document for each epoch
	spike_summary_doc = ndi_document('apps/vhlab_voltage2firingrate/vmspikesummary.json',...
		'vmspikesummary', spike_stats,'epochid',et(n).epoch_id) + E.newdocument();
	spike_summary_doc = spike_summary_doc.set_dependency_value('element_id',element_vmcorrected.id());
	spike_summary_doc = spike_summary_doc.set_dependency_value('spike_extraction_id',spikewaves_doc.id());
	E.database_add(spike_summary_doc);

end; % loop over epochs


