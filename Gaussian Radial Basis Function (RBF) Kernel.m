clc;
clear;

%Set path of the LIBSVM toolbox
path('C:\libsvm-3.22\matlab',path)

%Insert the data and divide it to train and test 
filename='C:\Project\river\data.xls';
nn_inp_train=xlsread(filename,'Train','C:C')';
nn_trg_train=xlsread(filename,'Train','E:E')';
nn_inp_test=xlsread(filename,'Test','C:C')';
nn_trg_test=xlsread(filename,'Test','E:E')';

%Normalization or rescale the input data 
%It is important to select the range of new scale carefully 
[inp_train,inS]=mapminmax(nn_inp_train,-1,1);
[trg_train,outS]=mapminmax(nn_trg_train,-1,1);
inp_test=mapminmax('apply',nn_inp_test,inS);
trg_test=mapminmax('apply',nn_trg_test,outS);

%Initial swarm location
%Location Range (LR)
X_axis=10*rands(1,4);
Y_axis=10*rands(1,4);


maxgen=200; %Maximum iteration number
sizepop=20; %Population size

%Initial Run
for i=1:sizepop
    
    %Unexpected search direction and distance for foraging of the fruit flies
    %Flight Range (FR)
    X(i,:)=X_axis+2*rand()-1;
    Y(i,:)=Y_axis+2*rand()-1;
    
    %The distance to the origin
    D(i,1)=(X(i,1)^2+Y(i,1)^2)^0.5;
    D(i,2)=(X(i,2)^2+Y(i,2)^2)^0.5;
    D(i,3)=(X(i,3)^2+Y(i,3)^2)^0.5;
    D(i,4)=(X(i,4)^2+Y(i,4)^2)^0.5;
    
    %The smell concentration judgment value
    S(i,1)=1/D(i,1);
    S(i,2)=1/D(i,2);
    S(i,3)=1/D(i,3);
    S(i,4)=1/D(i,4);
    
    %Several parameters of the SVR which have to be optimized
    %Please consider that each Kernel Function has its own parameters
    %See README for more information
    C=100*S(i,1);
    e=S(i,2)/10;
    ga=S(i,3)*10;
    t=S(i,4)/10;
    
    %Run SVR 
    param = ['-q -s 3 -t 2', ' -c ', num2str(C), ' -g ', num2str(ga), ' -p ', num2str(e), ' -e ', num2str(t)];
    model = svmtrain(trg_train', inp_train', param);
    [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
    %Calculation of Objective Function
    Smell(i)=mse(predict_label,trg_test');
end

%Optimum smell concentration
[bestSmell,bestindex]=min(Smell);
%Correction for swarm location
X_axis=X(bestindex,:);
Y_axis=Y(bestindex,:);
bestS=S(bestindex,:);
Smellbest=bestSmell;

%Main Run
for gen=1:maxgen
    gen
    for i=1:sizepop
        
        X(i,:)=X_axis+2*rand()-1;
        Y(i,:)=Y_axis+2*rand()-1;

        D(i,1)=(X(i,1)^2+Y(i,1)^2)^0.5;
        D(i,2)=(X(i,2)^2+Y(i,2)^2)^0.5;
        D(i,3)=(X(i,3)^2+Y(i,3)^2)^0.5;
        D(i,4)=(X(i,4)^2+Y(i,4)^2)^0.5;
        
        S(i,1)=1/D(i,1);
        S(i,2)=1/D(i,2);
        S(i,3)=1/D(i,3);
        S(i,4)=1/D(i,4);
        
        C=100*S(i,1);
        e=S(i,2)/10;
        ga=S(i,3)*10;
        t=S(i,4)/10;
        
        param = ['-q -s 3 -t 2', ' -c ', num2str(C), ' -g ', num2str(ga), ' -p ', num2str(e), ' -e ', num2str(t)];
        model = svmtrain(trg_train', inp_train', param);
        [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
        
        Smell(i)=mse(predict_label,trg_test');
    end
    
    [bestSmell,bestindex]=min(Smell);
    
    if bestSmell<Smellbest
        X_axis=X(bestindex,:);
        Y_axis=Y(bestindex,:);
        bestS=S(bestindex,:);
        Smellbest=bestSmell;
        Cbest=100*S(bestindex,1);
        ebest=S(bestindex,2)/10;
        gabest=S(bestindex,3)*10;
        tbest=S(bestindex,4)/10;
    end
    
    %Save the optimum results for each run
    yy(gen)=Smellbest;
    Xbest(gen,:)=X_axis;
    Ybest(gen,:)=Y_axis;
end

figure(1)
plot(yy)
title('Optimization process','fontsize',12)
xlabel('Iteration Number','fontsize',12);ylabel('MSE','fontsize',12);

figure(2)
plot(Xbest(:,1),Ybest(:,1),'b.');
title('Fruit fly flying route','fontsize',14)
xlabel('X-axis','fontsize',12);ylabel('Y-axis','fontsize',12);

%Run SVR with the best results
param = ['-q -s 3 -t 2', ' -c ', num2str(Cbest), ' -g ', num2str(gabest), ' -p ', num2str(ebest), ' -e ', num2str(tbest)];
model = svmtrain(trg_train', inp_train', param);
[predict_label, accuracy, dec_values] = svmpredict(trg_test', inp_test', model);
out_test=mapminmax('reverse',predict_label',outS);

%Compare the differences between simulation and observation
R=corr(out_test',nn_trg_test');
MAE=mae(out_test,nn_trg_test);
RMSE=(mse(out_test,nn_trg_test))^0.5;

%Show the optimized values
disp([gabest, ebest, Cbest, tbest])

%Save the best simulation result
xlswrite('D:\Project\river\Result-FOASVR',out_test');
