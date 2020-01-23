#include <stdio.h>

#define BUFFER_SIZE 8
 
static unsigned int buffer[BUFFER_SIZE];

static int head = 0, tail = 0; 


unsigned int fifo_get(unsigned int *val)
{
    if (((tail + 1) % BUFFER_SIZE) == head) return 0xFF;
    tail = (tail + 1) % BUFFER_SIZE;
    *val = buffer[tail];
    return 0;
}

unsigned int fifo_put(unsigned int val) 
{
    if (((head + 1)% BUFFER_SIZE) == tail) return 0xFF;
    head = (head + 1) % BUFFER_SIZE;
    buffer[head] = val;
    //printf("fifo_put(): head = %d, tail = %d\n\r", head, tail);
    return 0;
}