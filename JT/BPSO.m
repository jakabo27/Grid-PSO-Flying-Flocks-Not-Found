function [gBest,gBestScore, ConvergenceCurve]= BPSO(obj, noP, Max_iteration, target)
%Initial Parameters for PSO
tic
wMax=0.9;         %Max inirtia weight
wMin=0.4;         %Min inirtia weight
c1=2;
c2=2;

Velocity=zeros(noP,noH);%Velocity vector
Position=zeros(noP,noH);%Position vector

ConvergenceCurve=zeros(1,Max_iteration); %Convergence vector

for i=1:size(Position,1) % For each particle
    for j=1:size(Position,2) % For each variable
        if rand<=0.5
            Position(i,j)=0;
        else
            Position(i,j)=1;
        end
    end
end

pBest = Position;
result = zeros(noP,1);
for j= 1:noP
    result(j,1) = obj.fitness(obj, Position(j,:), target); %Calculate cost for each particle
end

pBestScore = result;
[gBestScore,i] = min(pBestScore);
gBest = pBest(i,:);

w = wMax;
delta_w = (wMax - wMin)/Max_iteration;
for l=1:Max_iteration
    
        w = w - delta_w;
        Velocity = w*Velocity + c1*rand([noP,noH]).*(pBest - Position) + ...
                  c2*rand([noP, noH]).* (repmat(gBest,[noP,1])- Position);
        s=1./(1+exp(-Velocity));
        Position = rand(noP,noH)< s;
                
        for j= 1:noP
            result(j,1) = obj.fitness(obj, Position(j,:), target); %Calculate cost for each particle
        end
        
        for k = 1:1:noP
            if(result(k) < pBestScore(k)) %selection of the local bests. Similar to what is done for global best. 
                pBestScore(k) = result(k);
                pBest(k,:) = Position(k,:);
            end
        end
        if(min(pBestScore) < gBestScore)
            [gBestScore,i] = min(pBestScore);
            gBest = pBest(i,:);
        end
        
     ConvergenceCurve(l)=gBestScore;       
end
end