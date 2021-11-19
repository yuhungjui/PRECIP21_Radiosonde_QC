clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Load PRECIP-2021 upper-air radiosonde data.
% Transfer each data from L4 (mat format) to L4 (csv format).
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

%% Load files and output:

log_fileID = fopen('./log.txt','w');

%% File path:
L4_mat_input_file_path     = ['../L4u_1hPa_mat/',year_no{1},'/'];
L4_csv_output_file_path    = ['./',year_no{1},'/'];

data_L4_list = dir([L4_mat_input_file_path,'*.mat']);

for di = 1:length(data_L4_list)
    
    load_data = load([L4_mat_input_file_path,data_L4_list(di).name]);
    
    eval([' data_L4 = load_data.ST_L4u_',data_L4_list(di).name(10:end-9),'; ']);
    
    clear load_data
    
    %% Output data:
    
    output_fileID = fopen([L4_csv_output_file_path, data_L4_list(di).name(1:end-4), '.csv'],'w');
    
    % Write header:
    fprintf(output_fileID, 'FileFormat,CSV\n');
    fprintf(output_fileID, ['Year,',num2str(data_L4.LaunchTime.Year),'\n']);
    fprintf(output_fileID, ['Month,',num2str(data_L4.LaunchTime.Month),'\n']);
    fprintf(output_fileID, ['Day,',num2str(data_L4.LaunchTime.Day),'\n']);
    fprintf(output_fileID, ['Hour,',num2str(data_L4.LaunchTime.Hour),'\n']);
    fprintf(output_fileID, ['Minute,',num2str(data_L4.LaunchTime.Minute),'\n']);
    fprintf(output_fileID, ['Second,',num2str(data_L4.LaunchTime.Second),'\n']);
    fprintf(output_fileID, 'Ascending,"true"\n');
    
    % Optional info:
    fprintf(output_fileID, ['latitude,',num2str(data_L4.LaunchLocation(1)),',"units=deg"\n']);
    fprintf(output_fileID, ['longitude,',num2str(data_L4.LaunchLocation(2)),',"units=deg"\n']);
    fprintf(output_fileID, ['altitude,',num2str(data_L4.LaunchLocation(3)),',"units=m"\n']);
    fprintf(output_fileID, 'project,"PRE-CIP-2021"\n');
    fprintf(output_fileID, 'agency,"CSU"\n');
    fprintf(output_fileID, ['sondeid,"',num2str(data_L4.ST_No),'"\n']);
    fprintf(output_fileID, 'sondetype,"Storm Tracker"\n');
    fprintf(output_fileID, 'launchsite,"Christman Field"\n\n');
    
    % Data header:
    fprintf(output_fileID, 'Fields,    Time,   Pressure,  Temperature,     RH,     Speed, Direction,     Latitude,     Longitude,   Altitude,     Gpsalt \n');
    fprintf(output_fileID, 'Units,      sec,         mb,     deg C,         %%,       m/s,       deg,          deg,           deg,          m,          m \n');
    
    % Write data:
    fprintf(output_fileID,'Data,    %6.1f,    %7.2f,    %6.2f,    %6.2f,    %6.2f,    %6.2f,    %9.5f,    %9.5f,    %7.1f,    %7.1f \n', ...
            [data_L4.TIME_s ...
            ,data_L4.P ...
            ,data_L4.TC ...
            ,data_L4.RH ...
            ,data_L4.WS ...
            ,data_L4.WD ...
            ,data_L4.LAT ...
            ,data_L4.LON ...
            ,data_L4.Z ...
            ,data_L4.Z_GPS ...
            ]');
    
    % Closing output:
    fclose(output_fileID);
    
    disp([data_L4_list(di).name(1:end-4),'.csv data saved.'])
    
    clear data_L4
    
end


fclose(log_fileID);

% ==============================================================================

toc;


