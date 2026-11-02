function R = demo_sec23(P, doFigs)
%DEMO_SEC23 论文 2.3 节「制造认知过载与重构兰彻斯特方程」的算法实现与数值算例
%
%   计算内容（论文中的对应数值即由本脚本给出）：
%     1) 兰彻斯特平方律（式 eq:lanchester）与守恒量校验
%     2) 诱饵稀释后的有效杀伤率 alpha_R^eff（式 eq:alpha_eff）
%     3) WTA 的 0-1 整数规划（式 eq:wta_obj/eq:wta_con）：精确枚举、分支定界
%     4) m_j = 1 时退化为线性指派（匈牙利算法）的对照
%     5) 拍卖算法的 eps-CS 收敛性与轮数/比较次数
%     6) O(M^T) 计算爆炸
%     7) 单次交战口径的成本交换比
if nargin < 2
    doFigs = true;
end
F = P.force;
R = struct();
fprintf('\n===== 2.3 制造认知过载与重构兰彻斯特方程 =====\n');

%% ---------- 1) 兰彻斯特平方律 ----------
aReff = alpha_effective(P.lan.alphaR, F.B_manned, F.B_CCA, F.B_decoy, F.kappa1, F.kappa2);
S1 = lanchester_solve(P.lan.alphaB, P.lan.alphaR, P.lan.B0, P.lan.R0, P.lan.tspan);
S2 = lanchester_solve(P.lan.alphaB, aReff, P.lan.B0, P.lan.R0, P.lan.tspan);
R.lan = struct('S1', S1, 'S2', S2, 'aReff', aReff);
fprintf('\n[1] 兰彻斯特平方律（B0=%d, R0=%d, alpha_B=%.4f/min, alpha_R=%.4f/min）\n', ...
    P.lan.B0, P.lan.R0, P.lan.alphaB, P.lan.alphaR);
fprintf('    守恒量 alpha_R R^2 - alpha_B B^2：传统 %.4f ~ %.4f（应沿轨迹为常数）\n', ...
    min(S1.invariant), max(S1.invariant));
tc = P.lan.tspan(end);
B1 = endValue(S1, tc); B2 = endValue(S2, tc);
fprintf('    t = %g min：传统架构 蓝方剩余 %.2f（战损 %.1f%%），红方剩余 %.2f，蓝方于 %.1f min 耗尽\n', ...
    tc, B1, 100*(1-B1/P.lan.B0), endValue(S1, tc, true), S1.tEnd);
fprintf('            马赛克架构 蓝方剩余 %.2f（战损 %.1f%%），红方剩余 %.2f（alpha_R^eff=%.5f）\n', ...
    B2, 100*(1-B2/P.lan.B0), endValue(S2, tc, true), aReff);
fprintf('    战损速率比 alpha_R^eff/alpha_R = %.1f%%，即下降 %.1f%%\n', ...
    100 * aReff / P.lan.alphaR, 100 * (1 - aReff / P.lan.alphaR));

%% ---------- 2) 诱饵稀释 ----------
R.dilution = aReff / P.lan.alphaR;
fprintf('\n[2] 有效目标膨胀与火力稀释（B_manned=%d, B_CCA=%d, B_decoy=%d）\n', ...
    F.B_manned, F.B_CCA, F.B_decoy);
fprintf('    kappa1=%.2f, kappa2=%.2f -> alpha_R^eff/alpha_R = %.4f\n', ...
    F.kappa1, F.kappa2, R.dilution);
fprintf('    有人机每百架次战损率降幅 = %.2f%%（论文 83%%~87%%）\n', ...
    100 * (1 - R.dilution));
% 降幅达到论文区间的 kappa 组合（对称取 kappa1 = kappa2 = kappa）
kappa = P.force.kappa_grid;
red = 1 - alpha_effective(P.lan.alphaR, F.B_manned, F.B_CCA, F.B_decoy, kappa, kappa) / P.lan.alphaR;
inBand = kappa(red >= P.force.loss_reduction_target(1) & red <= P.force.loss_reduction_target(2));
R.kappaBand = inBand;
if ~isempty(inBand)
    fprintf('    降幅落在 83%%~87%% 的逼真度区间：kappa in [%.2f, %.2f]\n', min(inBand), max(inBand));
else
    fprintf('    在当前兵力结构下降幅未落入 83%%~87%% 区间\n');
end

%% ---------- 3) 大规模 WTA：拍卖算法 ----------
inst = wta_instance(P.wta.M, P.wta.T, P.wta.seed, P.wta.mj_max);
a = inst.V(:)' .* inst.p;
[xtA, infoA] = auction_assign(a, inst.mj, P.wta.eps_list, 200000);
[xtAs, infoAs] = auction_assign(a, inst.mj, 0.02, 200000);
fA = wta_obj(xtA, inst.p, inst.V);
[xtG, fG] = wta_greedy(inst.p, inst.V, inst.mj);
[xtL, fL] = wta_local_search(xtA, inst.p, inst.V, inst.mj);
aL = addObjOf(xtL, a, inst.M, inst.T);
aG = addObjOf(xtG, a, inst.M, inst.T);
R.wtaBig = struct('inst', inst, 'xtA', xtA, 'infoA', infoA, 'fA', fA, ...
    'fG', fG, 'xtG', xtG, 'xtL', xtL, 'fL', fL, 'aG', aG, 'aL', aL, 'infoAs', infoAs);
