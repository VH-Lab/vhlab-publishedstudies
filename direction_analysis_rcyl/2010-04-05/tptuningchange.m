function [ind, curve] = tptuningchange(myind, mycurve, myblank, stimchange)
 %keyboard;

 ind = myind; valuechange = .04; 
 if stimchange>0,
    ind{stimchange} = myind{stimchange}+ valuechange;  
 else % need to make it unresponsive 
    for i = 1:8
    rnd = normrnd(0,.01); dif = mycurve(2,i)-myblank(1)+rnd;
    ind{i} = myind{i}-dif; 
    
    end;   
 end;
 
 for i = 1:8,
    curve(2,i) = nanmean(ind{i});
    curve(3,i) = nanstd(ind{i});
    curve(4,i) = nanstderr(ind{i}); 
    i = i+1;
 end;
 %keyboard;
     
 curve(1,:) = mycurve(1,:);
 
%  'IPSI ME'
%  i=69, 232;[4 8] 4 +.02
%  i=292;[1 5] 5 +.02
%  
%  'CONT ME'
%  i=103, 232;[4 8] 4 +.02
%  i=292;[1 5] 5 +.02