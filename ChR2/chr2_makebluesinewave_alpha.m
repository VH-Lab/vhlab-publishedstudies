  % this script makes the sinusoidally transparent blue sinusoidal grating for the figure


[x,y]=meshgrid(0:0.01:10);
BS = zeros(size(x,1),size(x,2),3);
BS(:,:,3) = 0.5+0.5*sin(0.5*2*pi*x);
BS(:,:,1) = 0.2 * BS(:,:,3);
BS(:,:,2) = 0.5059 * BS(:,:,3);
imwrite(BS,'sinewave_alpha_full.png','alpha',A);
A = 0.4 + 0.4*sin(0.5*2*pi*x);
imwrite(BS,'sinewave_alpha_full.png','alpha',A);
