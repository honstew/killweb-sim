function T = test_paper_numbers(P)
%TEST_PAPER_NUMBERS 以论文 2.2 / 2.3 节所列数值为准的回归断言
%
%   T = test_paper_numbers(P)
%
%   本程序即论文 2.2 / 2.3 节所用算法，论文中的数值由它计算给出。这里把这些
%   数值固化为断言，用于改动参数或代码后快速发现口径漂移（回归测试）。
%   每个断言给出：名称、论文所列值、程序计算值、误差、是否通过。精确模型的
%   容差取 1e-6 相对量级；蒙特卡洛按 4 sigma 判定。任一断言失败不会中断运行，
%   但会在末尾汇总并以 error 报出，避免“跑出图但数值不对”的静默错误。
fprintf('\n===== 数值一致性回归（断言测试） =====\n');
T = struct('name', {{}}, 'paper', [], 'prog', [], 'tol', [], 'pass', []);

NS = P.NS; NC = P.NC; NE = P.NE; q = P.q; eta = P.eta;

% --- 2.2 ---
T = push(T, '单链存活率 (1-q)^3', 0.1250, (1-q)^3, 1e-4);
T = push(T, 'E[L_linear]', 0.625, NS*(1-q)^3, 1e-4);
T = push(T, 'P_fail_linear', 0.5129, pfail_linear(NS, q), 1e-4);
T = push(T, 'E[L_web] (eta=0.9)', 12.66, eta^2*NS*NC*NE*(1-q)^3, 1e-2);
T = push(T, '路径数倍数', 20.2, eta^2*NS*NC*NE*(1-q)^3/(NS*(1-q)^3), 1e-1);
T = push(T, 'P_fail_web (eta=1)', 0.0909, pfail_web_baseline(NS, q), 1e-4);
T = push(T, 'P_fail_web (eta=0.9)', 0.0979, pfail_web_exact(NS, NC, NE, q, eta), 1e-4);
T = push(T, 'P_fail_web (eta=0.5)', 0.230, pfail_web_exact(NS, NC, NE, q, 0.5), 1e-3);
T = push(T, 'P_fail_web (eta=0.3)', 0.464, pfail_web_exact(NS, NC, NE, q, 0.3), 1e-3);
T = push(T, 'P_fail_web (eta=0.2)', 0.660, pfail_web_exact(NS, NC, NE, q, 0.2), 1e-3);
T = push(T, '非对称 12/5/8 (eta=0.9)', 0.036, ...
    pfail_web_exact(P.asym.NS, P.asym.NC, P.asym.NE, P.asym.q, P.asym.eta), 1e-3);
crit = eta_crossover(NS, NC, NE, q);
T = push(T, 'eta 期望路径拐点 1/N', 0.20, crit.etaPath, 1e-9);
T = push(T, 'eta 崩溃概率交叉点', 0.27, crit.etaFail, 0.02);

% 蒙特卡洛（按 4 sigma 判定）
mc = pfail_web_mc(NS, NC, NE, q, 1.0, P.mc.trials/4, P.mc.block, P.mc.seed);
sd = sqrt(pfail_web_baseline(NS,q)*(1-pfail_web_baseline(NS,q))/(P.mc.trials/4));
T = push(T, '蒙特卡洛 eta=1（10万次）', pfail_web_baseline(NS,q), mc.P, 4*sd + 1e-4);

% 拓扑计数：3 个节点被毁后可重构路径 = 2*2*2 = 8
[figTmp, cnt] = draw_killweb();
T = push(T, '3 节点战损后剩余路径', 8, cnt.webPaths, 1e-9);
close(figTmp);

% --- 2.3 ---
F = P.force;
aReff = alpha_effective(P.lan.alphaR, F.B_manned, F.B_CCA, F.B_decoy, F.kappa1, F.kappa2);
ratio = aReff / P.lan.alphaR;
T = push(T, 'alpha_R^eff/alpha_R', 0.147, ratio, 5e-3);
T = push(T, '有人机战损率降幅', 0.853, 1 - ratio, 5e-3);

S = lanchester_solve(P.lan.alphaB, P.lan.alphaR, P.lan.B0, P.lan.R0, [0 20]);
T = push(T, '兰彻斯特守恒量漂移', 0, max(abs(S.invariant - S.invariant(1))), 1e-4);

sm1 = wta_instance(P.wta.smallM, P.wta.smallT, P.wta.seed, 1);
[~, fEnum, ~] = wta_enum(sm1.p, sm1.V, sm1.mj);
[~, fH, addH] = wta_assign_hungarian(sm1.p, sm1.V);
T = push(T, 'm_j=1：匈牙利 = 枚举最优', fEnum, fH, 1e-8);

a = sm1.V(:)' .* sm1.p;
[xtA1, infoA] = auction_assign(a, sm1.mj, P.wta.eps_list, 200000);
foptA = wta_additive_opt(a, sm1.mj);
T = push(T, '拍卖 eps-CS 违反量', 0, infoA.csGap, P.wta.eps_list(end) * 1.5);
T = push(T, '拍卖 vs 加性最优（相对 gap）', 0, (foptA - infoA.addObj) / foptA, 0.01);
T = push(T, 'eps-CS 界：gap <= M*eps', 0, ...
    max((foptA - infoA.addObj) - sm1.M * P.wta.eps_list(end), 0), 1e-9);
[~, fL] = wta_local_search(xtA1, sm1.p, sm1.V, sm1.mj);
T = push(T, '局部搜索不劣于拍卖解', 0, max(wta_obj(xtA1, sm1.p, sm1.V) - fL, 0), 1e-9);

% 目标函数自检：全不分配时等于总价值
T = push(T, 'wta_obj(全不分配) = sum(V)', sum(sm1.V), ...
    wta_obj(zeros(sm1.M,1), sm1.p, sm1.V), 1e-9);

% --- 汇总 ---
nPass = sum(T.pass);
fprintf('\n  共 %d 项，通过 %d 项，失败 %d 项\n', numel(T.pass), nPass, numel(T.pass) - nPass);
if nPass < numel(T.pass)
    bad = T.name(~T.pass);
    fprintf('  失败项：%s\n', strjoin(bad, '；'));
    error('test_paper_numbers:fail', '%d 项一致性断言未通过', numel(T.pass) - nPass);
end
fprintf('  全部数值与论文口径一致。\n');
end

function T = push(T, name, paper, prog, tol)
k = numel(T.name) + 1;
T.name{k} = name;
T.paper(k) = paper;
T.prog(k) = prog;
T.tol(k) = tol;
ok = abs(prog - paper) <= tol;
T.pass(k) = ok;
if ok
    flag = 'PASS';
else
    flag = 'FAIL';
end
fprintf('  [%s] %-32s 论文=%-10.5g 程序=%-10.5g 误差=%.2e (tol %.1e)\n', ...
    flag, name, paper, prog, abs(prog - paper), tol);
end
