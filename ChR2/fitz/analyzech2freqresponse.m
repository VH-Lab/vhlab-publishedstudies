function [newcell,assocs] = analyzech2freqresponse(cell, cellnames, ds, plotit);

assocs = struct('type','','owner','','data','','desc','');
assocs = assocs([]);

A = findassociate(cell,'freqresp test','','');

newcell = cell;

if ~isempty(A),
        traintimesfilename = [getpathname(ds) filesep A.data filesep 'traintimes_0.txt'];
        try,
            tt = load([traintimesfilename],'-ascii');
        catch, return; end;
        [dummy,neworder] = sort(tt(:,2));
        tt = tt(neworder,[1 2]);

        stimtimesfilename = [getpathname(ds) filesep A.data filesep 'stimtimes.txt'];
        fid = fopen(stimtimesfilename,'rt');

        sp2_times = []; sp2_stimid = [];

        i=0;
        while ~feof(fid),
            i=i+1;
            stimline = fgets(fid);
            if ~isempty(stimline)&~eqlen(-1,stimline),
                stimdata = sscanf(stimline,'%f');
                if ~isempty(stimdata),
                    try,
                        sp2_times(end+1) = stimdata(2);
                        sp2_stimid(end+1) = stimdata(1);
                    catch, error(['error in  ' filename '.']);
                    end;
                end;
            end;
        end
        
        avgisi = mean(diff(sp2_times));

        g = load([getpathname(ds) filesep A.data filesep 'stims.mat'],'-mat');
        ss = g.saveScript;

        stimmean = [];
        stimstddev = [];
        stimstderr = [];
        stimfreq = [];
        allspikes = get_data(cell,[-Inf Inf],2);
        allspikes = allspikes - g.start; % convert to local directory time frame
        do = getDisplayOrder(ss);


        % now loop over stims

        for i=1:numStims(ss),
                p = getparameters(get(ss,i));
                if p.iontophor_curr~=0,
                    if p.iontophor_pulsewidth > 1, 
                        stimfreq(i) = 0; % whatever it is
                    else
                        stimfreq(i) = 1/(p.iontophor_pulseinterval+p.iontophor_pulsewidth+2e-5);
                    end;
                    times = find(sp2_stimid==i);
                    stimintervals = []; stimintervalswithspke = [];
                    for t = 1:length(times),
                            if stimfreq(i)~=0,
                                ups = find(tt(:,1)==1&tt(:,2)>sp2_times(times(t))-0.1&tt(:,2)<sp2_times(times(t))+p.iontophor_numpulses/stimfreq(i)+0.1);
                                downs = find(tt(:,1)==0&tt(:,2)>sp2_times(times(t))-0.1&tt(:,2)<sp2_times(times(t))+p.iontophor_numpulses/stimfreq(i)+0.1);
                                good=find(tt(downs,2)-tt(ups,2)>4/1000);
                                ups = ups(good); downs = downs(good);
                            else,
                                ups = find(tt(:,1)==1&tt(:,2)>sp2_times(times(t))-0.1&tt(:,2)<sp2_times(times(t))+p.iontophor_pulsewidth+0.1);
                                downs = find(tt(:,1)==0&tt(:,2)>sp2_times(times(t))-0.1&tt(:,2)<sp2_times(times(t))+p.iontophor_pulsewidth+0.1);
                            end;
                            if length(ups)~=length(downs), error(['issue']); end;
                            stimintervals(t) = 0; stimintervalswithspike(t) = 0;
                            for z = 1:length(ups),
                                stimintervals(t) = stimintervals(t) + 1;
                                if ~isempty(find(allspikes>=tt(ups(z),2)&allspikes<=tt(downs(z),2))),
                                    stimintervalswithspike(t) = stimintervalswithspike(t) + 1;
                                end;
                            end;
                    end;
                    stimmean(i) = mean(stimintervalswithspike./stimintervals);
                    stimstddev(i) = std(stimintervalswithspike./stimintervals);
                    stimstderr(i) = stderr([stimintervalswithspike./stimintervals]');
                end;
        end;
        assocs(end+1) = struct('type','StimProb curve','owner','','data',[stimfreq ; stimmean; stimstddev; stimstderr],'desc','');
        newcell = associate(newcell,assocs);
end;







