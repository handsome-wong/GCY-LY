#include <stdio.h>
#include "protool.h"
#include "protocol.h"
#include <time.h>
#include <string.h>
#include <errno.h>


static UINT16 flow_id = 0;
int n =0;

/* function declaration */
int prot_parse_protocol_head(struct CircularBuffer*);
int prot_parse_protocol_tail(struct CircularBuffer*, UINT16 offset);
int prot_get_protocol_length(struct CircularBuffer*);
int prot_get_data(struct CircularBuffer* buffer,UINT16 offset, UINT16 length, UCHAR* data);
int prot_get_protocol_data(struct CircularBuffer* buffer,UINT16 length, UCHAR* data );
int prot_check_crc16(struct CircularBuffer* buffer, UINT16 length);
UINT16 prot_parse_type(struct CircularBuffer* buffer);	
UINT16 prot_crc16(UCHAR* data, UINT16 len);
int prot_parse_protocol(struct CircularBuffer* buffer, UCHAR*);
int prot_make_frame(UCHAR* packet, const UINT16 data_length, const UINT16 version, const UINT16 work_id, const UCHAR  encrypt_type, const UCHAR* data);
void prot_print_protool(struct CircularBuffer* msg_receved);
int prot_parse_frame(struct CircularBuffer* buffer, UCHAR* packet);

extern int cbNew(struct CircularBuffer *cb, int size);
extern void cbFree(struct CircularBuffer *cb);
extern void cbClean(struct CircularBuffer *cb);
extern int cbIsEmpty(struct CircularBuffer *cb);
extern int returnToPre(struct CircularBuffer *cb);
extern int preToCurrentRead(struct CircularBuffer *cb);
extern void cbPrintAll(struct CircularBuffer *cb);
extern int cbWrite(struct CircularBuffer *cb, const UCHAR* msg, int length);
extern int cbRead(struct CircularBuffer *cb, UCHAR* msg, int length);
extern int cbReadhasOffset(struct CircularBuffer *cb, UCHAR* msg, int offset, int length);
extern int cbReadByte(struct CircularBuffer *cb, UCHAR* msg);

/* function definition */
int init_ringbuffer(struct CircularBuffer* buffer, int size)
{
	LOG(DL_ENTER);
	if(buffer == NULL)
	{
		LOG(DL_ERROR, "buffer is null\n");
		return -1;	
	}
	if(size < 0)
	{
		LOG(DL_ERROR, "size < 0\n");
		return -1;
	}
	return cbNew(buffer, size);
}

void del_ringbuffer(struct CircularBuffer* buffer)
{
	LOG(DL_ENTER);
	if(buffer == NULL)
	{
		LOG(DL_ERROR, "buffer is null\n");
		return ;	
	}
	cbFree(buffer);
}

int prot_parse_protocol_tail(struct CircularBuffer* buffer, UINT16 offset)
{
	LOG(DL_ENTER);
	UCHAR b[TAIL_LEN] ={0};
	// while(1)
	// {
		memset(b, 0, sizeof(UCHAR)*TAIL_LEN);
		if (prot_get_data(buffer, offset, TAIL_LEN, b))
		{
			
			if (memcmp(b, TAIL, TAIL_LEN) == 0)
			{
//				printf("succed to get tail\n");
				return 0;
			}
			else
			{
				return -1;
			}
		}
		else
		{
			return -1;
			//usleep(1000);
		}
	//}
}

int prot_parse_protocol_head(struct CircularBuffer* buffer)
{
	LOG(DL_ENTER);
	UCHAR b[HEAD_LEN] ={0};
	returnToPre(buffer);
	// while(1)
	// {
		memset(b, 0, sizeof(UCHAR)*HEAD_LEN);
		if (cbRead(buffer, b, HEAD_LEN))
		{
			if (memcmp(b, HEAD, HEAD_LEN) == 0)
			{
				//preToCurrentRead(buffer);
				return 0;
			}
			else /* if read head data is an error data, continue read until head */
			{
				returnToPre(buffer);
				cbReadByte(buffer, b);
				preToCurrentRead(buffer);
			}
		}

		// else
		// {
		// 	usleep(1000);
		// }
	//}
	return -1;
}


