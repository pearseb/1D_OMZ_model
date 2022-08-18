function [sms diag] =  bgc1d_sourcesink(bgc,tr); 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % iNitrOMZ v1.0 - Simon Yang  - April 2019
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Specifies the biogeochemical sources and sinks for OMZ nutrient/PON/N2O model
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Make sure we have no negative concentration
 if bgc.RunIsotopes
    % Update 15N/N ratios
    bgc = bgc1d_initIso_update_r15n(bgc,tr);
 end
 tmpvar = fields(tr);
 % For safety, reduces zero and negative variables to small value
 % Technically non-zero is mostly important for PON
 epsn = 1e-24;
 for indf=1:length(tmpvar)
        tmp = max(epsn,tr.(tmpvar{indf}));
 	tr.(tmpvar{indf}) = tmp;
 end
 
 pon = tr.pon .* 0.1; 

 % % % % % % % % % % % % % % % % %
 % % % % Uptake rates (p)  % % % %
 % % % % % % % % % % % % % % % % %
 
 p_het_oxy     = bgc.het_po_coef .* tr.o2;                                      % Uptake of oxygen by heterotrophs
 
 p_facnar_no3  = bgc.facnar_Vmax_no3  .* ( tr.no3 ./ (tr.no3 + bgc.nar_Kno3));  % Uptake of NO3
 p_facnar_Oorg = bgc.facnar_Vmax_Oorg .* ( pon ./ (pon + bgc.het_Korg) ); % Uptake of organic matter
 p_facnar_Norg = bgc.facnar_Vmax_Norg .* ( pon ./ (pon + bgc.het_Korg) ); % Uptake of organic matter
 
 p_facnir_no2  = bgc.facnir_Vmax_no2  .* ( tr.no2 ./ (tr.no2 + bgc.nir_Kno2));  % Uptake of NO2
 p_facnir_Oorg = bgc.facnir_Vmax_Oorg .* ( pon ./ (pon + bgc.het_Korg) ); % Uptake of organic matter
 p_facnir_Norg = bgc.facnir_Vmax_Norg .* ( pon ./ (pon + bgc.het_Korg) ); % Uptake of organic matter
 
 p_aoo_nh4     = bgc.aoo_Vmax_nh4 .* ( tr.nh4 ./ (tr.nh4 + bgc.aoo_Knh4) );     % Uptake of NH4
 p_aoo_oxy     = bgc.aoo_po_coef .* tr.o2;                                      % Uptake of oxygen

 p_noo_no2     = bgc.noo_Vmax_no2 .* ( tr.no2 ./ (tr.no2 + bgc.noo_Kno2) );     % Uptake of NO2
 p_noo_oxy     = bgc.noo_po_coef .* tr.o2;                                      % Uptake of oxygen

 p_aox_nh4     = bgc.aox_Vmax_nh4 .* ( tr.nh4 ./ (tr.nh4 + bgc.aox_Knh4) );     % Uptake of NH4
 p_aox_no2     = bgc.aox_Vmax_no2 .* ( tr.no2 ./ (tr.no2 + bgc.aox_Kno2) );     % Uptake of NO2


 % % % % % % % % % % % % % % % % %
 % % % % Growth rates (u)  % % % %
 % % % % % % % % % % % % % % % % %
 
 u_facnar_aer = max(0.0, min((p_facnar_Oorg .* bgc.facnar_y_Oorg), (p_het_oxy .* bgc.facnar_y_oxy))); 
 u_facnar_ana = max(0.0, min((p_facnar_Norg .* bgc.facnar_y_Norg), (p_facnar_no3 .* bgc.facnar_y_no3))); 
 
 u_facnir_aer = max(0.0, min((p_facnir_Oorg .* bgc.facnir_y_Oorg), (p_het_oxy .* bgc.facnir_y_oxy))); 
 u_facnir_ana = max(0.0, min((p_facnir_Norg .* bgc.facnir_y_Norg), (p_facnir_no2 .* bgc.facnir_y_no2))); 
 
 u_aoo = max(0.0, min((p_aoo_nh4 .* bgc.aoo_y_nh4), (p_aoo_oxy .* bgc.aoo_y_oxy))); 
 u_noo = max(0.0, min((p_noo_no2 .* bgc.noo_y_no2), (p_noo_oxy .* bgc.noo_y_oxy))); 
 u_aox = max(0.0, min((p_aox_nh4 .* bgc.aox_y_nh4), (p_aox_no2 .* bgc.aox_y_no2))); 
 

 % % % % % % % % % % % % % % % % %
 % % % % Facultative types % % % %
 % % % % % % % % % % % % % % % % %
 
 u_facnar = zeros(1,bgc.nz);
 facnar_y_org = zeros(1,bgc.nz);
 facnar_aerob = zeros(1,bgc.nz);
 
 u_facnir = zeros(1,bgc.nz);
 facnir_y_org = zeros(1,bgc.nz);
 facnir_aerob = zeros(1,bgc.nz);
 
 for zz = 1:bgc.nz
     % Faculative NAR heterotroph
     if u_facnar_aer(zz) >= u_facnar_ana(zz)
         u_facnar(zz) = u_facnar_aer(zz);
         facnar_y_org(zz) = bgc.facnar_y_Oorg; 
         facnar_aerob(zz) = 1.0;
     else
         u_facnar(zz) = u_facnar_ana(zz);
         facnar_y_org(zz) = bgc.facnar_y_Norg; 
         facnar_aerob(zz) = 0.0;
     end
     % Faculative NIR heterotroph
     if u_facnir_aer(zz) >= u_facnir_ana(zz)
         u_facnir(zz) = u_facnir_aer(zz);
         facnir_y_org(zz) = bgc.facnir_y_Oorg; 
         facnir_aerob(zz) = 1.0;
     else
         u_facnir(zz) = u_facnir_ana(zz);
         facnir_y_org(zz) = bgc.facnir_y_Norg; 
         facnir_aerob(zz) = 0.0;
     end
 end
 
 
 
 %!!! mm1 = Michaelis-Menton hyperbolic growth (var / var * k) where k is
 %!!! concentration of var where growth rate is half its maximum value
    %----------------------------------------------------------------------
    % (1) Oxic Respiration rate (C-units, mmolC/m3/s):
    %----------------------------------------------------------------------
    %!!! Respiration rate based on PON, modified by oxygen concentration
    RemOx = bgc.Krem .* mm1(tr.o2,bgc.KO2Rem) .* tr.pon;
    
 if ~bgc.RunIsotopes 
    %----------------------------------------------------------------------
    % (2) Ammonium oxidation (molN-units, mmolN/m3/s):
    %----------------------------------------------------------------------
    %!!! AO based on oxygen and NH4 concentration (loss of NH4)
    Ammox = bgc.KAo .*  mm1(tr.o2,bgc.KO2Ao) .*  mm1(tr.nh4,bgc.KNH4Ao) ;

    %----------------------------------------------------------------------
    % (3) Nitrite oxidation (molN-units, mmolN/m3/s):
    %----------------------------------------------------------------------
    %!!! NO based on oxygen and NO2 concentration (loss of NO2)
    Nitrox = bgc.KNo .*  mm1(tr.o2,bgc.KO2No) .* mm1(tr.no2,bgc.KNO2No);

    %----------------------------------------------------------------------
    % (4) N2O and NO2 production by ammox and nitrifier-denitrif 
    %  Yields: nondimensional. Units of N, not N2O (molN-units, mmolN/m3/s): 
    %----------------------------------------------------------------------
    %!!! Some AMMOX goes to N2O, most to NO2
    Y = n2o_yield(tr.o2, bgc);
    % via NH2OH
    Jnn2o_hx   = Ammox .* Y.nn2o_hx_nh4;
    Jno2_hx    = Ammox .* Y.no2_hx_nh4;
    % via NH4->NO2->N2O
    Jnn2o_nden = Ammox .* Y.nn2o_nden_nh4;
    
    % % % % % % % % % % % %
    % % %   J-ANOXIC  % % % 
    % % % % % % % % % % % %

    %----------------------------------------------------------------------
    % (5) Denitrification (C-units, mmolC/m3/s)
    %----------------------------------------------------------------------
    RemDen1 = bgc.KDen1 .* mm1(tr.no3,bgc.KNO3Den1) .* fexp(tr.o2,bgc.KO2Den1) .* tr.pon;
    RemDen2 = bgc.KDen2 .* mm1(tr.no2,bgc.KNO2Den2) .* fexp(tr.o2,bgc.KO2Den2) .* tr.pon;
    RemDen3 = bgc.KDen3 .* mm1(tr.n2o,bgc.KN2ODen3) .* fexp(tr.o2,bgc.KO2Den3) .* tr.pon;

    %----------------------------------------------------------------------
    % (6) Anaerobic ammonium oxidation (molN2-units, mmolN2/m3/s):
    % Note Anammox is in units of N2, i.e. 2 x mmolN/m3/s
    %----------------------------------------------------------------------
    Anammox = bgc.KAx .* mm1(tr.nh4,bgc.KNH4Ax) .* mm1(tr.no2,bgc.KNO2Ax) .* fexp(tr.o2,bgc.KO2Ax);
       
    % Non-isotope case
   %bgc.r14no3 = 1.0;
   %bgc.r14no2 = 1.0;
   %bgc.r14nh4 = 1.0;
   %bgc.r14n2o = 1.0;

 else
    tr.i15n2o = tr.i15n2oA + tr.i15n2oB;
    %----------------------------------------------------------------------
    % (2) Ammonium oxidation (molN-units, mmolN/m3/s):
    %----------------------------------------------------------------------
    Ammox = bgc.KAo .*  mm1(tr.o2,bgc.KO2Ao) .*  mm1_Iso(tr.nh4,tr.i15nh4,bgc.KNH4Ao) ;

    %----------------------------------------------------------------------
    % (3) Nitrite oxidation (molN-units, mmolN/m3/s):
    %----------------------------------------------------------------------
    Nitrox = bgc.KNo .*  mm1(tr.o2,bgc.KO2No) .* mm1_Iso(tr.no2,tr.i15no2,bgc.KNO2No);

    %----------------------------------------------------------------------
    % (4) N2O and NO2 production by ammox and nitrifier-denitrif 
    %  Yields: nondimensional. Units of N, not N2O (molN-units, mmolN/m3/s): 
    %----------------------------------------------------------------------
    Y = n2o_yield(tr.o2, bgc);
    % via NH2OH (hydroxilamine pathway)
    Jnn2o_hx = Ammox .* Y.nn2o_hx_nh4;
    Jno2_hx  = Ammox .* Y.no2_hx_nh4;
    % via NH4->NO2->N2O (nitrifier denitrification pathway)
    Jnn2o_nden = Ammox .* Y.nn2o_nden_nh4;

    % % % % % % % % % % % %
    % % %   J-ANOXIC  % % %
    % % % % % % % % % % % %

    %----------------------------------------------------------------------
    % (5) Denitrification (C-units, mmolC/m3/s)
    %----------------------------------------------------------------------
    RemDen1 = bgc.KDen1 .* mm1_Iso(tr.no3,tr.i15no3,bgc.KNO3Den1) .* fexp(tr.o2,bgc.KO2Den1) .* tr.pon;
    RemDen2 = bgc.KDen2 .* mm1_Iso(tr.no2,tr.i15no2,bgc.KNO2Den2) .* fexp(tr.o2,bgc.KO2Den2) .* tr.pon;
    RemDen3 = bgc.KDen3 .* mm1_Iso(tr.n2o,tr.i15n2o,bgc.KN2ODen3) .* fexp(tr.o2,bgc.KO2Den3) .* tr.pon;

    %----------------------------------------------------------------------
    % (6) Anaerobic ammonium oxidation (molN2-units, mmolN2/m3/s):
    % Note: Anammox is in units of N2, i.e. 2 x mmolN/m3/s
    %----------------------------------------------------------------------
    Anammox = bgc.KAx .* mm1_Iso(tr.nh4,tr.i15nh4,bgc.KNH4Ax) .* mm1_Iso(tr.no2,tr.i15no2,bgc.KNO2Ax) .* fexp(tr.o2,bgc.KO2Ax);
 end

 KRemOx = RemOx./tr.pon;
 KRemDen1 = RemDen1./tr.pon;
 KRemDen2 = RemDen2./tr.pon;
 KRemDen3 = RemDen3./tr.pon;

 %----------------------------------------------------------------------
 % (8)  Calculate SMS for each tracer (mmol/m3/s)
 %---------------------------------------------------------------------- 
 %sms.o2   =  -bgc.OCrem .* RemOx - 1.5.*Ammox - 0.5 .* Nitrox;
 %sms.no3  =  Nitrox - bgc.NCden1 .* RemDen1; % .* bgc.r14no3;
 %sms.pon  =  -(RemOx + RemDen1 + RemDen2 + RemDen3);
 sms.po4  =  bgc.PCrem .* (RemOx + RemDen1 + RemDen2 + RemDen3);
 %sms.nh4  =  bgc.NCrem .* (RemOx + RemDen1 + RemDen2 + RemDen3) - (Jnn2o_hx + Jno2_hx + Jnn2o_nden) - Anammox; % .* bgc.r14nh4;
 %sms.no2  =  Jno2_hx + bgc.NCden1 .* RemDen1 - bgc.NCden2 .* RemDen2 - Anammox - Nitrox; % .* bgc.r14no2;
 % N2 (mmol N2/m3/s, units of N2, not N)
 %sms.n2   =  bgc.NCden3 .* RemDen3 + Anammox;
 %sms.kpon = -(KRemOx + KRemDen1 + KRemDen2 + KRemDen3);
 % N2O individual SMSs (mmol N2O/m3/s, units of N2O, not N)
 sms.n2oind.ammox = 0.5 .* Jnn2o_hx;
 sms.n2oind.nden  = 0.5 .* Jnn2o_nden;
 sms.n2oind.den2  = 0.5 .* bgc.NCden2 .* RemDen2;
 sms.n2oind.den3  = - bgc.NCden3 .* RemDen3;
 % N2O total SMS
 sms.n2o = (sms.n2oind.ammox + sms.n2oind.nden + sms.n2oind.den2 + sms.n2oind.den3);
 

 % % % % % % % 
 % Biomasses %
 % % % % % % %

 sms.facnar = (tr.facnar .* u_facnar)...
              - (bgc.resp .* max(0.0, tr.facnar - bgc.min_bio))*0.0...
              - (bgc.mort .* tr.facnar .* max(0.0, tr.facnar - bgc.min_bio));
 sms.facnir = (tr.facnir .* u_facnir)...
              - (bgc.resp .* max(0.0, tr.facnir - bgc.min_bio))*0.0...
              - (bgc.mort .* tr.facnir .* max(0.0, tr.facnir - bgc.min_bio));
 sms.aoo = (tr.aoo .* u_aoo)...
           - (bgc.resp .* max(0.0, tr.aoo - bgc.min_bio))*0.0...
           - (bgc.mort .* tr.aoo .* max(0.0, tr.aoo - bgc.min_bio)); 
 sms.noo = (tr.noo .* u_noo)...
           - (bgc.resp .* max(0.0, tr.noo - bgc.min_bio))*0.0...
           - (bgc.mort .* tr.noo .* max(0.0, tr.noo - bgc.min_bio));
 sms.aox = (tr.aox .* u_aox)...
           - (bgc.resp .* max(0.0, tr.aox - bgc.min_bio))*0.0...
           - (bgc.mort .* tr.aox .* max(0.0, tr.aox - bgc.min_bio)); 
 
 
 % % % % % % % 
 % Substrate %
 % % % % % % %
 
 mort_total =  (bgc.mort .* tr.facnar .* max(0.0, tr.facnar - bgc.min_bio))...
              +(bgc.mort .* tr.facnir .* max(0.0, tr.facnir - bgc.min_bio))...
              +(bgc.mort .* tr.aoo .* max(0.0, tr.aoo - bgc.min_bio))...
              +(bgc.mort .* tr.noo .* max(0.0, tr.noo - bgc.min_bio))...
              +(bgc.mort .* tr.aox .* max(0.0, tr.aox - bgc.min_bio));
 resp_total =  (bgc.resp .* max(0.0, tr.facnar - bgc.min_bio))...
              +(bgc.resp .* max(0.0, tr.facnir - bgc.min_bio))...
              +(bgc.resp .* max(0.0, tr.aoo - bgc.min_bio))...
              +(bgc.resp .* max(0.0, tr.noo - bgc.min_bio))...
              +(bgc.resp .* max(0.0, tr.aox - bgc.min_bio));

 sms.o2  =  -(u_facnar .* tr.facnar ./ bgc.facnar_y_oxy .* facnar_aerob )...
            - (u_facnir .* tr.facnir ./ bgc.facnir_y_oxy .* facnir_aerob)...
            - (u_aoo .* tr.aoo ./ bgc.aoo_y_oxy)...
            - (u_noo .* tr.noo ./ bgc.noo_y_oxy);

 sms.nh4 =  resp_total...
            + (u_facnar .* tr.facnar .* (1./facnar_y_org - 1))...
            + (u_facnir .* tr.facnir .* (1./facnir_y_org - 1))...
            - (u_aoo .* tr.aoo ./ bgc.aoo_y_nh4)...
            - (u_noo .* tr.noo)...
            - (u_aox .* tr.aox ./ bgc.aox_y_nh4);

 sms.no2 =  (u_aoo .* tr.aoo .* (1./bgc.aoo_y_nh4 - 1))...
            + (u_facnar .* tr.facnar ./ bgc.facnar_y_no3 .* (1 - facnar_aerob))...
            - (u_facnir .* tr.facnir ./ bgc.facnir_y_no2 .* (1 - facnir_aerob))...
            - (u_noo .* tr.noo ./ bgc.noo_y_no2)...
            - (u_aox .* tr.aox ./ bgc.aox_y_no2);

 sms.no3 =  (u_noo .* tr.noo ./ bgc.noo_y_no2)...
            - (u_facnar .* tr.facnar ./ bgc.facnar_y_no3 .* (1 - facnar_aerob))...
            + (u_aox .* tr.aox .* bgc.aox_e_no3);

 sms.n2  =  ((u_facnir .* tr.facnir ./ bgc.facnir_y_no2 .* (1 - facnir_aerob))...
            + (u_aox .* tr.aox .* bgc.aox_e_n2)) * 0.5;

 sms.pon =  mort_total...
            - (tr.facnar .* u_facnar ./ facnar_y_org)...
            - (tr.facnir .* u_facnir ./ facnir_y_org);

 sms.kpon = sms.pon ./ tr.pon; 

 %---------------------------------------------------------------------- 
 % (9) Here adds diagnostics, to be handy when needed
 %---------------------------------------------------------------------- 
 diag.RemOx   = RemOx;		% mmolC/m3/s
 diag.Ammox   = (u_aoo .* tr.aoo ./ bgc.aoo_y_nh4);		% mmolN/m3/s
 diag.Nitrox  = (u_noo .* tr.noo ./ bgc.noo_y_no2);		% mmolN/m3/s
 diag.Anammox = Anammox;	% mmolN2/m3/s
 diag.RemDen1 = RemDen1;	% mmolC/m3/s
 diag.RemDen2 = RemDen2;	% mmolC/m3/s
 diag.RemDen3 = RemDen3; 	% mmolC/m3/s
 diag.RemDen  = RemDen1 + RemDen2 + RemDen3;	%mmolC/m3/s
 diag.Jno2_hx = Jno2_hx;	% mmolN/m3/s
 diag.Jnn2o_hx   = Jnn2o_hx;	% mmolN/m3/s
 diag.Jnn2o_nden = Jnn2o_nden;	% mmolN/m3/s
 diag.Jn2o_prod = sms.n2oind.ammox + sms.n2oind.nden + sms.n2oind.den2;	% mmolN2O/m3/s
 diag.Jn2o_cons = sms.n2oind.den3;					% mmolN2O/m3/s
 diag.Jno2_prod = Jno2_hx + bgc.NCden1 .* RemDen1;			% mmolN/m3/s
 diag.Jno2_cons = - bgc.NCden2 .* RemDen2 - Anammox - Nitrox;		% mmolN/m3/s
 diag.kpon = -(RemDen1 -RemDen2-RemDen3-RemOx) ./ tr.pon;		% 1/s
 %---------------------------------------------------------------------- 

 if bgc.RunIsotopes
    % Update 15N/N ratios
    bgc = bgc1d_initIso_update_r15n(bgc,tr);
    % Calculate sources and sinks for 15N tracers
    sms.i15no3 = bgc.r15no2 .* bgc.alpha_nitrox .* Nitrox ...
 	       - bgc.r15no3 .* bgc.alpha_den1 .* bgc.NCden1 .* RemDen1;
    sms.i15no2 = bgc.r15nh4 .* (bgc.alpha_ammox_no2 .* Jno2_hx) ...
               + bgc.r15no3 .* bgc.alpha_den1 .* bgc.NCden1 .* RemDen1 ...
    	       - bgc.r15no2 .* bgc.alpha_den2 .* bgc.NCden2 .* RemDen2 ...
               - bgc.r15no2 .* bgc.alpha_ax_no2 .* Anammox ...
               - bgc.r15no2 .* bgc.alpha_nitrox .* Nitrox ;
    sms.i15nh4 = bgc.r15norg.* bgc.NCrem .* (RemOx + RemDen1 + RemDen2 + RemDen3) ...
               - bgc.r15nh4 .* (bgc.alpha_ammox_no2 .* Jno2_hx) ...
 	       - bgc.r15nh4 .* (bgc.alpha_ammox_n2o .* Jnn2o_hx + bgc.alpha_nden_n2o .* Jnn2o_nden) ...
	       - bgc.r15nh4 .* bgc.alpha_ax_nh4 .* Anammox;
    % N2O indivisual SMS	    
    sms.i15n2oind.ammox =   bgc.r15nh4.* bgc.alpha_ammox_n2o .* sms.n2oind.ammox;
    sms.i15n2oind.nden  =   bgc.r15nh4.* bgc.alpha_nden_n2o  .* sms.n2oind.nden;
    sms.i15n2oind.den2  =   bgc.r15no2.* bgc.alpha_den2      .* sms.n2oind.den2;
    % Get isotopomer partitioning
    % Ammox
    ii = dNisoSP('i15N', sms.i15n2oind.ammox, 'N', sms.n2oind.ammox, 'SP', bgc.n2oSP_ammox); 
    sms.i15n2oAind.ammox = ii.i15N_A;
    sms.i15n2oBind.ammox = ii.i15N_B;
    % Nitrifier-denitrification
    ii = dNisoSP('i15N', sms.i15n2oind.nden, 'N', sms.n2oind.nden, 'SP', bgc.n2oSP_nden);
    sms.i15n2oAind.nden = ii.i15N_A;
    sms.i15n2oBind.nden = ii.i15N_B;
    % Denitrification 2 (no2-->n2o)
    ii = dNisoSP('i15N', sms.i15n2oind.den2, 'N', sms.n2oind.den2, 'SP', bgc.n2oSP_den2);
    sms.i15n2oAind.den2 = ii.i15N_A;
    sms.i15n2oBind.den2 = ii.i15N_B;
    % Total
    sms.i15n2oA = sms.i15n2oAind.ammox + sms.i15n2oAind.nden + sms.i15n2oAind.den2 + ...
                  bgc.r15n2oA.*bgc.alpha_den3_Alpha.*sms.n2oind.den3;
    sms.i15n2oB = sms.i15n2oBind.ammox + sms.i15n2oBind.nden + sms.i15n2oBind.den2 + ...
                  bgc.r15n2oB.*bgc.alpha_den3_Beta.* sms.n2oind.den3;
    sms.i15n2oind.den3  = bgc.r15n2oA .* bgc.alpha_den3_Alpha .* sms.n2oind.den3 + ...
                          bgc.r15n2oB .* bgc.alpha_den3_Beta .* sms.n2oind.den3;
    % Sum all SMS
    sms.i15n2o = sms.i15n2oind.ammox + sms.i15n2oind.nden + sms.i15n2oind.den2 + sms.i15n2oind.den3;
   
    % Checks
    if (sms.i15n2oind.ammox ~= sms.i15n2oAind.ammox + sms.i15n2oBind.ammox) 
       error('Ammox: prod. of i15n2o is not equal to the summed prod. of i15n2oA and i15n2oB')
    end
    if (sms.i15n2oind.nden ~= sms.i15n2oAind.nden + sms.i15n2oBind.nden)
       error('Nitrifier-denitrificaiton: prod. of i15n2o is not equal to the summed prod. of i15n2oA and i15n2oB')
    end
    if (sms.i15n2oind.den2 ~= sms.i15n2oAind.den2 + sms.i15n2oBind.den2)
       error('Nitrite reduction (den2): prod. of i15n2o is not equal to the summed prod. of i15n2oA and i15n2oB')
    end
   
 end

