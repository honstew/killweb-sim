function run_all()
%RUN_ALL 一键运行：论文 2.2 / 2.3 节算法的全部算例、图件、一致性校核与报告
%
%   用法（命令行）：
%       cd matlab
%       matlab -batch run_all
%   或在 MATLAB 中直接执行：
%       run_all
%
%   输出：
%       out/figs/fig22_F1..F6.png(+pdf)   2.2 节 6 张图
%       out/figs/fig23_G1..G5.png(+pdf)   2.3 节 5 张图
%       out/tab_sec22.tex, out/tab_sec23.tex   可直接 \input 的三线表
%       out/results/sec22.mat, sec23.mat  全部中间结果
%       out/report.md                     汇总报告
t0 = tic;
root = fileparts(mfilename('fullpath'));
addpath(genpath(root));
warning('off', 'MATLAB:legend:IgnoringExtraEntries');

fprintf('================================================================\n');
fprintf(' 论文 2.2 / 2.3 节算法实现与数值计算\n');
fprintf(' 工程目录：%s\n', root);
fprintf('================================================================\n');

P = paper_params();
R22 = demo_sec22(P, true);
R23 = demo_sec23(P, true);
T = test_paper_numbers(P);
write_report(P, R22, R23);

fprintf('\n================================================================\n');
fprintf(' 完成：%d 项一致性校核通过，用时 %.1f s\n', sum(T.pass), toc(t0));
fprintf(' 图件：out/figs/  表格：out/tab_*.tex  报告：out/report.md\n');
fprintf('================================================================\n');
end
