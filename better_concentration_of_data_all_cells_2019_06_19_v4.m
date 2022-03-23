%load([p.dataDir,'all_files_all_tracked_',num2str(length(D_in))]);
%D=whos('B*');
num_max_frames=300;
num_files=1000;

D=good_pos;
for i=1:size(D,1)
    if i==1
        out=[];
    end
    disp(num2str(i));
   % s=eval(D(i).name);
    s=eval(D(i,:));
    if length(s)> 1 && ~isempty(s(2).frames)
         s=promoterActivity_final_bg_2018_05_16(s,0.05,200,200);
         s=renumberschnitzes_concentrate2(s);
        %[frames_p,MY_p,MR_p,len_p,wid_p,gr_p,gr_no_conncet_p,ceny_p,cenx_p]=concentrate_better_killing_with_elong_2019_06_12_v1(s);
        try out=trimming_tree_2018_07_03_v1_all_cells2_func2(s,out);
        catch
            break;
        end
%         name=fieldnames(out);
%         if i==1;
%             for uu=1:length(name)
%                 if~exist(name{uu})
%                     eval([name{uu},'=nan(num_max_frames,num_files);']);
%                 end
%             end
%         end
%         for oo=1:length(fieldnames(out))
%              eval([name{oo},'(1:length(out.',name{oo},'),i)=out.',name{oo},';']);
%         end
%         save_yes=1;
    else
        save_yes=0;
    end
end




