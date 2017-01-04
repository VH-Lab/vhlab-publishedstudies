%


 % initialize and clear variables

alpha = 1;
T = 1;

load DI_image_smooth_gradient

DI_image_smooth = DI_image_smooth';

Wx = linspace(0,0.999,13);
Wy = linspace(0,0.999,13);

dDI = []; DI = []; Rup = []; Rdown = []; DI2 = []; Rup2 = []; Rdown2 = []; WX = []; WY = [];
Rup3 = []; Rdown3 = []; DI3 = [];

dT = [];

dWx  = []; % unidirectional w/o inhibition
dWx2 = []; % unidirectional w/ inhibition
dWx3 = []; % for bidirectional training w/o inhibition
dWx4 = []; % for bidirectional training w/ inhibition

dWy  = []; % unidirectional w/o inhibition
dWy2 = []; % unidirectional w/ inhibition
dWy3 = []; % for bidirectional training w/o inhibition
dWy4 = []; % for bidirectional training w/ inhibition

Rup22 = []; Rdown22 = [];
Rup32 = []; Rdown32 = [];
DI22 = [];
DI32 = [];

amp = 1.01;
const_offset = 0*0.003;  % shouldn't be any
inhib = 0.004; % strong value is 0.004, weak is 0.002

for x=1:length(Wx),
	for y=1:length(Wy),

		% initial responses
		
		WY(x,y) = Wy(y);
		WX(x,y) = Wx(x);
		Rup(x,y) = alpha * (2*rectify(Wy(y)-T) + rectify(2*Wx(x)-T));
		Rdown(x,y) = alpha * (2*rectify(Wx(x)-T) + rectify(2*Wy(y)-T));
		DI(x,y) = (Rup(x,y) - Rdown(x,y))/(Rup(x,y)+Rdown(x,y));

		% upward motion simulations (unidirectional) that lack inhibition
		dWx(x,y) = const_offset+(amp-1)*Wx(x)*alpha*rectify(2*Wx(x)-T); % upward motion is only thing displayed
		dWy(x,y) = const_offset+(amp-1)*Wy(y)*alpha*2*rectify(Wy(y)-T); % threshold should ensure no contribution from single LGN cells
		if Wx(x)+dWx(x,y)>=T,
			dWx(x,y) = 0.999*(T-Wx(x));
		end;
		if Wy(y)+dWy(x,y)>=T,
			dWy(x,y) = 0.999*(T-Wy(y));
		end;

		Rup2(x,y) = alpha * (2*rectify(Wy(y)-T) + rectify(2*(Wx(x)+dWx(x,y))-T));
		Rdown2(x,y) = alpha * (2*rectify(dWx(x,y)+Wx(x)-T) + rectify(2*Wy(y)-T));
		DI2(x,y) = (Rup2(x,y) - Rdown2(x,y))/(Rup2(x,y)+Rdown2(x,y));

		% now upward motion simulations (unidirectional) that include inhibition

		dWx2(x,y) = const_offset+(amp-1)*Wx(x)*alpha*rectify(2*Wx(x)-T); % upward motion is only thing displayed
		dWy2(x,y) = const_offset+(amp-1)*Wy(y)*alpha*2*rectify(Wy(y)-T); % threshold should ensure no contribution from single LGN cells
		dT(x,y) = inhib;
		if Wx(x)+dWx2(x,y)>=T+dT(x,y),
			dWx2(x,y) = 0.999*(T+dT(x,y)-Wx(x));
		end;
		if Wy(y)+dWy2(x,y)>=T+dT(x,y),
			dWy2(x,y) = 0.999*(T+dT(x,y)-Wy(y));
		end;
		Rup3(x,y) = alpha * (2*rectify(dWy2(x,y)+Wy(y)-(T+dT(x,y))) + rectify(2*(dWx2(x,y)+Wx(x))-(T+dT(x,y))));
		Rdown3(x,y) = alpha * (2*rectify(dWx2(x,y)+Wx(x)-(T+dT(x,y))) + rectify(2*(dWy2(x,y)+Wy(y))-(T+dT(x,y))));
		DI3(x,y) = (Rup3(x,y) - Rdown3(x,y))/(Rup3(x,y)+Rdown3(x,y));

		% now bidirectional training
			% upward portion
		dWx3(x,y) = const_offset+(amp-1)*Wx(x)*alpha*rectify(2*Wx(x)-T);
		dWy3(x,y) = const_offset+(amp-1)*Wy(y)*alpha*2*rectify(Wy(y)-T);
			% downward portion
		dWy3(x,y) = dWy3(x,y)+const_offset+(amp-1)*Wy(y)*alpha*rectify(2*Wy(y)-T);
		dWx3(x,y) = dWx3(x,y)+const_offset+(amp-1)*Wx(x)*alpha*2*rectify(Wx(x)-T);
		dWx4(x,y) = dWx3(x,y);
		dWy4(x,y) = dWy3(x,y);
		if Wx(x)+dWx3(x,y)>=T,
			dWx3(x,y) = 0.999*(T-Wx(x));
		end;
		if Wy(y)+dWy3(x,y)>=T,
			dWy3(x,y) = 0.999*(T-Wy(y));
		end;
		if Wx(x)+dWx4(x,y)>=T,
			dWx4(x,y) = 0.999*(T+dT(x,y)-Wx(x));
		end;
		if Wy(y)+dWy4(x,y)>=T,
			dWy4(x,y) = 0.999*(T+dT(x,y)-Wy(y));
		end;

		%bidirectional without inhib
		Rup22(x,y) = alpha * (2*rectify(Wy(y)+dWy3(x,y)-T) + rectify(2*(Wx(x)+dWx3(x,y))-T));
		Rdown22(x,y) = alpha * (2*rectify(dWx3(x,y)+Wx(x)-T) + rectify(2*(Wy(y)+dWy3(x,y))-T));
		DI22(x,y) = (Rup22(x,y) - Rdown22(x,y))/(Rup22(x,y)+Rdown22(x,y));
		%bidirectional with inhib
		Rup32(x,y) = alpha * (2*rectify(Wy(y)+dWy4(x,y)-(T+dT(x,y))) + rectify(2*(dWx4(x,y)+Wx(x))-(T+dT(x,y))));
		Rdown32(x,y) = alpha * (2*rectify(dWx4(x,y)+Wx(x)-(T+dT(x,y))) + rectify(2*(Wy(y)+dWy4(x,y))-(T+dT(x,y))));
		DI32(x,y) = (Rup32(x,y) - Rdown32(x,y))/(Rup32(x,y)+Rdown32(x,y));
	end;
