function [ Model ] = ComputeConfidencerRegionTestStatistics( Model )
%COMPUTECONFIDENCERREGIONTESTSTATISTICS Summary of this function goes here
%   Detailed explanation goes here
m = Model.m;
T = Model.T;
Freq = Model.Freq;
Er = Model.Er;
V = Model.V;
K = Model.K;
S = Model.S; %100
AcceptanceRegionAlpha = Model.AcceptanceRegionAlpha;
UpperConfidenceBound = Model.UpperConfidenceBound;
LowerConfidenceBound = Model.LowerConfidenceBound;
NumberConfidenceBounds = Model.NumberConfidenceBounds; %2
Model.Trace = 1; %1, 0 or otherwise
Model.PrintCounter = 100; %Print messages after this count

RankAssociatedPortfolioWeights = Model.RankAssociatedPortfolioWeights;  %51*17*100
RankAssociatedPortfolioWeights_average = Model.RankAssociatedPortfolioWeights_average;  %51*17
ConfidenceBoundIncr = (UpperConfidenceBound-LowerConfidenceBound)/(NumberConfidenceBounds-1); % -0.05
Model.ConficenceRegionTestStatistic = nan(NumberConfidenceBounds,K);
Model.ConficenceRegionMemberReturn = nan(NumberConfidenceBounds,K,S);
Model.ConficenceRegionMemberRisk = nan(NumberConfidenceBounds,K,S);
Model.ConficenceRegionMemberDistance = nan(NumberConfidenceBounds,K,S);


Model.ConfidenceBounds = nan(NumberConfidenceBounds,1);  %???
for c=1:NumberConfidenceBounds
    CurrentConfidenceBound = LowerConfidenceBound+(c-1)*ConfidenceBoundIncr;    
    Model.ConfidenceBounds(c) = CurrentConfidenceBound;
   %compute distance between simulated portfolios and portfolio k on
   %resample frontier
   for k=1:K
       P0 = RankAssociatedPortfolioWeights_average(k,:)';
       Distance_S = nan(S,1);
       Return_S = nan(S,1);
       Risk_S = nan(S,1);
       for s=1:S
           P = RankAssociatedPortfolioWeights(k,:,s)';
           Distance_S(s) = sqrt((P-P0)'*V*(P-P0)); %Annulized vol difference
           Return_S(s) = Freq*(Er'*P);
           Risk_S(s) = sqrt(Freq*P'*V*P);
       end
       Distances = vec(Distance_S); 
       [SortedValues,Index] = sort(Distances);
       NumSortedValues = length(SortedValues);
       Cutoff = floor(NumSortedValues*(1-CurrentConfidenceBound)); % <=0.95  colsest 95%
       if Cutoff == 0
           Cutoff = 1;
       end
       Model.ConfidenceRegionTestStatistic(c,k) = SortedValues(Cutoff);
       Model.ConficenceRegionMemberReturn(c,k,1:Cutoff) = Return_S(Index(1:Cutoff));
       Model.ConficenceRegionMemberRisk = Risk_S(Index(1:Cutoff));
   end
end
return



function Y_big = vec(Y)
% Vectorizaztion
[~,M] = size(Y);
Y_big = Y(:,1);
j = 2;
while (j <=M)
    Y_big = [Y_big;Y(:,j)];
    j = j+1;
end
return

