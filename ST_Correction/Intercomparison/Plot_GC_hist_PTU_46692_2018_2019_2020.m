clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Ground Check (GC) Scatter plots for 46692 Storm Tracker vs. Radiosonde.
% 
% Comparison is between Level 2 data.
% (synced by Vaisala launch time, sfc. obs., flagged 1, manually checked)
% 
% ==============================================================================

%% Load Data Info:

% Station number:
station_no = '46692';

% Year:
year_no = {'2018','2019','2020'};

% Data info:

ST_data_info_2018 = readtable('../../../../../Data/DATA_TASSE/TASSE2018_StormTracker_QC_AspenV344/46692_StormTracker_log_info.xlsx');
ST_data_info_2019 = readtable('../../../../../Data/DATA_TASSE/TASSE2019_StormTracker_QC_AspenV344/Banqiao_ST_log_info_wVaisala.xlsx');
ST_data_info_2020 = readtable('../../../../../Data/DATA_TASSE/TAWSE2020_StormTracker_QC_AspenV344/Banqiao_ST_log_info_wVaisala.xlsx');

% Data path (Storm Tracker):

data_path_ST_2018 = ['../../../../../Data/DATA_TASSE/TASSE2018_StormTracker_QC_AspenV342/L3_GC_mat/2018/'];
data_path_ST_2019 = ['../../../../../Data/DATA_TASSE/TASSE2019_StormTracker_QC/L3_GC_mat/2019/'];
data_path_ST_2020 =

% Data path (Vaisala Radiosonde):

data_path_RS_2018 = ['../../../../../Data/DATA_TASSE/Sounding_46692/L2_mat/2018/'];
data_path_RS_2019 = ['../../../../../Data/DATA_TASSE/Sounding_46692/L2_mat/2019/'];

% ==============================================================================

%% Set parameters:

process_vars = {'P';'gz';'T';'RH';'U';'V';'WS';'WD'};

process_vars_name = {'P';'Z';'TC';'RH';'U';'V';'WS';'WD'};

process_vars_unit = {'hPa';'km';'^\circC';'%';'m/s';'m/s';'m/s';'dir.'};

process_vars_range   = {[-5,5]; ... [994,1011]; ... [100,1025]; ...
                        [-0.1,15]; ...
                        [-9,9]; ...[24,41]; ... [-65,45]; ...
                        [-26,26]; ...[-1,101]; ...
                        [-22,22]; ...
                        [-22,22]; ...
                        [-0.1,26]; ...
                        [-1,361] ...
                        };
process_vars_tick    = {[-4:1:4]; ... [990:5:1010]; ... [100:200:1e3]; ...
                        [0:2:14]; ...
                        [-8:2:8]; ... [20:5:40]; ... [-60:20:40]; ...
                        [-25:5:25]; ... [0:20:100]; ...
                        [-20:5:20]; ...
                        [-20:5:20]; ...
                        [0:5:25]; ...
                        [0:22.5:360] ...
                        };

process_vars_color   = {[0.4,0.4,0.4]; ...
                        [0.4,0.4,0.4]; ...
                        [1,0.2,0.2]; ...
                        [0,0.4,0.2]; ...
                        [0,0.2,0.8]; ...
                        [0,0.2,0.8]; ...
                        [0,0.2,0.8]; ...
                        [0,0.2,0.8] ...
                        };

% ==============================================================================

%% Read data:

plot_var_RS = {[],[],[],[],[],[],[],[]};
plot_var_ST = {[],[],[],[],[],[],[],[]};

