 function data = get_data

 data.reference = 'Thamdrup et al., 2006';
 data.info = '';
 data.label = {
 'Thamdrup 04 s1 21/3'
 'Thamdrup 04 s1 21/4'
 'Thamdrup 04 s1 21/5'
 'Thamdrup 04 s1 21/6'
 'Thamdrup 04 s1 21/7'
 'Thamdrup 04 s1 21/8'
 'Thamdrup 04 s2 24/3'
 'Thamdrup 04 s2 24/3'
 'Thamdrup 04 s1 24/3'
 'Thamdrup 04 s1 24/3'
                       };
 data.data = [
30	0.108	0.114	-10	22	-20.10	-70.32
60	0.198	0.069	20	22	-20.10	-70.32
100	0.197	0.063	60	22	-20.10	-70.32
150	0.119	0.067	110	22	-20.10	-70.32
250	0.000	0.078	210	22	-20.10	-70.32
350	0.008	0.086	310	22	-20.10	-70.32
55	0.466	0.061	5	26	-20.17	-70.37
150	0.000	0.075	100	26	-20.17	-70.37
55	0.727	0.054	5	22	-20.105	-70.325
150	0.156	0.075	100	22	-20.105	-70.325
                       ];
 data.variables = {'depth','anammox','anammox_se','depth_below','distance','latitude','longitude'};
 data.units     = {'m','nM N_2 h^-^1','nM N_2 h^-^1','m','km','degrees','degrees'};
 data.incubations = 10; 
 data.incubations_annamox = 8; 

