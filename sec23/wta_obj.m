function [fval, L] = wta_obj(x, p, V)
%WTA_OBJ 目标函数：防守方期望被毁伤价值（式 eq:wta_obj）
%
%   [fval, L] = wta_obj(x, p, V)
%
%   fval = sum_j V_j * prod_i (1 - p_ij)^{x_ij}
%
%   输入 x 可为
%     M x 1 的分配向量（元素为目标编号，0 表示该通道不分配），或
%     M x T 的 0-1 分配矩阵。
%   输出 L 为各目标的存活概率行向量。
[M, T] = size(p);
if isvector(x) && numel(x) == M
    xt = x(:);
    X = zeros(M, T);
    for i = 1:M
        if xt(i) >= 1 && xt(i) <= T
            X(i, xt(i)) = 1;
        end
    end
else
    X = double(x);
end
L = prod((1 - p) .^ X, 1);
fval = V(:)' * L(:);
end
