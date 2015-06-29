function print_matador_session_err_files(err_files_list)


for i =1:length(err_files_list)
    
    err_file = err_files_list{i};
    lines = read_lines(err_file);
    fprintf('\n-----------------\n');
    fprintf('%s:\n',err_file);
    disp_cellstr(lines,'     ',1);
    
end