function [assoc]=ctxfdtanalysis(f0curve,f1curve,spont,cellname,display)

%  F0curve should be  [ angles ; f0responses]
%  F1curve should be  [ angles ; f1responses]


assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = [];
f1curve = []; 
maxfiring = []; 
fdtpref = []; 
circularvariance = [];
tuningwidth = [];
directionindex = [];
orientationindex = [];
f1f0 = [];
spont=[];

c = 1;

      [mf0,if0]=max(f0curve(2,:)); 
      [mf1,if1]=max(f1curve(2,:)); 
      
      f1f0 = [f1f0 ; mf1/mf0 ];
      fdtpref = [fdtpref; f0curve(1,if0) f1curve(1,if1)];
      f0curve(end+1,:) = f0curve(1,:);
      f0curve(end+1,:) = f0curve(2,:);
      f0curve(end+1,:) = f0curve(3,:);
      f0curve(end+1,:) = f0curve(4,:);
      f1curve(end+1,:) = f1curve(1,:);
      f1curve(end+1,:) = f1curve(2,:);
      f1curve(end+1,:) = f1curve(3,:);
      f1curve(end+1,:) = f1curve(4,:);
      spont(end+1)=co.spont(1);
      maxfiring = [maxfiring; mf0 mf1];

      circularvariance = ...
	  [circularvariance; ...
	   compute_circularvariance(f0curve(1,:),f0curve(2,:)) ...
	   compute_circularvariance(f1curve(1,:),f1curve(2,:))];
      tuningwidth = ...
	  [tuningwidth; ...
	   compute_tuningwidth(f0curve(1,:),f0curve(2,:)) ...
	   compute_tuningwidth(f1curve(1,:),f1curve(2,:))];
      directionindex = ...
	  [directionindex;...
	   compute_directionindex(f0curve(1,:),f0curve(2,:)) ...
	   compute_directionindex(f1curve(1,:),f1curve(2,:))];
      orientationindex = ...
	  [orientationindex;...
	   compute_orientationindex(f0curve(1,:),f0curve(2,:)) ...
	   compute_orientationindex(f1curve(1,:),f1curve(2,:))];
	
      for cmsmp=1:2
	if cmsmp==2 % simple
	  curve=f1curve;
	  spont_hint=0;
	else
	  curve=f0curve;
	  spont_hint=spont(1);
	end
	[rcurve{c,cmsmp},fdtpref(end,cmsmp),tuningwidth(end,cmsmp)]=...
	    fit_otcurve(curve,fdtpref(end,cmsmp),90,...
			maxfiring(end,cmsmp),spont_hint );
%			4*tuningwidth(end,cmsmp), ...
      end % loop over F0/F1
      
      
    if display,
      % for aligning curves in the center
      [m,irow]=max(maxfiring);
      [m,icol]=max(m);
      optangle=fdtpref(irow(icol),icol);
      [i,v]=findclosest(f0curve(1,:),mod(optangle-90,360));
      n_angles=size(f0curve,2);
      lowhalfsize=floor(n_angles/2);
      angles=f0curve(1,:);
      if i>lowhalfsize 
	% i lays past midpoint
	start1=i-lowhalfsize+1;
	end1=n_angles;
	start2=1;
	end2=i-lowhalfsize;
	angles(start2:end2)=angles(start2:end2)+360;
      else
  	% i lays before midpoint
	start1=i+lowhalfsize;
	end1=n_angles;
	start2=1;
	end2=i+lowhalfsize-1;
	angles(start1:end1)=angles(start1:end1)-360;
      end
      sequence=[(start1:end1) (start2:end2)];
      
      
      colors='kbrymcgw';
      figure;
      
      for i=1:length(contrast)
	subplot(2,1,1),plot(f0curve(1,:),...
			    f0curve(4*(i-1)+2,:), ...
			    [colors(i) 'o']);
	hold on
	plot(rcurve{i,1}(1,:),rcurve{i,1}(2,:),...
			      [colors(i)]);
	xlabel('Angle (degrees)')
	ylabel('Rate (Hz)')
	xt=get(gca,'XTick');
	set(gca,'XTickLabel',num2str(mod(xt,360)'));
	hold on;
	  subplot(2,1,2),plot(f1curve(1,:),...
			      f1curve(4*(i-1)+2,:), ...
			    [colors(i) 'o'])
	  hold on
	  plot(rcurve{i,2}(1,:),rcurve{i,2}(2,:),...
			      colors(i));
	xlabel('Angle (degrees)')
	ylabel('F1 (Hz)')
	xt=get(gca,'XTick');
	set(gca,'XTickLabel',num2str(mod(xt,360)'));
	hold on;
      end
    end
	

    spont=[mean(spont) std(spont) ];
      
    
    assoc(end+1)=ctxnewassociate('FDT Test',...
				 fdttest(end).data,...
				 'FDT Test');
    assoc(end+1)=ctxnewassociate('FDT Response Curve F1',f1curve,...
			'FDT Response Curve (F1)');
    assoc(end+1)=ctxnewassociate('FDT Response Curve F0',f0curve,...
			'FDT Response Curve (F0)');
    assoc(end+1)=ctxnewassociate('FDT Max firing rate',maxfiring,...
			'FDT Max firing rate [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Pref',fdtpref,...
			'FDT Direction with max response [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Circular variance',circularvariance,...
			'FDT Circular variance [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Tuning width',tuningwidth,...
			'FDT Tuning width [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Direction index',directionindex,...
			'FDT Direction index [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Orientation index',orientationindex,...
			'FDT Orientation index [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT F1/F0',f1f0,...
			'FDT F1/F0');
    assoc(end+1)=ctxnewassociate('FDT Spontaneous rate',spont,...
			'FDT Spontaneous rate ([mean std])');
  end;
end;

