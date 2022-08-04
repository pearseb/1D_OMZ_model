 function bgc = bgc1d_initialize(bgc)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iNitrOMZ v1.0 - Simon Yang  - April 2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialization of model parameters 
%   % Note that bgc/n-cycling parameters are defined in -- bgc1d_initbgc_params.m 
%   % Note that boundary condition values are defined in - bgc1d_initboundary.m
%   % Note that dependent parameters are updated in ------ bgc1d_initialize_DepParam.m
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%% General %%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%% User specific  %%%%%%%%%
 %bgc.root = '/Users/danielebianchi/AOS1/Ncycle/iNitrOMZ_v6.1/'; 
 %bgc.root = '/data/project1/demccoy/iNitrOMZ/';
 bgc.root = '/Users/pearseb/Dropbox/PostDoc/1D_OMZ_model/iNitrOMZ/';
 bgc.RunName = 'test_ETSP_F0p8_U2_MCCOY';
 bgc.region = 'ETSP';
 bgc.wup_profile = '/Data/vertical_CESM.mat'; % vertical velocities
 bgc.Tau_profiles = '/Data/Tau_restoring.mat'; % Depth dependent Restoring timescale
 bgc.visible = 'on'; % Show figures in X window
 bgc.flux_diag = 1; % Save fluxes online (turn off when runnning a GA for faster optimization)

 %%%%%%%% Vertical grid %%%%%%%%%
 bgc.npt = 130; % % number of mesh points for solution (for IVP)
 bgc.ztop = -30; % top depth (m)
 bgc.zbottom = -1330; % bottom depth (m)

 %%%%% Time step / history %%%%%%
 iTstep = 1;
 switch iTstep
 case 1
    % Original formulation - SYang
    % Specifies # timesteps, length and hist in timesteps 
    years = 5; 
    dt = 86400 ./ 24.0; % timestep in seconds bgc.hist =  500; 
    nt = years .* ((365 .* 86400) ./ dt);% Simulation length in timesteps
    hist = 365 .* 86400 ./ dt; % save a snapshot every day
    endTimey = nt*dt/(365*86400); % end time of simulation (years)
    histTimey = hist*dt/(365*86400); % history timestep (years)
   % Creates dt and history vectors
   [dt_vec time_vec hist_time_vec hist_time_ind hist_time] = bgc1d_process_time_stepping(dt,endTimey,histTimey);
 case 2
    % Variable time-stepping
    % Specifies time step bounds dn time steps
    % dt : Timesteps to be used in each interval (seconds)
    % endTimey : End of timestep intervals (years)
    % Case (1): Constant time step
   %dt       = [2.0]*86400;
   %endTimey = [700];
    % Case (2): Variable time step
   %dt       = [5.0 2.0 1.0 0.5]*86400;
   %endTimey = [650 670 690 700];
    %dt       = [5.0 2.0 1.0 0.5 0.25 0.125]*86400;
    dt       = [0.05 0.02 0.01 0.005 0.0025 0.001]*86400;
    endTimey = [650 670 690 695 698 700];
    % Output time step
    histTimey = 20; % history timestep (years)
    [dt_vec time_vec hist_time_vec hist_time_ind hist_time] = bgc1d_process_time_stepping(dt,endTimey,histTimey);
 otherwise
    error('Timestep mode not found');
 end
 bgc.dt_vec = dt_vec;
 bgc.hist_time_ind = hist_time_ind;
 bgc.hist_time_vec = hist_time_vec;
 bgc.hist_time = hist_time;
 bgc.nt = length(bgc.dt_vec);
 bgc.nt_hist = length(bgc.hist_time_ind);
 bgc.hist_verbose = true; % prompts a message at each saving timestep
 bgc.rest_verbose = true; % prompts a message when loading restart

 bgc.FromRestart = 1; % initialize from restart? 1 yes, 0 no
 bgc.RestartFile = 'test_ETSP_F0p8_U2_restart_700.0.mat'; % restart file
 bgc.SaveRestart = 0; %Save restart file? 1 yes, 0 no

 %% Advection diffusion scheme %%
 % 'FTCS': Forward in time and centered in space
 % 'GCN': Generalized Crank-Nicolson (currently broken April 2019)
 bgc.advection = 'FTCS';

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%   Model general   %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%% Prognostic variables %%%%%%
 bgc.RunIsotopes = false; % true -> run with isotopes
 bgc.tracers = {'o2', 'no3','pon', 'po4', 'n2o', 'nh4', 'no2', 'n2', 'facnar', 'facnir','aoo', 'noo', 'aox'};
 bgc.isotopes = {'i15no3', 'i15no2', 'i15nh4', 'i15n2oA', 'i15n2oB'};
 bgc.nvar_tr = length(bgc.tracers);
 bgc.nvar_is = length(bgc.isotopes);

 %%%%%%% Particle sinking %%%%%%%
 bgc.varsink = 1; % if 1 then use Martin curve else, use constant sinking speed. 
 if bgc.varsink == 1
	 bgc.b = -0.7049; % Martin curve exponent: Pi = Phi0*(z/z0)^b
 else
	 bgc.wsink_param = -20/(86400); % constant speed (bgc.varsink==0)
 end

 %%%%%% Upwelling speed %%%%%%%%%
 % Choose constant (=0) or depth-dependent (=1) upwelling velocity
 % depth-dependent velocity requires a forcing file (set in bgc1d_initialize_DepParam.m)
 bgc.depthvar_wup = 0; 
 bgc.wup_param = 4.0 * 7.972e-8;% 1.8395e-7; % m/s  % note: 10 m/y = 3.1710e-07 m/s

 %%%%%%%%%%% Diffusion %%%%%%%%%%
 bgc.depthvar_Kv = 1; 
 bgc.Kv_param  = 2.0 * 1.701e-5; % constant vertical diffusion coefficient in m^2/s
 % For sigmoidal Kv, use the following parameters
 bgc.Kv_top = 0.70 * 2.0 * 1.701e-5;
 bgc.Kv_bot = 1.00 * 2.0 * 1.701e-5;
 bgc.Kv_flex = -250;
 bgc.Kv_width = 300;

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%% Boundary conditions %%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modify in bgc1d_initboundary.m
 bgc = bgc1d_initboundary(bgc);

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%% BGC params %%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Initialize dependent parameters. (This should be on for optimization)
 bgc.depparams = 1;

 % Initialize BGC/N-cycling parameters (modify in bgc1d_initbgc_params.m)
 bgc = bgc1d_initbgc_params(bgc);

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%% N Isotopes params %%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modify in bgc1d_initIso_params.m
 bgc =  bgc1d_initIso_params(bgc);

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%% Restoring  %%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % set up restoring timescales for far-field profiles as a crude representation
 % of horizontal advective and diffusive processes.

 %%%%%% On and off switches %%%%%%%%%
 % Restoring switches: 1 to restore, 0 for no restoring
 bgc.RestoringOff = 1;	% 1: turns restoring off for all variables
			% (supersedes all following terms, used to speedup code)
 bgc.PO4rest = 0;
 bgc.NO3rest = 0;
 bgc.O2rest  = 0;
 bgc.N2Orest = 0;
 bgc.NH4rest = 0;
 bgc.N2rest  = 0;
 bgc.NO2rest = 0;
 bgc.FACNARrest = 0;
 bgc.FACNIRrest = 0;
 bgc.AOOrest = 0;
 bgc.NOOrest = 0;
 bgc.AOXrest = 0;
 bgc.i15NO3rest  = 0;
 bgc.i15NO2rest  = 0;
 bgc.i15NH4rest  = 0; 
 bgc.i15N2OArest = 0;
 bgc.i15N2OBrest = 0;
 
 %%%%%% Z-dependent restoring timescale %%%%%%%%%
 % Set to 1 for depth varying restoring timescales, 0 for constant
 % bgc.tauZvar = 1 requires a forcing file set in bgc1d_initialize_DepParam.m
 bgc.tauZvar = 1; 

 %%%%%% Physical scalings %%%%%%
 bgc.Rh = 1.0; 			% unitless scaling for sensitivity analysis. Default is 1.0
 bgc.Lh = 4000.0 * 1e3;		% m - horizontal scale
 % if you chose constant restoring timescales
 if bgc.tauZvar == 0
    bgc.Kh = 1000;		% m2/s - horizontal diffusion
    bgc.Uh = 0.05;		% m/s - horizontal advection
 end

 %%%%%% Force Anoxia %%%%%%
 % Option to force restoring to 0 oxygen in a certain depth range.
 % Useful to force the OMZ to span a target depth range or to remove
 % O2 intrusion in the OMZ while keeping restoring in the rest of the
 % water column
 % As usual, 1 is on and 0 is off 
 bgc.forceanoxic = 0;
 % Choose depth range
 bgc.forceanoxic_bounds = [-350 -100]; 

 % Calculate BGC/N-cycling parameters  that depend on bgc1d_initbgc_params
 if bgc.depparams
    bgc = bgc1d_initialize_DepParam(bgc);
    % Calculate dependent variables relate to isotopes
    if bgc.RunIsotopes
       bgc = bgc1d_initIso_Dep_params(bgc);
    end
 end
