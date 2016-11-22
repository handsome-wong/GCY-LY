# ifndef __PROTOOL_H__
#define __PROTOOL_H__
#include "ringbuffer.h"
#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#include "protocol.h"


/* interfaces */
int init_ringbuffer(struct CircularBuffer* buffer, int size);
void del_ringbuffer(struct CircularBuffer* buffer);

void make_frame(UCHAR* packet, const UINT16 work_id , const UCHAR* data, const UINT16 data_len);

int put_recvdata(struct CircularBuffer* buffer, UCHAR* recvdata, UINT16 len);
int parse_frame(struct CircularBuffer* buffer, UCHAR* packet);

void print_current_frame(struct CircularBuffer* buffer);
void print_ringbuffer(struct CircularBuffer* buffer);
#endif 
