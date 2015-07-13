# matador
matador is a wrapper to manage job distribution from Matlab. 

matador distributes jobs to nodes using either HTCondor or its own proprietary system Hyena, which uses ssh+tmux to run jobs.

At the moment it is only supported on Linux and Mac, due to a lot of underlying calls to Unix command-line utilities like find. It might be possible to port to Windows by using UnxUtils/GnuWin32/Cygwin, but there are no immediate plans to do that at the moment.


Hyena has the functionality to start jobs directly on a node (bypassing the need for a centralized cluster manager such as Condor), however this presents both advantages and disadvantages. The advantages are:
* your jobs will run immediately
* your jobs cannot be pre-empted

However, the disadvantages:
* Hyena doesn't yet support job restarting in case of power failure or a superuser killing your processes or someone just restarting the box
* you might be violating the honour code of machine/cluster usage in your organization
* your sysadmins will come and hit you with a stick

So you're advised to use it sparingly. HTCondor is a great system, but sometimes the scheduler can be a questionably stingy despite no-one else running jobs, or maybe you just need a boatload of compute at the last second (perhaps across multiple domains). In such a case, Hyena might prove useful.



### Install

Using this project requires cloning the dependencies listed in matlab_requirements.txt. Then add this folder and the dependency folders to your MATLAB path.

## Usage

###### kv_map data structure
In the guide below, a map refers to a key-value map (like a python dictionary). Since these do not exist in MATLAB, we wrote a bunch of utility functions to emulate them, in sbmat_core/key_val/. A map is just a Nx2 cellarray, where the first column contains the keys, and the second column contains the corresponding values e.g.:
```
	opts_map = {
    				'condor_rsync_args','--exclude="*.mat"';
    				'ssh_key','/home/$USER/.ssh/id_rsa'
                }
```

This structure is used for passing many of the options in the usage guide below. You can either use the utility functions `kv_create()` or `kv_create_w_names()` to create these dictionaries, or just construct the cell-array yourself. Up to you.

##### Sessions

The main functions for usage are:

###### HTcondor-backed
* `session_object = create_condor_session(session_root_dir, volatile_src_paths, session_options)`
* `submit_to_condor_session(session_object,  worker_task, worker_args, job_tags, options)`
* `submit_to_condor_session_synchronous(session_object,  worker_task, worker_args, job_tags, options)`


###### Hyena-backed
* `create_hyena_session(session_root_dir, volatile_src_paths, session_options)`
* `submit_to_hyena_session(session_object,  worker_task, worker_args, job_tags, options)`
* `submit_to_hyena_session_synchronous(session_object,  worker_task, worker_args, job_tags, options)`

In both cases, the `session_root_dir` is a single folder in which the state of the session will be kept, as well as all the necessary files for all the jobs to run. `volatile_src_paths` is a cell-array of folder paths in which **all the necessary source for a job can be found**. 

When submitting a job to a session, the user passes (along with the session object) the main worker function as a callback (`worker_task`), and all of its arguments in a cell-array (`worker_args`). They also have the option to add some string tags to the specific job (such as "validation" or "imagenet" or whatever). There are also more options that can be passed for that specific job submission, however see the corresponding function source for more details on valid options.

The `submit_to_*` functions submit a job to either Condor or Hyena asynchronously, so you can loop over e.g.  a large hyperparameter space and run all your jobs in parallel. You can synchronize on the completion of all your jobs using `matador_wait_on_files(session_object)`.

The `submit_to_*_synchronous` functions do what it sounds like - whilst the `worker_task()` is run remotely, the local machine waits for the job to finish. It also only returns a single numeric value - this is primarily useful with hyperparameter optimizers like [BayesOpt](https://github.com/rmcantin/bayesopt) that require nothing but a blackbox callback that takes a vector and returns a function value.

##### Loop-caching
HTCondor is often deployed in "cycle-scavenging" mode, such that the unused CPU cycles of workstations and servers can be put to good use when there is no user logged in (for example, overnight). However this means if someone does log in to their workstation (which is part of the cluster), even if just for 10s to check their Game of Thrones torrent, your job will get kicked, and rescheduled on another machine. So the job loses all its progress up to that point.

Hence, a way to cache intermediate results of long-running jobs is essential. Loops can be a bit tricky to cache correctly, so there are some functions in src/loop_caching to help.

These are:
*	`setup_loop_cache(opts_map)`
*	`check_loop_cache()`
*	`write_loop_cache()`

Modifying your own code to cache loops using these functions adds no more than 8 lines, and an example can be found in matador/examples/loop_cache_example_new.m. The main bit you need to think about is what expensive loop-variant object you want to save.

This can also be used for caching straight code blocks instead of loops (by unrolling the loops, see `matador/examples/straight_cache_example_new.m`, however we wrote it for the more general case of loops since they're more finicky.


##### Results collection
