function str = igorseriestest(datapath,scriptName,saving,remPath)

if ~saving, error('Cannot use if not saving results.'); end;

%str = {[sprintf('disp([''testing %d %s'']);',myarg,scriptName)]};

str = {'applescript(''igorseriesres.applescript'');'};

