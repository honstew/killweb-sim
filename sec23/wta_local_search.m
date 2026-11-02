function [xt, fval] = wta_local_search(xt, p, V, mj, maxIter)
%WTA_LOCAL_SEARCH 对给定分配做成对交换（2-opt）局部改进
%
%   [xt, fval] = wta_local_search(xt, p, V, mj, maxIter)
%
%   目标函数为式 eq:wta_obj 的精确非线性形式。每一步尝试交换两个通道的
%   目标或把某通道改派到更优目标，只要精确目标下降就接受，直到无改进。
%   用于说明：拍卖算法按加性代理定价，其解在精确目标上仍有改进空间，
%   而工程上可用轻量局部搜索弥补（对应论文所述“通信降级时退化为规则式
%   分配”的处置思路）。
if nargin < 5 || isempty(maxIter)
    maxIter = 500;
end
[M, T] = size(p);
xt = xt(:);
if numel(xt) ~= M
    xt = zeros(M, 1);
end
capLeft = mj(:)';
for i = 1:M
    if xt(i) > 0
        capLeft(xt(i)) = capLeft(xt(i)) - 1;
    end
end
f = wta_obj(xt, p, V);
for it = 1:maxIter
    improved = false;
    for i = 1:M
        for j = 0:T
            if j == xt(i)
                continue;
            end
            if j > 0 && capLeft(j) <= 0
                continue;
            end
            if j == 0 && xt(i) == 0
                continue;
            end
            xt2 = xt;
            xt2(i) = j;
            f2 = wta_obj(xt2, p, V);
            if f2 < f - 1e-12
                if xt(i) > 0, capLeft(xt(i)) = capLeft(xt(i)) + 1; end
                if j > 0, capLeft(j) = capLeft(j) - 1; end
                xt = xt2; f = f2;
                improved = true;
            end
        end
    end
    if ~improved
        break;
    end
end
fval = f;
end
