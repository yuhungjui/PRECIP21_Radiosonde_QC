clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Load PRECIP-2021 upper-air radiosonde data.
% 
% Transfer each data from L2 (.mat-format, QCed) to L3
% (.mat-format, sfc. P GCed, T, RH corrected based on CDF hours/Nighttime).
% 
% GC Basis: 2018-2020 PTU mean biases (420/431 STs except outliers)
%           2018-2019 PTU mean biases (202/209 STs except outliers)
%           2020      PTU mean biases (218/222 STs except outliers)
% 
% CDF basis: 2018-2020 CDF Correction Tables at 00Z, 03Z, 06Z, 09Z, and Nighttime.
% 
% ==============================================================================

%% Set file parameters:

% Station number:
project_no = 'precip21'

% Year:
year_no = {'2021'};

% Month:
month_no = {'01','02','03','04','05','06','07','08','09','10','11','12'};

% I/O:
L2_input_type = 'L2'
L3_output_type = 'L3_TASSE'

% ==============================================================================

%% Load GC Correction Table:

correction_table_path = '../../../../PRECIP21_Radiosonde_QC/ST_Correction/Correction_Table_TASSE';

load([correction_table_path,'/GC/GC_PTU_18_20_D10.mat']);

% ==============================================================================

%% Load CDF-Matching Correction Table:

