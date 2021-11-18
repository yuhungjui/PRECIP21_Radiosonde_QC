clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Load PRECIP-2021 upper-air radiosonde data.
% Transfer each data from L2 (Aspen-QCed, csv format) to L2 (matlab format).
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

%% Load L0 data info for Sat #:

% L0_data_info = readtable('../../Log/log_online.xlsx');
% 
% for di = 1:size(L0_data_info,1)
%     
%     tmp_date = num2str(L0_data_info.Date(di));
%     
%     ST_nominaltime(di) = datetime( str2double(tmp_date(1:4)), str2double(tmp_date(5:6)), str2double(tmp_date(7:8)), L0_data_info.Nominal_T(di), 0, 0, 'TimeZone', 'Asia/Taipei');
%     ST_no(di) = L0_data_info.ST_No(di);
%     
%     clear tmp_date
%     
% end

% ==============================================================================

%% Load files and output:

fileID = fopen('./log.txt','w');

% for year_id = 1:numel(year_no)
%     
%     switch year_no{year_id}
%         case '2021'
%             month_no = {'05','06','07','08'};
%     end
     
%% File path:
L2_input_file_path     = ['../L2/',year_no{1},'/'];
L2_output_file_path    = ['./',year_no{1},'/'];

% file_name_list_eol = dir([L2_input_file_path,'*.eol']);
file_name_list_csv = dir([L2_input_file_path,'*.csv']);

%% Import data

