
clear all,
close all
clc

%======Format data=======

TD = 10;            %time delay (embedding) length
np =.04;            %noise std
N_tr = 1500;        %Training size
N_te = 100;         %Test size

[X,T,X_te,T_te] = format_data(TD,np,N_tr,N_te);

%=========Regularized LMS===================

%L=150;                                   %windows size
%gamma=0.01;                            %regularized parameter
%[f,f_r] = RLMS(X,T,L,gamma,TD,N_tr);
%aar = AAR(X,T,L,gamma,TD,N_tr);

T=T';
gamma=0.01;
x = 5:10:200;
i=1;
nt=80;
% for L = x
%     [f,f_r] = RLMS(X,T,L,gamma,TD,N_tr);
%     aar = AAR(X,T,L,gamma,TD,N_tr);
%     error_f(i)=norm(f(end-nt:end)-T(end-nt:end));
%     error_aar(i)=norm(aar(end-nt:end)-T(end-nt:end));
%     i=i+1;
% end


for L = x
    f = RRR(X,T,L,gamma,TD,N_tr);
    aar = AAR(X,T,L,gamma,TD,N_tr);
    error_f(i)=norm(f(end-nt:end)-T(end-nt:end));
    error_aar(i)=norm(aar(end-nt:end)-T(end-nt:end));
    i=i+1;
end




plot(x,error_f,'-rs');hold on;plot(x,error_aar,'-bs');
title('MSE');
legend('RRG','AAR');
xlabel('Windows size (L)');
ylabel('MSE');


% inicio=L;
% fin=L+20;
% 
% plot(f(inicio:fin),'-rs');hold on;
% %plot(f_r(inicio:fin),'-bs');hold on;
% plot(aar(inicio:fin),'-ms');hold on;
% plot(T(inicio:fin),'-gs');
% legend('RRG','AAR','Target')


% subplot(3,1,1);
% plot(f(inicio:fin),'-rs');hold on;
% plot(f_r(inicio:fin),'-bs');
% title('F App Inverse v/s F Real Inverse');
% 
% subplot(3,1,2);
% plot(f(inicio:fin),'-rs');hold on;
% plot(T(inicio:fin),'-bs');
% title('Function v/s Target');
% 
% subplot(3,1,3);
% plot(abs(f(inicio:fin)-T(inicio:fin)'),'-bs');
% title('Function - Target');