function y = substrate_yield(y_org, bCN, bHN, bON, bgc, electrons);

  %     Estimate the yield of bacterial heterotrophy
  %  
  %  Parameters
  %  ----------
  %  Y_org : Float
  %      The yield of heterotrophy from organic matter (mol bioN / mol orgN)
  %  bCN : Float
  %      The C:N stoichiometric ratio of the biomass produced by heterotrophs
  %  bHN : Float
  %      The H:N stoichiometric ratio of the biomass produced by heterotrophs
  %  bON : Float
  %      The O:N stoichiometric ratio of the biomass produced by heterotrophs
  %  bgc : Structure
  %      need the stoichiometry of the organic matter supplied
  %  electrons : Float
  %      number of electrons required for substrate under consideration
  %
  %  Returns
  %  -------
  %  Float
  %      The yield of bacterial heterotrophy using the substrate of
  %      interest in mol Biomass N per mol substrate used
  %
    
    d_biomass = 4.*bCN + 1.*bHN - 2.*bON - 3;
    d_org = (4.*bgc.stoch_a + 1.*bgc.stoch_b - 2.*bgc.stoch_c - 3.*bgc.stoch_d) ./ bgc.stoch_d;
    fe = y_org .* d_biomass./d_org;                     % fraction of electrons used for biomass synthesis (Eq A9 in Zakem et al. 2020 ISME)
    y = (fe ./ d_biomass) ./ ( (1 - fe) ./ electrons ); % yield in mol bioN / mol substrate

  end
