function out = get_condor_job_stdout(idx, condor_session_obj, varargin)

out = get_condor_job_text_output('output.txt', idx, condor_session_obj, varargin{:});
