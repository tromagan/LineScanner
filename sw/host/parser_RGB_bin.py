#!/usr/bin/env python3

import os, sys
from PIL import Image, ImageDraw
import numpy as np

line_scan_bytes_size = 2592 * 6
fname = "f:/testfile.pcm"
#fname  = "f:/testfile_dark.pcm"
#fname  = "f:/testfile_white_1.pcm"
#fname = "/home/denc/Dropbox/Upload/adjust/testfile_white_0.pcm"





#if type = 0 - rgb has int8  elements
#if type = 1 - rgb has int16 elements
def save_colors_file(rgb, type = 1, fnames = ["out_red.pcm", "out_green.pcm", "out_blue.pcm"]):
    fds = ["","",""]
    
    for i in range(len(fnames)):
        fds[i] = open(fnames[i], "wb")

    lines_cnt = rgb.shape[0]

    for line_idx in range(lines_cnt):
        line = np.transpose(rgb[line_idx][:])

        for i in range(3):
            if type == 0:
                fds[i].write((np.int8(line[i])).tobytes())
            else:
                fds[i].write((np.int16(line[i])).tobytes())
            #print(line[i])
    for i in range(3):
        fds[i].close()




def load_colors_from_file(fnames = ["out_red_aver_.pcm", "out_green_aver_.pcm", "out_blue_aver_.pcm"]):
    fds = ["","",""]
    for i in range(len(fnames)):
        fds[i] = open(fnames[i], "rb")

    rgb = np.zeros((1,2592,3), np.int16)

    for i in range(3):
        word_color = 1
        words_cnt = 0   
        while word_color:
            word_color = fds[i].read(2)
            if word_color:
                rgb[0,words_cnt,i] = int.from_bytes(word_color, "little")
                words_cnt = words_cnt + 1

        fds[i].close()

    return rgb




def calc_average(rgb):
    lines_cnt = rgb.shape[0]
    #rgb_aver = np.int16(np.average(rgb[0:lines_cnt,:,:], axis = 0))
    rgb_aver = np.int16(np.average(rgb, axis = 0))
    rgb_aver = np.reshape(rgb_aver,(1,2592,3))  # make shape (1,2592,3)

    #make correction for lowest value
    for idx in range(3):
        rgb_aver[:,:,idx] = rgb_aver[:,:,idx] - np.min(rgb_aver[:,:,idx])
    
    return rgb_aver




def load_pcm(fname):
    f = open(fname, "rb")
    fsize   = os.path.getsize(fname)
    if(fsize % line_scan_bytes_size):
        print("*****error file size! not integer linescan bytes size!!!!!")
        sys.exit()

    raw_data = np.zeros((fsize >> 1,1), dtype = np.int16)

    word_color = 1
    words_cnt = 0
    while word_color:
        word_color = f.read(2)
        if word_color:
            raw_data[words_cnt] = int.from_bytes(word_color, "little")
            words_cnt = words_cnt + 1

    lines_cnt = int((words_cnt*2) / line_scan_bytes_size)

    #ignoring first RGB line
    raw_data = raw_data[2592*3:]
    lines_cnt = lines_cnt - 1   
    rgb = np.reshape(raw_data,(lines_cnt,2592,3))

    print("file info: %s\t lines count = %d \t bytes cnt = %d Bytes" % (fname,lines_cnt,words_cnt*2))     
    print("max,min = %d, %d" % (np.max(raw_data), np.min(raw_data)))

    f.close()

    return rgb






rgb = load_pcm(fname)
lines_cnt = rgb.shape[0]
save_colors_file(rgb, 1)

##################################################
##correction
#rgb[:,:,1] = np.multiply(rgb[:,:,1], 0.81)
#rgb[:,:,2] = np.multiply(rgb[:,:,2], 0.9)
##################################################


calc_store_mean = 0
###calculate 3 RGB averages on black lines
if calc_store_mean == 1:
    rgb_aver = calc_average(rgb)
    save_colors_file(rgb_aver, 1, ["out_red_aver.pcm", "out_green_aver.pcm", "out_blue_aver.pcm"])
else:
    ###if correction samples already calculated and stored
    rgb_aver = load_colors_from_file(["out_red_aver.pcm", "out_green_aver.pcm", "out_blue_aver.pcm"])

###correcting
for idx in range(3):
   rgb[:,:,idx] = rgb[:,:,idx] - rgb_aver[:,:,idx]


###check for negative samples
for idx in range(3):
    tmp = np.copy(rgb[:,:,idx])
    if np.min(tmp) < 0:
        print("detected negative correction at %d" % (idx))
        rgb[:,:,idx] = np.copy(tmp - np.min(tmp))


print("red  : " + str(np.max(rgb[:,:,0])) + " " + str(np.min(rgb[:,:,0])))
print("green: " + str(np.max(rgb[:,:,1])) + " " + str(np.min(rgb[:,:,1])))
print("blue : " + str(np.max(rgb[:,:,2])) + " " + str(np.min(rgb[:,:,2])))


save_colors_file(rgb, 1, ["out_red_tmp.pcm", "out_green_tmp.pcm", "out_blue_tmp.pcm"])



#scale
rgb = np.divide(rgb, 8.03)
rgb = np.uint8(rgb) 
print("final uint8: max= %s  min= %s" % (str(np.max(rgb)), str(np.min(rgb))))

save_colors_file(rgb, 0, ["out_red_cor.pcm", "out_green_cor.pcm", "out_blue_cor.pcm"])

bytes_array = rgb.tobytes()
print(len(bytes_array))



img = Image.frombytes('RGB', (2592, lines_cnt), bytes_array)
imgDrawer = ImageDraw.Draw(img)
img.save("lines.png")

input("done, press Enter...")