function [preg_m]=load_phase_for_add_phse(p)
%Script to load all images into memory 

imgDir=p.rootDir;

D=dir([imgDir,p.movieName,'-p-*']);

for i=1:length(D)
    preg_m(:,:,i)=imread([imgDir,D(i).name]);
end

%disp(a);
channels=dlmread([p.rootDir,'channel_pos_',D(1).name(end-11:end-10),'.txt']);

D2=dir([p.dateDir,strrep(p.movieName,'-','_'),'*']);
if length(channels)==length(D2)
    for j=1:length(D2)
        load([p.dateDir,D2(j).name,'\data\',D2(j).name,'-tracks']);
        s(1).preg=preg_m(:,channels(j)-20:channels(j)+20,:);
        save([p.dateDir,D2(j).name,'\data\',D2(j).name,'-tracks.mat'],'s');
    end
else
    errordlg('FUCK!');
end

    
    


% 
% disp(poslist(posctr));
% 
% segdir = p.segmentationDir;
%     
% D = dir([segdir '*.mat']); 
% D = {D.name};
% if length(range)<2
%     range_do=1:length(D);
% elseif length(range)>length(D)
%     range_do=1:length(D);
% else
%     range_do=range;
% end
% 
% mat_zero_size=length(range_do);
%     
%     for im_ind=range_do
%         if im_ind==1
% %              Lc = load([segdir D{im_ind}],'Lc');
% %              L= Lc(im_ind).('Lc');
% %              
% %              %kill small objects
% %              props=regionprops(L,'Perimeter','Area');
% %              val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
% %              f=find(val<0.30);
% %              %f=find(val<0.25);
% %              L=ismember(L,f);
% %              L = bwlabel(L,4);
% % 
% %              %killing small cells
% %              r = regionprops(L,'Area');
% %              flittle = find([r.Area]>50);
% %              bw2 = ismember(L, flittle);
% %              L2 = bwlabel(bw2,4);
% %              
%              Lc= L2;
%              im_s=size(Lc);
% %              Lc_m=zeros([im_s,mat_zero_size]);
% %              Lc_m(:,:,im_ind)=Lc;
% %              %%%Loading yimages
% %              yreg_m=zeros([im_s,mat_zero_size]);
% %              yreg = load([segdir D{im_ind}],'yreg');
% %              yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
%              %%%Loading rimages
%              preg_m=zeros([im_s,mat_zero_size]);
%              preg = load([segdir D{im_ind}],'preg');
%              preg_m(:,:,im_ind)=double(preg(1).('preg'));
% %              if sum(ismember(colors,'c'))
% %                 creg_m=zeros([im_s,mat_zero_size]);
% %                 creg = load([segdir D{im_ind}],'creg');
% %                 creg_m(:,:,im_ind)=double(creg(1).('creg'));
% %              end
%         else
%             %Add to Seg stack
%             Lc = load([segdir D{im_ind}],'Lc'); 
%             
%             L= Lc(1).('Lc');
%              
%              %kill small objects
%              props=regionprops(L,'Perimeter','Area');
%              val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
%              f=find(val<0.30);
%              %f=find(val<0.25);
%              L=ismember(L,f);
%              L = bwlabel(L,4);
% 
%              %killing small cells
%              r = regionprops(L,'Area');
%              flittle = find([r.Area]>50);
%              bw2 = ismember(L, flittle);
%              L2 = bwlabel(bw2,4);
%         
%             Lc_m(:,:,im_ind) = L2;
%             %Add to y stack
%             yreg = load([segdir D{im_ind}],'yreg');
%             yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
%             %Add to r stack
%             rreg = load([segdir D{im_ind}],'rreg');
%             rreg_m(:,:,im_ind)=double(rreg(1).('rreg'));
%             % Add to c stack
% %             if sum(ismember(colors,'c'))
% %                creg = load([segdir D{im_ind}],'creg');
% %                creg_m(:,:,im_ind)=double(creg(1).('creg'));
% %             end
%         end
%     end