function [dpm] = dpmatch(dp,myang)

J = find(angdiff(myang-dp')<=90);

dpm = (length(J))/length(dp);



