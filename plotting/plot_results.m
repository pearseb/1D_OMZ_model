function plot_results(bgc)
% My own script to generate plots from BGC1D solutions
% ----- Figure 1 -----
% Takes bgc solution and plots tracers
% ----- Figure 2 -----
% Generates rate plots
% ----- Figure 3 -----
% Generates 'comprates_ETSP.mat' results

close all

% -----------------------------------------------------------
% Copy bgc and process
results = bgc;
rname   = results.RunName;

% -----------------------------------------------------------
% Get comprates_ETSP and process
load('../Data/comprates_ETSP.mat');

% Process comprates
% Find where data exists below oxycline
comprates = comprates.ETSP;
ind       = find(comprates.depth_from_oxicline<=0);
cvars = fields(comprates);
for i = 1:length(cvars)
	comprates.(cvars{i}) = comprates.(cvars{i})(ind);
end

% Reset depth to that position, -30
comprates.depth = comprates.depth_from_oxicline+results.ztop;

% -----------------------------------------------------------
% Process bgc tracers

% Calculate N*
results.Data_nstar = results.NCrem/results.PCrem*results.Data_po4 - results.Data_no3;
results.nstar      = -results.nstar;

% Get list of vars to compare
vars  = {'o2','no3','po4','nh4','n2o','no2','poc','n2','nstar'};
vunit = {'mmol O_2 m^{-3}','mmol NO_3 m^{-3}','mmol PO_4 m^{-3}',...
	 'mmol NH_4 m^{-3}','mmol N_2O m^{-3}','mmol NO_2 m^{-3}',...
	 'mmol C m^{-3}','mmol N_2 m^{-3}','mmol m^{-3}'};
vtit  = {'O_2','NO_3','PO_4','NH_4','N_2O','NO_2','POC','N_2','N*'};

% -----------------------------------------------------------
% Process bgc rates

% Get list of rates and their units
rates = {'remox','ammox','nitrox',...
	 'nh4tono2','nh4ton2o','no3tono2',...
	 'noxton2o','n2oton2','anammox'};
runit = {'nM N d^{-1}','nM N d^{-1}','nM N d^{-1}',...
	 'nM N d^{-1}','nM N d^{-1}','nM N d^{-1}',...
	 'nM N d^{-1}','nM N d^{-1}','nM N d^{-1}'};
rtit1  = {'Oxic Remineralization','Ammonium Oxidation','Nitrite Oxidation',...
	  'NO_2 from Ammox','N_2O from Ammox','Nitrate Reduction',...
	  'Nitrite Reduction','Nitrous Oxide Reduction','Anammox'};
rtit2  = {'POC \rightarrow NH_4','NH_4 \rightarrow NO_2','NO_2 \rightarrow NO_3',...
	  'NH_4 \rightarrow NO_2','NH_4 \rightarrow N_2O','NO_3 \rightarrow NO_2',...
	  'NO_2 \rightarrow N_2O','N_2O \rightarrow N_2','NH_4 + NO_2 \rightarrow N2'};

% Convert mmolC to mmolN
results.remox   = results.remox   * (results.stoch_d ./ results.stoch_a);

% Grab oxygen contourf levels
clevs = [floor(min(results.o2)):(ceil(max(results.o2))-floor(min(results.o2)))./255:ceil(max(results.o2))];
% -----------------------------------------------------------

% -----------------------------------------------------------
% Establish tracer figure
figure('units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 10 15])
set(gcf,'color','w');

% Generate tracer plots
for i = 1:length(vars)
	% Generate subplot
	subplot(3,3,i)
	eval(['s = scatter(results.Data_',vars{i},'(~isnan(results.Data_',vars{i},')),results.zgrid(~isnan(results.Data_',vars{i},')));'])
	hold on; grid on
	plot(results.(vars{i}),results.zgrid,'k','linewidth',3);
	s.MarkerFaceColor = 'b';
	s.LineWidth = 0.6;
	s.MarkerEdgeColor = 'k';
	s.MarkerFaceColor = [0 0.5 0.5];
	title(vtit{i});
	xlabel(vunit{i})
	hl = hline(results.ztop);
	hl.Color = 'r';
	hl.LineStyle = '--';
	ylim([results.zbottom 0]);
end
fname = ['tmpfigs/bgc1d_tracers'];
print('-djpeg',fname);
close all

% -----------------------------------------------------------
% Establish rates figure
figure('units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 10 15])
set(gcf,'color','w');

% Generate rate plots
for i = 1:length(rates)
	
	% Generate subplot
	subplot(3,3,i)
	hold on; grid on
	
	% Generate oxy meshgrid
	try
		linx  = linspace(min([min(results.(rates{i})) min(comprates.(rates{i}))]),...
			         max([max(results.(rates{i})) max(comprates.(rates{i}))]),255);
	catch
		linx  = linspace(min(results.(rates{i})),max(results.(rates{i})),255);
	end
	[meshx,meshy] = meshgrid(linx,results.zgrid);
	oxyz          = repmat(results.o2,255,1)';

	% Generate contourf
	contourf(meshx,meshy,oxyz,clevs,'linestyle','none');
	colormap(cmocean('-ice'))
	zind = find(oxyz(:,1)<=10);
	h1 = hline(results.zgrid(zind(1)));
	h2 = hline(results.zgrid(zind(end)));
	h1.LineWidth = 1;
	h2.LineWidth = 1;
	h1.LineStyle = '--';
	h2.LineStyle = '--';
	h1.Color = 'k';
	h2.Color = 'k';

	% Plot rates
	plot(results.(rates{i}),results.zgrid,'k','linewidth',3);
	try
		s = scatter(comprates.(rates{i}),comprates.depth);
		s.MarkerFaceColor = 'b';
        	s.LineWidth = 0.6;
		s.MarkerEdgeColor = 'k';
		s.MarkerFaceColor = [0 0.5 0.5];
	end
	title({rtit1{i},rtit2{i}});
	xlabel(runit{i})
	hl = hline(results.ztop);
	hl.Color = 'r';
	hl.LineStyle = '--';
	ylim([results.zbottom 0]);

end
fname = ['tmpfigs/bgc1d_rates'];
print('-djpeg',fname);
close all

% -----------------------------------------------------------
% Establish tracer figure
figure('units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 10 15])
set(gcf,'color','w');


% Generate comprates_ETSP plots
return

