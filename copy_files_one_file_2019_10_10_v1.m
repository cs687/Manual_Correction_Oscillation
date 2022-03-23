function copy_files_one_file_2019_10_10_v1(p)
% This function finds all corrected traces by looking for folders with files
% ending with '*_lin_bak1.mat'. It then saves the tracking files (ending
% ('*-tracks.mat') into one file after removing all saved image matrices from the schnitz
% structure.


p1_all={p.dateDir};
outpath=p.dataDir;
for k=1:length(p1_all)
    p1=p1_all{k};
    folder_name=p1(end-29:end-20);
    if ~exist([outpath]);
        mkdir([outpath]);
    end
    D=dir([p1,'Bacillus_*']);
    %disp(p1);
    for i=1:length(D)
        if exist([p1,D(i).name,'\data\',D(i).name,'_lin_bak1.mat']);
            load([p1,D(i).name,'\data\',D(i).name,'-tracks']);
            s(1).Lc_c=[];
            s(2).Lc_c=[];
            s(3).Lc_c=[];
            s(1).yreg=[];
            s(1).rreg=[];
            s(1).preg=[];
            eval([D(i).name,'=s;']);
        end
    end
    names_pre=whos('Bacillus*');
    names={names_pre.name};
    D2=dir([outpath,'\all_files_all_tracked_*']);
    save([outpath,'\all_files_all_tracked_',num2str(length(D2)+1)],names{:});
end
