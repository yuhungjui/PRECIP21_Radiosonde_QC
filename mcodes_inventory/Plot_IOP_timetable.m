clear;close all;clc;

addpath(genpath('/Users/yuhungjui/Dropbox/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot the timetable for each site during TASSE 2019.
% 
% ==============================================================================

%% Set Station:

site_name = {'Banqiao'; ...
             'Chidu'; ...
             'NTU'; ...
             'Shezi'; ...
             'TNUA'; ...
             'Xindian' ...
             };

%% Reag IOP Date:

for si = 1:6

    IOP_date{si} = importdata(['./IOP_Date_',site_name{si},'.txt']);
    
end

% ==============================================================================

%% Set Time Table:

year_no = '2019';

date_1 = datetime(str2double(year_no),6,24)

date_2 = datetime(str2double(year_no),8,31)

% month_arr = datestr(date_1:calmonths(1):date_2,'mm');
% day_arr = datestr(date_1:days(1):date_2,'mmdd');
% date_int = 3; % Hr

date_dur = date_1:date_2;

date_arr = datestr(date_dur,'yyyymmdd');

date_mat = datevec(date_dur);

%% Set Xtick:

date_range = 1:numel(date_dur);

date_to_label_id = [1,5,8,24,37,39,50,57,67,68,69];

date_xtick_lab = datestr(date_dur,'mmdd');

for di = 1:numel(date_dur)
    if ( ismember(di,date_to_label_id) == 0 )
        date_xtick_lab(di,:) = '    ';
    end
end

% if (mod(date_mat(end,3),10) > 0 && mod(date_mat(end,3),10) <= 4 )
%     date_xtick_lab{end} = '';
% end
% 
% date_xtick = find( strcmp(date_xtick_lab(:),'') == 0 );
% date_xtick = date_xtick(1:24/date_int:end );
% 
% date_xtick_lab = date_xtick_lab(date_xtick);

% ==============================================================================

%% Set IOP matrix:

for di = 1:numel(date_dur)
    
    for si = 1:6
        
        IOP_matrix(di,si) = 0;
        
        if ( ismember(str2double(date_arr(di,:)),IOP_date{si}(:)) == 1 )
            
            IOP_matrix(di,si) = 1;
            
        end
        
    end
    
end

% ==============================================================================

%% Male the plot:

close;

gf1 = gcf;
gf1.WindowState = 'maximized';

%% Timetable

f11 = imagesc(0.5:numel(date_dur)-0.5,1:6,IOP_matrix');

colormap([1 1 1; 0 0.5 1]);

hold on;

% Make the grid lines manually ...

for ni = 0.5:6.5
    plot([0,69],[ni,ni],'k');
end

for ni = 0:numel(date_dur)+1
    plot([ni,ni],[0.5,6.5],'k');
    if ( ismember(ni,[7,38,69]) == 1 )
        plot([ni,ni],[0.5,6.5],'r','LineWidth',2);
    end
end

%% 1. Set axes: Axis 1:

axis equal

axfont = 24;

ax1 = gca;
set(ax1,'Box','on');
set(ax1,'TickDir','out')
set(ax1,'TickLength',[0.0025,0.025])
set(ax1,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',1.5)
set(ax1,'Xlim',[0,69])
set(ax1,'XTick',[0:68])
set(ax1,'XTickLabel',date_xtick_lab)
set(ax1,'XTickLabelRotation',45)
% set(ax1,'XGrid','on');
% set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[0.5,6.5])
set(ax1,'YTick',[1:6])
set(ax1,'YTickLabel',site_name)
% set(ax1,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','on');
set(ax1,'Layer','bottom')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:

set(gf1,'Color',[1,1,1]);

figname = ['./IOP_Timetable'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

