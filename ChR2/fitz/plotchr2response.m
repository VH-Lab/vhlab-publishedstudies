function [h]=plotchr2response(cell,cellname,property,varargin)
% PLOTTPRESPONSE - Plots orientation responses for cell
%
%   H = PLOTTPRESPONSE(CELL,CELLNAME,PROPERTY,EB,FIT,...)
%
%  Plots tp response curves for a cell on the curent axes.
%
%  Known PROPERTY codes:
%
%     'OT Pref'
%     'OT Fit Pref'
%     'OT Fit Pref 2 Peak'
%     'POS Fit Pref'
%     'Recovery OT Fit Pref 2 Peak'
%
%  If EB is 1, then standard error is shown.
%  If FIT is 1, then the fit is shown if available. If FIT is 1 or there is
%    no available fit then linear interpolation is shown.
%
%  Extra variables can be passed as name/value pairs, e.g., 
%     PLOTPTRESPONSE(CELL,CELLNAME,PROPERTY,EB,FIT,'ds',ds)
%
%  If property is 'Recovery OT Fit Pref 2 Peak', and if a variable DS
%     is passed as an extra variable, then an additional figure is shown
%     with the views of the original cell positions.


dontclose = 1;
plotnonsig = 1;
usepolar=0;
subtractblank = 0;
plotblankrange = 0;
assoc_prefix = 'SP F0';
ylab='Rate (Hz)';
xaxis_range = [];
assign(varargin{:});


switch property,
case {'Spatial frequency'},
	if ~exist('usesig','var'), usesig = 0; end;
	sgr=plotrespnamesallcolors(cell,assoc_prefix,'SF Response curve','SF DOG Fit',eb,fit,'SF visual response p',usesig,'',usepolar,subtractblank,plotblankrange);
	if sgr,
		title(cellname,'interp','none');
		xlabel('Spatial frequency (cpd)');
		ylabel('\DeltaF/F');
	end;
	proceed = 0;
case {'Orientation'},
	respname = 'Ach OT Response curve';fitname = 'Ach OT Carandini Fit';signame = 'Ach OT visual response p'; blankname = 'Ach OT Blank Response'; steps='CoarseDir steps';
	xlims = [0 180];
    sgr=plotrespnamessteps(cell,[assoc_prefix],respname,fitname,signame,blankname,steps,'xlims',xlims,varargin{:});
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Orientation(\circ)');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); axis square; box off;
        end;
	end;
	proceed = 0;
case {'Contrast'},
	respname = 'Ach CT Response curve';fitname = 'Ach CT NK Fit';signame = 'Ach CT visual response p'; blankname = 'Ach CT Blank Response'; steps='Contrast steps';
	xlims = [0 1];
    
    sgr=plotrespnamessteps(cell,[assoc_prefix],respname,fitname,signame,blankname,steps,'xlims',xlims,'stepblankxticks',[0 1+.15],'plotblankrange',[0 1],'errorbartee',0.05,varargin{:});
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Contrast');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); box off; axis square;
        end;
	end;
	proceed = 0;
case {'Length'},
    xaxis_range = [0 60];
    T = findassociate(cell,'LengthWidth 1 resp','','');
    if ~isempty(T),
        sgr = 1;
        T.blank = T.data.blank.curve{1}(2);
        T.data = T.data.curve{1};
        h=myerrorbar(T.data(1,:)/10,T.data(2,:),T.data(4,:),T.data(4,:),'k-'); hold on;
        plot([5 50],T.blank);
        T2 = findassociate(cell,'LengthWidth 2 resp','','');
        T2.blank = T2.data.blank.curve{1}(2:4);        
        T2.data = T2.data.curve{1};
        h=myerrorbar(T2.data(1,:)/10,T2.data(2,:),T2.data(4,:),T2.data(4,:),'b-'); hold on;
        h=myerrorbar(50,T2.blank(1),T2.blank(3),T2.blank(3),'bs',4);
    else, sgr = 0;
    end;
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Length (\circ)');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); box off;  box off;
        end;
	end;
	proceed = 0;
