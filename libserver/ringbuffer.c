#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ringbuffer.h"
#include <unistd.h>


void cbNew(struct CircularBuffer *cb, int size)
{
	cb->size  = size + 1; /* include empty elem */
	cb->pre_read_index = 0;
	cb->read_index = 0;
	cb->write_index   = 0;
	cb->buffer = (UCHAR*)calloc(cb->size, sizeof(UCHAR));
}

void cbFree(struct CircularBuffer *cb) 
{
	free(cb->buffer); /* OK if null */ 
	cb->buffer = NULL;
}

void cbClean(struct CircularBuffer *cb)
{
	cb->pre_read_index = 0;
    cb->read_index = 0;
    cb->write_index = 0;
    memset(cb->buffer, 0, cb->size);
}

int cbIsFull(struct CircularBuffer *cb) 
{
	if( (cb->write_index + 1) % cb->size == cb->pre_read_index)
	{
		LOG(DL_INFO, "full\n");
		return TRUE;
	}
	return FALSE;
}

int cbIsEmpty(struct CircularBuffer *cb)
{
	if (cb->write_index == cb->read_index)
	{
		LOG(DL_INFO, "empty\n");
		return TRUE;
	}
	return FALSE;
}

void returnToPre(struct CircularBuffer *cb)
{
	cb->read_index = cb->pre_read_index;
}

void preToCurrentRead(struct CircularBuffer *cb)
{

	cb->pre_read_index = cb->read_index;	
}

int returnCurrentIndex(struct CircularBuffer *cb)
{
	return cb->read_index - cb->pre_read_index;
}

int availableSize(struct CircularBuffer *cb)
{
	int length = 0;
	if(cb->write_index >= cb->pre_read_index)
	{
		length = cb->write_index- cb->pre_read_index;
	}
	else
	{
		length = cb->size- cb->pre_read_index + cb->write_index;
	}
	return length;
}

/* Write an element, overwriting oldest element if buffer is full. App can
   choose to avoid the overwrite by checking cbIsFull(). */

void cbWriteByte(struct CircularBuffer *cb, const UCHAR* msg) 
{
	memcpy(cb->buffer+cb->write_index, msg, 1*sizeof(UCHAR));
	cb->write_index = (cb->write_index + 1) % cb->size;
	if (cb->write_index == cb->pre_read_index)
	{
		cb->pre_read_index = (cb->pre_read_index + 1) % cb->size; 
	}

}

int getCbSize(struct CircularBuffer *cb)
{
	return cb->size;
}

int cbWrite(struct CircularBuffer *cb, const UCHAR* msg, int length)
{
	int count = 0;
	if(cb == NULL)
	{
		LOG(DL_ERROR, "cb is null\n");
		return -1;

	}
	if(msg == NULL)
	{
		LOG(DL_ERROR, "msg is null\n");
		return -1;
	}
	if (length <= 0)
	{
		LOG(DL_ERROR, "length is invalid\n");
		return -1;
	}

	while(length--)
	{
		if (!cbIsFull(cb))
		{
			cbWriteByte(cb, &msg[count]);
			count ++;
		}
		else
		{
			LOG(DL_ERROR, "buffer is full. %d byte(s) write.\n", count);
			break;
		}
	}
	return count ;
}

/* Read oldest element. App must ensure !cbIsEmpty() first. */
void cbReadByte(struct CircularBuffer *cb, UCHAR* msg) 
{
	memcpy(msg, cb->buffer+cb->read_index, 1*sizeof(UCHAR));
	cb->read_index = (cb->read_index + 1) % cb->size;
}

int cbRead(struct CircularBuffer *cb, UCHAR* msg, int length)
{
	int count = 0;
	if(cb == NULL)
	{
		LOG(DL_ERROR, "cb is null\n");
		return -1;

	}
	if(msg == NULL)
	{
		LOG(DL_ERROR, "msg is null\n");
		return -1;
	}
	if (length < 0)
	{
		LOG(DL_ERROR, "length is invalid\n");
		return -1;
	}
	    while(length--)
        {
           if (!cbIsEmpty(cb))
            {
               	cbReadByte(cb, &msg[count]);
 				count++;
            }
            else                                  
            {
            	//if data not enough, do not read. read_index is back to pre_read_index
				returnToPre(cb);
				memset(msg, 0, length);
				LOG(DL_ERROR, "data is not enough,%d byte(s) available\n", count);
				return -1;
			}
    	}
	return count;
}

int cbReadhasOffset(struct CircularBuffer *cb, UCHAR* msg, int offset, int length)
{
	int count = 0;
	if(cb == NULL)
	{
		LOG(DL_ERROR, "cb is null\n");
		return -1;
	}
	if(msg == NULL)
	{
		LOG(DL_ERROR, "msg is null\n");
		return -1;
	}
	if (length < 0)
	{
		LOG(DL_ERROR, "length is invalid\n");
		return -1;
	}
	if (offset < 0)
	{
		LOG(DL_ERROR, "offset < 0\n");
		return -1;
	}	
	if (availableSize(cb) < offset)
	{
		LOG(DL_ERROR, "availableSize:%d < offset:%d \n", availableSize(cb), offset);
		return -1;
	}

	cb->read_index = (cb->pre_read_index + offset)%cb->size;
    while(length)
    {
        if (!cbIsEmpty(cb))
        {
            cbReadByte(cb, &msg[count]);
			count++;
			length--;
        }
        else
        {
            //if data not enough, do not read. read_index is back to pre_read_index
			returnToPre(cb);
            memset(msg, 0, length);
			LOG(DL_ERROR, "data is not enough, %d byte(s) available\n", count);
            return -1;
        }
    }
    return count;
}

void cbPrintAll(struct CircularBuffer *cb)
{
	int tmpindex = cb->pre_read_index;
	while( ((tmpindex+1)%cb->size) != cb->write_index)
	{
		printf("%02x", cb->buffer[tmpindex]);
		tmpindex = (tmpindex + 1)%cb->size;
	}
	printf("%02x\n", cb->buffer[tmpindex]);
}
