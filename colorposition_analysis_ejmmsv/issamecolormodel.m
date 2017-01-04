function [b,m,numtriv] = issamecolormodel(mod1,mod2,onlytriv,plotit)

  % really answers can mod2 fit mod1
  % which means mod2 is more general than mod1
  %   (it can fit everything that mod1 can, but mod1 cant fit everything that mod2 can)

if nargin==2, ot = 0; else, ot = onlytriv; end;
if nargin<4, doplot = 0; else, doplot = plotit; end;

[Lc,Sc] = TreeshrewConeContrastsColorExchange(4);

m = 0;

numtriv = 0;

if doplot, figure; end;

for i=1:10,
	model = mod1 .* rand(size(mod1));
	[dummy,fitr] = color_fit_rect4_err(model,Lc,Sc,zeros(size(Lc)));
	if all(fitr==0),
		numtriv = numtriv + 1;
	elseif ot==0,
		g = 0;
		j = 1;
		if doplot, subplot(3,4,i); plot(fitr,'r-'); hold on; end;
		while j<10 & g~=1,
			model2 = mod2 .* rand(size(mod2));
			[se,si,le,li,err,r2,thefit] = color_fit_rect4switch(Lc,Sc,fitr,...
					model2(1),model2(3),model2(2),model2(4),sign(mod2));
			if err<1e-7,
				g = g + 1;
				if doplot, plot(thefit,'g','linewidth',2); end;
			else, if doplot, plot(thefit,'b','linewidth',2); end;
			end;
			j = j + 1;
		end;
		if g, m = m + 1; end;
	end;
end;

b = (m==10);