int prot_get_protocol_length(struct CircularBuffer* buffer)
{
	LOG(DL_ENTER);
	UCHAR len[COUNT_LEN] ={0};
	int length = 0;
    // while (1)
    // {
        memset(len, 0, sizeof(UCHAR)*COUNT_LEN);
        if (prot_get_data(buffer, 2, COUNT_LEN, len)> 0)
        {
			length = *(UINT16 *)(len);
			if (length < FIXED_PART_LEN || length > FIXED_PART_LEN+ DATA_MAX_LEN)
			{
				return -1;
			}
			return length;
        }
 		else
        {
			return -1;
        }
   // }
}

int prot_get_protocol_data(struct CircularBuffer* buffer, UINT16 length, UCHAR* data )
{
	LOG(DL_ENTER);
	prot_get_data(buffer, DATA_OFFSET, length - FIXED_PART_LEN, data);
	return 0;
}


int prot_get_data(struct CircularBuffer* buffer, UINT16 offset, UINT16 length, UCHAR* data )
{
	LOG(DL_ENTER);
	int readlen = 0;
	if (length < 0)
	{
		LOG(DL_ERROR, "length < 0\n");
		return -1;
	}
	if (offset < 0)
	{
		LOG(DL_ERROR, "offset < 0\n");
		return -1;
	}
	if (data == NULL)
	{
		LOG(DL_ERROR, "data is null\n");
		return -1;
	}
    //while (1)
    //{
	    memset(data, 0, sizeof(UCHAR)*length);

	    readlen = cbReadhasOffset(buffer, data, offset, length);
	    if (readlen == length){
//		   	returnToPre(buffer);
	        return readlen;
	    }
	 	else
		{
	    	return -1;
		}
	//}
}


UINT16 prot_parse_type(struct CircularBuffer* buffer)
{
	LOG(DL_ENTER);
	UCHAR type[2] = {0};
       	prot_get_data(buffer, TYPE_OFFSET, 2, type);	
	return *(UINT16*)(type);
}

UINT16 prot_crc16(UCHAR *buf, UINT16 length)
{
	LOG(DL_ENTER);
	if (length < 0)
	{
		LOG(DL_ERROR, "length < 0\n");
		return -1;
	}
    UINT32 i;
    UINT32 j;
    UINT32 c;
    UINT16 crc = 0xFFFF;
    for (i=0; i<length; i++)
    {
        c = *(buf+i) & 0x00FF;
        crc^=c;
        for (j=0; j<8; j++)
        {
             if (crc & 0x0001)
             {
                crc >>= 1;
                crc ^= 0xA001;
             }
             else
             { 
                crc >>= 1;
             }
       }
  }
    crc = (crc>>8) + (crc<<8);
    return(crc);
}
int prot_check_crc16(struct CircularBuffer* buffer, UINT16 length)
{
	LOG(DL_ENTER);

	UCHAR crc[2] ={0};
	UCHAR* elem = (UCHAR*)malloc(length -4);
	memset(elem, 0, length-4);
	memcpy(elem, HEAD, HEAD_LEN);
	if (prot_get_data(buffer, length -4, 2, crc) < 0)
	{
		LOG(DL_ERROR, "cannot get crcdata\n");
		free(elem);
		return -1;
	}
	prot_get_data(buffer, 2, length - 4 - HEAD_LEN, elem + HEAD_LEN);
	UINT16 crc_result = prot_crc16(elem, length -4);
	if (memcmp(&crc_result, crc, 2) ==0)
	{
		free(elem);
		return 0;
	}
	LOG(DL_ERROR, " ::::%02x -",crc[0]);  //  to be test TODO
        LOG(DL_ERROR, "%02x --pre: %d  curr: %d  ought to read--%d\n", crc[1], buffer->pre_read_index, buffer->read_index, length - 4 );
        LOG(DL_ERROR, "\n");
	LOG(DL_ERROR, "crc_result:%x\n", crc_result);
	LOG(DL_ERROR, "----------------------%d\n",n++);
	free(elem);
	LOG(DL_ERROR, "cannot get crcdata\n");
	return -1; // crc is wrong
}

