function [cell_id,schnitz_id]=getschnitzid(frames,cell_no_c,cell_no,mfr)

%get schnitz
for i=1:length(frames)
    if sum(ismember(frames{i},mfr))>0
        if cell_no_c{i}(find(frames{i}==mfr))==cell_no
            schnitz_id=i;
            cell_id=cell_no;
            return;
        end
    end
end

if ~exist('cell_id')
    cell_id=0;
    schnitz_id=0;
end
disp('done');


