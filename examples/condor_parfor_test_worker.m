function out = condor_parfor_test_worker(in, opts)

my_mult = 2^in;
print_var(in)
my_date = get_simple_date();
print_var(my_date)




for i =1:20
    print_var(i);
    pause(1);
end

disp(breaking_variable)

out = kv_create(my_mult,my_date);
disp('Bye!')