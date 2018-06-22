//
//  main.c
//  Epsi_Reader
//
//  Created by Arnaud Le Boyer on 6/19/18.
//  Copyright © 2018 Arnaud Le Boyer. All rights reserved.
//

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>

struct termios  config;

int main() {
    int fReadData;
    FILE *fileData;
    int baudrate=460800;
    
    const char *device = "/dev/tty.usbserial-FTYVXOH6";
    
    
    uint8_t buffer[1];
    
    fReadData  = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
    
    fileData=fopen("/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/epsi_raw.dat","w");
    
    if(fReadData == -1) {
        printf( "failed to open port\n" );
    }
    else{
        printf( "fd = %i\n",fReadData );
    }
    
    if(!isatty(fReadData)) {printf(" fd is not a tty ");}
    else{
        printf(" fd is a tty \n");
    };
    
    
    if(tcgetattr(fReadData, &config) < 0) { printf(" no tty configuration");}
    else{
        printf("config.c_iflag=%lx\n",config.c_iflag);
        printf("config.c_oflag=%lx\n",config.c_oflag);
        printf("config.c_cflag=%lx\n",config.c_cflag);
        printf("config.c_lflag=%lx\n",config.c_lflag);
        printf("config.c_ispeed=%lx\n",config.c_ispeed);
        printf("config.c_ospeed=%lx\n",config.c_ospeed);
    }

    printf("\n");
    printf("\n");
    printf("\n");
    printf("\n");
    printf("\n");

    
    config.c_lflag &= ICANON ;
    config.c_cc[VMIN]  = 1;
    config.c_cc[VTIME] = 0;
    
    config.c_ispeed = baudrate;
    config.c_ospeed = baudrate;
    cfsetospeed (&config, baudrate);
    cfsetispeed (&config, baudrate);

    printf("Whatttt1\n");
    printf("testspeed %i\n",460800);
    printf("config.c_ispeed=%lx\n",config.c_ispeed);
    printf("config.c_ospeed=%lx\n",config.c_ospeed);
    
    if(config.c_ispeed != 460800 || config.c_ispeed != 460800) {
        printf(" Serial Port baud rate is not 460800\n");
        config.c_ispeed = 460800;
        config.c_ospeed = 460800;
        printf("config.c_ispeed=%lx\n",config.c_ispeed);
        printf("config.c_ospeed=%lx\n",config.c_ospeed);
        printf(" now baud rate is 460800\n");
        
        
    }
    else{
        printf(" baud rate is 460800\n");
    }
    printf("Whatttt2\n");
    printf("config.c_ispeed=%lx\n",config.c_ispeed);
    printf("config.c_ospeed=%lx\n",config.c_ospeed);
    
    //the configuration is changed any data received and not read will be discarded.
    tcsetattr(fReadData, TCSAFLUSH, &config);
    
    int count=0;
    while(1){
        if (read(fReadData,&buffer,1)>0){
            fwrite(&buffer,1,1,fileData);  // file print
            fflush(fileData);
            printf("%s:%i\n","coucou",count);
            count ++;
            
                }
    } // while(1)
} //end main

