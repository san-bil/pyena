
submit_host='sb1006@ray03.doc.ic.ac.uk';
condor_profile_provider=@get_doc_ic_ac_uk_condor_profile;

submit_host='localhost';
condor_profile_provider=@get_vanilla_condor_profile;

%% ###############
%% can supply a function handle that returns a host running the condor_schedd daemon 
%% instead of a specific host. 
%% E.G. get_good_doc_condor_submitter() checks all the corona*.doc.ic.ac.uk,
%% ray*.doc.ic.ac.uk and line*.doc.ic.ac.uk lab machines downstairs, and returns one that is
%% running the condor_schedd

% remote_submit_host_getter=@get_good_doc_condor_submitter; 
%% ###############
new_session_folder = create_increment_folder('condor_test_','/home/sanjay/bitbucket/sb1006/condor_dev');
condor_obj = create_condor_session(new_session_folder, {}, kv_create(submit_host,condor_profile_provider));

condor_objs_acc = {};

for i = 1:5
   
    job_name = [num2str(i) '_'];
    condor_root_dir = get_condor_job_folder(condor_obj,  job_name); %in case you need to pass the job location to the job code
    condor_obj = submit_to_condor_session(condor_obj,  @condor_parfor_test_worker, {i, kv_create(condor_root_dir)}, {}, kv_create(job_name));
    
end

job_list = get_condor_session_job_list(condor_obj);

my_mults = collect_condor_session_results(job_list,'my_mult');
my_dates = collect_condor_session_results(job_list,'my_date');
