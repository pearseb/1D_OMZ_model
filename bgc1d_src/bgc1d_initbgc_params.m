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
 

 %%%%%%% Growth rates %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.het_mumax = 0.5 / d2s;   % 0.5   % Max. specific doubling rate of facultative heterotrophs (SAR11 bacteria) (/day) - Rappe et al. 2002; Kirkman et al. 2016
 bgc.aoo_mumax = 0.5 / d2s;   % 0.5   % Wutcher et al. 2006; Horak et al. 2013; Shafiee et al. 2019; Qin et al. 2015
 bgc.noo_mumax = 1.0 / d2s;   % 1.0   % Spieck et al. 2014; Kitzinger et al. 2020
 bgc.aox_mumax = 0.2 / d2s;   % 0.2   % Okabe et al. 2021 ISME | Lotti et al. 2014
 

 %%%%%%% Mortality %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.min_bio = 1e-3;            % minimum biomass of any group beneath which mortality stops
 bgc.mort = 1.0 / d2s;         % rate of mortality (quadratic)
 bgc.resp = 0.0 / d2s;         % rate of respiration (linear)
 

 %%%%%%% Aerobic heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Stoichiometry
 bgc.het_CN = 4.5;      % 4.5   % Carbon to Nitrogen ratio of heterotrophic biomass - White et al. 2019)
 bgc.het_HN = 7.0;      % 7.0   % Carbon to Hydrogen ratio of heterotrophic biomass
 bgc.het_ON = 2.0;      % 2.0   % Carbon to Oxygen ratio of heterotrophic biomass
 % Cell structure and quotas
 bgc.het_vol = 0.05;    % 0.05  % Volume of heterotrophic bacterial cell (um3) - Giovannoni 2017
 bgc.het_diam = effective_diam(bgc.het_vol); % effective diameter of a heterotrophic bacterial cell (um)
 bgc.het_gCcell = gC_per_cell(bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc.het_vol); % grams of carbon per cell (g/cell)
 bgc.het_molCum3 = molC_per_um3(bgc.het_gCcell, bgc.het_vol);       % mols of C per volume unit (mol C / um3)
 bgc.het_molCum3 = bgc.het_molCum3 * (6.5e-15 / bgc.het_gCcell);    % normalise to 6.5 fg C / cell measured for heterotrophs (White et al. 2019)
 % Maximum diffusive uptake of oxygen
 bgc.het_po_coef = po_coef(bgc.het_diam, bgc.het_molCum3, bgc.het_CN); % diffusive oxygen coefficient for growth on O2 - Zakem & Follows 2017
 % Yields
 bgc.het_y_org = yield_from_stoich(bgc.het_CN, bgc.stoch_a./bgc.stoch_d);    % Estimate the yield of heterotrophic bacteria - Sinsabaugh et al. 2013
 bgc.het_y_org = bgc.het_y_org ./ bgc.het_CN .* (bgc.stoch_a./bgc.stoch_d);   % Convert yield to units of nitrogen (mol bioN / mol orgN)
 bgc.het_y_oxy = substrate_yield(bgc.het_y_org, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 4.0); % yield of biomass per unit oxygen reduced
 % kinetics
 bgc.het_Vmax_org = bgc.het_mumax ./ bgc.het_y_org;
 bgc.het_Korg  = 0.1;   % 0.1   % Half sat. constant for organic N uptake  (guess)


 %%%%%%% Nitrate reducing heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 den_penalty = 0.9;
 % Yields
 bgc.nar_y_org = bgc.het_y_org .* den_penalty;      % denitrification is not as efficient as aerobic heterotrophy
 bgc.nar_y_no3 = substrate_yield(bgc.nar_y_org, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 2.0); % yield of biomass per unit oxygen reduced
 % kinetics
 bgc.nar_Vmax_org = bgc.het_mumax .* den_penalty ./ bgc.nar_y_org;
 bgc.nar_Korg  = 0.1;   % 0.1   % Half sat. constant for organic N uptake  (guess)
 bgc.nar_Kno3  = 4.0;   % 4.0   % Half sat. constant for NO3 uptake  (Almeida et al. 1995)
 

 %%%%%%% Nitrite reducing heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 den_penalty = 0.9;
 % Yields
 bgc.nir_y_org = bgc.het_y_org .* den_penalty;      % denitrification is not as efficient as aerobic heterotrophy
 bgc.nir_y_no3 = substrate_yield(bgc.nir_y_org, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 3.0); % yield of biomass per unit oxygen reduced
 % kinetics
 bgc.nir_Vmax_org = bgc.het_mumax .* den_penalty ./ bgc.nir_y_org;
 bgc.nir_Korg  = 0.1;   % 0.1   % Half sat. constant for organic N uptake  (guess)
 bgc.nir_Kno2  = 4.0;   % 4.0   % Half sat. constant for NO3 uptake  (Almeida et al. 1995)
 

 %%%%%%% Facultative NAR heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fac_penalty = 0.8; 
 bgc.facnar_y_Oorg = bgc.het_y_org .* fac_penalty; 
 bgc.facnar_y_oxy  = substrate_yield(bgc.facnar_y_Oorg, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 4.0); % yield of biomass per unit oxygen reduced
 bgc.facnar_y_Norg = bgc.nar_y_org .* fac_penalty;
 bgc.facnar_y_no3  = substrate_yield(bgc.facnar_y_Norg, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 2.0); % yield of biomass per unit nitrate reduced
 bgc.facnar_Vmax_Oorg = bgc.het_mumax .* fac_penalty ./ bgc.facnar_y_Oorg; 
 bgc.facnar_Vmax_Norg = bgc.het_mumax .* den_penalty .* fac_penalty ./ bgc.facnar_y_Norg; 
 bgc.facnar_Vmax_no3  = bgc.het_mumax .* den_penalty .* fac_penalty ./ bgc.facnar_y_no3; 


 %%%%%%% Facultative NIR heterotroph %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fac_penalty = 0.8; 
 bgc.facnir_y_Oorg = bgc.het_y_org .* fac_penalty; 
 bgc.facnir_y_oxy  = substrate_yield(bgc.facnir_y_Oorg, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 4.0); % yield of biomass per unit oxygen reduced
 bgc.facnir_y_Norg = bgc.nir_y_org .* fac_penalty;
 bgc.facnir_y_no2  = substrate_yield(bgc.facnir_y_Norg, bgc.het_CN, bgc.het_HN, bgc.het_ON, bgc, 3.0); % yield of biomass per unit nitrate reduced
 bgc.facnir_Vmax_Oorg = bgc.het_mumax .* fac_penalty ./ bgc.facnir_y_Oorg; 
 bgc.facnir_Vmax_Norg = bgc.het_mumax .* den_penalty .* fac_penalty ./ bgc.facnir_y_Norg; 
 bgc.facnir_Vmax_no2  = bgc.het_mumax .* den_penalty .* fac_penalty ./ bgc.facnir_y_no2; 


 %%%%%%% Ammonia oxidising archaea %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 % Stoichiometry
 bgc.aoo_CN = 4.0;      % 4.0   % Carbon to Nitrogen ratio of biomass - Bayer et al. 2022
 bgc.aoo_HN = 7.0;      % 7.0   % Carbon to Hydrogen ratio of biomass
 bgc.aoo_ON = 2.0;      % 2.0   % Carbon to Oxygen ratio of biomass
 % Cell structure and quotas
 bgc.aoo_vol = pi .* (0.2 .* 0.5).^2 .* 0.8 ;    % Volume of rod-shaped AOO cell (um3) - Table S1 from Hatzenpichler 2012 App. Envir. Microbiology
 bgc.aoo_diam = effective_diam(bgc.aoo_vol); % effective diameter (um)
 bgc.aoo_gCcell = gC_per_cell(bgc.aoo_CN, bgc.aoo_HN, bgc.aoo_ON, bgc.aoo_vol); % grams of carbon per cell (g/cell)
 bgc.aoo_molCum3 = molC_per_um3(bgc.aoo_gCcell, bgc.aoo_vol);       % mols of C per volume unit (mol C / um3)
 bgc.aoo_molCum3 = bgc.aoo_molCum3 * (6.5e-15 / bgc.het_gCcell);    % normalise to 6.5 fg C / cell measured for heterotrophs (White et al. 2019)
 % Maximum diffusive uptake of oxygen
 bgc.aoo_po_coef = po_coef(bgc.aoo_diam, bgc.aoo_molCum3, bgc.aoo_CN); % diffusive oxygen coefficient for growth on O2 - Zakem & Follows 2017
 % Yields
 bgc.aoo_y_nh4 = 0.0245;                                                % Bayer et al. 2022; Zakem et al. 2022
 d_aoo = 4.*bgc.aoo_CN + bgc.aoo_HN - 2.*bgc.aoo_ON - 3;                % number of electrons produced
 f_aoo = bgc.aoo_y_nh4 ./ (6.0 .* (1./d_aoo - bgc.aoo_y_nh4./d_aoo));   % fraction of electrons going to biosynthesis
 bgc.aoo_y_oxy = f_aoo ./ d_aoo ./ ((1-f_aoo)./4.0);                    % yield of AOO for oxygen
 % kinetics
 bgc.aoo_Vmax_nh4 = bgc.aoo_mumax ./ bgc.aoo_y_nh4;
 bgc.aoo_Knh4  = 0.1;                                   % 0.1   % Martens-Habbena et al. 2009 Nature


 %%%%%%% Nitrite oxidising bacteria %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 % Stoichiometry
 bgc.noo_CN = 3.4;      % 3.4   % Carbon to Nitrogen ratio of biomass - Bayer et al. 2022
 bgc.noo_HN = 7.0;      % 7.0   % Carbon to Hydrogen ratio of biomass
 bgc.noo_ON = 2.0;      % 2.0   % Carbon to Oxygen ratio of biomass
 % Cell structure and quotas
 bgc.noo_vol = pi .* (0.3 .* 0.5).^2 .* 3.0 ;       % Volume of rod-shaped NOO cell (um3) - based on average cell diameter and length of Nitrospina gracilis (Spieck et al. 2014 Sys. Appl. Microbiology)
 bgc.noo_diam = effective_diam(bgc.noo_vol);        % effective diameter (um)
 bgc.noo_gCcell = gC_per_cell(bgc.noo_CN, bgc.noo_HN, bgc.noo_ON, bgc.noo_vol); % grams of carbon per cell (g/cell)
 bgc.noo_molCum3 = molC_per_um3(bgc.noo_gCcell, bgc.noo_vol);       % mols of C per volume unit (mol C / um3)
 bgc.noo_molCum3 = bgc.noo_molCum3 * (6.5e-15 / bgc.het_gCcell);    % normalise to 6.5 fg C / cell measured for heterotrophs (White et al. 2019)
 % Maximum diffusive uptake of oxygen
 bgc.noo_po_coef = po_coef(bgc.noo_diam, bgc.noo_molCum3, bgc.noo_CN); % diffusive oxygen coefficient for growth on O2 - Zakem & Follows 2017
 % Yields
 bgc.noo_y_no2 = 0.0126;                                                % Bayer et al. 2022; Zakem et al. 2022
 d_noo = 4.*bgc.noo_CN + bgc.noo_HN - 2.*bgc.noo_ON - 3;                % number of electrons produced
 f_noo = (bgc.noo_y_no2 .* d_noo) ./ 2;                                 % fraction of electrons going to biosynthesis
 bgc.noo_y_oxy = 4 .* f_noo .* (1-f_noo) ./ d_noo;                      % yield of NOO for oxygen
 % kinetics
 bgc.noo_Vmax_no2 = bgc.noo_mumax ./ bgc.noo_y_no2;
 bgc.noo_Kno2  = 0.1;                                   % 0.1   % Reported from OMZ (Sun et al. 2017), oligotrophic conditions (Zhang et al. 2020), and Southern Ocean (Mdutyana et al. 2022)


 %%%%%%% Anammox bacteria %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 % Stoichiometry
 bgc.aox_CN = 5.0;      % 5.0   % Carbon to Nitrogen ratio of biomass - Lotti et al. 2014
 bgc.aox_HN = 8.7;      % 8.7   % Carbon to Hydrogen ratio of biomass - Lotti et al. 2014
 bgc.aox_ON = 1.55;     % 1.55  % Carbon to Oxygen ratio of biomass - Lotti et al. 2014
 % Cell structure and quotas
 bgc.aox_vol = 4/3 * pi * (0.8*0.5)^3;              % [cocci] diameter of 0.8 um based on Candidatus Scalindua (Wu et al. 2020 Water Science and Tech.)
 bgc.aox_diam = effective_diam(bgc.aox_vol);        % effective diameter (um)
 bgc.aox_gCcell = gC_per_cell(bgc.aox_CN, bgc.aox_HN, bgc.aox_ON, bgc.aox_vol); % grams of carbon per cell (g/cell)
 bgc.aox_molCum3 = molC_per_um3(bgc.aox_gCcell, bgc.aox_vol);       % mols of C per volume unit (mol C / um3)
 bgc.aox_molCum3 = bgc.aox_molCum3 * (6.5e-15 / bgc.het_gCcell);    % normalise to 6.5 fg C / cell measured for heterotrophs (White et al. 2019)
 % Yields
 bgc.aox_y_nh4 = 1/70;      % mol N biomass per mol NH4 (Lotti et al. 2014 Water Research) ***Rounded to nearest whole number
 bgc.aox_y_no2 = 1/81;      % mol N biomass per mol NO2 (Lotti et al. 2014 Water Research) ***Rounded to nearest whole number
 bgc.aox_e_no3 = 11;        % mol NO3 per mol N biomass (Lotti et al. 2014 Water Research) ***Rounded to nearest whole number
 bgc.aox_e_n2 = 139;        % mol N (in N2) per mol N biomass (Lotti et al. 2014 Water Research) ***Rounded to nearest whole number 
 % kinetics
 bgc.aox_Vmax_nh4 = bgc.aox_mumax ./ bgc.aox_y_nh4;
 bgc.aox_Vmax_no2 = bgc.aox_mumax ./ bgc.aox_y_no2;
 bgc.aox_Knh4  = 0.45;                                  % 0.45  % Awata et al. 2013 for Scalindua
 bgc.aox_Kno2  = 0.45;                                  % 0.45  % Awata et al. 2013 for Scalindua actually finds a K_no2 of 3.0 uM, but this excludes anammox completely in our experiments



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


