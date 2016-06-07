function matador_check_is_job_cancelled()

job_cancellation_file = get_global_job_root_dir('/cancel_job.txt');

if(exist(job_cancellation_file, 'file'))
    
    fprintf('MATADOR: Exiting job due to cancellation.\n');
    exit();
    
end