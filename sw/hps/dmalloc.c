#include "dmalloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <inttypes.h>

#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include "d_common.h"

static int dmalloc_dev = 0;

int dminit(){
	dmalloc_dev = open(DMALLOC_DEV_FILE_NAME, O_RDWR | O_SYNC);
	if(dmalloc_dev & 0x80000000){
		fprintf(stderr, "open(\"%s\") failed\n", DMALLOC_DEV_FILE_NAME);
		return -1;
	}
	return dmalloc_dev;
}

void dmfini(){
	close(dmalloc_dev);
}


// int dphysaddr(int size){
unsigned long int dphysaddr(){
	struct dmalloc_request request;
	//printf("123\n");
	if(ioctl(dmalloc_dev, IOCTL_DGET, &request)) return 0;
	//printf("456\n");
	
	//unsigned long val = (unsigned long) request.paddr;

	//printf("da: 0x%" PRIx64 "\n", val);
	// возвраащется только id 
	// хотя здесь ещё хранит в буфере свой физический адрес
	return request.paddr;
}


// int dmread(int id, void *dst, int size){
// 	struct dmalloc_request request;
// 	request.id = id;
// 	request.buffer = dst;
// 	request.size = size;
// 	return ioctl(dmalloc_dev, IOCTL_PREAD, &request);
// }

// void *dmget(int id){
// 	struct dmalloc_request request;
// 	request.id = id;
// 	if(ioctl(dmalloc_dev, IOCTL_PGET, &request)) return 0;
// 	return request.buffer;
// }

// int dmalloc(int size){
// 	struct dmalloc_request request;
// 	request.size = size;
// 	if(ioctl(dmalloc_dev, IOCTL_PALLOC, &request)) return 0;
// 	// возвраащется только id 
// 	// хотя здесь ещё хранит в буфере свой физический адрес
// 	return request.id;
// }

// void dmfree(int id){
// 	struct dmalloc_request request;
// 	request.id = id;
// 	ioctl(dmalloc_dev, IOCTL_PFREE, &request);
// 	return;
// }