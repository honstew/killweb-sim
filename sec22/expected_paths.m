function [E, crit] = expected_paths(NS, NC, NE, q, eta)
%EXPECTED_PATHS 线性杀伤链与杀伤网的期望可用杀伤路径数（式 eq:linear / eq:web）
%
%   [E, crit] = expected_paths(NS, NC, NE, q, eta)
%
%   E.linear = N_chain * (1-q)^3          （N_chain = min(NS,NC,NE)，对称时即 N）
%   E.web    = eta^2 * NS * NC * NE * (1-q)^3
%   E.ratio  = E.web / E.linear
%
%   crit 给出两个判据的解析拐点：
%     crit.etaPath = 1/N        （E[L_web] = E[L_linear] 的解析条件，式 eq:eta_crit）
%     crit.Nsym    = 对称编队规模（若三类节点数不等则取 NaN，并给出 min）
p = 1 - q;
Nchain = min([NS NC NE]);
E = struct();
E.linear = Nchain * p.^3;
E.web    = (eta.^2) * (NS * NC * NE) .* p.^3;
E.ratio  = E.web ./ max(E.linear, eps);

crit = struct();
if NS == NC && NC == NE
    crit.Nsym    = NS;
    crit.etaPath = 1 / NS;
else
    crit.Nsym    = NaN;
    crit.etaPath = 1 / Nchain;
end
crit.Nchain = Nchain;
end
