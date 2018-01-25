function h = mp_plotlengthfit(cellinfo,cellname, varargin)
% MP_PLOTLENGTHFIT - Plot a single length fit tuning curve with raw data
%
%   H = MP_PLOTLENGTHFIT(CELLINFO, CELLNAME, ...)
%
%  Plots the length fit tuning curve in the current axes, along with the
%  raw data and error bars.
%  
%  This function also takes additional parameters in name/value pairs:
%  Parameter (default value)    | Description
%  ------------------------------------------------------------------
%  newfigure (0)                | Create a new figure
%  fitcolor ([0 0 1])           | Fit plot color
%  datacolor ([0 0 0])          | Data plot color
%  usexlabel (1)                | Enable xlabel ('Diameter')
%  useylabel (1)                | Enable ylabel ('Response (spikes/sec)');
%  usetitle (1)                 | Enable title (w/ cellname and parameters)
%
% 

newfigure = 0;
fitcolor = [0 0 1];
datacolor = [0 0 0];
usexlabel = 1;
useylabel = 1;
usetitle = 1;

assign(varargin{:});

h = [];

struct2var(cellinfo.lengthfit.outputs);
struct2var(cellinfo.lengthfit.inputs);

if newfigure, figure; end;

hold on;
h = plot(2*radius(plotorder), fit_responses(plotorder),'color',fitcolor);
h2 = errorbar(2*radius(plotorder), response(plotorder), response_err(plotorder));
set(h2,'color',datacolor,'linestyle','none');

h = [h(:);h2];

box off;

if useylabel, ylabel('Response (spikes/sec)'); end;
if usexlabel, xlabel('Diameter'); end;
if usetitle,
        title({      cellname, ...
                      ['W=' num2str(halfwidth,3) ',A=' num2str(amp,3) ',B=' num2str(b,2) ',r^2=' num2str(r_squared,2)] ...
                },'interp','none');
end;

A = axis;

minx = min(2*radius);
maxx = max(2*radius);

miny = min(response-response_err);
maxy = max(response+response_err);

minyfit = min(fit_responses);
maxyfit = max(fit_responses);

miny = min(miny,minyfit);
maxy = max(maxy,maxyfit);

axis([minx maxx miny maxy]);
