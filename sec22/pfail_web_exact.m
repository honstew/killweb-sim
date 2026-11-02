function [P, br] = pfail_web_exact(NS, NC, NE, q, eta)
%PFAIL_WEB_EXACT 含链路失效的杀伤网崩溃概率精确枚举（式 eq:survive_eta）
%
%   [P, br] = pfail_web_exact(NS, NC, NE, q, eta)
%
%   模型（论文 2.2 节）：
%     P_fail(eta) = sum_{s,c,e} C(NS,s)C(NC,c)C(NE,e)
%                   * p^(s+c+e) q^(NS+NC+NE-s-c-e) * [1 - A_s*B_e]^c
%     其中 A_s = 1-(1-eta)^s，B_e = 1-(1-eta)^e。
%   读法：对每个存活的指挥节点，“至少有一个存活感知节点且至少有一个存活
%   射手节点与之连通”的失败概率为 1-A_s*B_e，c 个指挥节点独立取 c 次方；
%   c=0、s=0 或 e=0 时方括号为 1，对应“某类节点全灭即崩溃”。
%
%   !!! 口径说明 !!!
%   论文排版式中该式前多写了一个 “1 -”，按字面计算 eta=0.9 时得 90.2%，
%   与论文正文的 9.79%、以及 40 万次蒙特卡洛的 9.11% 均不符。去掉该前缀
%   （即上式）后：eta=1 时退化为 1-(1-q^N)^3 = 9.09%，eta=0.9 时 9.788%，
%   与论文其余数值吻合。本实现按数值自洽的口径计算，另以
%   pfail_web_exact_literal 提供字面写法用于对照。
%
%   输入
%     NS, NC, NE : 感知 / 指挥 / 射手节点数
%     q          : 单节点战损率，标量或行向量（多值一次算完）
%     eta        : 单跳链路连通概率（标量）
%
%   输出
%     P  : 体系崩溃概率，与 q 同尺寸
%     br : 分解结构体（仅在 q 为标量且请求第二个输出时给出）
%          .total    总崩溃概率
%          .anyDead  某类节点全灭的并集概率 1 - prod(1-q^Ni)（= eta=1 时的 P）
%          .linkOnly 仅由链路失效新增的崩溃概率 P - anyDead
%          .shareC/.shareS/.shareE  三类全灭事件在 anyDead 中的占比
p   = 1 - q;
q   = q(:)';
p   = p(:)';
ntot = NS + NC + NE;
% q^k 与 p^k 预先列成 (ntot+1) x numel(q) 的表，避免长度不一致的广播
qpow = zeros(ntot + 1, numel(q));
ppow = zeros(ntot + 1, numel(q));
for k = 0:ntot
    qpow(k + 1, :) = q .^ k;
    ppow(k + 1, :) = p .^ k;
end

ns = 0:NS; nc = 0:NC; ne = 0:NE;
A = 1 - (1 - eta) .^ ns;             % 长度 NS+1，A(1)=0
B = 1 - (1 - eta) .^ ne;

P = zeros(1, numel(q));
for s = ns
    Cs = nchoosek(NS, s);
    for c = nc
        Cc = nchoosek(NC, c);
        for e = ne
            Ce = nchoosek(NE, e);
            w = (Cs * Cc * Ce) * ppow(s + c + e + 1, :) .* qpow(ntot - s - c - e + 1, :);
            P = P + w .* (1 - A(s + 1) * B(e + 1)).^c;
        end
    end
end
P = min(max(P, 0), 1);

if nargout > 1
    qS = q .^ NS; qC = q .^ NC; qE = q .^ NE;
    anyDead = 1 - (1 - qS) .* (1 - qC) .* (1 - qE);
    br = struct();
    br.total    = P;
    br.anyDead  = anyDead;
    br.linkOnly = max(P - anyDead, 0);
    br.shareC   = qC ./ anyDead;
    br.shareS   = qS ./ anyDead;
    br.shareE   = qE ./ anyDead;
    br.qS = qS; br.qC = qC; br.qE = qE;
end
end
