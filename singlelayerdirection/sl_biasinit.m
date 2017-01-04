function init = sl_biasinit(N)

 % if N>100, then use triplet-based bias -- no, it doesn't work, don't worry about it

filename = '/Volumes/Data2/singlelayermodel/triplet2/ml53.mat';
filename2 = '/Volumes/Data2/singlelayermodel/triplet4/ml867.mat';

g = load(filename);

N0 = N;

if N>100,
	g = load(filename2);
	N = N - 100; 
	bias_spots = [56 12 600];
else,
	bias_spots = [56 80 600 10 20 30];
end;

switch N,

	case 1,
		init = 1.01*g.out.gmaxes(:,1)';
	case 2,
		init = mean([g.out.gmaxes(:,1) g.out.gmaxes(:,bias_spots(1))],2)';
	case 3,
		init=g.out.gmaxes(:,bias_spots(1))';
	case 4,
		init=g.out.gmaxes(:,bias_spots(2))';
	case 5,
		init=g.out.gmaxes(:,bias_spots(3))';
	case {6,7,8,9},
		init = sl_biasinit(N0-4)';
		init2 = reshape(init,5,5);
		init3 = init2(:,end:-1:1);
		init = init3(:)';
	case 10,
		init=g.out.gmaxes(:,bias_spots(4))';
	case 11,
		init=g.out.gmaxes(:,bias_spots(5))';
	case 12,
		init=g.out.gmaxes(:,bias_spots(6))';
end;
