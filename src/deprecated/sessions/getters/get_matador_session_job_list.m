function job_list = get_matador_session_job_list(session_object, retrieve_job_tags, partial_tag_set_matching, include_or_exclude )

job_list = get_condor_session_job_list(session_object, retrieve_job_tags, partial_tag_set_matching, include_or_exclude );