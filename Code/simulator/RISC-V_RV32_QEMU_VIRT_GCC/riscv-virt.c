/*
 * FreeRTOS V202212.00
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

#include <FreeRTOS.h>

#include <string.h>

#include "riscv-virt.h"
#include "ns16550.h"

int xGetCoreID( void )
{
int id;

	__asm ("csrr %0, mhartid" : "=r" ( id ) );

	return id;
}

void vSendString( const char *s )
{
struct device dev;
size_t i;

	dev.addr = NS16550_ADDR;

	portENTER_CRITICAL();

	for (i = 0; i < strlen(s); i++) {
		vOutNS16550( &dev, s[i] );
	}
	vOutNS16550( &dev, '\n' );

	portEXIT_CRITICAL();
}

void print_uint32(uint32_t value) {
    char buf[12];
    int i = 10;
    buf[11] = '\0';
    if (value == 0) {
        buf[10] = '0';
        printf(&buf[10]);
        return;
    }
    while (value > 0 && i > 0) {
        buf[i--] = '0' + (value % 10);
        value /= 10;
    }
    printf(&buf[i+1]);
}

