function [otcurve,pref,hwhh]=fit_otcurve(curve,pref_hint,tw_hint,peak_hint,spont_hint )
%FIT_OTCURVE fits orientation tuning curve
%
%    [OTCURVE,HWHH]=FIT_OTCURVE(CURVE,PREF_HINT,TW_HINT,PEAK_HINT,SPONT_HINT )
%      CURVE(1,:) = array of angles (in degrees)
%      CURVE(2,:) = array of spike rates
%
%      OTCURVE(1,:)= (1:360)
%      OTCURVE(2,:)= function values at these angles
%      PREF = preferred angle in degrees 
%      HWHH = halfwidth at halfheight = (peakrate+spont.rate)/2
%   
%  See Swindale 1998 for discussion of fitting an orientation tuning
%  curve
%
%  2003, Alexander Heimel (heimel@brandeis.edu)
%


  pref=pref_hint; % value if no fit could be made
  hwhh=180;       % value if no fit could be made

  disp(['Input : ']);
	pref_hint,tw_hint,peak_hint,spont_hint,
 
  search_options=optimset('fminsearch');
  search_options.TolFun=1e-4;
  search_options.TolX=1e-4;
  search_options.MaxFunEvals=300*4;
  search_options.Display='off';

  
  par=fminsearch('von_mises_error',...
		 [spont_hint peak_hint pref_hint tw_hint],search_options,...
		 curve(1,:),curve(2,:))';
  
  norm_error=von_mises_error(par,curve(1,:),curve(2,:));
  norm_error=sqrt(norm_error/  (curve(2,:)*curve(2,:)') );
  
  disp(['Normalized fitting error: ' num2str(norm_error,3)]);
  par
  
  
  otcurve(1,:)=linspace(0,360,360);
  otcurve(2,:)=von_mises(par,otcurve(1,:));
  
  pref=round(mod(par(3),360));

  k=1/par(4)^2;
  peakrate=par(1)+par(2);
  halfheight=(peakrate+spont_hint)/2;
  fract=1+1/k*log( (halfheight-par(1))/par(2));
  if fract<1 & fract>-1 & imag(fract)==0 % no halfheight
    hwhh=round(360/(2*pi)*0.5*acos(fract ));
  end

