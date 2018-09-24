#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 18 13:01:02 2018

@author: aleboyer
"""

import serial
from PyQt4 import QtGui, QtCore

def character(b):
    return b

class SerialMiniterm(object):
    def __init__(self, ui, SerialSettings):
        self.SerialSettings = SerialSettings
        self.ui = ui
        self.serial = serial.Serial(self.SerialSettings.Port, self.SerialSettings.BaudRate, parity=self.SerialSettings.Parity, rtscts=self.SerialSettings.RTS_CTS, xonxoff=self.SerialSettings.Xon_Xoff, timeout=1)
        self.repr_mode = self.SerialSettings.RxMode
        self.convert_outgoing = self.SerialSettings.NewlineMode
        self.newline = NEWLINE_CONVERISON_MAP[self.convert_outgoing]
        self.dtr_state = True
        self.rts_state = True
        self.break_state = False

    def _start_reader(self):
        """Start reader thread"""
        self._reader_alive = True
        self.receiver_thread = ReaderThread(self.alive, self._reader_alive, self.repr_mode, self.convert_outgoing, self.serial)
        self.receiver_thread.connect(self.receiver_thread, QtCore.SIGNAL("updateSerialTextBox(QString)"), self.updateTextBox)
        self.receiver_thread.start()

    def _stop_reader(self):
        """Stop reader thread only, wait for clean exit of thread"""
        self._reader_alive = False
        self.receiver_thread.join()

    def updateTextBox(self, q):
        self.ui.serialTextEditBox.insertPlainText(q)
        self.ui.serialTextEditBox.moveCursor(QtGui.QTextCursor.End)
        #print "got here with value %s..." % q

    def start(self):
        self.alive = True
        self._start_reader()
        # how do i handle transmitter thread?

    def stop(self):
        self.alive = False

    def join(self, transmit_only=False):
        self.transmitter_thread.join()
        if not transmit_only:
            self.receiver_thread.join()

class ReaderThread(QtCore.QThread):       
    def __init__(self, alive, _reader_alive, repr_mode, convert_outgoing, serial, parent=None):
        QtCore.QThread.__init__(self, parent)
        self.alive = alive
        self._reader_alive = _reader_alive
        self.repr_mode = repr_mode
        self.convert_outgoing = convert_outgoing
        self.serial = serial

    def __del__(self):
        self.wait()

    def run(self):
        """loop and copy serial->console"""
        while self.alive and self._reader_alive:
            data = self.serial.read(self.serial.inWaiting())
            if data:                            #check if not timeout
                q = data
                self.emit(QtCore.SIGNAL('updateSerialTextBox(QString)'), q)