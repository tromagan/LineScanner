package testbench_package;

class CUniversalRand;
    
    int min_val,max_val;
    
    rand int randval;
    
    function new(int min,max);
        min_val = min;
        max_val = max;
        //$display("CUniversalRand class constructor %d  %d ",min_val,max_val);
    endfunction

    constraint C1
    {
        randval >= min_val;
        randval <= max_val;
        
    }
   

endclass


function automatic void init_array32_data_pattern(ref int array [], input int words_cnt, input int pattern_num);
static int cnt_wrd = 0;
begin
    
    if(pattern_num == 0)
    begin
        //$display("init_array32_data_pattern(): words_cnt = %d", words_cnt);
        for(int i = 0; i < words_cnt; i++)
        begin
            array[i] = cnt_wrd++;
        end
    end
    

end
endfunction




endpackage