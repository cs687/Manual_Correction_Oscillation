
function p = schnitzedit_all_cells5_with_Edit6_might_be_good_2020_01_07_3(p,varargin)

global mousepos theimLc mainfig curschnitz dispframes c_width max_frames movie_name curapproved;
%global mousepos mainfig curschnitz dispframes curapproved;

%
% edit lineages one schnitz at a time:
%
% 	I'm enclosing the schnitzedit.m program.
% Here are a few notes on how to use it.  The term "schnitz" refers to
% one element of the schnitzcells array.  It represents a single
% branch of the tree.
%
% 1. Running the program: schnitzedit(schnitzcells, startnum).
% a.    The second argument is optional.  If you include it, the program
% will start showing you the specified schnitznum.  Otherwise it will
% start with the first schnitz.
%
% 2.	Commands when you're running:
% a.    Clicking on a cell takes you to the tree element containing the
% cell you clicked on.
% b.    Shift+Clicking on two cells on neighboring frames connects them
% into a single schnitz.
% b 1/2. Shift+Click on a cell and then on the black part of the next frame
% to terminate the cell lineage.
% c.    Ctrl+Clicking on three cells- a parent on one frame and two
% daughters on the next frame- will create a parent/daughters
% relationship between those cells.
% d.    While hovering over a cell, its number is displayed in the title
% bar.  This is handy.
% e.	Here are some keyboard commands:
%
% i.    , [comma] and . [period] go backward and forward in the schnitz
% sequence.  Enter also goes forward.
%    <space>: approve schnitz, go forward.
%     <ESC>:  disapprove schnitz.
%       J jumps to the next unapproved schnitz.
% ii.   Backspace takes you to the previous frame you were looking at.
% Kind of like clicking the "back" button on a web browser.
% iii.  N opens a new image window, leaving the previous window there
% for you to look at.
% iv.	Q quits.
% v.    A toggles "All Color Mode".  In all-color mode, all the lineages
% are color coded with random colors that are consistent from frame to
% frame (except when the cell divides).
% vi.   E edit segmentation.  This takes you to an image editor for the
% particular frame that your mouse was pointing to when you typed E.
% For image editor commands, see below.
% vii.  X toggles Extend mode on/off.  Extend mode extends the time
% series to 3 frames before and after the first and last frame of the
% schnitz.
% viii. G goes to a specific schnitz number.  You will be asked to
% enter a number in the main command window.
% ix.   C checks for continuity problems.  This essentially looks for
% errors in the tree structure.
% x.   D find Double schnitzes.  This is another error-checking thing.
% You shouldn't need it.
% xi.	R renumbers everything in the schnitz tree.  Not sure if this works.
% xii.  O toggles orphan mode.  In orphan mode, cells with no parents
% light up in blue.
% xiii. B toggles barren mode.  In barren mode, cells with no
% offspring light up green.
% xiv.	A
% xv.   S saves your work.  This is important!  Saving also
% automatically backs up the previous version.
% xvi.  Ctrl+L loads a different schnitz file - you will be asked
% for a filename in the main matlab command window.
% xvii. P finds a likely problem.  Don’t use this - I don’t
% think it works.
% xviii.K enters debugging mode, using the matlab keyboard command...
% 4.	Image editor commands:
% a.	Q quit the image editor and return to the main program.
% b.	G go to a different frame number
% c.	S save
% d.	A add a new cell where the mouse is pointing
% e.	Clicking on two cells joins them together.
% f.	Right-clicking on a cell cuts it at the point you clicked.
% g.	Shift+Click deletes the cell.
%
%
% instructions:
%     Q: Quit
%     G: goto specific schnitz number (prompt for input)
%     .: next schnitz
%     ,: previous schnitz
%     S: segment clicked region.
%
%     Left Click: navigate to the schnitz on which you clicked.
%
% Optional Parameters (varargin):
%
%     'lineageName',filename: this pair of arguments will make schnitzedit
%        load the schnitzcells lineage structure from the given filename
%        instead of the default file, [p.tracksDir p.movieName '_lin.mat'].
%
%     'schnitzNum',value: this pair of arguments makes schnitzedit start
%        displaying/editing the schnitz track number specified by value.

% Variable Name Changes
%   moviename -> p.movieName


%-------------------------------------------------------------------------------
% Parse the input arguments, input error checking
%-------------------------------------------------------------------------------

numRequiredArgs = 1;
if (nargin < 1) | ...
        (mod(nargin,2) == 0) | ...
        (~isSchnitzParamStruct(p))
    errorMessage = sprintf ('%s\n%s\n%s\n',...
        'Error using ==> makeschnitz:',...
        '    Invalid input arguments.',...
        '    Try "help makeschnitz".');
    error(errorMessage);
end

%-------------------------------------------------------------------------------
% Define schntizedit parameters/defaults
%-------------------------------------------------------------------------------

mainfig = 102;
%winsize = 300;
% winsize=1200;
winsize=3200;
%maxwinsize = 600;
%maxwinsize = 2400;
maxwinsize = 5000;
%minwinsize = 150;
% minwinsize =2200;
minwinsize =2200;
numframes = 10;
maxcols = 8;
maxschnitztorylength = 100;
schnitztory = [];
extendmode = 0;
extendxtra = 3;
orphanmode = 0;
barrenmode = 0;
colormode = 0;
c_width = 41;
movie_name=p.movieName;

frac_c_tot=50;
frac_c_start=1;
frac_next=5;
color_y=0;
traces_y=1;


%correction statistics
% corr_stat_on=1;
% if corr_stat_on==1
%     if exist([p.dataDir,'\corr_stat_v1.mat'])
%         load([p.dataDir,'\corr_stat_v1']);
%         corrected_pos=corrected_pos+1;
%     else
%         link_correct=0;
%         div_correct=0;
%         seg_correct=0;
%         corrected_pos=0;
%     end
% end


f_channel='s';

vervar = ver;
for i=1:length(vervar);
    verstr{i}=vervar(i).Name;
end

iptsetpref('imshowborder','tight');
if strcmp(vervar(find(strcmp(verstr,'MATLAB'))).Version,'7.0.4')
    iptsetpref('ImtoolInitialMagnification','adaptive'); % nitzan 2005June25
    iptsetpref('ImshowInitialMagnification',100); % nitzan 2005June25
else
    %iptsetpref('truesizewarning','off'); % nitzan 2005June25
    iptsetpref('ImtoolInitialMagnification',100); % nitzan 2005June25
end
warning('off','Images:initSize:adjustingMag'); % nitzan 2005June25
clear i vervar verstr

lastprobframe = 0;
lastprobnum = 0;
numwins = 10;


%-------------------------------------------------------------------------------
% Override any schnitzcells parameters/defaults given optional fields/values
%-------------------------------------------------------------------------------

% Loop over pairs of optional input arguments and save the given fields/values
% to the schnitzcells parameter structure
numExtraArgs = nargin - numRequiredArgs;
if numExtraArgs > 0
    for i=1:2:(numExtraArgs-1)
        if (~isstr(varargin{i}))
            errorMessage = sprintf ('%s\n%s%s%s\n%s\n',...
                'Error using ==> makeschnitz:',...
                '    Invalid property ', num2str(varargin{i}), ...
                ' is not (needs to be) a string.',...
                '    Try "help makeschnitz".');
            error(errorMessage);
        end
        fieldName = schnitzfield(varargin{i});
        p.(fieldName) = varargin{i+1};
    end
end

% % nitzan 2005June24 addition
% if ~existfield(p,'trackUnCheckedFrames')
%     p.trackUnCheckedFrames = 0;
% end
% % end nitzan 2005June24 addition

if ~existfield(p,'lineageName')
    %p.lineageName = [p.tracksDir,p.movieName,'_lin.mat'];
    p.lineageName = [p.tracksDir,p.movieName,'-tracks.mat'];
    disp(['Loading ',p.lineageName]);

end

lineage = load(p.lineageName);
%s = lineage.schnitzcells;
s = lineage.s;
if ~existfield(s(1),'approved'),
    for i = 1:length(s),
        s(i).approved = 0;
    end;
end;
max_frames=size(s(1).Lc_c,3);
max_frames1=max([s.frames]);
%frames={s.frames};
cell_no_all_schnitz={s.cellno};
outname = p.lineageName;
bak1name = [p.tracksDir,p.movieName,'_lin_bak1.mat'];
bak2name = [p.tracksDir,p.movieName,'_lin_bak2.mat'];

% schnitzlookup:
slookup = makeslookup(s);

curschnitz = 1;
if existfield(p,'schnitzNum')
    curschnitz = p.schnitzNum;
end

