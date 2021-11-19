clear;close all;clc;

addpath(genpath('/Users/yuhungjui/Dropbox/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot the inventory figure of sounding. (Time – Pressure)
% 
% ==============================================================================

%% Station names:
site_name = {'Banqiao (Vaisala)'};

%% Data level:

data_level = 'L4u_1hPa';
plot_level = 'L4u_1hPa';

% ==============================================================================

%% Set Time Table:

year_no = '2019';

date_1 = datetime(str2double(year_no),6,24,0,0,0,'TimeZone','Asia/Taipei');

date_2 = datetime(str2double(year_no),8,31,23,0,0,'TimeZone','Asia/Taipei');

date_int = 1; % hr

date_dur = date_1:hours(1):date_2;

date_arr = datestr(date_dur,'yyyymmddHH');

date_mat = datevec(date_dur);

%% Set Xtick:

date_range = 1:numel(date_dur);

date_to_label_id = [1,[7,11,16,21,26,31].*24+1,[38,42,47,52,57,62,68].*24+1];

date_xtick_lab = datestr(date_dur,'mmdd');

for di = 1:numel(date_dur)
    if ( ismember(di,date_to_label_id) == 0 )
        date_xtick_lab(di,:) = '    ';
    end
end

% ==============================================================================

%% Male the plot:

close;

gf1 = gcf;
gf1.WindowState = 'maximized';

%% Inventory:

si = 1;

file_path = ['../../../../Data/DATA_TASSE/Sounding_46692/L4u_1hPa_mat/',year_no,'/'];
    
file_dir = dir([file_path,'**/*.mat']);

for sti = 1:numel(file_dir)
    
    %% Load Storm Tracker data:
    
    data_RS = importdata([file_dir(sti).folder,'/',file_dir(sti).name]);
    
    %% Set plotting varaibles:
    data_RS_Time = datetime(data_RS.Time,'InputFormat','yyyyMMddHH','TimeZone','UTC');
    data_RS_Time.TimeZone = 'Asia/Taipei';
    
    plot_val_x = find(date_dur==data_RS_Time);
    
    if ~isempty(plot_val_x)
    
        %% Plot:
        
        f11{sti} = plot(repmat(plot_val_x,[numel(data_RS.P),1]),data_RS.P,'LineStyle','none');
        
        f11{sti}.Marker = '.';
        f11{sti}.MarkerSize = 1;
        f11{sti}.Color = [0,0,1];
        % f11{sti}.MarkerFaceColor = 'r';
        % f11{sti}.MarkerEdgeColor = 'r';
        
        hold on
    
    end
    
    clear data_ST
    clear plot_val_x
    
end

% ==============================================================================

%% 1. Set axes: Axis 1:

axfont = 36;

ax11 = gca;

set(ax11,'Box','off','Color','none')
set(ax11,'PlotBoxAspectRatio',[10,1,1])
set(ax11,'Position',[0.12,0.2,0.7,0.6])
set(ax11,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold','LineWidth',1.0,'TickDir','out')
set(ax11,'Xlim',[1,numel(date_dur)])
set(ax11,'XTick',[date_to_label_id])
set(ax11,'XTickLabel',date_xtick_lab(date_to_label_id,:))
set(ax11,'XMinorTick','on','XMinorGrid','off')
set(ax11,'XTickLabelRotation',45)
set(ax11,'Ylim',[300,1000])
set(ax11,'YScale','log')
set(ax11,'YTick',[100,150,200:100:1000])
set(ax11,'YTickLabel',{'100';'150';'200';'300';'';'';'600';'';'';'900';''})
set(ax11,'YMinorTick','off')
set(ax11,'YDir','Reverse')

%% 1. Labels:
xlab = xlabel(['\bf{',year_no,' Date (00LT)}'],'FontSize',36);
ylab = ylabel([site_name{si},'\newline','    \bf{P (hPa)}'],'FontSize',36);

%% 1. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',[10,1,1])
set(ax13,'LineWidth',1.0,'TickDir','out')
set(ax13,'Xlim',ax11.XLim);
set(ax13,'Ylim',ax11.YLim)
set(ax13,'YScale','log')
set(ax13,'YMinorTick','off')
set(ax13,'YDir','Reverse')

% Link axes in case of zooming and set original axis as active:
linkaxes([ax11,ax13])
axes(ax11)

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:

set(gf1,'Color',[1,1,1]);

figname = ['./Inventory_',site_name{si}];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

