function inst = wta_instance(M, T, seed, mjMax)
%WTA_INSTANCE 生成武器-目标分配（WTA）算例：杀伤概率矩阵与目标威胁价值
%
%   inst = wta_instance(M, T, seed, mjMax)
%
%   目标构成（按论文 4.1 节兵力结构）：1 个有人指挥节点（最高价值）、
%   若干 CCA（中等）、其余为诱饵/可消耗节点（最低）。价值 V 与“单通道
%   毁伤概率 p”呈反向关系：越贵的节点越难打。
%
%   输出
%     inst.p     M x T 单次交战毁伤概率 p_ij
%     inst.V     T x 1 目标威胁价值 V_j（归一化，有人指挥节点 = 100）
%     inst.mj    T x 1 单目标可重复拦截的弹数上限 m_j
%     inst.type  T x 1 类别（1 有人 / 2 CCA / 3 诱饵）
%     inst.label 类别中文名
if nargin < 3 || isempty(seed)
    seed = 7;
end
if nargin < 4 || isempty(mjMax)
    mjMax = 2;
end
oldState = rng;
rng(seed, 'twister');

nCCA   = min(12, max(T - 1, 0));
nManned = 1;
nDecoy = T - nManned - nCCA;

type = [ones(nManned, 1); 2 * ones(nCCA, 1); 3 * ones(nDecoy, 1)];
V = zeros(T, 1);
V(type == 1) = 100;
V(type == 2) = 30;
V(type == 3) = 5;

% 目标“硬度”：越贵越难毁伤
h = zeros(T, 1);
h(type == 1) = 0.35;
h(type == 2) = 0.70;
h(type == 3) = 1.00;

% 火控通道能力（异构）：不同通道对同一目标的毁伤概率不同
cap = 0.35 + 0.50 * rand(M, 1);
p = cap * h' .* (0.85 + 0.30 * rand(M, T));
p = min(max(p, 0.02), 0.98);

mj = ones(T, 1);
mj(type == 1) = mjMax;          % 高价值目标允许多弹拦截

rng(oldState);
inst = struct('p', p, 'V', V, 'mj', mj, 'type', type, ...
    'label', {{'有人指挥', 'CCA', '诱饵/ALE'}}, 'M', M, 'T', T, 'seed', seed);
end
