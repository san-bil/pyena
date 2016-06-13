#!/usr/bin/python2.7
import os,sys

task_dir=os.path.dirname(os.path.realpath(__file__))
os.chdir(task_dir)

python_path_additions=[x.strip() for x in open(os.path.join(task_dir,'python_path_additions.txt')).readlines()]
sys.path+=python_path_additions
print('\n'.join(sys.path));

import cloudpickle;
import pyena.src.core

pyena.src.core.run_remote_job(os.path.join(task_dir,'task_data.p'))
sys.exit()


