/*********************************************************************************
 *      Copyright:  (C) 2017 00
 *                  All rights reserved.
 *
 *       Filename:  i2c_dev.c
 *    Description:  This file 
 *                 
 *        Version:  1.0.0(2017Äê05ÔÂ11ÈÕ)
 *        
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
/******************************************************************************** 
 *  Description: 
 *   Input Args: 
 *  Output Args: 
 * Return Value: 
 ********************************************************************************/  
int main(int argc, char **argv)  
{  
    int     i;
    int     fd;
    int     ret;
    int     length;  
    unsigned char rdwr_addr = 0x00;  
    unsigned char device_addr = 0x50; 
    unsigned char data[] = "Hello";    

    struct i2c_rdwr_ioctl_data e2prom_data;  

    e2prom_data.nmsgs = 1;  

    printf("open i2c device...\n");  

    fd = open("/dev/i2c-0",O_RDWR);  
    if (fd < 0)  
     {  
         printf("open faild");  
         return -1;  
     }  

    e2prom_data.msgs = (struct i2c_msg *)malloc(e2prom_data.nmsgs * sizeof(struct i2c_msg));  

    if (e2prom_data.msgs == NULL)  
     {  
         printf("malloc error");  
         return -1;  
     }  

    ioctl(fd, I2C_TIMEOUT, 1); 
    ioctl(fd, I2C_RETRIES, 2);

    printf("run at line %d\n",__LINE__);

     length = sizeof(data);    
     e2prom_data.msgs[0].len = length;  
    printf("run at line %d\n",__LINE__);
     e2prom_data.msgs[0].addr = device_addr;  
    printf("run at line %d\n",__LINE__);

     e2prom_data.msgs[0].buf =(unsigned char *)malloc(length);  
     e2prom_data.msgs[0].buf[0] = rdwr_addr;  
     for(i = 0;i<length; i++)  
     e2prom_data.msgs[0].buf[1+i] = data[i]; /*  write data */  

     ret = ioctl(fd, I2C_RDWR, (unsigned long)&e2prom_data);  
     if(ret <0)  
        {  
             perror("write data error");  
             return -1;  
        }  

     printf("write data: %s to address %#x\n", data, rdwr_addr);  

     return 0;  
}