done = 0;
while ~done, % Main Loop:
    frac_c_tot=50;
    frames={s.frames};
    cell_no_all_schnitz={s.cellno};
    the_fig=figure(mainfig);
    %set(thefig,'Position',[20,200,1600,500]);

    mousepos=get(gca,'CurrentPoint');
    
    if frac_c_start+frac_c_tot-1<=max((cell2mat(frames)))
        dispframes = frac_c_start:frac_c_start+frac_c_tot-1;
    else
        dispframes = frac_c_start:max((cell2mat(frames)));
      %frac_c_tot = frac_c_start+frac_c_tot-1 - max((cell2mat(frames)));
    end
    
    %make_tile_all_cells_color_code_schnitzedit_goodone_function(p,s);
    theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
    set(the_fig,'Position',[20,300,1600,500]);
    %set(the_fig,'Position',[100,470,1400,300]);
    %set(the_fig,'Position',[50,470,1900,500])
    %%%set(the_fig,'Position',[50,470,1400,300])
    %set(the_fig,'Position',[100,140,1600,400]);
    %     set(mainfig,'name',['Schnitz: ',num2str(curschnitz),', frames ',num2str(frames(1)-1),'...',num2str(frames(end)-1)]);

    % nitzan's addition 2005May16th - otherwise updatetitle crashes
    %dispframes = frames;
    
%     if frac_c_start+frac_c_tot-1<=max((cell2mat(frames)))
%         dispframes = frac_c_start:frac_c_start+frac_c_tot-1;
%     else
%         dispframes = frac_c_start:max((cell2mat(frames)));
%     end
    % end nitzan's addition 2005May16th
    
    %updatetitle_all_cells;
    updatetitle_all_cells2;
    
    %cell_no=updatesptitle_check;

    %dispframes = frames;
     %dispframes = frac_c_start:frac_c_tot;
    
    set(gcf,'WindowButtonMotionFcn','global mousepos;mousepos=get(gca,''CurrentPoint''); updatetitle_all_cells2;');

    w = waitforrealbuttonpress;

    if w==0 %%mouse button
        cz=get(mainfig,'selectiontype');
        xy = get(gca,'CurrentPoint');
        % now figure out where the mouse is with respect to the image:
        xy = round(xy(1,1:2));
        [mfr_pre, mx, my] = mouse2coords2(xy, c_width);
        mfr=mfr_pre+frac_c_start-1;
        cell_no= theimLc(xy(2),xy(1));
        [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell_no,mfr);
        
        if (mfr<=max(cell2mat(frames))) & (mfr>0),
            %fr = frames(mfr);
            fr = mfr;
            switch upper(cz(1)),
                case 'N', % normal click:
                    newcellno = theimLc(xy(2),xy(1));
                    fcount = 0;
                    for k = 1:length(s),
                        fff = find( (s(k).frames==fr) & (s(k).cellno==newcellno));
                        if ~isempty(fff),
                            fcount = fcount + 1;
                            curschnitz = k;
                        end;
                    end;
                    if fcount > 1, disp('more than one instance!'); end;
                case 'A', % ctrl+click on three cells to set up new division event.
                    disp('Division Event!  Ctrl-click on the other two cells involved');
%                     if corr_stat_on==1
%                         div_correct=div_correct+1;
%                     end

                    fr1 = fr; 
                    cell(1) = theimLc(xy(2),xy(1)); 
                    pos1 = xy;
                    [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell(1),mfr); 
                    schn1=schnitz_id;
                    w = waitforrealbuttonpress;
                    if w==0,
                        xy = get(gca,'CurrentPoint');
                        xy = round(xy(1,1:2));
                        [mfr_pre, mx, my] = mouse2coords2(xy, c_width);
                        mfr=mfr_pre+frac_c_start-1;
                        if mfr>max(cell2mat(frames))
                            continue; 
                        end;
                        fr2 = mfr; cell(2) = theimLc(xy(2),xy(1)); pos2 = xy;
                        [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell(2),mfr); 
                        schn2=schnitz_id;
                        cz=get(mainfig,'selectiontype');
                        if (upper(cz(1))=='A') & abs(fr2-fr1)<=1,
                            disp('Great-got 2 out of 3, now click the last one.');
                            w = waitforrealbuttonpress;
                            if w==0,
                                xy = get(gca,'CurrentPoint');
                                xy = round(xy(1,1:2));
                                [mfr_pre, mx, my] = mouse2coords2(xy, c_width);
                                mfr=mfr_pre+frac_c_start-1;
                                fr3 = mfr; 
                                cell(3) = theimLc(xy(2),xy(1)); 
                                pos3 = xy;
                                [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell(3),mfr); 
                                schn3=schnitz_id;
                                cz=get(mainfig,'selectiontype');
                                [frs,I] = sort([fr1 fr2 fr3]);
                                frs0 = frs-frs(1);
                                if (upper(cz(1))=='A') & frs0==[0 1 1],
                                    disp('Great-we''ve got a dividing cell...readjustment in progress.')
                                    cells = cell(I);
                                    frames_re = frs;
                                    schnitzes=[schn1, schn2,schn3];
                                    schnitzes=schnitzes(I);
                                    saveschnitz = s;
                                    s = reconnectschnitz(p,s,frames_re,cells,schnitzes);
                                    slookup = makeslookup(s);
                                    L = finddoubleschnitz(s);
                                    if max2(L)>1,
                                        disp('found double schnitzes!');
                                    end;
                                    curschnitz = findschnitznum(s,fr1,cells(1));

                                end;
                            end;
                        end; % second double-click
                    end; % w==0


                case 'E', % shift+click to change the lineage!

                    % this is the first cell in the pair:
                    disp('Lineage Correction!  Shift-click on the cell to connect to');
                    
