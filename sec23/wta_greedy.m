function [xt, fval] = wta_greedy(p, V, mj)
%WTA_GREEDY 武器-目标分配的贪婪启发式（按威胁价值降序逐目标分配）
%
%   [xt, fval] = wta_greedy(p, V, mj)
%
%   每轮选取“当前边际下降最大”的 (通道, 目标) 对：边际下降 = V_j*L_j*p_ij。
%   复杂度 O(M*T + M*T*log)，用于大规模算例的基线对照。
[M, T] = size(p);
if nargin < 3 || isempty(mj)
    mj = ones(T, 1);
end
L = ones(1, T);
xt = zeros(M, 1);
capLeft = mj(:)';
freeCh = true(M, 1);
for k = 1:sum(mj)
    gainMat = (V(:)' .* L) .* p;            % M x T 边际收益
    gainMat(:, capLeft <= 0) = -inf;
    gainMat(~freeCh, :) = -inf;
    [g, idx] = max(gainMat(:));
    if ~isfinite(g) || g <= 0
        break;
    end
    [i, j] = ind2sub([M, T], idx);
    xt(i) = j;
    L(j) = L(j) * (1 - p(i, j));
    capLeft(j) = capLeft(j) - 1;
    freeCh(i) = false;
end
fval = wta_obj(xt, p, V);
end
