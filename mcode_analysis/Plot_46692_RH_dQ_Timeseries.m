clear;close all;clc;
addpath(genpath('../../../../../Dropbox/Work/MatLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot timeseries of the 46692 sounding data from L4u_mat dataset.
% 
% Make time series for specified period.
% 
% ==============================================================================

%% Set Time Table:

year_no = '2019';

date_1 = datetime(str2double(year_no),6,24,0,0,0)

date_2 = datetime(str2double(year_no),9,1,0,0,0)

month_arr = datestr(date_1:calmonths(1):date_2,'mm');

% day_arr = datestr(date_1:days(1):date_2,'mmdd');

date_int = 3; % Hr

date_dur = date_1:hours(date_int):date_2;

date_arr = datestr(date_dur,'yyyymmddhh');

date_mat = datevec(date_dur);

%% Set Xtick:

date_range = 1:numel(date_dur);

for di = 1:numel(date_dur) 
    if ( ismember(date_mat(di,3),[1,10,20]) == 1 || di == numel(date_dur) )
        date_xtick_lab{di} = date_arr(di,5:8);
    else
        date_xtick_lab{di} = '';
    end
end

if (mod(date_mat(end,3),10) > 0 && mod(date_mat(end,3),10) <= 4 )
    date_xtick_lab{end} = '';
end

date_xtick = find( strcmp(date_xtick_lab(:),'') == 0 );
date_xtick = date_xtick(1:24/date_int:end );

date_xtick_lab = date_xtick_lab(date_xtick);

%% Set IOP periods:

plot_IOP_period = 0;

switch plot_IOP_period
    case 1
        [IOP_start,IOP_end] = Set_TASSE_IOP_period(str2double(year_no));
        
        IOP_dur = [IOP_start;IOP_end];
        
        tmp_IOP_id = zeros(size(date_dur));
        
        for iopi = 1:size(IOP_dur,1)
            for ti = 1:size(date_arr,1)
                if ( strcmp(IOP_dur(iopi,:),date_arr(ti,1:8)) == 1 )
                    tmp_IOP_id(ti) = 1;
                end
            end
        end
        
        tmp_IOP_id = find(tmp_IOP_id==1);
        
        if ( length(tmp_IOP_id) > 2 )
            IOP_id = reshape(tmp_IOP_id,length(tmp_IOP_id)./size(IOP_start,1),2)'
        end
        
        clear tmp_IOP_id_*
end

% ==============================================================================

%% Load sounding data:

for di = 1:numel(date_dur)
    
    file_path_name = ['../../../../Data/DATA_TASSE/Sounding_46692/L4u_5hPa_mat/',datestr(date_dur(di),'yyyy'),'/',datestr(date_dur(di),'mm'),'/46692_',datestr(date_dur(di),'yyyymmddHH'),'.mat'];
    
    if ( exist(file_path_name) ~= 0 )
        load(file_path_name);
    end
    
end

% file_path = ['../../../../Data/DATA_TASSE/Sounding_46692/L4u_5hPa_mat/',year_no,'/'];
% 
% file_folder = dir(file_path);
% 
% switch size(month_arr,1)
%     case 1
%         load([file_path,month_arr,'/46692_',year_no,month_arr,'.mat'])
%     otherwise
%         for fi = 1:length(month_arr)
%             load(ls([file_path,month_arr(fi,:),'/*.mat']))
%         end
% end
% 


file_loaded = who('RS_*');

% ==============================================================================

%% Plotting variable name:

plot_var_name_1 = 'RH'

plot_var_loaded_1 = 'RH';

plot_var_name_2 = 'dQ'

plot_var_loaded_2 = 'MR';

plot_var_unit_1 = '(%)'

plot_var_unit_2 = '(g/kg)'

%% Set pressure level:

p_level_11 = [1020:-5:50];

%% Set plotting variables:

for ti = 1:length(date_range)
    
    file_loaded_id = find( strcmp(file_loaded(:),['RS_',date_arr(ti,1:8),'_',date_arr(ti,9:10)]) == 1 );
    
    if ( isempty(file_loaded_id) == 1 )
        
        plot_var_11(:,ti) = nan(length(p_level_11),1);
        
        plot_var_12(:,ti) = nan(length(p_level_11),1);
        
        plot_var_1pbl(ti) = nan;
        
        plot_var_1fre(ti) = nan;
    
    else
        
        tmp_p_length_matrix = eval(['[1:numel(',file_loaded{file_loaded_id},'.P)]'])';
        
        plot_var_11(:,ti) = eval([ 'interp1(',file_loaded{file_loaded_id},'.P + tmp_p_length_matrix.*1e-7 ,',file_loaded{file_loaded_id},'.',plot_var_loaded_1,',p_level_11);' ]);
        
        plot_var_12(:,ti) = eval([ 'interp1(',file_loaded{file_loaded_id},'.P + tmp_p_length_matrix.*1e-7 ,',file_loaded{file_loaded_id},'.',plot_var_loaded_2,',p_level_11).*1e3;' ]);
        
        plot_var_1pbl(ti) = eval([ file_loaded{file_loaded_id},'.P_PBL(1);' ]);
        
        plot_var_1fre(ti) = eval([ file_loaded{file_loaded_id},'.P_0C(1);' ]);
        
    end

end

%% Anomalies calculation:

plot_var_12 = plot_var_12 - repmat(nanmean(plot_var_12,2),[1,size(date_arr,1)]);

% ==============================================================================

%% Interpolation for NaNs:

for pi = 1:numel(p_level_11)
    
    plot_var_11(pi,:) = NaN_Interp1_Elimination(plot_var_11(pi,:));
    plot_var_12(pi,:) = NaN_Interp1_Elimination(plot_var_12(pi,:));
    
end

%% Smoothing plotting variables:

% Temporal smoothing:

for pi = 1:length(p_level_11)
    plot_var_11(pi,:) = smooth(plot_var_11(pi,:),9);
    plot_var_12(pi,:) = smooth(plot_var_12(pi,:),9);
end

plot_var_1pbl = smooth(plot_var_1pbl,5);
plot_var_1fre = smooth(plot_var_1fre,5);

% Vertical smoothing:

for ti = 1:length(date_range)
    plot_var_11(:,ti) = smooth(plot_var_11(:,ti),5);
    plot_var_12(:,ti) = smooth(plot_var_12(:,ti),5);
end

% ==============================================================================

%% Make the plot:

close all;

gf1 = gcf;
gf1.WindowState = 'maximized';

%% 1-1

[f11,f11h] = contourf([1:size(date_arr,1)],p_level_11,plot_var_11,24,'LineStyle','none');

% f11 = pcolor([1:size(date_arr,1)],p_level_11,plot_var_11);
% set(f11,'LineStyle','none')

caxis([45,105])

%% 1. Set colorbar:

CT = brewermap(14,'Greens');
CT = [1,1,1;CT(1:11,:)];
colormap(CT)
cb = colorbar;
set(cb,'YTick',[50:10:100])
set(cb,'TickDirection','out')

hold on;

%% 1-2

[f121,f121h] = contour([1:size(date_arr,1)],p_level_11,plot_var_12);
set(f121h,'LineColor',[0.3,0.3,0.3],'LineStyle','-','LineWidth',0.6);
set(f121h,'LevelList',[1.0,2.0]);
set(f121h,'TextList',[])
% clabel(f121,f121h,'FontSize',10);

hold on;

[f122,f122h] = contour([1:size(date_arr,1)],p_level_11,plot_var_12);
set(f122h,'LineColor',[0.3,0.3,0.3],'LineStyle','--','LineWidth',0.6);
set(f122h,'LevelList',[-1.0,-2.0]);
set(f122h,'TextList',[])
% clabel(f122,f122h,'FontSize',10);

hold on;

%% 1-3

% f1pbl = plot(plot_var_1pbl);
% set(f1pbl,'Color',[0,0.447,0.741],'LineWidth',1.5,'LineStyle','--');
% 
% hold on

%% 1-4

% f1fre = plot(plot_var_1fre);
% set(f1fre,'Color','k','LineWidth',1.5,'LineStyle',':');
% 
% hold on;

%% 1-5

% switch plot_IOP_period
%     case 1
%         for plti = 1:size(IOP_id,1);
%             
%             f1IOP= line([IOP_id(plti,1),IOP_id(plti,end)],[90,90]);
%             
%             f1IOP.Color = [0.83,0,0];
%             f1IOP.LineWidth = 5;
%             
%         end
% end

% ==============================================================================

%% 1. Set axes: Axis 1:

axfont = 24;

ax11 = gca;

set(ax11,'Box','off','Color','none')
set(ax11,'PlotBoxAspectRatio',[2.5,1,1])
set(ax11,'Position',[0.12,0.2,0.7,0.6])
set(ax11,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold','LineWidth',1.0,'TickDir','out')
set(ax11,'Xlim',[1,size(date_arr,1)])
set(ax11,'XTick',date_xtick)
set(ax11,'XTickLabel',date_xtick_lab)
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[90,1020])
set(ax11,'YScale','log')
set(ax11,'YTick',[100,150,200:100:1000])
set(ax11,'YTickLabel',{'100';'150';'200';'300';'400';'500';'600';'700';'800';'900';'1000'})
set(ax11,'YMinorTick','off')
set(ax11,'YDir','Reverse')

%% 1. Labels:
xlab = xlabel(['\bf{',year_no,' JJAS}']);
ylab = ylabel('\bf{P(hPa)}');

%% 1. Set axes: Axis 2:
ax12 = axes('Position',get(ax11,'Position'),'Box','off','Color','none','YTick',[]);

set(ax12,'PlotBoxAspectRatio',[2.5,1,1])
set(ax12,'TickLength',[0.0050,0.0250],'LineWidth',1.0,'TickDir','out')
set(ax12,'Xlim',ax11.XLim)
set(ax12,'XTick',[1:24/date_int:size(date_arr,1)])
set(ax12,'XTickLabel',[])
set(ax12,'Ylim',ax11.YLim)
set(ax12,'YScale','log')
set(ax12,'YMinorTick','off')
set(ax12,'YDir','Reverse')

%% 1. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',[2.5,1,1])
set(ax13,'LineWidth',1.0,'TickDir','out')
set(ax13,'Xlim',ax11.XLim);
set(ax13,'Ylim',ax11.YLim)
set(ax13,'YScale','log')
set(ax13,'YMinorTick','off')
set(ax13,'YDir','Reverse')

% Link axes in case of zooming and set original axis as active:
linkaxes([ax11,ax12,ax13])
axes(ax11)

% Get the actual axes position:
ax11_pos = plotboxpos(ax11);

% ==============================================================================

%% 1. Title:
% tit = title(['Time Series of ',plot_var_name1,' ',plot_var_unit1,' at Gan']);
% set(tit,'Position',get(tit,'Position')-[0,5,0])
% set(tit,'FontName','Helvetica','FontSize',8,'FontWeight','bold')

%% 1. Legends:

% leg_1 = legend([f1fre,f1pbl],{'0^\circC Level','BL Height'});
% leg_1.Position(1) = 0.65;
% leg_1.Position(2) = 0.1;
% set(leg_1,'LineWidth',0.5)
% set(leg_1,'FontName','Helvetica','FontSize',10,'FontWeight','bold')
% set(leg_1,'Box','off')
% % set(leg1,'Location','SouthEastOutside')

%% 1. Change the size(width) of colorbar.

axpos = get(ax11,'Position');
cpos = get(cb,'Position');
cpos(1) = 0.85;
cpos(3) = 0.5*cpos(3);
cpos(4) = 0.7*cpos(4);
cpos(2) = 0.5-0.5.*cpos(4);
set(cb,'Position',cpos)
set(gca,'Position',axpos)

%% 1. Colorbar unit:

cbu_axis = axes('Position',[cb.Position(1),cb.Position(2),cb.Position(3),cb.Position(4)], ...
                'XLim',[0,1],'YLim',[0,1], ...
                'visible','off');
cbu = text(1.5,-0.1,plot_var_unit_1);
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')


% ==============================================================================

%% Saving Figure:
set(gcf,'Color',[1,1,1]);

figname = ['46692_',plot_var_name_1,'_',plot_var_name_2,'_timeseries_',date_arr(1,:),'-',date_arr(end,:)];

% print(gcf,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

% ==============================================================================

%% Display runnung time.
time_cost = toc;
disp(time_cost);

% ==============================================================================
