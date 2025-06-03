% 20140604.
% using the load coil and capacitors values and matching network geometry
% to calculate min and max inductances for variable inductors in the
% matcher

Frequency = 2e6 % Hz

Load_paraller_resistance = 1e10 % Ohm
Load_serial_resistance = 0.1 % Ohm
Load_coil_inductance_range = [16e-6 38e-6] % H
Load_serial_capacitance = (0.519e-9 + 0.519e-9)./2 % F


Match_variable_capasitor_range = [7e-11 1.6e-9] % F

Load_inductance_impedance = sqrt(-1).*2.*pi.*Frequency.*Load_coil_inductance_range
Load_capacitive_impedance = -1/(sqrt(-1).*2.*pi.*Frequency.*Load_serial_capacitance)
Load_reactance = Load_inductance_impedance + Load_capacitive_impedance
Load_impedance_range = Load_serial_resistance + sqrt(-1).*2.*pi.*Frequency.*Load_coil_inductance_range - (sqrt(-1).*2.*pi.*Frequency.*Load_serial_capacitance).^-1 % Ohm

resonant_frequency = 1./(2.*pi.*sqrt(Load_coil_inductance_range.*Load_serial_capacitance))
wave_impedance = sqrt(Load_coil_inductance_range./Load_serial_capacitance)