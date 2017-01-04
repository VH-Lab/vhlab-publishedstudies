function [freqs,coeffs] = ssn_fft(cell,cellname,prefix)
% SSN_FFT compute FFT for sharp or gauss size tuning curves
%
%  [FQ,COEFFS] = SSN_FFT(CELL,CELLNAME,PREFIX)
%
%   Returns the FFT for a response curve with associate
%    [PREFIX 'Response curve']
%

D = findassociate(cell,[prefix 'SZ Response curve'],'','');

[coeffs,freqs] = fouriercoeffs(D.data(2,:),mean(diff(D.data(1,:))));
