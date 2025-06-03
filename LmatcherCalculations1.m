Blin_L = [1.4e-5 3.7e-5] % H
Blin_C_ballast = 0.161e-9 % 6.14e-9 ./ 32 % F = 6.14 nF
Blin_resonance_frequency_kHz = 1e-3./(2.*pi.*sqrt(Blin_L.*Blin_C_ballast))
Freq = 2e6 % Hz
Henry_per_turnsquare_valera = sqrt(351e-6)./12
Henry_per_turnsquare_amidon = sqrt(273e-5)./80
current_number_of_turns_on_amidon = sqrt(2e-5)./Henry_per_turnsquare_amidon
Z0 = 50 % Ohm
RL = [20 20] % Ohm
XL = 20 %2.*pi.*Freq.*Blin_L
LL = XL./(2.*pi.*Freq)
%C_ballast_nF = 0.25
C_ballast_nF = 0.614
%C_ballast_nF = 0.31

B = sqrt((Z0.*RL).^-1-Z0.^-2)
X = -sqrt(RL.*(Z0-RL))-XL

%B = -sqrt((Z0.*RL).^-1-Z0.^-2)
%X = -sqrt(RL.*(Z0-RL))-XL

Xs = B.^-1
Xb = X

% capacitors
Cb = 10e-9
Clb = 2e-9

Xcb = -1./(2.*pi.*Freq.*Cb) % C parallel to serially connected lb and clb
Xclb = -1./(2.*pi.*Freq.*Clb)
Xlb = 1./(1./Xb-1./Xcb) - Xclb 

Ls = Xs./(2.*pi.*Freq)
Lb = Xlb./(2.*pi.*Freq)

L_shunt_uH = round(1e8 .* Xs./(2.*pi.*Freq))./1e2
L_ballast_uH = round(1e8 .* Xlb./(2.*pi.*Freq))./1e2

P = 500; % Powr, Watts P=UI=UU/R -> UU=PR; P=IIXs -> II=P/Xs
U = sqrt(P.*Z0)
I = sqrt(P./Z0)
Z1 = 1./(1./Z0+1./(sqrt(-1).*Xs))
Z2 = RL+sqrt(-1).*(XL+1./(1./Xcb+1./(Xclb+Xlb)))
Z = 1./(1./(sqrt(-1).*Xs)+1./(Z2))
U_shunt_V = (sqrt(P.*Z))
I_shunt_A = (U_shunt_V./Xs)
I_load_A = (U_shunt_V./Z2)

I_cb = (U_shunt_V./(RL+sqrt(-1).*(XL+Xcb)))
U_cb = (I_cb.*Xcb)
I_clb = (U_shunt_V./(RL+sqrt(-1).*(XL+Xclb+Xlb)))
U_clb = (I_clb.*Xclb)
Ulb = (I_clb.*Xlb)

U_load_V = I_load_A .* (RL+sqrt(-1).*XL)
P_load_W = real(I_load_A .* U_load_V)


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
