import socket
import struct

#data_len_total = 32*1024*1024
#print('received %d MB' % (data_len_total/(1024*1024)))

sock = socket.socket()
sock.bind(('192.168.0.215', 2592))
sock.listen(1)
conn, addr = sock.accept()

print('connected:', addr)




fd = open("f:/testfile.pcm","wb") 
data_len_total = 0
blocks_cnt = 0
#buf_size = 16384
#bufs_cnt = 1024*2

dma_cnt = 1

linescan_bytes_size = 2592*6

buf_size = linescan_bytes_size*1024*dma_cnt
#buf_size = 16384
bufs_cnt = 10000000
#bufs_cnt = 1

#while True:
while data_len_total < buf_size*bufs_cnt:
    data = conn.recv(buf_size)
    
    data_len_total = data_len_total + len(data)
    #blocks_cnt = blocks_cnt + 1
    #print(blocks_cnt)
    #print(data)

    #fd.write(bytearray(data))

print('received %d MB' % (data_len_total/(1024*1024)))

fd.close()
conn.close()