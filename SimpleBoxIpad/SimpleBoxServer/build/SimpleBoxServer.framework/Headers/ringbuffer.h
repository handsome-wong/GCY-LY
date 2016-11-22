#ifndef __RINGBUFFER_H__
#define __RINGBUFFER_H__
#include <stdio.h>
#include "protocol.h"

#define TRUE 1
#define FALSE 0

/* log puts definitions */
#define  DEBUG_LEVEL 1  

#define DL_ENTER 5
#define DL_TRACE 4
#define DL_DEBUG 3
#define DL_INFO 2
#define DL_WARN 1
#define DL_ERROR 0

#define LOG_DL_ENTER() LOGD("## [ENTER]:\t%s\n", __FUNCTION__)
#define LOG_DL_TRACE(logstring, ...) LOGD("## [TRACE]:\t"logstring, ##__VA_ARGS__)
#define LOG_DL_DEBUG(logstring, ...) LOGD("## [DEBUG]:\t"logstring, ##__VA_ARGS__)
#define LOG_DL_INFO(logstring, ...) LOGD("## [INFO]:\t"logstring, ##__VA_ARGS__)
#define LOG_DL_WARN(logstring, ...) LOGD("## [WARN]:\t"logstring, ##__VA_ARGS__)
#define LOG_DL_ERROR(logstring, ...) LOGD("## [ERROR]:\t"logstring, ##__VA_ARGS__)
#define LOG(level, msg...) if(level <= DEBUG_LEVEL) LOG_##level(msg)


#ifdef DEBUG
#define LOGD(format, ...) printf(format, ##__VA_ARGS__);
#else
#define LOGD(format, ...) ;
#endif
/* Circular buffer object */
struct CircularBuffer
{
    int         size;   /* maximum number of elements           */
    int         pre_read_index;  /*last packet head index*/
    int         read_index;     /*current index of read*/
    int         write_index;    /* index at which to write new element  */
    UCHAR* 		buffer;  /* vector of elements                   */
};




#endif
