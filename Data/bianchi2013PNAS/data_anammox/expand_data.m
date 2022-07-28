 function data = expand_data(data)


 nvar = length(data.variables);

 for indv=1:nvar

    data.(data.variables{indv}) = data.data(:,indv);

 end




