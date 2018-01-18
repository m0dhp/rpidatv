/**************************************************************************//***
 *  @file    logitech.c
 *  @author  Ray M0DHP
 *  @date    2018-01-18  
 *  @version 0.1
*******************************************************************************/

#include <unistd.h>
#include <stdio.h>
#include <math.h>
#include <wiringPi.h>
#include <sys/wait.h>
#include "logitech.h"

 
/***************************************************************************//**
 * @brief Detects if a Logitech webcam was connected since last boot
 *
 * @param None
 *
 * @return (int) 1 if webcam detected, 0 if not
*******************************************************************************/
 
int detect_logitech_webcam()
{
  FILE * shell;
  shell = popen("dmesg | grep -E -q \"046d:0825|Webcam C525\"", "r");
  int r = pclose(shell);
  if (WEXITSTATUS(r) == 0)
  {
    printf("detected\n");
  }
  else if (WEXITSTATUS(r) == 1)
  {
    printf("not detected\n");
  } 
  else 
  {
    printf("unexpected exit status %d\n", WEXITSTATUS(r));
  }
  return 0;
}



int main(int argc, char *argv[])
{
  printf("hello\n");
  detect_logitech_webcam();
  printf("goodbye\n");
}

