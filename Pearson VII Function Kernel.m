clear;
clc

om=1;
sig=1;

F = @(X,Y)1./(1.+(((2.*sqrt(pdist2(X,Y,'euclidean').^2)).*(sqrt((2.^(1./om))-1))./sig)).^2).^om;

path('C:\Users\Salar\Downloads\Compressed\libsvm-3.22\matlab',path)

nn_inp_train=xlsread('C:\Users\Salar\Desktop\6 - T.xls','Train','A:D')';
nn_trg_train=xlsread('C:\Users\Salar\Desktop\6 - T.xls','Train','E:E')';
nn_inp_test=xlsread('C:\Users\Salar\Desktop\6 - V.xls','Test','A:D')';
nn_trg_test=xlsread('C:\Users\Salar\Desktop\6 - V.xls','Test','E:E')';

[inp_train,inS]=mapminmax(nn_inp_train,0,1);
[trg_train,outS]=mapminmax(nn_trg_train,0,1);
inp_test=mapminmax('apply',nn_inp_test,inS);
trg_test=mapminmax('apply',nn_trg_test,outS);

numTrain = size(inp_train',1);
numTest = size(inp_test',1);


K =  [ (1:numTrain)' , F(inp_train',inp_train')];
KK = [ (1:numTest)' , F(inp_test',inp_train')];

param = ['-q -s 3 -t 4', ' -c ', num2str(1), ' -p ', num2str(0.001)];
  model = svmtrain(trg_train', K, param);
  [predict_label, ~, ~] = svmpredict(trg_test', KK, model);
  
out_test=mapminmax('reverse',predict_label',outS);
R=corr(out_test',nn_trg_test')
MAE=mae(out_test,nn_trg_test)
RMSE=(mse(out_test,nn_trg_test))^0.5

  
  