%load the dataset
epil = csvread('epileptic_seizure_data.csv', 1, 1);

%selection of radius and characteristics
radius = [0.2 0.35 0.45 0.6 0.85];
charact = [6 10 20 30];
acc = zeros(4,5);

%preprocessing with relieff and split data
[idx, weight] = relieff(epil(:, 1:end-1), epil(:,end), 175);
[trnData,chkData,tstData] = split_scale(epil,1);

%5fold cross validation initialization
crossvalid5 = cvpartition(trnData(:, end), 'KFold', 5,'Stratify',true);

%for every characteristic and radius that we selected, perform training,
%validating and testing
for i=1:length(charact)
    for j=1:length(radius)
        %5fold  cross validation
        for k=1:5

            %create the fis object
            %first select which characteristics will get
            trainData1 = trnData(:,(1:idx(charact(i))));
            trainData2 = [trainData1 trnData(:,end)];
            validData1 = chkData(:,(1:idx(charact(i))));
            validData2 = [validData1 chkData(:,end)];     
            testData1 = tstData(:,(1:idx(charact(i))));
            testData2 = [testData1 tstData(:,end)];    
            
            %clustering with subclust for every class
            [c1, sig1] = subclust(trainData2(trainData2(:, end) == 1, :), radius(j));
            [c2, sig2] = subclust(trainData2(trainData2(:, end) == 2, :), radius(j));
            [c3, sig3] = subclust(trainData2(trainData2(:, end) == 3, :), radius(j));
            [c4, sig4] = subclust(trainData2(trainData2(:, end) == 4, :), radius(j));
            [c5, sig5] = subclust(trainData2(trainData2(:, end) == 5, :), radius(j));
            %number of rules
            numOfRules = size(c1, 1) + size(c2, 1) + size(c3, 1) + size(c4, 1) + size(c5, 1);    

            %build new fis object
            fis = newfis('FIS_SC', 'sugeno');

            %Add Input-Output variables
            %Add Input-Output Vaiables and Membership Functions
            for a=1:size(trainData2,2)-1
                name_in = "in" + int2str(a);
                fis = addInput(fis,[0,1], "Name",name_in);
                for b=1:size(c1,1)    
                    fis = addMF(fis, name_in, "gaussmf", [sig1(a) c1(b,a)]);
                end
                for b=1:size(c2,1)
                    fis = addMF(fis, name_in, "gaussmf", [sig2(a) c2(b,a)]);
                end
                for b=1:size(c3,1)
                    fis = addMF(fis, name_in, "gaussmf", [sig3(a) c3(b,a)]);
                end
                for b=1:size(c4,1)
                    fis = addMF(fis, name_in, "gaussmf", [sig4(a) c4(b,a)]);
                end
                for b=1:size(c5,1)
                    fis = addMF(fis, name_in, "gaussmf", [sig5(a) c5(b,a)]);
                end
            end
            fis = addOutput(fis, [0,1], "Name", "out1");

            %Add Output Membership Variables
            params = [zeros(1,size(c1,1)) 0.25*ones(1,size(c2,1)) 0.5*ones(1,size(c3,1)) 0.75*ones(1,size(c4,1)) ones(1,size(c5,1))];
            for i=1:numOfRules
                fis = addMF(fis, "out1", 'constant', params(i));
            end
            %Add FIS RuleBase
            ruleList = zeros(numOfRules, size(trainData2,2));
            for i=1:size(ruleList,1)
                ruleList(i,:) = i;
            end
            ruleList = [ruleList, ones(numOfRules,2)];
            fis = addrule(fis, ruleList);
            
            %training and evaluation
            [trnFis,trnError,~,valFis,valError]=anfis(trainData2,fis,[100 0 0.01 0.9 1.1],[],validData2);
            figure(1000);
            plot([trnError valError],'LineWidth',2); grid on;
            legend('Training Error','Validation Error');
            xlabel('# of Epochs');
            ylabel('Error');
            Y=evalfis(testData2(:,1:end-1),valFis);
            Y=round(Y);
            diff=testData2(:,end)-Y;
            Acc=(length(diff)-nnz(diff))/length(Y)*100;
            
            %we have 5 classes
            errMatrix = zeros(5,5);
            for a=1:5
               for b=1:5
                   errMatrix(a,b) = sum((Y(:) == a) & (tstData(:,size(tstData,2)) == b));
               end
            end
            %overall accuracy
            summ = trace(errMatrix);
            overallAccuracy = summ/size(Y,1);
            acc(i,j) = overallAccuracy;
            %producer's accuracy and user's accuracy
            sumUsers = zeros(5,1);
            sumProducers = zeros(5,1);
            usersAccuracy = zeros(5,1);
            producersAccuracy = zeros(5,1);
            for a=1:5
                for b = 1:5
                    sumUsers(a) = sumUsers(a) + errMatrix(a,b);
                    sumProducers(a) = sumProducers(a) + errMatrix(b,a);
                end
                usersAccuracy(a) = errMatrix(a,a)/sumUsers(a);
                producersAccuracy(a) = errMatrix(a,a)/sumProducers(a);
            end
            %Khat metric
            Khat = (size(Y,1)*trace(errMatrix)-sum(sumUsers.*sumProducers))/(size(Y,1)^2 - sum(sumUsers.*sumProducers));
            pl = 2;
            for j=1:size(trnData,2)-1
                figure(pl);
                pl=pl+1;
                plotmf(valFis,'input',j);
            end    



        end
    end
end
%find maximum overall accuracy and the No of characteristics and radius
maximumAccuracy = max(acc(:));
[ch,rad] = find(acc == maximumAccuracy);