%                     if corr_stat_on==1;
%                         link_correct=link_correct+1;
%                     end
                    
                    fr1 = fr; cell1 = theimLc(xy(2),xy(1)); pos1 = xy;
                    [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell1,mfr); 
                    schn1=schnitz_id;
                    % now get a new position
                    w = waitforrealbuttonpress;
                    if w==0,
                        xy = get(gca,'CurrentPoint');
                        xy = round(xy(1,1:2));
                        [mfr_pre, mx, my] = mouse2coords2(xy, c_width);
                        mfr=mfr_pre+frac_c_start-1;
                        if mfr > max(cell2mat(frames))
                            continue;
                        end;                        
                        fr2 = mfr; cell2 = theimLc(xy(2),xy(1)); pos2 = xy;
                        [cell_id,schnitz_id]=getschnitzid(frames,cell_no_all_schnitz,cell2,mfr); 
                        schn2=schnitz_id;
                        [fr2 cell2 pos2]

                        cz=get(mainfig,'selectiontype');
                        
                        if (upper(cz(1))=='E') & (1==abs(fr2-fr1)) & (cell1>0),
                            cells = [cell1 cell2]; 
                            frames_re = [fr1 fr2];
                            schnitzes=[schn1,schn2];
                            saveschnitz = s;
                            if (cell2>0),

                                disp('ok this pair works');

                                s = reconnectschnitz(p,s,frames_re,cells,schnitzes);
                                %slookup = makeslookup(s);
                                L = finddoubleschnitz(s);
                                if max2(L)>1,
                                    disp('found double schnitzes!');
                                end;
                                curschnitz = findschnitznum(s,fr1,cell1);
                                %  snew = suggestschnitz(s,frames,cells);
                            elseif cell2==0,
                                % terminate schnitz
                                disp('Captain, you''ve ordered me to terminate the schnitz');
                                %frames_re=8;
                                s = terminateschnitz(p,s,frames_re,cells);
                                slookup = makeslookup(s);
                                s = renumberschnitzes(p,s);
                            end;


                        end; % second double-click
                    end; % w==0
            end; % case
        end; % length(frames)
    else
        cz=get(mainfig,'selectiontype');
        xy = get(gca,'CurrentPoint');
        % now figure out where the mouse is with respect to the image:
        xy = round(xy(1,1:2));
        thechar = get(gcf,'CurrentCharacter');
        switch upper(thechar),
            % the arrow keys
            case 28 % left arrow
            case 29 % right arrow
            case 30 % up arrow
            case 31 % down arrow
            case 13 % return
                curschnitz = curschnitz + 1;
            case ' ' % space
                s(curschnitz).approved = 1;
                disp(['schnitz #',num2str(curschnitz),' approved.']); % nitzan 2005June25
                curschnitz = curschnitz + 1;
                if frac_c_start+frac_c_tot-frac_next<max_frames
                    frac_c_start=frac_c_start+frac_c_tot-frac_next-1;
                else
                    frac_c_start=1;
                end
            case 27 % ESC
                s(curschnitz).approved = 0;
            case 'J', % jump to next unapproved schnitz
                jumpdone = 0;
                while ~jumpdone,
                    curschnitz = curschnitz + 1;
                    jumpdone = (curschnitz == length(s)) | (s(curschnitz).approved==0);
                end;

            case ','
                curschnitz = curschnitz - 1;
                if frac_c_start-frac_c_tot+frac_next<max_frames
                    frac_c_start=frac_c_start-frac_c_tot+frac_next+1;
                else
                    frac_c_start=1;
                end
            case '.'
                curschnitz = curschnitz + 1;
                if frac_c_start+frac_c_tot-frac_next<max_frames
                    frac_c_start=frac_c_start+frac_c_tot-frac_next-1;
                else
                    frac_c_start=1;
                end
            case 'N',
                % Open a new image window (to leave the current one
                % there for reference
                mainfig = mainfig + 1;
            case 'Q'
                button = questdlg('Exit without saving?','Exit schnitz editor','Yes');
                b = upper(button(1));
                done = b=='Y';
            case 'T'
                if traces_y==0
                    traces_y=1;
                else
                    traces_y=0;
                end
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            case 'F'
                if color_y==0
                    color_y=1;
                else
                    color_y=0;
                end
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            
            case 'W'
                f_channel='s';
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            case 'Z'
                f_channel='p';
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            case 'X'
                f_channel='r';
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            case 'C'
                f_channel='y';
                theimLc=make_tile_all_cells_color_code_schnitzedit_function2_f_channel(p,s,frac_c_tot,frac_c_start,color_y,traces_y,max_frames,f_channel);
                
            case '\'
                %s2=calc_promo_for_schnitz_edit(s);
                s2=concentrate_elong_promo_bug_fix_no_connect_2020_01_29_v1(s);
                figure(2); plot([s2.AYlen(1:577)]);title('Promoter Activity');
                figure(1); plot([s2.len(1:577)]);title('Len');
                figure(3); plot([s2.MY(1:577)]);title('MY');
                figure(4); plot([s2.gr(1:577)]);title('Growth Rate');
            case 'K'
                button = questdlg('Keyboard (Debug) mode?','Debug','Yes');
                b = upper(button(1));
                if b=='Y',
                    keyboard;
                end;

            case 'U' % Undo command.
                if exist('saveschnitz'),
                    button = questdlg('Do you want to undo?','Undo Schnitz','Yes');
                    b = upper(button(1));
                    if b=='Y',
                        s = saveschnitz;
                        clear saveschnitz;
                    end;
                else
                    disp('Cannot undo');
                end;


            case '-',
                winsize = round(winsize*1.4);
                if winsize > maxwinsize,
                    winsize = maxwinsize;
                    disp('min zoom');
                end;
            case '=',
                winsize = round(winsize/1.4);
                if winsize < minwinsize,
                    winsize = minwinsize;
                    disp ('max zoom');
                end;
            case 'G',
                newschnitz = input('what schnitz number: ');
                curschnitz = newschnitz;
            case 'C',  % find continuity problems
                disp('looking for continuity problems')
                cprobs = findcontinuityprobs(s);
                cprobs
            case 'R' % renumber schnitz

                button = questdlg('Renumber schnitzes?', 'Renumber','Yes');
                b = upper(button(1));
                if b=='Y',
                    s = renumberschnitzes(p,s);
                    if curschnitz>length(s),
                        curschnitz = length(s);
                    end;
                end;
                slookup = makeslookup(s);

                %             case 'D' % run find double schnitzes
                %                 disp('finding double schnitzes');
                %                 L = finddoubleschnitz(s);
                %                 if max2(L)==1,
                %                     disp('no problems');
                %                 else
                %                     fn = figure; imagesc(L);
                %                     pause;
                %                     close(fn);
                %                 end;

            case 'D' % delete current schnitz
                button = questdlg('Do you want to delete this schnitz?','Delete Schnitz','No');
                b = upper(button(1));
                if b=='Y',
                    s = deleteschnitz(s,curschnitz);
                    if curschnitz > length(s),
                        curschnitz = length(s);
                    end;
                end;

            case 8, % backspace
                if length(schnitztory)>2,
                    curschnitz = schnitztory(end-1);
                    schnitztory(end-1:end) = [];
                    if curschnitz>length(s),
                        curschnitz = length(s);
                    end;
                end;
            case 'X', % extend mode toggle.
                extendmode = 1-extendmode;
                if extendmode, disp('Extend Mode On!');
                else disp('Extend Mode Off!');
                end;
            case 'O', % orphan mode toggle
                orphanmode = 1-orphanmode;
                if orphanmode, disp('Orphan Mode On!');
                else disp('Orphan Mode Off!');
                end;
            case 'A', % all-color mode
                colormode = 1-colormode;
                if colormode, disp('All-color mode on');
                else disp('All-color mode off');
                end;
            case 'B', % barren mode toggle
                barrenmode = 1-barrenmode;
                if barrenmode, disp('Barrren mode On!');
                else disp('Barren Mode Off!');
                end;
            case 'E', % edit segmentation
                %[mfr,mx,my] = mouse2coords(mousepos(1,1:2),winsize,numcols);
                
%                 if corr_stat_on==1
%                     seg_correct=seg_correct+1;
%                 end
%                 
                [mfr_pre,mx,my] = mouse2coords2(xy, c_width);
                mfr=frac_c_start+mfr_pre-1;
                %if mfr<=length(frames),
                if mfr<=max(cell2mat(frames))
                    disp(['editing frame: ',num2str(mfr)]);
                    %[Lcnew] = editframe(p,frames(mfr));
                    [Lcnew,s] = editframe(p,mfr,s);
                    %Lc = loadseg(p,frames(mfr),'Lc');
                    Lc=s(2).Lc_c(:,:,mfr);
                    %newaffected = getaffectedschnitzes(s,Lc,Lcnew,frames(mfr));     
                    [newaffected,s] = getaffectedschnitzes(s,Lc,Lcnew,mfr);
                    disp('affected schnitzes, disapproving:')
                    newaffected,
                    
%                     for i = 1:length(newaffected),
%                         s(i).approved = 0;
%                     end;
                end;

            case 'S', % Save.
                button = questdlg('Do you want to save?','Save Schnitz','Yes');
                b = upper(button(1));
                if b=='Y',
                    % first backup the original, if it exists:
                    if 2==exist(bak2name),
                        delete(bak2name);
                    end; 
                    if 2==exist(bak1name),
                        movefile(bak1name,bak2name);
                    end; 
                    if 2==exist(outname),
                        movefile(outname,bak1name);
                    end;

                    %schnitzcells = s;
                    save(outname,'s');
                    clear schnitzcells;
                    disp(['Saved to ',outname]);
                end;
            case {'L', 12} % L or Ctrl+L = Load
                button = questdlg('You will lose changes -- are you sure?','Load Schnitz','No');
                b = upper(button(1));
                if b=='Y',
                    [filename,pathname] = uigetfile('*.mat','Open Schnitz File');
                    ww = who('-file',[pathname,filename],'schnitzcells');
                    if isempty(ww),
                        msgbox('No schnitzcells in that file','Where''s the schnitz?','warn');
                    else
                        load([pathname,filename],'schnitzcells');
                        s = schnitzcells;
                        disp('loaded');

                    end;
                end;
            case 'S', % suggest links - between this frame and following frame
                % Some code for suggest links:
                %                     [mfr,mx,my] = mouse2coords(mousepos(1,1:2),winsize,numcols);
                %                     if (mfr+1) <= length(frames),
                %                         frames = [frames(mfr) frames(mfr+1)];
                %                         cells = [theimLc(my,mx) 0];
                %                         snew = suggestschnitz(s,frames,cells);
                %                     end;
            case 'P' % find a likely problem...
                disp('finding problem');
                allframes = setdiff(unique([s.frames]),0);
                probdone = 0; probframe = lastprobframe-1;
                while ~probdone,
                    probframe = probframe + 1;
                    [orphans,parentless] = findorphans(s,probframe);
                    probdone = (length(parentless)>0) | (probframe >= max(allframes));
                end;
                if length(parentless)>0,
                    if probframe==lastprobframe,
                        num = lastprobnum + 1;
                    else
                        num = 1;
                    end;
                    if num > length(parentless), num = 1; end;
                    lastprobnum = num;

                    n = findschnitznum(s,probframe,parentless(num));
                    disp(['found a problem on frame ',num2str(probframe),'; schnitznum=',num2str(n),' cell ',num2str(parentless(1))]);
                    curschnitz = n;
                else
                    disp(['no parentless on frame', probframe]);
                end;

            otherwise
                disp(['char pressed: ',num2str(double(thechar))]);
        end;
    end;
    if curschnitz < 1, curschnitz = 1; disp('first schnitz'); end;
    %     if ~done, done = curschnitz > length(s); end;

end;



% Joe added this earlier because it once exited without saving; 
% that may not be necessary anymore
button = questdlg('Finished reviewing tracking; Do you want to save?',...
    'Save Schnitz','Yes');
b = upper(button(1));
if b=='Y',
    
%     save([p.dataDir,'\corr_stat_v1'],'corrected_pos','link_correct','div_correct','seg_correct')
%     
    % first backup the original, if it exists:
    if 2==exist(bak2name),
        delete(bak2name);
    end;
    if 2==exist(bak1name),
        movefile(bak1name,bak2name);
    end;
    if 2==exist(outname),
        movefile(outname,bak1name);
    end;
    schnitzcells = s;
    save(outname,'s');
    clear schnitzcells;
    disp(['Saved to ',outname]);
end
%outschnitz = s;
set(gcf,'WindowButtonMotionFcn','');
close(mainfig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [affected,s,added,removed] = getaffectedschnitzes(s,Lold,Lnew,frame);

uold = unique(Lold(:));
unew = unique(Lnew(:));

added = setdiff(unew,uold);
% if length(added)>1
%     s_id=length(s);

%%%%%%%%% Correct s structure
Lc=s(1).Lc_c(:,:,frame);
r=regionprops(Lc,'Centroid','MajorAxis','MinorAxis');
cen=reshape([r.Centroid],[2,length(r)])';
ceny=cen(:,2);
[v,I]=sort(ceny);

removed = setdiff(uold,unew);
both = union(added,removed);

affected = [];
for i = 1:length(s),
    ff = find(s(i).frames==frame);
    if ~isempty(ff)
        for k=1:sum(~isnan(v))
            f2=s(i).cellno(ff)==I(k);
            if sum(f2)>0
                if ceny(I(k))~=s(i).ceny(ff)
                    s(i).cenx(ff)=r(I(k)).Centroid(1);
                    s(i).ceny(ff)=r(I(k)).Centroid(2);
                    s(i).len(ff)=r(I(k)).MajorAxisLength;
                    s(i).wid(ff)=r(I(k)).MinorAxisLength;
                    s(i).ind_c(ff)=k;
                    cell_m=I(k);
                    if ~isempty(s(1).yreg)
                        yreg=s(1).yreg(:,:,frame);
                        s(i).MY(ff) = mean(yreg(Lc == cell_m));
                    end
                    if isfield(s,'creg')
                        if ~isempty(s(1).creg)
                            creg = s(1).creg(:,:,frame);
                            s(i).MC(ff) = mean(creg(Lc == cell_m));
                        end
                    end
                    if ~isempty(s(1).rreg)
                        rreg =s(1).rreg(:,:,frame);
                        s(i).MR(ff) = mean(rreg(Lc == cell_m));
                    end
                end
            end
        end
            
        
        if ismember(s(i).cellno(ff),both),
            affected = [affected i];
        end;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fr,x,y] = mouse2coords2(axy,channel_width);

ax  = axy(1);
ay  = axy(2);

% sqx = ceil(ax / winsize);
% sqy = ceil(ay / winsize);

%fr = (sqy-1) * numcols + sqx;
fr = ceil(ax/channel_width);

x = ax;
y = ay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [fr,x,y] = mouse2coords(axy, winsize, numcols);
% 
% ax  = axy(1);
% ay  = axy(2);
% 
% sqx = ceil(ax / winsize);
% sqy = ceil(ay / winsize);
% 
% fr = (sqy-1) * numcols + sqx;
% 
% x = round(ax - (sqx-1)*winsize);
% y = round(ay - (sqy-1)*winsize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Lc,s] = editframe(p,framenum,s);

global segmpos;

thefig = 301;
figure(thefig);
iptsetpref('imshowborder','tight');

done = 0;
%[Lc,rect] = loadseg(p,framenum,'Lc','rect');
Lc=s(1).Lc_c(:,:,framenum);
while ~done,

    imshowlabel(Lc);
    set(thefig,'WindowButtonMotionFcn','global segmpos;segmpos=get(gca,''CurrentPoint'');');
    set(thefig,'name',['Editing frame ',num2str(framenum)]);
    w = waitforrealbuttonpress;
    if w==0, % mouse button:
        cz=get(thefig,'selectiontype');
        switch upper(cz(1)),
            case 'N', % normal click:
                % first save this position
                pos1 = round(segmpos(1,1:2));
                % now get a new position
                w = waitforrealbuttonpress;
                if w==0,
                    cz=get(thefig,'selectiontype');
                    if upper(cz(1))=='N',
                        pos2 = round(segmpos(1,1:2));
                        j1 = Lc(pos1(2),pos1(1));
                        j2 = Lc(pos2(2),pos2(1));
                        Lc(Lc==j2)=j1;
                        Lc=drawline(Lc,[pos1(1,2),pos1(1,1)],[pos2(1,2),pos2(1,1)],j1);
                        Lc=drawline(Lc,[pos1(1,2)+1,pos1(1,1)],[pos2(1,2)+1,pos2(1,1)],j1);
                        Lc=drawline(Lc,[pos1(1,2),pos1(1,1)+1],[pos2(1,2),pos2(1,1)+1],j1);
                    end;
                end;

            case 'E', % shift+click (delete):
                pos1 = round(segmpos(1,1:2));
                Lc(Lc==Lc(pos1(1,2),pos1(1,1)))=0;

            case 'A', % right+click
                Lc = cutcell(Lc,round(segmpos(1,1:2)));
        end;
    else % keyboard:
        thechar = get(gcf,'CurrentCharacter');
        double(thechar)
        switch upper(thechar),
            case 'Q'

                button = questdlg('Exit without saving?','Exit segmentation editor','No');
                b = upper(button(1));
                done = b=='Y';
            case 'G',
                newframe = input('what frame number: ');
                newframenum = newschnitz;
            case 'S', % S is Save...

                button = questdlg('Save changes?','Save confirmation','Yes');
                b = upper(button(1));
                if b=='Y',
                    % first backup the old one:
                    %Lcnew = Lc;
                    %[Lc,rect] = loadseg(p,framenum,'Lc','rect');
                    
                    %Lc_back = Lc;
                    %save([p.segmentationDir,p.movieName,'seg',str3(framenum-1)],'Lc_back','-append');
                    if length(s(2).Lc_c)==0
                        s(2).Lc_c=s(1).Lc_c;
                    end
                    %Lc = Lcnew;
                    %save([p.segmentationDir,p.movieName,'seg',str3(framenum-1)],'Lc','-append');
                    s(1).Lc_c(:,:,framenum)=Lc;
                end;
            case 'A' % add cell:
                %phsub = loadseg(p,framenum,'phsub');
                phsub=s(1).rreg(:,:,framenum);
                Lc = addcell(Lc,round(segmpos(1,1:2)),phsub);
                figure(thefig);
            case 'P',
                %phsub = loadseg(p,framenum,'phsub');
                phsub=s(1).rreg(:,:,framenum);
                showphase(Lc,round(segmpos(1,1:2)),phsub);
                figure(thefig);

        end;
    end;
end;

close(thefig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Lcnew = cutcell(Lc,pos);

% cut at this location
cutx=round(pos(1,2));
cuty=round(pos(1,1));
chosencolor=Lc(cutx,cuty);
cell=zeros(size(Lc));
cell(Lc==chosencolor)=chosencolor;
[fx,fy] = find(cell);
xmin = max(min(fx)-5,1);
xmax = min(max(fx)+5,size(cell,1));
ymin = max(min(fy)-5,1);
ymax = min(max(fy)+5,size(cell,2));
subcell = cell(xmin:xmax, ymin:ymax);

perim=bwperim(imdilate(subcell,strel('disk',1)));
perims=zeros(size(perim));
radp=1;
while max2(perims)<2 & radp<41
    pxmin = max(cutx-xmin+1-radp,1);
    pxmax = min(cutx-xmin+1+radp,size(perims,1));
    pymin = max(cuty-ymin+1-radp,1);
    pymax = min(cuty-ymin+1+radp,size(perims,2));
    perims(pxmin:pxmax,pymin:pymax)=bwlabel(perim(pxmin:pxmax,pymin:pymax));
    radp=radp+1;
end
if max2(perims)>1
    kim=zeros(size(subcell));
    kim(cutx-xmin+1,cuty-ymin+1)=1;
    kim1=kim;
    while ~any(any(kim1 & perims))
        kim1=imdilate(kim1,strel('disk',1));
    end
    [cut1x,cut1y]=find(kim1 & perims);
    color1=perims(cut1x(1),cut1y(1));
    perims(perims==color1)=0;
    kim2=kim;
    while ~any(any(kim2 & perims))
        kim2=imdilate(kim2,strel('disk',1));
    end
    [cut2x,cut2y]=find(kim2 & perims);
    subcell = drawline(subcell,[cut1x(1) cut1y(1)],[cut2x(1) cut2y(1)],0);

    cutcell = cell;
    cutcell(xmin:xmax,ymin:ymax) = bwlabel(subcell,4);
    Lc(Lc==Lc(cutx,cuty))=0;
    Lc(cutcell==1) = chosencolor;
    for k = 2:max2(cutcell),
        Lc(cutcell==k) = max2(Lc)+k-1;
    end;
else
    disp(['less than 2 perims! cell number: ' num2str(Lc(cutx,cuty)) ' in Lbot_back.'])
end
Lcnew = Lc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Lcnew = addcell(Lout,pos,phin);

zoomrect=[max([1,pos(1,2)-50]),min([size(Lout,1),pos(1,2)+49]),...
    max([1,pos(1,1)-50]),min([size(Lout,2),pos(1,1)+49])];
Lzoom=Lout(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4));
Phzoom=phin(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4));
addfig=figure;

