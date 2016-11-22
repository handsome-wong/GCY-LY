/*
 * =====================================================================================
 *
 *       Filename:  server.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  12/01/2015 10:59:54 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  judeng (), judeng.fnst@cn.fujitsu.com
 *   Organization:  
 *
 * =====================================================================================
 */

#ifndef __SERVER_H__
#define __SERVER_H__
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <pthread.h>
#include <time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>
#include "Queue.h"
#include "protool.h"
#include "protocol.h"
#include "ringbuffer.h"
#include "heart_beat.h"

/*
typedef struct {
	ushort frame_header;
	ushort frame_len;
	ushort version;
	ushort id;
	ushort flow_id;
	uchar  encrypt_type;
	char  *data;
	ushort frame_tailer;
} __attribute__((aligned(1))) Frame;
*/
#define ERR_ID 0xFFFF
typedef struct {
	int errtype;
	UINT16 work_id;
	UINT16 reserved;
} Errdata;
#define BUF_LEN 8192
#define NET_ERR	0x00000001;
#define OTH_ERR 0x00000002; 
#define RETRY_MAX 3
extern Queue *sendque;
extern Queue *recvque;
int connect_box(const UCHAR *data, const int data_len, const char *ip, const UINT32 port, UCHAR* out);
int start_pthread();
int get_data(UINT16 *id, UCHAR *buf, const UINT32 buf_len);
int send_data(const UINT16 id, const UCHAR *data, const UINT32 data_len);
int disconnect_box(int flag);

#endif
