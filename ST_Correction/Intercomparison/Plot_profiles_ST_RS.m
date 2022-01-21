clear;close all;clc;

addpath(genpath('/Users/yuhungjui/Dropbox/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot the differences in T & RH profiles between Vaisala RS41-SGP radiosonde 
% and the co-launched Storm Tracker.
% 
% ==============================================================================

%% Load Data Info:

% Station number:
% station_no = '46692';
project_no = 'precip21'

% Year:
year_no = {'2021'};

% Data info:

% ST_Level = 'L2';
ST_Level = 'L3_TASSE';

% Data info:
ST_data_info_2021 = readtable('../../../Data/StormTracker/Log/log_online.xlsx');

% Data path (Storm Tracker):
data_path_ST_2021 = ['../../../Data/StormTracker/Data/',ST_Level,'_mat/2021/'];

% Data path (Vaisala Radiosonde):
data_path_RS_2021 = ['../../../Data/VaisalaRS41/Data/L2_mat/2021/'];

% ==============================================================================

%% Set parameters:

process_var = {'TC','RH'};
process_var_unit = {'K','%'};

P1L = [900:-1:80];

time_of_day_id = 0;

% time_of_day = {'06'};
% time_of_day = [0,3,6,9];
% time_of_day = [12,15,18,21];

% ==============================================================================

%% Read data & Difference Calculation at 1-hPa Pressure Level:

ssi = 1;

for vari = 1:2 % T & RH
    
    dii = 1;

    for yeari = 1 % 2021
        
        eval([ 'ST_data_info = ST_data_info_',year_no{yeari},';' ]);
        eval([ 'data_path_ST = data_path_ST_',year_no{yeari},';' ]);
        eval([ 'data_path_RS = data_path_RS_',year_no{yeari},';' ]);
        
        pb1 = CmdLineProgressBar(['... Loading  ... ']);
        
        for di = 1:size(ST_data_info,1)
            
            if ( ST_data_info.Co_launch_flag(di) == 1 )
                % if ( data_info.info_flag(di) == 1 && strcmp(data_info.ps(di),'check') == 1 && data_info.intercomp_flag(di) == 0 ) % SUSPICIOUS STORM TRACKER P REMOVED.
                
                %% Get datetime:
            
                tmp_date = num2str(ST_data_info.Date(di));
                ST_nominalT = datetime( str2double(tmp_date(1:4)), str2double(tmp_date(5:6)), str2double(tmp_date(7:8)), ST_data_info.Nominal_T(di), 0, 0, 'TimeZone', 'UTC' );

                %% Get Storm Tracker #:

                ST_no = ST_data_info.ST_No(di);
                
                %% Load Storm Tracker data & corresponding L2 Radiosonde data:
            
                tmp_data_ST = importdata([data_path_ST,project_no,'_',datestr(ST_nominalT,'yyyymmddHH'),'_',num2str(ST_no),'.mat']);
                tmp_data_RS = importdata([data_path_RS,project_no,'_',datestr(ST_nominalT,'yyyymmddHH'),'.mat']);

                test_size_ST(ssi) = length(tmp_data_ST.P);
                test_size_RS(ssi) = length(tmp_data_RS.P);
                ssi = ssi+1;
                
                %% Calculate the difference at each p-level from 1020-80 hPa:
                
                tmp_nan_p = isnan(tmp_data_ST.P);
                eval([ 'tmp_process_var_ST = tmp_data_ST.',process_var{vari},';' ]);
                tmp_var_ST_i = interp1(tmp_data_ST.P(~tmp_nan_p) - [1:numel(tmp_data_ST.P(~tmp_nan_p))]'.*1e-7,tmp_process_var_ST(~tmp_nan_p),P1L);
                
                tmp_nan_p = isnan(tmp_data_RS.P);
                eval([ 'tmp_process_var_RS = tmp_data_RS.',process_var{vari},';' ]);
                tmp_var_RS_i = interp1(tmp_data_RS.P(~tmp_nan_p) - [1:numel(tmp_data_RS.P(~tmp_nan_p))]'.*1e-7,tmp_process_var_RS(~tmp_nan_p),P1L);
                
                switch time_of_day_id
                    case 0
                        P1LDiff(dii,:,vari) = tmp_var_ST_i - tmp_var_RS_i;
                        dii = dii + 1;
                    case 1
                        if ( ST_data_info.UTC(di) == str2double(time_of_day{:}) )
                            P1LDiff(dii,:,vari) = tmp_var_ST_i - tmp_var_RS_i;
                            dii = dii + 1;
                        end
                    case 2
                        if ( ismember(ST_data_info.UTC(di),time_of_day) == 1 )
                            P1LDiff(dii,:,vari) = tmp_var_ST_i - tmp_var_RS_i;
                            dii = dii + 1;
                        end
                    case 3
                        if ( ismember(ST_data_info.UTC(di),time_of_day) == 1 )
                            P1LDiff(dii,:,vari) = tmp_var_ST_i - tmp_var_RS_i;
                            dii = dii + 1;
                        end
                end
                
                clear tmp_*
                
            end
            
            pb1.print(di,size(ST_data_info,1));
            
        end
        
        clear pb1
        
    end

end

% ==============================================================================

%% CONSISTENCY FACTOR CALCULATION:

% % Combined Uncertainty:
% 
% con_vars = {'P';'Z';'T';'RH';'WSPD'};
% 
% combined_uncertainty = {[sqrt((1).^2+(1).^2)]; ...
%                         [sqrt((0.01).^2+(0.01).^2)]; ...
%                         [sqrt((0.3).^2+(0.3).^2)]; ...
%                         [sqrt((4).^2+(2).^2)]; ...
%                         [sqrt((0.15).^2+(0.1).^2)] ...
%                         };
% 
% % K-factor:
% 
% K_factor = {[abs(nanmean(plot_var_ST{1})-nanmean(plot_var_RS{1}))./combined_uncertainty{1}]; ...
%             [abs(nanmean(plot_var_ST{2})-nanmean(plot_var_RS{2}))./combined_uncertainty{2}]; ...
%             [abs(nanmean(plot_var_ST{3})-nanmean(plot_var_RS{3}))./combined_uncertainty{3}]; ...
%             [abs(nanmean(plot_var_ST{4})-nanmean(plot_var_RS{4}))./combined_uncertainty{4}]; ...
%             [abs(nanmean(plot_var_ST{7})-nanmean(plot_var_RS{7}))./combined_uncertainty{5}] ...
%             };
%                 
% disp(K_factor);

% ==============================================================================

%% Set plotting variables:

P1LDiff_no = dii-1;

P1LDiff_m = nanmean(P1LDiff);
P1LDiff_s = nanstd(P1LDiff);

plot_var_11 = P1LDiff_m(:,:,1);
plot_var_12 = P1LDiff_s(:,:,1);

plot_var_21 = P1LDiff_m(:,:,2);
plot_var_22 = P1LDiff_s(:,:,2);

for vi = 1:2
    for pi = 1:size(P1LDiff,2)
        P1LDiff_nan(pi,vi) = sum(~isnan(P1LDiff(:,pi,vi)));
    end
end

% ==============================================================================

%% Plotting figure.

close all;

% gf1 = gcf;
% gf1.WindowState = 'maximized';

%% Vertical Profiles:

for vari = 1:2 % T, RH

    close all;

    gf1 = gcf;
    gf1.WindowState = 'maximized';
    
%     %% Set sub-pot locations:
%     
%     switch vari
%         case 1
%             sub_id_v = 1; sub_id_h = 1;
%         case 2
%             sub_id_v = 1; sub_id_h = 2;
%     end
%     
%     %% Subplot:
%     
%     subaxis(1,2,sub_id_h,sub_id_v,'Spacing',0.0);
%     % subplot(1,2,vari)
    
    switch vari
        case 1
            f11 = line(plot_var_11,P1L);
            f11.Color = [0.83,0,0];
        case 2
            f11 = line(plot_var_21,P1L);
            f11.Color = [0,0.67,0];
    end
    f11.LineWidth = 3;
    
    hold on;
    
    %% Std. Range:
    
    switch vari
        case 1
            nanid = ~isnan(plot_var_12);
            lo = plot_var_11(nanid) - plot_var_12(nanid);
            hi = plot_var_11(nanid) + plot_var_12(nanid);
        case 2
            nanid = ~isnan(plot_var_22);
            lo = plot_var_21(nanid) - plot_var_22(nanid);
            hi = plot_var_21(nanid) + plot_var_22(nanid);
    end
    
    yy = P1L(nanid);
    
    f12 = patch([lo, hi(end:-1:1), lo(1)], [yy, yy(end:-1:1), yy(1)], [0.8,0.8,0.8]);
    
    f12.FaceColor = [0.6,0.6,0.6];
    f12.FaceAlpha = 0.5;
    f12.EdgeColor = 'none';
    
    hold on;
    
    % f11 = line(plot_var_11,P1L);
    %
    % set(f11, 'color', [0.5,0.5,0.5], 'marker', '.');
    
    %% 0-line:
    
    f10 = line([0,0],[1020,50]);
    
    f10.LineWidth = 2.0;
    f10.Color = [0.3,0.3,0.3];
    
    
    %% Set axes: Axis 1:
    
    ax11 = gca;
    
    set(ax11,'Box','off','Color','none');
    set(ax11,'PlotBoxAspectRatio',[1,2,1])
    set(ax11,'Position',[0.3,0.125,0.4,0.75])
    set(ax11,'TickDir','out')
    set(ax11,'FontName','Helvetica','FontSize',18,'FontWeight','bold')
    set(ax11,'LineWidth',2.0)
    switch vari
        case 1
            set(ax11,'Xlim',[-6,26])
            set(ax11,'XTick',[-5:5:25])
        case 2
            set(ax11,'Xlim',[-41,11])
            set(ax11,'XTick',[-40:5:10])
    end
    set(ax11,'XGrid','on')
    set(ax11,'XMinorTick','on','XMinorGrid','off')
    set(ax11,'Ylim',[80,1020])
    set(ax11,'YTick',[100:100:1000])
    set(ax11,'YScale','log')
    set(ax11,'YDir','reverse')
    set(ax11,'YMinorTick','off','YMinorGrid','off')
    set(ax11,'YGrid','on');
    
    %% Labels:
    
    switch time_of_day_id
        case 0
            xlabel(['\bf{\Delta',process_var{vari},' (',process_var_unit{vari},')}'])
        case 1
            xlabel(['\bf{',time_of_day{:},'Z \Delta',process_var{vari},' (',process_var_unit{vari},')}'])
        case 2
            xlabel(['\bf{Daytime \Delta',process_var{vari},' (',process_var_unit{vari},')}'])
        case 3
            xlabel(['\bf{Nighttime \Delta',process_var{vari},' (',process_var_unit{vari},')}'])
    end
    ylabel(['\bf{P (hPa)}'])
    
    %% Set axes: Axis 2:
    ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);
    
    set(ax12,'PlotBoxAspectRatio',ax11.PlotBoxAspectRatio)
    
    set(ax12,'TickLength',[0.0050,0.0250])
    set(ax12,'TickDir','out')
    set(ax12,'LineWidth',2.0)
    set(ax12,'Xlim',ax11.XLim);
    set(ax12,'XDir',ax11.XDir)
    set(ax12,'Ylim',ax11.YLim);
    set(ax12,'YMinorTick','off')
    set(ax12,'YDir',ax11.YDir)
    
    % Link axes in case of zooming and set original axis as active:
    linkaxes([ax11,ax12])
    axes(ax11)
    
    % Get the actual axes position:
    % ax11_pos = plotboxpos(ax11);
    
    %% 1. Legends:
    
    leg_label_1 = ['\Delta',process_var{vari},' (#: ',num2str(P1LDiff_no),')'];
    
    % leg1 = text(0.05,0.98,leg_label_1,'Units','normalized');
    leg1 = text(-5,90,leg_label_1);
    
    set(leg1,'VerticalAlignment','top')
    set(leg1,'FontName','Helvetica')
    set(leg1,'FontSize',24)
    set(leg1,'FontWeight','bold')
    set(leg1,'BackgroundColor',[1,1,1])
    set(leg1,'EdgeColor','k')
    set(leg1,'LineWidth',1.5)

    % ==============================================================================
    
    %% Save Figure:
    
    set(gf1,'Color',[1,1,1]);
    
    switch time_of_day_id
        case 0
            figname = ['./LevDiff_ST-RS_',ST_Level,'_',process_var{vari}];
        case 1
            figname = ['./LevDiff_ST-RS_',ST_Level,'_',process_var{vari},'_',time_of_day{:}];
        case 2
            figname = ['./LevDiff_ST-RS_',ST_Level,'_',process_var{vari},'_Daytime'];
        case 3
            figname = ['./LevDiff_ST-RS_',ST_Level,'_',process_var{vari},'_Nighttime'];
    end
    
    % print(gf1,'-dpng','-r300',figname);
    
    export_fig([figname,'.png'],'-r300')
    % export_fig([figname,'.png'],'-r300','-transparent')
    
    
end

% ==============================================================================

toc;
