/*
 * =====================================================================================
 *
 *       Filename:  server.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  11/30/2015 11:48:37 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  judeng (), judeng.fnst@cn.fujitsu.com
 *   Organization:  
 *
 * =====================================================================================
 */
#include "server.h"

static int register_box(const UCHAR* data, const int data_len, int socketfd, UCHAR* out);
void *send_to_box(void *args);
static int send_frame(Frame frame);
void *recv_from_box(void *args);
static void push_recvque(struct CircularBuffer * cb);

Queue *sendque;
Queue *recvque;
Heart *heart;
pthread_t send_thread;
pthread_t recv_thread;
pthread_t heart_thread;
int connect_fd;
int exit_flag;

int connect_box(const UCHAR *data, const int data_len, const char *ip, const UINT32 port, UCHAR *out)
{
	int ret = -1;
	connect_fd = -1;
	struct sockaddr_in addr;
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(ip);
	addr.sin_port = htons(port);

	connect_fd = socket(AF_INET, SOCK_STREAM, 0);
	if(connect_fd < 0 ) {
        printf("create socket failed\n");
		return -1;
	}
	ret = connect(connect_fd, (struct sockaddr*) &addr, sizeof(addr));
	if(ret < 0 ) {
        printf("connect failed\n");
		return -1;
	}
	ret = register_box(data, data_len, connect_fd, out);
	if(ret < 0) {
        printf("register failed\n");
		return -1;
	}
	return ret;
}

int start_pthread()
{
	sendque = InitQueue();
	recvque = InitQueue();
	heart = init_heart();
	
	exit_flag = 0;
	pthread_create(&send_thread, NULL, send_to_box, NULL);
	pthread_create(&recv_thread, NULL, recv_from_box, NULL);
	pthread_create(&heart_thread, NULL, heart_beat, (void *)heart);
	return 0;
}
//int register_box(UINT16 appid, int socketfd, char *data, UINT32 data_len)
static int register_box(const UCHAR* data, const int data_len, int socketfd, UCHAR* out)
{
	int ret 	= -1;
	char buf[BUF_LEN];
	int len;
	int i;
	UINT16 id=0x0a02;
	Frame frame;
	fd_set rfds;
	FD_ZERO(&rfds);
	FD_SET(socketfd, &rfds);

	struct timeval tv;
	tv.tv_sec = 30;
	tv.tv_usec = 0;
	frame = (Frame) malloc (data_len + FIXED_PART_LEN);
	make_frame(frame, id, data, data_len);
	ret = send_frame(frame);
    
    printf("send hand len:%d\n", *FRAME_LEN(frame));
    //printf("recv hand len:%d\n", len);
    for(int i=0; i<*FRAME_LEN(frame); i++)
        printf("%02hhx ", *(frame+i));
    printf("\n");
	free(frame);
	if(ret < 0 ) {
		return -1;//send error
	}
	ret = select(connect_fd+1, &rfds, NULL, NULL, &tv);
	if(ret <= 0) {
		return -1;//register error;
	}
	len = recv(connect_fd, buf, BUF_LEN, MSG_DONTWAIT);	
	printf("recv hand len:%d\n", len);
	for(i=0; i<len; i++)
		printf("%02hhx ", buf[i]);
	printf("\n");
    if(len <= 0)
        return -1;
	if(len != *FRAME_LEN(buf)) {
		printf("connect error!recv len:%d, frame_len:%d\n", len, *FRAME_LEN(buf));
		return -1;
	}
	if(*FRAME_ID(buf) != 0x4a02){
		printf("connect error!FRAME_ID:%hx", *FRAME_ID(buf));
	}
	memcpy(out, GET_DATA(buf), DATA_LEN(buf));
	return DATA_LEN(buf);
}


void *send_to_box(void *args)
{
	int ret = -1;
	int i;
	Frame frame;
	printf("send_to_box start\n");
	while(!exit_flag) {
		while(GetFront(sendque, &frame)) {
			//printf("frame len:%d\n", *FRAME_LEN(frame));
			if(frame==NULL) {
				printf("OOPS!frame IS NULL\n");
				continue;
			}
			printf("frame len:%d\n", *FRAME_LEN(frame));
			for(i=0; i<*FRAME_LEN(frame); i++)
				printf("%02hhx ", *(frame+i));
			printf("\n");
			ret = send_frame(frame);
			if(ret != 0) {
				
				break;//exit thread;
			}
			free(frame);
			frame=NULL;
			DeQueue(sendque);
		}
	}
	return NULL;
}

