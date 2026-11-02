function [xt, fval, addObj] = wta_assign_hungarian(p, V)
%WTA_ASSIGN_HUNGARIAN m_j == 1 时的线性指派最优解（匈牙利算法 / matchpairs）
%
%   [xt, fval, addObj] = wta_assign_hungarian(p, V)
%
%   当每个目标至多分配一个通道（m_j = 1）时，式 eq:wta_obj 的连乘退化为
%   线性形式：
%       sum_j V_j (1 - p_ij x_ij) = sum_j V_j - sum_{i,j} (V_j p_ij) x_ij
%   于是最小化等价于最大化 sum (V_j p_ij) x_ij，即经典线性指派问题，
%   可在多项式时间内精确求解。这正是论文所说“马赛克编队打破了这一前提”
%   的对照基线。
%
%   输出
%     xt       M x 1 分配（目标编号，0 表示不分配）
%     fval     在原始非线性目标（式 eq:wta_obj）下的取值
%     addObj   线性指派目标 sum(V_j p_ij x_ij) 的最大值
[M, T] = size(p);
a = V(:)' .* p;                 % M x T 收益
cost = -a;                      % matchpairs 求最小代价
bigCost = 1e6;                  % 允许通道“不分配”
[m, ~] = matchpairs(cost, bigCost);
xt = zeros(M, 1);
for k = 1:size(m, 1)
    xt(m(k, 1)) = m(k, 2);
end
addObj = 0;
idx = find(xt > 0);
if ~isempty(idx)
    addObj = sum(a(sub2ind([M, T], idx, xt(idx))));
end
fval = wta_obj(xt, p, V);
end
