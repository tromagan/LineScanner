#!/usr/bin/env python3

import os, sys
from PIL import Image, ImageDraw
import numpy as np

line_scan_bytes_size = 2592 * 6
fname_dark  = "f:/testfile_dark.pcm"
fname_white = "f:/testfile_white_0.pcm"




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

#calc mean value of every color on all lines
def calc_average_rgb(rgb):
    lines_cnt = rgb.shape[0]
    rgb_aver = np.int16(np.average(rgb, axis = 0))
    return rgb_aver    

dark = load_pcm(fname_dark)
white = load_pcm(fname_white)

dark_mean = calc_average_rgb(dark)
dark_mean = np.int16(np.average(dark_mean, axis = 1))
print("dark_mean: %d, %d" %(np.max(dark_mean), np.min(dark_mean)))


white_mean = calc_average_rgb(white)
print("white_mean: %d, %d" %(np.max(white_mean), np.min(white_mean)))

print(dark_mean.shape)
print(white_mean.shape)

input("done, press Enter...")