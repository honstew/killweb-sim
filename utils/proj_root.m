function r = proj_root()
%PROJ_ROOT 返回 matlab/ 工程根目录（utils/ 的上一级）
r = fileparts(fileparts(mfilename('fullpath')));
end
