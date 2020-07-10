f = '~/tools/matlab/vhlab-intracellrfs-matlab/intracellular data index - young.tsv';

if 0,
	f = '~/tools/matlab/vhlab-intracellrfs-matlab/intracellular data index - old.tsv';
end

prefix = ['/Volumes/van-hooser-lab/Users/steve/araniintracellular'];

z = loadStructArray(f);
	
if 0, intracell_strf_markgarbage_all(z,prefix); end;

expnames = {};

for i=1:numel(z),
	expnames{i} = datestr( datenum(z(i).Date), 'yyyy-mm-dd');
end

expnames = unique(expnames);

opt.setsharpthresholds = 1;
opt.compute_binned_spike_rate_vm = 0;
opt.plot_vm_firingrate = 0;
opt.do_vm_fit = 0;
opt.examine_vm_fit = 0;
opt.examine_residuals = 0;
opt.plot_residuals = 0;
opt.displayresults = 1;
opt.decode_stimuli = 0;
opt.analyze_stimuli = 0;
opt.extract_spikewaves = 0;
opt.analyze_spikewaves = 0;
opt.generate_sim_fit = 0;
opt.analyze_fits = 0;

  % options for voltage / firing rate; needs to be run first
opt_vmfr = opt;
opt_vmfr.compute_binned_spike_rate_vm = 1;
opt_vmfr.plot_vm_firingrate = 1;
opt_vmfr.do_vm_fit = 1;
  % options for stimulus decoding/stimulus analysis
opt_stim = opt;
opt_stim.decode_stimuli = 1;
opt_stim.analyze_stimuli = 1;
 % options for generating model responses and fits
opt_m = opt;
opt_m.generate_sim_fit = 1;
opt_m.analyze_fits = 1;
 % options for residual quantification and examination
opt_res = opt;
opt_res.examine_residuals = 1;
opt_res.plot_residuals = 1;
 % options for spikewave analysis
opt_spike = opt;
opt_spike.extract_spikewaves = 1;
opt_spike.analyze_spikewaves = 1;

for i=1:numel(expnames),
	intracell_strf_pipeline([prefix filesep expnames{i}], opt);
	intracell_strf_pipeline([prefix filesep expnames{i}], opt_vmfr);
	intracell_strf_pipeline([prefix filesep expnames{i}], opt_spike);
	intracell_strf_pipeline([prefix filesep expnames{i}], opt_stim);
	intracell_strf_pipeline([prefix filesep expnames{i}], opt_m);
	intracell_strf_pipeline([prefix filesep expnames{i}], opt_res);
end


