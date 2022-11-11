function output = read_json(fpath)

fid = fopen(fpath);
raw = fread(fid,inf);
info = char(raw');
fclose(fid);
output = jsondecode(info);
