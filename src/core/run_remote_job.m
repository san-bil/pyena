function run_remote_job(experiment_setup_data_path)
!hostname
task_dir = get_parent_dir(experiment_setup_data_path);
try_folder = [task_dir filesep 'trys'];
my_mkdir(try_folder)
create_increment_file( 'condor', try_folder, 'try', 1 );


load(experiment_setup_data_path,'worker_task','worker_args');
%src_paths = {...}
%executer = @fn_handle
%args = {...}

worker_result = worker_task(worker_args{:});

job_completion_file = fopen([task_dir filesep 'job_complete.txt'],'a');
fclose(job_completion_file);

myClock = clock;h = myClock(4);m = myClock(5);
completion_time = strcat(num2str(h),'h',num2str(m),'m');
save(experiment_setup_data_path, 'completion_time', '-append');
save(experiment_setup_data_path, 'worker_result', '-append');

