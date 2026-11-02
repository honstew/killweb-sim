function fig = fig_sec22_f6(P, mc1, mc09)
%FIG_SEC22_F6 蒙特卡洛收敛性与精确枚举的一致性（40 万次抽样）
%
%   左：运行均值随抽样次数的收敛，含 +/-2 sigma 包络；
%   右：最终估计值与精确枚举值、论文所列值的对比。
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 17.0 8.0]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
n = (1:mc1.trials);
h1 = semilogx(ax1, n, 100 * mc1.cumP, '-', 'LineWidth', 1.2);
h2 = semilogx(ax1, n, 100 * mc09.cumP, '-', 'LineWidth', 1.2);
% +/- 2 sigma 包络（用精确值算理论标准差）
e1 = pfail_web_exact(P.NS, P.NC, P.NE, P.q, 1.0);
e9 = pfail_web_exact(P.NS, P.NC, P.NE, P.q, 0.9);
hEnv = gobjects(2, 1);
for k = 1:2
    if k == 1, mu = e1; mk = '-'; else, mu = e9; mk = '--'; end
    sd = sqrt(mu * (1 - mu) ./ n);
    hEnv(2*k-1) = semilogx(ax1, n, 100 * (mu + 2*sd), mk, 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8);
    hEnv(2*k)   = semilogx(ax1, n, 100 * (mu - 2*sd), mk, 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8);
end
yline(ax1, 100 * e1, ':', 'Color', [0.00 0.55 0.55], 'LineWidth', 1.0);
yline(ax1, 100 * e9, ':', 'Color', [0.80 0.20 0.15], 'LineWidth', 1.0);
xlabel(ax1, '抽样次数'); ylabel(ax1, '崩溃概率运行均值 / %');
ylim(ax1, [0 15]); set(ax1, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
legend(ax1, [h1 h2 hEnv(1)], {'\eta = 1 抽样均值', '\eta = 0.9 抽样均值', '±2\sigma 包络'}, ...
    'Location', 'northeast');
title(ax1, '(a) 运行均值收敛（±2\sigma 包络）', 'FontWeight', 'normal', 'FontSize', 10);

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
vals = [100*e1, 100*mc1.P; 100*e9, 100*mc09.P];
b = bar(ax2, vals, 'grouped');
set(b(1), 'FaceColor', [0.00 0.45 0.55]); set(b(2), 'FaceColor', [0.85 0.55 0.20]);
xticks(ax2, 1:2); xticklabels(ax2, {'\eta = 1.0', '\eta = 0.9'});
ylabel(ax2, '崩溃概率 / %');
ylim(ax2, [0 14]);
sd2 = [1.96*100*sqrt(mc1.P*(1-mc1.P)/mc1.trials); 1.96*100*sqrt(mc09.P*(1-mc09.P)/mc09.trials)];
errorbar(ax2, 1 + 0.15, vals(1, 2), sd2(1), 'k.', 'LineWidth', 0.9);
errorbar(ax2, 2 + 0.15, vals(2, 2), sd2(2), 'k.', 'LineWidth', 0.9);
for i = 1:2
    text(ax2, i - 0.15, vals(i, 1) + 0.35, sprintf('%.2f%%', vals(i, 1)), ...
        'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0 0.25 0.35]);
    text(ax2, i + 0.15, vals(i, 2) + 0.35, sprintf('%.2f%%', vals(i, 2)), ...
        'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0.55 0.30 0.05]);
end
legend(ax2, {'精确枚举', sprintf('蒙特卡洛（%d 次）', mc1.trials)}, 'Location', 'northeast');
title(ax2, '(b) 抽样估计与精确枚举一致', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig22_F6_monte_carlo');
end
