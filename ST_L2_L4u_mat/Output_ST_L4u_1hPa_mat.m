clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Load PRECIP-2021 upper-air radiosonde data.
% Transfer each data from L2 (Aspen-QCed, mat format) to L4 (mat format).
% 
% ==============================================================================

%% Load file parameters:

% Station number:
project_no = 'precip21'

% Year:
year_no = {'2021'};

% Month:
month_no = {'01','02','03','04','05','06','07','08','09','10','11','12'};

% ==============================================================================

%% Set constants:
g       =       9.80665; % gravity acceleration (m/s^2)
R0      =           287; % gas constant for dry air (J/(K*kg))
cp      =          1004; % specific heat of dry air at constant pressure (J/(K*kg))
Gamma_d =          g/cp; % dry adiabatic temperature lapse rate (K/m) 
Gamma_m =        6.8e-3; % moist adiabatic tempreature lapse rate (K/m)
Lc      =         2.5e6; % latent heat of condensation (J/kg)
CD      =        1.5e-3; % surface turbulent transfer coefficient over oceans

%% Set functions:

% Latent heat of vaporization (J/kg), T in [K]. (According to R. R. Rogers; M. K. Yau 1989)
Lw = @(T) (2500.8 - 2.36.*(T-273.15) + 0.0016.*(T-273.15).^2 - 0.00006.*(T-273.15).^3 ).*1e3;

% Equivalent temperature, T in [K], mixing ratio in [kg/kg].
t_e = @(T,MR) T + (Lc./cp).*MR;

% Potential temperature, P in [hPa], T in [K].
theta = @(P,T) T.*(1e3./P).^(R0/cp);

% Saturation mixing ratio, P in [hPa], T in [K], RH = 100%.
mrs = @(P,T) convert_humidity_RH_MR_yhj(P,T,100);

% Equivalent Potential Temperature:
    % Bolton 1980, P in [hPa], T in [K], RH in [%].
    theta_e_Bolton = @(P,T,RH) equivalent_potential_temp_Bolton(P,T,RH);

    % Holton 1972, P in [hPa], T in [K], RH in [%].
    theta_e_Holton = @(P,T,RH) equivalent_potential_temp_Holton(P,T,RH);

    % Simplified formula found on Wiki, P in [hPa], T in [K], RH in [%].
    theta_e_t_e = @(P,T,RH) equivalent_potential_temp_Te(P,T,RH);

% Saturation Equivalent Potential Temperature:
    % Bolton 1980, P in [hPa], T in [K], RH is 100%.
    theta_es_Bolton = @(P,T) equivalent_potential_temp_Bolton(P,T,100);

    % Holton 1972, P in [hPa], T in [K], RH is 100%.
    theta_es_Holton = @(P,T) equivalent_potential_temp_Holton(P,T,100);

    % Simplified formula found on Wiki, P in [hPa], T in [K], RH is 100%.
    theta_es_t_e = @(P,T) equivalent_potential_temp_Te(P,T,100);

% Dry Static Energy, T in [K], z in [m].
dse = @(T,Z) cp.*T + g.*Z;

% Moist Static Energy, T in [K], Z in [m], mixing ratio in [kg/kg].
mse = @(T,Z,MR) cp.*T + g.*Z + Lw(T).*MR;

% ==============================================================================

%% Set parameters:

p_res = 1;

% ==============================================================================

%% Load files and output:

fileID = fopen('./log.txt','w');

%% File path:
L2_input_file_path     = ['../L2_mat/',year_no{1},'/'];
L4_output_file_path    = ['./',year_no{1},'/'];

data_L2_list = dir([L2_input_file_path,'*.mat']);
        
