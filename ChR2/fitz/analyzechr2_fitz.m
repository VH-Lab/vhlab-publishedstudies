function [cells,cellnames]=analyzechr2(thedir, redoresponses, redoanalysis, plotit, saveit)

ds = dirstruct(thedir);

[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

if redoresponses,  % extract responses
    for i=1:length(cells),
        mylist = {'CoarseDir','SpatFreq','TempFreq','Contrast','LengthWidth','Aperature'};
        myparams={'angle','sFrequency','tFrequency','contrast','length','aperaturelength'};
        cellnames{i},
        doit = [ 1 1 1 1 1 1 ]*1+[1 0 0 1 0 0]*1;
        for z=1:length(mylist),
            if doit(z),
                myassoc=findassociate(cells{i},[mylist{z} ' test'],'','');
                if ~isempty(myassoc),
                    [dummy,currVals,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, myparams{z}, plotit);
                    if length(co)==1,
                        cells{i}=associate(cells{i},struct('type',[mylist{z} ' resp'],'owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
                    elseif length(co)>1,
                        cells{i}=associate(cells{i},struct('type',[mylist{z} ' steps'],'owner','gratingsheetlet','data',currVals,'desc','Number of current values'));
                        for j=1:length(currVals),
                            cells{i}=associate(cells{i},struct('type',[mylist{z} ' ' int2str(j) ' test'],'owner','gratingsheetlet','data',myassoc.data,'desc',''));
                            cells{i}=associate(cells{i},struct('type',[mylist{z} ' ' int2str(j) ' resp'],'owner','gratingsheetlet','data',make_resp_from_output(co{j}),'desc',''));                        
                        end;
                    end;
                end;
            end;
        end;
    end;

    if saveit, for i=1:length(cells), saveexpvar(ds,cells{i},cellnames{i}); end; end;
end;

if redoanalysis,
    for i=1:length(cells),
        mylist = {'CoarseDir','SpatFreq','TempFreq','Contrast','LengthWidth','Aperature'};
        myparams={'angle','sFrequency','tFrequency','contrast','length','aperaturelength'};
        mycode = {'otanalysis_compute','sfanalysis_compute','tfanalysis_compute','ctanalysis_compute','lengthanalysis_compute','aperatureanalysis_compute'};
        doit = [ 1 1 1 1 1 1 ]*0+[1 0 0 0 0 0]*1;
                cellnames{i},
        for z=1:length(mylist),
            if doit(z),
                j = 1;
                myassoc = findassociate(cells{i},[mylist{z}  ' ' int2str(j) ' test'],'','');
                while ~isempty(myassoc),
                    cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{[mylist{z}  ' ' int2str(j) ' test']},myparams{z},mycode{z},['SP F0 ' int2str(j)],'',0);
                    cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{[mylist{z}  ' ' int2str(j) ' test']},myparams{z},mycode{z},['SP F1 ' int2str(j)],'',1);
                    cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{[mylist{z}  ' ' int2str(j) ' test']},myparams{z},mycode{z},['SP F2 ' int2str(j)],'',2);
                    j = j+1;
                    myassoc = findassociate(cells{i},[mylist{z}  ' ' int2str(j) ' test'],'','');
                end;
            end;
        end;
        cells{i} = analyzech2freqresponse(cells{i}, cellnames{i}, ds, 0);
    end;
    if saveit, saveexpvar(ds,cells,cellnames); end;
end;
