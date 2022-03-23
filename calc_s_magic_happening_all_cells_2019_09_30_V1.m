function calc_s_magic_happening_all_cells_2019_09_30_V1(p,wtf_m,f_start_m,f_end_m)

path_files={p.rootDir};
date1=p.movieDate;

for ee=1:length(path_files)
    %loading data
    pp=path_files{ee};
    if ~exist(p.dataDir)
        mkdir(p.dataDir);
    end
    D_in=dir([p.dataDir,'all_files_all*']);
    load([p.dataDir,'all_files_all_tracked_',num2str(length(D_in))]);
        %loop over conditions
        for ww=1:length(wtf_m)
            wtf=wtf_m{ww};
            %Finding_pos to use
            frame_start=f_start_m(ww);
            frame_end=f_end_m(ww);

            D=whos('Bacillus*');
            Dc={D.name};
            Dcc=char(Dc);
            Dcc_pos=Dcc(:,end-4:end-3);
            Dcc_pos_n=str2num(Dcc_pos);
            good_i=Dcc_pos_n>=frame_start&Dcc_pos_n<=frame_end;
            good_pos=Dcc(good_i,:);
            %concentrating data
            better_concentration_of_data_all_cells_2019_06_19_v4;
        end
        %saving data
        save([p.dataDir,wtf,'_mat_',date1],'out');
        clear('out');
    end
end