LZedge = zeros(size(Lzoom));
for ie = 1:max2(Lzoom);
    LZedge = LZedge | bwperim(Lzoom==ie);
end;
LZedge=double(+LZedge);
imshow(makergb(+imresize(LZedge,5),imresize(Phzoom(:,:,1),5)));
subaddcell=imresize(roipoly,1/5);%(phin);
if max2(Lzoom(subaddcell>0))>0
    disp('overlaps existing cell; ignored.');
else
    Lzoom(subaddcell)=max2(Lout)+1;
    Lout(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4))=Lzoom;
end
close(addfig)

Lcnew = Lout;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showphase(Lout,pos,phin);

zoomrect=[max([1,pos(1,2)-50]),min([size(Lout,1),pos(1,2)+49]),...
    max([1,pos(1,1)-50]),min([size(Lout,2),pos(1,1)+49])];
Lzoom=Lout(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4));
Phzoom=phin(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4));
addfig=figure;

% LZedge = zeros(size(Lzoom));
% for ie = 1:max2(Lzoom);
%     LZedge = LZedge | bwperim(Lzoom==ie);
% end;
% LZedge=double(+LZedge);
imshow(Phzoom(:,:,1),[]);

% %subaddcell=imresize(roipoly,1/5);%(phin);
% if max2(Lzoom(subaddcell>0))>0
%     disp('overlaps existing cell; ignored.');
% else
%     Lzoom(subaddcell)=max2(Lout)+1;
%     Lout(zoomrect(1):zoomrect(2),zoomrect(3):zoomrect(4))=Lzoom;
% end
% close(addfig)
%
% Lcnew = Lout;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snew = terminateschnitz(p,s,frames,cells);

