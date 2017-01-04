function dDI = deltaDI(dpbefore, dibefore, dpafter, diafter)

vec = 0;

for i=1:size(dpafter),
	vec = vec + exp(sqrt(-1)*2*pi*mod(dpbefore(i),180)/180);
end;

angori = mod(angle(vec/length(dpbefore)),2*pi)/2;

mydiff = angdiff(dpbefore'-angori*180/pi);
if length(find(mydiff<90))<length(find(dpbefore>90)),
    angori = angori + 180;
end;

angdir = angori;

I = find(angdiff(angdir-dpafter')>90);
diafter(I) = -diafter(I);

I = find(angdiff(angdir-dpbefore')>90);
dibefore(I) = -dibefore(I);

dDI = diafter - dibefore;