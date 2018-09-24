#!/usr/bin/env python

import sys,glob
#from PyQt5.QtWidgets import (QLineEdit, QSlider, QLabel, QPushButton, QHBoxLayout, QVBoxLayout, QApplication, QWidget)
from PyQt5.QtWidgets import (QLabel, QPushButton, QHBoxLayout, QVBoxLayout, QApplication, QWidget)
from PyQt5.QtWidgets import (QMainWindow,QAction,QMenu,qApp)
from PyQt5.QtWidgets import (QLineEdit,QMessageBox)
from PyQt5 import QtGui
from PyQt5.QtGui import (QIcon)
#from PyQt5.QtCore import (QTimer)

new_path = '/../Python_lib/PLOT_EPSILOMETER/'
sys.path.append(new_path)

import serial

ports = glob.glob("/dev/tty.usbserial*")    
baudrate=460800
baudlist=[9600,38400,57600,115200,460800]

class SerialPortWindow(QMainWindow):
    def __init__(self, parent=None, name=None):
        global ser
        super(SerialPortWindow,self).__init__(parent)
        print("open Serial %s, baud rate is %i" % (name,baudrate))
        self.setWindowTitle(name)
 
        try:
            ser = serial.Serial(name,baudrate,timeout=1) 
            mess = ser.name + ' open'
        except:
            mess = name + " is busy. Close or change port"    
        
        self.form_widget = FormSerialWidget(self,mess) 
        self.setCentralWidget(self.form_widget) 
        #self.show()
        
class FormSerialWidget(QWidget):
    def __init__(self, parent,mess=None):
        super(FormSerialWidget, self).__init__(parent)

        self.l1=QLabel(mess)
        print(mess)
        h1_box = QHBoxLayout()
        h1_box.addStretch()
        h1_box.addWidget(self.l1)
        h1_box.addStretch()
        v_box = QVBoxLayout()
        v_box.addLayout(h1_box)
        self.setLayout(v_box)
        
class FormMainWidget(QWidget):

    def __init__(self, parent):        
        super(FormMainWidget, self).__init__(parent)

        self.l1 = QLabel('Epsilometer Communication Protocole.\n MOD group, MPL lab, SIO')
        self.b1 = QPushButton('Stop sampling')
        self.b2 = QPushButton('Close serial port')
        self.l2 = QLabel()
        self.l2.setPixmap(QtGui.QPixmap('MOD_logo.jpg'))
        self.setGeometry(100,100,500,800) # size of the window

        # define an horizontal box layout
        h1_box = QHBoxLayout()
        h1_box.addStretch()
        h1_box.addWidget(self.l1)
        h1_box.addStretch()
        h2_box = QHBoxLayout()
        h2_box.addStretch()
        h2_box.addWidget(self.l2)
        h2_box.addStretch()

        # define an Vertical box layout
        v_box = QVBoxLayout()
        v_box.addLayout(h1_box)
        v_box.addWidget(self.b1)
        v_box.addWidget(self.b2)
        v_box.addLayout(h2_box)
        self.setLayout(v_box)
        #self.setLayout(self.layout)        
        self.b1.clicked.connect(self.b1on_click)
        self.b2.clicked.connect(self.b2on_click)

    def b1on_click(self):
        global ser
        ser.write(b'qq')

    def b2on_click(self):
        global ser
        ser.close()
    

class MainWindow(QMainWindow):
#class Window(QWidget):

    def __init__(self):
        super().__init__()
        self.init_menu()

    def init_menu(self):
        self.setWindowTitle('EPSI menu')
  
        
        self.form_widget = FormMainWidget(self) 
        self.setCentralWidget(self.form_widget) 


        
        mainMenu = self.menuBar()
        fileMenu  = mainMenu.addMenu('File')
        editMenu  = mainMenu.addMenu('Edit')
        
        newAct = QAction('New', self) 
        fileMenu.addAction(newAct)
        
        #define baudrate
        baudMenu = QMenu('choose baud rate', self)
        editMenu.addMenu(baudMenu)
        baud=[None] * len(baudlist);
        
        baud[0] = QAction(str(baudlist[0]), self) 
        baud[0].triggered.connect(lambda: self.btn_Changebaudrate(baudlist[0]))
        baudMenu.addAction(baud[0])
        baud[1] = QAction(str(baudlist[1]), self) 
        baud[1].triggered.connect(lambda: self.btn_Changebaudrate(baudlist[1]))
        baudMenu.addAction(baud[1])
        baud[2] = QAction(str(baudlist[2]), self) 
        baud[2].triggered.connect(lambda: self.btn_Changebaudrate(baudlist[2]))
        baudMenu.addAction(baud[2])
        baud[3] = QAction(str(baudlist[3]), self) 
        baud[3].triggered.connect(lambda: self.btn_Changebaudrate(baudlist[3]))
        baudMenu.addAction(baud[3])
        baud[4] = QAction(str(baudlist[4]), self) 
        baud[4].triggered.connect(lambda: self.btn_Changebaudrate(baudlist[4]))
        baudMenu.addAction(baud[4])
        
        
        # connection to serial port 
        # the baud rate is define in the edit menu
        
        connectMenu = QMenu('Connect to Port', self)
        fileMenu.addMenu(connectMenu)
        newPort=[None] * len(ports);
        try:
            newPort[0] = QAction(ports[0], self) 
            newPort[0].triggered.connect(lambda: self.btn_OpenSerialPort(ports[0]))
            connectMenu.addAction(newPort[0])
        except:
            print("no port")
            
        try:    
            newPort[1] = QAction(ports[1], self) 
            newPort[1].triggered.connect(lambda: self.btn_OpenSerialPort(ports[1]))
            connectMenu.addAction(newPort[1])
        except:
            print("only 1 port")
        try:    
            newPort[2] = QAction(ports[2], self) 
            newPort[2].triggered.connect(lambda: self.btn_OpenSerialPort(ports[2]))
            connectMenu.addAction(newPort[2])
        except:
            print("2 ports")
        try:    
            newPort[3] = QAction(ports[3], self) 
            newPort[3].triggered.connect(lambda: self.btn_OpenSerialPort(ports[3]))
            connectMenu.addAction(newPort[3])
        except:
            print("3 ports")



        
        exitAct = QAction(QIcon('exit.png'), '&Exit', self)        
        exitAct.setShortcut('Ctrl+Q')
        exitAct.setStatusTip('Exit application')
        exitAct.triggered.connect(qApp.quit)
        fileMenu.addAction(exitAct)


        mainMenu.setNativeMenuBar(False)
        self.show()
        app.aboutToQuit.connect(self.closeEvent)


    def btn_OpenSerialPort(self,name):
        self.mw=SerialPortWindow(self, name)
       # print('Serial Port status: Open' + ser.name)
        self.mw.show()

    def btn_Changebaudrate(self,name):
        global baudrate
        baudrate=name
        
        print(" baud rate is now %i" % name)

        
        
    def closeEvent(self):
        global ser
        #Your code here
        print('User has pressed the close button')
        ser.close()
        qApp.quit
    
 
if __name__ == '__main__':

    app = QApplication(sys.argv)
    a_window=MainWindow()
    sys.exit(app.exec_())


