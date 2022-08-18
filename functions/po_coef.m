  function po = po_coef(diam, Qc, CN);

  % Calculates the maximum rate that O2 can be diffused into a cell
  %
  %  Parameters
  %  ----------
  %  diam : Float
  %      equivalent spherical diatmeter of the microbe (um)
  %  Qc : Float
  %      carbon quota of a single cell (mol C / um^3)
  %  C_to_N : Float
  %      carbon to nitrogen ratio of the microbes biomass
  %  
  %  Returns
  %  -------
  %  po_coef : Float
  %      The maximum rate of O2 diffusion into the cell in units of m^3 / mmol N / s
  %

    dc = 1.5775 .* 1e-5;                    % cm2/s for 12C, 35 psu, 50 bar (Unisense seawater and gases table)
    dc = dc .* 1e-4 * 86400;                % cm2/s --> m2/day
    Vc = 4./3 .* pi .* (diam./2).^3;        % volume of the cell
    Qn = Qc ./ CN * Vc;                     % mol N / cell
    p1 = 4 .* pi .* dc .* (diam.*1e-6./2);  % convert diameter to meters (from um) because diffusion coefficent is in m/day
    pm = p1 ./ Qn;                          % m3 / mol N / day
    po = pm .* 1e-3 / 86400;                % m3 / mmol N / s

  end
