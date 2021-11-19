clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Taylor Diagram for Intercomparison between 46692 Storm Tracker vs. Radiosonde 
% during TASSE 2018-2019.
% 
% Source Datasets: Vaisala RS41-SGP:   L2
%                  Storm Tracker:      L2, L3
% 
% Comparison is between Level 2 / Level 3 data for P, T, RH.
% 
% ==============================================================================

%% Load Data Info:

% Station number:
station_no = '46692';

% Year:
year_no = {'2018','2019','2020'};

% Data info:

% ST_Level = 'L2';
% ST_Level = 'L3_GC_P';
% ST_Level = 'L3_GC_P_CDFhr_T';
% ST_Level = 'L3_GC_P_CDFhr_T_RH';
ST_Level = 'L3_GC_P_CDFhr_T_RH_P1LDC_RH';

% Data info:
ST_data_info_2018 = readtable('../../../../../Data/DATA_TASSE/TASSE2018_StormTracker_QC_AspenV344/46692_StormTracker_log_info.xlsx');
ST_data_info_2019 = readtable('../../../../../Data/DATA_TASSE/TASSE2019_StormTracker_QC_AspenV344/Banqiao_ST_log_info_wVaisala.xlsx');
ST_data_info_2020 = readtable('../../../../../Data/DATA_TASSE/TAWSE2020_StormTracker_QC_AspenV344/Banqiao_ST_log_info_wVaisala.xlsx');

% Data path (Storm Tracker):
data_path_ST_2018 = ['../../../../../Data/DATA_TASSE/TASSE2018_StormTracker_QC_AspenV344/',ST_Level,'_mat/2018/'];
data_path_ST_2019 = ['../../../../../Data/DATA_TASSE/TASSE2019_StormTracker_QC_AspenV344/',ST_Level,'_mat/2019/'];
data_path_ST_2020 = ['../../../../../Data/DATA_TASSE/TAWSE2020_StormTracker_QC_AspenV344/',ST_Level,'_mat/2020/'];

% Data path (Vaisala Radiosonde):
data_path_RS_2018 = ['../../../../../Data/DATA_TASSE/Sounding_46692/L2_mat/2018/'];
data_path_RS_2019 = ['../../../../../Data/DATA_TASSE/Sounding_46692/L2_mat/2019/'];
data_path_RS_2020 = ['../../../../../Data/DATA_TASSE/Sounding_46692/L2_mat/2020/'];

% ==============================================================================

%% Set parameters:

process_vars = {'P';'gz';'T';'RH';'U';'V';'WS'};

process_vars_name = {'P';'Z';'TC';'RH';'U';'V';'WS'};

process_vars_unit = {'hPa';'km';'^\circC';'%';'m/s';'m/s';'m/s'};

process_vars_range   = {[290,1025]; ...
                        [-0.1,15]; ...
                        [-65,45]; ...
                        [-0.2,100.2]; ...
                        [-22,22]; ...
                        [-22,22]; ...
                        [-0.1,26] ...
                        };
