
% kill(kk)=Di(sc);
% kill(kk+1)=D
Pi=[s.P];

for i=1:length(Pi)
    Pind=1;
    ii=length(Pi)-i+1;
    kk=1;
    while Pind~=0;
        if kk==1
            trace1{i,1}(kk)=ii;
            Pind=ii;
        else
            trace1{i,1}(kk)=Pi(Pind);
            Pind=Pi(Pind);
        end
        kk=kk+1;
        %Pind=Pi(Pind);
    end
end

        
    
    