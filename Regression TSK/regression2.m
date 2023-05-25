%import dataset
dataset = csvread('superconduct.csv',1,0);
Rsq = @(ypred,y) 1-sum((ypred-y).^2)/sum((y-mean(y)).^2);

%split the dataset
[trnData,chkData,tstData] = split_scale(dataset,1);
%from 82 characteristics we chose the following
characteristics = [5 10 15 20 25 30];

%for clusters
clust = [0.1 0.2 0.3 0.4 0.5 0.6 0.8];

%initialize error with zeros
error = zeros(6,7);

%initialize number of rules
rules = zeros(6,7);
%preprocess with relieff
[idx, weight] = relieff(trnData(:, 1:end-1), trnData(:,end), 5);

%5fold cross validation initialization
crossvalid5 = cvpartition(trnData(:, end), 'KFold', 5);

%5fold cross validation script
for i=1:length(characteristics)
    for j=1:length(clust)
        err = 0;
        for k=1:5
            %clustering, i: number of features
            trainData1 = trnData(:,(1:idx(characteristics(i))));
            trainData2 = [trainData1 trnData(:,end)];
            validData1 = chkData(:,(1:idx(characteristics(i))));
            validData2 = [validData1 chkData(:,end)];

            %training, j: radius
            outfis = genfis2(trainData2(:,1:end-1),trainData2(:,end),clust(j));
            [trnFis,trnError,~,valFis,valError]=anfis(trainData2,outfis,[100 0 0.01 0.9 1.1],[],validData2);

            err = err + min(valError);
            
        end
        %save error and number of rules
        error(i,j) = sum(err(:))/5;
        rules(i,j) = size(showrule(outfis), 1);
    end
end

%find the minimum error
minimum = error(1,1);
row=1;
col=1;
for i=1:6
    for j=1:7
        if error(i,j) < minimum
            minimum = error(i,j);
            row = i;
            col = j;
        end
    end
end
%training, validation and testing

fis = genfis2(trnData(:,idx(1:characteristics(row))),trnData(:, end), clust(col));
[trnFis,trnError,~,valFis,valError] = anfis(trnData(:,[idx(1:characteristics(row)) end]), fis,...
         [100 0 0.01 0.9 1.1],[], chkData(:,[idx(1:characteristics(row)) end]));

Y = evalfis(tstData(:, idx(1:characteristics(row))), valFis);

%performace
R2=Rsq(Y,test_data(:,end));
RMSE=sqrt(mse(Y,tstData(:,end)));
mse_value = mse(tstData(:,end),Y);
var_original = var(tstData(:,end));
nmse = mse_value / var_original;
ndei = sqrt(nmse);

Perf = [R2;RMSE;nmse;ndei];

%learning curve
figure(1);
plot([trnError valError],'LineWidth',2); grid on;
xlabel('Number of Iterations'); ylabel('Error');
legend('Training Error','Validation Error');
title('ANFIS Hybrid Training - Validation');

%actual values vs predicted values plot
figure(2);
plot(tstData(:,end));
hold on;
plot(Y);
legend('actual','predicted');
hold off;
%plot membership functions
for j=1:size(trnData,2)-1
        figure(j+2);
        plotmf(checking_fis,'input',j);
end