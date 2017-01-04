
v = [];
for i1=-1:1, for i2=-1:1, for i3=-1:1, for i4=-1:1,
	v(end+1,:) = [i1 i2 i3 i4];
end; end; end; end;

g = size(v,1);

bs = []; bm = []; triv = [];
for i=1:g,
	[bs(i),bm(i),triv(i)] = issamecolormodel(v(i,:),v(i,:),1);
end;

pos = find(triv<10);
v = v(pos,:);

Vs = {};

while size(v,1)>0,
	pos = 1;
	for i=2:size(v,1),
		[b1,m1] = issamecolormodel(v(1,:),v(i,:));
		if m1>8,
			[b2,m2] = issamecolormodel(v(i,:),v(1,:));
			if m2>8, pos(end+1) = i; end;
		end;
		i,
	end;
	Vs{end+1} = v(pos,:);
	v = v(setdiff(1:size(v,1),pos),:);
	size(v),
end;

Vh = {};

for i=1:length(Vs),
	i,
	for j=1:length(Vs),
		if i==j, Vh{j} = [];
		else,
			[b,m]=issamecolormodel(Vs{i}(1,:),Vs{j}(1,:));
			if m>8,
				if length(Vh)<j, Vh{j} = i; else, Vh{j}(end+1) = i; end;
			end;
		end;
	end;
end;

if 0,
m = []; b = [];
for g1=1:g, for g2=1:g1,
	[b(g1,g2),m(g1,g2)] = issamecolormodel(v(g1,:),v(g2,:));
end; end;
end;
