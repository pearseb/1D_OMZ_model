% Generates rate for optimization
% These are a combination of rates from various publications
% Philosophy:
% - Reference data to oxicline
% - Average all data available
% - Remove some blatant outliers to make it "well behaved" or "representative"
% - Consider carefully some obvious inconsistencies, e.g. 
%	- Large NO2- oxidation rates under O2=0 (Iodate? Dismutation?)
%	- No Denitrification in Kalvelage
% - Either merge different authors' processed datasets or merge all and process?

% ETSP sources:
% - Kalvelage et al., 2013 (RV MEteor 2009)
%	- Anammox
%	- NO3- reduction to NO2- (but careful with outliers/extreme values)
%	- NH4+ oxidation to NO2-
%	- NO2- oxidation to NO3-
% -  Ji et al., 2018 (RV Palmer 2013; RV Atlantis 2017)
%	- NO3- reduction to NO2- 
%	- NH4+ oxidation to NO2-
%	- N2O production from NH4+ oxidation
%	- N2O production from NO2- reduction
%	- N2O production from NO3- reduction


 % Ji et al., 2018 data (ingested by S. Yang)
 load /Users/danielebianchi/AOS1/Ncycle/iNitrOMZ_v6.1/Data/comprates_ETSP.mat;
 rates_j18_v1 = comprates.ETSP;

 % Kalvelage 2013 data
 load /Users/danielebianchi/AOS1/Ncycle/data/kalvelage2013NatGeo/data_kalvelage.mat;
 rates_k13_v0 = data_kalvelage; 

 % Process Kalvelage's data
 % Uses same formulation and names as S. Yang "comprates" structure
 rates_k13_v1.no3tono2 = rates_k13_v0.no3re;
 rates_k13_v1.nh4tono2 = rates_k13_v0.nh4ox;
 rates_k13_v1.no2tono3 = rates_k13_v0.no2ox;
 rates_k13_v1.anammox  = rates_k13_v0.anamx;
 rates_k13_v1.depth    = rates_k13_v0.depth;
 rates_k13_v1.oxycline_depth = rates_k13_v0.oxycline_depth;
 % Note that for consistency needs to be negative *deeper* than the oxycline
 % Hence uses a sign "minus" from original calculation
 rates_k13_v1.depth_from_oxycline = - rates_k13_v0.depth_from_oxycline;
 % Remove points where all rates are NaNs
 % And, for consistency with Palmer 2013 measurements (oxycl. @ approx 100-125m), 
 % profiles with oxycline outside the range 75-150m 
 ibad = find((isnan(rates_k13_v1.no3tono2) & isnan(rates_k13_v1.nh4tono2) & ...
              isnan(rates_k13_v1.no2tono3) & isnan(rates_k13_v1.anammox)) | ...
              isnan(rates_k13_v1.depth_from_oxycline) | ...
              (rates_k13_v1.oxycline_depth>150 | rates_k13_v1.oxycline_depth<75) ...
              );
 % To exclude all:
 %ibad = [1:length(rates_k13_v1.depth)];
 % Here could also include criterion on oxycline depth
 % indb = find(rates_k13_v1.oxycline_depth>150 | rates_k13_v1.oxycline_depth<75) 

 rates_k13_v1.no3tono2(ibad) = [];
 rates_k13_v1.nh4tono2(ibad) = [];
 rates_k13_v1.no2tono3(ibad) = [];
 rates_k13_v1.anammox(ibad) = [];
 rates_k13_v1.depth(ibad) = [];
 rates_k13_v1.oxycline_depth(ibad) = [];
 rates_k13_v1.depth_from_oxycline(ibad) = [];

 if (0)
 % Some outlier processing of "extreme rates"
 maxval.no3tono2 = prctile(rates_k13_v1.no3tono2,90);
 maxval.anammox  = prctile(rates_k13_v1.anammox,90);
 rates_k13_v1.no3tono2(rates_k13_v1.no3tono2>maxval.no3tono2) = maxval.no3tono2;
 rates_k13_v1.anammox(rates_k13_v1.anammox>maxval.anammox) = maxval.anammox;