% CDF_TC_00Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(00Z_164).mat']);
% CDF_TC_03Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(03Z_60).mat']);
% CDF_TC_06Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(06Z_55).mat']);
% CDF_TC_09Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(09Z_29).mat']);
load([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(Day_308).mat']);
% CDF_TC_Night = importdata('../../../../Research/NTU_DMLab/research/TAWSE2020_StormTracker_CORR/Correction_Table/CDF_MATCHING/2018_2020/CDF_P_100hPa_L3_GC_P_T_2018_2020_(Night_123).mat');

% CDF_RH_00Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(00Z_164).mat']);
% CDF_RH_03Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(03Z_60).mat']);
% CDF_RH_06Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(06Z_55).mat']);
% CDF_RH_09Z = importdata([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(09Z_29).mat']);
load([correction_table_path,'/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(Day_308).mat']);
% CDF_RH_Night = importdata('../../../../Research/NTU_DMLab/research/TAWSE2020_StormTracker_CORR/Correction_Table/CDF_MATCHING/2018_2020/CDF_T_10C_L2_RH_2018_2020_(Night_123).mat');
a
% ==============================================================================

%% Load P1LDC Correction Table:

P1LDC_RH_00Z = importdata([correction_table_path,'/P1LDC/P1LDC_RH_L3_GC_P_CDFhr_T_RH_2018_2020_(00Z_164).mat']);
P1LDC_RH_03Z = importdata([correction_table_path,'/P1LDC/P1LDC_RH_L3_GC_P_CDFhr_T_RH_2018_2020_(03Z_60).mat']);
P1LDC_RH_06Z = importdata([correction_table_path,'/P1LDC/P1LDC_RH_L3_GC_P_CDFhr_T_RH_2018_2020_(06Z_55).mat']);
P1LDC_RH_09Z = importdata([correction_table_path,'/P1LDC/P1LDC_RH_L3_GC_P_CDFhr_T_RH_2018_2020_(09Z_29).mat']);
P1LDC_RH_Night = importdata([correction_table_path,'/P1LDC/P1LDC_RH_L3_GC_P_CDFhr_T_RH_2018_2020_(Night_123).mat']);

% ==============================================================================

%% Load files and output:

fileID = fopen('./log.txt','w');

%% File path:
L2_input_file_path  = ['../',L2_input_type,'_mat/',year_no{1},'/'];
L3_output_file_path = ['./',year_no{1},'/'];

data_L2_list = dir([L2_input_file_path,'*.mat']);

%% Import data

for fi = 1:length(data_L2_list)
    
    data_L2 = importdata([L2_input_file_path,data_L2_list(fi).name],'');
    
    tmp_data.NominalTime    = data_L2.NominalTime;
    tmp_data.ST_No          = data_L2.ST_No;
    tmp_data.LaunchLocation = data_L2.LaunchLocation;
    tmp_data.LaunchTime     = data_L2.LaunchTime;
    % tmp_data.Station        = data_L2.Station;
    tmp_data.TIME_SEC       = data_L2.TIME_SEC;
    tmp_data.TIME           = data_L2.TIME;
    
    tmp_data.Z_GPS          = data_L2.Z_GPS;
    tmp_data.U              = data_L2.U;
    tmp_data.V              = data_L2.V;
    tmp_data.WD             = data_L2.WD;
    tmp_data.WS             = data_L2.WS;
    tmp_data.LON            = data_L2.LON;
    tmp_data.LAT            = data_L2.LAT;
    % tmp_data.Sat_No_L0      = data_L2.Sat_No_L0;
    % tmp_data.Volt_L0        = data_L2.Volt_L0;
    
    %% Apply GC to P:
    
    tmp_data.P              = data_L2.P - ( GC_PTU.P_bias.mean ); % hPa
    
    tmp_data.TC             = data_L2.TC; % deg-C
    tmp_data.RH             = data_L2.RH; % %
    
    %% !!! Apply CDF 00, 03, 06, 09Z to T !!!
    
%     switch tmp_data.NominalTime.Hour
%         case 0
%             CDF_TC = CDF_TC_00Z;
%         case 3
%             CDF_TC = CDF_TC_03Z;
%         case 6
%             CDF_TC = CDF_TC_06Z;
%         case 9
%             CDF_TC = CDF_TC_09Z;
%         otherwise
%             CDF_TC = CDF_TC_Night;
%     end
    
    [tmp_CDF_TC_P,tmp_CDF_TC_TC] = meshgrid(CDF_TC.P,CDF_TC.TC);
    
    for pi = 1:length(tmp_data.TC)
        
        tmp_CDF_Tdiff = interp2(tmp_CDF_TC_P,tmp_CDF_TC_TC,CDF_TC.BIAS',tmp_data.P(pi),tmp_data.TC(pi),'linear');
        
        tmp_data.TC(pi) = tmp_data.TC(pi) + (tmp_CDF_Tdiff); % w/ P_GCed + CDFhr_T
        
        clear tmp_CDF_Tdiff
        
    end
    
    clear tmp_CDF_*
    
    %% !!! Apply CDF 00, 03, 06, 09Z to RH (AFTER T CORRECTED) !!!
    
%     switch tmp_data.NominalTime.Hour
%         case 0
%             CDF_RH = CDF_RH_00Z;
%         case 3
%             CDF_RH = CDF_RH_03Z;
%         case 6
%             CDF_RH = CDF_RH_06Z;
%         case 9
%             CDF_RH = CDF_RH_09Z;
%         otherwise
%             CDF_RH = CDF_RH_Night;
%     end
    
    [tmp_CDF_RH_TC,tmp_CDF_RH_RH] = meshgrid(CDF_RH.TC,CDF_RH.RH);
    
    for tci = 1:length(tmp_data.RH)
        
        tmp_CDF_RHdiff = interp2(tmp_CDF_RH_TC,tmp_CDF_RH_RH,CDF_RH.BIAS',tmp_data.TC(tci),tmp_data.RH(tci),'linear');
        
        tmp_data.RH(tci) = tmp_data.RH(tci) + (tmp_CDF_RHdiff); % w/ P_GCed + CDFhr_T_RH
        
        clear tmp_CDF_RHdiff
        
    end
    
    clear tmp_CDF_*
    
    %% !!! Apply P1LDC 00, 03, 06, 09Z to RH (AFTER RH CDF-matching CORRECTED) !!!
    
%     switch tmp_data.NominalTime.Hour
%         case 0
%             P1LDC_RH = P1LDC_RH_00Z;
%         case 3
%             P1LDC_RH = P1LDC_RH_03Z;
%         case 6
%             P1LDC_RH = P1LDC_RH_06Z;
%         case 9
%             P1LDC_RH = P1LDC_RH_09Z;
%         otherwise
%             P1LDC_RH = P1LDC_RH_Night;
%     end
%     
%     tmp_P1LDC_RHdiff = interp1(P1LDC_RH.P,P1LDC_RH.DIFF_MEAN,tmp_data.P);
%     
%     tmp_data.RH = tmp_data.RH + (-tmp_P1LDC_RHdiff); % w/ P_GCed + CDFhr_T_RH + P1LDC_RH
%     
%     clear tmp_P1LDC_*
    
    %% Corrected Fields Derivation:
    
    for pi = 1:numel(data_L2.TIME_SEC)
        
        % For Geopotential Height:
%         if ( pi == 1 )
%             tmp_data.Z(pi,1) = tmp_data.LaunchLocation(3);
%         else
%             tmp_data.Z(pi,1) = tmp_data.LaunchLocation(3) + hydro_height(tmp_data.P(pi),tmp_data.TC(pi),tmp_data.P(1));
%         end
        
        % For Dew-point Temperature:
        tmp_data.TD(pi,1) = convert_humidity_RH_Td_yhj(tmp_data.TC(pi),tmp_data.RH(pi));
        
        % For RH w.r.t. Ice:
        tmp_data.RHI(pi,1) = convert_humidity_TTd_RHI_yhj(tmp_data.TC(pi,1)+273.15,tmp_data.TD(pi,1)+273.15);
        
    end
    
    %% Set output files names:
    
    fprintf(fileID,'%s\n',[data_L2_list(fi).name,' done.']);
    
    % disp([year_no{year_id},month_no{month_id},tmp_data.Time(7:8),tmp_data.Time(9:10),' done.']);
    
    eval([ 'ST_L3_',data_L2_list(fi).name(10:end-4),' = tmp_data;' ]);
    
    %% Output the data:
    
    L3_output_file_name = [L3_output_file_path,project_no,'_',data_L2_list(fi).name(10:end-4),'.mat'];
    
    save(L3_output_file_name,'ST_L3_*');
    
    fprintf(fileID,'%s\n',[L3_output_file_path,project_no,'_',data_L2_list(fi).name(10:end-4),' data saved.']);
    
    % disp([L2_output_file_path,station_no,'_',year_no{year_id},month_no{month_id},' data saved.'])
    
    clear tmp_data
    clear ST_L3_*
    
end

fclose(fileID);

% ==============================================================================

toc;


