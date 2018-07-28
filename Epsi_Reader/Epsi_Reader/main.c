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
#include <string.h>
#include <time.h>


struct termios  config;

int main() {
    int fReadData;
    FILE *fileData;
    int baudrate=460800;
    
    //char device[100];
    //const char *device = "/dev/tty.usbserial-FTYVXOH6";
    //printf("Port Path?\n");
    //scanf("%s",device);
    //printf("log in to %s\n", device);
    
    
    uint8_t buffer=0;
    
    //fReadData  = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
    fReadData  = open("/dev/tty.usbserial-FTYVXOLZ", O_RDWR | O_NOCTTY | O_NDELAY);
//    fReadData  = open("/dev/tty.usbserial-FTYVXOH6", O_RDWR | O_NOCTTY | O_NDELAY);tty.usbserial-FTYVXOLZ
    int countfile=0;
    char filename[100];
    sprintf (filename, "/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/epsiauto/raw/epsi_raw%04d.bin", countfile);
    fileData=fopen(filename,"w");
    
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

    time_t Ltime;
    int count=0;
    int count1=0;
    int State=0;
    while(1){
        switch (State){
            case 0:
                if (read(fReadData,&buffer,1)>0){
                    if (buffer==0x24){
                        printf("$");
                        if (read(fReadData,&buffer,1)>0){
                            if (buffer==0x4d){
                               printf("M");
                               if (read(fReadData,&buffer,1)>0){
                                   if (buffer==0x41){
                                       printf("A\n");
                                       while (count<=4205){
                                           if (read(fReadData,&buffer,1)>0){
                                               count++;
                                           }
                                       }
                                       if (read(fReadData,&buffer,1)>0){
                                           if(buffer==0xa){
                                               State=1;
                                               printf("State1\n");
                                               printf("%x\n",buffer);
                                           }
                                       }
                               }
                            }
                        }
                    }
                }
            }
            break;
            case 1:
                count=0;
                Ltime =time(NULL);
                fprintf(fileData,"$TIME%ld\r\n",Ltime);  // file print
                fflush(fileData);
                while (count<4210){
                    if (read(fReadData,&buffer,1)>0){
                        if ((count==0) & (buffer!=36) ){
                            printf("%x\n",buffer);
                            printf("State0\n");
                            State=0;
                        }
                        fwrite(&buffer,1,1,fileData);  // file print
                        fflush(fileData);
                        count ++;
                    }
                }
                count1++;
                if (count1 % 120==0){
                    fclose(fileData);
                    count1=0;
                    countfile++;
                    sprintf (filename, "/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/epsiauto/raw/epsi_raw%0d.bin", countfile);
                    fileData=fopen(filename,"w");
                }
                break;
        }
    } // while(1)
} //end main

