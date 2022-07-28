
 data_list = {
              'data_Dalsgaard_extended_2012'
              'data_Galan_2009'
              'data_Hamersley_2007'
              'data_Lam_2010'
              'data_Thamdrup_2006'
              'data_Ward_2009'
              'data_Kalvelage_2013'
 };

 ndata = length(data_list);

 data_all.ndata = ndata;
 data_all.datasets = data_list;

 variables = '';
 ncast = 0;

 for indd=1:ndata
    eval(['tmp = ' data_list{indd} ';']);
    variables = unique([variables tmp.variables]);
    ncast = ncast+length(tmp.label);
    clear tmp
 end


 data_all.ncast = ncast;
 data_all.variables = variables;
 
 data_all.name = repmat({''},[ncast 1]);
 data_all.label = repmat({''},[ncast 1]);
 data_all.idataset = repmat(nan,[ncast 1]);
 for indv=1:length(variables)
    data_all.(variables{indv}) = nan(ncast,1);
 end

 ind1 = 0;
 for indd=1:ndata
    eval(['tmp = ' data_list{indd} ';']);
    tmp = expand_data(tmp);
    tncast = length(tmp.label);
    ind0 = ind1 + 1;
    ind1 = ind0 + tncast - 1;
    
    data_all.name(ind0:ind1) = data_list(indd);
    data_all.label(ind0:ind1) = tmp.label;
    for indv=1:length(tmp.variables)
       data_all.(tmp.variables{indv})(ind0:ind1) = tmp.(tmp.variables{indv});
    end
    clear tmp
 end

 % Few useful name changes
 data_all.lon = data_all.longitude;
 data_all.lat = data_all.latitude;

 % Fills in the dataset index
 for indc=1:data_all.ncast
    data_all.idataset(indc) = find(strcmp(data_all.name(indc),data_all.datasets));   
 end