fprintf('\n[3] 大规模 WTA：M=%d 通道, T=%d 目标, 总价值 %.0f\n', inst.M, inst.T, sum(inst.V));
fprintf('    拍卖(eps-scaling)：迭代 %d 轮，比较 %d 次，eps-CS 违反量 %.2e -> 加性目标 %.2f\n', ...
    infoA.rounds, infoA.comps, infoA.csGap, infoA.addObj);
fprintf('      单级 eps=0.02 时仅 %d 轮（与论文 10^1~10^2 轮一致）；各级轮数 = [%s]\n', ...
    infoAs.rounds, num2str(infoA.roundsPerEps));
fprintf('    贪婪：加性目标 %.2f，精确目标 %.3f\n', aG, fG);
fprintf('    拍卖：加性目标 %.2f（优于贪婪 %.2f%%），精确目标 %.3f\n', ...
    infoA.addObj, 100*(infoA.addObj-aG)/aG, fA);
foptA = wta_additive_opt(a, inst.mj);
R.wtaBig.foptA = foptA;
fprintf('    加性目标的最优值（运输问题 LP）%.2f -> 拍卖 gap %.2f%%（界 M*eps = %.3f 仅在不含闲置标的价项时成立）\n', ...
    foptA, 100*(foptA-infoA.addObj)/foptA, inst.M*P.wta.eps_list(end));
fprintf('    拍卖+2-opt 局部改进：精确目标 %.3f（较拍卖降 %.2f%%，较贪婪降 %.2f%%）\n', ...
    fL, 100*(fA-fL)/fA, 100*(fG-fL)/fG);
fprintf('    说明：价格机制按加性代理 a_ij=V_j p_ij 定价，忽略连乘项的边际递减，\n');
fprintf('          故在精确非线性目标上式 eq:wta_obj 上存在口径差，需局部搜索或边际定价弥补\n');

%% ---------- 4) 小规模精确对照（m_j = 1 与 m_j > 1） ----------
sm1 = wta_instance(P.wta.smallM, P.wta.smallT, P.wta.seed, 1);      % m_j 全为 1
[~, fEnum1, infoE1] = wta_enum(sm1.p, sm1.V, sm1.mj);
[xtH, fH, addH] = wta_assign_hungarian(sm1.p, sm1.V);
sm2 = wta_instance(P.wta.smallM, P.wta.smallT, P.wta.seed, P.wta.mj_max);  % m_j 含 2
[xtE2, fEnum2, infoE2] = wta_enum(sm2.p, sm2.V, sm2.mj);
a2 = sm2.V(:)' .* sm2.p;
[xtA2, infoA2] = auction_assign(a2, sm2.mj, P.wta.eps_list, 200000);
fA2 = wta_obj(xtA2, sm2.p, sm2.V);
R.wtaSmall = struct('sm1', sm1, 'sm2', sm2, 'fEnum1', fEnum1, 'fH', fH, ...
    'addH', addH, 'fEnum2', fEnum2, 'fA2', fA2, 'infoA2', infoA2, ...
    'infoE1', infoE1, 'infoE2', infoE2);
fprintf('\n[4] 小规模精确对照：M=%d, T=%d\n', P.wta.smallM, P.wta.smallT);
fprintf('    m_j=1：候选 %d 个，可行 %d 个；枚举最优 %.4f vs 匈牙利 %.4f（差 %.2e）\n', ...
    infoE1.candidates, infoE1.feasible, fEnum1, fH, abs(fEnum1 - fH));
fprintf('    m_j>1：候选 %d 个，可行 %d 个；枚举最优 %.4f vs 拍卖 %.4f（gap %.2f%%）\n', ...
    infoE2.candidates, infoE2.feasible, fEnum2, fA2, 100*(fA2-fEnum2)/fEnum2);
fprintf('    m_j>1 时枚举耗时 %.2f s，正是“计算爆炸”的最小规模体现\n', infoE2.seconds);

%% ---------- 5) 中等规模分支定界 ----------
md = wta_instance(P.wta.midM, P.wta.midT, P.wta.seed, P.wta.mj_max);
[xtB, fB, infoB] = wta_bnb(md.p, md.V, md.mj, P.wta.bnb_maxNodes, 10);
[xtGm, fGm] = wta_greedy(md.p, md.V, md.mj);
R.wtaMid = struct('md', md, 'xtB', xtB, 'fB', fB, 'infoB', infoB, 'fGm', fGm);
fprintf('\n[5] 中等规模分支定界：M=%d, T=%d\n', md.M, md.T);
if infoB.proven
    fprintf('    已证最优：%.4f（节点 %d，%.2f s）；贪婪 %.4f（劣化 %.2f%%）\n', ...
        fB, infoB.nodes, infoB.seconds, fGm, 100*(fGm-fB)/fB);
