function [fig, key] = fig_sec22_f5(P)
%FIG_SEC22_F5 崩溃概率随编队规模 N 的衰减（q = 0.5）
%
%   线性架构的崩溃概率按 (1-p^3)^N 衰减（底数 0.875），
%   网状架构按 1-(1-q^N)^3 衰减（底数 q = 0.5），二者随 N 拉开的倍数持续放大。
N = P.N_grid;
lin  = pfail_linear(N, P.q);
w100 = 1 - (1 - P.q .^ N) .^ 3;
w090 = arrayfun(@(n) pfail_web_exact(n, n, n, P.q, 0.9), N);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 14.5 10.2]);
hold on; box on;
h1 = semilogy(N, lin,  '-', 'LineWidth', 1.9);
h2 = semilogy(N, w100, '--', 'LineWidth', 1.6);
h3 = semilogy(N, w090, ':', 'LineWidth', 1.9);
i5 = find(N == 5, 1);
plot(N(i5), lin(i5), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.2);
plot(N(i5), w100(i5), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.2);
text(N(i5) + 0.3, lin(i5) * 1.35, sprintf('N=5: %.2f%%', 100*lin(i5)), 'FontSize', 8.5);
text(N(i5) + 0.3, w100(i5) * 1.6, sprintf('N=5: %.2f%%', 100*w100(i5)), 'FontSize', 8.5);

set(gca, 'YScale', 'log', 'XTick', 1:2:19, 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim([1e-6 1.2]); xlim([1 20]);
xlabel('每类节点数 N（三种节点各 N 个）');
ylabel('体系完全崩溃概率 P_{fail}');
legend([h1 h2 h3], {'线性杀伤链 (1-(1-q)^3)^N', ...
    '动态杀伤网 \eta = 1', '动态杀伤网 \eta = 0.9'}, 'Location', 'southwest');
grid on; set(gca, 'GridAlpha', 0.15);
title('q = 0.5 时崩溃概率随编队规模的衰减', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig22_F5_pfail_vs_N');
key = struct('lin5', lin(N == 5), 'web5', w100(N == 5));
end
