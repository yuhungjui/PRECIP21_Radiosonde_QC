clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Scatter plots for Intercomparison: Storm Tracker vs. Radiosonde 
% 
% Source Datasets: Vaisala RS41-SGP:   L2
%                  Storm Tracker:      L2, L3
% 
% Comparison is between Level 2 / Level 3 data for P, T, RH.
% 
% ==============================================================================

%% Load Data Info:

% Station number:
project_no = 'precip21'

% Year:
year_no = {'2021'};

% Data info:

ST_Level = 'L2';
% ST_Level = 'L3_GC_P';
% ST_Level = 'L3_GC_P_CDFhr_T';
% ST_Level = 'L3_GC_P_CDFhr_T_RH';
% ST_Level = 'L3_GC_P_CDFhr_T_RH_P1LDC_RH';

% Data info:
ST_data_info_2021 = readtable('../../../Data/StormTracker/Log/log_online.xlsx');

% Data path (Storm Tracker):
data_path_ST_2021 = ['../../../Data/StormTracker/Data/',ST_Level,'_mat/2021/'];

% Data path (Vaisala Radiosonde):
data_path_RS_2021 = ['../../../Data/VaisalaRS41/Data/L2_mat/2021/'];

% ==============================================================================

%% Set parameters:

process_vars = {'P';'gz';'T';'RH';'U';'V';'WS'};

process_vars_name = {'P';'Z';'TC';'RH';'U';'V';'WS'};

process_vars_unit = {'hPa';'km';'^\circC';'%';'m/s';'m/s';'m/s'};

process_vars_range   = {[0,900]; ...
                        [-0.1,15]; ...
                        [-85,45]; ...
                        [-0.2,100.2]; ...
                        [-22,22]; ...
                        [-22,22]; ...
                        [-0.1,26] ...
                        };
process_vars_tick    = {[0:150:900]; ...
                        [0:2:14]; ...
                        [-80:20:40]; ...
                        [0:20:100]; ...
                        [-20:5:20]; ...
                        [-20:5:20]; ...
                        [0:5:25] ...
                        };

process_vars_color   = {[0.6,0.6,0.6]; ...
                        [0.6,0.6,0.6]; ...
                        [1,0.2,0.2]; ...
                        [0,0.4,0.2]; ...
                        [0,0.2,0.8]; ...
                        [0,0.2,0.8]; ...
                        [0,0.2,0.8] ...
                        };

% ==============================================================================

%% Read data:

plot_var_RS = {[],[],[],[],[],[],[]};
plot_var_ST = {[],[],[],[],[],[],[]};

test_var_st = [];
test_var_per = [];

varid = 4;

ssi = 1;

for vari = varid % one variable.
    
    yeari = 1;
    
    eval([ 'ST_data_info = ST_data_info_',year_no{yeari},';' ]);
    eval([ 'data_path_ST = data_path_ST_',year_no{yeari},';' ]);
    eval([ 'data_path_RS = data_path_RS_',year_no{yeari},';' ]);
    
    pb1 = CmdLineProgressBar(['... Loading ',process_vars{vari},' ... ']);
    
    comp_sonde_no = 0;
    
    for di = 1:size(ST_data_info,1)
        
        if ( ST_data_info.Co_launch_flag(di) == 1 )
        % if ( ST_data_info.L1_flag(di) == 1 && ismember(ST_data_info.UTC(di),[22,23,0:9]) )
            
            comp_sonde_no = comp_sonde_no+1;
            
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
            
            %% FILTER DATA BY PRESSURE:
            tmp_data_ST_pid = find(tmp_data_ST.P>=10);
            tmp_data_ST.TIME_SEC = tmp_data_ST.TIME_SEC(tmp_data_ST_pid);
            eval([ 'tmp_data_ST.',process_vars_name{vari},' = tmp_data_ST.',process_vars_name{vari},'(tmp_data_ST_pid);' ]);
            
            %% Find the same date & time:
            
            tmp_ST_sec = floor(tmp_data_ST.TIME_SEC);
            tmp_RS_sec = floor(tmp_data_RS.TIME_SEC);
            
            % tmp_RS_sec = tmp_RS_sec( tmp_data_RS.P >= 900 ); % CRITERIA FOR LOW-LEVEL!
            
            [tmp_ST_RS_sec, tmp_ST_sec_id, tmp_RS_sec_id] = intersect(tmp_ST_sec, tmp_RS_sec);
            
            %% Get variables at the same date & time:
            
            eval([ 'tmp_ST_var = tmp_data_ST.',process_vars_name{vari},'(tmp_ST_sec_id);' ]);
            eval([ 'tmp_RS_var = tmp_data_RS.',process_vars_name{vari},'(tmp_RS_sec_id);' ]);
            
            plot_var_RS{vari} = [plot_var_RS{vari};tmp_RS_var];
            plot_var_ST{vari} = [plot_var_ST{vari};tmp_ST_var];
            
            if ( vari == 4 )
                test_var_st = [test_var_st;ST_no];
                test_var_per =[test_var_per;(numel(tmp_data_ST.RH(tmp_data_ST.RH>=100)))/(numel(tmp_data_ST.RH))];
            end
            
            clear tmp_*
            
        end
        
        pb1.print(di,size(ST_data_info,1));
        
    end
    
    % clear ST_* RS_*
    
    clear pb1
    
