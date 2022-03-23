%load([p.dataDir,'all_files_all_tracked_',num2str(length(D_in))]);
%D=whos('B*');
num_max_frames=300;
num_files=1000;

D=good_pos;
for i=1:size(D,1)
    disp(num2str(i));
   % s=eval(D(i).name);
    s=eval(D(i,:));
    if length(s)> 1 && ~isempty(s(2).frames)
        %[frames_p,MY_p,MR_p,len_p,wid_p,gr_p,gr_no_conncet_p,ceny_p,cenx_p]=concentrate_better_killing_with_elong_2019_06_12_v1(s);
%         try [out]=concentrate_better_killing_with_elong_promo_2019_06_12_v1(s);
        try [out]=concentrate_better_killing_with_elong_promo_2019_10_13_v1(s);
        catch
            break;
        end
        name=fieldnames(out);
        if i==1;
            for uu=1:length(name)
                if~exist(name{uu})
                    eval([name{uu},'=nan(num_max_frames,num_files);']);
                end
            end
        end
        for oo=1:length(fieldnames(out))
             eval([name{oo},'(1:length(out.',name{oo},'),i)=out.',name{oo},';']);
        end
    end
end




