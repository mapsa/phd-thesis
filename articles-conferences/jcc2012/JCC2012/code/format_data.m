
function [X,T,X_te,T_te] = format_data(TD,np,N_tr,N_te)
load MK30                               %Load Mackey-Glass chaotic time series 5000 point
MK30 = MK30+np*randn(size(MK30));       %Adding white noise mean 0 and std=np
MK30 = MK30 - mean(MK30);               %Substracting
MK30 = MK30(1500:end);                  %Eliminando primeros 1500 datos

train_set = MK30(1:N_tr+TD);            
test_set = MK30(N_tr+1:N_tr+N_te+TD);

X = zeros(TD,N_tr);                     %Train Input vectors
T = train_set(TD+1:TD+N_tr);            %Train Targets

X_te = zeros(TD,N_te);                  %Test Input vectors
T_te = test_set(TD+1:TD+N_te);          %Test Targets

for k=1:N_tr
    X(:,k) = train_set(k:k+TD-1)';
end
for k=1:N_te
    X_te(:,k) = test_set(k:k+TD-1)';
end
