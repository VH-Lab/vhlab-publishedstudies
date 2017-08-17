function lengthtuningfitinfo = mp_lengthtuning2lengthtuningfits(cellinfo)
% MP_LENGTHTUNING2LENGTHTUNINGFITS - Compute length tuning parameter fits
%
%  LENGTHTUNINGFITINFO = MP_LENGTHTUNING2LENGTUNINGFITS(CELLINFO)
%
%  Given CELLINFO with a subfield 'lengthinfo' with fields
%  'vis_resp_p','length_resp_p','length_curve','length_curve_norm',
%  'aperture_curve','aperture_curve_norm','blank' calculate
%  as returned from MP_GETLENGTHTUNINGCELL
%
%  

li = cellinfo.length_info;


xrange = 1:400;
yrange = 1:400;

radius = [li.length_curve(1,:)];
response = [li.length_curve(2,:)];

if ~isempty(li.aperture_curve),
	radius = [radius -li.aperture_curve(1,:) ];
	response = [response li.aperture_curve(2,:) ];
end;



[mu,C,a,b,fit_responses] = gaussspotfit_nopos_surr(xrange,yrange,radius,response);

lengthtuningfitinfo = vars2struct('C','a','b','fit_responses');

