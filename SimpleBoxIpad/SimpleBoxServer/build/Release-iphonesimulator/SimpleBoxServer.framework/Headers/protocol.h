#ifndef __PROTOCOL_H__
#define __PROTOCOL_H__

#include <stdint.h>
typedef unsigned char* Frame;
typedef unsigned char UCHAR;
#define UINT16 uint16_t 
#define UINT32 uint32_t
#define UINT8  uint8_t 

#define FIXED_PART_LEN 15
#define DATA_OFFSET 11

#define HEAD_LEN 2
#define COUNT_LEN 2
#define TAIL_LEN 2
#define TYPE_OFFSET 6
#define DATA_MAX_LEN 150

#define PACKET_HEADER 			2
#define PACKET_LEN    			2
#define PACKET_VERSION			2
#define PACKET_ID				2
#define PACKET_FLOW_ID			2
#define PACKET_ENCRYPT			1
#define APCKET_TAILER			2
#define FRAME_LEN(frame) 		((UINT16 *)(frame + PACKET_HEADER))
#define FRAME_ID(frame)			((UINT16 *)(frame + PACKET_HEADER + PACKET_LEN + PACKET_VERSION))
#define GET_DATA(frame)			((char *)(frame + DATA_OFFSET))

#define DATA_LEN(frame)			(*FRAME_LEN(frame) - FIXED_PART_LEN)

//#define HEAD "ab"
//#define TAIL "ba"
#define HEART_REQID  0x0a01
#define HEART_RSPID  0x4a01
#define HEAD "\x6c\x79"
#define TAIL "\xbb\x66"
#define PROTOCOL_VER 0x0901

#define ENCRYPT_NO 0x00
#define ENCRYPT_RSA 0x01
#define ENCRYPT_RC4 0x02

#endif 