int prot_pop_frame(struct CircularBuffer* buffer, UINT16 length, UCHAR* frame )
{
    LOG(DL_ENTER);
    prot_get_data(buffer, 0, length, frame);
    preToCurrentRead(buffer);
    return 0;
}

int parse_frame(struct CircularBuffer* buffer, UCHAR* data)
{
	if(buffer == NULL)
	{
		LOG(DL_ERROR, "buffer is null\n");
		return -1;	
	}
	if(data == NULL)
	{
		LOG(DL_ERROR, "data is null\n");
		return -1;
	}
	LOG(DL_ENTER);
	int length = 0;
	length = prot_parse_frame(buffer, data);
	if (length > 0)
	{
		memset(data,0, length);
		prot_pop_frame(buffer, length, data);
	}
	return length;
}

int prot_parse_frame(struct CircularBuffer* msg_receved, UCHAR* data)
{
	LOG(DL_ENTER);
	int length = 0;
	if(cbIsEmpty(msg_receved))
	{
		return 0;  // empty frame;
	}
        if (prot_parse_protocol_head(msg_receved) == 0)
        {
            length = prot_get_protocol_length(msg_receved);
            if (length < FIXED_PART_LEN || length > DATA_MAX_LEN + FIXED_PART_LEN) 
			{
				LOG(DL_ERROR, "wrong length--%d, %d\n", length, msg_receved->read_index);
				cbClean(msg_receved);
                return -3;  //length is wrong
			}
		
            if (prot_check_crc16(msg_receved, length) !=0 )
            {
 				LOG(DL_ERROR, "wrong crc--%d, %d\n", length, msg_receved->read_index);
 				cbClean(msg_receved);
           		return -2;  //crc is wrong
            }
            
            if(prot_parse_protocol_tail(msg_receved, length - 2 ) != 0 )
            {
				LOG(DL_ERROR, "wrong tail--%d, %d\n", length, msg_receved->read_index);
				cbClean(msg_receved);
            	return -4;  // tail is wrong

            }
			memset(data,0, length);
			prot_get_data(msg_receved, 0, length, data);
			return length;        //return data length
            
        }
        else
        {
			LOG(DL_ERROR, "wrong head--%d, %d\n", length, msg_receved->read_index);
			cbClean(msg_receved);
        	return -1;   //head is wrong
        }
}



void prot_print_protool(struct CircularBuffer* msg_receved)
{
	LOG(DL_ENTER);
	UCHAR buf[1024];
	int i=0, length;
	memset(buf, 0, 1024);
	length = prot_parse_frame(msg_receved, buf);
	if(length < 0) 
	{
		LOG(DL_INFO, "current frame is empty!\n");
		return;
	}
	printf("current frame length:%d\tdata:", length);

	for (; i< length-1; i++)
	{
		printf("%02x-", buf[i]);
	}
	printf("%02x\n", buf[i]);
}

void print_current_frame(struct CircularBuffer* buffer)
{
	LOG(DL_ENTER);
	prot_print_protool(buffer);
}

int prot_make_frame(UCHAR* packet, const UINT16 data_length, const UINT16 version, const UINT16 work_id, const UINT8 encrypt_type, const UCHAR* data)
{
	LOG(DL_ENTER);
	UINT16 length= data_length+FIXED_PART_LEN;
	memcpy(packet, HEAD, HEAD_LEN);
	memcpy(packet+HEAD_LEN, &length, 2);
	memcpy(packet+HEAD_LEN+2, &version, 2);
	memcpy(packet+HEAD_LEN+4, &work_id, 2);
	memcpy(packet+HEAD_LEN+6, &flow_id, 2);
	memcpy(packet+HEAD_LEN+8, &encrypt_type, 1);
	memcpy(packet+HEAD_LEN+9, data, data_length);
	unsigned int _crc= prot_crc16(packet, HEAD_LEN+data_length+9);
	memcpy(packet+HEAD_LEN+9+data_length, &_crc, 2);
	memcpy(packet+data_length+HEAD_LEN+11, TAIL, TAIL_LEN);
	
	if(work_id != 0xFFFF) {//the error frame what send to UI
		if (flow_id++ >= 65535)
		{
			flow_id = 0;
		}
	}
	return 0;
}
int put_recvdata(struct CircularBuffer* cb, UCHAR* recvdata, UINT16 length)
{
	LOG(DL_ENTER);
	if(cb == NULL)
	{
		LOG(DL_ERROR, "buffer is null\n");
		return -1;
	}
	if (length < 0 )
	{
		LOG(DL_ERROR, "length < 0\n");
		return -1; 
	}
	if((recvdata == NULL) || (length <= 0))
	{
		LOG(DL_INFO, "data is null\n");
		return 0;
	}

	int wlen = 0;
	wlen = cbWrite(cb, recvdata, length);
	if(wlen != length)
	{
		//buffer is full, discard the packet
		return -1;
	}
	return wlen;
}


