function [A,dog_sse, fitvalues_dog] = dogfit(x,r)

%DOGFIT- difference of gaussian function for the classical surround
%suppression model
%takes data and returns fit parameters (a1 through a7)
%Inputs: x is stimulus length, r is response of a neuron
%Outputs: A is the parameters a1-a7, sse is the sum squared error, and
%fitvalues is the difference of gaussian distribution

lowerlimit = [ 0 0 -Inf 0 0 -Inf -Inf ];
upperlimit = [ Inf 0.2 Inf 1 1 Inf Inf];
a = 1; b = 1/10; c = 20; d = 1/2; e = 1/10; f = 40/2; g = 1;

fo = fitoptions('Method','NonlinearLeastSquares', ...
               'Lower',lowerlimit,...
               'Upper',upperlimit);
 %              'Startpoint',[a1 a2 a3 a4 a5 a6 a7]);
 
dog=fittype('a*(((erf((x - c)*b) + 1)/2) - d*((erf((x - f)*(b*e)) + 1)/2)) - g;','options',fo);


half_r = find(r>0.5*max(r));
half_x = x(half_r(1));

surr_x = 0.7*half_x + 20;
 
cfit_best=[];
cfit_error=Inf;
cfit_best_gof=[];

for a=[2*max(r)],
  for b=[1/10 1/50],
    for c=[0 half_x/2 half_x],
      for d=[0.25 0.5 0.75]*max(r),
       for e=[1/10 1/50],
        for f=[0 surr_x/2 surr_x],
          for g=[1],
		fo.Startpoint = [ a b c d e f g];
		dog = setoptions(dog,fo);
		[cfit, gof] = fit(x(:),r(:),dog);
        	if gof.sse<cfit_error
	        	cfit_best=cfit;
			cfit_error=gof.sse;
			cfit_best_gof=gof;
		end;
   		A=coeffvalues(cfit_best);   
		fitvalues_dog=cfit_best(x);
		dog_sse=cfit_best_gof.sse;
          end;
        end;
       end;
      end;
    end;
  end;
end;

%Test it on some generated data (use the function to create some data points with an arbitrary a1, a2, ...)
%R_madeup = dog(A, x)
%A_fit = dogfit(R_madeup)
%A_fit should be the same as A (pretty close)
%Then R_madeup = dog(A,x) + randn(size(R_madeup))

