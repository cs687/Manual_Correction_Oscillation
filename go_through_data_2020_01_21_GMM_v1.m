function go_through_data_2019_06_13_GMM_v1(path_check,p)
%This function helps correcting all data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%inputs:
% path_check: this is the path withe names to check e.g
%             \\slcu.cam.ac.uk\data\Microscopy\teamJL_2\Sasha\2019-05-18-Sasha\subAuto\Data\names_to_check_1-3
% date1: folder date names e.g.
%        '2019-06-11';
% imgDir: path with images e.g:
%           '\\slcu.cam.ac.uk\data\Microscopy\teamJL_2\Sasha\2019-05-18-Sasha\subAuto';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important short cuts
% z: switch to phase image
% x: rfp image
% c: yfp image
% w: color code dependet on the position in the channel
% f: black and white image
% t: remove traces
% r: renumber
% s: save 
% q: quit
% shift click: continuation correction
% ctrl slick: division event
% space: move to next frames
% ,: previous frames
% .: next frames
% 
% e: edit/ add correct segmentation (This is standard schnitzcells)
% In edit mode:
% right click on cell: devide cells
% left click on two cells: merge cells
% shift click: remove cell
% a: add a cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Loading data to check
load(path_check);
date1=p.movieDate;
imgDir=p.imageDir;

% Getting good channels
close all;
Ds=check_names;
for oo=1:size(check_names,1)
    Dsc{oo}=check_names(oo,:);
end
Dsc=Dsc';
good_channel=Ds(:,end-4:end);

%Setting posistion and size of windows.
h1=figure(1);
set(h1,'Position',[20,20,350,350]);
h2=figure(2);
set(h2,'Position',[380,20,350,350]);
h3=figure(3);
set(h3,'Position',[740,20,350,350]);
h4=figure(4);
set(h4,'Position',[1100,20,350,350]);


%loop over all channels to check
yy=1;
kk=1;
for i= 1:size(good_channel,1)
    p2 = initschnitz(['Bacillus_',good_channel(i,:)],date1,'bacillus','rootDir',imgDir,'imageDir',imgDir);
    load([p2.tracksDir,'Bacillus_',good_channel(i,:),'-tracks.mat']);
    %s=calc_promo_for_schnitz_edit(s);
    if max([s.frames])>577
          yy=1+yy;
%         s=concentrate_better_killing_with_elong_promo_2019_10_13_v1(s);
%         figure(2); plot([s.AYlen(1:577)]);title('Promoter Activity');
%         figure(1); plot([s.len(1:577)]);title('Len');
%         figure(3); plot([s.MY(1:577)]);title('MY');
%        figure(4); plot([s.gr_no_conncet(1:577)]);title('Growth Rate');
%         %p2 =schnitzedit_all_cells5_with_Edit6_might_be_good_2020_01_07_3(p2);%use for SLPC 250
%         p2 =schnitzedit_all_cells5_with_Edit6_2020_01_27_SLPC23_3(p2);
    else 
        disp(num2str(max([s.frames])));
        kk=kk+1;
    end
end
disp(num2str(yy));

close all;