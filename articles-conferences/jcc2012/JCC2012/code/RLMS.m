
function [f,f_r] = RLMS(X,T,L,gamma,TD,N_tr)
U=[];
d=[];
U_inv=zeros(TD,TD,N_tr);
c=0;
norma=[];
f=[];
f_r =[];

for i=1:N_tr
    if i <= L
        U = [X(:,i)'; U];
        d = [T(i);d];
        if i == L
            U_inv(:,:,i) = inv(U'*U + gamma*eye(TD));
            w = U_inv(:,:,i)*U'*d;
            w_r = U_inv(:,:,i)*U'*d;
            f(i)=w'*X(:,i);
            f_r(i)=w_r'*X(:,i);
        end
    else
        f(i)=w'*X(:,i);
        f_r(i)=w_r'*X(:,i);
        U=[X(:,i)';U(1:L-1,:)];                     %Updating U
        d=[T(i);d(1:L-1)];                          %Updating d
        
        A = X(:,i)*X(:,i)' - X(:,i-L)*X(:,i-L)';
        Delta = A*U_inv(:,:,i-1);
        Delt_inv = eye(TD)-Delta+Delta^2;             %Taylor expansion of (I+Delta)^{-1}
        B = U_inv(:,:,i-1)*Delt_inv;                  %Aproximation of inv(U(k+1)'*U(k+1))=B
        U_inv(:,:,i) = 2*B-B*(U'*U)*B;                %Improvement of the inverse calculation
        %U_inv(:,:,i)=inv(U'*U + gamma*eye(TD));
 
        norma(i-L) = norm(U_inv(:,:,i) - inv(U'*U + gamma*eye(TD))); %error of the approximation
        w = U_inv(:,:,i)*U'*d;                        %Calculo de w
        w_r = (U'*U + gamma*eye(TD))\U'*d;

    end
end


