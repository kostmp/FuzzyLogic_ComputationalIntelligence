%load the dataset
dataset = load('airfoil_self_noise.dat');
%split to training, validation and testing datasets and normalization of
%them
[trnData,chkData,tstData] = split_scale(dataset,1);

% Evaluation function - from sample code
Rsq = @(ypred,y) 1-sum((ypred-y).^2)/sum((y-mean(y)).^2);

Perf = zeros(4,4);
%Fis must be gbellmf and two are singletons and the other two are polynomials
Fis(1) = genfis1(trnData,2,'gbellmf','constant');
Fis(2) = genfis1(trnData,3,'gbellmf','constant');
Fis(3) = genfis1(trnData,2,'gbellmf','linear');
Fis(4) = genfis1(trnData,3,'gbellmf','linear');
%k: counter for all figures
k=1;
for i=1:4
    %train of model
    [trnFis,trnError,~,valFis,valError]=anfis(trnData,Fis(i),[100 0 0.01 0.9 1.1],[],chkData);
    %learning curve
    figure(k);
    k=k+1;
    plot([trnError valError],'LineWidth',2); grid on;
    xlabel('Number of Iterations'); ylabel('Error');
    legend('Training Error','Validation Error');
    title('ANFIS Hybrid Training - Validation');
    %test the model
    Y=evalfis(tstData(:,1:end-1),valFis);
    %metrics R2, RMSE, NMSE, NDEI
    R2=Rsq(Y,tstData(:,end));
    RMSE=sqrt(mse(Y,tstData(:,end)));
    %membership function plots
    for j=1:size(trnData,2)-1
        figure(k);
        k=k+1;
        plotmf(valFis,'input',j);
    end
    mse_value = mse(tstData(:,end),Y);
    var_original = var(tstData(:,end));
    nmse = mse_value / var_original;
    ndei = sqrt(nmse);
    %overal performance of the model
    Perf(i,:)=[R2 RMSE nmse ndei];
    %actual vs predicted plot
    figure(k);
    k=k+1;
    plot(tstData(:,end));
    hold on;
    plot(Y);
    legend('actual','predicted');
    hold off;
    %plot prediction error in histogram
    prediction_error = Y - tstData(:,end);
    pred = 100*(prediction_error./tstData(:,end));
    figure(k);
    k=k+1;
    histogram(pred);
end
