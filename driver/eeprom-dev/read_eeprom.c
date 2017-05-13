/*********************************************************************************
 *      Copyright:  (C) 2017 LYM
 *                  All rights reserved.
 *
 *       Filename:  read_eeprom.c
 *    Description:  This file is used to read 24c02 eeprom data.
 *                 
 *        Version:  1.0.0(05/13/2017)
 *         Author:  LeiYimin <yutianos@qq.com>
 *      ChangeLog:  1, Release initial version on "05/13/2017 10:47:50 PM"
 *                 
 ********************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<linux/i2c.h>
#include<linux/i2c-dev.h>
#include<string.h>
#include<sys/types.h>
#include<unistd.h>
#include<fcntl.h>
#include<errno.h>


//#define DEBUG_N

int main(int argc, char **argv)
{
    int         i;
    int         fd;
    int         ret;
    int         length;
    unsigned char rdwr_addr = 0x00;
    unsigned char device_addr = 0x50;
    unsigned char rdata[10]={0};
    unsigned char offset = 0x02;

    struct i2c_rdwr_ioctl_data erom_data;

    erom_data.nmsgs = 2;

    printf("open i2c device...\n");

    fd = open("/dev/i2c-0",O_RDWR);
    if ( fd<0 ){
        printf("can't open i2c-0\n");
        return -1;
    }


    erom_data.msgs = (struct i2c_msg *)malloc(erom_data.nmsgs * sizeof(struct i2c_msg));

    if( erom_data.msgs == NULL ){
        printf("malloc error\n");
        return -1;
    }

    ioctl(fd, I2C_TIMEOUT, 1);
    ioctl(fd, I2C_RETRIES, 2);

    length = sizeof(rdata);
    erom_data.msgs[0].len = 1;
    erom_data.msgs[0].addr = device_addr;
    erom_data.msgs[0].flags=0;

    erom_data.msgs[0].buf = (unsigned char *)malloc(sizeof(unsigned char));
    erom_data.msgs[0].buf[0]=offset;
    

    erom_data.msgs[1].len = length;
    erom_data.msgs[1].addr = device_addr;
    erom_data.msgs[1].flags = I2C_M_RD;
    
    erom_data.msgs[1].buf = (unsigned char *)malloc(length);
    erom_data.msgs[1].buf[0]=0;

#ifdef DEBUG_N
    printf("run at line is %d\n",__LINE__);
#endif
    ret = ioctl(fd, I2C_RDWR, (unsigned long)&erom_data);
#ifdef DEBUG_N
    printf("run at line is %d\n",__LINE__);
#endif
    if( ret<0){
        perror("read data error");
        return -1;
    }
#ifdef DEBUG_N
    printf("run at line is %d\n",__LINE__);
#endif
    for(i=0;i<10;i++){
        printf("the data of %d is %c\n",i,erom_data.msgs[1].buf[i]);
    }    

#ifdef DEBUG_N
    printf("run at line is %d\n",__LINE__);
#endif
    close(fd);
}