for yeari = 1:2 % 2018-2019

    eval([ 'ST_data_info = ST_data_info_',year_no{yeari},';' ]);
    eval([ 'data_path_ST = data_path_ST_',year_no{yeari},';' ]);
    eval([ 'data_path_RS = data_path_RS_',year_no{yeari},';' ]);
    
    for vari = [1,3,4] % for PTU
        
        pb1 = CmdLineProgressBar(['... Loading ',process_vars{vari},' ... ']);
        
        for di = 1:size(ST_data_info,1)
            
            if ( ST_data_info.L1_flag(di) == 1 )
            % if ( ST_data_info.L1_flag(di) == 1 & ST_data_info.StormTracker_no(di) > 600 ) % for 1st & 2nd patches
                
                %% Get datetime:
                
                switch year_no{yeari}
                    case '2018'
                        tmp_date = num2str(ST_data_info.DATE(di));
                    case '2019'
                        tmp_date = num2str(ST_data_info.DATE_UTC(di));
                end
                
                ST_tmp_nominalT = datetime( str2double(tmp_date(1:4)), str2double(tmp_date(5:6)), str2double(tmp_date(7:8)), ST_data_info.UTC(di), 0, 0 );
                
                %% Get Storm Tracker #:
                
                ST_no = ST_data_info.StormTracker_no(di);
                
                %% Load Storm Tracker L2 data & corresponding L2 Radiosonde data:
                
                load([data_path_ST,datestr(ST_tmp_nominalT,'mm'),'/46692_',year_no{yeari},datestr(ST_tmp_nominalT,'mmddHH'),'_',num2str(ST_no),'.mat']);
                load([data_path_RS,datestr(ST_tmp_nominalT,'mm'),'/46692_',year_no{yeari},datestr(ST_tmp_nominalT,'mmddHH'),'.mat']);
                
                % eval([ 'tmp_ST_data = ST_L2_',year_no,datestr(tmp_date,'mmddHH'),';' ]);
                eval([ 'tmp_ST_data = ST_L3_GC_',year_no{yeari},datestr(ST_tmp_nominalT,'mmddHH'),'_',num2str(ST_no),';' ]);
                
                eval([ 'tmp_RS_data = RS_L2_',year_no{yeari},datestr(ST_tmp_nominalT,'mmddHH'),';' ]);
                
                %% Get variables at the sfc.:
                
                tmp_ST_sfcid = find( tmp_ST_data.TIME_SEC <= 2 );
                tmp_RS_sfcid = find( tmp_RS_data.TIME_SEC <= 2 );
                
                if ( isempty(tmp_ST_sfcid) == 1 )
                    tmp_ST_var = NaN;
                else
                    eval([ 'tmp_ST_var = tmp_ST_data.',process_vars_name{vari},'(tmp_ST_sfcid(1));' ]);
                end
                
                if ( isempty(tmp_ST_sfcid) == 1 )
                    tmp_RS_var = NaN;
                else
                    eval([ 'tmp_RS_var = tmp_RS_data.',process_vars_name{vari},'(tmp_ST_sfcid(1));' ]);
                end
                
                plot_var_RS{vari} = [plot_var_RS{vari};tmp_RS_var];
                plot_var_ST{vari} = [plot_var_ST{vari};tmp_ST_var];
                
                clear tmp_*
                
            end
            
            pb1.print(di,size(ST_data_info,1));
            
        end
        
        % clear ST_* RS_*
        
        clear pb1
        
    end
    
    clear ST_data_info
    

end

plot_var_RS{2} = plot_var_RS{2}(:)./1e3;
plot_var_ST{2} = plot_var_ST{2}(:)./1e3;

clear ST_L* RS_L*


% ==============================================================================

%% GROUND CHECK:

