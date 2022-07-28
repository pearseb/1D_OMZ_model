 function secout = woce2_interp_profile(secin,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Arguments: 
 % Example:
 %  secout = woce2_interprof(secin,'var','sigma0','mode',P.mode,'number',P.number,'mincast',P.mincast, ...
 %                                    'skeleton',P.skeleton,'tolerance',P.tolerance);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 % History:
 % Version 2.0 : 03/09/2010
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % default arguments:
 A.var       	= 'temp';
                              % Number of contiguous profiles to inlcude
 A.mode       	= 'number';   % alternative: 'circle' : uses all proficles within a circle
 A.number   	= 8;
 A.radius   	= 500; % Radius in Km to include profiles for interpolation
 A.mincast     	= 3; % minimum # of casts to make a point valid in the profile
 A.tolerance   	= 2; % factor that provides the upper and lower bounds for rejecting a spline interpolated value
 A.iterpol     	= 'spline';
 A.diag		= 0;
 A.skeleton	= 0;
 % argments for selection
 % Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % UPPER OCEAN COARSENED
 %if length(Param.vertgrid) < 3
 %   vertgrid = [0 , 50,  100, 150, 200, 300, 400, 500, 600, ...
 %               800,  1000, 1250,  1500, 1750, 2000, 2250, ...
 %              2500, 2750, 3000, 3500, 4000, 5000 6000]';
 %else
 %   vertgrid = Param.vertgrid;
 %end
 %
 %skeleton = vertgrid(1:end-1) + diff(vertgrid)/2;
 %nskel = length(skeleton);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if length(Param.skeleton) < 3
    skeleton =  [10, 20 ,50, 100, 150, 200, 300, 400, 500, 600, 800, 1000, ...
                 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3500, ...
                 4000, 4500, 5000, 6000, 7000];
 else
    skeleton = Param.skeleton;
 end

 nskel = length(skeleton);
 vertgrid = zeros(1,length(skeleton)+1);
 vertgrid(1) = 0;
 for ind=2:length(vertgrid)
     vertgrid(ind) = 2*skeleton(ind-1) - vertgrid(ind-1);
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % Add needed functions
 addpath /Users/danielebianchi/AOS1/Ncycle/data/scripts/functions/ 

 % Add some internal variables
 secin.nvar = length(secin.variables);

 % Clean variable
 %secin = woce2_clean(secin,'var',Param.var);

 % Loops over all stations
 % checking that each station contains at least a measurement for the chosen variable
 allustations = secin.ustation(find(~isnan(secin.(Param.var))));
 
 ustation  = unique(allustations);
 industation = zeros(size(ustation));
 for inda=1:length(ustation)
     industation(inda) = min(find(secin.ustation==ustation(inda)));
 end 
 nstation  = length(ustation);
 xstation  = secin.lon(industation); 
 ystation  = secin.lat(industation); 

 % Preprocesses output
 secout = secin;
 secout.(['i_' Param.var]) = nan(size(secin.ustation)); 
 secout.(['d_i' Param.var '_dz']) = nan(size(secin.ustation)); 
 secout.nvar=secout.nvar+2;
 secout.variables{end+1}  = ['i_' Param.var];
 secout.variables{end+1}  = ['d_i' Param.var '_dz'];
 % Adds units (temporarily empty)
 ivar = find(strcmp(Param.var,secout.variables));
 secout.units{end+1}  = [secout.units{ivar} '/m'];
 secout.units{end+1}  = [secout.units{ivar} '/m2'];

 for  ind=1:nstation
    disp(['Var: ' Param.var  ' - Station ' num2str(ind) '/' num2str(nstation)]);
    locstat = ustation(ind);
    locind  = find(secin.ustation==locstat);
    locx    = secin.lon(locind(1)); 
    locy    = secin.lat(locind(1));
    locz    = secin.depth(locind);
    % calculates distances
    dist = zeros(size(ustation));
    for ind1=1:nstation
       dist(ind1) = m_lldist([locx xstation(ind1)],[locy ystation(ind1)]);
    end
    if strcmp(Param.mode,'circle')
       include = find(dist<Param.radius);	% index of station to include
    elseif strcmp(Param.mode,'number')
       [sortdist insortdist] = sort(dist);
       include = insortdist(2:min(length(sortdist),Param.number+1));
    else
       error(['Mode ' Param.mode ' not valid']);
    end
    uinclude = ustation(include);	% unique station number of station to include
    % Proceeds to create collapsed neighbor cast profile
    istoinclude = ismember(secin.ustation,uinclude);	% 1 if cast is included, 0 otherwise
    indistoinclude = find(istoinclude);
    inclx = secin.lon(indistoinclude); 
    incly = secin.lat(indistoinclude); 
    inclz = secin.depth(indistoinclude);
    inclvar = secin.(Param.var)(indistoinclude);
    % Removes BAD casts (equal to nan)
    indbadinclvar = find(isnan(inclvar));
    inclx(indbadinclvar) =[]; 
    incly(indbadinclvar) =[]; 
    inclz(indbadinclvar) =[]; 
    inclvar(indbadinclvar) =[]; 
    % collapses all casts onto skeleton grid
    skelz = skeleton;
    skelnca = zeros(size(skeleton));	% number of casts used at skeleton gridpoin
    skelvar = zeros(size(skeleton));	% variable at skeleton gridpoint
    minskelvar = zeros(size(skeleton));	% min variable at skeleton gridpoint
    maxskelvar = zeros(size(skeleton));	% max variable at skeleton gridpoint
    for ind1 = 1:nskel
        xlo = vertgrid(ind1); 
        xhi = vertgrid(ind1+1); 
        isin = (inclz>=xlo & inclz<xhi);
        skelnca(ind1) = sum(isin);
        skelvar(ind1) = mean(inclvar(isin));
        if ~ isempty(inclvar(isin))
           minskelvar(ind1) = min(inclvar(isin));
           maxskelvar(ind1) = max(inclvar(isin));
        else 
           minskelvar(ind1) = skelvar(ind1);
           maxskelvar(ind1) = skelvar(ind1);
        end
    end
    % removes points where there are less than mincast number of casts    
    indtoremove =  find(skelnca<Param.mincast); 
    skelz(indtoremove) = []; 
    skelnca(indtoremove) = []; 
    skelvar(indtoremove) = []; 
    minskelvar(indtoremove) = []; 
    maxskelvar(indtoremove) = []; 
    nskelvar = length(skelvar);
    % defines a spline approximating skelvar on skelz
    % only if there are 4 or more points
    % so far assumes the points are somehow contiguous
    % i.e. there are not big gaps in profile - this should be adressed
    % for example rejecting the profile, or reducing it
    if nskelvar>=4 
       pp = spline(skelz,skelvar);	% spline interpolating values
       ppder1 = pp;			% spline interpolating vertical gradient
       ppder2 = pp;			% spline interpolating vertical gradient
       ppder1.coefs = pp.coefs*diag([3 2 1],1);
       ppder2.coefs = pp.coefs*diag([6 2],2);
       % reorder the depths of the original profile
       [goodlocz indgoodlocz] = sort(locz);     
       newvar      = ppval(pp,goodlocz);
       newdvardz   = ppval(ppder1,goodlocz);
       newd2vardz2 = ppval(ppder2,goodlocz);
       % Excludes values outside the min and max
       % Interpolates linearly minskelvar and maxskelvar on goodlocz 
       % after applying an tolerance factor
       acceptminvar = skelvar - (skelvar - minskelvar) * Param.tolerance;
       acceptmaxvar = skelvar + (maxskelvar - skelvar) * Param.tolerance;
       newminvar = interp1(skelz,acceptminvar,goodlocz);
       newmaxvar = interp1(skelz,acceptmaxvar,goodlocz);
       izexclude1 = find(newvar<newminvar | newvar>newmaxvar);
       newvar(izexclude1) = nan;
       newdvardz(izexclude1) = nan;
       newd2vardz2(izexclude1) = nan;
       % includes only values within the skelz
       izexclude2 = find(goodlocz<min(skelz) | goodlocz>max(skelz));
       newvar(izexclude2) = nan;
       newdvardz(izexclude2) = nan;
       newd2vardz2(izexclude2) = nan;
       % reset the original order
       clear newindgoodlocz;
       newindgoodlocz(indgoodlocz) = (1:length(locz));
       newvar = newvar(newindgoodlocz); 
       newdvardz = newdvardz(newindgoodlocz); 
       newd2vardz2 = newd2vardz2(newindgoodlocz); 
    else
       newvar = nan(size(locz)); 
       newdvardz = nan(size(locz)); 
       newd2vardz2 = nan(size(locz)); 
    end 

    % Adds variables into structure
    secout.(['i_' Param.var])(locind) = newvar; 
    secout.(['d_i' Param.var '_dz'])(locind) = newdvardz; 
    secout.(['d2_i' Param.var '_dz2'])(locind) = newd2vardz2; 

    % diagnostics
    if (Param.diag==1)
       figure
       subplot(2,1,1)
       woce2_map(secin);  
       hold on
       plot(xstation(include),ystation(include),'og');
       plot(locx,locy,'r*');
       subplot(2,1,2)
       hold on
       plot(inclvar,-inclz,'.b'); % neigbor casts
       plot(newvar,-locz,'.-g'); %  spline interploated profile
       plot(skelvar,-skelz,'*--c'); % skeleton collapsed profile
       plot(secin.(Param.var)(locind),-locz,'or-'); % original profile
       if min(inclvar)< max(inclvar);xlim([min(inclvar) max(inclvar)]);end
       disp(['profile ' num2str(ind) '/' num2str(nstation) '... # ' num2str(locstat)]); 
       title(['profile ' num2str(ind) '/' num2str(nstation) '... # ' num2str(locstat)]); 
       %pause
       % end diagnostics
    end
 end

 end
  