for fi = 1:size(file_name_list_csv,1)
    
    disp(file_name_list_csv(fi).name);
    
    data_L2 = importdata([L2_input_file_path,file_name_list_csv(fi).name], '');
    % data_L2 = readtable([L2_input_file_path,file_name_list_csv(fi).name], 'ReadVariableNames', true, 'HeaderLines', 44);
    
    data_L1 = importdata(['../L1_csv/',year_no{1},'/',file_name_list_csv(fi).name(1:end-6),'.csv'], ' ');
    data_L1 = data_L1.textdata(20:end,2:end);
    % data_L1 = strrep(data_L1(20:end,:),'Data,','');
    data_L1 = str2double(data_L1);
    data_L1_SEC_SAT = data_L1(:,[1,10]);
    clear data_L1
    
    tmp_data.NominalTime = datetime(file_name_list_csv(fi).name(10:19),'InputFormat','yyyyMMddHH','TimeZone','UTC');
    tmp_data.ST_No = str2double(extractBetween(file_name_list_csv(fi).name,'ST_','QC'));
    
    %% For launch location & time:
    
    tmp_data.LaunchLocation = [ str2double(extractBetween(data_L2{13},'Latitude,',',"units=deg"')) ...
                              , str2double(extractBetween(data_L2{14},'Longitude,',',"units=deg"')) ...
                              , str2double(extractBetween(data_L2{15},'Altitude,',',"units=m"')) ...
                              ]; % Christman Field.
    
    tmp_data.LaunchTime = datetime([ data_L2{2}(end-3:end) ...
                                   , data_L2{3}(end-1:end) ...
                                   , data_L2{4}(end-1:end) ...
                                   , data_L2{5}(end-1:end) ...
                                   , data_L2{6}(end-1:end) ...
                                   , data_L2{7}(end-1:end) ...
                                   ] ...
                                   , 'InputFormat', 'yyyyMMddHHmmss', 'TimeZone', 'UTC' ...
                                   );
    
    % tmp_data.Station = station_no;
    
    ii = 1;
    
    for data_i = 47:size(data_L2,1)
        
        %% Put data in the output format:
        
        tmp_data_row = str2double(strsplit(data_L2{data_i},','));
        
        tmp_data_row(tmp_data_row == -999.00) = NaN;
        
        tmp_data.TIME_SEC(ii,1) = tmp_data_row(2);
        tmp_data.TIME(ii,1) = tmp_data.LaunchTime+seconds(tmp_data_row(2));
        
        tmp_data.P(ii,1)      = tmp_data_row(3); % hPa
        % tmp_data.Z(ii,1)      = tmp_data_row(15); % [m]
        tmp_data.Z_GPS(ii,1)  = tmp_data_row(11); % [m]
        tmp_data.TC(ii,1)     = tmp_data_row(4);
        tmp_data.TD(ii,1)     = tmp_data_row(12);
        tmp_data.RH(ii,1)     = tmp_data_row(5);
        
        % For RH w.r.t. Ice:
        tmp_data.RHI(ii,1)    = convert_humidity_TTd_RHI_yhj(tmp_data_row(4)+273.15,tmp_data_row(12)+273.15);
        
        tmp_data.U(ii,1)      = tmp_data_row(13);
        tmp_data.V(ii,1)      = tmp_data_row(14);
        tmp_data.WD(ii,1)     = tmp_data_row(7);
        tmp_data.WS(ii,1)     = tmp_data_row(6);
        tmp_data.LON(ii,1)    = tmp_data_row(9);
        tmp_data.LAT(ii,1)    = tmp_data_row(8);
        
        %% Check satellite number from L1 data:
        if ( data_L1_SEC_SAT( data_L1_SEC_SAT(:,1)==tmp_data.TIME_SEC(ii,1), 2 ) < 4 )
            tmp_data.U(ii,1) = NaN;
            tmp_data.V(ii,1) = NaN;
            tmp_data.WD(ii,1) = NaN;
            tmp_data.WS(ii,1) = NaN;
            tmp_data.LON(ii,1) = NaN;
            tmp_data.LAT(ii,1) = NaN;
        end
        
        ii = ii + 1;
        
    end
    
    clear data_L1_SEC_SAT
    
    %% For L0 information (Sat #, Voltage, ST #):
    
    %         L0_fid = find( RS_datetime == tmp_data.NominalTime & ST_no == tmp_data.ST_No);
    %
    %         data_L0_ST = readtable(['../L0_wVaisala/Banqiao_ST_',datestr(ST_nominaltime(L0_fid),'yyyymmddHH'),'_no_',num2str(tmp_data.ST_No),'.csv']);
    %
    %         L0_tmp_time = datetime(datestr(data_L0_ST.Time),'InputFormat','dd-MMM-yyyy HH:mm:sss','TimeZone','Asia/Taipei');
    %
    %         L2_tmp_time = tmp_data.TIME;
    %
    %         for st_di = 1:size(L2_tmp_time,1)
    %
    %             L0_tid = find( L0_tmp_time == L2_tmp_time(st_di) );
    %
    %             if ( isempty(L0_tid) == 1 )
    %
    %                 tmp_data.Sat_No_L0(st_di,1) = NaN;
    %                 tmp_data.Volt_L0(st_di,1) = NaN;
    %
    %             else
    %
    %                 if ( data_L0_ST.Sat(L0_tid(1)) ~= 99 )
    %                     tmp_data.Sat_No_L0(st_di,1) = data_L0_ST.Sat(L0_tid(1));
    %                 else
    %                     tmp_data.Sat_No_L0(st_di,1) = NaN;
    %                 end
    %
    %                 tmp_data.Volt_L0(st_di,1) = data_L0_ST.Voltage_V_(L0_tid(1));
    %
    %             end
    %
    %         end
    %
    %         clear data_L0_ST
    %         clear L0_tmp_time L2_tmp_time
    
    
    %% Set output files names:
    
    fprintf(fileID,'%s\n',[file_name_list_csv(fi).name(10:19),'_',num2str(tmp_data.ST_No),' done.']);
    
    % disp([year_no{year_id},month_no{month_id},tmp_data.Time(7:8),tmp_data.Time(9:10),' done.']);
    
    eval([ ['ST_L2_',file_name_list_csv(fi).name(10:19)],'_',num2str(tmp_data.ST_No),' = tmp_data;' ]);
    
    %% Output the data:
    
    L2_output_file_name = [L2_output_file_path,project_no,'_',file_name_list_csv(fi).name(10:19),'_',num2str(tmp_data.ST_No),'.mat'];
    
    save(L2_output_file_name,'ST_L2_*');
    
    fprintf(fileID,'%s\n',[L2_output_file_path,project_no,'_',file_name_list_csv(fi).name(10:19),'_',num2str(tmp_data.ST_No),' data saved.']);
    
    % disp([L2_output_file_path,station_no,'_',year_no{year_id},month_no{month_id},' data saved.'])
    
    clear tmp_data
    clear ST_L2_*
    
end
    
%     clear file_name_list_eol
    
% end

fclose(fileID);

% ==============================================================================

toc;