% we terminate the relevant schnitz at the relevant frame.
% this shouldn''t be too hard.

snew = s;

[frames,I] = sort(frames);
cells = cells(I);
framefields = {'frames','cellno','cenx','ceny','len','ind_c','wid','MY','MR'};
schnitznum = findschnitznum(s, frames(1), cells(1));
%s(schnitznum).approved = 0;

theschnitz = s(schnitznum);

get_tree_1;

if s(schnitznum).frames(end)==frames(1)
    % we don't need to create a new schnitz, we just need to get rid of the
    % daughters.
    
    if s(schnitznum).D>0,
        s(s(schnitznum).D).P = 0;
    end;
    if s(schnitznum).E>0,
        s(s(schnitznum).E).P = 0;
    end;
    s(schnitznum).D = 0;
    s(schnitznum).E = 0;
else 
    start1 = 1;
    end1 = find(s(schnitznum).frames==frames(1));
    start2 = end1+1;
    end2 = length(s(schnitznum).frames);
    
    newschnitz = s(schnitznum);    
    for i = 1:length(framefields),
        name = char(framefields(i));
        x = theschnitz.(name)(start1:end1);
        y = theschnitz.(name)(start2:end2);
        newschnitz.(name) = y;
        s(schnitznum).(name) = x;
    end;        
    %newschnitz.P = 0;
    D_ind=s(schnitznum).D;
    E_ind=s(schnitznum).E;
    
    s(schnitznum).D = 0;
    s(schnitznum).E = 0;
    
    %get_tree_1;
    st=schnitznum;
    for kk=1:length(trace1)
        if sum(ismember(trace1{kk},st))>0
            %disp(num2str(kk));
            a_ind=find(trace1{kk}==st);
            for qq=1:length(trace1{kk})
            %for qq=1:a_ind
                schnitznum=trace1{kk}(qq); 
                %if schnitznum>st
                if qq<a_ind
                
                    for i = 1:length(framefields),
                        name = char(framefields(i));
                        s(schnitznum).(name) = [];
                    end
                    s(schnitznum).D = 0;
                    s(schnitznum).E = 0;
                    s(schnitznum).P = 0;
                end
            end;  
        end
    end

            
            
    
%     kk=1;
%     while D_ind~=0 && ~isnan(D_ind)
%         d_kill(kk)=D_ind;
%         kk=kk+1;
%         schnitznum=D_ind;    
%         for i = 1:length(framefields),
%             name = char(framefields(i));
%             s(schnitznum).(name) = [];
%         end;  
%         D_ind=s(schnitznum).D;
%         s(schnitznum).D = 0;
%     end
%     
%     while E_ind~=0 && ~isnan(E_ind)
%         d_kill(kk)=E_ind;
%         kk=kk+1;
%         schnitznum=E_ind;    
%         for i = 1:length(framefields),
%             name = char(framefields(i));
%             s(schnitznum).(name) = [];
%         end;  
%         E_ind=s(schnitznum).E;
%         s(schnitznum).E = 0;
%     end
%     P_ind=[s.P];
%     killer_master_ind=ismember(P_ind,unique(d_kill));
%     killer_master=P_ind(killer_master_ind);
%     
%     for ll=1:length(killer_master)
%         schnitznum=killer_master(ll);
%         for i = 1:length(framefields),
%             name = char(framefields(i));
%             s(schnitznum).(name) = [];
%         end;  
%         s(schnitznum).D = 0;
%         s(schnitznum).E = 0;
%     end
        
    

        %s = addschnitz(p,s,newschnitz);

%     if newschnitz.D>0,
%         s(newschnitz.D).P = length(s);
%     end;
%     if newschnitz.E>0,
%         s(newschnitz.E).P = length(s);
%     end;
end;

snew = s;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function snew = reconnectschnitz(p,s,frames,cells,schnitzes);

% frames and cells should be either length 2 or 3.
% if they are length three that indicates that they should become a
% parent-daughter1-daughter2 triad.

% first we want to truncate the disconnected schnitzes.
% then we want to make the connection.
% NOTE: we only take care of tree-related fields.
% fluorescence and other derived quantities can be recalculated afterwards.

% put it in temporal order from earlier to later:
snew = s;

[frames,I] = sort(frames);
cells = cells(I);
schnitznum= schnitzes(I);
framefields = {'frames','cellno','cenx','ceny','ind_c', 'len', 'wid', 'MC', 'MY','MR'};

% find the 2-3 relevant schnitzes:
% for k = 1:length(frames),
%     schnitznum(k) = findschnitznum(s, frames(k), cells(k));
%     % s(schnitznum(k)).approved = 0; % this command here leads
%     % to crashing since sometimes schnitznum(k)=0. see below.
% end;

% some schnitzes may not exist, since the relevant cells could have been
% added with the image editor, or simply not tracked:
% this loop creates a new schnitz if one doesn't already exist
for k = 1:length(frames),
    if schnitznum(k)==0,
        disp(['couldn''t find schnitz for cell ',num2str(k),'--creating new one']);
        newschnitz = makeemptyschnitz(s);
        newschnitz.frames = frames(k);
        newschnitz.cellno = cells(k);
        % what other fields do we need to add here?
        newschnitz = addfields(p,newschnitz,s);
        %newschnitz = addcenxceny(p,newschnitz,s);
        s = addschnitz(p,s,newschnitz);
        schnitznum(k) = length(s);
    end;
end;
% end of new schnitz creation

% nitzan's addition - 2005May16th
% mark the schnitzes which are tampered-with as non-approved:
for k = 1:length(frames),
    s(schnitznum(k)).approved = 0;
end;
% this should be placed after the new schnitz creation above.
% end nitzan's addition 2005May16th

% now we do the actual reconnection:
if length(frames)==2, % not a division event:
    snew = reconnect2(p,s,frames,cells,schnitznum);
elseif length(frames)==3,
    snew = reconnect3(p,s,frames,cells,schnitznum);
else
    disp('not a 2 or 3 reconnect...strange!');
