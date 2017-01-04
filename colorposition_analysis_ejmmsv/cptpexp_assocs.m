function cptpexp_assocs

fitzlabtestid;  % make sure our tests are registered

tpassociatelistglobals;

s = input('Should we clear current associate list? (y/n) :','s');
if s=='y'|s=='Y', tpassociatelist = tpassociatelist([]); end;

r = input('What is PND of tree shrew? (enter -1 to skip) :');
if r>0, tpassociatelist = [ tpassociatelist struct('type','Age','owner','twophoton','data',r,'desc','')]; end;

r = input('How many days have eyes been open ? (-1 for closed) :');
tpassociatelist = [ tpassociatelist struct('type','Eyes open','owner','twophoton','data',r,'desc','')];

s = input('What is tree shrew name/number? :','s'); 
tpassociatelist = [ tpassociatelist struct('type','Animal number','owner','twophoton','data',s,'desc','')];

