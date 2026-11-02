function R = demo_sec22(P, doFigs)
%DEMO_SEC22 论文 2.2 节「杀伤网拓扑优势与数学建模分析」的算法实现与数值算例
%
%   R = demo_sec22(P, doFigs)
%
%   计算内容（论文中的对应数值即由本脚本给出）：
%     1) 式(chain)/(linear)：单链存活率 12.5%、E[L_lin]=0.625、P_fail_lin=51.29%
%     2) 式(web)/(survive)：E[L_web]=12.66（20.2 倍）、P_fail_web=9.09%
%     3) 式(survive_eta)：eta=0.9 时 9.79%（40 万次抽样校验）
%     4) 崩溃成因分解（指挥节点全灭的贡献占比）
%     5) 非对称编队 12/5/8 的交叉核对（3.6%）
%     6) 图 2-2 的 MATLAB 版与 5 张敏感性图
if nargin < 2
    doFigs = true;
end
NS = P.NS; NC = P.NC; NE = P.NE; N = NS; q = P.q; eta = P.eta;
p = 1 - q;

R = struct();
fprintf('\n===== 2.2 杀伤网拓扑优势与数学建模分析 =====\n');
fprintf('参数：N_S=%d, N_C=%d, N_E=%d, q=%.2f, eta=%.2f\n', NS, NC, NE, q, eta);

%% ---------- 1) 线性杀伤链 ----------
R.p_chain_single = p^3;
R.EL_linear     = N * p^3;
R.Pfail_linear  = pfail_linear(N, q);
fprintf('\n[1] 传统线性杀伤链\n');
fprintf('    单链存活率 (1-q)^3      = %.4f%%\n', 100 * R.p_chain_single);
fprintf('    E[L_linear] = N(1-q)^3   = %.4f 条\n', R.EL_linear);
fprintf('    P_fail_linear            = %.4f%%   （论文 51.29%%）\n', 100 * R.Pfail_linear);

%% ---------- 2) 动态杀伤网 ----------
R.EL_web   = eta^2 * NS * NC * NE * p^3;
R.EL_ratio = R.EL_web / R.EL_linear;
R.Pfail_web_eta1 = pfail_web_exact(NS, NC, NE, q, 1.0);
R.Pfail_web      = pfail_web_exact(NS, NC, NE, q, eta);
R.Pfail_web_base = pfail_web_baseline(N, q);
fprintf('\n[2] 马赛克动态杀伤网\n');
fprintf('    E[L_web] = eta^2 N^3 (1-q)^3 = %.4f 条（为线性架构的 %.2f 倍，论文 12.66 / 20.2 倍）\n', ...
    R.EL_web, R.EL_ratio);
fprintf('    P_fail_web (eta=1)       = %.4f%%   （论文 9.09%%）\n', 100 * R.Pfail_web_eta1);
fprintf('    P_fail_web (eta=%.2f)      = %.4f%%   （论文 9.79%%）\n', eta, 100 * R.Pfail_web);
% 字面公式对照
R.Pfail_literal = pfail_web_exact_literal(NS, NC, NE, q, eta);
fprintf('    [对照] 式 eq:survive_eta 字面（含 “1 -”）= %.2f%%  <-- 与论文数值不符，故不采用\n', ...
    100 * R.Pfail_literal);

%% ---------- 3) 蒙特卡洛 ----------
fprintf('\n[3] 蒙特卡洛抽样校验（%d 次抽样）\n', P.mc.trials);
mc1  = pfail_web_mc(NS, NC, NE, q, 1.0, P.mc.trials, P.mc.block, P.mc.seed);
mc09 = pfail_web_mc(NS, NC, NE, q, eta, P.mc.trials, P.mc.block, P.mc.seed);
R.mc = struct('P1', mc1.P, 's1', mc1.Pstd, 'P09', mc09.P, 's09', mc09.Pstd, ...
    'trials', P.mc.trials);
fprintf('    eta=1.0 : MC = %.4f%% +/- %.4f pp  |  精确 = %.4f%%\n', ...
    100*mc1.P, 100*mc1.ci95, 100*R.Pfail_web_eta1);
fprintf('    eta=%.2f : MC = %.4f%% +/- %.4f pp  |  精确 = %.4f%%   （论文抽样 9.11%%, 标准差约 0.05 pp）\n', ...
    eta, 100*mc09.P, 100*mc09.ci95, 100*R.Pfail_web);

