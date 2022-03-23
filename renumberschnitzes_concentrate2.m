function snew = renumberschnitzes_concentrate(s)


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
                        %disp(['found an isolated schnitz #',num2str(i),'--snipping it...']);

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
%disp('deleting schnitzes: ');
f';
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
        %disp(['daughters swapped...fixing, new schnitz #',num2str(i)]);
        snew(i).D = snew(i).E;
        snew(i).E = 0;
    end;
end;

% finally, find everyone who lacks cenx/ceny definitions and fill those in:
for i = 1:length(snew),
    if length(s(i).frames)>0,
        if length(s(i).cenx)==0,
            %disp(['adding cenx/ceny info to: ',num2str(i)]);
            snew(i) = addcenxceny(snew(i),s);
        end;
    end;
end;


function newschnitz = addcenxceny(schnitz,s)

newschnitz = schnitz;
for i = 1:length(newschnitz.frames),
    [Lc] = s(1).Lc_c(:,:,newschnitz.frames(i));
    [x,y] = find(Lc==schnitz.cellno(i));
    
    %newschnitz.cenx(i) = mean(y);
    %newschnitz.ceny(i) = mean(x);
end;