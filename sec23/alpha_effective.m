function aEff = alpha_effective(alphaR, Bmanned, B_CCA, B_decoy, k1, k2)
%ALPHA_EFFECTIVE 诱饵与无人节点稀释后的红方有效杀伤率（式 eq:alpha_eff）
%
%   aEff = alphaR * B_manned ./ (B_manned + k1*B_CCA + k2*B_decoy)
%
%   物理含义：红方无法在远距离区分高价值有人机与低价值诱饵，其火力
%   按“可探测目标数”摊薄，只有 B_manned/(有效目标总数) 的比例落到有人机上。
%
%   输入可为同尺寸数组（用于 eta/kappa 扫描）。
aEff = alphaR .* Bmanned ./ (Bmanned + k1 .* B_CCA + k2 .* B_decoy);
end