case {'Aperature'},
    xaxis_range = [0 60];
    T = findassociate(cell,'Aperature 1 resp','','');
    if ~isempty(T),
        sgr = 1;
        T.blank = T.data.blank.curve{1}(2);
        T.data = T.data.curve{1};
        h=myerrorbar(T.data(1,:)/10,T.data(2,:),T.data(4,:),T.data(4,:),'k-'); hold on;
        plot([5 50],T.blank);
        T2 = findassociate(cell,'Aperature 2 resp','','');
        T2.blank = T2.data.blank.curve{1}(2:4);        
        T2.data = T2.data.curve{1};
        h=myerrorbar(T2.data(1,:)/10,T2.data(2,:),T2.data(4,:),T2.data(4,:),'b-'); hold on;
        h=myerrorbar(50,T2.blank(1),T2.blank(3),T2.blank(3),'bs',4);
    else, sgr = 0;
    end;
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Aperature (\circ)');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); box off;  box off;
        end;
	end;
	proceed = 0;
case {'Contrast2'},
    xaxis_range = [0 1.4];
    T = findassociate(cell,'Contrast 1 resp','','');
    if ~isempty(T),
        sgr = 1;
        T.blank = T.data.blank.curve{1}(2);
        T.data = T.data.curve{1};
        h=myerrorbar(T.data(1,:),T.data(2,:),T.data(4,:),T.data(4,:),'ko-'); hold on;
        plot([0 1],T.blank);
        T2 = findassociate(cell,'Contrast 2 resp','','');
        T2.blank = T2.data.blank.curve{1}(2:4);        
        T2.data = T2.data.curve{1};
        h=myerrorbar(T2.data(1,:),T2.data(2,:),T2.data(4,:),T2.data(4,:),'bo-'); hold on;
        h=myerrorbar(1.2,T2.blank(1),T2.blank(3),T2.blank(3),'bs',0.1);
    else, sgr = 0;
    end;
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Contrast');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); box off;  box off;
        end;
	end;
	proceed = 0;
case {'Contrast3'},
    xaxis_range = [0 1.4];
    T = findassociate(cell,'Contrast 1 resp','','');
    if ~isempty(T),
        sgr = 1;
        T.blank = T.data.blank.curve{1}(2);
        T.data = T.data.curve{1};
        h=myerrorbar(T.data(1,:),T.data(2,:),T.data(4,:),T.data(4,:),'ko-'); hold on;
        plot([0 1],T.blank);
        T2 = findassociate(cell,'Contrast 2 resp','','');
        T2.blank = T2.data.blank.curve{1}(2:4);        
        T2.data = T2.data.curve{1};
        h=myerrorbar(T2.data(1,:),T2.data(2,:),T2.data(4,:),T2.data(4,:),'bo-'); hold on;
        h=myerrorbar(1.2,T2.blank(1),T2.blank(3),T2.blank(3),'bs',0.1);
    else, sgr = 0;
    end;
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Contrast');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range A(3) A(4)]); box off;  box off;
        end;
	end;
	proceed = 0;    
case {'Frequency'},
    xaxis_range = [-1 100];
    T = findassociate(cell,'StimProb curve','','');
    if ~isempty(T),
        sgr = 1;
        h=myerrorbar(T.data(1,:),T.data(2,:),T.data(4,:),T.data(4,:),'ko-'); hold on;
    else, sgr = 0;
    end;
    if sgr, title(cellname,'interp','none'); end;
	if sgr&~usepolar,
		xlabel('Frequency (Hz)');
		ylabel(ylab);
		xch = get(gca,'children');
        if ~isempty(xaxis_range), 
            A=axis;
            axis([xaxis_range 0 1.2]); box off; axis square; box off;
        end;
	end;
	proceed = 0;
otherwise,
	proceed = 0;
	disp(['Do not know how to plot ' property '.']);
	return;
end;



