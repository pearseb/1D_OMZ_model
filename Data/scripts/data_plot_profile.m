 function woce2_plot_profile(sec,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
 A.var           = 'temp';
 A.depth_var     = 'depth'; % Chooses vertical variable for profiles
 A.ustations     = nan;
 A.sty           = '.';
 A.size          = 10;
 A.col           = [0.3 0.3 0.5];
 A.fig           = 1;
 A.hold          = 'off';
 A.mode          = 1; % 0 plot the whole section at once; 1 plot station by station
 A.rmnan	 = 1; % 1 removes NaNs when plotting profiles
 % argments for selection
 A.select        = 'off';
 A.zoom          = 'on';
 A.draw          = 1;
 A.linewidth     = 1;
 A.fontsize      = 18;
 A.fact		= 1; % multiplicative factor
 % Parse required variables, substituting defaults where necessary
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if strcmp(A.select,'on')
%   sec = woce2_selcruise(sec,'mode','station','zoom',A.zoom,'draw',A.draw);
%end

  % remove bad (-999) values from varname
% [sec index] = woce2_clean(sec,'var',A.var);
% if index==0;
%    return
% end

 if isnan(A.ustations)|isempty(A.ustations)
    ind = sec.ustation;
    unind = unique(ind); 
 else
    unind = A.ustations;
 end
 depth = sec.(A.depth_var);
 lvar = sec.(A.var)*A.fact;

 ihold = ishold;
 
 switch A.hold
 case 'on'
    hold on
 case 'off'
    hold off
    if A.fig==1
       figure
    end
 end
 
 if strcmp(A.hold,'off')
    hold off
 else
    hold on;
 end

 % Plots station-by-station

 if A.mode==1
   % plots station by station
   for i=1:length(unind)
     iloc = find(sec.ustation==unind(i)); 
     az = depth(iloc); 
     alvar = lvar(iloc); 
     [bz b] = sort(az);
     blvar = alvar(b);
     % Removes NaNs for cleaner profile plotting
     if A.rmnan==1
        irm = find(isnan(blvar));
        blvar(irm) = [];
        bz(irm) = [];
     end
     pp = plot(blvar,-bz,A.sty);
     set(pp,'color',A.col,'markersize',A.size,'linewidth',A.linewidth);
     hold on
   end
 else
   % plots all points at once (easier for large sections/global dataset)
     plot(lvar,-depth,A.sty);
 end
 grid on;box on;
 title([A.var],'fontsize',15);

 % Add axis labels
 xxlab = A.var; 
 yylab = 'depth (m)';
 ivar = find(strcmp(A.var,sec.variables));
 if isfield(sec,'units'); 
    xxlab = [xxlab ' (' sec.units{ivar}  ')'];
 end
 xlabel(xxlab);
 ylabel(yylab);
 
 % Restores original hold state
 switch ihold
 case 0
    hold off
 case 1
    hold on
 end 

 set(gca,'fontsize',A.fontsize);
