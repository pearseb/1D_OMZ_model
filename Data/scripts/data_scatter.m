 function index = data_scatter(sec,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Arguments: 
 % 
 % Usage:
 % 
 % 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 % History:
 % Version 3.0 : 10/17/2020
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % default arguments:
 A.var1       	= 'salt';
 A.var2       	= 'temp';
 A.var3       	= 'none';
 A.mode		= 'normal';	% 'normal' : no variable transformation
				% 'log' : log-transform data
 A.hold       	= 'off';
 A.figure     	= 1;
 A.sty       	= 'b.';
 A.size       	= 30;
 A.caxis    	= 0;
 A.cb    	= 0;
 A.col    	= [0.3 0.3 0.5];
 A.size    	= 15;
 A.plotnan	= 1;
 A.rmse    	= 0;
 A.fontsize    	= 20;
 A.title    	= '';
 % Parse required variables, substituting defaults where necessary
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % If needed applies any variable transformation
 switch A.mode
 case 'log'
    var1 = log(sec.(A.var1));
    var2 = log(sec.(A.var2));
    if ~strcmp(A.var3,'none')
       var3 = sec.(A.var3);
    end
 case 'log3'
    var1 = log(sec.(A.var1));
    var2 = log(sec.(A.var2));
    if ~strcmp(A.var3,'none')
       var3 = log(sec.(A.var3));
    end
 otherwise
    var1 = sec.(A.var1);
    var2 = sec.(A.var2);
    if ~strcmp(A.var3,'none')
       var3 = sec.(A.var3);
    end
 end

 % Additional section for colouring
 if ~strcmp(A.var3,'none')
    cclim =  [min(var3) max(var3)];
 end

 if A.figure==1
    figure
 else
   if strcmp(A.hold,'off')
      hold off
   else
      hold on;
   end
 end

 if strcmp(A.var3,'none')
    % Case (1) only 2 variables 
    %uses plot for higher efficiency
    ibv1  = find(var1==-999);
    ibv2  = find(var2==-999);
    ibv3  = union(ibv1,ibv2);
    var1(ibv3) = [];
    var2(ibv3) = [];
    pp = plot(var1,var2,A.sty);
    set(pp,'color',A.col,'markersize',A.size);
 else
    % Case (2) use 3d variable for colouring
    if A.plotnan==1
       scatter(var1,var2,A.size,'o','markeredgecolor',[0.8 0.8 0.8],'markerfacecolor',[0.8 0.8 0.8])
       hold on
    end
    scatter(var1,var2,A.size,var3,'filled','markeredgecolor',A.col)

    if length(A.caxis)==2 
       cclim = A.caxis;
    end
    try;caxis(cclim);end

    switch A.cb
    case -1
       cb = colorbar;
    case 0
       cb = colorbarn;
    otherwise
       cb = colorbarn('num',A.cb);
    end
    cblab = A.var3;
    ivar3 = find(strcmp(A.var3,sec.variables));
    if isfield(sec,'units');
       cblab = [cblab ' (' sec.units{ivar3}  ')'];
    end
    cb.Label.String = cblab;
    cb.Label.FontSize = round(A.fontsize*0.9);
 end


 grid on
 box on
 xxlim = [min(var1) max(var1)];
 yylim = [min(var2) max(var2)];
 xlim(xxlim);
 ylim(yylim); 
 hold off
 title([A.title A.var2 '  vs.  ' A.var1 '  - colour: ' A.var3],'fontsize',A.fontsize,'interpreter','none');
 % Add axis labels
 xxlab = A.var1;
 yylab = A.var2;
 ivar1 = find(strcmp(A.var1,sec.variables));
 ivar2 = find(strcmp(A.var2,sec.variables));
 if isfield(sec,'units');
    xxlab = [xxlab ' (' sec.units{ivar1}  ')'];
    yylab = [yylab ' (' sec.units{ivar2}  ')'];
 end
 xlabel(xxlab);
 ylabel(yylab);

 set(gca,'fontsize',A.fontsize);
