function out = get_condor_job_stderr(idx, condor_session_obj, varargin)

out = get_condor_job_text_output('err.txt', idx, condor_session_obj, varargin{:});
