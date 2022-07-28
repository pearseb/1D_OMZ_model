 function woce2_map(sec,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Plots a dataset map in longitude-latitude space
 % using the unique station numbers (ustation - must be a variable!)
 % Usage:
 % woce2_map(sec,'sty','.b','coast',1) 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % History:
 % Version 3.0 : 16/10/2020 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % default arguments:
 A.fig       = 1;
 A.sty       = '.';
 A.col       = [0.8 0.2 0.2];
 A.col1      = [0.7 0.7 0.7];
 A.size      = 15;
 A.hold      = 'off';
 A.coast     = 1;
 A.var       = '';
 % Coastline parameters
 A.res             = 'intermediate';     % Resolution 'full','high','intermediate','low','crude'
                                        % Equivalent: 5, 4, 3, 2, 1
 A.lakes           = 0;
 A.ccol            = [0 0 0];
 A.linewidth       = 0.5;
 A.linestyle       = '-';
 A.padding         = 0.1;	% Padding space (relative) for map min and max extension
 % Parse required variables, substituting defaults where necessary
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 ihold = ishold;

 if A.fig==1 & ~strcmp(A.hold,'on');
    figure;
 end

 % If a variable is provided, then adds it in color for the points where it's not NaN
 if ~isempty(A.var)

    % First plot all points with unique stations ingray
    [ind1 ind2] = unique(sec.ustation);
    pp1 = plot(sec.lon(ind2),sec.lat(ind2),A.sty);
    set(pp1,'markersize',A.size,'color',A.col1);
    hold on

    % Then plits points with variable in red
    tmp = sec.(A.var);
    igood = find(~isnan(tmp)); 
    [ind3 ind4] = unique(sec.ustation(igood));
    pp2 = plot(sec.lon(igood(ind4)),sec.lat(igood(ind4)),A.sty);
    set(pp2,'markersize',A.size*1.25,'color',A.col);
 else
    [ind1 ind2] = unique(sec.ustation);
    pp1 = plot(sec.lon(ind2),sec.lat(ind2),A.sty);
    set(pp1,'markersize',A.size,'color',A.col);
 end

 % Sets a nice range for map
 minlon = min(min(sec.lon(ind2)));
 maxlon = max(max(sec.lon(ind2)));
 minlat = min(min(sec.lat(ind2)));
 maxlat = max(max(sec.lat(ind2)));
 % pads map ranges with some space
 lonrange = abs(maxlon-minlon);
 latrange = abs(maxlat-minlat);
 minlon = minlon - A.padding*lonrange;
 maxlon = maxlon + A.padding*lonrange;
 minlat = minlat - A.padding*latrange;
 maxlat = maxlat + A.padding*latrange;

 tax = [minlon maxlon minlat maxlat];
 axis(tax);

 if A.coast == 1
   plot_coast('res',A.res,'lakes',A.lakes,'color',A.ccol,'linewidth',A.linewidth,'linestyle',A.linestyle);
 end

 box on; grid on;

 % Restores original hold state
 switch ihold
 case 0
    hold off
 case 1
    hold on
 end

 return
