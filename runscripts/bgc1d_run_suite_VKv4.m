% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template BGC1D runscript 
% Versions: 0.1 : D. Bianchi, Spet 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Documentation:
% This script allows to perform "sensitivity experiments", where an arbitrary number
% of model parameters is varied, and the model run for each possible combinations of
% parameters.
% Output for each parameter combination will be stored in the cell array Suite.Out
% Access individual experiments by using the appropriate indices, e.g. Suite.Out{1,1}, ... 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions

 %-------------------------------------------------------
 % Initialize the model - baseline
 % Based on the code and options in bgc1d_main.m
 %-------------------------------------------------------
 clear bgc;

 %-------------------------------------------------------
 bgc.root = '/Users/pearseb/Dropbox/PostDoc/1D_OMZ_model/iNitrOMZ/'; % root path
 bgc.rootdirs = {'bgc1d_src','Data','functions','processing','plotting','optimization','restart','runscripts'};
 bgc.iPlot = 0;            % To plot output
% initialize the model
% here, specify iNitrOMZ root path ($PATHTOINSTALL/iNitrOMZ/)
 for indp=1:length(bgc.rootdirs);
    addpath([bgc.root bgc.rootdirs{indp}]); % adds root to MATLAB's search paths
 end

 bgc.depparams = 1; % make sure dependent parameters are updated
 bgc = bgc1d_initialize(bgc);

 %-------------------------------------------------------
 % Process observations to validate the model solution
 Tracer.name = {'o2' 'no3' 'poc' 'po4' 'n2o' 'nh4' 'no2' 'n2'};
 if strcmp(bgc.region,'ETNP')
    load([bgc.root,'/Data/compilation_offshore.mat']);
    Data = GA_data_init_opt(bgc,compilation_offshore,Tracer.name);
 elseif strcmp(bgc.region,'ETSP')
   load([bgc.root,'/Data/compilation_ETSP_gridded_Feb232018.mat']);
   Data = GA_data_init_opt(bgc,compilation_ETSP_gridded,Tracer.name);
 end

 %-------------------------------------------------------
 % Define the suite of model runs
 %-------------------------------------------------------

 clear Suite;
 Suite.name = 'test_VKv4_ko2den';
 Suite.long_name = 'Testing KO2Den2 and KO2Den3';
 NameAdd = 1;  % 1 to add the parameter names to the Suite name
 Suite.base = bgc;
 Suite.collapse = 1; 	% Collapses the suite Output by taking average output
			% and packaging the output into arrays with the size 
			% of the Suite parameters (useful to save space, removes time-dependent output)
 Suite.rmOut = 1;	% 0: keeps Out; 1: removes Out
 %---------------------
 % Suite parameters
 % Specify the following:
 % params : names of parameters to be varied
 % values : one vector of values for each parameter
 %---------------------
 Suite.params = {'KO2Den2','KO2Den3'};
 Suite.KO2Den2 = linspace(0.01,3,10);
 Suite.KO2Den3 = linspace(0.01,3,10);

 %-------------------------------------------------------
 % Here, if needed, overrides default parameters for BioModules and SetUp
 % All Suite experiments will adopt these parameters
 % (use ['property',value] format)
 % NOTE: these should be variables not used as Suite Parameters
 load([bgc.root,'optimization/cluster_params_best_cost.mat']);
 param_choice = VKv4;
 fieldnames = fields(VKv4);
 fcnt  = 1;
 for i = 1:length(fieldnames)
	if ~ismember(fieldnames{i},Suite.params)
		new_ParName{fcnt} = fieldnames{i};
		new_ParVal(fcnt)  = param_choice.(fieldnames{i});
		fcnt = fcnt + 1;
	end
 end

 %-------------------------------------------------------
 Suite.nparam = length(Suite.params);
 Suite.dims = zeros(1,Suite.nparam);
 Suite.AllParam = cell(1,Suite.nparam);
 for ip = 1:Suite.nparam
    Suite.dims(ip) = length(eval(['Suite.' Suite.params{ip}]));
    Suite.AllParam{ip} = eval(['Suite.' Suite.params{ip}]);
 end
 Suite.nruns = prod(Suite.dims);
 if length(Suite.dims)>1
    Suite.Out = cell(Suite.dims);
 else
    Suite.Out = cell(1,Suite.dims);
 end

 %-------------------------------------------------------
 % Loop through experiments
 %-------------------------------------------------------

 Tsuite = Suite.base;
 runindex = cell(Suite.nparam,1);
 for irun = 1:Suite.nruns
    disp(['Run number # ' num2str(irun) '/' num2str(Suite.nruns)]);
    [runindex{:}] = ind2sub(Suite.dims,irun);
    %---------------------
    % Here, creates the input arguments for bio module and experiment setup
    arg_ParName = new_ParName;
    arg_ParVal = new_ParVal;
    for ipar = 1:Suite.nparam
       disp([ Suite.params{ipar} ' - Start ........  ' num2str(Suite.AllParam{ipar}(runindex{ipar}))]);
       arg_ParName = [arg_ParName Suite.params{ipar}]; 
       arg_ParVal  = [arg_ParVal  Suite.AllParam{ipar}(runindex{ipar})]; 
    end
    %---------------------
    % Initialized Biomodule with user-defined inputs
    % (use ['property',value] format)
    % Substitute the optimal parameters
    % Change parameters with those selected in Scenario_child(ichr).chromosome
    for indp=1:length(arg_ParName)
       Tsuite = bgc1d_change_input(Tsuite,arg_ParName{indp},arg_ParVal(indp));
    end
    % Updates BGC/N-cycling parameters  that depend on bgc1d_initbgc_params
    if Tsuite.depparams
       Tsuite = bgc1d_initialize_DepParam(Tsuite);
       % Calculate dependent variables relate to isotopes
       if Tsuite.RunIsotopes
          Tsuite = bgc1d_initIso_Dep_params(Tsuite);
       end
    end
    % % % % % % % % % % % % % % % % % % % % 
    if (0)
       disp(['WARNING: updating any derived parameter']);
       % % % % % % % % % % % %
       % DERIVED PARAMETERS  %
       % % % % % % % % % % % %
       % E.g. change timestepping, etc.
       % E.g. Constraints: 
       % ... 
       % ... KDen1 + KDen2 + KDen3 = remin
       % % % % % % % % % % % %
    end
    %---------------------
    Suite.Out{irun} = Tsuite;
    tic;
    % Run the model
    [Suite.Out{irun}.sol_time, ~, ~, ~, ~] = bgc1d_advection_diff_opt(Suite.Out{irun});
    Suite.Out{irun}.runtime = toc;
    % Postprocess the results
    Suite.Out{irun} = bgc1d_postprocess(Suite.Out{irun}, Data);
    % Keeps track of runtime
 end
 %---------------------
 % Keeps track of total time, summing up individual times
 Suite.runtime = 0;
 for irun = 1:Suite.nruns
     Suite.runtime = Suite.runtime + Suite.Out{irun}.runtime;
 end;

 %-------------------------------------------------------
 % Postprocess, rename and save the suite
 %-------------------------------------------------------
 % If required, collapses Suite output
 if Suite.collapse==1
    % WARNING: this removes the "Out" field
 end

 % Rename the suite
 snewname = ['Suite_' Suite.name];
 if NameAdd ==1
    % Create a newname that includes all the parameters
    for indn=1:Suite.nparam
       snewname = [snewname '_' Suite.params{indn}];
    end
 end
 eval([snewname ' = Suite;']);
 % Save the suite
 eval(['save ' snewname '.mat ' snewname ';']);

