function [dpm] = di_train(dp,myang)

J = find(angdiff(myang-dp')<=90);

dpm = (length(J))/length(dp);



