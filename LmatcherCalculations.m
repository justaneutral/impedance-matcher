% teflon (thread sealing tape) for HF isolation.

% RG-59 
% 20-gauge solid copper center conductor and a single braided copper shield. 
% At 1000 MHz, RG-59 has a loss of 12 decibels (dB) per 100 feet, 
% an inductance of .131 microhenrys (uH) and 
% a capacitance of 20.5 picofarads (pF) per foot.
% a DC resistance 49.0 ohms per 1000 feet on the center conductor
% and 2.6 ohms per 1000 feet on the shield.

% RG-6 
% 18-gauge solid copper center conductor, a braided copper shield and an additional foil shield.
% At 1000 MHz, RG-6 has a loss of 7 dB per 100 feet, 
% an inductance of .097 uH and 
% a capacitance of 16.3 pF per foot.
% a DC resistance of 6.5 ohms per 1000 feet on the center conductor 
% and 9 ohms per 1000 feet on the shield.


%Matson TLT transformer:

% Input: 
% 8.5 Ohm - 0.195 mH = 1.95e-4 H
% 13 Ohm  - 0.124 mH = 1.24e-4 H
% 17 Ohm  - 0.098 mH = 9.8e-5 H
% 23 Ohm  - 0.071 mH = 7.1e-5 H
% 29 Ohm  - 0.057 mH = 5.8e-5 H
% Output:
% phase to ground (middle) 0.008 mH = 8e-6 H
% between phases: 0.034 mH = 3.4e-5 H
% 
% Matson Blin:
% 
Blin_L = [1.4e-5 3.7e-5] % H
Blin_C_ballast = 0.161e-9 % 6.14e-9 ./ 32 % F = 6.14 nF
Blin_resonance_frequency_kHz = 1e-3./(2.*pi.*sqrt(Blin_L.*Blin_C_ballast))

% 
% 
Freq = 2e6 % Hz
% 
% Calculated Impedance = 2*pi*Freq*L = 1.257e5 * 1.4e-5...3.7e-5 = 1.8...5 Ohm
% 
% 
% Impedance with plasma = 4...20 Ohm.
% 
% 
% Valera's based coil:
% 
% 12 turns = 0.351 mH
Henry_per_turnsquare_valera = sqrt(351e-6)./12
% 
% L drops 10 times at Imagnetization = 2.2A
% 
% 
% My coil on Amidon ferrites:
% 
% 0.02 mH = 2e-5 H
% 
% 2.73 mh on 80 turns
% 
Henry_per_turnsquare_amidon = sqrt(273e-5)./80
current_number_of_turns_on_amidon = sqrt(2e-5)./Henry_per_turnsquare_amidon
% 
% 
% Transformator transformation coefficient:
% 
% Nmax = sqrt(50 / 4...20) = 7.07 / 2 = 4/4...16/4 = 4+16*x / 4+4*x, x = 0.1..1
% 
% 
% 
% 
% 
% Transformer induction:


% Rs - source internal resistance
% Rl - load resistance

Rs = 50 % Ohm
Rl = [2:40] % Ohm
%C_ballast_nF = 0.25
C_ballast_nF = 0.614
%C_ballast_nF = 0.31

if Rl>Rs % shunt || to load
    %Q = sqrt(Rl./Rs -1)
    %Rl2Rs = 1+Q.^2
    %Xl2Xs = (1+Q.^2)./Q.^2
    Xl2Xs = (Rl./Rs)./(Rl./Rs-1)
    
else     % shunt || to source
    %Q = sqrt(Rs./Rl -1)
    %Rs2Rl = 1+Q.^2
    %Xs2Xl = (1+Q.^2)./Q.^2
    %(Rs.*1i.*Xs)./(Rs+1i.*Xs)=Rl-1i.*Xl
    Xs = Rs./(sqrt((Rs./Rl) - 1))
    Xl = -1.*Xs.*(Rs.^2)./((Rs.^2)+(Xs.^2))

end
%Xsmin = min(Xs)
%Xsmax = max(Xs)

Xlmin = min(Xl)
max(Xs)./min(Xs)
max(Xl)./min(Xl)

L_shunt_uH = round(1e8 .* Xs./(2.*pi.*Freq))./1e2
C_ballast_max_nF = 1e9./(2.*pi.*Freq.*abs(Xlmin))
if(C_ballast_nF > C_ballast_max_nF)
    C_ballast_nF = C_ballast_max_nF
end
Xc_bal = -1e9./(2.*pi.*Freq.*C_ballast_nF)
L_ballast_uH = round(1e8 .* (Xl-Xc_bal)./(2.*pi.*Freq))./1e2

