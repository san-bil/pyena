function linepart = condor_get_job_submission_id(message)

lines = strsplit(message,'\n');

filterlines = filter_string_list(lines,'cluster');
try
    linepart_start=regexp(filterlines{1},'cluster');

    linepart=filterlines{1}(linepart_start:end);
    linepart=strrep(linepart,'cluster ','');
catch
    linepart='';
    disp('Job ID not available - submission host returned message:')
    disp(message)
end