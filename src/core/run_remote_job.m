function run_remote_job(experiment_setup_data_path)
!hostname
task_dir = get_parent_dir(experiment_setup_data_path);
diaries_folder=path_join(task_dir,'diaries');
my_mkdir(diaries_folder);
diary_file=create_increment_file( 'diary_',diaries_folder, 'txt', 1 );
print_var(diary_file);
diary(diary_file)

try_folder = [task_dir filesep 'trys'];
my_mkdir(try_folder)
create_increment_file( 'condor', try_folder, 'try', 0 );

global job_root_dir
load(experiment_setup_data_path,'worker_task','worker_args');
job_root_dir = task_dir;

try
    worker_result = worker_task(worker_args{:});
    job_completion_file = fopen(path_join(task_dir,'job_complete.txt'),'a');
    fclose(job_completion_file);
    myClock = clock;h = myClock(4);m = myClock(5);
    completion_time = strcat(num2str(h),'h',num2str(m),'m');
    save(experiment_setup_data_path, 'completion_time', '-append');
    save(experiment_setup_data_path, 'worker_result', '-append');
catch job_err
    fprintf(2, '%s\n', getReport(job_err, 'extended'));
    exit;
end
