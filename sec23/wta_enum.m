function [xb, fbest, info] = wta_enum(p, V, mj)
%WTA_ENUM 武器-目标分配问题的全局最优解（穷举）
%
%   [xb, fbest, info] = wta_enum(p, V, mj)
%
%   直接枚举全部 (T+1)^M 个候选分配（每个通道选 0..T 之一），剔除违反
%   容量约束 sum_i x_ij <= m_j 的方案后取目标函数最小值。仅适用于
%   M <= 7、T <= 9 量级；其规模 O(M^T) 正是论文所述“计算爆炸”的直接体现。
%
%   输出
%     xb     M x 1 最优分配（元素为目标编号，0 表示不分配）
%     fbest  全局最优目标值
%     info.candidates 候选分配总数 (T+1)^M
%     info.feasible   满足容量约束的可行解数
%     info.seconds    计算耗时
if nargin < 3 || isempty(mj)
    mj = ones(size(p, 2), 1);
end
[M, T] = size(p);
ncand = (T + 1)^M;
if ncand > 8e6
    error('wta_enum:size', '候选解 %d 超过穷举上限，请改用分支定界或拍卖算法', ncand);
end
t0 = tic;
opts = 0:T;
c = cell(1, M);
[c{:}] = ndgrid(opts);
X = zeros(ncand, M);
for i = 1:M
    X(:, i) = c{i}(:);
end

% 容量约束
ok = true(ncand, 1);
for j = 1:T
    ok = ok & (sum(X == j, 2) <= mj(j));
end

% 目标函数：每个目标的存活概率连乘
L = ones(ncand, T);
for j = 1:T
    lg = zeros(ncand, 1);
    for i = 1:M
        sel = (X(:, i) == j);
        if any(sel)
            lg(sel) = lg(sel) + log(1 - p(i, j));
        end
    end
    L(:, j) = exp(lg);
end
f = L * V(:);
f(~ok) = inf;
[fbest, idx] = min(f);

info = struct();
info.candidates = ncand;
info.feasible = sum(ok);
info.seconds = toc(t0);
info.fvalAll = f;
xb = X(idx, :)';
end
