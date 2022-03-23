function generatating_s_from_checked_v8_path_all_cells(p,f_start_m,f_end_m,wtf_m)
%This function compresses the output data into either matrices a super s
%structure or cells.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
% p: p structure
% f_start_m: start of position with same condition as a vector e.g. 
%           f_start_m=[1,31,];
% f_end_m: end of position with same condition as a vector e.g. 
%            f_end_m=[30,60];
% wtf_m: name of condition; cell with strings e.g.
            % wtf_m={'1ug_Lyso','05ug_Lyso'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path_files={p.rootDir};


%calc_s_magic_happening(path_files,wtf_m,f_start_m,f_end_m);
calc_s_magic_happening_all_cells_2019_09_30_V1(p,wtf_m,f_start_m,f_end_m);
%calc_s_magic_happening_all_cells(path_files,wtf_m,f_start_m,f_end_m);