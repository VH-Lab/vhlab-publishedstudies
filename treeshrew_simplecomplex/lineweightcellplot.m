function lineweightcellplot(cell,cellname, assoc_prefix, check_simple_complex)
% lineweightcellplot - Examine a cell's lineweight responses and indexes
%
%  LINEWEIGHTCELLPLOT(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Plots the DOG fit for spatial frequency, along with mean responses
%  and error bars.  Also shows LOW/HIGH cut-offs for DOG in blue, and
%  LOW/HIGH cut-offs based on interpolation of the raw data in red.

assoc_name{1} = ['lineweight white response curve'];
assoc_name{2} = ['lineweight black response curve'];
assoc_name{3} = ['normalized area overlap'];
assoc_name{4} = ['black white peak fraction'];

if check_simple_complex,
        f1_f0f1 = extract_oridir_indexes(cell);
        if ~isempty(f1_f0f1),
                if 2*f1_f0f1>=1,
                        F0 = findstr(assoc_prefix,'F0');
                        assoc_prefix(F0:F0+1) = 'F1';
                end;
        end;
end;

for i=1:length(assoc_name),
	A{i} = findassociate(cell,[assoc_prefix ' ' assoc_name{i}],'','');
end;

hold off;

 % plot the white curve
h = myerrorbar(A{1}.data(1,:),A{1}.data(2,:),A{1}.data(4,:),'b');
%delete(h(2)); % remove the line

hold on;

 % plot the black curve
h = myerrorbar(A{2}.data(1,:),A{2}.data(2,:),A{2}.data(4,:),'k');
%delete(h(2)); % remove the line
 % plot the raw data

 % now add the labels

title({cellname, ['OFFf=' num2str(A{4}.data,2) ', OV=' num2str(A{3}.data,2)]} ,'interp','none');

box off;

Ax = axis;

dx = median(diff(A{2}.data(1,:)));

mndata = min([ min(A{2}.data(2,:)-A{2}.data(4,:)) min(min(A{1}.data(2,:)-A{1}.data(4,:)))]);
mxdata = max([ max(A{2}.data(2,:)+A{2}.data(4,:)) max(max(A{1}.data(2,:)+A{1}.data(4,:)))]);

hundredpercent = (mxdata - mndata);

axis([ min(A{2}.data(1,:))-dx max(A{2}.data(1,:))+dx mndata-0.1*hundredpercent mxdata+0.1*hundredpercent]);
