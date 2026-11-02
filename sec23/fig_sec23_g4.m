function fig = fig_sec23_g4(P, R)
%FIG_SEC23_G4 拍卖算法的 eps 互补松弛：解的次优性与迭代代价
%
%   左：加性目标的 gap = OPT - obj 随 eps 的变化，与 n*eps、T*eps 界对照；
%   右：迭代轮数与净收益比较次数随 eps 的变化。
%   实例取 M=6、T=8、m_j 含重复拦截（m_1 = 2）的算例，
%   其加性最优由运输问题 LP 精确给出（wta_additive_opt）。
sm = R.wtaSmall.sm2;
a = sm.V(:)' .* sm.p;
foptA = wta_additive_opt(a, sm.mj);
epsList = [2 1 0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001];
gap = zeros(size(epsList)); rounds = zeros(size(epsList)); comps = zeros(size(epsList));
for k = 1:numel(epsList)
    [~, info] = auction_assign(a, sm.mj, epsList(k), 200000);
    gap(k) = max(foptA - info.addObj, 0);
    rounds(k) = info.rounds;
    comps(k) = info.comps;
end

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 17.0 8.4]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
xt = [0.001 0.01 0.1 1 2];   % 必须单调递增（log 轴的 XTick 校验）

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
h1 = loglog(ax1, epsList, max(gap, 1e-3), 'o-', 'LineWidth', 1.5, 'MarkerSize', 4);
h2 = loglog(ax1, epsList, sm.M * epsList, '--', 'LineWidth', 1.2);
h3 = loglog(ax1, epsList, numel(sm.mj) * epsList, ':', 'LineWidth', 1.2);
set(ax1, 'XScale', 'log', 'YScale', 'log', 'XDir', 'reverse', 'XTick', xt);
xlabel(ax1, '价格增量 ε');
ylabel(ax1, '次优性 gap = OPT − Σ a_{ij}x_{ij}');
legend(ax1, [h1 h2 h3], {'实测 gap', 'M·ε 界', 'T·ε 界'}, 'Location', 'southwest');
title(ax1, '(a) ε-互补松弛给出的次优性界', 'FontWeight', 'normal', 'FontSize', 10);
grid(ax1, 'on'); set(ax1, 'GridAlpha', 0.12, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim(ax1, [3e-4 30]);
text(ax1, 0.02, 1.3e-3, 'gap = 0（已对齐到绘图下限）', 'FontSize', 7.5);

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
yyaxis(ax2, 'left');
semilogx(ax2, epsList, rounds, 'o-', 'LineWidth', 1.5, 'MarkerSize', 4);
ylabel(ax2, '拍卖迭代轮数');
yyaxis(ax2, 'right');
semilogx(ax2, epsList, comps / 1000, 's--', 'LineWidth', 1.2, 'MarkerSize', 4);
ylabel(ax2, '比较次数 / 10^3');
set(ax2, 'XScale', 'log', 'XDir', 'reverse', 'XTick', xt);
xlabel(ax2, '价格增量 ε');
title(ax2, '(b) 迭代代价随 ε 减小而上升', 'FontWeight', 'normal', 'FontSize', 10);
grid(ax2, 'on'); set(ax2, 'GridAlpha', 0.12, 'YMinorGrid', 'off', 'XMinorGrid', 'off');

save_fig(fig, 'fig23_G4_auction');
end