% GC_list = who('RS_*');
% 
% for gci = 1:length(GC_list)
%     
%     % RS:
%     
%     eval([ 'GC_RS_TIME_sfc(gci) = ',GC_list{gci},'.TIME_SEC(1);' ]);
%     eval([ 'GC_RS_P_sfc(gci) = ',GC_list{gci},'.P(1);' ]);
%     eval([ 'GC_RS_T_sfc(gci) = ',GC_list{gci},'.TC(1);' ]);
%     eval([ 'GC_RS_RH_sfc(gci) = ',GC_list{gci},'.RH(1);' ]);
%     
%     % ST:
%     
%     eval([ 'GC_ST_TIME_sfc(gci) = ST_L3',GC_list{gci}(6:end),'.TIME_SEC(1);' ]);
%     eval([ 'GC_ST_P_sfc(gci) = ST_L3',GC_list{gci}(6:end),'.P(1);' ]);
%     eval([ 'GC_ST_T_sfc(gci) = ST_L3',GC_list{gci}(6:end),'.TC(1);' ]);
%     eval([ 'GC_ST_RH_sfc(gci) = ST_L3',GC_list{gci}(6:end),'.RH(1);' ]);
%     
% end
% 
% clear ST_* RS_*
% 
% % f1 = histogram(GC_ST_P_sfc-GC_RS_P_sfc,[-3:0.25:3]); hold on;
% % f1 = histogram(GC_ST_T_sfc-GC_RS_T_sfc,[-5:0.25:5]); hold on;
% f1 = histogram(GC_ST_RH_sfc-GC_RS_RH_sfc,[-12:2:12]); hold on;
% f0 = plot([0,0],[0,100]); f0.LineWidth = 2; f0.LineStyle = '--'; f0.Color = 'k';
% % axis([-3.25,3.25,0,15]);
% % axis([-5.25,5.25,0,12]);
% axis([-12,12,0,12]);
% axis square;
% % l1 = legend('P'); 
% % l1 = legend('T');
% l1 = legend('RH');
% l1.Location = 'northeast'; l1.FontSize = 16;
% set(gcf,'Color',[1,1,1]);
% % export_fig(['GC_P.png'],'-r150');
% % export_fig(['GC_T.png'],'-r150');
% export_fig(['GC_RH.png'],'-r150');
% 
% close;

sample_no = length(plot_var_ST{1})

P_diff = plot_var_ST{1}-plot_var_RS{1};
P_diff_mean_std = [ nanmean(P_diff), nanstd(P_diff) ]

T_diff = plot_var_ST{3}-plot_var_RS{3};
T_diff_mean_std = [ nanmean(T_diff), nanstd(T_diff) ]

RH_diff = plot_var_ST{4}-plot_var_RS{4};
RH_diff_mean_std = [ nanmean(RH_diff), nanstd(RH_diff) ]

% ==============================================================================

%% CONSISTENCY FACTOR CALCULATION:

% % Combined Uncertainty:
% 
% con_vars = {'P';'Z';'T';'RH';'WSPD';'U';'V'};
% 
% combined_uncertainty = {[sqrt((1).^2+(1).^2)]; ...
%                         [sqrt((0.01).^2+(0.01).^2)]; ...
%                         [sqrt((0.3).^2+(0.3).^2)]; ...
%                         [sqrt((4).^2+(2).^2)]; ...
%                         [sqrt((0.15).^2+(0.1).^2)]; ...
%                         [sqrt((0.15).^2+(0.1).^2)]; ...
%                         [sqrt((0.15).^2+(0.1).^2)] ...
%                         };
% 
% % K-factor:
% 
% K_factor = {[abs(nanmean(plot_var_ST{1})-nanmean(plot_var_RS{1}))./combined_uncertainty{1}]; ...
%             [abs(nanmean(plot_var_ST{2})-nanmean(plot_var_RS{2}))./combined_uncertainty{2}]; ...
%             [abs(nanmean(plot_var_ST{3})-nanmean(plot_var_RS{3}))./combined_uncertainty{3}]; ...
%             [abs(nanmean(plot_var_ST{4})-nanmean(plot_var_RS{4}))./combined_uncertainty{4}]; ...
%             [abs(nanmean(plot_var_ST{7})-nanmean(plot_var_RS{7}))./combined_uncertainty{5}]; ...
%             [abs(nanmean(plot_var_ST{5})-nanmean(plot_var_RS{5}))./combined_uncertainty{6}]; ...
%             [abs(nanmean(plot_var_ST{6})-nanmean(plot_var_RS{6}))./combined_uncertainty{7}] ...
%             };
%                 
% disp(K_factor);

% ==============================================================================

%% T-TEST BETWEEN 1 & 2 PATCHES:

% clear RS_L2_* ST_L2_*
% 
% valid_id = find( ST_data_info.L1_flag(:) == 1 );
% ST_no = ST_data_info.StormTracker_no(valid_id);
% 
% patch1_id = find( ST_no(:) <= 600 );
% patch2_id = find( ST_no(:) > 600 );
% 
% [h_P,p_P] = ttest2(P_diff(patch1_id),P_diff(patch2_id))
% [h_T,p_T] = ttest2(T_diff(patch1_id),T_diff(patch2_id))
% [h_RH,p_RH] = ttest2(RH_diff(patch1_id),RH_diff(patch2_id))


