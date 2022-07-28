function [hfig] = optim_plot_profiles(opt,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% version:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loads results from a series of optimizations
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default arguments
 A.var = {'o2','no3','po4','n2o','nh4','no2','n2','nstar'};
%A.var = {'o2','no3','po4','n2o','nh4','no2','n2','nstar'};
 A.mode = 1;    % 1 plots variable
                % 2 plots anomaly versus final value
 A.fig = 0;
 A.col = [0 0 0];
 A.ylim = [0 800];
 A = parse_pv_pairs(A,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if A.fig==0
   %hfig = figure;
   hfig = piofigs('lfig',1);
 else
   hfig = figure(A.fig);
 end
 if ~iscell(A.var)
    A.var = {A.var};
 end

 nvar = length(A.var);
 pp = numSubplots(nvar);
 sp1 = pp(1);
 sp2 = pp(2);

 plot_x = opt.var.ncount;
 plot_y = opt.var.zgrid;

 if ~isempty(A.ylim);
    yl1 = -abs(A.ylim(2));
    yl2 = -abs(A.ylim(1));
 else
    yl1 = opt.bgc{1}.zbottom; 
    yl2 = opt.bgc{1}.ztop;
 end

 for indv=1:nvar;

    varname = A.var{indv};
    switch A.mode
    case 1
       % plots variable
       var_plot = opt.var.(varname);
    case 2
       % plots variable - mean
       var_plot = opt.var.(varname);
       var_plot = var_plot - mean(var_plot,1);
    otherwise
      error('Plotting mode not found');
    end
    %var_range = [min(var_plot(:)) max(var_plot(:))];
	%{
    eps = 1e-10;
     mmin = min(var_plot(:));
    mmax = max(var_plot(:));
    var_range = [(1-sign(mmin)*0.1)*mmin-eps (1+sign(mmax)*0.1)*mmax+eps];
	%}
    if A.mode == 1
	var_range = prclims(var_plot,'prc',1,'bal',0);
    elseif A.mode == 2	
	var_range = prclims(var_plot,'prc',1,'bal',1);
    end
    var_span = diff(var_range);
    % ------------------------------------------------
    % Plots Variable
    subplot(sp1,sp2,indv)
    sanePColor(plot_x,plot_y,var_plot');
    shading flat
    colorbar
    title([varname])
    if ismember(indv,[1:sp2:sp2*10]);
    	ylabel('depth (m)')
    else
	set(gca,'YTickLabel',[]);
    end
    xlabel('optimization #')
    ylim([yl1 yl2]);
%{
    if A.mode==1
       caxis([var_range(1) var_range(2)]);
    else
       absmax = max(abs(mmin),abs(mmax));
       caxis([-absmax-eps absmax+eps]);
       colormap(mycolormaps('num',30,'scheme','redblue'));
    end
%}
    caxis(var_range);
    if A.mode == 1
	%colormap(cmocean('amp'));
	colormap(parula);
    elseif A.mode == 2
	%colormap(cmocean('balance'));
        colormap(mycolormaps('num',30,'scheme','redblue'));
    end
    grid on; box on;
 end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function [p,n]=numSubplots(n)
% function [p,n]=numSubplots(n)
%
% Purpose
% Calculate how many rows and columns of sub-plots are needed to
% neatly display n subplots. 
%
% Inputs
% n - the desired number of subplots.     
%  
% Outputs
% p - a vector length 2 defining the number of rows and number of
%     columns required to show n plots.     
% [ n - the current number of subplots. This output is used only by
%       this function for a recursive call.]
%
%
%
% Example: neatly lay out 13 sub-plots
% >> p=numSubplots(13)
% p = 
%     3   5
% for i=1:13; subplot(p(1),p(2),i), pcolor(rand(10)), end 
%
%
% Rob Campbell - January 2010


while isprime(n) & n>4,
    n=n+1;
end
p=factor(n);
if length(p)==1
    p=[1,p];
    return
end
while length(p)>2
    if length(p)>=4
        p(1)=p(1)*p(end-1);
        p(2)=p(2)*p(end);
        p(end-1:end)=[];
    else
        p(1)=p(1)*p(2);
        p(2)=[];
    end
    p=sort(p);
end
%Reformat if the column/row ratio is too large: we want a roughly
%square design 
while p(2)/p(1)>2.5
    N=n+1;
    [p,n]=numSubplots(N); %Recursive!
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
