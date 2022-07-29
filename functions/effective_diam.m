  function diam = effective_diam(vol);

  % Calculate the effectie diameter of a microbe given its volume
   diam = (3 .* vol ./ (4 .* pi) ).^(1./3).*2;

  end
