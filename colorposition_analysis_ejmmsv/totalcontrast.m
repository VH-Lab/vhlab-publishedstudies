function Tc=totalcontrast(Lc,Sc,l,s)

if sign(s)==sign(l),
	Tc = Lc + Sc;
else,
	Tc = abs(Sc-Lc);
end;
