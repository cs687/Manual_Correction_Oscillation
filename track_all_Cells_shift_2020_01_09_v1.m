function p=track_all_Cells_shift_2020_01_09_v1(p,range1)

% if ~exist(range1)
%     imgdir=p.imageDir;
%     %Finding basename
%     basenamedir = dir([imgdir filesep '*-01-y-*.tif']);
%     range=length(basenamedir);
% end

colors='ry';
poslist=get_poslist(p);
imgDir=p.imageDir;

%parfor posctr=1:length(poslist)
%parfor posctr=15:15
%for posctr=16:length(poslist)
for posctr=1:length(poslist)
%parfor posctr=1:length(poslist)
    %load all frames into the memory
    p = initschnitz(poslist{posctr},'2016-06-14','bacillus','rootDir',imgDir,'imageDir',imgDir);
    run_track_all_cells_shift_2020_01_09(p,poslist,posctr,colors,range1)    
end
