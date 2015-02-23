function out = condor_parfor_test_worker(in)

my_mult = 2^in;
my_date = get_simple_date();



out = kv_create(my_mult,my_date);
disp('Bye!')