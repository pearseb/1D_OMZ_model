  function y = yield_from_stoich(biomass_CN, supply_CN);

  %     Estimate the yield of bacterial heterotrophy
  %  
  %  Parameters
  %  ----------
  %  Y_max : Float
  %      The maximum yield
  %  biomass_CN : Float
  %      The C:N stoichiometric ratio of the biomass produced by heterotrophs
  %  supply_CN : Float
  %      The C:N stoichiometric ratio of the organic matter fuelling heterotrophy
  %  K_CN : Float
  %      Half-saturation coefficient for the assimialtion of C:N precursor molecules
  %  eea_CN : Float
  %      Eco-Enzymatic Activity (EEA) rate of carbon and nitrogen processing%
  %
  %  Returns
  %  -------
  %  Float
  %      The yield of bacterial heterotrophy (0-->Y_Max) in mol Biomass C per mol Organic C
  %
    
    y_max = 0.6;                    % maximum yield possible for heterotrophy
    K_CN = 0.5;                     % C:N half-saturation coefficient (Sinsabaugh & Follstad Shah 2012 - Ecoenzymatic Stoichiometry and Ecological Theory)
    eea_CN = 1.123;                 % relative rate of enzymatic processing of complex C and complex N molecules into simple precursors for biosynthesis (Sinsabaugh & Follstad Shah 2012)
    s = biomass_CN ./ (supply_CN .* eea_CN); 
    y = y_max .* s ./ (s + K_CN);   % yield in mol bioC / mol orgC

  end
