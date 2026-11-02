function fig = fig_sec22_f1()
%FIG_SEC22_F1 拓扑对比图（对应论文图 2-2：同等 33.3% 战损下的生存力）
[fig, cnt] = draw_killweb();
fprintf('  [F1] 线性剩余链 %d 条，网状剩余路径 %d 条，节点损失率 %.1f%%\n', ...
    cnt.linearPaths, cnt.webPaths, 100 * cnt.lossRatio);
save_fig(fig, 'fig22_F1_topology');
end
