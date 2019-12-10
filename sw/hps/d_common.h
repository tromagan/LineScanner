#ifndef _D_COMMON_H_
#define _D_COMMON_H_

#include <linux/ioctl.h>
// #include <linux/dma-mapping.h>

#define DMALLOC_IOC_MAGIC 0x5100CC

#define IOCTL_DGET	_IO(DMALLOC_IOC_MAGIC, 0)
// #define IOCTL_PFREE	_IO(DMALLOC_IOC_MAGIC, 1)



#define DMALLOC_FILE_NAME "dma_alloc"
#define DMALLOC_DEV_FILE_NAME "/dev/" DMALLOC_FILE_NAME


struct dmalloc_request{
	// int id;
	unsigned char *buffer;
	unsigned long int paddr;
	// unsigned int size;
};

#endif

