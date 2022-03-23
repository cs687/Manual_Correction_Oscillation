function theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel)
%D=dir('Bacillus-*');
%p=initschnit_check(D(1).name,'C:\Users\christian.schwall\Desktop\2018-01-09\2\subAuto\To_Check');
%clear cenx2 ceny2;
%color_y=1;
%traces_y=1;
%frac_c_tot=50;
%frac_c_start=1;

%D2=dir([p.segmentationDir,'*.mat']);
%j=1;
%im_i=load([p.segmentationDir,D2(j).name],'LNsub');

if f_channel=='s'
    z=s(1).Lc_c;
elseif f_channel=='p'
    z=s(1).preg;
elseif f_channel=='r'
    z=s(1).rreg;
elseif f_channel=='y'
    z=s(1).yreg;
end

im_s=size(z);
%im_s(2)=41;

%z=zeros(im_s(1),im_s(2),length(D2));

% for j=1:length(D2);
%     im_i=load([p.segmentationDir,D2(j).name],'LNsub');
%     z(:,:,j)=im_i.LNsub(:,channels(c)-20:channels(c)+20);
% end
%z=Lc_c;
%z=p.z;
if frac_c_start>max_frames-frac_c_tot
    frac_c_tot=max_frames-frac_c_start+1;
end

mymap = [1, 0, 0
        1, 1, 0 
        0, 1, 1
        1, 1, 1
        1, 0, 1
        0, 1, 0];
if color_y==1 && f_channel=='s';
    tile=zeros(im_s(1),im_s(2)*frac_c_tot,3);
else
    tile=zeros(im_s(1),im_s(2)*frac_c_tot);
end
for k=frac_c_start:(frac_c_tot+frac_c_start-1)
    L=z(:,:,k);
    if color_y==1 && f_channel=='s';
        r=regionprops(L,'Centroid');
        cen=reshape([r.Centroid],[2,length(r)])';
        ceny=cen(:,2);
        [cens,c_i]=sort(ceny);
        mymap2=zeros(length(cens),3);
        for i=1:length(cens)
            if ~isnan(ceny(c_i(i)))
                repeat_ind=mod(i,6);
                if repeat_ind==0
                    repeat_ind=6;
                end
                mymap2(c_i(i),:)=mymap(repeat_ind,:);
            end
        end
        L2=ind2rgb(L, mymap2);
        L3=L;
        tile2(:,1+im_s(2)*(k-frac_c_start):im_s(2)*(k-frac_c_start+1),:)=L3;
    else
        L2=L;
    end
    tile(:,1+im_s(2)*(k-frac_c_start):im_s(2)*(k-frac_c_start+1),:)=L2;  
end
%figure; 
if color_y==1 && f_channel=='s';
    theimLc=tile2;
    imshow(tile);
elseif f_channel=='s';
    theimLc=tile;
    imshow(tile);
else
    theimLc=tile;
    imshow(tile,[]);
end

frames={s.frames};
for i=1:length(frames)
    goodones(i)=sum(ismember(frames{i},frac_c_start:frac_c_start+frac_c_tot));
    ind_g=goodones>0;
end
map=hsv;
% plot trace onto image
if traces_y==1
    for j=1:length(s)
        if ind_g(j)==1
            for i=1:length(s(j).cenx) 
                cenx2(i)=s(j).cenx(i)+im_s(2)*(s(j).frames(i)-frac_c_start); 
            end
            ceny2=s(j).ceny;
            if s(j).P>0
                cenx2=[s(s(j).P).cenx(end)+im_s(2)*(s(s(j).P).frames(end)-frac_c_start),cenx2];
                ceny2=[s(s(j).P).ceny(end),ceny2];
            end        
            %hold on; plot(cenx2,ceny2,'-','Linewidth',2,'color',rand(1,3));
            hold on; plot(cenx2,ceny2,'-','Linewidth',2,'color',map(randi(256,1,1),:));
            clear cenx2 ceny2;
        end
    end
end
hold off;