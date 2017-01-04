function err=carandini_orientations_error( params, x, y, ste)
%CARANDINI_ORIENTATIONS_ERROR computes squared error of a shifted gaussian
% to data
%
%  ERR=CARANDINI_ORIENTATIONS_ERROR( PARAMS, X, Y)
%  ERR=VAN_MISES_ERROR( PARAMS, X, Y, STE)
%
%     PARAMS =    (see HELP VAN_MISES)
%     X = x values of data
%     Y = y values of data
%
%   also includes an extra cost for small sigma
%  
%  2003, Alexander Heimel, (heimel@brandeis.edu)
%
   
yfit=carandini_orientation_fit(params,x);
err=(yfit-y);
if nargin==4
%  err=err./((ste+0.001)./(y+0.001)); 
  err=err./ste;
end
err=err*err';

err=err - 0.001*size(x,1)*(min(abs(params(4)),180))^0.3;
