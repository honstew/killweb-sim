function set_fig_style(fig)
%SET_FIG_STYLE 统一图件风格：白底、中文字体、细边框、外向刻度
if nargin < 1 || isempty(fig)
    fig = gcf;
end
fn = 'Microsoft YaHei';
persistent fnCached
if isempty(fnCached)
    fns = listfonts;
    if ~any(strcmpi(fns, 'Microsoft YaHei'))
        if any(strcmpi(fns, 'SimHei'))
            fn = 'SimHei';
        else
            fn = 'SimSun';
        end
    end
    fnCached = fn;
else
    fn = fnCached;
end

set(fig, 'Color', 'w', 'InvertHardcopy', 'on');
axs = findall(fig, 'Type', 'axes');
set(axs, 'FontName', fn, 'FontSize', 9, 'LineWidth', 0.9, ...
    'Box', 'on', 'TickDir', 'out', 'TickLength', [0.012 0.012], ...
    'Layer', 'top', 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15]);
set(findall(fig, 'Type', 'text'), 'FontName', fn);
legs = findall(fig, 'Type', 'legend');
if ~isempty(legs)
    set(legs, 'FontName', fn, 'FontSize', 8, 'Box', 'off');
end
set(fig, 'DefaultAxesColorOrder', [ ...
    0.00 0.30 0.60; ...   % 深蓝：线性杀伤链
    0.00 0.55 0.55; ...   % 青：杀伤网
    0.80 0.20 0.15; ...   % 红：告警/失效
    0.45 0.45 0.45; ...   % 灰：参考线
    0.55 0.35 0.10; ...   % 棕
    0.30 0.30 0.70]);
end