for di = 1:length(data_L2_list)
    
    load_data = load([L2_input_file_path,data_L2_list(di).name]);
    
    eval([' data_L2 = load_data.ST_L2_',data_L2_list(di).name(10:end-4),'; ']);
    
    clear load_data
    
    %% Put data in the output format:
    
    % tmp_data.Station = data_L2.Station;
    
    tmp_data.NominalTime = data_L2.NominalTime;
    
    tmp_data.ST_No = data_L2.ST_No;
    
    tmp_data.LaunchLocation = data_L2.LaunchLocation;
    
    tmp_data.LaunchTime = data_L2.LaunchTime;
    
    if ( exist([L4_output_file_path,data_L2_list(di).name],'file') ~= 0 )
        
        disp([data_L2_list(di).name,' already done.'])
        
    else
        
        fprintf(fileID,'%s\n',data_L2_list(di).name);
        
        %% Interpolation to P:
        
        if ( mod(data_L2.P(1),p_res) ~= 0 )
            tmp_data.P = [data_L2.P(1),floor(data_L2.P(1)./p_res)*p_res:-p_res:ceil(min(data_L2.P)./p_res)*p_res]';
        else
            tmp_data.P = [data_L2.P(1),floor(data_L2.P(2)./p_res)*p_res:-p_res:ceil(min(data_L2.P)./p_res)*p_res]';
        end
        
        nan_p = isnan(data_L2.P);
        tmp_p = data_L2.P(~nan_p) + [1:numel(data_L2.P(~nan_p))]'.*1e-7; % ADD AN SMALL MONOTONIC EPSILON TO ENSURE THE INTERPOLATION.
        
        tmp_data.TIME_s = interp1(tmp_p,data_L2.TIME_SEC(~nan_p),tmp_data.P,'nearest');
        % tmp_data.Z      = interp1(tmp_p,data_L2.Z(~nan_p),tmp_data.P,'linear');
        tmp_data.Z_GPS  = interp1(tmp_p,data_L2.Z_GPS(~nan_p),tmp_data.P,'linear');
        tmp_data.TC     = interp1(tmp_p,data_L2.TC(~nan_p),tmp_data.P,'linear');
        tmp_data.TD     = interp1(tmp_p,data_L2.TD(~nan_p),tmp_data.P,'linear');
        tmp_data.RH     = interp1(tmp_p,data_L2.RH(~nan_p),tmp_data.P,'linear');
        tmp_data.RHI    = interp1(tmp_p,data_L2.RHI(~nan_p),tmp_data.P,'linear');
        tmp_data.WD     = interp1(tmp_p,data_L2.WD(~nan_p),tmp_data.P,'nearest');
        tmp_data.WS     = interp1(tmp_p,data_L2.WS(~nan_p),tmp_data.P,'linear');
        tmp_data.U      = interp1(tmp_p,data_L2.U(~nan_p),tmp_data.P,'linear');
        tmp_data.V      = interp1(tmp_p,data_L2.V(~nan_p),tmp_data.P,'linear');
        
        % Geopotential Height:
        for tmpi = 1:length(tmp_data.P)
            if ( tmpi == 1 )
                tmp_data.Z(tmpi) = data_L2.LaunchLocation(3);
            else
                tmp_data.Z(tmpi) = tmp_data.Z(1) + hydro_height(tmp_data.P(tmpi).*100,tmp_data.TC(tmpi)+273.15,tmp_data.P(1).*100);
            end
        end
        tmp_data.Z = tmp_data.Z';
                
        data_L2.LON(data_L2.LON==-999) = NaN;
        data_L2.LAT(data_L2.LAT==-999) = NaN;
        tmp_data.LON    = interp1(tmp_p,data_L2.LON(~nan_p),tmp_data.P,'linear');
        tmp_data.LAT    = interp1(tmp_p,data_L2.LAT(~nan_p),tmp_data.P,'linear');
        
        clear nan_p
        
        %% Derived fields:
        
        % Moisture:
        for mr_i = 1:numel(tmp_data.P)
            tmp_data.MR(mr_i,1) = convert_humidity_RH_MR_yhj(tmp_data.P(mr_i),tmp_data.TC(mr_i)+273.15,tmp_data.RH(mr_i)); % [kg/kg]
            tmp_data.MRS(mr_i,1) = mrs(tmp_data.P(mr_i),tmp_data.TC(mr_i)+273.15);
        end
        
        nan_mr = isnan(tmp_data.MR);
        tmp_data.TPW = (1/9.8).*(-trapz(tmp_data.P(~nan_mr).*100,tmp_data.MR(~nan_mr))); % [mm]
        clear nan_mr
        
        % Thermodynamics:
        tmp_data.TE = t_e(tmp_data.TC+273.15,tmp_data.MR);
        tmp_data.THETA = theta(tmp_data.P,tmp_data.TC+273.15);
        for te_i = 1:numel(tmp_data.P)
            tmp_data.THETAE(te_i,1) = theta_e_Bolton(tmp_data.P(te_i),tmp_data.TC(te_i)+273.15,tmp_data.RH(te_i));
            tmp_data.THETAES(te_i,1) = theta_es_Bolton(tmp_data.P(te_i),tmp_data.TC(te_i)+273.15);
        end
        
        % Energy:
        tmp_data.DSE = dse(tmp_data.TC+273.15,tmp_data.Z);
        tmp_data.MSE = mse(tmp_data.TC+273.15,tmp_data.Z,tmp_data.MR);
        
        %% Freezing level:
        if ( min(tmp_data.TC) <= 0 )
            tmp_Tdif = tmp_data.TC-0.0;
            zid = find(abs(tmp_Tdif) == min(abs(tmp_Tdif)));
            if ( abs(tmp_Tdif(zid)) <= 0.3 )
                tmp_data.P_0C = tmp_data.P(zid);
                tmp_data.Z_0C = tmp_data.Z(zid);
                %                     elseif ( tmp_Tdif(zid) > 0 & tmp_data.TC(zid) ~= tmp_data.TC(zid+1) )
                %                         tmp_data.P_0C = interp1(tmp_data.TC(zid:zid+1),tmp_data.P(zid:zid+1),0.0);
                %                         tmp_data.Z_0C = interp1(tmp_data.TC(zid:zid+1),tmp_data.Z(zid:zid+1),0.0);
                %                     elseif ( tmp_Tdif(zid) < 0 & tmp_data.TC(zid-1) ~= tmp_data.TC(zid) )
                %                         tmp_data.P_0C = interp1(tmp_data.TC(zid-1:zid),tmp_data.P(zid-1:zid),0.0);
                %                         tmp_data.Z_0C = interp1(tmp_data.TC(zid-1:zid),tmp_data.Z(zid-1:zid),0.0);
                %                     else
                %                         tmp_data.P_0C = tmp_data.P(zid);
                %                         tmp_data.Z_0C = tmp_data.Z(zid);
            end
            clear tmp_Tdif zid
        else
            tmp_data.P_0C = NaN;
            tmp_data.Z_0C = NaN;
        end
        
        %% PBL:
        [PBL_id,tmp_data.Z_PBL,tmp_data.P_PBL] = PBL_Calculation_Liu_and_Liang(tmp_data.P.*100, ...
            tmp_data.Z, ...
            tmp_data.THETA, ...
            tmp_data.WS, ...
            1, ...
            0 ...
            );
        tmp_data.P_PBL = tmp_data.P_PBL./100;
        
        %% Stability:
        tmp_data.DTDZ = -(gradient(tmp_data.TC)./gradient(tmp_data.Z)).*1000; % [K/km]
        tmp_data.DQDP = -(gradient(tmp_data.MR)./gradient(tmp_data.P)).*1000; % [g/kg*hPa]
        
        %% Sounding parameters:
        tmp_data.KINDEX = (tmp_data.TC(tmp_data.P==850)-tmp_data.TC(tmp_data.P==500)) ...
            + (tmp_data.TD(tmp_data.P==850)) ...
            - (tmp_data.TC(tmp_data.P==700)-tmp_data.TD(tmp_data.P==700));
        [tmp_data.CAPE, tmp_data.CIN] = getcape( length(tmp_data.P), ...
            tmp_data.P, ...
            tmp_data.TC, ...
            tmp_data.TD ...
            );
        
        %% Set output files names:
        
        fprintf(fileID,'%s\n',[data_L2_list(di).name,' done.']);
        
        eval([ ['ST_L4u_',data_L2_list(di).name(10:19)],' = tmp_data;' ]);
        
        %% Output the data:
        
        L4_output_file_name = [L4_output_file_path,data_L2_list(di).name];
        
        save(L4_output_file_name,'ST_L4u*');
        
        fprintf(fileID,'%s\n',[L4_output_file_path,data_L2_list(di).name,' data saved.']);
        
        disp([data_L2_list(di).name,' data saved.'])
        
        clear tmp_data
        clear ST_*
        
    end
    
end

fclose(fileID);

% ==============================================================================

toc;


