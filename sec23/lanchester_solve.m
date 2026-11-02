function S = lanchester_solve(alphaB, alphaR, B0, R0, tspan)
%LANCHESTER_SOLVE 兰彻斯特平方律数值解（式 eq:lanchester）
%
%   S = lanchester_solve(alphaB, alphaR, B0, R0, tspan)
%
%   dB/dt = -alphaR*R,   dR/dt = -alphaB*B
%   积分到任一方兵力归零（事件检测）或 tspan 结束。
%
%   输出
%     S.t, S.B, S.R     时间序列
%     S.invariant       守恒量 alphaR*R^2 - alphaB*B^2（应沿轨迹为常数）
%     S.tEnd            交战结束时间
%     S.Bend, S.Rend    结束时兵力
%     S.winner          'blue' | 'red' | 'stalemate'
%     S.ratio           胜负判据 alphaB*B0^2 / (alphaR*R0^2)
if nargin < 5 || isempty(tspan)
    tspan = [0 90];
end
odef = @(t, y) [-alphaR * y(2); -alphaB * y(1)];
opt = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @stopEvent);
[t, y] = ode45(odef, tspan, [B0; R0], opt);

S = struct();
S.t = t;
S.B = max(y(:, 1), 0);
S.R = max(y(:, 2), 0);
S.invariant = alphaR * S.R.^2 - alphaB * S.B.^2;
S.tEnd = t(end);
S.Bend = S.B(end);
S.Rend = S.R(end);
S.alphaB = alphaB;
S.alphaR = alphaR;
S.B0 = B0; S.R0 = R0;
if S.Bend > 1e-6 && S.Rend <= 1e-6
    S.winner = 'blue';
elseif S.Rend > 1e-6 && S.Bend <= 1e-6
    S.winner = 'red';
elseif S.Bend <= 1e-6 && S.Rend <= 1e-6
    S.winner = 'mutual';
else
    S.winner = 'stalemate';
end
S.ratio = alphaB * B0^2 / (alphaR * R0^2);
end

function [value, isterminal, direction] = stopEvent(~, y)
value = [y(1) - 1e-6; y(2) - 1e-6];
isterminal = [true; true];
direction = [-1; -1];
end
