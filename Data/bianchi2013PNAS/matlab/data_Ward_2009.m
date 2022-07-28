 function data = get_data

 data.reference = 'Ward et al. 2009';
 data.info = '';
 data.label = {
 'Ward st. 9'
 'Ward st. 9'
 'Ward st. 9'
 'Ward st. 24'
 'Ward st. 24'
};

% Removed Indian ocean data:
% 'Ward st. 1'
% 'Ward st. 1'
% 'Ward st. 2'
% 'Ward st. 2'

 data.data = [
80	0.235	0.000	30	21	-15.63	-75.01
150	0.000	0.000	100	21	-15.63	-75.01
250	0.026	0.000	200	21	-15.63	-75.01
100	0.365	0.000	18	200	-12.25	-79.3
260	0.104	0.700	178	200	-12.25	-79.3
                       ];
% Removed Indian ocean data:
% 113	0.040	0.330	48	660	19.00	67.00
% 150	0.000	0.670	85	660	19.00	67.00
% 150	0.250	0.060	110	1100	15.00	64.00
% 200	0.000	0.060	160	1100	15.00	64.00

 data.variables = {'depth','anammox','denitrification','depth_below','distance','latitude','longitude'};
 data.units     = {'m','nM N_2 h^-^1','nM N_2 h^-^1','m','km','degree','degree'};
 data.incubations = 5; 
 data.incubations_annamox = 3; 

