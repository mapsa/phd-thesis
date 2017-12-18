
function f = AAR(X,T,L,gamma,TD,N_tr)
U=[];
d=[];
U_inv=zeros(TD,TD,N_tr);
c=0;
norma=[];
f=[];

A = gamma*eye(TD);
for i=1:N_tr
    U = [X(:,i)'; U];
    A = A + X(:,i)*X(:,i)';
    d = [T(i);d];
    w = A\U'*d;
    if i >= L
        f(i)=w'*X(:,i);
    end
end


