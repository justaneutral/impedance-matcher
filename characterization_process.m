%step 1 calibrating ku (V/V) ,ki (A/V) checking generator internal impedance
R = [10 20 30]
Uprobe = [12 22.4 32.8]
U = [128 160 192].*(1e-3)./sqrt(2)
I = [84 70 58].*(1e-3)./sqrt(2)
ku = Uprobe./U
ki = Uprobe./R./I
R = ku./ki.*U./I
ku = max(ku,300)
ki = max(ki,30)
X = ku./ki.*U./I
Pgenerator=10
Ugenerator = Pgenerator./ki./I./sqrt(2)
Zgenerator = Ugenerator./I - X
Zgenerator = 50

%step 2 define load impedance wariations
ResonanceFrequency_SerialCapacitance_LVoltage_Current_Voltage = [...
18e5 1.124e-9 0.376*ku 0.112*ki 2.24; ... % completely covered with metal on the winding side
18e5 0.437e-9 1.28*ku 0.112*ki 3.12; ... % 80% covered with metal on the winding side
18e5 0.319e-9 1.84*ku 0.112*ki 3.84; ... % 50% covered with metal on the winding side
18e5 0.265e-9 2.32*ku 0.112*ki 5.2; ... % 20% covered with metal on the winding side
18e5 0.261e-9 2.56*ku 0.108*ki 6; ... % completely covered with metal on the metal side
18e5 0.242e-9 2.72*ku 0.112*ki 6.4; ... % 80% covered with metal on the metal side
18e5 0.232e-9 2.8*ku 0.112*ki 6.4; ... % 50% covered with metal on the metal side
18e5 0.22e-9 2.88*ku 0.112*ki 6.8; ... % 20% covered with metal on the metal side
18e5 0.22e-9 3*ku 0.112*ki 6.8; ... % in free air
17e5 0.24e-9 2.8*ku 0.112*ki 5.6; ... % in free air
17e5 0.237e-9 2.64*ku 0.108*ki 5.6; ... % in free air
];
Frequency = ResonanceFrequency_SerialCapacitance_LVoltage_Current_Voltage(:,1)
Capacitance = ResonanceFrequency_SerialCapacitance_LVoltage_Current_Voltage(:,2)
Iload = ResonanceFrequency_SerialCapacitance_LVoltage_Current_Voltage(:,4)
Ureal = ResonanceFrequency_SerialCapacitance_LVoltage_Current_Voltage(:,5)
Rload = Ureal./Iload
Xload = 1./(2.*pi.*Frequency.*Capacitance)
Lload = Xload./(2.*pi.*Frequency)
LLoadRange = [min(Lload) max(Lload)]

%step 3 derive maximum and minimum of variable inductor
LballastMaxtoMinRatio = 0.061./0.021
Capacitance = 0.15e-9
Frequency = 1.7e6
XloadRange = 2.*pi.*Frequency.*LLoadRange
XballastRange = 1./(Capacitance.*2.*pi.*Frequency) - XloadRange
if min(XballastRange)<0 || min(XballastRange)<max(XballastRange)./LballastMaxtoMinRatio
    display('insufficient data: decrease capacitance or increase ballast max to min ratio')
    return
end
LballastRange = XballastRange./(2.*pi.*Frequency)

%step 5 calculate number of turns in semimatching autotransformer
SemiTurnRatio = 4
LballastRange1 = LballastRange.*SemiTurnRatio
L1 = 0.013e-3; % H
Turns1 = 27;
L2 = 0.027e-3; % H
Turns2 = Turns1 + 14;
sqrtlperturn = min(sqrt(L1)./Turns1,sqrt(L2)./Turns2)
Xautotransformer = 500
Lautotransformer = Xautotransformer./(2.*pi.*Frequency)
NTurnsAutotransformer = [1 SemiTurnRatio-1].*sqrt(Lautotransformer)./sqrtlperturn
