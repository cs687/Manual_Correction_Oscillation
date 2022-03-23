function add_phase_to_track_function_to_use_part(p)
% This function adds the phase images to each position. This is not done
% during the tracking or the segmentation. Should be changed at one
% point.... For now this is the shit.
imgDir=p.rootDir;
date1=p.movieDate;

D=dir([p.rootDir,'*-*-p-001.tif']);

for i=1:length(D)
    p=initschnitz(D(i).name(1:end-10),date1,'bacillus', 'rootDir', imgDir, 'imageDir',imgDir);
    disp(D(i).name(1:end-10));
    a=load_phase_for_add_phse(p);
end
