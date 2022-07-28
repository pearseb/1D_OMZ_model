 
 addpath ~/AOS1/matlabpathfiles
 addpath /Users/danielebianchi/AOS1/Ncycle/data/scripts/
 % Data retrieved from:
 % https://doi.pangaea.de/10.1594/PANGAEA.843460
 % On 20/10/11
 % Kalvelage's data comes as tab-separated ASCII, here loads a version where all lines 
 % except headers and data have been removed
 dirname = 'datasets';
 tfile = {
          'M77_3_hy.processed.tab'; ...
          'M77_3_n-cycle.processed.tab'; ...
          'M77_3_poc-pon.processed.tab'; ...
          'M77_4_hy.processed.tab'; ...
          'M77_4_n-cycle.processed.tab'; ...
          'M77_4_nh4.processed.tab'; ...
          'M77_4_poc-pon.processed.tab'
         };

 % A list of unique names found in the files above can be seen by running "kalvelage_raw_names.mat"
 % headers name; variable name; units; isnumeric
 variables = {
    'Event',							'event',	'',		0;	...
    'Date/Time',						'date',		'',		0;	...
    'Latitude',							'lat',		'',		1;	...
    'Longitude',						'lon',		'',		1;	...
    'Depth water [m]',						'depth',	'm',		1;	...
    'Sample label',						'label',	'',		0;	...
    'Press [dbar] (CTD, SEA-BIRD SBE 911plus)',			'pres',		'dbar',		1;	...
    'Temp [°C] (CTD, SEA-BIRD SBE 911plus)',			'temp',		'C',		1;	...
    'Sal (CTD, SEA-BIRD SBE 911plus)',				'salt',		'psu',		1;	...
    'OXYGEN [µmol/kg] (CTD, SEA-BIRD SBE 911plus)',		'o2',		'umol/kg',	1;	...
    'Sal',							'salt',		'psu',		1;	...
    'OXYGEN [µmol/kg]',						'o2',		'umol/kg',	1;	...
    'NITRAT [µmol/kg]',						'no3',		'umol/kg',	1;	...
    'NITRIT [µmol/kg]',						'no2',		'umol/kg',	1;	...
    'N2O [nmol/kg]',						'n2o',		'nmol/kg',	1;	...
    'PON [µmol/kg] (Measured)',					'pon',		'umol/kg',	1;	...
    'DON [µmol/kg]',						'don',		'umol/kg',	1;	...
    'POC [µmol/kg] (Measured)',					'poc',		'umol/kg',	1;	...
    '[NH4]+ [µmol/kg]',						'nh4',		'umol/kg',	1;	...
    'PHSPHT [µmol/kg]',						'po4',		'umol/kg',	1;	...
    'POP [µmol/kg]',						'pop',		'umol/kg',	1;	...
    'DOP [µmol/kg]',						'dop',		'umol/kg',	1;	...
    'SILCAT [µmol/kg]',						'sio2',		'umol/kg',	1;	...
    'bSiO2 [µmol/kg]',						'bsio2',	'umol/kg',	1;	...
    'CHLORA [µg/kg]',						'chl',		'ug/kg',	1;	...
    '[NH4]+ OR [nmol/l/day]',					'nh4ox',	'nmol/l/d',	1;	...
    'Std dev [±] (Ammonium oxidation)',				'nh4ox_sd',	'nmol/l/d',	1;	...
    '[NO2]- OR [nmol/l/day]',					'no2ox',	'nmol/l/d',	1;	...
    'Std dev [±] (Nitrite oxidation)',				'no2ox_sd',	'nmol/l/d',	1;	...
    '[NO3]- RR [nmol/l/day]',					'no3re',	'nmol/l/d',	1;	...
    'Std dev [±] (Nitrate reduction)',				'no3re_sd',	'nmol/l/d',	1;	...
    'Anammox rate [nmol/l/day]',				'anamx',	'nmol/l/d',	1;	...
    'Std dev [±] (Anammox)',					'anamx_sd',	'nmol/l/d',	1;	...
    'DNRA [nmol/l/day]',					'dnra',		'nmol/l/d',	1;	...
    'Std dev [±] (DNRA)',					'dnra_sd',	'nmol/l/d',	1;	...
    'Denitrifi [nmol/l/day] (coupled to H2S oxidation)',	'denit_h2s',	'nmol/l/d',	1;	...
    'Std dev [±] (Denitrification H2S)',			'denit_h2s_sd',	'nmol/l/d',	1;	...
    'Denitrifi [nmol/l/day]',					'denit',	'nmol/l/d',	1;	...
    'Std dev [±] (Denitrification)',				'denit_sd',	'nmol/l/d',	1;	...
    'POC [µmol/l]',						'poc',		'umol/l',	1;	...
    'PON [µmol/l]',						'pon',		'umol/l',	1;	...
    'Press [dbar]',						'pres',		'dbar',		1;	...
    'Temp [°C]',						'temp',		'C',		1;	...
    'δ15N NO2 [‰ air]',						'd15no2',	'permil',	1;	...
    'δ15N NO3 [‰ air]',						'd15no3',	'permil',	1;	...
    'δ15N NO2+NO3 [‰ air]',					'd15nox',	'permil',	1;	...
    'Bottle',							'bottle',	'',		1;	...
    '[NH4]+ [µmol/l]',						'nh4',		'umol/l',	1;	...
    };

 % Loads all files
 npoints = nan(length(tfile),1);
 for indf=1:length(tfile)
    [tdata tresult] = readtext([dirname '/' tfile{indf}],'\t');
     alldata{indf}.tdata = tdata; 
     alldata{indf}.tresult = tresult; 
     npoints(indf,1) = alldata{indf}.tresult.rows-1;
 end

 % Deals with some repeated variables, e.g. Temp from multiple instruments
 npall = sum(npoints);
 fullname = {variables{:,1}};
 vars = {variables{:,2}};
 [uvars iva ivb] = unique({variables{:,2}},'stable');
 units = {variables{:,3}};
 ivarnum = [variables{:,4}];

 % Initializes data structure
 clear data_raw
 data_raw.variables = [vars 'file_origin'];
 data_raw.units = [units {''}];
 data_raw.file_origin = repmat({''},npall,1);
 for indv=1:length(uvars)
    % finds multiplicity of variable
    tvar = uvars{indv};
    ivmlt = sum(strcmp(tvar,vars));
    switch ivarnum(iva(indv))
    case 0
       data_raw.(uvars{indv}) = repmat({''},npall,ivmlt);
    case 1
       data_raw.(uvars{indv}) = nan(npall,ivmlt);
    otherwise
       error
    end
 end

 % Fills in all data
 % Loops through files
 iend = 0;
 for indf=1:length(tfile)
    % loops through file variables
    headers = alldata{indf}.tdata(1,:);
    nvar = length(headers);
    vardone = repmat({''},nvar,1); 
    istart = iend+1;
    iend = istart+npoints(indf)-1;
    data_raw.file_origin(istart:iend) = tfile(indf);
    for indv=1:nvar
       tnamelong = headers{indv};
       ivar = find(strcmp(tnamelong,fullname));
       tnameshort = vars{ivar};
       itvarnum = ivarnum(ivar);
       % Checks how many times the variable has been loaded (for multiplicity)
       ivmlt = sum(strcmp(tnameshort,vardone))+1;
       tvarall = alldata{indf}.tdata(2:end,indv);
       switch itvarnum
       case 0
          isubst = find(cellfun(@isnumeric,tvarall));
          tvarall(isubst) = cellfun(@num2str,tvarall(isubst),'UniformOutput',false);
          data_raw.(tnameshort)(istart:iend,ivmlt) = tvarall; 
       case 1
          % Sets empty and NON-NUMERIC cells to NANs
          %-------------------------
          % First does few corrections, e.g. N2O contains they symbol "#", which
          % needs to be removed
          ichar = find(cellfun(@ischar,tvarall));
          if any(cell2mat(strfind(tvarall(ichar),'#'))) | any(cell2mat(strfind(tvarall(ichar),'?')))
             disp(['WARNING: keeping variables with ? and # symbols, here: ' vars{ivar}]);
             tvarall(ichar) = strrep(tvarall(ichar),'#',''); 
             tvarall(ichar) = strrep(tvarall(ichar),'?',''); 
             tvarall(ichar) = num2cell(cellfun(@str2num,tvarall(ichar)));
          end
          %-------------------------
          isubst = find(cellfun(@isempty,tvarall) | ~cellfun(@isnumeric,tvarall));
          tvarall(isubst) = {nan};
          data_raw.(tnameshort)(istart:iend,ivmlt) = cell2mat(tvarall); 
       otherwise
          error
       end
       vardone{indv} = tnameshort;
    end
 end

 % Add date vector
 % Needs to process the specific strings used in this file... E.g.:
 % CTD:    		'2009-02-09T20:42'
 % Incubations		'2009-01-30'
 date_new = nan(npall,6); 
 for indi=1:npall
    tmp = data_raw.date{indi};
    switch length(tmp)
    case 16
       tyea = str2num(tmp(1:4));
       tmon = str2num(tmp(6:7));
       tday = str2num(tmp(9:10));
       thou = str2num(tmp(12:13));
       tmin = str2num(tmp(15:16));
       tsec = 0;
    case 10
       tyea = str2num(tmp(1:4));
       tmon = str2num(tmp(6:7));
       tday = str2num(tmp(9:10));
       thou = 0;
       tmin = 0;
       tsec = 0;
    otherwise
    error('length of date string not recognized');
    end
    date_new(indi,:) = [tyea tmon tday thou tmin tsec];
 end


 % Replaces variable names with unique names
 data_raw.date_string = data_raw.date;
 data_raw.date = date_new;
 [uvariables iaa ibb] = unique(data_raw.variables,'stable');
 uunits = data_raw.units(iaa);
 data_raw.variables = [uvariables 'date_string'];
 data_raw.units = [uunits {''}];

