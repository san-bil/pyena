function test_counter(stride)
i=0;

while(1)
 i = i+stride;
 kv_print(kv_create(i));
 pause(2);
end