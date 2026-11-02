function save_tex_table(name, header, rows, caption)
%SAVE_TEX_TABLE 输出 booktabs 三线表片段到 out/，可直接 \input 进论文
d = fullfile(proj_root(), 'out');
if ~exist(d, 'dir')
    mkdir(d);
end
fid = fopen(fullfile(d, [name '.tex']), 'w', 'n', 'UTF-8');
assert(fid > 0, '无法写入 %s', name);
fprintf(fid, '%% 由 matlab/run_all.m 自动生成，勿手工修改\n');
fprintf(fid, '\\begin{tabular}{l%s}\n\\toprule\n', repmat('r', 1, numel(header) - 1));
fprintf(fid, '%s \\\\\n\\midrule\n', strjoin(header, ' & '));
for i = 1:size(rows, 1)
    fprintf(fid, '%s \\\\\n', strjoin(rows(i, :), ' & '));
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('  [表格] out/%s.tex  (%s)\n', name, caption);
end