end;
snew(1).Lc_c=s(1).Lc_c;
snew(1).yreg=s(1).yreg;
snew(1).rreg=s(1).rreg;
snew(1).channel_pos=s(1).channel_pos;
badschnitzes = quickcheck(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snew = reconnect2(p,s,frames,cells,schnitznum);
framefields = {'frames','cellno','cenx','ceny','ind_c', 'len', 'wid', 'MC', 'MY','MR'};
snew = s;
% first a silly check to make sure the two schnitznums are different:
if diff(schnitznum)==0,
    disp('these 2 cells have the same schnitznum...quitting');
    return;
end;

% now create the newly connected schnitz from its two pieces.
schnitz1 = s(schnitznum(1));
schnitz2 = s(schnitznum(2));

start1 = 1;
end1 = find(schnitz1.frames==frames(1));
start2 = find(schnitz2.frames==frames(2));
end2 = length(schnitz2.frames);

newschnitz = schnitz1;

% the daughters of this schnitz are just the D and E of schnitz2.
for i = 1:length(framefields),
    name = char(framefields(i));
    if ~isempty(schnitz1.(name))
        x = schnitz1.(name)(start1:end1);
        y = schnitz2.(name)(start2:end2);
        newschnitz.(name) = [x y];
    end
end;
% fix up the connections:
newschnitz.D = schnitz2.D;
newschnitz.E = schnitz2.E;
newschnitz.P = schnitz1.P;

s(schnitznum(1)) = newschnitz;
if newschnitz.D>0, s(newschnitz.D).P = schnitznum(1); end;
if newschnitz.E>0, s(newschnitz.E).P = schnitznum(1); end;

% now truncate the disconnected schnitzes:
% First, the end of schnitz1:

newschnitz1 = makeemptyschnitz(s);
newschnitz2 = makeemptyschnitz(s);

L1 = length(schnitz1.frames);
if end1<L1,
    for i = 1:length(framefields),
        name = char(framefields(i));
        newschnitz1.(name) = schnitz1.(name)(end1+1:end);
    end;
    newschnitz1.P = 0;
    newschnitz1.D = schnitz1.D;
    newschnitz1.E = schnitz1.E;
    newschnitz1 = addcenxceny(p,newschnitz1,s);
    s = addschnitz(p,s,newschnitz1);
    k = length(s);
    if schnitz1.D>0,
        s(schnitz1.D).P = k;
    end;
    if schnitz1.E>0,
        s(schnitz1.E).P = k;
    end;
else
    % the former daughters of schnitz1 don't connect to anything now:
    if schnitz1.D>0, s(schnitz1.D).P = 0; end;
    if schnitz1.E>0, s(schnitz1.E).P = 0; end;

    newschnitz1 = [];
end;

% Second, let's deal with the remains of Schnitz2:
if start2==1,
    % nothng to do, because the entire schnitz2 has been subsumed into
    % schnitz1:
    s(schnitznum(2)) = makeemptyschnitz(s); % just to hold the place
    % the former parent of schnitz2 just lost a daughter:
    if schnitz2.P>0,
        pnum = schnitz2.P;
        dnum = 0;
        if s(schnitz2.P).D==schnitznum(2), % if it was D, then connect the parent with its E daugthter...
            dnum = s(schnitz2.P).E;
            s(schnitz2.P).D = 0;
        elseif s(schnitz2.P).E==schnitznum(2), % if it was E, then connect the parent wih its D daughter...
            dnum = s(schnitz2.P).D;
            s(schnitz2.P).E = 0;
        else
            disp('strangely i can''t disconnect the parent of schnitz2...');
        end;
        if isnan(dnum)
            dnum=0;
        end
        if dnum,
            % now, we want to join the parent to its other daughter into
            % one single unified schnitz.  this will go into the parent.
            for i = 1:length(framefields),
                name = char(framefields(i));
                y = s(dnum).(name);
                s(pnum).(name) = [s(pnum).(name) y];
            end;
            s(pnum).D = s(dnum).D;
            s(pnum).E = s(dnum).E;
            if s(dnum).D>0,
                s(s(dnum).D).P = pnum;
            end;
            if s(dnum).E>0,
                s(s(dnum).E).P = pnum;
            end;

            s(dnum) = makeemptyschnitz(s);
        end;
    end;
else
    % in this case there is still some schnitz2 stuff that we want to
    % preserve:
    for i = 1:length(framefields),
        name = char(framefields(i));
        if ~isempty(schnitz2.(name))
            newschnitz2.(name) = schnitz2.(name)(1:start2-1);
        end
    end;
    newschnitz2.P = schnitz2.P;
    newschnitz2.D = 0;
    newschnitz2.E = 0;
    s(schnitznum(2)) = newschnitz2;
end;
snew = s;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snew = reconnect3(p,s,frames,cells,schnitznum);
% reconnection for division events that involve 3 cells.
snew = s;

framefields = {'frames','cellno','cenx','ceny','ind_c', 'len', 'wid', 'MC', 'MY','MR'};
if schnitznum(2)==schnitznum(3),
    disp('the two daughter cells have identical schnitznums...quitting');
    schnitznum,  return;
end;
% first pull out the three key schnitzes:
for k = 1:3, schnitz(k) = s(schnitznum(k)); end;

% Main Step 1:
% If one of the daughters of the split is currently in the same schnitz with
% the new parent, then we are going to create a new schnitz for it:
dup = 0;
if (schnitznum(1)==schnitznum(2)),
    dup=2;
elseif schnitznum(1)==schnitznum(3),
    dup=3;
end;

if dup>0,
    [s, newdaughternum] = divorphan(p, s, schnitznum(1), frames(1));
    schnitz(dup) = s(newdaughternum);
    schnitznum(dup) = newdaughternum;
    schnitz(1) = s(schnitznum(1));
end;

% Main Step 2:
% Here is how we proceed:
% 1. If there is more to the schnitz(1) after frames(1), then we divide
% schnitz1 into two pieces: newschnitz1 and orphanschnitz1.  Otherwise, we
% copy it to newschnitz1.
% 2. If there was previous info in schnitz(2) and schnitz(3) then we divide
% those off into newbarrens and newdaughters, both containing up to 2
% schnitzes.
% 3. Finally we reconnect all the .P, .D., and .E fields so everything
% makes sense.

% First, the parent
% we note that this operation definitely truncates schnitz1.
% any remaining frames of schnitz1 will have to be orphans.
% this only necessary if schnitz(1) has additional frames after the split.
newschnitz1 = schnitz(1);
orphan1num=0;
if schnitz(1).frames(end)>frames(1),
    orphanschnitz1 = makeemptyschnitz(s);
    end1 = find(schnitz(1).frames==frames(1));pwd
    for i = 1:length(framefields),
        name = char(framefields(i));
        if ~isempty(schnitz(1).(name))
            newschnitz1.(name) = schnitz(1).(name)(1:end1);
            orphanschnitz1.(name) = schnitz(1).(name)(end1+1:end);
        end
    end;
% nitzan's change - 2005June22nd - changed schnitz1.D into schnitz(1).D
    orphanschnitz1.D = schnitz(1).D;
    orphanschnitz1.E = schnitz(1).E;
% end nitzan's change - 2005June22nd - changed schnitz1.E into schnitz(1).E
    s = addschnitz(p,s,orphanschnitz1);
    orphan1num = length(s);
    if orphanschnitz1.D>0, s(orphanschnitz1.D).P =orphan1num; end;
    if orphanschnitz1.E>0, s(orphanschnitz1.E).P =orphan1num; end;
end;
s(schnitznum(1))=newschnitz1;

% Next step: offspring
% we similarly note that if the offspring had earlier frames than
% frames(2:3), those will become barren:
for k = 1:2,
    newdaughter(k) = schnitz(k+1);
    newdaughternum(k) = schnitznum(k+1);
    newbarren(k) = makeemptyschnitz(s);
    numbarren(k) = 0;
    if newdaughter(k).frames(1)<frames(2),

        endbar = find(newdaughter(k).frames==frames(1));
        for i = 1:length(framefields),
            name = char(framefields(i));
            if ~isempty(schnitz(k+1).(name))
                newbarren(k).(name) = schnitz(k+1).(name)(1:endbar);
                newdaughter(k).(name) = schnitz(k+1).(name)(endbar+1:end);
            end
        end;
        newbarren(k).P = newdaughter(k).P;
        s(schnitznum(k+1))=newdaughter(k);
        s = addschnitz(p,s,newbarren(k));
        numbarren(k) = length(s);

        if newbarren(k).P>0,
            tempD = s(newbarren(k).P).D;
            tempE = s(newbarren(k).P).E;
            if tempD == schnitznum(k+1),
                s(newbarren(k).P).D = numbarren(k);
            elseif tempE == schnitznum(k+1),
                s(newbarren(k).P).E = numbarren(k);
            else
                disp('That''s weird, nobody was pointing back at our barren');
            end;
        end;
    end;
end;

% Now, having created all of this mishegas, we can actually go ahead and
% connect things:

s(schnitznum(1)).D = newdaughternum(1);
s(schnitznum(1)).E = newdaughternum(2);
s(newdaughternum(1)).P = schnitznum(1);
s(newdaughternum(2)).P = schnitznum(1);
%         % not sure if this is necessary:
%         commonframes = intersect(newbarren(k).frames,s(schnitznum(1)).frames);
%         fb = find(newbarren(k).frames==commonframes(1));
%         fs = find(s(schnitznum(1)).frames==commonframes(1));
%         for i = length(commonframes):-1:1,
%             if newbarren(k).cellno(fb+i-1)==newschnitz1.cellno(fs+i-1),
%                 disp('achtung! deleting stuff...!');
%                 newbarren(k).frames(fb+i-1)=[];
%                 newbarren(k).cellno(fb+i-1)=[];
%             end;
%         end;
%


disp('Reconnection Report:');
if dup>0,
    disp(['   Original parent split: schnitz#',num2str(schnitznum(1)),'-->itself+#',num2str(newdaughternum)]);
end;
if orphan1num>0,
    disp(['   Created an orphan from parent: schnitz#',num2str(orphan1num)]);
end;
for k = 1:2,
    if numbarren(k)>0,
        disp(['   Created a new barren: schnitz#',num2str(numbarren(k))]);
    end;
end;
disp(['otherwise, connected schnitz#',num2str(schnitznum(1)),' to schnitzes ',num2str(schnitznum(2)), ' and ',num2str(schnitznum(3))]);
snew = s; % return value, very important

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [snew, newdaughternum] = divorphan(p, s, snum, frame1);
% this function is called by reconnect3, when you are creating a division
% event in which the parent and one of the daughters occupty the same
% schnitz.
% The purpose of the function is to split that schnitz after frame1,
% creating a new schnitz which will be one of the two daughters

framefields = {'frames','cellno','cenx','ceny','ind_c', 'len', 'wid', 'MC', 'MY','MR'};
schnitz = s(snum);
newdaughter=makeemptyschnitz(s);

end1 = find(schnitz.frames==frame1);
for i = 1:length(framefields),
    name = char(framefields(i));
    %if ~isempty(schnitz(1).(name)) || strcmp(name,'frames')
    if ~isempty(schnitz(1).(name))
        newdaughter.(name) = schnitz(1).(name)(end1+1:end);
        schnitz.(name) = schnitz.(name)(1:end1);
    end

end;
newdaughter.P = snum;
newdaughter.D = schnitz.D;
newdaughter.E = schnitz.E;

s = addschnitz(p,s,newdaughter);
newdaughternum = length(s);

if newdaughter.D>0, s(newdaughter.D).P = newdaughternum; end;
if newdaughter.E>0, s(newdaughter.E).P = newdaughternum; end;

schnitz.D = newdaughternum;
schnitz.E = 0;
s(snum) = schnitz;
snew = s;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snew = suggestschnitz(s,frames,cells);

suggestfig = 401;
radius = 200;
snew = s;

% this function looks in the vicinity of chosen cells in the frame pair
% frames for lineages that end in frames(1) and start in frames(2) and asks
% you if you would like to connect them.

% first find cells that either appear only on frame 1 or whose lineage ends
% on frame 1.
% Then find cells that either appear only on frame 2 or whose lineage
% starts on frame 2.

% u1 and u2 are vectors of the unique cell numbers appearing in frames 1
% and 2 of of Lc.

% First just look at orphan cells that may have been created by, say,
% segmentation problems.



Lc1 = loadseg(p,frames(1),'Lc'); Lc2 = loadseg(p,frames(2),'Lc');
u1 = unique(Lc1(:)); u2 = unique(Lc2(:));

orphan1 = [];
for i = 1:length(u1),
    fu1 = find(([s.frames]==frames(1)) & ([s.cellno]==u1(i)));
    if isempty(fu1), orphan1 = [orphan1 u1(i)]; end;
end;

orphan2 = [];

for i = 1:length(u2),
    fu2 = find(([s.frames]==frames(2)) & ([s.cellno]==u2(i)));
    if isempty(fu2), orphan2 = [orphan2 u2(i)]; end;
end;


disp('Orphan List');
orphan1
orphan2

allcenx = [s.cenx]; allceny = [s.ceny];

f1 = find( ([s.frames]==frames(1)) & ([s.cellno]==cells(1)));
if isempty(f1), disp('suggestschnitz cannot find cell 1'); return; end;
pos1 = [allcenx(f1) allceny(f1)];

f2 = find( ([s.frames]==frames(2)) & ([s.cellno]==cells(2)));
if isempty(f2),
    disp('suggestschnitz cannot find cell 2');
    pos2 = pos1;
else
    pos2 = [allcenx(f2) allceny(f2)];
end;

schnitznum1 = []; cell1 = [];
schnitznum2 = []; cell2 = [];
for i = 1:length(s),
    if (s(i).D<1) & (s(i).frames(end)==frames(1)) & (schnitzdist(pos1(f1),[s(i).cenx(end) s(i).ceny(end)])<radius),
        cell1 = [cell1 s(i).cellno(end)];
        schnitznum1 = [schnitznum1 i];
        pos1(1:2,i) = [s(i).cenx(end) s(i).ceny(end)];
    end;

    if (s(i).P<1) & (s(i).frames(1)==frames(2)) & (schnitzdist(pos2,[s(i).cenx(1) s(i).ceny(1)])<radius),
        cell2 = [cell2 s(i).cellno(1)];
        schnitznum1 = [schnitznum1 i];
        pos2(1:2,i) = [s(i).cenx(1) s(i).ceny(1)];
    end;
end;

figure(suggestfig);clf;
thesuggestim = zeros(max(size(Lc1,1),size(Lc2,1)),size(Lc1,2)+size(Lc2,2));
thesuggestim(1:size(Lc1,1),1:size(Lc1,2))=Lc1;
start2 = size(Lc1,2)+1; stop2 = start2+size(Lc2,2)-1;
thesuggestim(1:size(Lc2,1),start2:stop2) = Lc2;
thesuggestim(:,start2) = max2(thesuggestim);

% now cycle through possible suggestions and calculate distance:
k = 0;
for i = 1:length(cell1),
    for j = 1:length(cell2),
        k = k + 1;
        I(k) = i;
        J(k) = j;
        D(k) = schnitzdist(pos1(:,i),pos2(:,j));
    end;
end;

[D,S] = sort(D);
cell1 = cell1(S);
cell2 = cell2(S);
schnitznum1 = schnitznum1(S);
schnitznum2 = schnitznum2(S);
pos1 = pos1(S,:);
pos2 = pos2(S,:);

imshowlabel(thesuggestim);

for i = 1:length(D),
    h = line([pos1(1) pos2(1)],[pos1(2) pos2(2)]);
    set(h,'linecolor','w');
    pause;
end;



snew = s;

close(suggestfig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = schnitzdist(pos1,pos2);
D = sqrt(sum((pos1-pos2).^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [varargout] = loadseg(p,fr,varargin);

option=2;

% if p.segmentedColor=='p'
    filename = [p.segmentationDir,p.movieName,'seg',str3(fr-1),'.mat'];
% else
%     filename = [p.segmentationDir,p.movieName,'-fseg-',p.segmentedColor,'-',str3(fr-1),'.mat'];
% end
if exist(filename),
    for i = 1:length(varargin),
        if ~isempty(who('-file',filename,char(varargin{i}))),
            x = load(filename,char(varargin{i}));
            varargout(i) = {x.(char(varargin{i}))};
        % added by nitzan 2005June24
        elseif strcmp(char(varargin{i}),'Lc') % & p.trackUnCheckedFrames
            x = load(filename,'LNsub');
            varargout(i) = {x.LNsub};
        % end addition by nitzan 2005June24
        else
            disp(['cannot find ',char(varargin{i}),' in ',filename]);
%             for k = 1:length(varargin),
                varargout(i)={0};
%             end;
        end;
    end;
else
    disp([filename, ' does not exist']);
    for i = 1:length(varargin),
        varargout(i) = {0};
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [orphans,parentless] = findorphans(s,fr);
% orphans are simply all the possible cellnos that do not appear in s on
% this frame.

orphans = [];

cellnos = [s.cellno];
ucells = setdiff(unique(cellnos),0);
f = find([s.frames]==fr);
orphans = setdiff(cellnos,[cellnos(f)]);

f = find([s.P]<1);
snoparent = s(f);
x = [];
for i = 1:length(snoparent),
    if length(snoparent(i).frames)>0,
        if snoparent(i).frames(1)==1,
            x(end+1) = i;
        end;
    end;
end;
snoparent(x)=[];

f = find([snoparent.frames]==fr);
cellnos = [snoparent.cellno];
parentless = cellnos(f);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function barren = findbarren(s,fr);
maxframes = max([s.frames]);
f = find(([s.D]<1) & ([s.E]<1));
sbarren = s(f);
lastframes = zeros(length(sbarren),1);
for i = 1:length(sbarren), lastframes(i) = max(sbarren(i).frames); end;
sbarren(lastframes==max([s.frames]))=[];
f = find([sbarren.frames]==fr);
cellnos = [sbarren.cellno];
barren = cellnos(f);
% barren = setdiff(barren,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatetitle_original_internal;

global mousepos theimLc mainfig curschnitz dispframes curapproved;

numstr='';

xy = round(mousepos(1,1:2));
% [mfr, mx, my] = mouse2coords(xy, winsize, numcols);
if all(xy>0) & (xy(2)<size(theimLc,1)) & (xy(1)<size(theimLc,2)),
    cellno = theimLc(xy(2),xy(1));
    %     name = get(mainfig,'name');
    cellnumstr = '; cell # '; cellnumstrlen=length(cellnumstr);
    %     frnumstr = '; frame # '; frnumstrlen=length(frnumstr);
    %     f = findstr(name,cellnumstr);
    numstr = num2str(cellno);
    %     frstr = num2str(mfr);
    %     if isempty(f),
    %         name = cat(2,name,cellnumstr,numstr);
    %     else
    %         name = cat(2,name(1:f+cellnumstrlen),numstr);
    %     end;
    %     set(mainfig,'name',name);
end;
if curapproved,
    appchar = '*';
else
    appchar = '-';
end;

set(mainfig,'name',[appchar,' Schnitz: ',...
    num2str(curschnitz),', frames ',num2str(dispframes(1)),...
    '...',num2str(dispframes(end)),'; cell: ',numstr]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sn = findschnitznum(s,fr,cellno);
sn = 0;
for i = 1:length(s),

    if any(s(i).frames==fr & s(i).cellno==cellno),
        sn = i;
        return;
    end;
end;


% *********************

function L=finddoubleschnitz(s);

uf = setdiff(unique([s.frames]),0);
for i = 1:length(s),
    s(i).schnitznums = ones(size(s(i).frames))*i;
end;
snums = [s.schnitznums];

for i = 1:length(uf),
    fr = uf(i);
    f = find([s.frames]==fr);
    cn = [s.cellno];
    uc = unique(cn(f));
    for j = 1:length(uc),
        cn = uc(j);

        % now, are there any other guys who have the same cell number on
        % the same frame?

        fff = find(([s.cellno]==cn) & ([s.frames]==fr));
        L(i,j) = length(fff);
        if L(i,j)>1,
            for m = 1:length(fff)
                [fr cn snums(fff(m))]
            end;
        end;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snew = addschnitz(p,s,newschnitz);

for i = 1:length(newschnitz.frames),
    Lc = loadseg(p,newschnitz.frames(i),'Lc');
    [x,y] = find(Lc==newschnitz.cellno(i));
   % if ~isempty(x),
   %     newschnitz.cenx(i) = mean(y);
   %     newschnitz.ceny(i) = mean(x);
   % else
   %     disp('addschnitz can''t find the pixels...');
   % end;
end;
s(end+1) = newschnitz;
disp(['adding schnitz #',num2str(length(s))]);
snew = s;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function probs = findcontinuityprobs(s);
probs = [];
slist = [];
sd = 1;
while ~isempty(sd),

    [slist,probs] = tracecontinuity(s,sd(1),slist,probs);

    sd = setdiff(1:length(s), slist);

end;

function [newslist,newprobs] = tracecontinuity(s,snum,slist,probs);
newslist = slist;
newprobs = probs;
if ismember(snum,slist), return; end;
frend = s(snum).frames(end);
newslist = [slist snum];
if s(snum).D>0,
    if s(snum).frames(end) ~= s(s(snum).D).frames(1)+1,
        probs = [probs s(snum).D];
    end;
    [newslist,newprobs] = tracecontinuity(s,s(snum).D,newslist,newprobs);
end;
if s(snum).E>0,
    if s(snum).frames(end) ~= s(s(snum).E).frames(1)+1,
        probs = [probs s(snum).E];
    end;
    [newslist,newprobs] = tracecontinuity(s,s(snum).E,newslist,newprobs);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slookup = makeslookup(s);
for i = 1:length(s),
    for j = 1:length(s(i).frames),
        if ~isempty(s(i).frames),
            if s(i).frames
                slookup(s(i).frames(j),s(i).cellno(j))=i;
            end;
        end;
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555


function w = waitforrealbuttonpress;
global mousepos theimLc mainfig curschnitz dispframes movie_name;


done = 0;
while ~done,
    w = waitforbuttonpress;
    badchar = (w==1) & isempty(get(gcf,'CurrentCharacter'));
    if ~badchar,
        done = 1;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

function empty = makeemptyschnitz(s);
% make an empty schnitz:
allfields = fieldnames(s);
for i = 1:length(allfields),
    name = char(allfields(i));
    empty.(name) = [];
end;
empty.P = 0;
empty.D = 0;
empty.E = 0;
empty.frames = [];
empty.cellno = [];
empty.approved = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555

function badschnitzes = quickcheck(s);
disp('running quickcheck');
badschnitzes=[];
for i = 1:length(s),
    if ~isempty(s(i).frames),
        mylastframe = s(i).frames(end);

        if s(i).D > 0,
            ffd = s(s(i).D).frames(1);
            if ffd ~= (mylastframe+1),
                badschnitzes = [badschnitzes i];
            end;
        end;
        if s(i).E>0,
            ffe = s(s(i).E).frames(1);
            if ffe ~= (mylastframe+1),
                badschnitzes = [badschnitzes i];
            end;
        end;
    end;
end;
badschnitzes,

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function snew = renumberschnitzes(p,s);


N0 = length(s);
keepit = zeros(N0,1);
for i = 1:N0,
    keepit(i)=0;
    if ~isempty(s(i).frames),
        if length(s(i).frames)>0,
            keepit(i) = 1;
        end;
        if length(s(i).frames)==1,
            if (s(i).P<1),
                if s(i).D<1
                    if s(i).E<1,

                        % let's get rid of schnitzes that are totally disconnected from everything
                        % and have only a single frame
                        keepit(i) = 0;
                        disp(['found an isolated schnitz #',num2str(i),'--snipping it...']);

                    end;
                end;
            end;
        end;

    end;
end;




j = 1;
for i = 1:N0,
    if keepit(i),
        snew(j) = s(i);
        newnum(i) = j;
        j = j + 1;
    end;
end;
f = find(keepit==0);
disp('deleting schnitzes: ');
f'
% newnum,

for i = 1:length(snew),
    if snew(i).D>0,
        snew(i).D = newnum(snew(i).D);
    end;
    if snew(i).E>0,
        snew(i).E = newnum(snew(i).E);
    end;
    if snew(i).P>0,
        snew(i).P = newnum(snew(i).P);
    end;
end;

% now fix guys who have an E but no D...
for i = 1:length(snew),
    if (snew(i).E>0) & ~(snew(i).D>0),
        disp(['daughters swapped...fixing, new schnitz #',num2str(i)]);
        snew(i).D = snew(i).E;
        snew(i).E = 0;
    end;
end;

% finally, find everyone who lacks cenx/ceny definitions and fill those in:
for i = 1:length(snew),
    if length(s(i).frames)>0,
        if length(s(i).cenx)==0,
            disp(['adding cenx/ceny info to: ',num2str(i)]);
            snew(i) = addcenxceny(p,snew(i),s);
        end;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

function newschnitz = addcenxceny(p,schnitz,s);

newschnitz = schnitz;
for i = 1:length(newschnitz.frames),
    [Lc] = s(1).Lc_c(:,:,newschnitz.frames(i));
    [x,y] = find(Lc==schnitz.cellno(i));
    
    %newschnitz.cenx(i) = mean(y);
    %newschnitz.ceny(i) = mean(x);
end;

function newschnitz = addfields(p,schnitz,s);

newschnitz = schnitz;
for i = 1:length(newschnitz.frames),
    [Lc] = s(1).Lc_c(:,:,newschnitz.frames(i));
    cell_m=newschnitz.cellno(i);
    r=regionprops(Lc,'Centroid','MajorAxis','MinorAxis');
    newschnitz.cenx(i)=r(newschnitz.cellno(i)).Centroid(1);
    newschnitz.ceny(i)=r(newschnitz.cellno(i)).Centroid(2);
    newschnitz.len(i)=r(newschnitz.cellno(i)).MajorAxisLength;
    newschnitz.wid(i)=r(newschnitz.cellno(i)).MinorAxisLength;
    %Cell ID in channel
    cen=reshape([r.Centroid],[2,length(r)])';
    [v,I]=sort(cen(:,2));
    newschnitz.ind_c(i)=find(I==cell_m);
    
    if ~isempty(s(1).yreg)
        yreg=s(1).yreg(:,:,newschnitz.frames(i));
        newschnitz.MY(i) = mean(yreg(Lc == cell_m));
    end
    if isfield(s,'creg')
        if ~isempty(s(1).creg)
            creg = s(1).creg(:,:,newschnitz.frames(i));
            newschnitz.MC(i) = mean(creg(Lc == cell_m));
        end
    end
    if ~isempty(s(1).rreg)
        rreg =s(1).rreg(:,:,newschnitz.frames(i));
        newschnitz.MR(i) = mean(rreg(Lc == cell_m));
    end
%     if length(s.yreg)>0
%         
%     
%     
%     [x,y] = find(Lc==schnitz.cellno(i));
%     
    %newschnitz.cenx(i) = mean(y);
    %newschnitz.ceny(i) = mean(x);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

function snew = deleteschnitz(s,snum);

s(snum) = makeemptyschnitz(s);

for i = 1:length(s),
    if s(i).P==snum,
        s(i).P=0;
    end;
    if s(i).E==snum,
        s(i).E=0;
        if s(i).D>0,
            if s(i).D~=snum,
                disp('should merge these schnitzes here...');
            end;
        end;
    end;
    if s(i).D==snum,
        s(i).D=0;
        if s(i).E>0,
            if s(i).E~=snum,
                disp('should merge schnitzes here, the other way...');
            end;
        end;
    end;

end;

snew = s;




