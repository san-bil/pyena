function out = get_doc_ic_ac_uk_condor_profile()

condor_job_requirements='requirements = regexp("^(texel|ray|pixel|edge|corona|ianos|line)..", TARGET.Machine)';
presubmit_auth_steps='''kinit $USER@IC.AC.UK -k -t $HOME/.kerb/$USER.keytab''';

out = kv_create(condor_job_requirements,presubmit_auth_steps);