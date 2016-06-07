function remote_add_relevant_src_paths(data_path)

load(data_path,'src_paths');
for i = 1:length(src_paths)
    addpath(genpath(src_paths{i}));
end