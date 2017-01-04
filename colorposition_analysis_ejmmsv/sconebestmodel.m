function m=sconebestmodel(cell)

 % returns m='linear', 'NK', or 'R4'
 
 % 1st round:     Second round
 %   Lin vs NK
 %                Winner by lower error
 %   Lin vs R4

 
 [p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct, p_r4vsln, p_r4vsnl, linvsr4, nlvsr4]=isnonlinearcolor(cell);
 
 if p_r4vsln<0.05&~p_nlvsln, m = 'R4'
 elseif p_r4vsln<0.05&p_nlvsln, 
     if nlvsr4,m='NK'; else, m='R4';end;
 elseif p_nlvsln, m='NK';
 else, m='linear';
 end;
 
 