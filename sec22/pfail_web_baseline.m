function P = pfail_web_baseline(N, q)
%PFAIL_WEB_BASELINE 杀伤网的崩溃概率下界（式 eq:survive，eta = 1 基准）
%
%   P_fail = 1 - (1 - q^N)^3
%
%   崩溃的充要条件：某一类功能节点被全部歼灭。三类事件独立，
%   存活概率为 (1 - q^N)^3。
%
%   输入
%     N : 每类节点数；标量或与 q 同尺寸的数组
%     q : 单节点战损率；标量或数组
%
%   输出
%     P : 崩溃概率。N=5, q=0.5 时为 9.085%。
P = 1 - (1 - q.^N).^3;
end
