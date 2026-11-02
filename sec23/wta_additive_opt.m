function [fopt, xopt, info] = wta_additive_opt(a, mj)
%WTA_ADDITIVE_OPT 线性化（加性）WTA 的全局最优：运输问题，LP 即得整数解
%
%   [fopt, xopt, info] = wta_additive_opt(a, mj)
%
%   求解  max_{x}  sum_{i,j} a_ij x_ij
%   s.t.  sum_j x_ij <= 1,  sum_i x_ij <= m_j,  x_ij in {0,1}
%   约束矩阵是全幺模的（行和为 1 的指派/运输结构），故 LP 最优解必为整数，
%   用 linprog 即可在多项式时间内得到精确最优——这正是论文所说
%   “m_j = 1 时退化为线性指派问题”的一般化形式。
%
%   该值用作拍卖算法（分布式、eps-最优）的对照基准：Bertsekas 的
%   eps-互补松弛给出 f_opt - f_auction <= n*eps。
%
%   输入 a 为 M x T 收益矩阵，mj 为 T x 1 容量。
%   输出 xopt 为 M x T 的 0-1 矩阵，info 含 LP 状态与求解时间。
if nargin < 2 || isempty(mj)
    mj = ones(size(a, 2), 1);
end
[M, T] = size(a);
t0 = tic;
f = -a(:);                            % 列优先：x((j-1)*M+i) = x_ij，与 a(:) 一致
R = zeros(M, M * T);                  % 通道容量约束
for i = 1:M
    R(i, i:M:(M * T)) = 1;
end
C = zeros(T, M * T);                  % 目标容量约束
for j = 1:T
    C(j, (j - 1) * M + (1:M)) = 1;
end
Aineq = [R; C];
bineq = [ones(M, 1); mj(:)];
lb = zeros(M * T, 1);
ub = ones(M * T, 1);
opts = optimoptions('linprog', 'Display', 'none');
[x, fval, flag] = linprog(f, Aineq, bineq, [], [], lb, ub, opts);
if flag ~= 1
    error('wta_additive_opt:lp', 'linprog 未收敛（flag=%d）', flag);
end
X = reshape(x, M, T);
xopt = round(X);
fopt = -fval;
info = struct('flag', flag, 'seconds', toc(t0), ...
    'fractional', max(abs(X(:) - xopt(:))));
end
