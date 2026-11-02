function fpath = save_fig(fig, name, dpi)
%SAVE_FIG 同时导出 300 dpi PNG 与矢量 PDF 到 out/figs/
if nargin < 3 || isempty(dpi)
    dpi = 300;
end
d = fullfile(proj_root(), 'out', 'figs');
if ~exist(d, 'dir')
    mkdir(d);
end
set_fig_style(fig);
drawnow;
pngPath = fullfile(d, [name '.png']);
pdfPath = fullfile(d, [name '.pdf']);
exportgraphics(fig, pngPath, 'Resolution', dpi);
exportgraphics(fig, pdfPath, 'ContentType', 'vector');
fpath = pngPath;
end
