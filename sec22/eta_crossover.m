function crit = eta_crossover(NS, NC, NE, q)
%ETA_CROSSOVER 两个判据的交叉点：期望路径拐点与崩溃概率交叉点
%
%   crit = eta_crossover(NS, NC, NE, q)
%
%   crit.etaPath  解析拐点 1/N：超过它网状架构的期望可用路径多于线性编队
%   crit.etaFail 数值交叉点：P_fail_web(eta) = P_fail_linear 的 eta（fzero）
%   crit.pFailLin 线性架构在该 (N,q) 下的崩溃概率
%
%   论文 5.3 节给出 N=5 时 etaPath=0.2、etaFail≈0.27。“偏离方向一致，
%   1/N 落在崩溃概率交叉点以下，作为反制门槛偏保守”。
Nchain = min([NS NC NE]);
crit.etaPath = 1 / Nchain;
crit.pFailLin = pfail_linear(Nchain, q);

f = @(eta) pfail_web_exact(NS, NC, NE, q, eta) - crit.pFailLin;
opt = optimset('TolX', 1e-10, 'Display', 'off');
try
    crit.etaFail = fzero(f, [1e-6, 1], opt);
catch
    % 若区间端点同号（不交叉），返回 NaN
    crit.etaFail = NaN;
end
end
