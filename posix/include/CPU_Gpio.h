//
// Copyright (c) .NET Foundation and Contributors
// Portions Copyright (c) Microsoft Corporation.  All rights reserved.
// See LICENSE file in the project root for full license information.
//


#ifndef _CPU_GPIO_H_
#define _CPU_GPIO_H_

#include "include/stdafx.h"

#if defined(BOARD_WSL)

#define NF_POSIX_GPIO
// multi bank, each have 36
#define GPIO_MAX_PIN        36
#define TOTAL_GPIO_PORTS    36

#endif // BOARD_WSL

#if defined(BOARD_PI_ZERO)

#define NF_POSIX_GPIO
// 1 bank
#define GPIO_MAX_PIN        27
#define TOTAL_GPIO_PORTS    27

#endif // BOARD_PI_ZERO

#if defined(BOARD_JH7100)

#define NF_POSIX_GPIO
// TODO: 1 bank?
#define GPIO_MAX_PIN        48
#define TOTAL_GPIO_PORTS    48

#endif // BOARD_JH7100


#if defined(BOARD_PI_PICO)

#define NF_POSIX_GPIO
#define GPIO_MAX_PIN        26
#define TOTAL_GPIO_PORTS    26

#endif // BOARD_PI_PICO

#if defined(BOARD_ESP32_C3)

#define NF_POSIX_GPIO
#define GPIO_MAX_PIN        21
#define TOTAL_GPIO_PORTS    21

#endif // BOARD_ESP32_C3

// common linux
#if defined(__linux__) && defined(NF_POSIX_GPIO)

#include <gpiod.h>

// TODO: multi chip/bank solution
struct gpiod_chip *_chip;

static gpiod_line* pinLineStored[GPIO_MAX_PIN];
static GpioPinValue pinLineValue[GPIO_MAX_PIN];

#endif // __linux__

// common nuttx
#if defined(__nuttx__) && defined(NF_POSIX_GPIO)

// for now we ca handle only 1 bank/chip
#define GPIO_MAX_BANK 1
static int ioctrlFdReference[GPIO_MAX_BANK];
static GpioPinValue pinLineValue[GPIO_MAX_PIN];

#endif //__nuttx__

// common all
#if defined(NF_POSIX_GPIO)

static GpioPinDriveMode pinDirStored[GPIO_MAX_PIN];

#endif

#endif  //_CPU_GPIO_H_
