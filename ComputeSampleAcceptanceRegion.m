function [ Model ] = ComputeSampleAcceptanceRegion( Model )
%???
%   Detailed explanation goes here
K = Model.K;
S = Model.S;
RankAssociatedPortfolioReturns = Model.RankAssociatedPortfolioReturns;
RankAssociatedPortfolioRisk = Model.RankAssociatedPortfolioRisk;
AcceptanceRegionAlpha = Model.AcceptanceRegionAlpha;
AcceptanceRegionReturn = nan(K,1);
AcceptanceRegionRisk = nan(K,1);

for r=1:K
    if r==1
        AcceptanceRegionRisk(r) = Model.PortfolioRisk(r)/2;
        PortfolioList = find(RankAssociatedPortfolioRisk >= 0 & ...
            RankAssociatedPortfolioRisk < Model.PortfolioRisk(r));
    end
    if r>1
        AcceptanceRegionRisk(r) = (Model.PortfolioRisk(r-1)+...
            Model.PortfolioRisk(r))/2;
        PortfolioList = find(RankAssociatedPortfolioRisk >= ...
            Model.PortfolioRisk(r-1) &  RankAssociatedPortfolioRisk < Model.PortfolioRisk(r));
    end
    if ~isempty(PortfolioList)
        NumPortfolio = length(PortfolioList);
        AcceptenceLimit = floor(NumPortfolio*(1-AcceptanceRegionAlpha));
        ReturnList = RankAssociatedPortfolioReturns(PortfolioList);
        [SortedReturnList,OriginalPosition] = sort(ReturnList,1,'descend');
        if AcceptenceLimit ~= 0
            AcceptanceRegionReturn(r) = SortedReturnList(AcceptenceLimit);
        end
    end
end
Model.AcceptanceRegionReturn = AcceptanceRegionReturn;
Model.AcceptanceRegionRisk = AcceptanceRegionRisk;
return
