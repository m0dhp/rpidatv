/**************************************************************************//***
 *  @file    hmc1119.h
 *  @author  Ray M0DHP
 *  @date    2018-02-16
 *  @version 0.3
*******************************************************************************/

#ifndef __HMC1119_H__
#define __HMC1119_H__


/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/

#include <stdint.h>


/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/

#define HMC1119_MIN_ATTENUATION	     0.00 	// dB
#define HMC1119_MAX_ATTENUATION	    31.75 	// dB
#define HMC1119_DISPLAY_NAME    "HMC1119"

// Set time to wait for signals to settle after each control line state change
#define HMC1119_SLEEP                 100       // us


/******************************************************************************/
/************************ Types Definitions ***********************************/
/******************************************************************************/



/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/

/* Set attenuation level */
int hmc1119_set_level(float level);


#endif // __HMC1119_H__