end

% plot_var_RS{2} = plot_var_RS{2}(:)./1e3;
% plot_var_ST{2} = plot_var_ST{2}(:)./1e3;

% ==============================================================================

%% OUTLIERS DELETION:

% for vari = varid
%     
%     tmp_bias = plot_var_ST{vari}-plot_var_RS{vari};
%     tmp_bias_outlier_id = ~isoutlier(tmp_bias,'quartiles');
%     
%     plot_var_ST{vari} = plot_var_ST{vari}(tmp_bias_outlier_id);
%     plot_var_RS{vari} = plot_var_RS{vari}(tmp_bias_outlier_id);
%     
%     clear tmp_*
%     
% end

% ==============================================================================

%% CONSISTENCY FACTOR CALCULATION:

% Combined Uncertainty:

con_vars = {'P';'gz';'T';'RH';'U';'V';'WS'};

combined_uncertainty = {[sqrt((1).^2+(1).^2)]; ...
                        [sqrt((0.01).^2+(0.01).^2)]; ...
                        [sqrt((0.3).^2+(0.3).^2)]; ...
                        [sqrt((4).^2+(2).^2)]; ...
                        [sqrt((0.15).^2+(0.1).^2)]; ...
                        [sqrt((0.15).^2+(0.1).^2)]; ...
                        [sqrt((0.15).^2+(0.1).^2)] ...
                        };

% K-factor:

K_factor = { [abs(nanmean(plot_var_ST{1})-nanmean(plot_var_RS{1}))./combined_uncertainty{1}]; ...
             [abs(nanmean(plot_var_ST{2})-nanmean(plot_var_RS{2}))./combined_uncertainty{2}]; ...
             [abs(nanmean(plot_var_ST{3})-nanmean(plot_var_RS{3}))./combined_uncertainty{3}]; ...
             [abs(nanmean(plot_var_ST{4})-nanmean(plot_var_RS{4}))./combined_uncertainty{4}]; ...
             [abs(nanmean(plot_var_ST{5})-nanmean(plot_var_RS{5}))./combined_uncertainty{5}]; ...
             [abs(nanmean(plot_var_ST{6})-nanmean(plot_var_RS{6}))./combined_uncertainty{6}]; ...
             [abs(nanmean(plot_var_ST{7})-nanmean(plot_var_RS{7}))./combined_uncertainty{7}] ...
            };

disp('K_factor');        
disp(K_factor);

% ==============================================================================

%% RMSE:

RMSE = { sqrt(nanmean((plot_var_ST{1} - plot_var_RS{1}).^2)); ...
         sqrt(nanmean((plot_var_ST{2} - plot_var_RS{2}).^2)); ...
         sqrt(nanmean((plot_var_ST{3} - plot_var_RS{3}).^2)); ...
         sqrt(nanmean((plot_var_ST{4} - plot_var_RS{4}).^2)); ...
         sqrt(nanmean((plot_var_ST{5} - plot_var_RS{5}).^2)); ...
         sqrt(nanmean((plot_var_ST{6} - plot_var_RS{6}).^2)); ...
         sqrt(nanmean((plot_var_ST{7} - plot_var_RS{7}).^2)); ...
        };

disp('RMSE');
disp(RMSE);

% ==============================================================================

%% Biases:

