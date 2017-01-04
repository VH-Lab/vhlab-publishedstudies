function [A,dog_sse, fitvalues_dog] = dogfit(x,r)

%DOGFIT- difference of gaussian function for the classical surround
%suppression model
%takes data and returns fit parameters (a1 through a7)
%Inputs: x is stimulus length, r is response of a neuron
%Outputs: A is the parameters a1-a7, sse is the sum squared error, and
%fitvalues is the difference of gaussian distribution

%Lower and Upper
%a1=0<x<Inf
%a2=0<x<Inf
%a3=-Inf<x<Inf
%a4=0<x<Inf
%a5=0<x<Inf
%a6=-Inf<x<Inf
%a7=-Inf<x<Inf
%r(x)= a1*(erf(a2*(x-a3))/2 + 0.5)-a4(erf(a5*(x-a6))/2 + a7)
%plot data on top subplot; show fit on bottom subplot

%StartPoints
%a1 =maxr;        %set as maximum of r
%a2 =rand;        %set as rand
%a3 =0.5*x(locmaxr); %set as 0.5*x(locmaxr)   % was locmaxx
%a4 =maxr-r(end);      %set as maximum minus last point
%a5 =rand;        %set as rand
%a6 =x(locmaxr);     %set as x(locmaxr)    % was locmaxx
%a7 =randn;       %set as any random number

[maxr,locmaxr]=max(r);
[minr,locminrr]=min(r);
[maxx,locmaxx]=max(x);
[minx,locminx]=min(x);
lowerlimit=[-abs(maxr) 0 minx 0 0 -Inf -Inf];
upperlimit=[abs(maxr) 1 maxx Inf 1 Inf Inf]; 

a1 =maxr;   %set as maximum of r
a2 =[rand];  %set as rand
a3 =0.5*x(locmaxr)+rand*30; %set as 0.5*x(locmaxr)   % was locmaxx
a3 =transpose(a3);
a4 =rand*(maxr-r(end));      %set as maximum minus last point
a5 =[rand];       %set as rand
a6 =x(locmaxr)+rand*30;     %set as x(locmaxr)    % was locmaxx
a6 =transpose(a6);
a7 =[rand] ;
    
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',lowerlimit,...
               'Upper',upperlimit,...
               'Startpoint',[a1 a2 a3 a4 a5 a6 a7]);
 
dog=fittype('a1*(erf(a2*(x-a3))/2 + 0.5)-a4*(erf(a5*(x-a6))/2 + a7)','options',fo); % old
dog=fittype('a1*(((erf((xdata - c)*b) + 1)/2) - d*((erf((xdata - f)*(b*e)) + 1)/2)) - g;','options',fo);

 
    cfit_best=[];
    cfit_error=Inf;
    cfit_best_gof=[];
	fo.Startpoint = [ maxr rand 0.5*x(locmaxr)+rand*30 maxr-r(end) rand x(locmaxr)+rand*30 randn];% edit here
	dog = setoptions(dog,fo);
        [cfit, gof]=fit(x(:),r(:),dog);
        if gof.sse<cfit_error
            cfit_best=cfit;
            cfit_error=gof.sse;
            cfit_best_gof=gof;
        end;
    end;
    
   A=coeffvalues(cfit_best);   
   fitvalues_dog=cfit_best(x);
   dog_sse=cfit_best_gof.sse;
                
end

%Test it on some generated data (use the function to create some data points with an arbitrary a1, a2, ...)
%R_madeup = dog(A, x)
%A_fit = dogfit(R_madeup)
%A_fit should be the same as A (pretty close)
%Then R_madeup = dog(A,x) + randn(size(R_madeup))

