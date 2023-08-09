#!/usr/bin/python3

import sys
import colorsys

for line in sys.stdin:
    if line[0] != "#":
        break

    r = int(line[1:3], 16)
    g = int(line[3:5], 16)
    b = int(line[5:7], 16)

    # Desaturoi värejä
    # nr = 255 - (g+b)//2
    # ng = 255 - (r+b)//2
    # nb = 255 - (r+g)//2

    # Invertoi rgb, sitten pyöritä hsv:ssä väri takaisin
    (h,s,v) = colorsys.rgb_to_hsv(1-(r/255), 1-(g/255), 1-(b/255))
    if h >= 0.5:
        h = h - 0.5
    else:
        h = h + 0.5
    (nr,ng,nb) = colorsys.hsv_to_rgb(h,s,v)
    nr = int(nr*255)
    ng = int(ng*255)
    nb = int(nb*255)

    hr = hex(nr)[2:].rjust(2,'0')
    hg = hex(ng)[2:].rjust(2,'0')
    hb = hex(nb)[2:].rjust(2,'0')

    print((" -> #"+hr+hg+hb).upper())
