
function f = RRM(X,T,L,gamma,TD,N_tr)
U=[];
d=[];
U_inv=zeros(TD,TD,N_tr);
c=0;
norma=[];
f=[];

A = gamma*eye(TD);
for i=1:N_tr
    U = [X(:,i)'; U];
    d = [T(i);d];
    w = (U'*U+A)\U'*d;
    if i >= L
        f(i)=w'*X(:,i);
        A = A + X(:,i)*X(:,i)'- X(:,i-L+1)*X(:,i-L+1)';
        w = A\U'*d;
    end
end


