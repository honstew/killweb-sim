function S = cost_exchange(P)
%COST_EXCHANGE 成本交换比（2.3 节“成本天平逆转”的单次交战口径）
%
%   S = cost_exchange(P)
%
%   口径说明：2.3 节只给出装备与弹药单价，因此本函数计算的是
%     (a) 单价级交换比：蓝方被消耗节点单价 / 红方拦截弹单价；
%     (b) 弹匣级交换比：蓝方投放一批可消耗节点换取红方一个远程防空营
%         全部待发弹（8 部发射车 × 4 发 = 32 发）时的总成本比。
%   论文正文与表 tab:killweb_metrics 给出的 3.8:1 -> 0.65:1 是第 4/5 章
%   想定推演的体系级结果，含拦截成功率、交换架次与弹药基数，不由本节模型
%   直接解出；本函数不反推该值，以免口径混淆。
intC   = linspace(P.cost.interceptor(1), P.cost.interceptor(2), 60);  % 万美元
decoyC = mean(P.cost.decoy);     % MALD-X 单价
aleC   = mean(P.cost.ale);       % 小型空射效应器单价
mannedC = P.cost.manned;

S = struct();
S.intCost = intC;
S.ratioManned = mannedC ./ intC;      % 有人机被拦截时的单价交换比
S.ratioDecoy  = decoyC ./ intC;       % 诱饵被拦截时的单价交换比
S.ratioALE    = aleC ./ intC;

% 弹匣级：24 枚 MALD-X + 16 架 X-61A 换取一个营 32 发待发弹
nBlue = 24 + 16;
blueCost = 24 * decoyC + 16 * aleC;   % 万美元
redCost  = 32 * mean(P.cost.interceptor);
S.magazine.blueCost = blueCost;
S.magazine.redCost  = redCost;
S.magazine.ratio    = blueCost / redCost;
S.magazine.decoyC = decoyC;
S.magazine.aleC = aleC;
S.magazine.intC = mean(P.cost.interceptor);
S.magazine.nBlue = nBlue;
S.magazine.nRed = 32;
end
