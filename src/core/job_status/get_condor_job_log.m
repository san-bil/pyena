function out = get_condor_job_log(idx, condor_session_obj, varargin)

out = get_condor_job_text_output('log.txt', idx, condor_session_obj, varargin{:});
