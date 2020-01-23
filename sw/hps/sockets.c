#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "sockets.h"


const uint16_t  i_port = 2592;          //server port

int s = -1;

uint32_t socket_connect(char *s_addr)
{
    printf("Create socket\n\r");
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0) 
    {
      printf("create socket error\n\r");
      return 1;
    }


    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(s_addr);
    server_addr.sin_port = htons(i_port);

    printf("Trying connect\n\r");
    if (connect(s, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        printf("connect failed\n\r");
        return 1;
    }

    return 0;
}


uint32_t socket_send(volatile uint32_t *buf, uint32_t size_bytes)
{
  write(s, (void *)buf, size_bytes); 
  return 0;
}

void socket_close()
{
    if(s > 0)
        close(s);
}