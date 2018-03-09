function [ Model ] = ComputeCheapestToTrade( Model,p,CriticalValueRow )
%Optimization
%   Detailed explanation goes here
V = Model.V;
K = Model.K;
S = Model.S;

ResampledFrontierWeights_KM = Model.ResampledFrontierWeights_KMT(:,:,p); %51*17
RankAssociatedPortfolioWeights = Model.RankAssociatedPortfolioWeights; %51*17*100
CurrentWeights_KM = Model.CurrentWeights_KMT(:,:,p-1);  %ResampledFrontierWeights_KMT(:,:,p-1)

for k=1:K
    CriticalValue = Model.ConfidenceRegionTestStatistic(CriticalValueRow,k);
    P0 = ResampledFrontierWeights_KM(k,:)';  %Target  ResampledFrontierWeights_KMT(:,:,p)  17*1
    P3 = CurrentWeights_KM(k,:)';   %Current  ResampledFrontierWeights_KMT(:,:,p-1)
    EFW = Model.PortfolioWeights(k,:)';
    Distance_S = nan(S,1);
    CostToTrade_S = ones(S,1)*1E10;
    for s=1:S
        P = RankAssociatedPortfolioWeights(k,:,s)'; %Target at simulation s
        Distance_S(s) = sqrt((P-P0)'*V*(P-P0));
        if Distance_S(s) <= CriticalValue % distance<=0.95
            CostToTrade_S(s) = sum((P3-P).^2);
            %CostToTrade_S(s) = sum(abs(P3-P));
        end
    end
    MinCost = min(CostToTrade_S);
    MinPort = find(min(CostToTrade_S)==MinCost);
    if length(MinPort)>1
        MinPort = MinPort(1);
    end
    CheapestToTrade = RankAssociatedPortfolioWeights(k,:,MinPort)';
    Model.CurrentWeights_KMT(k,:,p) = CheapestToTrade';
    Model.CostToTrade(k,p) = MinCost;
    Model.CostToTradeToResampledFrontier_KT(k,p) = sum((Model.ResampledFrontierWeights_KMT(k,:,p)...
        -Model.ResampledFrontierWeights_KMT(k,:,p-1)).^2);
    Model.CostToTradeToEfficientFrontier_KT(k,p) = sum((Model.EfficientFrontierWeights_KMT(k,:,p)...
        -Model.EfficientFrontierWeights_KMT(k,:,p-1)).^2);
    try
        Model.ReturnToTrade_KT(k,p) = Model.Returns(p+1,:)*Model.CurrentWeights_KMT(k,:,p)';
        Model.ReturnToTradeToSampledFrontier_KT(k,p) = Model.Returns(p+1,:)*P0;
        Model.ReturnToTradeToEfficientFrontier(k,p) = Model.Returns(p+1,:)*EFW;
    catch
    end
end
return