%rates_k13_v1.no3tono2(rates_k13_v1.no3tono2>maxval.no3tono2) = nan;
%rates_k13_v1.anammox(rates_k13_v1.anammox>maxval.anammox) = nan;
 end

 %-----------------------------------------------------------------------------
 % Merge datasets
 %-----------------------------------------------------------------------------
 
 % Lumps all data together
 rates_all.depth = [rates_j18_v1.depth;rates_k13_v1.depth];
 rates_all.oxycline_depth = [rates_j18_v1.oxicline_depth;rates_k13_v1.oxycline_depth];
 rates_all.depth_from_oxycline = [rates_j18_v1.depth_from_oxicline;rates_k13_v1.depth_from_oxycline];
 rates_all.dataset_source = [1*ones(size(rates_j18_v1.depth));2*ones(size(rates_k13_v1.depth))];
 rates_all.no3tono2 = [rates_j18_v1.no3tono2;rates_k13_v1.no3tono2];
 rates_all.nh4ton2o = [rates_j18_v1.nh4ton2o;nan(size(rates_k13_v1.depth))];
 rates_all.noxton2o = [rates_j18_v1.noxton2o;nan(size(rates_k13_v1.depth))];
 rates_all.nh4tono2 = [rates_j18_v1.nh4tono2;rates_k13_v1.nh4tono2];
 % For Anammox, just keeps Kalvelage, since S.Yang compilation came mostly from it
 rates_all.anammox  = [nan(size(rates_j18_v1.depth));rates_k13_v1.anammox];
 rates_all.no2tono3 = [nan(size(rates_j18_v1.depth));rates_k13_v1.no2tono3];

 %-----------------------------------------------------------------------------
 %  Processing of merged dataset
 %-----------------------------------------------------------------------------

 if (1)
 % If needed plots dataset
 allvars = {'no3tono2','nh4ton2o','noxton2o','nh4tono2','anammox','no2tono3'};
 % Uses different colors for different data sources 
 col(1:3,1) = [0.8 0.3 0.3];
 col(1:3,2) = [0.3 0.3 0.8];
 ff =  figure;
 for indv=1:length(allvars)
 %------------------
 s1 = subplot(2,3,indv);
 ind1 = find(rates_all.dataset_source==1);
 ind2 = find(rates_all.dataset_source==2);
 pp1 = plot(rates_all.(allvars{indv})(ind1),rates_all.depth_from_oxycline(ind1),'.');
 set(pp1,'color',col(:,1),'markersize',15)
 hold on
 pp2 = plot(rates_all.(allvars{indv})(ind2),rates_all.depth_from_oxycline(ind2),'.');
 set(pp2,'color',col(:,2),'markersize',15)
 title(allvars{indv});
 set(s1,'fontsize',18);
 %------------------
 end % for loop
 end
 
 %-----------------------------------------------------
 % Performs binning around the oxycline using "depth_from_oxycline"
 % Specifies witdth of bins in m
 bin_width = 5;
 % New depth axis
 new_depth_min = floor(min(rates_all.depth_from_oxycline)/bin_width)*bin_width;
 new_depth_max = ceil(max(rates_all.depth_from_oxycline)/bin_width)*bin_width;
 depth1 = [new_depth_min:bin_width:new_depth_max]';
 dz = diff(depth1);
 depth2 = [depth1 + [dz;dz(end)]/2];
 new_depth_bounds = [depth2(1:end-1) depth2(2:end)];
 new_depth = mean(new_depth_bounds,2);

 % Initializes binned rates structure
 rates_bin.depth_from_oxycline = new_depth;
 % Bins data
 alldepths = rates_all.depth_from_oxycline;
 allvars = {'no3tono2','nh4ton2o','noxton2o','nh4tono2','anammox','no2tono3'};
 for indv=1:length(allvars);
    % Initializes variable in output strucutre
    rates_bin.(allvars{indv}) = nan(size(rates_bin.depth_from_oxycline));
    tmpvar = rates_all.(allvars{indv});
    % Loops through all depths
    for indd=1:length(new_depth);
       iloc = find(alldepths>=new_depth_bounds(indd,1) & alldepths<new_depth_bounds(indd,2));
       lvar = tmpvar(iloc);
       mvar = nanmean(lvar);
      %mvar = nanmedian(lvar);
       rates_bin.(allvars{indv})(indd) = mvar;
    end
 end 

 if (1)
 ff =  figure;
 for indv=1:length(allvars)
 %------------------
 ss = subplot(2,3,indv);
 pp = plot(rates_bin.(allvars{indv}),rates_bin.depth_from_oxycline,'d');
 set(pp,'markerfacecolor',[0.2 0.2 0.2],'markersize',10)
 hold on
 tmp = get(ss,'XLim');
 plot([tmp],[0 0],'--r','linewidth',2);
 title(allvars{indv});
 set(ss,'fontsize',18);
 %------------------
 end % for loop
 end


 if (0)
  comprates.ETSP = rates_bin;
  save comprates_ETSP_Combined_mean comprates;
 %save comprates_ETSP_Combined_median;
 end
