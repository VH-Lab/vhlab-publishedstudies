
angles = [0 45 90 135 180 225 270 315];
ntrials = 100;

spontaneous = 2;
% This will be subtracted from the responses before the vectors are calculated

expected_response = [2 5 2 2 2 2 2 2];

noise = 'scaled';
% noise = eps;
% Enter 'scaled' if you want variance to be equal to the expected resposne
% Otherwise, the number you enter will be used as the standard dev of the response

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate responses
if(isstr(noise))
  if(strmatch(noise,'scaled'))
    noise = sqrt(expected_response);
  end
end

rates_mtx = nan*ones(ntrials,length(angles));
for i_trial = 1:ntrials
  rates_mtx(i_trial,:) = normrnd(expected_response,noise);
end

figure(1),clf;
myerrorbar(angles,mean(rates_mtx),stderr(rates_mtx),stderr(rates_mtx));
box off;
title('Direction response');
xlabel('Angle of grating motion');
ylabel('Reponse (Hz)');

rates_mtx = rates_mtx - spontaneous;

mean_rates = mean(rates_mtx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate statistics for direction selectivity using the vector method in 360-degree space
angles_polar = (angles/360)*2*pi;

r_trial = nan*ones(ntrials,1);
for i_trial = 1:ntrials
  rates = rates_mtx(i_trial,:);
  r = (rates * exp(i*angles_polar)') / sum(abs(rates));
  r_trial(i_trial) = r;
end

x = real(r_trial);
y = -imag(r_trial);
q = x.^2 + y.^2;
[q,magnitude] = cart2pol(x,y);
theta = rad2deg(q);
theta(theta<0) = 360 + theta(theta<0);

figure(2),clf,hold on
plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',8)
plot(mean(x),mean(y),'o','Color','r','MarkerFaceColor','r','MarkerSize',12)
x2pl = abs(x);
dx = 2*max(x2pl);
xlim = [-max(x2pl)-0.05*dx max(x2pl)+0.05*dx];
y2pl = abs(y);
dy = 2*max(y2pl);
ylim = [-max(y2pl)-0.05*dy max(y2pl)+0.05*dy];
set(gca,'XLim',xlim,'YLim',ylim)
plot(get(gca,'XLim'),[0 0],'k-')
plot([0 0],get(gca,'YLim'),'k-')

% Do stats on this distribution to ask whether the cell is directionally-selective
X = [x y];
[H,P]=hotellingt2test(X,[0 0])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantify uncertainty: What's the % chance that the direction points the other way?
% The basic approach is to measure the distribution of vector magnitudes along the axis of preferred orientation. This distribution will be
% use to calculate the probability that the preferred direction is opposite to that obtained from the vector analysis.
% Here's the method:
% (1) Rotate points so that they align along the X-axis
%   -To do this, need to determine the preferred angle in [0 180] space (i.e., orientation), then subtract this angle
% (2) Calculate the mean and standard dev of the x-projection of data points
% (3) Use the distribution to calculate the probability that the actual preferred direction is opposite what we obtained from the analysis

%%%%%%
% Step 1: Obtain the axis of preferred orientation
% Method: Convert data to [0 180] --> calculate vector
x360 = x;
y360 = y;

angles_180 = angles;
ind = angles_180>=180;
angles_180(ind) = angles_180(ind)-180;
angles_polar_180 = (angles_180/180)*2*pi;

r_trial = nan*ones(ntrials,1);
for i_trial = 1:ntrials
  rates = rates_mtx(i_trial,:);
  r = (rates * exp(i*angles_polar_180)') / sum(abs(rates));
  r_trial(i_trial) = r;
end

x = real(r_trial);
y = -imag(r_trial);
% NOTE: These points map 180-degree visual space onto a 360-degree plane. Thus, whatever we calculate for the angle of the mean vector, we
% need to divide by 2.
q = rad2deg(cart2pol(mean(x),mean(y)));
if(q<0)
  q = 360+q;
end
theta180 = q/2;

%%%%%%
% Step 2, determine the magnitude of the projection of each vector onto the orientation axis
% Convert to polar, subtract of theta180, then convert back to Cartesian
x = x360;
y = y360;
[q r] = cart2pol(x,y);
th = rad2deg(q);
th = th-theta180;
[x_adj y_adj] = pol2cart(deg2rad(th),r);
if(mean(x_adj)<0)
  x_adj = -x_adj;
end

%%%%%%
% Step 3: Use the mean and std of x_adj to determine the probability that actual preferred direction is the reverse of what we calculated
prob_reverse = normcdf(0,mean(x_adj),std(x_adj))


