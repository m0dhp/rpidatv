/**************************************************************************//***
 *  @file    logitech.c
 *  @author  Ray M0DHP
 *  @date    2018-01-18  
 *  @version 0.1
*******************************************************************************/

#include <stdio.h>
#include <sys/wait.h>
#include "logitech.h"

 
/***************************************************************************//**
 * @brief Detects if a Logitech webcam was connected since last restart
 *
 * @param None
 *
 * @return 0 = webcam not detected
 *         1 = webcam detected
 *         2 = shell returned unexpected exit status
*******************************************************************************/
 
int detect_logitech_webcam()
{
  char shell_command[MAX_COMMAND_LENGTH];
  FILE * shell;
  sprintf(shell_command, "dmesg | grep -E -q \"%s\"", DMESG_PATTERN);
  shell = popen(shell_command, "r");
  int r = pclose(shell);
  if (WEXITSTATUS(r) == 0)
  {
    printf("Logitech: webcam detected\n");
    return 1;
  }
  else if (WEXITSTATUS(r) == 1)
  {
    printf("Logitech: webcam not detected\n");
    return 0;
  } 
  else 
  {
    printf("Logitech: unexpected exit status %d\n", WEXITSTATUS(r));
    return 2;
  }
}


int main(int argc, char *argv[])
{
  detect_logitech_webcam();
  return 0;
}

