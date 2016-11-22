cc=gcc
LIB=libserver.so
obj=server.o ringbuffer.o protool.o Queue.o heart_beat.o
 
$(LIB):$(obj)
	$(cc) -fPIC -shared -lpthread -Wall -g -o $(LIB) $(obj)
server.o:server.c server.h
	$(cc) -c  -fPIC -Wall server.c 
ringbuffer.o:ringbuffer.c
	$(cc) -c -fPIC -Wall ringbuffer.c
protool.o:protool.c
	$(cc) -c -fPIC -Wall protool.c
Queue.o:Queue.c Queue.h
	$(cc) -c -fPIC -Wall Queue.c
heart_beat.o:heart_beat.c heart_beat.h
	$(cc) -c -fPIC -Wall heart_beat.c
#simplebox.pb-c.o:simplebox.pb-c.c
#	$(cc) -c -fPIC simplebox.pb-c.c
clean:
	rm -rf *.o libserver.so
