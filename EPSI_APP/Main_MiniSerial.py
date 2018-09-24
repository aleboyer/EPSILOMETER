#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 18 16:11:56 2018

@author: aleboyer
"""

import sys
from PyQt4 import QtGui
from MainGUI import TestGUI
from SerialClasses import *
from SerialMiniterm import *

class StartMainWindow(QtGui.QMainWindow):      
    def __init__(self, parent=None):
        super(StartMainWindow, self).__init__(parent)
        self.ui = TestGUI()
        self.ui.setupUi(self)    
        self.ui.serialTextEditBox.installEventFilter(self)

    def eventFilter(self, source, event):
        if (event.type() == QtCore.QEvent.KeyPress and source is self.ui.serialTextEditBox):
            # print some debug statements to console
            if (event.key() == QtCore.Qt.Key_Tab):
                print ('Tab pressed')
            print ('key pressed: %s' % event.text())
            print ('code pressed: %d' % event.key())
            # do i emit a signal here?  how do i catch it in thread?
            self.emit(QtCore.SIGNAL('transmitSerialData(QString)'), event.key())
            return True
        return QtGui.QTextEdit.eventFilter(self, source, event)   

    def serialConnectCallback(self):
        self.miniterm = SerialMiniterm(self.ui, self.SerialSettings)
        self.miniterm.start()
        temp = self.SerialSettings.Port + 1
        self.ui.serialLabel.setText("<font color = green>Serial Terminal Connected on COM%d" % temp) 

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    app.setStyle("Cleanlooks")
    myapp = StartMainWindow()
    myapp.show()
    sys.exit(app.exec_())