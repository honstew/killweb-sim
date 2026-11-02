function fig = fig_sec23_g2(P, R)
%FIG_SEC23_G2 WTA 解空间规模 O(M^T) 的“计算爆炸”
%
%   纵轴为候选分配数 M^T 的以 10 为底的对数（直接画对数，避免 10^400 溢出）；
%   阴影区标出传统编队（10~20 个节点）与马赛克编队（100~300 个节点）的
%   典型规模；水平线 log10 = 9 对应 1 s 内可枚举的上限（按 1e9 次/s 假设）。
Tlist = 5:5:300;
Mset = [8 12 24];
cols = lines(numel(Mset));
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 14.5 10.2]);
hold on; box on;

xr = [10 20 100 300];
yl = [0 460];
patch([xr(1) xr(2) xr(2) xr(1)], [yl(1) yl(1) yl(2) yl(2)], [0.85 0.92 0.98], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.6);
patch([xr(3) xr(4) xr(4) xr(3)], [yl(1) yl(1) yl(2) yl(2)], [0.98 0.90 0.85], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.6);
text(15, 300, '传统编队', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Rotation', 90);
text(200, 430, '马赛克编队 100~300', 'HorizontalAlignment', 'center', 'FontSize', 8);

h = gobjects(numel(Mset), 1);
for k = 1:numel(Mset)
    h(k) = plot(Tlist, Tlist * log10(Mset(k)), '-', 'LineWidth', 1.8, 'Color', cols(k, :));
end
yline(9, '--', 'Color', [0.80 0.20 0.15], 'LineWidth', 1.2);
text(8, 22, '10^9 次/s 的 1 秒枚举上限', 'FontSize', 8, 'Color', [0.80 0.20 0.15]);

ylim(yl); xlim([5 300]);
xlabel('来袭节点数 T');
ylabel('解空间规模（以 10 为底的对数）');
legend(h, arrayfun(@(m) sprintf('M = %d 个火力通道', m), Mset, 'UniformOutput', false), ...
    'Location', 'southeast');
grid on; set(gca, 'GridAlpha', 0.12);
title('目标数量膨胀把可多项式求解的指派问题推回指数规模', ...
    'FontWeight', 'normal', 'FontSize', 10);

save_fig(fig, 'fig23_G2_complexity');
end
