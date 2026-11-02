function P = pfail_web_exact_literal(NS, NC, NE, q, eta)
%PFAIL_WEB_EXACT_LITERAL 论文式 eq:survive_eta 的字面实现（含 “1 -” 前缀）
%
%   仅用于对照：该式按字面计算得 1 - 9.79% = 90.2%（eta=0.9），
%   与论文所列数值矛盾，故正式计算一律使用 pfail_web_exact。
P = 1 - sum_fail_sum(NS, NC, NE, q, eta);
end

function S = sum_fail_sum(NS, NC, NE, q, eta)
p = 1 - q;
S = 0;
for s = 0:NS
    for c = 0:NC
        for e = 0:NE
            A = 1 - (1 - eta)^s;
            B = 1 - (1 - eta)^e;
            S = S + nchoosek(NS, s) * nchoosek(NC, c) * nchoosek(NE, e) * ...
                p^(s + c + e) * q^(NS + NC + NE - s - c - e) * ...
                (1 - A * B)^c;
        end
    end
end
end
