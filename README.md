# matador
A wrapper to manage HTCondor jobs from Matlab. 

Also has functionality to start direct jobs (bypassing the need for Condor) via "Hyena", which uses ssh+tmux. This doesn't yet support job restarting in case of power failure or someone killing your processes though.

Using this project requires cloning the dependencies listed in matlab_requirements.txt into the relative path ./deps/. Do this manually, or using the project manager script at https://github.com/san-bil/matprojman to do dependency management for you.
