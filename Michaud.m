function Model = Michaud( Model )
%Michaud Resampled Efficient Producere

m = Model.m;
T = Model.T;
Freq = Model.Freq;
Er = Model.Er;
V = Model.V;
K = Model.K;
S = Model.S; %100
Trace = Model.Trace;
PrintCounter = Model.PrintCounter;

%% Step 1-3
% Efficient Frontier
f=[];
A=[];
b=[];
Options = optimset('quadprog');
Options = optimset(Options,'Display','off','Largescale','off');
X0 = [];
Aeq = ones(1,m); %Equality constraints
LB = zeros(m,1)'; %Long-only Portfolio
UB = [];
beq = 1;
h = quadprog(V,f,A,b,Aeq,beq,LB,UB,X0,Options); %Compute min variance long portflio with full investment
L = h'*Er;    %return to min volatility
H = max(Er)'; %return to max volatility

ReturnIncr = (H-L)/(K-1);
PortfolioWeights = nan(K,m);
PortfolioReturn = nan(K,1);
PortfolioRisk = nan(K,1);
for Port=1:K
    if rem(Port, PrintCounter)==0 && Trace == 1
        disp(['Efficient frontier portfolio ' num2str(Port) ' of ' num2str(K)])
    end
    Required_return = L+(Port-1)*ReturnIncr;
    Aeq = [ones(m,1),Er]';
    beq = [1;Required_return];
    h = quadprog(V,f,A,b,Aeq,beq,LB,UB,X0,Options);
    PortfolioWeights(Port,:) = h';
    PortfolioReturn(Port,1) = Required_return*Freq;
    PortfolioRisk(Port,1) = sqrt((h'*V*h)*Freq);
end

%% Step 4
%Resample the weights on efficient frontier

RankAssociatedPortfolioWeights = zeros(K,m,S);
RankAssociatedPortfolioReturns = zeros(K,S);
RankAssociatedPortfolioRisk = zeros(K,S);
RankAssociatedPortfolioWeights_average = zeros(K,m);
RankAssociatedPortfolioWeights_stderror = zeros(K,m);
RankAssociatedPortfolioWeights_5thpercentile = zeros(K,m);
RankAssociatedPortfolioWeights_95thpercentile = zeros(K,m);
RankAssociatedPortfolioWeihts_Tstatistic = zeros(K,m);
for s=1:S
%     if rem(S, PrintCounter)==0 && Trace == 1
%         disp(['Resampling Simulation = ' num2str(s) ' of ' num2str(S)])
%     end
    X_star = mvnrnd(Er, V, T);
    Er_star = mean(X_star)';
    if Model.CovarianceMethod==1
        V_star= cov(X_star);
    end
    if Model.CovarianceMethod==2
        V_star = covmarket2(X_star);
    end
    beq = 1;
    Aeq = ones(1,m);
    LB = zeros(1,m);
    h = quadprog(V_star,f,A,b,Aeq,beq,LB,UB,X0,Options);
    L_star = h'*Er_star;
    H_star = max(Er_star)';
    ReturnIncr_star = (H_star-L_star)/(K-1);
    Aeq=[ones(m,1),Er_star]';
    
    for Port=1:K
%         disp(['Simulation = ' num2str(s) ' Portfolio ' num2str(Port)])
        Required_return_star = L_star+(Port-1)*ReturnIncr_star;
        beq = [1;Required_return_star];
        h = quadprog(V_star,f,A,b,Aeq,beq,LB,UB,X0,Options);
        RankAssociatedPortfolioWeights(Port,:,s) = h';
        RankAssociatedPortfolioReturns(Port,s) = Freq*h'*Er;  %expected return from 
                                            % bootstrap weights and original return
        RankAssociatedPortfolioRisk(Port,s) = sqrt((h'*V*h)*Freq);
        RankAssociatedPortfolioWeights_average(Port,:) = ...
            RankAssociatedPortfolioWeights_average(Port,:)+h';
    end
end
RankAssociatedPortfolioWeights_average = RankAssociatedPortfolioWeights_average./S;

%% Step 5
%Form the Resampled Efficient Frontier
ResampledEfficientFrontier_Weights=RankAssociatedPortfolioWeights_average;
ResampledEfficientFrontier_Return = nan(K,1);
ResampledEfficientFrontier_Risk = nan(K,1);
for k=1:K
    ResampledEfficientFrontier_Return(k) = (Freq*RankAssociatedPortfolioWeights_average(k,:)*Er);
    ResampledEfficientFrontier_Risk(k) = ...
        sqrt(Freq*Freq*RankAssociatedPortfolioWeights_average(k,:)*V...
        *Freq*RankAssociatedPortfolioWeights_average(k,:)');
end

%% Result
%Efficient Frontier
Model.PortfolioReturn = PortfolioReturn;
Model.PortfolioRisk = PortfolioRisk;
Model.PortfolioWeights = PortfolioWeights;

Model.RankAssociatedPortfolioWeights = RankAssociatedPortfolioWeights;
Model.RankAssociatedPortfolioReturns = RankAssociatedPortfolioReturns;
Model.RankAssociatedPortfolioRisk = RankAssociatedPortfolioRisk;
Model.RankAssociatedPortfolioWeights_average = RankAssociatedPortfolioWeights_average;
Model.RankAssociatedPortfolioWeights_stderror = RankAssociatedPortfolioWeights_stderror;
Model.RankAssociatedPortfolioWeights_5thpercentile = RankAssociatedPortfolioWeights_5thpercentile;
Model.RankAssociatedPortfolioWeights_95thpercentile = RankAssociatedPortfolioWeights_95thpercentile;
Model.RankAssociatedPortfolioWeihts_Tstatistic = RankAssociatedPortfolioWeihts_Tstatistic;

%Resampled efficient frontier
Model.ResampledEfficientFrontier_Weights = ResampledEfficientFrontier_Weights;
Model.ResampledEfficientFrontier_Return = ResampledEfficientFrontier_Return; % it =
                                                           % mean(Model.RankAssociatedPortfolioReturns,2)
Model.ResampledEfficientFrontier_Risk = ResampledEfficientFrontier_Risk;
return