void make_frame(UCHAR* packet, const UINT16 work_id, const UCHAR* data, const UINT16 data_length)
{
	LOG(DL_ENTER);
	if(packet == NULL)
	{
		LOG(DL_ERROR, "packet is null\n");
		return ;
	}

	UINT16 version = PROTOCOL_VER;
	UINT8 entype = ENCRYPT_NO;
	prot_make_frame(packet, data_length, version, work_id, entype, data);
}

void print_ringbuffer(struct CircularBuffer* cb)
{
	LOG(DL_ENTER);
	if(cbIsEmpty(cb))
	{
		printf("ringbuffer is empty!\n");
		return ;
	}
	cbPrintAll(cb);
}
#if 0
int main()
{
	struct CircularBuffer buffer;
	struct CircularBuffer* pBuf= &buffer;
	int i = 0, ret;

	init_ringbuffer(pBuf, 50);
	UCHAR data[] ={'\x01','\x02','\x03','\x04','\x06'};
	UINT16 work_id1 = 0xa01;
	int len1 = sizeof(data);
	UCHAR data2[] ={'\x06','\x07','\x08','\x09'};
	int len2 = sizeof(data2);
	UINT16 work_id2 = 0xa02;
	UCHAR data3[] ={};
	int len3 = sizeof(data3);
	UINT16 work_id3 = 0xa03;
	UCHAR _data[100];

	UCHAR* packet = (UCHAR*)malloc(30);

	make_frame(packet, work_id1, data, len1);
    put_recvdata(pBuf, packet, len1+FIXED_PART_LEN);

	make_frame(packet, work_id1, NULL, 0);
    put_recvdata(pBuf, packet, len1+FIXED_PART_LEN);
    print_ringbuffer(pBuf);

	memset(_data, 0, sizeof(_data));
	print_current_frame(pBuf);
     ret = parse_frame(pBuf, _data);

	memset(_data, 0, sizeof(_data));
	print_current_frame(pBuf);
     ret = parse_frame(pBuf, _data);
    printf("parse_frame return value0:%d\n", ret);

	make_frame(packet, work_id2, data2, len2);
   put_recvdata(pBuf, packet, len2+FIXED_PART_LEN);
    put_recvdata(pBuf, NULL, 10);

    print_ringbuffer(pBuf);


    printf("parse_frame return value1:%d\n", ret);

    print_ringbuffer(pBuf);

	make_frame(packet, work_id1, data, len1);
    ret = put_recvdata(pBuf, packet, len1+FIXED_PART_LEN);
    printf("put_recvdata return value2:%d\n", ret);

	make_frame(packet, work_id1, data, len1);
    ret = put_recvdata(pBuf, packet, len1+FIXED_PART_LEN);
    printf("put_recvdata return value3:%d\n", ret);

    print_ringbuffer(pBuf);


	memset(_data, 0, sizeof(_data));
 	print_current_frame(pBuf);
 	ret =parse_frame(pBuf, _data);
    printf("parse_frame return value4:%d\n", ret);
    print_current_frame(pBuf);
 
    print_ringbuffer(pBuf);

    del_ringbuffer(pBuf);
    return 0;
}
#endif
