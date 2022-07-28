
 load /Users/danielebianchi/AOS/MANUSCRIPTS/2013-Bianchi-Babbin-DVM-and-Anammox/data/matlab/data_all_kalvelage.mat

 % Adds the bottom from ETOPO
 etopofile =  '/Users/danielebianchi/AOS/DATA/ETOPO/etopo5.nc';
 etopo = netcdf_load('file',etopofile);

 % First adds a unique station index
 ustation = nan([data_all.ncast 1]);
 % loops over all casts, using (lon,lat) pairs to assign unique station numbers
 lon = data_all.longitude;
 lat = data_all.latitude;
 pairs = [lon(:) lat(:)];
 [dum1 dum2 dum3] = unique(pairs,'rows');
 data_all.ustation = dum3;

 data_all.allstation = unique(data_all.ustation);
 data_all.nstation = length(data_all.allstation);

 tcol = jet(data_all.nstation);

 if (0)
   %fig = figure;
   %hold on
    for inds=1:data_all.nstation
       igood = find(data_all.ustation==data_all.allstation(inds)); 
       tdepth = data_all.depth(igood); 
       to2 = data_all.o2(igood); 
       tammx = data_all.anammox(igood); 
       if mean(data_all.idataset(igood))==6
          figure;
          plot(tammx,-tdepth,'.-','color',tcol(inds,:));
       end
    end
 end


