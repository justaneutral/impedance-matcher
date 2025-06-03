F = 1.7e6
Ll = [0.016e-3 0.041e-3]
C = 1./(Ll.*(2.*pi.*F).^2)
Llt = [0.074e-3 0.107e-3]
Ct = 1./(Llt.*(2.*pi.*F).^2)

Lltcalc = sqrt(50./8.5).*Ll
Lload = [min(min(Llt,Lltcalc)),max(max(Llt,Lltcalc))]

LballastRange = max(Lload)-min(Lload)
Lballast = [1.1 0.1].*LballastRange
L = Lload+Lballast
L = L(1)
C = 1./(L.*(2.*pi.*F).^2)
Ct = C.*sqrt(50./8.5)

Cexp = [0.22e-9 1.42e-9]
Xcexp = -1./(2.*pi.*F.*Cexp)
Xlexp = Xcexp-min(Xcexp)
Lexp = Xlexp./(2.*pi.*F)
