/*********************************************************************************
 *      Copyright:  (C) 2017 LYM
 *                  All rights reserved.
 *
 *       Filename:  app_led.c
 *    Description:  This file app of led
 *                 
 *        Version:  1.0.0(04/30/2017)
 *         Author:  LeiYimin <yutianos@qq.com>
 *      ChangeLog:  1, Release initial version on "04/30/2017 08:39:36 AM"
 *                 
 ********************************************************************************/

#include <stdio.h>

#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/********************************************************************************
 *  Description:this is led test program.
 *   Input Args:LED_ON, LED_OFF
 *  Output Args:NULL
 * Return Value:NULL
 ********************************************************************************/
int main (int argc, char **argv)
{
    int fd;
    fd = open("/dev/led0",O_RDWR);
    
    if( fd<0)
    {
        printf("can't open led");
        return -1;
    }

    if( argc !=2 )
    {
        printf("arg is NULL");
        close(fd);
        return -1;
    }

    if(strcmp(argv[1],"LED_ON") == 0)
    {
        ioctl(fd,"LED_ON");
        printf("LED is ON");
        close(fd);
    }else if(strcmp(argv[1],"LED_OFF") == 0)
    {
        ioctl(fd,"LED_OFF");
        printf("LED is OFF");
        close(fd);
    }else
    {
        printf("arg is wrong");
        close(fd);
        return -1;
    }
    return 0;
} /* ----- End of main() ----- */

