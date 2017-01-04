function plotCEDEsinwaves


[Lc,Sc,Rc,RGB_plus,RGB_minus] = TreeshrewConeContrastsColorExchange(4);


x = 0:0.01:3;
y={};
for i=1:12,
    subplot(4,3,i);
    for j=1:3,
        y{j}=rescale(sin(2*pi*x),[-1 1],[RGB_minus(j,i) RGB_plus(j,i)],'noclip');
        y{j} = repmat(y{j},10,1);
    end;
    image(cat(3,y{1},y{2},y{3})); axis off;
end;

