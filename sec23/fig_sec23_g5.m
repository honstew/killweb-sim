function fig = fig_sec23_g5(P, R)
%FIG_SEC23_G5 成本交换比（单次交战口径）
%
%   左：三类蓝方节点被拦截时的单价交换比（蓝:红）随拦截弹单价的变化；
%   右：弹匣级交换——40 个可消耗节点耗尽一个远程防空营 32 发待发弹。
C = R.cost;
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 16.0 8.0]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl); hold(ax1, 'on'); box(ax1, 'on');
semilogy(ax1, C.intCost, C.ratioManned, '-', 'LineWidth', 1.9);
semilogy(ax1, C.intCost, C.ratioDecoy, '-', 'LineWidth', 1.9);
semilogy(ax1, C.intCost, C.ratioALE, '-', 'LineWidth', 1.9);
yline(ax1, 1, '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1.1);
text(ax1, mean(C.intCost), 3.2, '成本均势线 1:1', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', [0.35 0.35 0.35]);
xlabel(ax1, '红方远程拦截弹单价 / 万美元');
ylabel(ax1, '蓝 : 红 单价交换比');
legend(ax1, {sprintf('有人机 %.0f 万美元', P.cost.manned), ...
    sprintf('MALD-X %.0f 万美元', C.magazine.decoyC), ...
    sprintf('ALE %.0f 万美元', C.magazine.aleC)}, 'Location', 'northeast');
title(ax1, '(a) 被拦截节点单价决定成本天平', 'FontWeight', 'normal', 'FontSize', 10);
grid(ax1, 'on'); set(ax1, 'GridAlpha', 0.12);

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
b = barh(ax2, [C.magazine.blueCost C.magazine.redCost], 0.45, 'FaceColor', 'flat');
b.CData(1, :) = [0.00 0.45 0.55];
b.CData(2, :) = [0.80 0.20 0.15];
yticks(ax2, [1 2]);
yticklabels(ax2, {sprintf('蓝方 %d 节点', C.magazine.nBlue), ...
    sprintf('红方 %d 发弹', C.magazine.nRed)});
xlabel(ax2, '成本 / 万美元');
xlim(ax2, [0 C.magazine.redCost * 1.22]);
text(ax2, C.magazine.blueCost * 1.03, 1, sprintf('%.0f', C.magazine.blueCost), ...
    'HorizontalAlignment', 'left', 'FontSize', 8.5, 'Color', [0.10 0.25 0.35]);
text(ax2, C.magazine.redCost * 1.03, 2, sprintf('%.0f', C.magazine.redCost), ...
    'HorizontalAlignment', 'left', 'FontSize', 8.5, 'Color', [0.55 0.10 0.10]);
title(ax2, sprintf('(b) 弹匣级交换比 = %.3f : 1', C.magazine.ratio), ...
    'FontWeight', 'normal', 'FontSize', 10);
grid(ax2, 'on'); set(ax2, 'GridAlpha', 0.12);

save_fig(fig, 'fig23_G5_cost');
end
