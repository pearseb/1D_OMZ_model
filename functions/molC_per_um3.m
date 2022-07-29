  function cquota = molC_per_um3(gCcell,vol);

  % Calculate the carbon quota per um3 in mol
   cquota = gCcell ./ vol ./ 12.0;
  % normalise by measured C quotas (g/cell)
   cquota = cquota * (6.5e-15 / gCcell);

  end
