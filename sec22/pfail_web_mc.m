function out = pfail_web_mc(NS, NC, NE, q, eta, trials, blockSize, seed)
%PFAIL_WEB_MC 杀伤网崩溃概率的蒙特卡洛抽样（逐节点伯努利实验）
%
%   out = pfail_web_mc(NS, NC, NE, q, eta, trials, blockSize, seed)
%
%   每次试验独立地：
%     1) 按 q 抽毁 NS+NC+NE 个节点；
%     2) 按 1-eta 抽 S-C 与 C-E 两类单跳链路的失效；
%     3) 若存在某条 S-C-E 两跳皆通且三节点均存活，则体系未崩溃。
%
%   输出 out
%     .P       崩溃概率点估计
%     .Pstd    标准差 sqrt(P(1-P)/trials)
%     .ci95    95% 置信半宽 1.96*Pstd
%     .fail    1 x trials 逻辑向量（用于收敛曲线）
%     .cumP    运行均值
%     .trials, .Pexact（若存在闭式/枚举可给出对照则另行填入）
if nargin < 7 || isempty(blockSize)
    blockSize = 20000;
end
if nargin < 8 || isempty(seed)
    seed = 20261102;
end
p = 1 - q;
oldState = rng;
rng(seed, 'twister');

fail = false(1, trials);
done = 0;
while done < trials
    nb = min(blockSize, trials - done);
    rows = done + (1:nb);

    % 节点存活（逻辑）
    aliveS = rand(NS, nb) < p;
    aliveC = rand(NC, nb) < p;
    aliveE = rand(NE, nb) < p;

    % 链路连通（逻辑）：Lsc(s,c,t)、Lce(c,e,t)
    Lsc = rand(NS, NC, nb) < eta;
    Lce = rand(NC, NE, nb) < eta;

    % 对每个指挥节点 c：是否存在“连通的存活感知节点”
    okC = false(NC, nb);
    for c = 1:NC
        hasS = false(1, nb);
        hasE = false(1, nb);
        for s = 1:NS
            hasS = hasS | (aliveS(s, :) & squeeze(Lsc(s, c, :))');
        end
        for e = 1:NE
            hasE = hasE | (aliveE(e, :) & squeeze(Lce(c, e, :))');
        end
        okC(c, :) = hasS & hasE;
    end
    aliveAndOk = okC & aliveC;
    fail(rows) = ~any(aliveAndOk, 1);
    done = done + nb;
end
rng(oldState);

out = struct();
out.P     = mean(fail);
out.Pstd  = sqrt(out.P * (1 - out.P) / trials);
out.ci95  = 1.96 * out.Pstd;
out.fail  = fail;
out.cumP  = cumsum(fail) ./ (1:trials);
out.trials = trials;
out.seed  = seed;
end
