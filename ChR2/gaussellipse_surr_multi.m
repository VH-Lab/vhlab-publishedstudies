function output = gaussellipse_surr_fit_multi(filenames, filesizes, varargin)
% GAUSSELLIPSEFIT_MULTI - Perform gaussian fit to spot stimuli at multiple sizes
%
%  GAUSSELLIPSE_SURR_FIT_MULTI(FILENAMES, FILESIZES, ...)
%
%  Input: FILENAMES should be a cell list of file names of text files
%    that have, in columns, X position (in pixels), Y position (in pixels), and 
%    RESPONSE (in spikes).
%    FILESIZES should be an array with the radius of the spot used (in pixels).
%    
%  Output: a structure called output with fields:
%    MU - the mean of the gaussian fit
%    C  - the covariance matrix of the gaussian fit
%    a  - the scaling factor of the gaussian
%    mod_amp - the surround scale factor
%    mod_sigma - the sourround sigma scale factor
%    

if iscell(filenames), 
	x_ctr = [];
	y_ctr = [];
	response = [];
	radius = [];
	inds = [];

	for i=1:length(filenames),
		z = load(filenames{i});
		inds = [inds; i*ones(size(z.location_response(:,1)))];
		x_ctr = [x_ctr; z.location_response(:,1)];
		y_ctr = [y_ctr; z.location_response(:,2)];
		response = [response; z.location_response(:,3)];
		radius = [radius; ones(size(z.location_response(:,2))) * filesizes(i)];
	end;
	stders = [];
else,
	table = filenames;
	x_ctr = table(:,1);
	y_ctr = table(:,2);
	radius = table(:,3);
	response = table(:,4);
	stders = table(:,5);

	radii = unique(radius);
	inds = zeros(size(radius));
	for i=1:length(radii),
		inds(find(radius==radii(i))) = i;
	end;
end;

rotation = 0*radius;

[output.mu, output.C, output.a,output.mod_amp,output.mod_sigma,output.fit_responses] = gaussspotfit_mod(1:5:800, 1:5:600, x_ctr, y_ctr,radius,response);

figure;
[xmesh,ymesh]=meshgrid(1:800,1:600);
p = mvnpdf([xmesh(:) ymesh(:)],output.mu,output.C);
colormap(jet(256));
image(1.3*[1:800],1.3*[1:600],255 *reshape(p,600,800)/max(p(:)));

figure;
symbs = ['os^d<>'];
plot([0 1]*max(response),[0 1]*max(response),'k--');
hold on;
indlist = unique(inds);
for i=1:length(indlist),
        I = find(inds==i);
        %plot(response(I),output.fit_responses(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
	if isempty(stders),
	        plot(output.fit_responses(I),output.response(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
	else,
		h = errorbar(output.fit_responses(I),response(I),stders(I),stders(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
		set(h,'color',(i-1)*[1 1 1]/length(indlist));
	end;
end;
xlabel('Fit responses');
ylabel('Actual responses');

legend_text = {'Equality line'};
for i=1:length(indlist)
	myinds = find(inds==indlist(i));
        legend_text{i+1} = num2str(radius(myinds(1)));
end;
legend(legend_text);
box off;

