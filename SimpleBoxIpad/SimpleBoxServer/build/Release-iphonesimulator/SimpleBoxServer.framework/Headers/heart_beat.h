#ifndef __HEART_BEAT_H__
#define __HEART_BEAT_H__
#include <pthread.h>

typedef struct{
	int heart_flag;
	pthread_mutex_t heart_lock;
} Heart;

Heart* init_heart();
void destroy_heart(Heart *heart);
void *heart_beat(void *args);
#endif
