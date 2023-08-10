# source venv/bin/activate

import sys
# import colorsys
from colormath.color_objects import LabColor, sRGBColor
from colormath.color_conversions import convert_color

for line in sys.stdin:
    if line[0] != "#":
        break

    r = int(line[1:3], 16)
    g = int(line[3:5], 16)
    b = int(line[5:7], 16)

    # 1. (haalea) Desaturoi värejä
    # nr = 255 - (g+b)//2
    # ng = 255 - (r+b)//2
    # nb = 255 - (r+g)//2

    # 2. (huono!) Invertoi rgb, sitten pyöritä hsv:ssä väri takaisin
    # (h,s,v) = colorsys.rgb_to_hsv(1-(r/255), 1-(g/255), 1-(b/255))
    # if h >= 0.5:
    #     h = h - 0.5
    # else:
    #     h = h + 0.5
    # (nr,ng,nb) = colorsys.hsv_to_rgb(h,s,v)
    # nr = int(nr*255)
    # ng = int(ng*255)
    # nb = int(nb*255)

    # 3. toimiva? Muunna Lab:hen, käännä L-kanava, sitten takaisin
    # rgb = sRGBColor(r, g, b, is_upscaled=True)
    rgb = sRGBColor.new_from_rgb_hex(line)
    lab = convert_color(rgb, LabColor)
    # (l,a,b) = lab.get_value_tuple()
    lab.lab_l = 100.0 - lab.lab_l
    rgb2 = convert_color(lab, sRGBColor)
    nr = int(255*rgb2.clamped_rgb_r)
    ng = int(255*rgb2.clamped_rgb_g)
    nb = int(255*rgb2.clamped_rgb_b)

    hr = hex(nr)[2:].rjust(2,'0')
    hg = hex(ng)[2:].rjust(2,'0')
    hb = hex(nb)[2:].rjust(2,'0')

    print((" -> #"+hr+hg+hb).upper())
