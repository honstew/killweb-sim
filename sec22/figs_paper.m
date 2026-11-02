function figs_paper(P)
%FIGS_PAPER 生成论文正文用的跨栏双联图（面板宽约 7.4 cm，字号按最终尺寸设定）
%
%   论文中两幅半栏图若各缩到 0.48\textwidth，字号会从 9 pt 压到 4.5 pt。
%   这里按最终物理尺寸（15.5 cm x 6.8 cm）重画，两幅各占一半，字号 8 pt。
%
%   输出到 out/figs/：
%     paper_fig22_pfail.png   崩溃概率对 q 与 eta 的敏感性
%     paper_fig23_wta.png     解空间规模与拍卖 eps-CS 收敛
if nargin < 1 || isempty(P)
    P = paper_params();
end
outdir = fullfile(proj_root(), 'out', 'figs');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

%% ---------- 图 A：崩溃概率敏感性 ----------
q = linspace(0.01, 0.99, 99);
lin  = pfail_linear(P.NS, q);
w100 = pfail_web_exact(P.NS, P.NC, P.NE, q, 1.00);
w090 = pfail_web_exact(P.NS, P.NC, P.NE, q, 0.90);
w050 = pfail_web_exact(P.NS, P.NC, P.NE, q, 0.50);

eta = linspace(0.02, 1, 99);
pLin = pfail_linear(P.NS, P.q);
we = arrayfun(@(e) pfail_web_exact(P.NS, P.NC, P.NE, P.q, e), eta);
crit = eta_crossover(P.NS, P.NC, P.NE, P.q);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 15.5 6.9]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
h1 = semilogy(ax1, q, lin, '-', 'LineWidth', 1.6);
h2 = semilogy(ax1, q, w100, '-', 'LineWidth', 1.4);
h3 = semilogy(ax1, q, w090, '--', 'LineWidth', 1.4);
h4 = semilogy(ax1, q, w050, ':', 'LineWidth', 1.6);
plot(ax1, P.q, pfail_linear(P.NS, P.q), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'w', 'LineWidth', 1.1);
xline(ax1, P.q, ':', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.7);
set(ax1, 'YScale', 'log', 'FontSize', 8, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim(ax1, [1e-4 1.2]); xlim(ax1, [0 1]);
xlabel(ax1, '单节点战损率 q', 'FontSize', 8);
ylabel(ax1, '崩溃概率 P_{fail}', 'FontSize', 8);
legend(ax1, [h1 h2 h3 h4], {'线性', '\eta=1', '\eta=0.9', '\eta=0.5'}, ...
    'Location', 'southeast', 'FontSize', 7, 'Box', 'off');
grid(ax1, 'on'); set(ax1, 'GridAlpha', 0.12);
title(ax1, '(a) 随 q 变化（N = 5）', 'FontWeight', 'normal', 'FontSize', 8);

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
h5 = semilogy(ax2, eta, we, '-', 'LineWidth', 1.6);
h6 = semilogy(ax2, eta([1 end]), pLin * [1 1], '--', 'LineWidth', 1.2, 'Color', [0.80 0.35 0.10]);
xline(ax2, crit.etaPath, '-.', 'Color', [0.45 0.35 0.10], 'LineWidth', 1.0);
xline(ax2, crit.etaFail, ':', 'Color', [0.80 0.20 0.15], 'LineWidth', 1.0);
plot(ax2, crit.etaFail, pLin, 'o', 'MarkerSize', 5, 'MarkerFaceColor', [0.80 0.20 0.15]);
text(ax2, crit.etaFail + 0.02, pLin * 1.55, sprintf('%.3f', crit.etaFail), ...
    'FontSize', 7, 'Color', [0.80 0.20 0.15]);
set(ax2, 'YScale', 'log', 'FontSize', 8, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim(ax2, [1e-3 1.3]); xlim(ax2, [0 1]);
xlabel(ax2, '链路连通系数 \eta', 'FontSize', 8);
ylabel(ax2, '崩溃概率 P_{fail}', 'FontSize', 8);
legend(ax2, [h5 h6], {'杀伤网', sprintf('线性 %.2f%%', 100*pLin)}, ...
    'Location', 'southwest', 'FontSize', 7, 'Box', 'off');
grid(ax2, 'on'); set(ax2, 'GridAlpha', 0.12);
title(ax2, '(b) 随 \eta 变化（q = 0.5）', 'FontWeight', 'normal', 'FontSize', 8);

exportgraphics(fig, fullfile(outdir, 'paper_fig22_pfail.png'), 'Resolution', 300);
exportgraphics(fig, fullfile(outdir, 'paper_fig22_pfail.pdf'), 'ContentType', 'vector');
close(fig);
fprintf('  [paper] paper_fig22_pfail.png  %.1f%% / %.3f\n', 100*pLin, crit.etaFail);

%% ---------- 图 B：WTA 规模与拍卖收敛 ----------
Tlist = 5:5:300;
Mset = [8 12 24];
cols = lines(numel(Mset));

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 15.5 6.9]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
patch(ax1, [10 20 20 10], [0 0 460 460], [0.85 0.92 0.98], 'EdgeColor', 'none');
patch(ax1, [100 300 300 100], [0 0 460 460], [0.98 0.90 0.85], 'EdgeColor', 'none');
h = gobjects(numel(Mset), 1);
for k = 1:numel(Mset)
    h(k) = plot(ax1, Tlist, Tlist * log10(Mset(k)), '-', 'LineWidth', 1.4, 'Color', cols(k, :));
end
yline(ax1, 9, '--', 'Color', [0.80 0.20 0.15], 'LineWidth', 0.9);
text(ax1, 15, 430, '传统', 'FontSize', 6.5, 'HorizontalAlignment', 'center');
text(ax1, 200, 430, '马赛克', 'FontSize', 6.5, 'HorizontalAlignment', 'center');
set(ax1, 'FontSize', 8, 'XTick', 0:50:300);
ylim(ax1, [0 460]); xlim(ax1, [5 300]);
xlabel(ax1, '来袭节点数 T', 'FontSize', 8);
ylabel(ax1, '解空间规模 log_{10}(M^T)', 'FontSize', 8);
legend(ax1, h, arrayfun(@(m) sprintf('M = %d', m), Mset, 'UniformOutput', false), ...
    'Location', 'southeast', 'FontSize', 7, 'Box', 'off');
grid(ax1, 'on'); set(ax1, 'GridAlpha', 0.12);
title(ax1, '(a) 候选分配规模', 'FontWeight', 'normal', 'FontSize', 8);

% (b) 拍卖 eps-CS
sm = wta_instance(P.wta.smallM, P.wta.smallT, P.wta.seed, P.wta.mj_max);
a = sm.V(:)' .* sm.p;
foptA = wta_additive_opt(a, sm.mj);
epsList = [2 1 0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001];
gap = zeros(size(epsList)); rounds = zeros(size(epsList));
for k = 1:numel(epsList)
    [~, info] = auction_assign(a, sm.mj, epsList(k), 200000);
    gap(k) = max(foptA - info.addObj, 0);
    rounds(k) = info.rounds;
end
ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
h1 = loglog(ax2, epsList, max(gap, 1e-3), 'o-', 'LineWidth', 1.3, 'MarkerSize', 3);
h2 = loglog(ax2, epsList, sm.M * epsList, '--', 'LineWidth', 1.0);
h3 = loglog(ax2, epsList, numel(sm.mj) * epsList, ':', 'LineWidth', 1.0);
set(ax2, 'XScale', 'log', 'YScale', 'log', 'XDir', 'reverse', ...
    'XTick', [0.001 0.01 0.1 1], 'FontSize', 8, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
xlabel(ax2, '价格增量 ε', 'FontSize', 8);
ylabel(ax2, '次优性 gap', 'FontSize', 8);
legend(ax2, [h1 h2 h3], {'实测', 'Mε', 'Tε'}, ...
    'Location', 'southwest', 'FontSize', 7, 'Box', 'off');
ylim(ax2, [3e-4 30]);
grid(ax2, 'on'); set(ax2, 'GridAlpha', 0.12);
title(ax2, '(b) ε-互补松弛', 'FontWeight', 'normal', 'FontSize', 8);

exportgraphics(fig, fullfile(outdir, 'paper_fig23_wta.png'), 'Resolution', 300);
exportgraphics(fig, fullfile(outdir, 'paper_fig23_wta.pdf'), 'ContentType', 'vector');
close(fig);
fprintf('  [paper] paper_fig23_wta.png\n');
end
