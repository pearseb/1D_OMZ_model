 function data_out = find_unique_stations(data,varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Finds unique stations based on lon, lat, date criteria
 % assigns an index 'ustation" to identify the same stations
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Parse required variables, substituting defaults where necessary
 A.prec_lon = 0.01;
 A.prec_lat = 0.01;
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 vars = data.variables;
 nvar = length(data.variables);
 ncast = length(data.depth);

 % Initializes empty out structure (for safety!) 
 data_out = data;
 for indv=1:nvar
    tmp = data_out.(vars{indv});
    if isnumeric(tmp)
       data_out.(vars{indv}) = nan(size(tmp));
    else
       data_out.(vars{indv}) = repmat({''},size(tmp));
    end
 end
 % Adds unique station index to data_out
 data_out.ustation = nan(ncast,1);

 % Sets the criterion for same station:
 % Note, uses a roundoff uncertaity given by A.prec_lon, A.prec_lat
 all_coord = [round(data.lon/A.prec_lon)*A.prec_lon ...
              round(data.lat/A.prec_lat)*A.prec_lat ...
              data.date(:,1:3)];

 [u_all_coord iaa ibb] = unique(all_coord,'rows','stable');
 nunique = size(u_all_coord,1);

 % loops all the unique stations
 % starting index to fill current unique station
 istart=1;
 % ending index to fill current unique station
 iend = nan;
 for inds=1:nunique
    % Finds all indices of casts in the current unique station
    its =  find(ibb == inds);
    nits = length(its);
    iend = istart + nits - 1; 
    % loops through all variables and fills in
    for indv=1:nvar
       tmp = data.(vars{indv});
       data_out.(vars{indv})(istart:iend,:) = tmp(its,:);
    end
    % fills in ustation
    data_out.ustation(istart:iend,:) = inds;
    istart = iend+1;
 end

 % Updates variables and units with "ustation"
 data_out.variables = [data_out.variables 'ustation'];
 data_out.units = [data_out.units {''}];


