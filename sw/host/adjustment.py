#!/usr/bin/env python3

import os, sys
from PIL import Image, ImageDraw
import numpy as np

line_scan_bytes_size = 2592 * 6

fname_dark  = "f:/testfile_dark.pcm"
#fname_white = "f:/testfile_white_0.pcm"
#fname_white = "f:/testfile_white_1.pcm"
fname_white = "f:/testfile.pcm"

#fname_dark  = "/home/denc/Dropbox/Upload/adjust/testfile_dark.pcm"
#fname_white = "/home/denc/Dropbox/Upload/adjust/testfile_white_0.pcm"



#if type = 0 - rgb has int8  elements
#if type = 1 - rgb has int16 elements
def save_colors_file(rgb, type = 1, fnames = ["out_red.pcm", "out_green.pcm", "out_blue.pcm"]):
    fds = ["","",""]
    
    for i in range(len(fnames)):
        fds[i] = open(fnames[i], "wb")

    lines_cnt = rgb.shape[0]
    #print("lines_cnt=%d" % lines_cnt)

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
    rgb_aver = np.int16(np.average(rgb, axis = 0))
    return rgb_aver    

dark = load_pcm(fname_dark)
white = load_pcm(fname_white)

##################################################
##correction
#white[:,:,1] = np.multiply(white[:,:,1], 0.81)
#white[:,:,2] = np.multiply(white[:,:,2], 0.9)
##################################################

dark_mean = calc_average_rgb(dark)
dark_mean = np.int16(np.average(dark_mean, axis = 1))
print("dark_mean: max=%d, min=%d" %(np.max(dark_mean), np.min(dark_mean)))


white_mean = calc_average_rgb(white)
print("white_mean: max=%d, min=%d" %(np.max(white_mean), np.min(white_mean)))
save_colors_file(np.reshape(white_mean, (1, 2592,3)), 1, ["out_red_white.pcm", "out_green_white.pcm", "out_blue_white.pcm"])

#print(dark_mean.shape)
#print(white_mean.shape)
Vdmax = np.max(dark_mean)
Vdmin = np.min(dark_mean)
print("Vdmin = %d, Vdmax = %d" % (Vdmin, Vdmax))




Vp  = np.zeros_like(white_mean)
VEp = np.zeros_like(white_mean)
for i in range(3):
    Vp[:,i]  = white_mean[:,i] - Vdmin
    VEp[:,i] = white_mean[:,i] - dark_mean[:]

#Check UEp for < 50%
VEp_max = np.max(VEp[:,:], axis = 0)
VEp_min = np.min(VEp[:,:], axis = 0)
UEp = ((VEp_max - VEp_min)/VEp_max) * 100
print("*****")
print(VEp_max)
print(VEp_min)
print(UEp)
print("*****")



#step3 find MIN[Vpmax] across all colors
Vpmax = np.zeros(3)
for i in range(3):
    Vpmax[i] = np.max(Vp[:,i])
print("Vpmax'es: " + str(Vpmax))
Vpmax_min = np.min(Vpmax)
print("MIN[Vpmax] " + str(Vpmax_min))

#step4 here should be correction MIN[Vpmax] for Vpmax from table



#step5 calculate Vp(n) on color RED for example and store to Vp_avg_r
Vp_avg_r = np.average(Vp[:,0])
print("Vp_avg_r: " + str(Vp_avg_r))
Vp_avg_min = Vp_avg_r - Vp_avg_r*0.05
Vp_avg_max = Vp_avg_r + Vp_avg_r*0.05
print("AVG[Vp] 5 percents boundaries: %f, %f" % (Vp_avg_min, Vp_avg_max))

#step6 calc and tune other two AVG[Vp]
Vp_avg_g = np.average(Vp[:,1])
Vp_avg_b = np.average(Vp[:,2])

print("Vp_avg_g: " + str(Vp_avg_g))
print("Vp_avg_b: " + str(Vp_avg_b))

if(Vp_avg_g < Vp_avg_min or Vp_avg_g > Vp_avg_max):
    print("Vp_avg_g is not in boundaries!")
else:
    print("Vp_avg_g ok!")

if(Vp_avg_b < Vp_avg_min or Vp_avg_g > Vp_avg_max):
    print("Vp_avg_b is not in boundaries!")
else:
    print("Vp_avg_b ok!")



#Check for Ud < Vpmax/2.5
Ud = Vdmax - Vdmin
if( np.all( [(Ud * 2.5) < Vpmax]) ):
    #pass
    print("Ud value %d ok!" % Ud)
else:
    print("Ud value error!")



input("done, press Enter...")