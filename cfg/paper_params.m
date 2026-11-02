function P = paper_params()
%PAPER_PARAMS 论文 2.2 / 2.3 节全部参数（单一出处，改这里即可全量重算）
%
%   用法：
%       P = paper_params();
%       disp(P.NS)
%
%   参数口径说明：
%     1) 2.2 节拓扑模型取对称编队 N_S = N_C = N_E = N = 5，q = 0.5，eta = 0.9；
%     2) 4.3 节的非对称编队 12 / 5 / 8 用于交叉核对 3.6% 的崩溃概率；
%     3) 2.3 节兰彻斯特方程的单平台杀伤率为量级假设（1/min），
%        取值仅用于演示 α_R^eff 的稀释效果与交会趋势，不代表实兵数据；
%     4) 兵力结构取 4.1 节口述编成：1 架 B-21 + 4 架 F-35A、12 架 CCA、
%        24 枚 MALD-X + 16 架 X-61A 共 40 个可消耗/诱饵节点。

P = struct();

%% ---------- 2.2 拓扑与连通概率模型 ----------
P.NS = 5;                  % 感知节点数
P.NC = 5;                  % 指挥控制节点数
P.NE = 5;                  % 打击火力节点数
P.q  = 0.50;               % 单节点战损率（独立同分布）
P.eta = 0.90;              % 单跳链路连通概率
P.q_grid = linspace(0.01, 0.99, 99);   % q 扫描
P.eta_grid = linspace(0.02, 1.00, 99); % eta 扫描
P.N_grid = 1:20;                       % 编队规模扫描

%% ---------- 非对称编队（4.3 节，交叉核对用） ----------
P.asym.NS = 12;
P.asym.NC = 5;
P.asym.NE = 8;
P.asym.q = 0.50;
P.asym.eta = 0.90;

%% ---------- 蒙特卡洛 ----------
P.mc.trials = 400000;      % 与论文“40 万次抽样”一致
P.mc.block  = 20000;       % 分块，控制内存
P.mc.seed   = 20261102;

%% ---------- 2.3 兰彻斯特方程 ----------
P.lan.B0     = 6;          % 蓝方有人作战单元（B-21 ×1 + F-35A ×4 + 备份 1）
P.lan.R0     = 24;         % 红方空中作战单元（8 架五代 + 16 架四代半）
P.lan.alphaB = 0.0300;     % 蓝方单平台平均杀伤率 (1/min)，量级假设
P.lan.alphaR = 0.0240;     % 红方单平台平均杀伤率 (1/min)，量级假设
P.lan.tspan  = [0 20];     % 交战时长 (min)：覆盖传统架构的耗尽时刻
P.lan.dt     = 0.05;

%% ---------- 兵力结构与诱骗逼真度 ----------
P.force.B_manned = 5;      % 高价值有人节点（式中 B_manned）
P.force.B_CCA    = 12;     % 协同作战飞机
P.force.B_decoy  = 40;     % 24×MALD-X + 16×X-61A
P.force.kappa1   = 0.75;   % 无人节点特征逼真度
P.force.kappa2   = 0.50;   % 诱饵节点特征逼真度
P.force.kappa_grid = linspace(0, 1, 51);
% 论文摘要给出的有人机战损率下降区间，用于校核
P.force.loss_reduction_target = [0.83 0.87];

%% ---------- 2.3 WTA 规模 ----------
P.wta.M     = 24;          % 火力通道数（论文 2.3.2 节量级估算）
P.wta.T     = 40;          % 待分配目标数
P.wta.smallM = 6;          % 精确枚举规模
P.wta.smallT = 8;
P.wta.midM   = 8;          % 分支定界规模
P.wta.midT   = 10;
P.wta.seed   = 7;
P.wta.mj_max = 2;          % 单个目标可重复拦截的弹数上限
P.wta.eps0   = 0.02;       % 拍卖算法初始 eps
P.wta.eps_list = [1.0 0.5 0.2 0.1 0.05 0.02 0.01];  % eps-CS 扫描
P.wta.bnb_maxNodes = 3e5;  % 分支定界节点上限（超限则报告持平解）

%% ---------- 成本（万美元，取 2.3 节正文单价区间） ----------
P.cost.interceptor = [150 400];  % 远程防空拦截弹（48N6E3 / 40N6E / PAC-3 MSE）
P.cost.decoy       = [32 40];    % ADM-160C MALD-J
P.cost.ale         = [10 20];    % 小型空射效应器 ALE
P.cost.manned      = 8000;       % 有人机（8 000 万美元级）

%% ---------- 输出与绘图 ----------
P.fig.dpi    = 300;
P.fig.font   = 'Microsoft YaHei';
P.fig.fontSize = 9;
P.out.dir    = fullfile(proj_root(), 'out');
end
