%load dataset
dataset = load('haberman.data');

%training, validation and testing data
[trnData,chkData,tstData] = split_scale(dataset,1);

%two extreme values for cluster's radius for both dependent and independent
clust_rad = [0.15 0.85];

%initialize the errors and accuracy metrics for 4 models
error1 = zeros(4,1);
error2 = zeros(4,1);
error3 = zeros(4,1);
error4 = zeros(4,1);

%i: for every value of cluster's radius
for rad=1:2
    
    %Clustering Per Class, 1 and 2 are the two classes
    [c1,sig1]=subclust(trnData(trnData(:,end)==1,:),clust_rad(rad));
    [c2,sig2]=subclust(trnData(trnData(:,end)==2,:),clust_rad(rad));
    num_rules=size(c1,1)+size(c2,1);
    
    %Build FIS From Scratch
    fis=newfis('FIS_SC','sugeno');

    % Add Input-Output Variables
    names_in = {'in1','in2','in3'};
    for i = 1:size(trnData,2)-1
        fis = addvar(fis,'input',names_in{i},[0 1]);
    end
    fis = addvar(fis,'output','out1',[0 1]);
    
    % Add Input Membership Functions
    for i = 1:size(trnData, 2)-1
        for j = 1:size(c1, 1)
            fis = addmf(fis, 'input', i, strcat('in',int2str(j)), 'gaussmf', [sig1(i) c1(j, i)]);
        end
        for j = 1:size(c2, 1)
            fis = addmf(fis, 'input', i,strcat('in',int2str(j+53)), 'gaussmf', [sig2(i) c2(j, i)]);
        end
    end    
    
    % Add Output Membership Functions
    params = [zeros(1,size(c1,1)) ones(1,size(c2,1))];
    for i = 1:num_rules
        fis = addmf(fis,'output',1,strcat('out',int2str(i)),'constant',params(i));
    end
    
    %Add FIS Rule Base
    ruleList=zeros(num_rules,size(trnData,2));
    for i=1:size(ruleList,1)
        ruleList(i,:)=i;
    end
    ruleList=[ruleList ones(num_rules,2)];
    fis=addrule(fis,ruleList);
   

    %Train & Evaluate ANFIS
    [trnFis,trnError,~,valFis,valError]=anfis(trnData,fis,[100 0 0.01 0.9 1.1],[],chkData);
    plot([trnError valError],'LineWidth',2); grid on;
    legend('Training Error','Validation Error');
    xlabel('# of Epochs');
    ylabel('Error');
    Y=evalfis(tstData(:,1:end-1),valFis);
    Y=round(Y);
    diff=tstData(:,end)-Y;
    Acc=(length(diff)-nnz(diff))/length(Y)*100;

    %error matrix 2x2 because we have 2 classes, 1 and 2
    errMatrix = zeros(2,2);
    for i=1:2
        for j=1:2
            errMatrix(i,j) = sum((Y(:) == i) & (tstData(:,size(tstData,2)) == j));
        end
    end
    %overall accuracy
    summ = trace(errMatrix);
    overallAccuracy = summ/size(Y,1);

    %producer's accuracy and user's accuracy
    sumUsers = zeros(2,1);
    sumProducers = zeros(2,1);
    usersAccuracy = zeros(2,1);
    producersAccuracy = zeros(2,1);
    k = 0;
    for i=1:2
       for j = 1:2
           sumUsers(i) = sumUsers(i) + errMatrix(i,j);
           sumProducers(i) = sumProducers(i) + errMatrix(j,i);
       end
       usersAccuracy(i) = errMatrix(i,i)/sumUsers(i);
       producersAccuracy(i) = errMatrix(i,i)/sumProducers(i);
    end
    %Khat metric
    Khat = (size(Y,1)*trace(errMatrix)-sum(sumUsers.*sumProducers))/(size(Y,1)^2 - sum(sumUsers.*sumProducers));
    
    %membership function plots
    pl = 2;
    for j=1:size(trnData,2)-1
        figure(pl);
        pl=pl+1;
        plotmf(valFis,'input',j);
    end



    %Compare with Class-Independent Scatter Partition
    fisIndep=genfis2(trnData(:,1:end-1),trnData(:,end),clust_rad(rad));
    [trnFis,trnError,~,valFis1,valError]=anfis(trnData,fisIndep,[100 0 0.01 0.9 1.1],[],chkData);
    plot([trnError valError],'LineWidth',2); grid on;
    legend('Training Error','Validation Error');
    xlabel('# of Epochs');
    ylabel('Error');
    Yindep=evalfis(tstData(:,1:end-1),valFis1);
    Yindep=round(Yindep);
    diff=tstData(:,end)-Yindep;
    Acc=(length(diff)-nnz(diff))/length(Y)*100;

    %error matrix 2x2 because we have 2 classes, 1 and 2
    errMatrix2 = zeros(2,2);
    for i=1:2
        for j=1:2
            errMatrix2(i,j) = sum((Yindep(:) == i) & (tstData(:,size(tstData,2)) == j));
        end
    end
    %overall accuracy
    summ2 = trace(errMatrix2);
    overallAccuracy = summ2/size(Yindep,1);
     %producer's accuracy and user's accuracy
    sumUsers = zeros(2,1);
    sumProducers = zeros(2,1);
    usersAccuracy = zeros(2,1);
    producersAccuracy = zeros(2,1);
    k = 0;
    for i=1:2
       for j = 1:2
           sumUsers(i) = sumUsers(i) + errMatrix(i,j);
           sumProducers(i) = sumProducers(i) + errMatrix(j,i);
       end
       usersAccuracy(i) = errMatrix(i,i)/sumUsers(i);
       producersAccuracy(i) = errMatrix(i,i)/sumProducers(i);
    end
    %Khat metric
    Khat = (size(Y,1)*trace(errMatrix)-sum(sumUsers.*sumProducers))/(size(Y,1)^2 - sum(sumUsers.*sumProducers));
    
    %membership function plots
    pl = 2;
    for j=1:size(trnData,2)-1
        figure(pl);
        pl=pl+1;
        plotmf(valFis,'input',j);
    end  


end

