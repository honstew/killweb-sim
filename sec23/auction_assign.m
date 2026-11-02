function [xt, info] = auction_assign(a, mj, epsSeq, maxRounds)
%AUCTION_ASSIGN 分布式拍卖算法求解武器-目标分配（Bertsekas 价格机制）
%
%   [xt, info] = auction_assign(a, mj, epsSeq, maxRounds)
%
%   模型：M 个竞标者（火力节点）对 T 个标的（目标）竞标，标的 j 的容量为
%   m_j（可重复拦截弹数上限）。收益矩阵 a 为 M x T。
%
%   算法：把容量 m_j 拆成 m_j 个“标的槽位”，按 Bertsekas 拍卖进行——
%     1) 取一个未分配的竞标者 i，计算净收益 v_j = a_ij - u_j；
%     2) 对其最优标的 j1 加价 u_j1 <- u_j1 + (v_j1 - v_j2) + eps，
%        其中 v_j2 为次优净收益（此步保证出价恰好超过次优者一个增量）；
%     3) 若 j1 已被他人持有，其持有者退回未分配状态，进入下一轮。
%   每轮至少有一个价格上升 eps，而价格上界受 max a_ij 约束，故有限轮终止。
%
%   eps 递减（eps-scaling）：先用大 eps 快速获得粗解，再逐级减小 eps，
%   在迭代轮数与最优性之间折中（论文 2.3.2 节）。
%
%   输出
%     xt        M x 1 分配（目标编号，0 表示未分配）
%     info.rounds      总迭代轮数（竞标次数）
%     info.comps       总净收益比较次数
%     info.csGap       最终 eps-CS 条件最大违反量（应 <= eps_min）
%     info.eps         最终 eps
%     info.addObj      sum a_ij x_ij（线性化目标，拍卖算法实际优化对象）
%     info.u           各标的当前价格（按目标聚合）
%     info.slotTarget  槽位到目标的映射
%     info.roundsPerEps 每级 eps 的轮数
if nargin < 3 || isempty(epsSeq)
    epsSeq = [0.5 0.2 0.1 0.05 0.02 0.01];
end
if nargin < 4 || isempty(maxRounds)
    maxRounds = 200000;
end
[M, T] = size(a);
mj = mj(:)';
slotTarget = repelem(1:T, mj);          % 1 x Ns
Ns = numel(slotTarget);
A = a(:, slotTarget);

u = zeros(1, Ns);
roundsPerEps = zeros(size(epsSeq));
comps = 0;
rounds = 0;
slotOf = zeros(M, 1);
xt = zeros(M, 1);

for k = 1:numel(epsSeq)
    eps = epsSeq(k);
    xt(:) = 0;
    slotOf(:) = 0;
    hold = zeros(1, Ns);
    nRound = 0;
    while any(xt == 0) && nRound < maxRounds
        i = find(xt == 0, 1);
        v = A(i, :) - u;
        comps = comps + Ns;
        [vmax, j1] = max(v);
        v(j1) = -inf;
        if Ns > 1
            v2 = max(v);
        else
            v2 = 0;
        end
        if ~isfinite(v2)
            v2 = 0;
        end
        % 出价：恰好超过次优净收益一个 eps
        u(j1) = u(j1) + (vmax - v2) + eps;
        prev = hold(j1);
        hold(j1) = i;
        xt(i) = slotTarget(j1);
        slotOf(i) = j1;
        if prev > 0 && prev ~= i
            xt(prev) = 0;
            slotOf(prev) = 0;
        end
        nRound = nRound + 1;
    end
    roundsPerEps(k) = nRound;
    rounds = rounds + nRound;
end

% eps-CS 校验：已分配者的净收益与其最优标的相比，差距不超过 eps
epsFinal = epsSeq(end);
csGap = 0;
for i = 1:M
    if xt(i) > 0
        v = A(i, :) - u;
        csGap = max(csGap, max(v) - v(slotOf(i)));
    end
end

addObj = 0;
if any(xt > 0)
    addObj = sum(a(sub2ind([M, T], find(xt > 0), xt(xt > 0))));
end
uTarget = zeros(1, T);
for t = 1:T
    sl = find(slotTarget == t, 1);
    uTarget(t) = u(sl);
end

info = struct('rounds', rounds, 'comps', comps, 'csGap', csGap, ...
    'eps', epsFinal, 'addObj', addObj, 'u', uTarget, ...
    'slotTarget', slotTarget, 'roundsPerEps', roundsPerEps, ...
    'Ns', Ns, 'maxRoundsHit', rounds >= maxRounds);
end
