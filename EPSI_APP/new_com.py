#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 17 12:26:06 2018

@author: aleboyer
"""


import serial,glob
ports = glob.glob("/dev/tty.usbserial*")    

ser = serial.Serial('/dev/tty.usbserial-FTYVXOLZ',115200)


ser.write(b'qq')

ser.write(b'qq')


# python -m serial.tools.miniterm /dev/tty.usbserial-FTYVXOLZ 115200