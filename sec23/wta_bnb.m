function [xb, fbest, info] = wta_bnb(p, V, mj, maxNodes, timeLimit)
%WTA_BNB 武器-目标分配问题的分支定界求解（集中式，子树剪枝）
%
%   [xb, fbest, info] = wta_bnb(p, V, mj, maxNodes, timeLimit)
%
%   以“火力通道”为分支变量（每个通道选择 0..T 之一），深度优先搜索；
%   下界用
%       LB(i) = 当前代价 - sum_{k=i..M} max_j V_j * p_kj
%   它假定每个剩余通道都能独立地按最大边际收益降低代价，是乐观松弛，
%   故剪枝不会误删最优解。目标值随通道分配单调下降，配合“先分配高价值
%   目标”的分支顺序可快速得到紧的初始上界。
%
%   论文指出该类集中式方法“在没有全局矩阵、没有中心节点的杀伤网中不适用”，
%   本函数用于在中等规模上给出精确最优解作为基准，并量化节点数随规模的爆炸。
if nargin < 4 || isempty(maxNodes)
    maxNodes = 3e5;
end
if nargin < 5 || isempty(timeLimit)
    timeLimit = 20;
end
[M, T] = size(p);
if nargin < 3 || isempty(mj)
    mj = ones(T, 1);
end
t0 = tic;

best = inf;
xb = zeros(M, 1);
xg = zeros(M, 1);
capLeft = mj(:)';
Lvec = ones(1, T);
nodes = 0;
limitHit = false;

% 后缀乐观界
pmax = max(V(:)' .* p, [], 2);          % M x 1
suf = zeros(M + 1, 1);
for i = M:-1:1
    suf(i) = suf(i + 1) + pmax(i);
end
[~, order] = sort(V(:), 'descend');

    function rec(i, cost)
        nodes = nodes + 1;
        if nodes > maxNodes || toc(t0) > timeLimit
            limitHit = true;
            return;
        end
        if cost - suf(i) >= best - 1e-12
            return;
        end
        if i > M
            if cost < best
                best = cost;
                xb = xg;
            end
            return;
        end
        for jj = 1:T
            j = order(jj);
            if capLeft(j) <= 0
                continue;
            end
            Lold = Lvec(j);
            newCost = cost - V(j) * Lold * p(i, j);
            % 注意：部分代价单调下降，不能用 newCost >= best 剪枝，
            % 必须用“部分代价 - 剩余通道的乐观收益”作为下界
            if newCost - suf(i + 1) >= best - 1e-12
                continue;
            end
            capLeft(j) = capLeft(j) - 1;
            Lvec(j) = Lold * (1 - p(i, j));
            xg(i) = j;
            rec(i + 1, newCost);
            xg(i) = 0;
            Lvec(j) = Lold;
            capLeft(j) = capLeft(j) + 1;
            if limitHit
                return;
            end
        end
        % 该通道不分配
        xg(i) = 0;
        rec(i + 1, cost);
    end

rec(1, sum(V(:)' .* 1));   % 初始代价 = 全部目标均存活的价值和
fbest = best;
info = struct('nodes', nodes, 'seconds', toc(t0), 'limitHit', limitHit, ...
    'proven', ~limitHit);
if limitHit
    fbest = NaN;
end
end
