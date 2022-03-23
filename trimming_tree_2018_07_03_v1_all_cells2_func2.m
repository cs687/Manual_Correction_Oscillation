function out=trimming_tree_2018_07_03_v1_all_cells2_func2(s,out)
%s=s_01_23;
%s=Bacillus_04_01;
%load('\\slcu.cam.ac.uk\Data\Microscopy\teamjl\Chris\movies\killing\2018-01-08\register_im\Data\0ug-1ug-20ug\corrected_traces\surv\s_Bacillus_04_01.mat');
%s=s_Bacillus_02_15;
    s(1).Lc_c=[];
    s(2).Lc_c=[];
    s(1).rreg=[];
    s(1).yreg=[];
    if isfield(s,'preg');
        s(1).preg=[];
    end
done_trace=[];
tree=nan(300,1000);
aa=1;
for i=fliplr(1:length(s))
    %if ~ismember(s(i).E,done_trace) && ~ismember(s(i).D,done_trace)
    if s(i).D==0 || s(i).E==0 || isnan(s(i).D) || isnan(s(i).E)
        kk=i;
        mm=1;
        while kk~=0
            tree(mm,aa)=kk;
            if mm>1
                if tree(mm-1,aa)==tree(mm,aa)
                    disp('uups');
                end
            end
            done_trace(length(done_trace)+1)=s(kk).D;
            done_trace(length(done_trace)+1)=s(kk).E;
            kk=s(kk).P;
            mm=mm+1;
        end
        aa=aa+1;
        clear kk mm
    end
end
all_trace_cell={};
%sum(~isnan(tree(:,1)))
fields=fieldnames(s);
for k=1:length(fields)
    eval([fields{k},'=nan(243,',num2str(sum(~isnan(tree(1,:)))),');']);
end
for i=1:size(tree,2)
    trace_part=tree(:,i);
    trace_part_gi=~isnan(trace_part);
    if sum(trace_part_gi)~=0
        trace_part_num=trace_part(trace_part_gi);
        trace_part_num_sort=flip(trace_part_num);
        part=s(trace_part_num_sort);
        for j=1:length(fields)
            eval([fields{j},'(1:length([part.',fields{j},']),i)=[part.',fields{j},'];']);
        end
    end
end

if ~isempty(out)
    for j=1:length(fields)
        eval(['out.',fields{j},'=[out.',fields{j},',',fields{j},'];']);
    end
else
    for j=1:length(fields)
        eval(['out.',fields{j},'=',fields{j},';']);
    end
end


        


% 
% frames=[s.frames];
% sur_f=max(frames);
% 
% kk=1;
% 
% for i=1:length(s)
%     if sum(s(i).frames==sur_f)>0
%         gs(kk)=i;
%         fs(kk)=find(s(i).frames==sur_f);
%         ps(kk)=s(i).ceny(fs(kk));
%         kk=kk+1;
%     end
% end
% 
% [pss,pss_I]=sort(ps);
% 
% %for j=1:length(pss_I)
% for j=1:1
%     curr_s=gs(pss_I(j));
%     ind=1;
%     tree1(ind)=curr_s;
%     while s(curr_s).P~=0
%         ind=ind+1;
%         curr_s=s(curr_s).P;
%         tree1(ind)=curr_s;
%     end
% end
% %s=promoterActivity_final_bg_cs(s,0.05,200);
% first_m=min(tree1);
% tree_s=sort(tree1);
% curr_s1=first_m;
% fname=fieldnames(s);
% for kk=1:length(tree1)
%     curr_s1=tree_s(kk);
%     out(kk)=s(curr_s1);
% %     %first entry is different
% %     if kk==1
% %         out=s(curr_s1);
% %         if s(curr_s1).D~=0 && ~isnan(s(curr_s1).D)
% %             out(kk).D=kk+1;
% %             %ouf(kk).P=kk;
% %         end
% %         
% %         if s(curr_s1).E~=0 && ~isnan(s(curr_s1).E)
% %             out(kk).E=kk+2;
% %             out(kk+2)=s(s(curr_s1).E);
% %             out(kk+2).D=0;
% %             out(kk+2).E=0;
% %             for tt=1:length(fname)
% %                 if length(eval(['s(s(curr_s1).E).',fname{tt}]))>1
% %                     eval(['out(kk+2).',fname{tt},'=s(s(curr_s1).E).',fname{tt},'(1);']);
% %                 end
% %             end
% %             
% %         end
% %     %last entry is differnt
% %     elseif curr_s1==tree_s(end)
% %         kk=length(out)-1;
% %         out(kk)=s(curr_s1);
% %         out(kk).P=kk-2;
% %     %the rest
% %     else
% %         kk=length(out)-1;
% %         out(kk)=s(curr_s1);
% %         if kk==2
% %             out(kk).P=1;
% %         else
% %             out(kk).P=kk-2;
% %         end
% %         
% %         if s(curr_s1).D~=0 && ~isnan(s(curr_s1).D)
% %             out(kk).D=kk+2;
% %         end
% %         
% %         if s(curr_s1).E~=0 && ~isnan(s(curr_s1).E)
% %             out(kk).E=kk+3;
% %             if s(curr_s1).E>0
% %                 out(kk+3)=s(s(curr_s1).E);
% %                 out(kk+3).D=0;
% %                 out(kk+3).E=0;
% %                 out(kk+3).P=kk;
% % 
% %             for tt=1:length(fname)
% %                 if length(eval(['s(s(curr_s1).E).',fname{tt}]))>1
% %                     eval(['out(kk+3).',fname{tt},'=s(s(curr_s1).E).',fname{tt},'(1);']);
% %                 end
% %             end
% %             end
% %         end
% %         %curr_s1=curr_s1+2;
% %     end
% end
%     
% 
%         
%     
% 
% 
% %disp(pss);