P = 500; % Powr, Watts P=UI=UU/R -> UU=PR; P=IIXs -> II=P/Xs
U_shunt_V = sqrt(P.*Rs)
I_shunt_A = U_shunt_V./Xs
I_load_A = U_shunt_V./abs(Rl+1i.*(2e-6.*pi.*Freq.*L_ballast_uH - 1./(2e-9.*pi.*Freq.*C_ballast_nF)))
U_L_ballast_V = I_load_A .* (2e-6.*pi.*Freq.*L_ballast_uH)
U_C_ballast_V = I_load_A ./ (2e-9.*pi.*Freq.*C_ballast_nF)
U_load_V = I_load_A .* Rl
P_load_W = I_load_A .* U_load_V

wire_gauges_AWG_Dmm_Asqmm_Rohmperkm_Wkgpwrkm=[...
12 2.0525 3.3087729 5.2107 29.415;
13 1.8278 2.6239762 6.5706 23.3271; 
14 1.6277 2.0809077 8.2853 18.4993 ;
15 1.4495 1.6502348 10.4476 14.6706 ;
16 1.2908 1.3086957 13.1742 11.6343 ;
17 1.1495 1.0378429 16.6123 9.2264 ;
18 1.0237 0.8230468 20.9478 7.3169 ;
19 0.9116 0.6527058 26.4147 5.8026 ;
20 0.8118 0.5176192 33.3083 4.6016 ;
21 0.7229 0.4104907 42.0009 3.6493 ;
22 0.6438 0.3255339 52.9622 2.894 ;
23 0.5733 0.2581602 66.7841 2.295 ;
24 0.5106 0.2047303 84.2132 1.8201 ;
25 0.4547 0.1623585 106.1909 1.4434 ;
26 0.4049 0.1287562 133.9043 1.1446 ;
27 0.3606 0.1021083 168.8502 0.9077 ;
28 0.3211 0.0809755 212.9161 0.7199 ;
29 0.2859 0.0642165 268.4823 0.5709 ;
30 0.2546 0.050926 338.5499 0.4527 ;
31 0.2268 0.0403862 426.9036 0.359 ;
32 0.2019 0.0320277 538.3155 0.2847 ;
33 0.1798 0.0253991 678.8033 0.2258 ;
34 0.1601 0.0201424 855.9551 0.1791 ;
35 0.1426 0.0159737 1079.3395 0.142 ;
36 0.127 0.0126677 1361.0219 0.1126 ;
37 0.1131 0.0100459 1716.217 0.0893 ;
38 0.1007 0.0079668 2164.1097 0.0708 ;
39 0.0897 0.0063179 2728.8919 0.0562 ;
40 0.0799 0.0050104 3441.0692 0.0445 ];

% skin depth at Freq.
pho = 1.68e-8 % conductivity of copper O/m
mu_r = 0.999994 % relative permeability of copper
mu_0 = 4e-7.*pi % vacuum permeability Vs/A/m=H/m=N/A/A=Tm/A=Wb/A/m 
skin_depth_mm = 1e3.*sqrt(2.*pho./(2.*pi.*Freq.*mu_r.*mu_0))
wire_table_index = 1
Wire_diameter_mm = wire_gauges_AWG_Dmm_Asqmm_Rohmperkm_Wkgpwrkm(wire_table_index,2)
Effective_crossection_mmsq = pi.*(Wire_diameter_mm./2-skin_depth_mm).^2
Effective_current_density = max(max(abs(I_load_A)),max(abs(I_shunt_A)))./Effective_crossection_mmsq

hpt = [Henry_per_turnsquare_valera Henry_per_turnsquare_amidon];
L_shunt_turns = sqrt(max(1e-6.*L_shunt_uH))./hpt
L_ballast_turns = sqrt(max(1e-6.*L_ballast_uH))./hpt

Cbnf_Lmax_b_mh_Lmax_s_mh=[C_ballast_nF max(L_ballast_uH)./1000 max(L_shunt_uH)./1000]
Cbnf_Lmin_b_mh_Lmin_s_mh=[C_ballast_nF min(L_ballast_uH)./1000 min(L_shunt_uH)./1000]

U_shunt_V_min_max = [min(U_shunt_V) max(U_shunt_V)]
I_shunt_A_min_max = [min(I_shunt_A) max(I_shunt_A)]
I_load_A_min_max = [min(I_load_A) max(I_load_A)]
U_L_ballast_V_min_max = [min(U_L_ballast_V) max(U_L_ballast_V)]
U_C_ballast_V_min_max = [min(U_C_ballast_V) max(U_C_ballast_V)]
U_load_V_min_max = [min(U_load_V) max(U_load_V)]
