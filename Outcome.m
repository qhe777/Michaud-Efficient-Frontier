Ports=1:51;
%% Cost
plot(Ports,mean(Model.CostToTrade(:,37:199),2))
hold on
plot(Ports,mean(Model.CostToTradeToEfficientFrontier_KT(:,37:199),2))
plot(Ports,mean(Model.CostToTradeToResampledFrontier_KT(:,37:199),2))
legend('CostToTrade','Cost_Efficient Frontier','Cost_Resampled EF')
%% Return
plot(Ports,mean(Model.ReturnToTrade_KT(:,37:199),2))
hold on
plot(Ports,mean(Model.ReturnToTradeToEfficientFrontier(:,37:199),2))
plot(Ports,mean(Model.ReturnToTradeToSampledFrontier_KT(:,37:199),2))
legend('TetrunToTrade','Tetrun_Efficient Frontier','Tetrun_Resampled EF')


%% Risk
plot(Ports,mean(Model.EfficientFrontierRisk_KT(:,37:199),2))
hold on
plot(Ports,mean(Model.ResampledFrontierRisk_KT(:,37:199),2))
legend('Risk_Efficient Frontier','Risk_Resampled EF')

%% Profit

plot(Ports,mean(Model.ReturnToTrade_KT(:,37:199)-...
    0.1*Model.CostToTrade(:,37:199),2))
hold on
plot(Ports,mean(Model.ReturnToTradeToEfficientFrontier(:,37:199)-...
    0.1*Model.CostToTradeToEfficientFrontier_KT(:,37:199),2))
plot(Ports,mean(Model.ReturnToTradeToSampledFrontier_KT(:,37:199)-...
    0.1*Model.CostToTradeToResampledFrontier_KT(:,37:199),2))
legend('ProfitToTrade','Profit_Efficient Frontier','Profit_Resampled EF')