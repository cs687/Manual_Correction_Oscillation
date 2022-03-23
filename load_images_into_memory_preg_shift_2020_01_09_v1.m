function [Lc_m,rreg_m,yreg_m,preg_m]=load_images_into_memory_preg_shift_2020_01_09_v1(p,poslist,posctr,range)
%Script to load all images into memory 


disp(poslist(posctr));

segdir = p.segmentationDir;
    
D = dir([segdir '*.mat']); 
D = {D.name};
if length(range)<2
    range_do=1:length(D);
elseif length(range)>length(D)
    range_do=1:length(D);
else
    range_do=range;
end

mat_zero_size=length(range_do);
    
    for im_ind=range_do
        if im_ind==1
             Lc = load([segdir D{im_ind}],'Lc');
             L= Lc(im_ind).('Lc');
             
             %kill small objects
             props=regionprops(L,'Perimeter','Area');
             val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
             f=find(val<0.30);
             %f=find(val<0.25);
             L=ismember(L,f);
             L = bwlabel(L,4);

             %killing small cells
             r = regionprops(L,'Area');
             flittle = find([r.Area]>50);
             bw2 = ismember(L, flittle);
             L2 = bwlabel(bw2,4);
             
             Lc= L2;
             im_s=size(Lc);
             Lc_m=zeros([im_s,mat_zero_size]);
             Lc_m(:,:,im_ind)=Lc;
             %%%Loading yimages
             yreg_m=zeros([im_s,mat_zero_size]);
             yreg = load([segdir D{im_ind}],'yreg');
             yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
             %%%Loading rimages
             rreg_m=zeros([im_s,mat_zero_size]);
             rreg = load([segdir D{im_ind}],'rreg');
             rreg_m(:,:,im_ind)=double(rreg(1).('rreg'));
%              if sum(ismember(colors,'c'))
%                 creg_m=zeros([im_s,mat_zero_size]);
%                 creg = load([segdir D{im_ind}],'creg');
%                 creg_m(:,:,im_ind)=double(creg(1).('creg'));
%              end
             %%%Loading pimages
             preg_m=zeros([im_s,mat_zero_size]);
             preg = load([segdir D{im_ind}],'preg');
             preg_m(:,:,im_ind)=double(preg(1).('preg'));           
             
        else
            %Add to Seg stack
            Lc = load([segdir D{im_ind}],'Lc'); 
            
            L= Lc(1).('Lc');
             
             %kill small objects
             props=regionprops(L,'Perimeter','Area');
             val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
             f=find(val<0.30);
             %f=find(val<0.25);
             L=ismember(L,f);
             L = bwlabel(L,4);

             %killing small cells
             r = regionprops(L,'Area');
             flittle = find([r.Area]>50);
             bw2 = ismember(L, flittle);
             L2 = bwlabel(bw2,4);
        
            Lc_m(:,:,im_ind) = L2;
            %Add to y stack
            yreg = load([segdir D{im_ind}],'yreg');
            yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
            %Add to r stack
            rreg = load([segdir D{im_ind}],'rreg');
            rreg_m(:,:,im_ind)=double(rreg(1).('rreg'));
            % Add to c stack
%             if sum(ismember(colors,'c'))
%                creg = load([segdir D{im_ind}],'creg');
%                creg_m(:,:,im_ind)=double(creg(1).('creg'));
%             end
            %Add to p stack
            preg = load([segdir D{im_ind}],'preg');
            preg_m(:,:,im_ind)=double(preg(1).('preg'));    
        end
    end
    disp('aa');
    