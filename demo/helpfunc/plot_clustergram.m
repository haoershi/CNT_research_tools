function plot_clustergram(data, level)
global paths params

blue = params.darkCols(1,:);red = params.darkCols(2,:); white = [1,1,1]; 
colors = [blue;white;red];
positions = [0, 0.5, 1];
mycolormap = interp1(positions, colors, linspace(0, 1, 256), 'pchip');
t.Colormap = colormap(mycolormap);
t.ColumnLabels = params.shortList;
t.RowLabels = params.shortList;
t.ColumnLabelsRotate = 45;
fig1 = clustergram(data);
set(fig1,t);
addTitle(fig1,'Global Connectivity Measure Grouped');
f = plot(fig1);
% added
columnLabels = fig1.ColumnLabels;
t.ColumnLabels = {};
t.RowLabels = {};
set(fig1,t);
f.Children.CData(logical(triu(ones(params.nMethod,params.nMethod),1))) = 0;
for i = 1:params.nMethod
    text(f,i+1, i, columnLabels{i}, 'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle','FontName','Calibri');
end
set(f,'XColor','none');
set(f,'YColor','none');
% end of added code
set(gcf,'Position',[1,1,850,1000]);
exportgraphics(gcf, strcat(paths.figPath,filesep,level,'GroupUT.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,level,'GroupUT.svg'))
close all force