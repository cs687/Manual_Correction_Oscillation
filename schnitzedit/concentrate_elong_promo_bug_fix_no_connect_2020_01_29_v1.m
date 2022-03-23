function [out]=concentrate_elong_promo_bug_fix_no_connect_2020_01_29_v1(s)

%s=renumberschnitzes_concentrate(s);

%[frames_all,MR_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','MY');
[~,MY_all,~, ~, ~]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','MY');
% [frames_all,MR_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','MR');
% 
% [frames_all,cenx_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','cenx');
 [frames_all,ceny_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','ceny');
% 
% [frames_all,len_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','len');
% [frames_all,wid_all,Pout2, Mout2, Dout2]=plotschnitzme_2019_06_12_no_ploy_5(s,'frames','wid');




ind_cells=sum(~isnan(MY_all));
frames_longest_trace=max(ind_cells);
f=find(ind_cells==frames_longest_trace);

[~, out_trace_ind]=min(ceny_all(frames_longest_trace,f));

which_trace=f(out_trace_ind);
% Mout2_pre=Mout2(2:end,:);
% Mout2_pre(Mout2_pre==0)=nan;
% Mout2(2:end,:)=Mout2_pre;
% 
% Dout2_pre=Dout2(2:end,:);
% Dout2_pre(Dout2_pre==0)=nan;
% Dout2(2:end,:)=Dout2_pre;

Mout2(Mout2==0)=nan;
Dout2(Dout2==0)=nan;
last_schnitz_pre_P=find(isnan(Pout2(:,which_trace)));
last_schnitz_pre_M=find(isnan(Mout2(:,which_trace)));
last_schnitz_pre_D=find(isnan(Dout2(:,which_trace)));
%finding ID of last frame
if length([s(Dout2(last_schnitz_pre_D(1)-1,which_trace)).frames])>length([s(Mout2(last_schnitz_pre_M(1)-1,which_trace)).frames])
    indp=[Pout2(2:last_schnitz_pre_P(1)-1,which_trace);Dout2(last_schnitz_pre_D(1)-1,which_trace)];
    P_use=[Pout2(1:last_schnitz_pre_P(1)-1,which_trace);Dout2(last_schnitz_pre_D(1)-1,which_trace)];
else
    indp=[Pout2(2:last_schnitz_pre_P(1)-1,which_trace);Mout2(last_schnitz_pre_M(1)-1,which_trace)];
    P_use=[Pout2(1:last_schnitz_pre_P(1)-1,which_trace);Mout2(last_schnitz_pre_M(1)-1,which_trace)];
end

 
 ind_use=indp(~isnan(indp)&indp>0);
 
 s=promoterActivity_final_bg_2018_05_16(s,0.05,200,200);
 s_use=s(ind_use);
 
 for qq=1:length(s_use)
%      if isempty(length(s_use(qq).frames))
%          s_use(qq).cell_cycle=nan;
%      else
         s_use(qq).cell_cycle=length(s_use(qq).frames);
%      end
     s_use(qq).frame_end=s_use(qq).frames(end);
 end
 
 

MY=MY_all(:,f(out_trace_ind));
out.MY=MY(~isnan(MY));
out.frames=frames_all(:,f(out_trace_ind));
out.len=[s_use.len];
out.wid=[s_use.wid];
out.ceny=[s_use.ceny];
out.cenx=[s_use.cenx];
out.MR=[s_use.MR];

out.last_frame=[s_use.frame_end];
out.cell_cycle=[s_use.cell_cycle];
out.framesMid=[s_use.framesMid];
out.polylen=[s_use.polylen];
out.len_smooth=[s_use.len_smooth];
out.dpolylen=[s_use.dpolylen];
out.dlen_smooth=[s_use.dlen_smooth];
out.MY_smooth=[s_use.MY_smooth];
out.MR_smooth=[s_use.MR_smooth];
out.dMY_smooth=[s_use.dMY_smooth];
out.dMR_smooth=[s_use.dMR_smooth];
out.mu=[s_use.mu];
out.AY=[s_use.AY];
out.AR=[s_use.AR];
out.AR=[s_use.ARlen];
out.AYlen=[s_use.AYlen];

%MR=MR_all(:,f(out_trace_ind));
%len=len_all(:,f(out_trace_ind));
%wid=wid_all(:,f(out_trace_ind));
%ceny=ceny_all(:,f(out_trace_ind));
%cenx=cenx_all(:,f(out_trace_ind));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating growth rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%0. Generating s with only mothers and sisters. The sister will have only
%one frame

%1. Combine all mother and sister cells which are not followed

%ind=[Pout2(:,f(out_trace_ind)),Dout2(:,f(out_trace_ind))];
%P_use=[s_use.P];
M_use=[s_use.D];
D_use=[s_use.E];

ind_pre=sort(unique([P_use(2:end);M_use';D_use']));
ind=ind_pre(~isnan(ind_pre));

%ind=sort([Pout2(2,f(out_trace_ind));Mout2(1:end-1,f(out_trace_ind));Dout2(:,f(out_trace_ind))]);
fields=fieldnames(s);

ind=ind(ind>0);

%2. Loop over all mothers and sisters and compress the s structure. From
%the output s_pseud the growth rate is then calculated.

%Making vector with parent cells as mother cells.
p_vector=nan(length(ind),1); 
p_vector(1:2)=P_use(2:3); 
for i=4:length(P_use); 
    p_vector(i*2-4)=P_use(i);
end
f=find(isnan(p_vector));

%Adding the correct daugther cell
for i=1:length(f) 
    if ismember(p_vector(f(i)-1),M_use); 
        p_vector(f(i))=p_vector(f(i)-1)+1;
    else
        p_vector(f(i))=p_vector(f(i)-1)-1;
    end;
end;

ind=p_vector;

% for i=1:sum(~isnan(p_vector))
%     if i==1 %the first one is special
%         s_pseud(i)=s(ind(i));
%         s_pseud(i).P=0;
%         s_pseud(i).D=i+1;
%         s_pseud(i).E=i+2;
%     elseif i==2 % the second schnitz is special too
%         s_pseud(i)=s(ind(i));
%         s_pseud(i).P=1;
%         s_pseud(i).D=i+1;
%         s_pseud(i).E=i+2;  
%     elseif i==3 % so is the third
%         for j=1:length(fields) % this loop cuts the sister which is no longer followed to one frame
%             if ~isempty(eval(['s(ind(i)).',fields{j}]))
%                 eval(['s_pseud(i).',fields{j},'=s(ind(i)).',fields{j},'(1);']);
%             else
%                 eval(['s_pseud(i).',fields{j},'=s(ind(i)).',fields{j},';']);
%             end
%         end
%         s_pseud(i).P=1;
%         s_pseud(i).D=0;
%         s_pseud(i).E=0;  
%     %elseif ismember(ind(i),P_use) % the mother case. 
%     elseif mod(i,2)==0 % the mother case. 
%         s_pseud=[s_pseud,s(ind(i))];
%         s_pseud(i).P=i-2;
%         s_pseud(i).D=i+2;
%         s_pseud(i).E=i+3;
%     else  %the sister case
%         for j=1:length(fields) % this loop cuts the sister which is no longer followed to one frame
%             if ~isempty(eval(['s(ind(i)).',fields{j}]))
%                 eval(['s_pseud(i).',fields{j},'=s(ind(i)).',fields{j},'(1);']);
%             else
%                 eval(['s_pseud(i).',fields{j},'=s(ind(i)).',fields{j},';']);
%             end
%         end
%         s_pseud(i).P=i-3;
%         s_pseud(i).D=0;
%         s_pseud(i).E=0;
%     end
% end

%3. determining which one is mother and saving it in goodones
im_int=10;
% goodones=zeros(length(s_pseud),1);
% for i=1:length(s_pseud)
%     if length(s_pseud(i).frames)>1
%         goodones(i)=true;
%     else 
%         goodones(i)=false;
%     end
% end

%4. calculating the log growth rate as
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % gr= (log(len(2))-log(len(1)))./ im int
% % % gr is the growth rate with a connection between the schnitzes. 
% % % division evens are handles has
% % % gr= log([s(3).len(1)+s(2).len(1)])-log(s(1).len(end))/ im int
% % %
% % % gr_no_connect does not connect the schnitzes instead a nan is inserted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[out.gr,out.gr_no_connect]=growth_rate_2019_06_11_in_script(s_pseud,goodones,im_int);
[out.gr]=growth_rate_2019_06_11_in_script(s_use,p_vector,im_int);


% This is to check whether the mother cell is always larger than the
% daughter cell.

%  mm=1;
% dd=1;
% len_m=[];
% len_d=[];
% for i=1:length(goodones)
%     if goodones(i)==1
%         len_m(mm)=s_pseud(i).len(1);
%         mm=mm+1;
%     else
%         len_d(dd)=s_pseud(i).len(1);
%         dd=dd+1;
%     end
% end

% figure;
% histogram(len_m,[5:5:65]);
% hold on;
% histogram(len_d,[5:5:65]);
% hold off;
% 

% disp('haha');



function [gr]=growth_rate_2019_06_11_in_script(s,p_vector,im_int);
kk=1;
gr=nan(2000,1);
gr2=nan(2000,1);
for i=1:length(s)
    %if goodones(i)==1
        if length(s(i).len)>1 %checking that s has more than one entry and does a loop over the schnitz
            for j=1:length(s(i).len)-1
                gr(kk)=(log(s(i).len(j+1))-log(s(i).len(j)))./im_int;
                %gr2(kk)=(log(s(i).len(j+1))-log(s(i).len(j)))./im_int;
                kk=kk+1;
            end
        

            if i==1 %special case if i is the one 
                gr(kk)=(log(s(2+i).len(1)+s(1+i).len(1))-log(s(i).len(end)))./im_int;
                %gr2(kk)=(log(s(2+i).len(1)+s(1+i).len(1))-log(s(i).len(end)))./im_int;
                kk=kk+1;
            end
            kk=kk+1;

%             %adding last entry to link schnitzes at the end of of each schnitz.
%             if i<length(s)-2&& i~=1
%                 gr(kk)=(log(s(3+i).len(1)+s(2+i).len(1))-log(s(i).len(end)))./im_int;
%                 kk=kk+1;
%             end
        else
            kk=kk+1;
        end
    %end
end
