function fig = fig_sec23_g1(P, R)
%FIG_SEC23_G1 兰彻斯特平方律的诱饵稀释效应
%
%   左：传统架构（alpha_R）与马赛克架构（alpha_R^eff）下的 B(t)、R(t)；
%   右：有人机战损率降幅随诱骗逼真度 kappa 的变化，标注论文 83%~87% 带。
F = P.force;
S1 = R.lan.S1; S2 = R.lan.S2;

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 17.0 8.0]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
plot(ax1, S1.t, S1.B, '-', 'LineWidth', 1.9);
plot(ax1, S1.t, S1.R, '-', 'LineWidth', 1.9);
plot(ax1, S2.t, S2.B, '--', 'LineWidth', 1.9);
plot(ax1, S2.t, S2.R, '--', 'LineWidth', 1.9);
xlabel(ax1, '交战时间 t / min'); ylabel(ax1, '作战单元数量');
legend(ax1, {'蓝方 B (传统)', '红方 R (传统)', ...
    '蓝方 B (马赛克)', '红方 R (马赛克)'}, 'Location', 'best');
title(ax1, '(a) 诱饵稀释后的兵力损耗轨迹', 'FontWeight', 'normal', 'FontSize', 10);
ylim(ax1, [0 max([S1.B0, S1.R0]) * 1.05]);

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
kappa = P.force.kappa_grid;
red = 1 - alpha_effective(P.lan.alphaR, F.B_manned, F.B_CCA, F.B_decoy, kappa, kappa) / P.lan.alphaR;
plot(ax2, kappa, 100 * red, '-', 'LineWidth', 1.9);
yline(ax2, 100 * P.force.loss_reduction_target(1), '--', 'Color', [0.45 0.45 0.45]);
yline(ax2, 100 * P.force.loss_reduction_target(2), '--', 'Color', [0.45 0.45 0.45]);
plot(ax2, F.kappa1, 100*(1 - R.dilution), 'o', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'LineWidth', 1.4);
text(ax2, 0.02, 96, '论文区间 83%~87%', 'FontSize', 8);
xlabel(ax2, '诱骗/无人节点特征逼真度 \kappa_1=\kappa_2=\kappa');
ylabel(ax2, '有人机战损率降幅 / %');
ylim(ax2, [0 100]); xlim(ax2, [0 1]);
title(ax2, '(b) 战损率降幅对逼真度的敏感性', 'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig23_G1_lanchester');
end
