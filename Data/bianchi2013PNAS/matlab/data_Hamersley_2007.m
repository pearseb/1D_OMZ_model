 function data = get_data

 data.reference = 'Hamersley et al., 2007';
 data.info = 'All stations - pelagic rates only';
 data.label = {
 'Ham2 21 Apr'
 'Ham2 21 Apr'
 'Ham2 21 Apr'
 'Ham2 21 Apr'
 'Ham 7'
 'Ham 7'
 'Ham 7'
 'Ham 7'
                        };
 data.data = [
20	0.004	-15	15	-12.05	-77.50
26	0.063	-9	15      -12.05  -77.50
40	0.083	5	15      -12.05  -77.50
59	0.054	24	15      -12.05  -77.50
60	0.000	15	81	-12.04	-78.00
100	0.000	55	81	-12.04	-78.00
200	0.020	155	81	-12.04	-78.00
400	0.071	355	81	-12.04	-78.00
                       ];
 data.variables = {'depth','anammox','depth_below','distance','latitude','longitude'};
 data.units     = {'m','nM N_2 h^-^1','m','km','degree','degree'};
 data.incubations = 8; 
 data.incubations_annamox = 6; 

