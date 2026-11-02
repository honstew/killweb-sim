function [fig, key] = fig_sec22_f4(P)
%FIG_SEC22_F4 期望可用杀伤路径数随 eta 的变化与 eta = 1/N 拐点（式 eq:eta_crit）
eta = P.eta_grid;
[E, crit] = expected_paths(P.NS, P.NC, P.NE, P.q, eta);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 14.5 10.2]);
hold on; box on;
h1 = semilogy(eta, E.linear .* ones(size(eta)), '--', 'LineWidth', 1.6);
h2 = semilogy(eta, E.web, '-', 'LineWidth', 1.9);
h3 = xline(crit.etaPath, '-.', 'Color', [0.45 0.35 0.10], 'LineWidth', 1.2);
plot(crit.etaPath, E.linear(1), 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0.45 0.35 0.10]);
text(crit.etaPath + 0.03, E.linear(1) * 3.2, ...
    sprintf('\\eta = 1/N = %.2f 处交叉', crit.etaPath), 'FontSize', 8.5, 'Color', [0.45 0.35 0.10]);

% 论文 5.3 节给出的反例：eta = 0.15 时 0.35 条 < 0.625 条
e15 = 0.15;
w15 = expected_paths(P.NS, P.NC, P.NE, P.q, e15);
plot(e15, w15.web, 'v', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.2);
text(e15 + 0.02, w15.web * 0.55, sprintf('\\eta=0.15: %.2f 条 < %.3f 条', w15.web, w15.linear), ...
    'FontSize', 8, 'HorizontalAlignment', 'left');

set(gca, 'YScale', 'log', 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim([1e-2 1e3]); xlim([0 1]);
xlabel('单跳链路连通系数 \eta');
ylabel('期望可用杀伤路径数 E[L]');
legend([h1 h2], {sprintf('线性杀伤链：N(1-q)^3 = %.3f', E.linear(1)), ...
    '动态杀伤网：\eta^2 N^3 (1-q)^3'}, 'Location', 'northwest');
grid on; set(gca, 'GridAlpha', 0.15);
title('期望路径数的 \eta 拐点（N = 5, q = 0.5）', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig22_F4_expected_paths');
key = struct('etaPath', crit.etaPath, 'Elin', E.linear(1), ...
    'Eweb09', expected_paths(P.NS, P.NC, P.NE, P.q, 0.9).web);
end
