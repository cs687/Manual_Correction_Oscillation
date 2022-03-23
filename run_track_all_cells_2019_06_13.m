function run_track_all_cells_2019_06_13(p,poslist,posctr,colors,range)   
% This funtion tracks all cells in the channl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load all images of position into memory
[Lc_m,rreg_m,yreg_m]=load_images_into_memory_2018_04_04_v4(p,poslist,posctr,range);

    if exist('Lc_m')
        %load channel positions
        if exist([p.imageDir,'channel_pos_',poslist{posctr}(10:11),'.txt'])
            channels=dlmread([p.imageDir,'channel_pos_',poslist{posctr}(10:11),'.txt']);
            %Loop over all channels of one stage position
            for c=1:length(channels)
                disp(c);
                %tracking core function
                track_core_2019_06_13_v7m(p,Lc_m,yreg_m,rreg_m,channels,c,colors,poslist,posctr);
            end
        end
    end