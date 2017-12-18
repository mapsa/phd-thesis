
clear all,
close all
clc


%=========Parameters ==============
gamma=0.1;
x = 10:10:1000;                  %Length sliding windows
error_f = zeros(length(x),1);
i=1;
nt=100;

%======Format data================

importfile('data_2000.csv');
index = 46;          %indice del activo a predecir
%data = data(1:200,1:10);
[N TD]=size(data);
data_n = zeros(N-1,TD);

%Convirtiendo a retornos
%dailyRV=100*diff(log(dailyPrices));

for i=1:TD
    data_n(:,i) = tick2ret(data(:,i));
end
data = data_n;
N=N-1;
TD=TD-1;

fprintf('Stock,AAR error, RR error, SLAAR error, Best L\n');
%for index=1:TD
    X = data';
    T=X(index,:)';       %Un precio de un activo se usará como target
    X(index,:)=[];      %Se elimina la información del activo
    
    aar = AAR(X,T,gamma,TD,N);
    rr = RR(X,T,gamma,TD,N);

    e_aar = norm(aar(end-nt:end)-T(end-nt:end));
    e_rr = norm(rr(end-nt:end)-T(end-nt:end));

    best_error = 100;
    best_L = 0;
    best_f = zeros(N-1,1);
    for L = x
        f = SLAAR(X,T,L,gamma,TD,N);
        error_f=norm(f(end-nt:end)-T(end-nt:end));
        if error_f < best_error
            best_error = error_f;
            best_L=L;
            best_f=f;
        end
    end
    
    fprintf('%s,%f,%f,%f,%d\n',char(colheaders(index)),e_aar,e_rr,best_error,best_L)
%end

results=[aar(end-nt:end) rr(end-nt:end) best_f(end-nt:end) T(end-nt:end)];
nt=70;
plot(1:nt+1,aar(end-nt:end),'s');
hold on;
plot(1:nt+1,rr(end-nt:end),'o');
hold on;
plot(1:nt+1,T(end-nt:end),'-');
hold on;
plot(best_f(end-nt:end),'*');
legend('AAR','RR','Target','Our method');
title('Comparison AAR,RR and proposal for SPY')
xlabel('Time')
ylabel('Return')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(1:nt+1,aar(end-nt:end),'s');
hold on;
plot(1:nt+1,T(end-nt:end),'-');
hold on;
legend('AAR','Target');
title('AAR performance for SPY')
xlabel('Time')
ylabel('Return')



plot(1:nt+1,rr(end-nt:end),'o');
hold on;
plot(1:nt+1,T(end-nt:end),'-');
hold on;
legend('RR','Target');
title('RR performance for SPY')
xlabel('Time')
ylabel('Return')



plot(1:nt+1,rr(end-nt:end),'o');
hold on;
plot(best_f(end-nt:end),'*');
legend('AAR','RR','Target','Our method');
title('Comparison AAR,RR and proposal for SPY')
xlabel('Time')
ylabel('Return')