else
    fprintf('    节点上限触发：%d 节点 / %.2f s 内未证最优%s\n', ...
        infoB.nodes, infoB.seconds, '');
end

%% ---------- 6) O(M^T) 计算爆炸 ----------
Tlist = [10 20 40 60 100 150 200 300];
Mref  = [8 12 24];
R.explosion = struct('T', Tlist, 'M', Mref);
for mi = 1:numel(Mref)
    lg = Tlist * log10(Mref(mi));
    R.explosion.(sprintf('log10_M%d', Mref(mi))) = lg;
end
fprintf('\n[6] 解空间规模 O(M^T)（log10）\n');
fprintf('    %-6s', 'T ='); fprintf('%10d', Tlist); fprintf('\n');
for mi = 1:numel(Mref)
    fprintf('    M=%-4d', Mref(mi));
    fprintf('%10.1f', R.explosion.(sprintf('log10_M%d', Mref(mi))));
    fprintf('\n');
end
fprintf('    以 10^9 次/s 的机载处理器计，T=300、M=24 时穷举需 10^%0.0f s（远超宇宙年龄）\n', ...
    R.explosion.log10_M24(end) - 9);

%% ---------- 7) 成本交换比 ----------
C = cost_exchange(P);
R.cost = C;
fprintf('\n[7] 成本交换比（单次交战口径）\n');
fprintf('    有人机 %.0f 万美元 / 拦截弹 %.0f 万美元 = %.1f : 1\n', ...
    P.cost.manned, mean(P.cost.interceptor), P.cost.manned/mean(P.cost.interceptor));
fprintf('    MALD-X %.0f 万美元 / 拦截弹 %.0f 万美元 = %.3f : 1\n', ...
    C.magazine.decoyC, C.magazine.intC, C.magazine.decoyC/C.magazine.intC);
fprintf('    弹匣级：40 个消耗节点（%.0f 万美元）耗尽一个营 32 发弹（%.0f 万美元）= %.3f : 1\n', ...
    C.magazine.blueCost, C.magazine.redCost, C.magazine.ratio);
fprintf('    注：表 tab:killweb_metrics 的 3.8:1 -> 0.65:1 属第4/5章体系级推演口径，本模型不反推\n');

%% ---------- 8) 图件 ----------
if doFigs
    fprintf('\n[8] 生成 2.3 节图件\n');
    fig_sec23_g1(P, R);
    fig_sec23_g2(P, R);
    fig_sec23_g3(P, R);
    fig_sec23_g4(P, R);
    fig_sec23_g5(P, R);
end

%% ---------- 9) 表格 ----------
rows = {
    '$\alpha_R^{\mathrm{eff}}/\alpha_R$', '诱饵稀释比', sprintf('%.4f', R.dilution)
    '有人机战损率降幅', '83\%$\sim$87\%', sprintf('%.2f\\%%', 100*(1-R.dilution))
    '小规模枚举 vs 匈牙利（$m_j=1$）', '相等', sprintf('$|\\Delta|=%.1e$', abs(fEnum1-fH))
    '拍卖 $\varepsilon$-CS 违反量', '$\le\varepsilon$', sprintf('$%.2e$', infoA.csGap)
    sprintf('拍卖迭代轮数（$M=%d,T=%d$）', inst.M, inst.T), '10$\sim$10$^2$', sprintf('%d', infoA.rounds)
    '解空间规模（$M=24,T=300$）', '$O(M^T)$', sprintf('$10^{%.0f}$', R.explosion.log10_M24(end))
    '弹匣级成本交换比', '单次交战口径', sprintf('%.3f', C.magazine.ratio)
    };
save_tex_table('tab_sec23', {'指标', '论文结果', '程序计算'}, rows, '2.3 节数值汇总');

if ~exist(fullfile(P.out.dir, 'results'), 'dir')
    mkdir(fullfile(P.out.dir, 'results'));
end
save(fullfile(P.out.dir, 'results', 'sec23.mat'), 'R');
fprintf('\n  2.3 节结果已保存至 out/results/sec23.mat\n');
end

% ---------- 局部辅助函数 ----------
function v = endValue(S, t, useR)
%ENDVALUE 取轨迹在 t 时刻的值；t 超出积分区间时取末值（兵力归零后保持不变）
if nargin < 3
    useR = false;
end
if useR
    y = S.R;
else
    y = S.B;
end
if t <= S.t(end)
    v = interp1(S.t, y, t, 'linear');
else
    v = y(end);
end
end

function s = addObjOf(xt, a, M, T)
%ADDOBJOF 线性化目标 sum a_ij x_ij
idx = find(xt > 0);
if isempty(idx)
    s = 0;
else
    s = sum(a(sub2ind([M, T], idx, xt(idx))));
end
end
