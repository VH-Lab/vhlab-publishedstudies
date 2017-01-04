function plotcolorstimproperties(dorods)

if nargin==0, dr = 0; else, dr = dorods; end;

figure;

axl = [10 16 13];
thetitles = {'Color exchange classic','Color exch. barrage','Color exch. Dacey-like'};

for i=1:3,

	[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(i);
	subplot(3,3,(i-1)+1);
	plot(Lc,'g.-','linewidth',2); hold on;plot(Sc,'b.-','linewidth',2);
	axis([1 axl(i) -0.5 0.5]);
	if i==1, ylabel('Relative cone contrast'); end;
	title(thetitles{i});
	if dr, plot(Rc,'r.-','linewidth',2); end;
	
	subplot(3,3,(i-1)+4);
	plot(abs(Lc),'g.-','linewidth',2); hold on;plot(abs(Sc),'b.-','linewidth',2);
	axis([1 axl(i) 0 0.5]);
	if i==1, ylabel('Absolute cone contrast'); end; 
	if dr, plot(abs(Rc),'r.-','linewidth',2); end;

	
	subplot(3,3,(i-1)+7);
	plot((sign(Sc).*sign(Lc)).*(Sc-Lc),'k.-','linewidth',2);
	hold on; plot([-100 100],[0 0],'k--');
	axis([1 axl(i) -1 1]);
	if i==1, ylabel('S-L phase'); end; 
	xlabel('Stim number');
	
end;

x = -10:0.05:10; sigm = 2;

LONLY = [ 0*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod

SONLY = [ sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           0*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod
	   
SUMMER = [ 0.5*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod

OPPONENT = [ 0.5*sin(x).*exp(-x.^2/(2*sigm^2)) ; % S
             sin(x+pi).*exp(-x.^2/(2*sigm^2))  % L
             0*sin(x)];  % no rod input

RF = {LONLY, SONLY, SUMMER, OPPONENT};

for i=1:length(RF),
	figure;
	
	subplot(2,3,1);
	plot(RF{i}(1,:),'b--');
	hold on;
	plot(RF{i}(2,:),'g--');
		
	for j=1:3,
		[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(j);
		%cphase = sign(Lc).*sign(Sc); cphase(find(cphase>0)) = 0;
		R = [];
		for g=1:length(Lc),
			R(g)=0;
			for phase=0:pi/12:2*pi-pi/12,
				stim = [Sc(g)*sin(x+phase); Lc(g)*sin(x+phase); 0*sin(x)];
				R(g)=R(g)+max(0,sum(sum(RF{i} .* stim)));
			end;
		end;
		subplot(2,3,3+j);
		plot(R,'k.-','linewidth',2);
		A=axis;
		axis([1 axl(j) A(3) A(4)]);
	end;
end;