%% ---------- 4) 崩溃成因分解 ----------
[~, br] = pfail_web_exact(NS, NC, NE, q, eta);
R.br = br;
fprintf('\n[4] 崩溃成因分解（eta=%.2f）\n', eta);
fprintf('    某类节点全灭（三类事件并集）  = %.4f%%\n', 100 * br.anyDead);
fprintf('    其中：指挥全灭 %.4f%% / 感知全灭 %.4f%% / 射手全灭 %.4f%%\n', ...
    100*br.qC, 100*br.qS, 100*br.qE);
fprintf('    仅由链路失效新增             = %.4f%%\n', 100 * br.linkOnly);
fprintf('    指挥类占比（对称算例应为 1/3） = %.1f%%\n', 100 * br.shareC);

%% ---------- 5) 非对称编队交叉核对 ----------
A = P.asym;
R.asym.Pfail = pfail_web_exact(A.NS, A.NC, A.NE, A.q, A.eta);
[~, brA] = pfail_web_exact(A.NS, A.NC, A.NE, A.q, A.eta);
R.asym.br = brA;
fprintf('\n[5] 非对称编队交叉核对 N_S/N_C/N_E = %d/%d/%d, q=%.2f, eta=%.2f\n', ...
    A.NS, A.NC, A.NE, A.q, A.eta);
fprintf('    P_fail = %.4f%%   （论文 4.3 节 3.6%%）\n', 100 * R.asym.Pfail);
fprintf('    指挥节点类别对崩溃概率的贡献 = %.1f%%   （摘要口径约 88%%）\n', 100 * brA.shareC);

%% ---------- 6) 判据交叉点 ----------
crit = eta_crossover(NS, NC, NE, q);
R.crit = crit;
fprintf('\n[6] 两个判据的交叉点\n');
fprintf('    期望路径拐点 eta = 1/N      = %.3f   （论文 0.2）\n', crit.etaPath);
fprintf('    崩溃概率交叉点 eta_fail     = %.3f   （论文约 0.27）\n', crit.etaFail);
for e = [0.5 0.3 0.2]
    fprintf('    P_fail(eta=%.1f) = %.2f%%\n', e, 100*pfail_web_exact(NS,NC,NE,q,e));
end

%% ---------- 7) 图件 ----------
if doFigs
    fprintf('\n[7] 生成 2.2 节图件\n');
    fig_sec22_f1();
    fig_sec22_f2(P);
    fig_sec22_f3(P);
    fig_sec22_f4(P);
    fig_sec22_f5(P);
    fig_sec22_f6(P, mc1, mc09);
end

%% ---------- 8) 表格 ----------
rows = {
    '单链存活率 $(1-q)^3$',            '12.50\%', sprintf('%.4f\\%%', 100*R.p_chain_single)
    '$E[L_{\mathrm{linear}}]$',        '0.625',   sprintf('%.4f', R.EL_linear)
    '$P_{\mathrm{fail,linear}}$',      '51.29\%', sprintf('%.2f\\%%', 100*R.Pfail_linear)
    '$E[L_{\mathrm{web}}]\;(\eta=0.9)$','12.66',  sprintf('%.4f', R.EL_web)
    '路径数倍数',                       '20.2',    sprintf('%.2f', R.EL_ratio)
    '$P_{\mathrm{fail,web}}\;(\eta=1)$','9.09\%', sprintf('%.4f\\%%', 100*R.Pfail_web_eta1)
    '$P_{\mathrm{fail,web}}\;(\eta=0.9)$','9.79\%', sprintf('%.4f\\%%', 100*R.Pfail_web)
    sprintf('蒙特卡洛 $\\eta=1$（%d 次）', P.mc.trials), '9.11\%', ...
        sprintf('$%.2f\\%%\\pm%.2f$\\,pp', 100*mc1.P, 100*mc1.ci95)
    '交叉点 $\eta$（期望路径）',        '0.20',    sprintf('%.3f', crit.etaPath)
    '交叉点 $\eta$（崩溃概率）',        '$\approx0.27$', sprintf('%.3f', crit.etaFail)
    '非对称 $12/5/8$ 的 $P_{\mathrm{fail}}$', '3.6\%', sprintf('%.2f\\%%', 100*R.asym.Pfail)
    };
save_tex_table('tab_sec22', {'指标', '论文结果', '程序计算'}, rows, '2.2 节数值汇总');

if ~exist(fullfile(P.out.dir, 'results'), 'dir')
    mkdir(fullfile(P.out.dir, 'results'));
end
save(fullfile(P.out.dir, 'results', 'sec22.mat'), 'R');
fprintf('\n  2.2 节结果已保存至 out/results/sec22.mat\n');
end