static int send_frame(Frame frame)
{
	int ret		= -1;
	int i		=0;
	Errdata		errdata;
	Frame errframe;
	while(i++ < RETRY_MAX) {
		ret = send(connect_fd, frame, *FRAME_LEN(frame), MSG_DONTWAIT);
		if(ret == *FRAME_LEN(frame)) {
			return 0;
		}
	}
	errdata.errtype=NET_ERR;
	errdata.work_id=*FRAME_ID(frame);
	errframe=(Frame)malloc(FIXED_PART_LEN+sizeof(Errdata));
	make_frame(errframe, ERR_ID, (UCHAR *)&errdata, sizeof(Errdata));
	EnQueue(recvque, errframe);	
	return -1;
}

void *recv_from_box(void *args)
{
	int ret = -1;
	UCHAR buf[BUF_LEN];
	Errdata errdata;
	int len;
	fd_set rfds;
	FD_ZERO(&rfds);
	FD_SET(connect_fd, &rfds);
	struct CircularBuffer cb;
	init_ringbuffer(&cb, BUF_LEN);
	while(!exit_flag) {
		ret = select(connect_fd+1, &rfds, NULL, NULL, NULL);
		if(ret == 0) 
			continue;
		if(ret < 0) {
			goto EXIT;
		}
		len = recv(connect_fd, buf, BUF_LEN, MSG_DONTWAIT);
		if(len <=0 ) {
			goto EXIT;
		}
		put_recvdata(&cb, buf, len);
		push_recvque(&cb);
	}
EXIT:
	errdata.errtype=NET_ERR;
	errdata.work_id=ERR_ID;
	Frame errframe=(Frame)malloc(FIXED_PART_LEN+sizeof(Errdata));
	make_frame(errframe, ERR_ID, (UCHAR *)&errdata, sizeof(Errdata));
	EnQueue(recvque, errframe);	
	del_ringbuffer(&cb);
	return NULL;
}

static void push_recvque(struct CircularBuffer * cb)
{
	UCHAR tmp[256];
	Frame frame			= NULL;
	int len				= 0;
	while((len = parse_frame(cb, tmp)) > 0) {
		if(*FRAME_ID(tmp) == HEART_RSPID) {
			pthread_mutex_lock(&heart->heart_lock);
			heart->heart_flag = 1;
			pthread_mutex_unlock(&heart->heart_lock);
			continue;
		}
		frame = (Frame)malloc(len);
		memcpy((void *)frame, (void *)tmp, len);
		EnQueue(recvque, frame);	
	}
}

int send_data(const UINT16 id, const UCHAR *data, const UINT32 data_len)
{
	Frame frame		= NULL;
	if(sendque == NULL) {
		return -1;
	}
	frame = (Frame) malloc (data_len + FIXED_PART_LEN);
	make_frame(frame, id, (UCHAR *)data, data_len);
	EnQueue(sendque, frame);
	return 0;
}

int get_data(UINT16 *id, UCHAR *buf, const UINT32 buf_len)
{
	if(recvque == NULL) {
        printf("recvque NULL");
		return 0;
	}
    
    if(GetSize(recvque) == 0) {
        printf("recvque length is zero");
        return 0;
    }
    
	Frame frame;
	GetFront(recvque, &frame);
	if(frame==NULL) {
		return 0;
	}
	int data_len = DATA_LEN(frame);
	if(data_len > buf_len) {
		return -1;//buf not enough
	}
	memcpy(buf, GET_DATA(frame), data_len);
	memcpy((void *)id, (void *)FRAME_ID(frame), sizeof(UINT16));

    printf("get frame len:%d\n", *FRAME_LEN(frame));
    for(int i=0; i<*FRAME_LEN(frame); i++)
        printf("%02hhx ", *(frame+i));
    printf("\n");
	free(frame);
	DeQueue(recvque);
	return data_len;
}

int disconnect_box(int flag)
{
	exit_flag=1;
	pthread_cancel(heart_thread);
	pthread_cancel(send_thread);
	pthread_cancel(recv_thread);//TODO memory leak
//	pthread_join(heart_thread, NULL);
//	pthread_join(send_thread, NULL);
//	pthread_join(recv_thread, NULL);
	close(connect_fd);
	QueueTraverse(sendque, free);//free frame
	DestroyQueue(sendque);//free que
	sendque=NULL;
	QueueTraverse(recvque, free);
	DestroyQueue(recvque);
	recvque=NULL;
	destroy_heart(heart);

	return 0;
}
