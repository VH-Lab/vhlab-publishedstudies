function R=carandini_orientation_fit(par,x)
%VON_MISES returns Carandini&Ferster (2000) orientation fit
%
%    R=VON_MISES(PAR,X)
%
%    X is input variable vector
%
%    R=Rsp+Rp*EXP(-(X-Op)^2)/(2*sig^2))+Rn*EXP(-(X-Op+180)^2/(2*sig^2))
%    where Rsp=PAR(1),Rp=PAR(2),Op=PAR(3),sig=PAR(4),Rn=PAR(5)
%
%   Fits orientation tuning curve using same function as Carandini
%   and Ferster (2000).
%
%   2004 Steve Van Hooser (vanhoosr@brandeis.edu)
%   (modified from von_mises by Alexander Heimel)

Rsp=par(1);Rp=par(2);Op=par(3);sig=par(4);Rn=par(5);
R=Rsp+Rp*exp((-(x-Op).^2)/(2*sig^2))+Rn*exp(-(x-Op+180).^2/(2*sig^2))
