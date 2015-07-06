function add_matador_experiment_manager_to_search_path(rc_file)

manager_script = path_join(dirname(mfilename('fullpath')),'matador_experiment_manager.sh');

cmd = concat_cell_string_array({['echo "alias matador_experiment_manager=''' manager_script '''" >> ' rc_file]},' ',1);

[~, stdout] = system(cmd);
