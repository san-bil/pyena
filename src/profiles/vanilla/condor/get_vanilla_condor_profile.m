function out = get_vanilla_condor_profile()

presubmit_auth_steps='''echo No pre-auth steps required.''';

out = kv_create(presubmit_auth_steps);