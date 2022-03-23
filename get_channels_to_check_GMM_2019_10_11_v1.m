function get_channels_to_check_GMM_2019_10_11_v1(p,first_pos,last_pos,num_pos)
%This function selects only positions larger than the first_pos and smaller
%than the last_pos and randomly selects channels to manually correct between those two positions.
%Input: 
%p: p-structrue with paths
%first_pos: integer, number of first pos to pick a random channel from
%last_pos: integer, number of last pos to pick a random channel from
%num_pos: integer, number of channels to pick

D=dir([p.dateDir,'Bacillus-*']);
out2={D.name};
out2_char=char(out2);
good_pos=str2num(out2_char(:,end-1:end));

good_pos_ind=good_pos>=first_pos&good_pos<=last_pos;

good_pos_use=good_pos(good_pos_ind);

D=dir([p.dateDir,'Bacillus_*']);
Dc=char({D.name});
ind=Dc(:,end-4:end-3);
ind_mat=str2num(ind);
%ind_test=ismember(ind_mat,[60,54,47,41,38,36]);
ind_test=ismember(ind_mat,good_pos_use);
p2_ind=Dc(ind_test,:);
to_check=randperm(length(p2_ind));
if num_pos>length(to_check)
    num_pos=length(to_check);
end
to_check_f=to_check(1:num_pos);
to_check_fs=sort(to_check_f);
check_names=p2_ind(to_check_fs,:);
check_names=check_names(randperm(length(check_names)),:);
%save('\\slcu.cam.ac.uk\Data\Microscopy\teamjl\Chris\movies\2016-09-07\subAuto\Data_2018_05_22\names_to_check1','check_names');
save([p.rootDir,'Data\names_to_check_',num2str(first_pos),'-',num2str(last_pos)],'check_names');
