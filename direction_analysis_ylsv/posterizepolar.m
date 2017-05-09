function posterizepolar(fignum, method, limit, rtick)
% POSTERIZEPOLAR - Make a thicker graphic suitable for posters using MMPOLAR
%
% POSTERIZEPOLAR(FIGNUM, METHOD, LIMIT, RTICK)
%
%   
%   Changes 'markersize' of points to 20, 

figure(fignum);

switch method,
    case 1,
        mmpolar('rlimit',[0 limit]);
	mmpolar('rtickvalue',[0 rtick]);
	mmpolar('ttickdelta',90);
        ch = get(gca,'children');
        for i=1:length(ch),
		try,
			set(ch(i),'markersize',20);
		end;
	end;
        mmpolar('rgridlinestyle','--','rgridvisible','on','rticklabel',{'' ''},'tgridlinestyle','-');
end;