bias_mean = { nanmean(plot_var_ST{1} - plot_var_RS{1}), nanstd(plot_var_ST{1} - plot_var_RS{1}); ...
              nanmean(plot_var_ST{2} - plot_var_RS{2}), nanstd(plot_var_ST{2} - plot_var_RS{2}); ...
              nanmean(plot_var_ST{3} - plot_var_RS{3}), nanstd(plot_var_ST{3} - plot_var_RS{3}); ...
              nanmean(plot_var_ST{4} - plot_var_RS{4}), nanstd(plot_var_ST{4} - plot_var_RS{4}); ...
              nanmean(plot_var_ST{5} - plot_var_RS{5}), nanstd(plot_var_ST{5} - plot_var_RS{5}); ...
              nanmean(plot_var_ST{6} - plot_var_RS{6}), nanstd(plot_var_ST{6} - plot_var_RS{6}); ...
              nanmean(plot_var_ST{7} - plot_var_RS{7}), nanstd(plot_var_ST{7} - plot_var_RS{7}); ...
             };

disp('bias_mean & bias_std.');
disp(bias_mean);
    
% ==============================================================================

%% Plotting figure.

close all;

gf1 = gcf;

% gf1.WindowState = 'maximized';

ax_fontsize = 18;
ax_linewidth = 2;

%% Scatter:

for vari = varid % one variable
    
    %% Set sub-pot locations:
    
%     switch vari
%         case 1
%             sub_id_v = 1; sub_id_h = 1;
%         case 3
%             sub_id_v = 1; sub_id_h = 2;
%         case 4
%             sub_id_v = 1; sub_id_h = 3;
%     end
    
    %% Sub-Plot:
    
%     subaxis(1,3,sub_id_h,sub_id_v,'Spacing',0.05);
    
    f11 = scatter(plot_var_RS{vari},plot_var_ST{vari});
    
    f11.Marker = '.';
    f11.MarkerEdgeColor = process_vars_color{vari};
    f11.MarkerEdgeAlpha = 0.5;
    % f11.LineWidth = 2;
    % f11.MarkerFaceColor = process_vars_color{vari};
    % f11.MarkerFaceAlpha = 0.5;
    
    hold on;
    
    %% 1-1 line:
    
    f10 = line([-1e6,1e6],[-1e6,1e6]);
    
    f10.LineWidth = 2;
    f10.LineStyle = '--';
    f10.Color = [0.2,0.2,0.2];
    
    
    %% Set axes: Axis 1:
    
    ax11 = gca;
    
    set(ax11,'Box','off','Color','none');
    set(ax11,'PlotBoxAspectRatio',[1,1,1])
    % set(ax11,'Position',[0.125,0.125,0.75,0.75])
    set(ax11,'TickDir','out')
    set(ax11,'FontName','Helvetica','FontSize',ax_fontsize,'FontWeight','bold')
    set(ax11,'LineWidth',ax_linewidth)
    set(ax11,'Xlim',process_vars_range{vari})
    set(ax11,'XTick',process_vars_tick{vari})
    if ( strcmp(process_vars_name{vari},'P') == 1 )
        set(ax11,'XDir','reverse')
    end
    % set(ax11,'XTickLabel',[])
    set(ax11,'XMinorTick','off','XMinorGrid','off')
    set(ax11,'Ylim',process_vars_range{vari})
    set(ax11,'YTick',process_vars_tick{vari})
    if ( strcmp(process_vars_name{vari},'P') == 1 )
        set(ax11,'YDir','reverse')
    end
    set(ax11,'YMinorTick','off','YMinorGrid','off')
    % set(ax1,'YGrid','off');
    
    %% Labels:
    
    % xlabel(['\bf{RS-41 ',process_vars{vari},'}'])
    % ylabel(['\bf{Storm Tracker ',process_vars{vari},'}'])
    
    %% Set axes: Axis 2:
    ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);
    
    set(ax12,'PlotBoxAspectRatio',[1,1,1])
    set(ax12,'TickLength',[0.0050,0.0250])
    set(ax12,'TickDir','out')
    set(ax12,'LineWidth',ax_linewidth)
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
    
    leg_label_1 = [process_vars{vari},' (',process_vars_unit{vari},')'];
    
    leg1 = text(0.05,0.95,leg_label_1,'Units','normalized');
    
    set(leg1,'VerticalAlignment','top')
    set(leg1,'FontName','Helvetica')
    set(leg1,'FontSize',ax_fontsize)
    set(leg1,'FontWeight','bold')
    set(leg1,'BackgroundColor',[1,1,1,0.5])
    set(leg1,'EdgeColor','k')
    set(leg1,'LineWidth',ax_linewidth)
    
end

% ==============================================================================
    
%% Save Figure:
 
set(gf1,'Color',[1,1,1]);

figname = ['./Scatter_RS_ST_',ST_Level,'_',process_vars{varid}];
 
% print(gf1,'-dpng','-r300',figname);
 
export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

% ==============================================================================

toc;