end;
	
dDI = DI2 - DI;
dDI2 = DI3 - DI;

dDI22 = DI22 - DI;
dDI32 = DI32 - DI;


DI_image = rescale(DI,[-1 1],[0 254]);
DI_image(find(isnan(DI)))=255;
cmap = [jet(254); 1 1 1];

figure;
subplot(2,2,1);
image(Wx,Wy,DI_image_smooth);
colormap(cmap);
hold on;
arrowplot(WX,WY,atan2(dWy,dWx)*180/pi,0.03*ones(size(WX)).*((dWx.^2+dWy.^2)>1e-10),...
	'linecolor',1+[0 0 0],'linethickness',1);
box off;
set(gca,'ydir','normal');
axis([-.1 1.1 -0.1 1.1]);
axis square;
set(gca,'ytick',[0 0.5 1]);
title('Unidirectional w/o inhib');
subplot(2,2,2);
%quiver(WX,DI,dWx,dDI,'b')
arrowplot(WX,DI,atan2(dDI,dWx)*180/pi,0.03*ones(size(WX)).*((dWx.^2+dDI.^2)>1e-10),...
	'linecolor',[0 1 0],'linethickness',1);
box off;
title('Unidirectional w/o inhib');
axis([0 1 -1 1]);

subplot(2,2,3);
image(Wx,Wy,DI_image_smooth);
hold on;
%quiver(WX,WY,dWx2-dT,dWy2-dT,'g')
arrowplot(WX,WY,atan2(dWy2-dT,dWx2-dT)*180/pi,0.03*ones(size(WX)).*(((dWx-dT).^2+(dWy-dT).^2)>1e-13),...
	'linecolor',1+0*[0 1 0],'linethickness',1);
box off;
set(gca,'ydir','normal');
set(gca,'ytick',[0 0.5 1]);
title('Unidirectional w inhib');
axis([-.1 1.1 -0.1 1.1]);
axis square;
subplot(2,2,4);
quiver(WX,DI,dWx2-dT,dDI2,'b')
box off;
title('Unidirectional w inhib');
axis([0 1 -1 1]);

figure;
subplot(2,2,1);
image(Wx,Wy,DI_image_smooth);
hold on;
colormap(cmap);
%h=quiver(WX,WY,dWx3,dWy3,1,'w','linewidth',1)
arrowplot(WX,WY,atan2(dWy3,dWx3)*180/pi,0.03*ones(size(WX)).*(((dWx3).^2+(dWy3).^2)>1e-10),...
	'linecolor',1+[0 0 0],'linethickness',1);
%adjust_quiver_arrowhead_size(h,2);
axis([-.1 1.1 -0.1 1.1]);
set(gca,'ydir','normal');
axis square;
set(gca,'ytick',[0 0.5 1]);
box off;
title('Bidirectional w/o inhib');
subplot(2,2,2);
quiver(WX,DI,dWx,dDI22,'b')
box off;
title('Bidirectional w/o inhib');
axis([0 1 -1 1]);

subplot(2,2,3);
image(Wx,Wy,DI_image_smooth);
hold on;
colormap(cmap);
set(gca,'ydir','normal');
%h=quiver(WX,WY,dWx4-dT,dWy4-dT,1,'w','linewidth',1);
arrowplot(WX,WY,atan2(dWy4-dT,dWx4-dT)*180/pi,0.03*ones(size(WX)).*(((dWx4-dT).^2+(dWx4-dT).^2)>1e-10),...
	'linecolor',1+[0 0 0],'linethickness',1);
%adjust_quiver_arrowhead_size(h,2);
axis([-.1 1.1 -0.1 1.1]);
axis square;
set(gca,'ytick',[0 0.5 1]);
box off;
title('Bidirectional w inhib');
subplot(2,2,4);
quiver(WX,DI,dWx2-dT,dDI32,1,'b')
box off;
title('Bidirectional w inhib');
axis([0 1 -1 1]);


