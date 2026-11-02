function [fig, key] = fig_sec22_f2(P)
%FIG_SEC22_F2 体系崩溃概率随单节点战损率 q 的变化（4 条曲线）
%
%   线性杀伤链 vs 动态杀伤网（eta = 1, 0.9, 0.5），N = 5。
%   用于说明：同等 q 下并联冗余把“串联可靠性问题”转为“冗余度问题”。
q = P.q_grid;
lin  = pfail_linear(P.NS, q);
w100 = pfail_web_exact(P.NS, P.NC, P.NE, q, 1.00);
w090 = pfail_web_exact(P.NS, P.NC, P.NE, q, 0.90);
w050 = pfail_web_exact(P.NS, P.NC, P.NE, q, 0.50);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 14.5 10.2]);
hold on; box on;
h1 = semilogy(q, lin,  '-', 'LineWidth', 1.8);
h2 = semilogy(q, w100, '-', 'LineWidth', 1.6);
h3 = semilogy(q, w090, '--', 'LineWidth', 1.6);
h4 = semilogy(q, w050, ':', 'LineWidth', 1.8);

% 标注 q = 0.5 的四个取值
qs = P.q;
yl = [pfail_linear(P.NS, qs), pfail_web_exact(P.NS,P.NC,P.NE,qs,1.0), ...
      pfail_web_exact(P.NS,P.NC,P.NE,qs,0.9), pfail_web_exact(P.NS,P.NC,P.NE,qs,0.5)];
plot(qs, yl(1), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.4);
plot(qs, yl(2), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.4);
plot(qs, yl(3), 's', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.4);
plot(qs, yl(4), '^', 'MarkerSize', 6, 'MarkerFaceColor', 'w', 'LineWidth', 1.4);
xline(qs, ':', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.8);

set(gca, 'YScale', 'log', 'YMinorGrid', 'off', 'XMinorGrid', 'off');
ylim([1e-4 1.2]); xlim([0 1]);
xlabel('单节点战损率 q');
ylabel('体系完全崩溃概率 P_{fail}');
legend([h1 h2 h3 h4], {sprintf('线性杀伤链（%.2f%%）', 100*yl(1)), ...
    sprintf('动态杀伤网 \\eta = 1.0（%.2f%%）', 100*yl(2)), ...
    sprintf('动态杀伤网 \\eta = 0.9（%.2f%%）', 100*yl(3)), ...
    sprintf('动态杀伤网 \\eta = 0.5（%.1f%%）', 100*yl(4))}, ...
    'Location', 'southeast');
grid on; set(gca, 'GridAlpha', 0.15);
title('N = 5 对称编队下的崩溃概率对比', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig22_F2_pfail_vs_q');
key = struct('q', qs, 'lin', yl(1), 'web1', yl(2), 'web09', yl(3), 'web05', yl(4));
end
