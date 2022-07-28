 function [data oxycline_depth] = data_add_oxycline(data,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Adds a new depth variable, which is "depth from oxycline"
 % Here uses a simple concentration threshold for oxycline depth, e.g. O2=2umol (default)
 % If no oxycline is found, fills "depth_from_oxycline" to 0
 % NOTE: only upper oxycline is considered, further crossing of the threshold are ignored!
 %
 % Usage : 
 % Example:
 % Plots 
 %
 %
 % sec: the original section
 %
 % var: variable to plot
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % History:
 % Version 0.0 : 05-24-08 dbianchi
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % default arguments:
 A.o2_lim 	= 1.0;		% O2 threshold (mmol/m2) for oxycline detection
 A.int_dz 	= 0.1;		% For interpolation purposes, vertical step of finer grid (m)
 A.int_method 	= 'linear';	% Method for interpolation on finer grid
 A.ioxy_depth   = 0;		% Set to 1 to save also oxycline depth
 A.verbose 	= 1;		% Display messages
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Initializes
 ncast = length(data.lon);
 depth_from_oxycline = nan(ncast,1);
 oxycline_depth_long = nan(ncast,1);
 % Includes oxycline depth itself if needed
 ustation = unique(data.ustation);
 nstat = length(ustation);
 oxycline_depth = nan(1,nstat);

 % Loops through all stations 
 for inds=1:nstat
    % Finds current indices
    tind = find(data.ustation==ustation(inds));
    tdepth = data.depth(tind);
    to2 = data.o2(tind);
 
    % First cleans depths that contain NaNs in o2
    igood = find(~isnan(to2));
    % Removes NaNs from current calculation
    ndepth = tdepth(igood); 
    no2 = to2(igood); 
    nz = length(ndepth);
    % Only works if there are at least two distinct depths to search for oxycline
    if nz>=2
       % Makes a finer (1m) depth grid and interpolates o2
       new_depth = [ndepth(1):A.int_dz:ndepth(end)]'; 
       new_o2 = interp1(ndepth,no2,new_depth,A.int_method);
       % Finds occurences of o2_threshold 
       indanox = find(new_o2<=A.o2_lim);
       if ~isempty(indanox)
          oxycline_depth(1,inds) = new_depth(indanox(1));
       else
          % No oxycline found
          oxycline_depth(1,inds) = nan;
          if A.verbose==1;disp(['No oxycline found at profile #' num2str(ustation(inds))]);end          
       end
    else
       % Profile contains two few depths
       oxycline_depth(1,inds) = nan;
       if A.verbose==1;disp(['Too few depths at profile #' num2str(ustation(inds))]);end          
    end
    
    % Now calculates depth from oxycline
    % In case of NaN, then all depths will be NaNs
    depth_from_oxycline(tind) = tdepth - oxycline_depth(1,inds);
    oxycline_depth_long(tind) = oxycline_depth(1,inds);
 end
 
 % Adds in the final variable to the data structure
 data.depth_from_oxycline = depth_from_oxycline;
 data.variables = [data.variables 'depth_from_oxycline'];
 data.units = [data.units 'm'];
 if A.ioxy_depth==1
    % Also adds in the oxycline depth
    data.oxycline_depth = oxycline_depth_long;
    data.variables = [data.variables 'oxycline_depth'];
    data.units = [data.units 'm'];
 end

