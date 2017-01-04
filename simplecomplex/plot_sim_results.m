function plot_sim_results(layer4ONinput,layer4OFFinput,i,j,plotsum)

if plotsum,

layer4input = layer4ONinput + layer4OFFinput;

plot(0:22.5:180,reshape(layer4input(i,j,:,1),1,9),'y');
hold on;
plot(0:22.5:180,reshape(layer4input(i,j,:,2),1,9),'g');
plot(0:22.5:180,reshape(layer4input(i,j,:,3),1,9),'m');
plot(0:22.5:180,reshape(layer4input(i,j,:,4),1,9),'r');
plot(0:22.5:180,reshape(layer4input(i,j,:,5),1,9),'b');
plot(0:22.5:180,reshape(layer4input(i,j,:,6),1,9),'k');

else,

subplot(2,2,1);
hold off;
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,1),1,9),'y');
hold on;
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,2),1,9),'g');
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,3),1,9),'m');
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,4),1,9),'r');
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,5),1,9),'b');
plot(0:22.5:180,reshape(layer4ONinput(i,j,:,6),1,9),'k');
title('Layer 4 ON input, c=[4 8 16 32 64 1]%');
A = axis;
axis([0 180 A(3) A(4)]);

subplot(2,2,3);
hold off;
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,1),1,9),'y--');
hold on;
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,2),1,9),'g--');
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,3),1,9),'m--');
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,4),1,9),'r--');
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,5),1,9),'b--');
plot(0:22.5:180,reshape(layer4OFFinput(i,j,:,6),1,9),'k--');
title('Layer 4 OFF input, c=[4 8 16 32 64 1]%');
axis([0 180 A(3) A(4)]);

end;
