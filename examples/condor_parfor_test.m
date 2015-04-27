remote_submit=1;
remote_submit_host = 'corona12.doc.ic.ac.uk';
condor_verbose=1;

%% ###############
%% can supply a function handle that returns a host running the condor_schedd daemon 
%% (i.e. the thing that lets you submit jobs) instead of a
%% specific host. 
%% E.G. get_good_doc_condor_submitter() checks all the corona*.doc.ic.ac.uk,
%% ray*.doc.ic.ac.uk and line*.doc.ic.ac.uk lab machines downstairs, and returns one that is
%% running the condor_schedd

% remote_submit_host_getter=@get_good_doc_condor_submitter; 
%% ###############
condor_obj = create_condor_session('/vol/bitbucket/sb1006/condor/2', {},kv_create(remote_submit,remote_submit_host,condor_verbose));

condor_objs_acc = {};



for i = 1:5
   
    job_name = [num2str(i) '_'];
    task_dir = get_condor_job_folder(condor_obj,  job_name); %in case you need to pass the job location to the job code
    condor_obj = submit_to_condor_session(condor_obj,  @condor_parfor_test_worker, {i}, {}, kv_create(job_name));
    
end

job_list = get_condor_session_job_list(condor_obj);

my_mults = collect_condor_session_results(job_list,'my_mult');
my_dates = collect_condor_session_results(job_list,'my_date');