%-------------------------------------------------
% A bit of cleaning: keeps only 1 out of 2 instances of multiple-occurrence variables
% Salt and o2 are the only variables that need care, the other can be avearged
% for both, seems safer to keep only the first dataset, since there's no NaNs that are in the 2nd dataset
% sum(isnan(data_raw.o2(:,1)) & ~isnan(data_raw.o2(:,1))) == 0
% sum(isnan(data_raw.salt(:,1)) & ~isnan(data_raw.salt(:,1))) ==0
% alternative could be averaging?
 data_raw.o2(:,2) = nan;
 data_raw.salt(:,2) = nan;
 for indv=1:length(data_raw.variables)
    tmp = data_raw.(data_raw.variables{indv});
    if size(tmp,2)==2
       data_raw.(data_raw.variables{indv}) = nanmean(tmp,2);
    end
 end

 % Based on Kalvelage's paper, removes 2 umol to O2 profiles, based on comparison with Stox
 disp('Warning correcting O2 for STOX offset = 2 umol');
 inan = find(isnan(data_raw.o2));
 data_raw.o2 = max(0,data_raw.o2-2);
 data_raw.o2(inan) = nan;

 % Adds nstar (basic definition)
 inan = find(isnan(data_raw.po4)|isnan(data_raw.no3));
 data_raw.nstar = data_raw.no3 - 16*data_raw.po4;
 data_raw.nstar(inan) = nan;
 data_raw.variables = [data_raw.variables 'nstar'];
 data_raw.units = [data_raw.units 'umol/kg']; 

 % Final processing
 if (1)
 % Assigns a unique station index, from 1 to N by identifying stations
 % with unique [lon, lat, year month day];
 % Note, allows an uncertainty 'prec_lon', 'prec_lat' for lon and lat
    prec_lon = 0.3;		% Default : 0.02
    prec_lat = 0.3;		% Default : 0.02
    data = data_find_unique_stations(data_raw,'prec_lon',prec_lon,'prec_lat',prec_lat);

 % Goes through all stations and processes profiles by:
 % (1) sorting each profile by depth
 % (2) Merging multiple occurrences of same depth, by averaging numerical variables
 % and keeping the first occurrence for alphanumerical variables
    data = data_process_profiles(data);
 % If needed, adds depth_from_oxycline variable
 % Given 2 umol has been already removed, it seems 1.5 umol is fairly safe definition
 % (perhaps a bit generous)
    [data oxy_depth] = data_add_oxycline_depth(data,'o2_lim',1.5,'ioxy_depth',1);
 end

 % Save Kalvelage's data
 if (0)
    data_kalvelage = data;
    save data_kalvelage data_kalvelage;
 end 

