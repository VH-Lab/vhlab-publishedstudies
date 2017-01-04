function output = gaussellipsenkfit_multi(filenames, filesizes, varargin)
% GAUSSELLIPSENKFIT_MULTI - Perform gaussian fit to spot stimuli at multiple sizes with Naka-Rushton response
%
%  GAUSSELLIPSEFIT_MULTI(FILENAMES, FILESIZES, ...)
%
%  Input: FILENAMES can take 2 forms. 
%    In one form, FILENAMES should be a cell list of file names of text files
%    that have, in columns, X position (in pixels), Y position (in pixels), and 
%    RESPONSE (in spikes).
%    FILESIZES should be an array with the radius of the spot used (in pixels).
%
%    In the other form, FILENAMES is not a filename at all but is a table
%    with the response data. The table should have, in columns, the X position (in
%    pixels), the Y position (in pixels), the spot radius (in pixels), the 
%    responses (in Hz), and the standard error of the responses (Hz).
%    
%  Output: a structure called output with fields:
%    MU - the mean of the gaussian fit
%    C  - the covariance matrix of the gaussian fit
%    a  - the scaling factor of the gaussian
%    C50 - the Naka Rushton C50 (see help NAKA_RUSHTON_FUNC)
%    N - The Naka Rushton function N
%    

x_ctr = [];
y_ctr = [];
response = [];
radius = [];

inds = [];


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

[output.mu, output.C, output.a,output.C50, output.N, output.fit_responses] = gaussspotfit_nk(1:5:800, 1:5:600, x_ctr, y_ctr,radius,response);

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
for i=1:length(unique(inds)),
	I = find(inds==i);
	%plot(response(I),output.fit_responses(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
	if isempty(stders),
		plot(output.fit_responses(I),output.response(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
	else,
		h = errorbar(output.fit_responses(I),response(I),stders(I),stders(I),symbs(i),'color', (i-1)*[1 1 1]/length(indlist));
	end;
end;
xlabel('Fit responses');
ylabel('Actual responses');

legend_text = {'Equality line'};
indlist = unique(inds);
for i=1:length(indlist)
	myinds = find(inds==indlist(i));
	legend_text{i+1} = num2str(radius(myinds(1)));
end;
legend(legend_text);
box off;

