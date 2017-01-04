function convertvhlvbatch
% runs through a date folder of experiment, picks t folders to add, and
% then converts old-format .vld files to new format .vld files.

dname = uigetdir('E:\Arani\Data'); % pick the date dir of experiment to be analyzed
cd(dname);

files = uipickfiles('out','cell'); % pick the t folders to be included in the analysis


for i=1:length(files)
    cd (files{i});
    if ~exist('vhlvanaloginput_original.vld'),
       movefile('vhlvanaloginput.vld','vhlvanaloginput_original.vld');
       movefile('vhlvanaloginput.vlh','vhlvanaloginput_original.vlh');
    end;
    convertvhlvdatafile2integer('vhlvanaloginput_original.vld',[],'vhlvanaloginput.vld',10,'int16');
end

