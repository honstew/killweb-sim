function write_report(P, R22, R23)
%WRITE_REPORT 生成 out/report.md：数值汇总、图件清单与口径说明
d = P.out.dir;
if ~exist(d, 'dir')
    mkdir(d);
end
fid = fopen(fullfile(d, 'report.md'), 'w', 'n', 'UTF-8');
assert(fid > 0, '无法写入 report.md');

v = ver('MATLAB');
fprintf(fid, '# 论文 2.2 / 2.3 节 MATLAB 数值计算报告\n\n');
fprintf(fid, '- 生成时间：%s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '- 环境：MATLAB %s\n', v.Version);
fprintf(fid, '- 入口：`matlab/run_all.m`\n');
fprintf(fid, '- 说明：本目录是论文 2.2 / 2.3 节所用算法的程序实现，论文中的数值与图件由它计算给出；下表为程序输出与论文所列数值的对照。\n\n');

fprintf(fid, '## 一、2.2 节：杀伤网拓扑优势\n\n');
fprintf(fid, '参数：$N_S=N_C=N_E=%d$，$q=%.2f$，$\\eta=%.2f$。\n\n', P.NS, P.q, P.eta);
fprintf(fid, '| 量 | 论文结果 | 程序计算 |\n|---|---|---|\n');
fprintf(fid, '| 单链存活率 $(1-q)^3$ | 12.50%% | %.4f%% |\n', 100*R22.p_chain_single);
fprintf(fid, '| $E[L_{\\mathrm{linear}}]$ | 0.625 | %.4f |\n', R22.EL_linear);
fprintf(fid, '| $P_{\\mathrm{fail,linear}}$ | 51.29%% | %.4f%% |\n', 100*R22.Pfail_linear);
fprintf(fid, '| $E[L_{\\mathrm{web}}]$（$\\eta=0.9$） | 12.66 | %.4f |\n', R22.EL_web);
fprintf(fid, '| 路径数倍数 | 20.2 | %.2f |\n', R22.EL_ratio);
fprintf(fid, '| $P_{\\mathrm{fail,web}}$（$\\eta=1$） | 9.09%% | %.4f%% |\n', 100*R22.Pfail_web_eta1);
fprintf(fid, '| $P_{\\mathrm{fail,web}}$（$\\eta=0.9$） | 9.79%% | %.4f%% |\n', 100*R22.Pfail_web);
fprintf(fid, '| 蒙特卡洛（$\\eta=1$，40 万次） | 9.11%% | %.4f%% ± %.4f pp |\n', ...
    100*R22.mc.P1, 100*R22.mc.s1*1.96);
fprintf(fid, '| 非对称 12/5/8 的 $P_{\\mathrm{fail}}$ | 3.6%% | %.2f%% |\n', 100*R22.asym.Pfail);
fprintf(fid, '| 期望路径拐点 $\\eta=1/N$ | 0.20 | %.3f |\n', R22.crit.etaPath);
fprintf(fid, '| 崩溃概率交叉点 $\\eta$ | $\\approx0.27$ | %.3f |\n\n', R22.crit.etaFail);

fprintf(fid, '崩溃成因分解（$\\eta=%.2f$）：节点全灭 %.2f%%，其中指挥类占 %.1f%%、感知类占 %.1f%%、射手类占 %.1f%%；', ...
    P.eta, 100*R22.br.anyDead, 100*R22.br.shareC, 100*R22.br.shareS, 100*R22.br.shareE);
fprintf(fid, '链路失效新增 %.2f%%。\n\n', 100*R22.br.linkOnly);

fprintf(fid, '## 二、2.3 节：兰彻斯特方程与武器-目标分配\n\n');
fprintf(fid, '| 量 | 论文结果/口径 | 程序计算 |\n|---|---|---|\n');
fprintf(fid, '| $\\alpha_R^{\\mathrm{eff}}/\\alpha_R$ | 诱饵稀释 | %.4f |\n', R23.dilution);
fprintf(fid, '| 有人机战损率降幅 | 83%%~87%% | %.2f%% |\n', 100*(1-R23.dilution));
fprintf(fid, '| 小规模枚举 vs 匈牙利（$m_j=1$） | 应相等 | 差 %.1e |\n', ...
    abs(R23.wtaSmall.fEnum1 - R23.wtaSmall.fH));
fprintf(fid, '| 拍卖迭代轮数（$M=24,T=40$） | $10^1$~$10^2$ | %d（$\\varepsilon$-scaling 累计，精化各级 24--28 轮）/ %d（单级 $\\varepsilon=0.02$ 冷启动） |\n', ...
    R23.wtaBig.infoA.rounds, R23.wtaBig.infoAs.rounds);
fprintf(fid, '| 拍卖 $\\varepsilon$-CS 违反量 | $\\le\\varepsilon$ | %.2e |\n', ...
    R23.wtaBig.infoA.csGap);
fprintf(fid, '| 精确目标：拍卖 / 拍卖+2-opt / 贪婪 | 加性代理的口径差 | %.2f / %.2f / %.2f |\n', ...
    R23.wtaBig.fA, R23.wtaBig.fL, R23.wtaBig.fG);
fprintf(fid, '| 解空间规模（$M=24,T=300$） | $O(M^T)$ | $10^{%.0f}$ |\n', ...
    R23.explosion.log10_M24(end));
fprintf(fid, '| 弹匣级成本交换比 | 单次交战口径 | %.3f : 1 |\n\n', R23.cost.magazine.ratio);

fprintf(fid, '## 三、图件清单\n\n');
figs = dir(fullfile(d, 'figs', '*.png'));
for k = 1:numel(figs)
    fprintf(fid, '- `out/figs/%s`\n', figs(k).name);
end
fprintf(fid, '\n## 四、口径说明\n\n');
fprintf(fid, '1. **式 eq:survive_eta 的符号**：论文排版式中 `P_fail` 前多了一个 “1 -”。按字面计算 $\\eta=0.9$ 时为 90.2%%，与论文正文的 9.79%%、以及 40 万次抽样 9.11%% 不符；去掉该前缀后 $\\eta=1$ 退化为 $1-(1-q^N)^3=9.09\\%%$，全部数值吻合。本实现按数值自洽口径计算，`pfail_web_exact_literal` 保留字面写法供对照。\n');
fprintf(fid, '2. **指挥类崩溃占比**：非对称 12/5/8 算例下程序给出 %.1f%%，摘要口径为“约 88%%”，差异来自取整与 $\\eta$ 口径，量级一致。\n', 100*R22.asym.br.shareC);
fprintf(fid, '3. **成本交换比**：2.3 节只给单价，程序给单价级与弹匣级两种单次交战口径；表 tab:killweb_metrics 的 3.8:1→0.65:1 属第 4/5 章体系级想定推演，不由本节模型反推。\n');
fprintf(fid, '4. **兰彻斯特参数**：$\\alpha_B$、$\\alpha_R$ 为量级假设（1/min），仅用于展示 $\\alpha_R^{\\text{eff}}$ 的稀释效果，不代表实兵数据。\n');
fprintf(fid, '5. **拍卖算法的全局界**：$\\varepsilon$-互补松弛只对“已分配标的”成立；当标的（槽位 %d 个）多于射手（%d 个）时存在闲置标的，其价格不为零，Bertsekas 的 $n\\varepsilon$ 全局界须附加 $\\sum_{\\text{闲置}} u_s$ 项。故程序只用有完整指派的小规模算例做全局最优校核（与匈牙利/LP 差 0），大规模算例只报轮次、$\\varepsilon$-CS 违反量与精确目标对比。\n', ...
    R23.wtaBig.infoA.Ns, R23.wtaBig.inst.M);
fprintf(fid, '6. **加性代理与精确目标的差**：拍卖按 $a_{ij}=V_jp_{ij}$ 线性定价，忽略了连乘项的边际递减；$M=24,T=40$ 时精确目标上拍卖 %.2f、加 2-opt 后 %.2f、贪婪 %.2f，说明 2.3.1 节所述“取对数也无法线性化”确有代价，工程上需以边际收益定价或叠加局部交换。\n', ...
    R23.wtaBig.fA, R23.wtaBig.fL, R23.wtaBig.fG);
fclose(fid);
fprintf('\n  报告已写入 out/report.md\n');
end
