import getpass

def get_doc_candidate_list(host_family_order=[], username=getpass.getuser()):


    machine_count_map = {
                          'matrix':range(1,38),\
                          'texel':range(1,38),\
                          'line':range(1,34),\
                          'ray':range(1,40),\
                          'voxel':range(1,27),\
                          'corona':range(1,41) \
                      };
    #machine_count_map = kv_order_keys(host_family_order,machine_count_map);
    if(not host_family_order==[]):
        raise NotImplementedError('host ordering isnt implemented yet')

    all_candidates = [];

    for i in machine_count_map.iterkeys():
        
    

        host_idxs = machine_count_map[key]
    
        tmp_hosts=map(lambda(tmp):username+'@'+key+('%2.2d' % (tmp))+'.doc.ic.ac.uk', host_idxs);
        all_candidates = all_candidates+tmp_hosts;



    return all_candidates

def get_doc_ic_ac_uk_condor_profile():

    out['condor_job_requirements']='requirements = regexp("^(texel|ray|pixel|edge|corona|ianos|line)..", TARGET.Machine)';
    out['presubmit_auth_steps']="'kinit $USER@IC.AC.UK -k -t $HOME/.kerb/$USER.keytab'";

    return out


def get_good_doc_condor_submitter():
    all_candidates = get_doc_candidate_list()    
    for candidate_host in all_candidates:
        is_condor_running = check_condor_running_on_remote(candidate_host)
        if(is_condor_running):
            return candidate_host;
    
    
