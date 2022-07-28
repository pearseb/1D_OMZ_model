 function data = get_data

 data.reference = 'Lam et al. 2010';
 data.info = 'Maintained Values for station7; ecluded2: excluded due to bottom influences';
 data.label = {
 'Lam 05-St2 15/4'
 'Lam 05-St2 15/4'
 'Lam 05-St2 15/4'
 'Lam 05-St2 15/4'
 'Lam 05-St4'
 'Lam 05-St4'
 'Lam 05-St4'
 'Lam 05-St4'
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 };
 data.data = [
20	0.000	-10	15	-12	-77.28
30	1.460	0	15	-12	-77.28
40	0.695	10	15	-12	-77.28
50	0.345	20	15	-12	-77.28
35	0.000	1	37	-12	-77.48
35	5.800	1	37	-12	-77.48
40	5.505	6	37	-12	-77.48
60	0.740	26	37	-12	-77.48
20      0.000   -19     92	-12	-77.98
60      1.115   21      92	-12	-77.98
100     1.450   61      92	-12	-77.98
200     1.230   161     92	-12	-77.98
400     1.680   361     92	-12	-77.98
                       ];
 data.variables = {'depth','anammox','depth_below','distance','latitude','longitude'};
 data.units     = {'m','nM N_2 h^-^1','m','km','degree','degree'};
 data.incubations = 8; 
 data.incubations_annamox = 6; 

%----------------------------------------------

 data.label_excluded1 = {
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 'Lam 05-St7'
 };

 data.data_excluded1 = [
20	0.000	-19	nan
60	1.115	21	nan
100	1.450	61	nan
200	1.230	161	nan
400	1.680	361	nan
 ];

%----------------------------------------------

 data.label_excluded2 = {
 'Lam 05-St2'
 'Lam 05-St4'
 };

 data.data_excluded2 = [
80	2.100	1.050	50	nan
140	1.150	0.575	106	nan
 ];


 

