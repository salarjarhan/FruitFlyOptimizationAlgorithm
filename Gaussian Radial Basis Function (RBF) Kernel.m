clc;
clear;
path('C:\Users\Salar\Downloads\Compressed\libsvm-3.22\matlab',path)

filename='D:\Project\river\vaniar\vandata.xls';
nn_inp_train=xlsread(filename,'Train','C:C')';
nn_trg_train=xlsread(filename,'Train','E:E')';
nn_inp_test=xlsread(filename,'Test','C:C')';
nn_trg_test=xlsread(filename,'Test','E:E')';

[inp_train,inS]=mapminmax(nn_inp_train,-1,1);
[trg_train,outS]=mapminmax(nn_trg_train,-1,1);
inp_test=mapminmax('apply',nn_inp_test,inS);
trg_test=mapminmax('apply',nn_trg_test,outS);


X_axis=10*rands(1,4);
Y_axis=10*rands(1,4);

maxgen=100;
sizepop=10;

for i=1:sizepop
    fx=2*rand()-1;
    fy=2*rand()-1;
    
    X1(i,:)=X_axis+fx;
    X2(i,:)=X_axis-fx;
    Y1(i,:)=Y_axis+fy;
    Y2(i,:)=Y_axis-fy;
    
end

X=[X1;X2];
Y=[Y1;Y2];

for i=1:sizepop*2
    
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
    %    pred=mapminmax('reverse',predict_label',outS);
    %        Smell(i)=(mse(pred,nn_trg_test))^0.5;
    Smell(i)=mse(predict_label,trg_test');
end

[bestSmell,bestindex]=min(Smell);

X_axis=X(bestindex,:);
Y_axis=Y(bestindex,:);
bestS=S(bestindex,:);
Smellbest=bestSmell;

for gen=1:maxgen
    gen
    for i=1:sizepop
        
        fx=2*rand()-1;
        fy=2*rand()-1;
        
        X1(i,:)=X_axis+fx;
        X2(i,:)=X_axis-fx;
        Y1(i,:)=Y_axis+fy;
        Y2(i,:)=Y_axis-fy;
        
    end
    
    X=[X1;X2];
    Y=[Y1;Y2];
    
    for i=1:sizepop*2
        
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
        %    pred=mapminmax('reverse',predict_label',outS);
        %        Smell(i)=(mse(pred,nn_trg_test))^0.5;
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


param = ['-q -s 3 -t 2', ' -c ', num2str(Cbest), ' -g ', num2str(gabest), ' -p ', num2str(ebest), ' -e ', num2str(tbest)];
model = svmtrain(trg_train', inp_train', param);
[predict_label, accuracy, dec_values] = svmpredict(trg_test', inp_test', model);
out_test=mapminmax('reverse',predict_label',outS);
R=corr(out_test',nn_trg_test')
MAE=mae(out_test,nn_trg_test)
RMSE=(mse(out_test,nn_trg_test))^0.5
gabest
ebest
Cbest
tbest
% xlswrite('D:\Project\river\prediction-foa1',out_test','van','A2');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',Cbest,'1','O12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',gabest,'1','P12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',ebest,'1','Q12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',tbest,'1','R12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',R,'1','S12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',RMSE','1','T12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',MAE','1','U12');