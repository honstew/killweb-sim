function [fig, key] = fig_sec22_f3(P)
%FIG_SEC22_F3 崩溃概率随链路连通系数 eta 的变化与两个判据交叉点
%
%   水平虚线为线性杀伤链的 51.29%（与 eta 无关）。
%   竖线给出 eta = 1/N = 0.2（期望路径拐点）与数值交叉点 eta_fail。
eta = P.eta_grid;
pLin = pfail_linear(P.NS, P.q);
w = arrayfun(@(e) pfail_web_exact(P.NS, P.NC, P.NE, P.q, e), eta);
crit = eta_crossover(P.NS, P.NC, P.NE, P.q);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 14.5 10.2]);
hold on; box on;
h1 = semilogy(eta, w, '-', 'LineWidth', 1.9);
h2 = semilogy(eta([1 end]), pLin * [1 1], '--', 'LineWidth', 1.6);
h3 = xline(crit.etaPath, '-.', 'Color', [0.45 0.35 0.10], 'LineWidth', 1.2);
if ~isnan(crit.etaFail)
    xline(crit.etaFail, ':', 'Color', [0.80 0.20 0.15], 'LineWidth', 1.4);
    semilogy(crit.etaFail, pLin, 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0.80 0.20 0.15]);
    text(crit.etaFail + 0.012, pLin * 1.45, sprintf('\\eta_{fail}\\approx%.2f', crit.etaFail), ...
        'FontSize', 8.5, 'HorizontalAlignment', 'left', 'Color', [0.80 0.20 0.15]);
end
text(crit.etaPath + 0.015, 0.0035, sprintf('\\eta = 1/N = %.2f', crit.etaPath), ...
    'FontSize', 8.5, 'Color', [0.45 0.35 0.10]);

% 标注 5.3 节三个点位
for e = [0.5 0.3 0.2]
    v = pfail_web_exact(P.NS, P.NC, P.NE, P.q, e);
    plot(e, v, 'o', 'MarkerSize', 5.5, 'MarkerFaceColor', 'w', 'LineWidth', 1.2);
end
text(0.60, 0.0013, {sprintf('\\eta=0.5：%.1f%%', 100*pfail_web_exact(P.NS,P.NC,P.NE,P.q,0.5)), ...
    sprintf('\\eta=0.3：%.1f%%', 100*pfail_web_exact(P.NS,P.NC,P.NE,P.q,0.3)), ...
    sprintf('\\eta=0.2：%.1f%%', 100*pfail_web_exact(P.NS,P.NC,P.NE,P.q,0.2))}, ...
    'FontSize', 8.5, 'VerticalAlignment', 'bottom', ...
    'BackgroundColor', [1 1 1 0.85], 'EdgeColor', [0.6 0.6 0.6], 'Margin', 3);

set(gca, 'YScale', 'log', 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim([1e-3 1.3]); xlim([0 1]);
xlabel('单跳链路连通系数 \eta');
ylabel('体系完全崩溃概率 P_{fail}');
legend([h1 h2], {'动态杀伤网（精确枚举）', sprintf('线性杀伤链 = %.2f%%', 100*pLin)}, ...
    'Location', 'northeast');
grid on; set(gca, 'GridAlpha', 0.15);
title('N = 5, q = 0.5：崩溃概率的 \eta 交叉点', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig22_F3_pfail_vs_eta');
key = struct('etaPath', crit.etaPath, 'etaFail', crit.etaFail, 'pLin', pLin);
end
