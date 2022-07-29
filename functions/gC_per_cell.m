 function cquota = gC_per_cell(CN,HN,ON,vol);

  % Calculate the carbon quota per cell in grams
  %     Assumes that 0.1 g dry weight per 1 gram wet weight for all
  %     microbial types, as per communication with Marc Strous
   cquota = 0.1 .* ( 12.*CN / (12.*CN + HN + 16.*ON + 14) ) / ( 1e12 ./ vol );

  end