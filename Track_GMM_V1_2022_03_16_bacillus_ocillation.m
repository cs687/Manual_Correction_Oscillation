function Track_GMM_V1_2022_03_16_bacillus_ocillation(in_path,varargin)
% Sample input:
% Track_GMM_V1_2022_03_16_bacillus_ocillation(in_path, 0,0,1);
%'do_track' ,add_phase,get_channels_to_check,copy_files,

%default settings
do_track=0;
add_phase=0;
get_channels_to_check=0;
copy_files=0;
generate_s_from_checked=0;
date_use='2021-11-03';


if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'do_track')
            do_track=varargin{i+1};
        elseif strcmp(varargin{i},'add_phase')
            add_phase=varargin{i+1};
        elseif strcmp(varargin{i},'get_channels_to_check')
            get_channels_to_check=varargin{i+1};
        elseif strcmp(varargin{i},'copy_files')
            copy_files=varargin{i+1};
        elseif strcmp(varargin{i},'generate_s_from_checked')
            generate_s_from_checked=varargin{i+1};
        elseif strcmp(varargin{i},'date_use')
            date_use=varargin{i+1};
        end
    end
end


% Getting data to track

first_pos=29;
last_pos=35;
% first_pos=24;
% last_pos=45;

num_pos=123;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tracking and correcting all cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in this part all cells in the channel are track. It might still have
% bugs. So please be careful.

% 1. Tracing
p = initschnitz('Bacillus-01',date_use,'bacillus','rootDir',in_path,'imageDir',in_path);
p.dataDir=[p.rootDir,'Data\'];
if ~exist(p.dataDir) 
    mkdir(p.dataDir);
end

if do_track==1
    D=dir([p.imageDir,'*-01-p-*.tif']);
    range=1:length(D);
    p=track_all_Cells_2019_06_13_v2_parv4_3(p,range);

    %p=track_all_Cells_shift_pos_2020_01_09_v1(p,range1,[16:30])
    p=track_all_Cells_shift_2020_01_09_v1(p,range);

    %p=track_all_Cells_2019_06_13_v2_parv4_3_part2(p,range,[24:45]);
end

% 2. Adding Phase image
% this step is not criticl
if add_phase==1
    add_phase_to_track_function_to_use_part(p);
end

% 3. Getting positions to check
if get_channels_to_check==1
    get_channels_to_check_GMM_2019_10_11_v1(p,first_pos,last_pos,num_pos);
    %get_channels_to_check_GMM_2019_06_13_v1_check_if_done(p,first_pos,last_pos,num_pos);
end
% 4. going trough schnitzes
p.dataDir=[p.rootDir,'Data\'];
path_check=[p.dataDir,'names_to_check_',num2str(first_pos),'-',num2str(last_pos),'.mat'];
%go_through_data_2019_10_11_GMM_v1(path_check,p);
go_through_data_2020_01_21_GMM_v1(path_check,p);


% 5. copying_all_corrected_trace_into_one_file
if copy_files==1
    copy_files_one_file_2019_10_10_v1(p);
end

% 6. concentrating all files
% f_start_m={1,21};
% f_end_m={20,41};
% wtf_m={'all_files_all_tracked_6'};
% out_name={'JLB224_MPA_to_MPA_and_EtoH2','JLB224_EtoH2'};
if generate_s_from_checked==1
    f_start_m=[1];
    f_end_m=[20];
    wtf_m={'all_files_all_tracked_3'};
    out_name={'JLB224_MPA'};
    generatating_s_from_checked_v8_path_2020_01_06_2(p,f_start_m,f_end_m,wtf_m,out_name);
    generatating_s_from_checked_v8_path_all_cells(p,f_start_m,f_end_m,out_name);
end
%generatating_s_from_checked_v7_path(p,f_start_m,f_end_m,wtf_m);
%generatating_s_from_checked_v8_path(p,f_start_m,f_end_m,wtf_m);

%generatating_s_from_checked_v6_path_uncorrect_time_2019_08_19