% ==============================================================================

%% Plotting figure.
close all;

gf1 = gcf;

gf1.WindowState = 'maximized';

ax_font_size = 24;
ax_line_width = 4;

%% Scatter:

for vari = [1,3,4] % plot P, T, RH
    
    %% Set sub-pot locations:
    
    switch vari
        case 1
            sub_id_v = 1; sub_id_h = 1;
        case 3
            sub_id_v = 1; sub_id_h = 2;
        case 4
            sub_id_v = 1; sub_id_h = 3;
    end
    
    %% Sub-Plot:
    
    subaxis(1,3,sub_id_h,sub_id_v,'Spacing',0.05);
    
    f11 = histogram(plot_var_ST{vari}(:)-plot_var_RS{vari}(:),25);
    
    f11.FaceColor = process_vars_color{vari};
    f11.EdgeColor = process_vars_color{vari};
    
    hold on;
    
    % f12 = histogram(plot_var_ST{vari}(54:end)-plot_var_RS{vari}(54:end),20);
    
    hold on;
    
    %% Mean value:
    
    f110 = line([mean(plot_var_ST{vari}(:)-plot_var_RS{vari}(:)),mean(plot_var_ST{vari}(:)-plot_var_RS{vari}(:))],[-1e6,1e6]);
    
    f110.LineWidth = 2.0;
    f110.LineStyle = '--';
    f110.Color = process_vars_color{vari};
    
    txt110 = text(mean(plot_var_ST{vari}(:)-plot_var_RS{vari}(:))+0.2,50,['avg.=',num2str(mean(plot_var_ST{vari}(:)-plot_var_RS{vari}(:)),3)]);
    
    txt110.FontName = 'Helvetica';
    txt110.FontSize = ax_font_size;
    txt110.FontWeight = 'bold';
    
    hold on;
    
    %% 1-1 line:
    
    f10 = line([0,0],[-1e6,1e6]);
    
    f10.LineWidth = 2.0;
    f10.LineStyle = '-';
    f10.Color = [0.2,0.2,0.2];
    
    %% Set axes: Axis 1:
    
    ax11 = gca;
    
    set(ax11,'Box','off','Color','none');
    set(ax11,'PlotBoxAspectRatio',[1,1,1])
    % set(ax11,'Position',[0.125,0.125,0.75,0.75])
    set(ax11,'TickDir','out')
    set(ax11,'FontName','Helvetica','FontSize',ax_font_size,'FontWeight','bold')
    set(ax11,'LineWidth',ax_line_width)
    set(ax11,'Xlim',process_vars_range{vari})
    set(ax11,'XTick',process_vars_tick{vari})
    % set(ax11,'XTickLabel',[])
    set(ax11,'XMinorTick','off','XMinorGrid','off')
    set(ax11,'Ylim',[0,60])
    set(ax11,'YTick',[0:10:50])
    % set(ax11,'YMinorTick','on','YMinorGrid','off')
    % set(ax1,'YGrid','off');
    
    %% Labels:
    
    % xlabel(['\bf{RS-41 ',process_vars{vari},'}'])
    % ylabel(['\bf{Storm Tracker ',process_vars{vari},'}'])
    
    %% Set axes: Axis 2:
    ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);
    
    set(ax12,'PlotBoxAspectRatio',[1,1,1])
    set(ax12,'TickLength',[0.0050,0.0250])
    set(ax12,'TickDir','out')
    set(ax12,'LineWidth',ax_line_width)
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
    set(leg1,'FontSize',ax_font_size)
    set(leg1,'FontWeight','bold')
    set(leg1,'BackgroundColor',[1,1,1,0.5])
    set(leg1,'EdgeColor','k')
    set(leg1,'LineWidth',ax_line_width)
    
end

% ==============================================================================
    
%% Save Figure:
 
set(gf1,'Color',[1,1,1]);

figname = ['./Hist_GC_ST_RS_2018_2019'];

% print(gf1,'-dpng','-r300',figname);
 
export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

% ==============================================================================

toc;
