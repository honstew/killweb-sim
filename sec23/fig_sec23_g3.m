function fig = fig_sec23_g3(P, R)
%FIG_SEC23_G3 大规模算例的分配结果（M=24, T=40）
%
%   左：拍卖算法给出的 0-1 分配矩阵；
%   中：各目标的期望存活概率（拍卖 vs 贪婪）；
%   右：按目标类别汇总的期望被毁伤价值。
inst = R.wtaBig.inst;
xtA = R.wtaBig.xtA; xtG = R.wtaBig.xtG;
M = inst.M; T = inst.T;
X = zeros(M, T);
for i = 1:M
    if xtA(i) > 0
        X(i, xtA(i)) = 1;
    end
end
LA = prod((1 - inst.p) .^ X, 1);
XG = zeros(M, T);
for i = 1:M
    if xtG(i) > 0
        XG(i, xtG(i)) = 1;
    end
end
LG = prod((1 - inst.p) .^ XG, 1);

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 18.5 8.2]);
tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl);
imagesc(ax1, X); colormap(ax1, flipud(gray(2)));
xlabel(ax1, '目标序号 j'); ylabel(ax1, '火力通道 i');
title(ax1, '(a) 拍卖算法的分配矩阵', 'FontWeight', 'normal', 'FontSize', 10);
set(ax1, 'YDir', 'normal');

ax2 = nexttile(tl); hold(ax2, 'on'); box(ax2, 'on');
[~, ord] = sort(inst.V, 'descend');
dA = inst.V(ord)' .* (1 - LA(ord));
dG = inst.V(ord)' .* (1 - LG(ord));
cA = cumsum(dA) / sum(inst.V);
cG = cumsum(dG) / sum(inst.V);
plot(ax2, 1:T, cA, '-', 'LineWidth', 1.6);
plot(ax2, 1:T, cG, '--', 'LineWidth', 1.4);
xlabel(ax2, '目标序号（按价值降序）');
ylabel(ax2, '累计毁伤价值占比');
legend(ax2, {'拍卖算法', '贪婪算法'}, 'Location', 'southeast');
ylim(ax2, [0 1.05]); xlim(ax2, [1 T]);
title(ax2, '(b) 高价值目标的累计毁伤占比', 'FontWeight', 'normal', 'FontSize', 10);
grid(ax2, 'on'); set(ax2, 'GridAlpha', 0.12);

ax3 = nexttile(tl); hold(ax3, 'on'); box(ax3, 'on');
cls = [1 2 3];
names = {'有人指挥', 'CCA', '诱饵/ALE'};
vA = zeros(1, 3); vG = zeros(1, 3);
for k = 1:3
    sel = (inst.type == cls(k));
    vA(k) = sum(inst.V(sel)' .* (1 - LA(sel)));
    vG(k) = sum(inst.V(sel)' .* (1 - LG(sel)));
end
bar(ax3, [vA; vG]', 'grouped');
set(ax3, 'XTickLabel', names);
ylabel(ax3, '期望被毁伤价值');
legend(ax3, {'拍卖算法', '贪婪算法'}, 'Location', 'northwest');
title(ax3, '(c) 按节点类别的毁伤价值', 'FontWeight', 'normal', 'FontSize', 10);
ylim(ax3, [0 max([vA vG]) * 1.18]);

save_fig(fig, 'fig23_G3_assignment');
end
