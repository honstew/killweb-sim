function [fig, cnt] = draw_killweb(killS, killC, killE)
%DRAW_KILLWEB 绘制线性杀伤链与动态杀伤网的拓扑对比（对应论文图 2-2）
%
%   [fig, cnt] = draw_killweb(killS, killC, killE)
%
%   输入（均可省略）：
%     killS, killC, killE : 1x3 逻辑向量，标记该类 3 个节点是否被击毁
%                           默认 [1 0 0]、[0 1 0]、[0 0 1]，即每类损失 1 个
%
%   输出：
%     fig : 图句柄
%     cnt : 结构体
%           .linearPaths 线性编组剩余有效链条数（每个连通三元组计 1）
%           .webPaths    网状编组剩余可重构路径数（|S_alive|·|C_alive|·|E_alive|）
%           .lossRatio   节点损失率
if nargin < 1 || isempty(killS), killS = [true false false]; end
if nargin < 2 || isempty(killC), killC = [false true false]; end
if nargin < 3 || isempty(killE), killE = [false false true]; end
killS = logical(killS(:)'); killC = logical(killC(:)'); killE = logical(killE(:)');

nS = sum(~killS); nC = sum(~killC); nE = sum(~killE);
cnt = struct();
cnt.linearPaths = 0;
for i = 1:3
    if ~killS(i) && ~killC(i) && ~killE(i)
        cnt.linearPaths = cnt.linearPaths + 1;
    end
end
cnt.webPaths   = nS * nC * nE;
cnt.lossRatio  = sum([killS killC killE]) / 9;

cBlue = [0.00 0.30 0.60];
cTeal = [0.00 0.55 0.55];
cRed  = [0.80 0.20 0.15];
cGray = [0.55 0.55 0.55];

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 17.5 8.2]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% ---------- 左：传统线性杀伤链 ----------
ax1 = nexttile(tl); hold(ax1, 'on'); axis(ax1, 'equal'); axis(ax1, 'off');
xS = 1.1; xC = 5.0; xE = 8.9; ys = [7.4 5.0 2.6];
for i = 1:3
    plot(ax1, [xS xC], [ys(i) ys(i)], '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.3);
    plot(ax1, [xC xE], [ys(i) ys(i)], '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.3);
end
for i = 1:3
    draw_node(ax1, xS, ys(i), 'o', cBlue, killS(i));
    draw_node(ax1, xC, ys(i), 'h', cTeal, killC(i));
    draw_node(ax1, xE, ys(i), 's', cRed,  killE(i));
    text(ax1, xS - 0.95, ys(i), sprintf('S_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cBlue);
    text(ax1, xC, ys(i) + 0.95, sprintf('C_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cTeal, 'FontWeight', 'bold');
    text(ax1, xE + 0.95, ys(i), sprintf('E_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cRed);
end
text(ax1, 5.0, 9.55, '(a) 传统线性杀伤链', 'FontSize', 11, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', cBlue);
text(ax1, 5.0, 9.0, '链路刚性绑定：单节点损毁即整链断裂', 'FontSize', 8.5, ...
    'HorizontalAlignment', 'center', 'Color', [0.35 0.35 0.35]);
text(ax1, 5.0, 0.85, {sprintf('损失 %d 个异构节点（%.1f%%）', ...
    sum([killS killC killE]), 100 * cnt.lossRatio), ...
    sprintf('\\Rightarrow 剩余有效杀伤链 = %d 条（体系崩溃）', cnt.linearPaths)}, ...
    'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'Color', cRed);
xlim(ax1, [-0.4 10.2]); ylim(ax1, [0.4 10.2]);

% ---------- 右：马赛克动态杀伤网 ----------
ax2 = nexttile(tl); hold(ax2, 'on'); axis(ax2, 'equal'); axis(ax2, 'off');
for i = 1:3
    for j = 1:3
        plot(ax2, [xS xC], [ys(i) ys(j)], '--', 'Color', [0.55 0.75 0.80], 'LineWidth', 0.6);
        plot(ax2, [xC xE], [ys(i) ys(j)], '--', 'Color', [0.55 0.75 0.80], 'LineWidth', 0.6);
    end
end
% 高亮一条仍可闭合的路径：S2 -> C1 -> E2
if ~killS(2) && ~killC(1) && ~killE(2)
    plot(ax2, [xS xC], [ys(2) ys(1)], '-', 'Color', [0.10 0.60 0.25], 'LineWidth', 2.4);
    plot(ax2, [xC xE], [ys(1) ys(2)], '-', 'Color', [0.10 0.60 0.25], 'LineWidth', 2.4);
end
for i = 1:3
    draw_node(ax2, xS, ys(i), 'o', cBlue, killS(i));
    draw_node(ax2, xC, ys(i), 'h', cTeal, killC(i));
    draw_node(ax2, xE, ys(i), 's', cRed,  killE(i));
    text(ax2, xS - 0.95, ys(i), sprintf('S_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cBlue);
    text(ax2, xC, ys(i) + 0.95, sprintf('C_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cTeal, 'FontWeight', 'bold');
    text(ax2, xE + 0.95, ys(i), sprintf('E_%d', i), 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'Color', cRed);
end
text(ax2, 5.0, 9.55, '(b) 马赛克动态杀伤网', 'FontSize', 11, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', cTeal);
text(ax2, 5.0, 9.0, '跨域解耦互操作：残存节点重组杀伤路径', 'FontSize', 8.5, ...
    'HorizontalAlignment', 'center', 'Color', [0.35 0.35 0.35]);
text(ax2, 5.0, 0.85, {'同等战损下仍可重组', ...
    sprintf('剩余可重构路径 = %d\\times%d\\times%d = %d 条', nS, nC, nE, cnt.webPaths)}, ...
    'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'Color', [0.10 0.50 0.20]);
xlim(ax2, [-0.4 10.2]); ylim(ax2, [0.4 10.2]);
end

function draw_node(ax, x, y, mk, col, killed)
if killed
    plot(ax, x, y, mk, 'MarkerSize', 13, 'MarkerFaceColor', [0.88 0.88 0.88], ...
        'MarkerEdgeColor', [0.55 0.55 0.55], 'LineWidth', 1.0);
    plot(ax, [x-0.42 x+0.42], [y-0.42 y+0.42], '-', 'Color', [0.80 0.20 0.15], 'LineWidth', 2.2);
    plot(ax, [x-0.42 x+0.42], [y+0.42 y-0.42], '-', 'Color', [0.80 0.20 0.15], 'LineWidth', 2.2);
else
    plot(ax, x, y, mk, 'MarkerSize', 13, 'MarkerFaceColor', col, ...
        'MarkerEdgeColor', col * 0.6, 'LineWidth', 1.0);
end
end
