  function cquota = molC_per_um3(gCcell,vol);

  % Calculate the carbon quota per um3 in mol
   cquota = gCcell ./ vol ./ 12.0;
  
  end
