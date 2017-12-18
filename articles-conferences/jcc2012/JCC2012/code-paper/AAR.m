
function f = AAR(X,Y,gamma,TD,N)

f=zeros(N,1);
b=zeros(TD,1);
A = gamma*eye(TD);

for i=1:N
    A = A + X(:,i)*X(:,i)';
    f(i)=b'*(A\X(:,i));
    b = b + Y(i)*X(:,i);
end


