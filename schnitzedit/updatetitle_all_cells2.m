function updatetitle_all_cells2;

global mousepos theimLc mainfig curschnitz dispframes curapproved max_frames c_width movie_name;

numstr='';

xy = round(mousepos(1,1:2));
 im_s=size(theimLc,2);
 
 if max(dispframes)<=max_frames
     if length(dispframes(1):max_frames)>50
         num_frames=length(dispframes);
     else
         num_frames=length(dispframes(1):max_frames);
     end     
 end
 
 
 %num_frames=length(dispframes);
c_width2=im_s/num_frames;
 [mfr, mx, my] = mouse2coords2(xy, c_width2);
if all(xy>0) & (xy(2)<size(theimLc,1)) & (xy(1)<size(theimLc,2)),
    cellno = theimLc(xy(2),xy(1));
    %     name = get(mainfig,'name');
    cellnumstr = '; cell # '; cellnumstrlen=length(cellnumstr);
    %     frnumstr = '; frame # '; frnumstrlen=length(frnumstr);
    %     f = findstr(name,cellnumstr);
   
    
    
    frame_ind = floor(xy(1)/c_width)+1;
%     if frame_ind<1
%         frame_ind=1;
%     elseif frame_ind>num_frames;
%         frame_ind=num_frames;
%     end
    %frame=dispframes(frame_ind);
    if length(dispframes)<mfr
        frame=dispframes(end);
    else
        frame=dispframes(mfr);
    end
    
    numstr = num2str(cellno);
    %     frstr = num2str(mfr);
    %     if isempty(f),
    %         name = cat(2,name,cellnumstr,numstr);
    %     else
    %         name = cat(2,name(1:f+cellnumstrlen),numstr);
    %     end;
    %     set(mainfig,'name',name);
else
    frame=0;
    num_frames=length(dispframes);
end;

if curapproved,
    appchar = '*';
else
    appchar = '-';
end;





set(mainfig,'name',[appchar,' Pos: ',movie_name,' Schnitz: ',...
    num2str(curschnitz),', frames ',num2str(dispframes(1)),...
    '...',num2str(dispframes(end)),'; cell: ',numstr,' Frame:',num2str(frame),' #frames:',num2str(num_frames)]);
pause(0.00001);

function [fr,x,y] = mouse2coords2(axy,channel_width);

ax  = axy(1);
ay  = axy(2);

% sqx = ceil(ax / winsize);
% sqy = ceil(ay / winsize);

%fr = (sqy-1) * numcols + sqx;
fr = ceil(ax/channel_width);

x = ax;
y = ay;