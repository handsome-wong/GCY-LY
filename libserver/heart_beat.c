#include "server.h"
extern int exit_flag;
Heart *init_heart()
{
	Heart *heart = (Heart*) malloc(sizeof(Heart));
	heart->heart_flag = 1;
	pthread_mutex_init(&heart->heart_lock, NULL);
	return heart;
}
void destroy_heart(Heart *heart)
{
	if(!heart)
		return;
	pthread_mutex_destroy(&heart->heart_lock);
	free(heart);
	heart=NULL;
}
void *heart_beat(void *args)
{
	int retry		= 0;
	Errdata	errdata;
	Heart *heart = (Heart *) args;
	send_data(HEART_REQID, NULL, 0);
	while (!exit_flag) {
		sleep(3);
		if (heart->heart_flag == 1) {
			retry = 0;
			pthread_mutex_lock(&heart->heart_lock);
			heart->heart_flag = 0;
			pthread_mutex_unlock(&heart->heart_lock);
            send_data(HEART_REQID, NULL, 0);
		} else {
			// If timeout, put a same packet with heart beat response into recv queue, let app knows
			if(++retry > RETRY_MAX) {
				errdata.errtype = NET_ERR;
				errdata.work_id = HEART_RSPID;
				Frame errframe=(Frame)malloc(FIXED_PART_LEN + sizeof(Errdata));
				make_frame(errframe, ERR_ID, (UCHAR *)&errdata, sizeof(Errdata));
				EnQueue(recvque, errframe);
				break;
			}	
		}
	}
	return NULL;
}
