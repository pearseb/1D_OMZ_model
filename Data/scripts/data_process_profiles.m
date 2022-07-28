 function data_out = woce2_process_profiles(data,varargin);  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % For a given section loops through each profile and processes by:
 % (1) sorting profile depth to be monotonically increasing
 % (2) average measurements for duplicate profiles and removes profiles
 % Arguments:
 %   'sort'  : 1 to sort profile depths
 %   'delete': 1 to delete profiles
 % Usage:
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % History:
 % Version :
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % default arguments:
 A.sort      = 1;
 A.delete    = 1;
 A.zcoord    = 'depth'; % could be pressure as well
 % Parse required variables, substituting defaults where necessary
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 stations  = unique(data.ustation);
 nstations = length(stations);

 nvar = length(data.variables);
 
 data_out = data;

 ustation_old = data_out.ustation;

 for indi = 1:nstations
    disp(['Processing profile ' num2str(indi) '/' num2str(nstations)]);
    lstat = find(ustation_old==stations(indi));
    ldepth     = data_out.(A.zcoord)(lstat);
    % (1) sorts profiles
    % If profile is not monotonically increasing rearranges profile
    if A.sort==1
       if any(diff(ldepth)<0)
          disp(['WARNING: Profile is not monotonically increasing - sorting profile']);
          [nldepth inewldepth] = sort(ldepth);
          for indv=1:nvar
             tempvar = data_out.(data_out.variables{indv})(lstat,:);
             data_out.(data_out.variables{indv})(lstat,:) = tempvar(inewldepth,:);
          end
       ldepth = nldepth;
       %lstat  = lstat(inewldepth);
       end   % End sorting
    end
    % (2) average duplicates values
    % Check for duplicates
    if A.delete==1
       [uldepth id jd] = unique(ldepth);
       if length(uldepth)~=length(ldepth)
          disp(['WARNING: Profile has duplicates - removing duplicates ']);
         %disp(indi);
         for indz=1:length(uldepth)
             lindz = find(ldepth==uldepth(indz));
             if length(lindz)>1
                duplstat = lstat(lindz);
                ndupl = length(duplstat);
                for indv=1:nvar
                   tmp = data_out.(data_out.variables{indv}); 
                   if isnumeric(tmp) & ~any(strcmp(data_out.variables{indv},{'date','ustation'}))
                      % averages variables, excluding -999 (nan)
                      dupldata = tmp(duplstat,:);
                      avedata = nanmean(dupldata,1);
                      % substitute the average for all duplicate indeces
                      data_out.(data_out.variables{indv})(duplstat,:) = repmat(avedata,[ndupl 1]);
                   else
                      %Takes first value (including for date)
                      avedata = tmp(duplstat(1),:);
                      data_out.(data_out.variables{indv})(duplstat,:) = repmat(avedata,[ndupl 1]);
                   end 
                   %  assigns a dummy value to ustation to flag it for removal
                   data_out.ustation(duplstat(2:end)) = -999999;
                end
             end
          end
       end
    end
 end

 % Now removes duplicated casts for which we set ustations=-999999
 iexclude = find(data_out.ustation==-999999);
 for indv=1:nvar
    data_out.(data_out.variables{indv})(iexclude,:) = [];
 end
 % Updates "ustations"
 [dum1 dum2 dum3] = unique(data_out.ustation);
 data_out.ustation = dum3;

 end

