function lengthfitinfo = mp_lengthfit(cellinfo, cellname, varargin)
% MP_LENGTHFIT - Perform several length-tuning fits and store the results
%
% LENGTHFITINFO = MP_LENGTHFIT(CELLINFO, CELLNAME, ...)
%
% This function takes extra arguments as name/value pairs:
% Parameter (default)    | Description:
% --------------------------------------------------------
% plotit (0)             | Plot the fit and raw data on the current
%                        |   axes
% newfigure (1)          | Create a new figure before plotting
%                        |   (only invoked if 'plotit' is 1)
%  


plotit = 0;
newfigure = 1;

assign(varargin{:});

li = cellinfo.length_info;

if isfield(li,'length_curve'),
	if numel(li.length_curve)<1,
		lengthfitinfo = [];
		return;
	end;
end;

radius = [li.length_curve(1,:)/2]; % function needs radius
response = [li.length_curve(2,:)];
response_err = [li.length_curve(4,:)];

if isfield(li,'aperture_curve'),
	if length(li.aperture_curve)>2,
		radius = [radius -li.aperture_curve(1,:)/2 ];
		response = [response li.aperture_curve(2,:) ];
		response_err = [response_err li.aperture_curve(4,:)];
	end;
end;


xrange = 1:5:800;
yrange = 1:5:800;

[mu,C,amp,b,fit_responses,r_squared] = gaussspotfit_nopos_surr(xrange,yrange,radius,response);

[dummy,plotorder] = sort(radius);

halfwidth_ellipse = gauss2d_ellipse(mu,C);
halfwidth = halfwidth_ellipse.major;

if plotit,
	if newfigure, figure; end;
	plot(2*radius(plotorder), fit_responses(plotorder),'b-');
	hold on;
	errorbar(2*radius(plotorder), response(plotorder), response_err(plotorder), 'ko');
	box off;

	rad = sqrt(C(1));

	ylabel('Response (spikes/sec)');
	xlabel('Diameter');
	title({      'Length tuning: ', ...
	              cellname, ...
	              ['W=' num2str(halfwidth,3) ',A=' num2str(amp,3) ',B=' num2str(b,2)] ...
		},'interp','none');
end;


inputs = var2struct('radius','response','response_err');
parameters = var2struct('plotit','newfigure');
outputs = var2struct('mu','C','amp','b','fit_responses','plotorder','halfwidth','r_squared');

lengthfitinfo = var2struct('inputs','parameters','outputs');