process_vars_tick    = {[100:200:1e3]; ...
                        [0:2:14]; ...
                        [-60:20:40]; ...
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
    
    for yeari = 1:3 
        
        eval([ 'ST_data_info = ST_data_info_',year_no{yeari},';' ]);
        eval([ 'data_path_ST = data_path_ST_',year_no{yeari},';' ]);
        eval([ 'data_path_RS = data_path_RS_',year_no{yeari},';' ]);
        
        pb1 = CmdLineProgressBar(['... Loading ',process_vars{vari},' ... ']);
        
        for di = 1:size(ST_data_info,1)
            
            if ( ST_data_info.L1_flag(di) == 1 )
            % if ( ST_data_info.L1_flag(di) == 1 && ismember(ST_data_info.UTC(di),[22,23,0:9]) )
                
                %% Get datetime:
                
                switch year_no{yeari}
                    case '2018'
                        tmp_date = num2str(ST_data_info.DATE(di));
                    otherwise
                        tmp_date = num2str(ST_data_info.DATE_UTC(di));
                end
                ST_nominalT = datetime( str2double(tmp_date(1:4)), str2double(tmp_date(5:6)), str2double(tmp_date(7:8)), ST_data_info.UTC(di), 0, 0, 'TimeZone', 'UTC' );
                
                %% Get Storm Tracker #:
                
                ST_no = ST_data_info.StormTracker_no(di);
                
                %% Load Storm Tracker data & corresponding L2 Radiosonde data:
                
                tmp_data_ST = importdata([data_path_ST,datestr(ST_nominalT,'mm'),'/46692_',datestr(ST_nominalT,'yyyymmddHH'),'_',num2str(ST_no),'.mat']);
                tmp_data_RS = importdata([data_path_RS,datestr(ST_nominalT,'mm'),'/46692_',datestr(ST_nominalT,'yyyymmddHH'),'.mat']);
                
                test_size_ST(ssi) = length(tmp_data_ST.P);
                test_size_RS(ssi) = length(tmp_data_RS.P);
                ssi = ssi+1;
                
                %% FILTER DATA BY PRESSURE:
                % tmp_data_ST_pid = find(tmp_data_ST.P>=800);
                tmp_data_ST_pid = find(tmp_data_ST.P>=300 & tmp_data_ST.P<500);
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
        
    end
    
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

% % Combined Uncertainty:
% 
% con_vars = {'P';'gz';'T';'RH';'U';'V';'WS'};
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
% K_factor = { [abs(nanmean(plot_var_ST{1})-nanmean(plot_var_RS{1}))./combined_uncertainty{1}]; ...
%              [abs(nanmean(plot_var_ST{2})-nanmean(plot_var_RS{2}))./combined_uncertainty{2}]; ...
%              [abs(nanmean(plot_var_ST{3})-nanmean(plot_var_RS{3}))./combined_uncertainty{3}]; ...
%              [abs(nanmean(plot_var_ST{4})-nanmean(plot_var_RS{4}))./combined_uncertainty{4}]; ...
%              [abs(nanmean(plot_var_ST{5})-nanmean(plot_var_RS{5}))./combined_uncertainty{5}]; ...
%              [abs(nanmean(plot_var_ST{6})-nanmean(plot_var_RS{6}))./combined_uncertainty{6}]; ...
%              [abs(nanmean(plot_var_ST{7})-nanmean(plot_var_RS{7}))./combined_uncertainty{7}] ...
%             };
% 
% disp('K_factor');        
% disp(K_factor);
% 
% % ==============================================================================
% 
% %% RMSE:
% 
% RMSE = { sqrt(nanmean((plot_var_ST{1} - plot_var_RS{1}).^2)); ...
%          sqrt(nanmean((plot_var_ST{2} - plot_var_RS{2}).^2)); ...
%          sqrt(nanmean((plot_var_ST{3} - plot_var_RS{3}).^2)); ...
%          sqrt(nanmean((plot_var_ST{4} - plot_var_RS{4}).^2)); ...
%          sqrt(nanmean((plot_var_ST{5} - plot_var_RS{5}).^2)); ...
%          sqrt(nanmean((plot_var_ST{6} - plot_var_RS{6}).^2)); ...
%          sqrt(nanmean((plot_var_ST{7} - plot_var_RS{7}).^2)); ...
%         };
% 
% disp('RMSE');
% disp(RMSE);
% 
% % ==============================================================================
% 
% %% Biases:
% 
% bias_mean = { nanmean(plot_var_ST{1} - plot_var_RS{1}), nanstd(plot_var_ST{1} - plot_var_RS{1}); ...
%               nanmean(plot_var_ST{2} - plot_var_RS{2}), nanstd(plot_var_ST{2} - plot_var_RS{2}); ...
%               nanmean(plot_var_ST{3} - plot_var_RS{3}), nanstd(plot_var_ST{3} - plot_var_RS{3}); ...
%               nanmean(plot_var_ST{4} - plot_var_RS{4}), nanstd(plot_var_ST{4} - plot_var_RS{4}); ...
%               nanmean(plot_var_ST{5} - plot_var_RS{5}), nanstd(plot_var_ST{5} - plot_var_RS{5}); ...
%               nanmean(plot_var_ST{6} - plot_var_RS{6}), nanstd(plot_var_ST{6} - plot_var_RS{6}); ...
%               nanmean(plot_var_ST{7} - plot_var_RS{7}), nanstd(plot_var_ST{7} - plot_var_RS{7}); ...
%              };
% 
% disp('bias_mean');
% disp(bias_mean);

% ==============================================================================

%% Taylor diagram parameters calculation:

nnid_ST = ~isnan(plot_var_ST{varid});
nnid_RS = ~isnan(plot_var_RS{varid});
nnid = nnid_ST.*nnid_RS;

centered_sample_ST = plot_var_ST{varid}(nnid==1)-nanmean(plot_var_ST{varid}(nnid==1));
centered_sample_RS = plot_var_RS{varid}(nnid==1)-nanmean(plot_var_RS{varid}(nnid==1));

centered_std_ST = nanstd(centered_sample_ST);
centered_std_RS = nanstd(centered_sample_RS);
% centered_std_ST = nanstd(plot_var_ST{varid}-nanmean(plot_var_ST{varid}));
% centered_std_RS = nanstd(plot_var_RS{varid}-nanmean(plot_var_RS{varid}));

centered_std_ST_normalized = centered_std_ST./centered_std_RS;
centered_std_RS_normalized = centered_std_RS./centered_std_RS; % 1

centered_CC = corrcoef(centered_sample_ST,centered_sample_RS);

centered_RMSE = sqrt(nanmean((centered_sample_ST - centered_sample_RS).^2));
centered_RMSE_normalized = centered_RMSE./centered_std_RS;

disp('centered_std_RS');
disp(centered_std_RS);

disp('centered_std_ST');
disp(centered_std_ST);

disp('centered_std_ST_normalized');
disp(centered_std_ST_normalized);

disp('centered_CC');
disp(centered_CC);

disp('centered_RMSE');
disp(centered_RMSE);

disp('centered_RMSE_normalized');
disp(centered_RMSE_normalized);


% ==============================================================================

%% Plotting figure.

close;

gf1 = gcf;

% gf1.WindowState = 'maximized';

ax_fontsize = 14;
ax_linewidth = 1.5;

% % Taylor Diagram:
% 
% [tay_hp,tay_ht,tay_axl] = taylordiag([centered_std_RS,centered_std_ST],[0,centered_RMSE],[1,centered_CC(1,2)] ...
%                                     ,'tickRMS',[2:2:10] ...
%                                     ,'titleRMS',0 ...
%                                     ,'tickCOR',[0:0.1:0.8,0.85,0.9:0.02:0.96,0.97,0.98,0.99,0.995,0.999,1] ...
%                                      );
                                 
% Normalized Taylor Diagram:

[tay_hp,tay_ht,tay_axl] = taylordiag([centered_std_RS_normalized,centered_std_ST_normalized],[0,centered_RMSE_normalized],[1,centered_CC(1,2)] ...
                                    ,'tickRMS',[0,0.1,0.2,0.4,0.6] ...
                                    ,'titleRMS',0 ...
                                    ,'limSTD', 1.5 ...
                                    ,'tickCOR',[0:0.1:0.8,0.85,0.9,0.95,0.98,0.99,0.995,0.999,1] ...
                                     );

% [tay_hp,tay_ht,tay_axl] = taylordiag([1,1.0194],[0,0.0834],[1,0.9968]);

xlab = xlabel('Normalized Std. Dev.');                                 
xlab.FontName = 'Helvetica';
xlab.FontSize = ax_fontsize;
xlab.FontWeight = 'bold';

tay_axl(1).handle.String = 'Normalized Std. Dev.';
tay_axl(1).handle.FontSize = ax_fontsize;

for ti = 1:length(tay_axl(2).handle)
    tay_axl(2).handle(ti).FontSize = ax_fontsize;
end

% for ti = 1:length(tay_axl(3).handle)
%     tay_axl(3).handle(ti).FontSize = ax_fontsize;
% end
                                
tay_hp(1).LineWidth = ax_linewidth;
tay_hp(1).Marker = 'o';
tay_hp(1).MarkerSize = 10;
tay_hp(1).MarkerFaceColor = 'k'; % [0,0.5,1];
tay_hp(1).MarkerEdgeColor = 'k';

% tay_ht(1).String = 'RS';
tay_ht(1).String = '';
tay_ht(1).FontSize = ax_fontsize;

tay_hp(2).LineWidth = ax_linewidth;
tay_hp(2).Marker = 'o';
tay_hp(2).MarkerSize = 10;
switch varid
    case 3
        tay_hp(2).MarkerFaceColor = 'r';
    case 4
        tay_hp(2).MarkerFaceColor = [0,0.5,1];
end
tay_hp(2).MarkerEdgeColor = 'k';

% tay_ht(2).String = ['ST (',ST_Level(1:2),')'];
tay_ht(2).String = [''];
tay_ht(2).FontSize = ax_fontsize;
if ( ST_Level(1:2)=='L3' )
    tay_ht(2).Position = [14,1];
    % tay_ht(2).Position = [37,7];
end

% for vari = varid % one variable
%     
%     %% Set sub-pot locations:
%     
% %     switch vari
% %         case 1
% %             sub_id_v = 1; sub_id_h = 1;
% %         case 3
% %             sub_id_v = 1; sub_id_h = 2;
% %         case 4
% %             sub_id_v = 1; sub_id_h = 3;
% %     end
%     
%     %% Sub-Plot:
%     
% %     subaxis(1,3,sub_id_h,sub_id_v,'Spacing',0.05);
%     
%     f11 = scatter(plot_var_RS{vari},plot_var_ST{vari});
%     
%     f11.Marker = '.';
%     f11.MarkerEdgeColor = process_vars_color{vari};
%     f11.MarkerEdgeAlpha = 0.5;
%     % f11.LineWidth = 2;
%     % f11.MarkerFaceColor = process_vars_color{vari};
%     % f11.MarkerFaceAlpha = 0.5;
%     
%     hold on;
%     
%     %% 1-1 line:
%     
%     f10 = line([-1e6,1e6],[-1e6,1e6]);
%     
%     f10.LineWidth = 2;
%     f10.LineStyle = '--';
%     f10.Color = [0.2,0.2,0.2];
%     
%     
%     %% Set axes: Axis 1:
%     
%     ax11 = gca;
%     
%     set(ax11,'Box','off','Color','none');
%     set(ax11,'PlotBoxAspectRatio',[1,1,1])
%     % set(ax11,'Position',[0.125,0.125,0.75,0.75])
%     set(ax11,'TickDir','out')
%     set(ax11,'FontName','Helvetica','FontSize',ax_fontsize,'FontWeight','bold')
%     set(ax11,'LineWidth',ax_linewidth)
%     set(ax11,'Xlim',process_vars_range{vari})
%     set(ax11,'XTick',process_vars_tick{vari})
%     if ( strcmp(process_vars_name{vari},'P') == 1 )
%         set(ax11,'XDir','reverse')
%     end
%     % set(ax11,'XTickLabel',[])
%     set(ax11,'XMinorTick','off','XMinorGrid','off')
%     set(ax11,'Ylim',process_vars_range{vari})
%     set(ax11,'YTick',process_vars_tick{vari})
%     if ( strcmp(process_vars_name{vari},'P') == 1 )
%         set(ax11,'YDir','reverse')
%     end
%     set(ax11,'YMinorTick','off','YMinorGrid','off')
%     % set(ax1,'YGrid','off');
%     
%     %% Labels:
%     
%     % xlabel(['\bf{RS-41 ',process_vars{vari},'}'])
%     % ylabel(['\bf{Storm Tracker ',process_vars{vari},'}'])
%     
%     %% Set axes: Axis 2:
%     ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);
%     
%     set(ax12,'PlotBoxAspectRatio',[1,1,1])
%     set(ax12,'TickLength',[0.0050,0.0250])
%     set(ax12,'TickDir','out')
%     set(ax12,'LineWidth',ax_linewidth)
%     set(ax12,'Xlim',ax11.XLim);
%     set(ax12,'XDir',ax11.XDir)
%     set(ax12,'Ylim',ax11.YLim);
%     set(ax12,'YMinorTick','off')
%     set(ax12,'YDir',ax11.YDir)
%     
%     % Link axes in case of zooming and set original axis as active:
%     linkaxes([ax11,ax12])
%     axes(ax11)
%     
%     % Get the actual axes position:
%     % ax11_pos = plotboxpos(ax11);
%     
%     %% 1. Legends:
%     
%     leg_label_1 = [process_vars{vari},' (',process_vars_unit{vari},')'];
%     
%     leg1 = text(0.05,0.95,leg_label_1,'Units','normalized');
%     
%     set(leg1,'VerticalAlignment','top')
%     set(leg1,'FontName','Helvetica')
%     set(leg1,'FontSize',ax_fontsize)
%     set(leg1,'FontWeight','bold')
%     set(leg1,'BackgroundColor',[1,1,1,0.5])
%     set(leg1,'EdgeColor','k')
%     set(leg1,'LineWidth',ax_linewidth)
%     
% end
a
% ==============================================================================
    
%% Save Figure:
 
set(gf1,'Color',[1,1,1]);

figname = ['./TaylorDiag_RS_ST_',ST_Level,'_',process_vars{varid}];
 
% print(gf1,'-dpng','-r300',figname);
 
% export_fig([figname,'.png'],'-r300')
export_fig([figname,'.png'],'-r300','-transparent')

% ==============================================================================

toc;
