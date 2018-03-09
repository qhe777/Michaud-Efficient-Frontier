load IndexData
[T,m] = size(IndexDataMI.Returns);
LookBack = 36;
Model.CovarianceMethod = 2; %Sample covariance Matrix = 1, Ledoit covariance matrix=2
NumberPointsEfficientFrontier = 51;
%MVO
Model.Returns = IndexDataMI.Returns;
Model.EfficientFrontierWeights_KMT = nan(NumberPointsEfficientFrontier,m,T);
Model.EfficientFrontierReturn_KT = nan(NumberPointsEfficientFrontier,T);
Model.EfficientFrontierRisk_KT = nan(NumberPointsEfficientFrontier,T);
%Resampled
Model.ResampledFrontierWeights_KMT = nan(NumberPointsEfficientFrontier,m,T);
Model.ResampledFrontierReturn_KT = nan(NumberPointsEfficientFrontier,T);
Model.ResampledFrontierRisk_KT = nan(NumberPointsEfficientFrontier,T);

Model.CurrentWeight_KMT = nan(NumberPointsEfficientFrontier,m,T);
Model.CostToTrade_KT = nan(NumberPointsEfficientFrontier,T);
Model.CostToTradeToResampledFrontier_KT = nan(NumberPointsEfficientFrontier,T);
Model.CostToTradeToEfficientFrontier_KT = nan(NumberPointsEfficientFrontier,T);
Model.ReturnToTrade_KT = nan(NumberPointsEfficientFrontier,T);
Model.ReturnToTradeToResampledFrontier_KT = nan(NumberPointsEfficientFrontier,T);
Model.ReturnToTradeToEfficientFrontier_KT = nan(NumberPointsEfficientFrontier,T);

for p = LookBack:T
    disp(['BackTest for month' num2str(p)])
    MeanReturns = mean(IndexDataMI.Returns(p-LookBack+1:p,:))'; %36*17 to 17*1
    if Model.CovarianceMethod==1
        V = cov(IndexDataMI.Returns(p-LookBack+1:p,:));
    end
    if Model.CovarianceMethod==2
        V = covmarket2(IndexDataMI.Returns(p-LookBack+1:p,:));
    end
    Model.m = m; % #of assets
    Model.T = LookBack;
    Model.Freq = 12; %12 months per year
    Model.Er = MeanReturns; % expected return
    Model.V = V;
    Model.K = NumberPointsEfficientFrontier;
    Model.S = 100; %Number of simulation
    Model.AcceptanceRegionAlpha = 0.05;
    Model.UpperConfidenceBound = 0.05;
    Model.LowerConfidenceBound = 0.1;
    Model.NumberConfidenceBounds = 2;
    Model.Trace = 1; %1, 0 or otherwise
    Model.PrintCounter = 100; %Print messages after this count
    
    Model = Michaud(Model);
    Model = ComputeSampleAcceptanceRegion(Model);
    Model = ComputeConfidencerRegionTestStatistics(Model);
    
    Model.EfficientFrontierWeights_KMT(:,:,p) = Model.PortfolioWeights;
    Model.EfficientFrontierReturn_KT(:,p) = Model.PortfolioReturn;
    Model.EfficientFrontierRisk_KT(:,p) = Model.PortfolioRisk;
    
    Model.ResampledFrontierWeights_KMT(:,:,p) = Model.RankAssociatedPortfolioWeights_average;
    Model.ResampledFrontierReturn_KT(:,p) = Model.ResampledEfficientFrontier_Return;
    Model.ResampledFrontierRisk_KT(:,p) = Model.ResampledEfficientFrontier_Risk;
    
    %% Cost
    if p == LookBack
        Model.CurrentWeights_KMT(:,:,p) = Model.ResampledFrontierWeights_KMT(:,:,p);
    end
    if p ~= LookBack
        Model = ComputeCheapestToTrade(Model,p,1);
    end
end
save Results
