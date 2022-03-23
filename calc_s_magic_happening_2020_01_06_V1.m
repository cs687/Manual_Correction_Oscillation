function calc_s_magic_happening_2020_01_06_V1(p,wtf_m,f_start_m,f_end_m,out_name)

path_files={p.rootDir};
date1=p.movieDate;

for ee=1:length(path_files)
    %for ee=6:length(path_files)
    pp=path_files{ee};
%     if ~exist([pp,'\Data'])
%         mkdir([pp,'\Data'])
%     end
    if ~exist(p.dataDir)
        mkdir(p.dataDir);
    end
    p.dataDir

    %D_in=dir([pp,'Data\all_files_all*']);
    D_in=dir([p.dataDir,'all_files_all*']);
    %load([pp,'Data\all_files_all_tracked_',num2str(length(D_in))]);
   %if  exist([p.dataDir,'all_files_all_tracked_',num2str(length(D_in)),'.mat'])
        load([p.dataDir,'all_files_all_tracked_',num2str(length(D_in))]);
    %     cd(pp);
    %     pause(1);
    %     date1=pp(end-9:end);
        %parameters

        for ww=1:length(wtf_m)
            wtf=wtf_m{ww};
            frame_start=f_start_m(ww);
            frame_end=f_end_m(ww);

            D=whos('Bacillus*');
            Dc={D.name};
            Dcc=char(Dc);
            Dcc_pos=Dcc(:,end-4:end-3);
            Dcc_pos_n=str2num(Dcc_pos);

            if frame_start==1
                good_i=Dcc_pos_n<=frame_end;
            else
                good_i=Dcc_pos_n>=frame_start&Dcc_pos_n<=frame_end;
            end

            good_pos=Dcc(good_i,:);

            %start here

            %clear('Dc','Dcc','Dcc_pos','Dcc_pos_n','good_i','frame_start','frame_end')
    %         if ~isempty(good_pos)
    %             s_out=[];
    % 
    %             for i=1:size(good_pos,1);
    %             %for i=1:4
    %                 %load(Dcc(i,:));
    %                 %load(good_pos(i,:));
    %                 eval(['s=',good_pos(i,:),';']);
    %                 rmfield(s,'Lc_c');
    %                 if isfield(s,'preg')
    %                     rmfield(s,'preg');
    %                 end
    %                 rmfield(s, 'yreg');
    %                 rmfield(s, 'rreg');
    %                 s(1).Lc_c=[];
    %                 s(2).Lc_c=[];
    %                 s(3).Lc_c=[];
    %                 s(1).yreg=[];
    %                 s(1).rreg=[];
    %                 if isfield(s,'preg')
    %                     s(1).preg=[];
    %                 end
    %                 %eval([D(i).name(1:end-4),'=s;']);
    %                 %eval([good_pos(i,1:end-4),'=s;']);
    %             %    calc_promo_17_01_21_c
    %             %     s=calc_promo_for_schnitz_edit(s);
    %             %     if i==1;
    %             %         s_out=s;
    %             %     else
    %             %         kk=length(s_out);
    %             %         for i=1:length(s)
    %             %             s(i).P=s(i).P+kk;
    %             %             if s(i).E>0
    %             %                 s(i).E=s(i).E+kk;
    %             %             elseif s(i).D>0
    %             %                 s(i).D=s(i).D+kk;
    %             %             end
    %             %         end
    %             %         s_out=[s_out,s];
    %             %     end
    % 
    % 
    %             end
    % 
    %             D=whos('B*');
    %             for i=1:length(D)
    %     %         surv={};
    %     %         for i=23:length(D)
    %                 if i==1
    %                     surv={};
    %                 end
    %                 %ii=1;
    %                 %for ii=1:length(D)
    %                 if length(D)>0
    %                     s=eval(D(i).name);
    %                     %if length(s)>30
    % 
    %                         s=renumberschnitzes_concentrate(s);
    %                         s_new=promoterActivity_final_bg_2018_05_16(s,0.05,200,200);
    %                         eval(['s_all.',D(i).name,'=s_new;']);
    %                         try surv=trimming_tree_2018_05_15_only_v3_pseudo_M_only_M_v2(s,surv); end
    %                         %tree_2018_05_15_only_v3(s,surv);
    %                         %surv=trimming_tree_2018_05_15_only_v3_pseudo_M(s,surv);
    %                     %end
    %                 end
    %             %    clear(D(ii).name)
    % 
    %             end
    % 
    %             del1=whos('B*');
    %             if ~exist([pp,'\Data'])
    %                 mkdir([pp,'\Data']);
    %             end
    %             save([pp,'\Data\',wtf,'_all_cells_track',date1], '-struct','s_all');
    %             aa={del1.name};
    %             clear(aa{:},'s_all');
    %             super_s=[];
    %             for o=1:length(surv)
    %                 if o==1
    %                     if isfield(surv{o},'preg')
    %                         a=rmfield(surv{o},'preg');
    %                     else
    %                         a=surv{o};
    %                     end
    %                     %super_s=surv{o};
    %                     super_s=a;
    %                     clear a
    %                 else
    %                     kk=length(super_s);
    %                     s=surv{o};
    %                     if isfield(surv{o},'preg')
    %                         s=rmfield(surv{o},'preg');
    %                     end
    %                     for i=1:length(s)
    %                         if s(i).P>0
    %                             s(i).P=s(i).P+kk;
    %                         end
    %                         if s(i).E>0
    %                             s(i).E=s(i).E+kk;
    %                         end
    %                         if s(i).D>0
    %                             s(i).D=s(i).D+kk;
    %                         end
    %                     end
    %                     super_s=cat(2,super_s,s);
    %                     clear s;
    %                 end
    %             end     
    % 
    %             %out=concentrate_schnitz_func_18_05_17(surv);
                %better_concentration_of_data_all_Tracked_2019_06_19_v3
                better_concentration_of_data_all_Tracked_2019_10_13_v3;

                % if ~exist([pp,'\Data'])
                %     mkdir([pp,'\Data']);
                % end
                %save([pp,'\Data\',wtf,'_mat_',date1],'out');
               %%% save([p.dataDir,wtf,'_mat_',date1],name{:}); last used
               save([p.dataDir,out_name{ww}],name{:});
                %save([p.dataDir,wtf,'_s_',date1],'super_s');
                %save([p.dataDir,wtf,'_s_cell_',date1],'surv');
                clear('out','super_s','suris_there_another_prob_with_killing_data_2019_06_12_v4v','s_all');
        end
       % end
end
    
end