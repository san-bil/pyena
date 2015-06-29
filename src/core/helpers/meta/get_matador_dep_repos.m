function matador_deps=get_matador_dep_repos()
matador_dir = get_matador_dir();
matador_deps = cell2str(head(read_lines(path_join(matador_dir,'matlab_requirements.txt'))));
