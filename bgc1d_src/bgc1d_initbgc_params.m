 function bgc = bgc1d_initbgc_params(bgc)

 d2s = 86400;
 %%%%%%%%% Stochiometry %%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Organic matter form: C_aH_bO_cN_dP
 % Stoichiometric ratios: C:H:O:N:P = a:b:c:d:1
 % Anderson and Sarmiento 1994 stochiometry
 bgc.stoch_a = 106.0;
 bgc.stoch_b = 175.0;
 bgc.stoch_c = 42.0;
 bgc.stoch_d = 16.0;
 
 %%%%%%% Facultative heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Stoichiometry
 bgc.het_CN = 4.5;      % 4.5   % Carbon to Nitrogen ratio of heterotrophic biomass - White et al. 2019)
 bgc.het_HN = 7.0;      % 7.0   % Carbon to Hydrogen ratio of heterotrophic biomass
 bgc.het_ON = 2.0;      % 2.0   % Carbon to Oxygen ratio of heterotrophic biomass
 % Cell structure and quotas
 bgc.het_vol = 0.05;    % 0.05  % Volume of heterotrophic bacterial cell (um3) - Giovannoni 2017
 bgc.het_diam = effective_diam(bgc.het_vol); % effective diameter of a heterotrophic bacterial cell (um)
 bgc.het_gCcell = gC_per_cell(bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc.het_vol); % grams of carbon per cell (g/cell)
 bgc.het_molCum3 = molC_per_um3(bgc.het_gCcell, bgc.het_vol); % mols of C per volume unit (mol C / um3)
 % Maximum diffusive uptake of oxygen
 bgc.het_po_coef = po_coef(bgc.het_diam, bgc.het_molCum3, bgc.het_CN); % diffusive oxygen coefficient for growth on O2 - Zakem & Follows 2017
 % Yields
 bgc.het_y_org = yield_from_stoich(bgc.het_CN, bgc.stoch_a./bgc.stoch_d);    % Estimate the yield of heterotrophic bacteria - Sinsabaugh et al. 2013
 bgc.het_y_org = bgc.het_y_org ./ bgc.het_CN .* (bgc.stoch_a./bgc.stoch_d);   % Convert yield to units of nitrogen (mol bioN / mol orgN)
 bgc.het_y_oxy = substrate_yield(bgc.het_y_org, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 4.0); % yield of biomass per unit oxygen reduced
 % kinetics
 bgc.het_mumax = 0.5;   % 0.5   % Max. specific doubling rate of facultative heterotrophs (SAR11 bacteria) (/day) - Rappe et al. 2002; Kirkman et al. 2016
 bgc.het_Vmax_org = bgc.het_mumax ./ bgc.het_y_org;
 bgc.het_Korg  = 0.1;   % 0.1   % Half sat. constant for organic N uptake  (guess)
 
 %%%%%%% Ammonification %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.Krem = 0.08/d2s ;              % 0.08    % Max. specific remineralization rate (1/s)
 bgc.KO2Rem  = 0.046571922641370;   % 4       % Half sat. constant for respiration  (mmolO2/m3) - Martens-Habbena 2009

 %%%%%% Ammonium oxidationn %%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Ammox: NH4 --> NO2
 bgc.KAo = 0.1170/d2s;       % 0.045  % Max. Ammonium oxidation rate (mmolN/m3/s) - Bristow 2017
 bgc.KNH4Ao  = 0.130;       % 0.1    % Half sat. constant for nh4 (mmolN/m3) - Peng 2016
 bgc.KO2Ao = 0.333;                     % 0.333+-0.130  % Half sat. constant for Ammonium oxidation (mmolO2/m3) - Bristow 2017

 %%%%%%% Nitrite oxidationn %%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Nitrox: NO2 --> NO3
 bgc.KNo = 0.05/d2s;                  % 0.256 % Max. Nitrite oxidation rate (mmolN/m3/s) - Bristow 2017
 bgc.KNO2No = 1.0;                    % Don't know (mmolN/m3)
 bgc.KO2No = 0.778;                   % Half sat. constant of NO2 for Nitrite oxidation (mmolO2/m3) - Bristow 2017

 %%%%%%% Denitrification %%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Denitrif1: NO3 --> NO2
 bgc.KDen1 = 0.0215/d2s;     % Max. denitrif1 rate (1/s)
 bgc.KO2Den1 = 5.0;                     % O2 poisoning constant for denitrif1 (mmolO2/m3)
 bgc.KNO3Den1 = 0.4;      % Half sat. constant of NO3 for denitrif1 (mmolNO3/m3)

 % Denitrif2: NO2 --> N2O
 bgc.KDen2 = 0.008/d2s;                 % Max. denitrif2 rate (1/s)
 bgc.KO2Den2 = 2.3;                     % O2 poisoning constant for denitrif2 (mmolO2/m3)
 bgc.KNO2Den2 = 0.05;                   % Half sat. constant of NO2 for denitrification2 (mmolNO3/m3)

 % Denitrif3: N2O --> N2
 bgc.KDen3 = 0.0455/d2s;     % Max. denitrif3 rate (1/s)
 bgc.KO2Den3 = 0.11;       % O2 poisoning constant for denitrif3 (mmolO2/m3)
 bgc.KN2ODen3 = 0.2;                    % Half sat. constant of N2O for denitrification3 (mmolNO3/m3)

 %%%%%%%%%% Anammox %%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.KAx     = 0.3900/d2s;       % Max. Anaerobic Ammonium oxidation rate (mmolN/m3/s) - Bristow 2017
 bgc.KNH4Ax  = 0.23;       % Half sat. constant of NH4 for anammox (mmolNH4/m3)
 bgc.KNO2Ax  = 0.1;                     % Half sat. constant of NO2 for anammox (mmolNO2/m3)
 bgc.KO2Ax   = 0.7;                      % 1.0     %

 %%%%% N2O prod via ammox %%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Parameters for calculation of N2O yields during Ammox and
 % nitrifier-denitrification (see n2o_yield.m).
 
 % Choose paramterization:
 % 'Ji': Ji et al 2018
%bgc.n2o_yield = 'Ji';
 bgc.n2o_yield = 'Yang';

 switch bgc.n2o_yield
 case 'Ji'
    % Ji et al 2018
    bgc.Ji_a = 0.2; 	% non-dimensional
    bgc.Ji_b  = 0.08; 	% 1/(mmolO2/m3)
 case 'Yang'
    % S. Yang March 15 2019 optimized results 
    bgc.Ji_a = 0.30; 	% non-dimensional
    bgc.Ji_b  = 0.10; 	% 1/(mmolO2/m3)
 otherwise
    error(['N2O yield ' bgc.n2o_yield  ' case not found']);
 end

