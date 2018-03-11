#include<config.h>

u8 Counter0;

void startup_task (void) _task_ 0
{
	os_create_task(1);    /* Create serial_io Task */
	os_create_task(2);    /* Create serial_cmds Task */
	os_create_task(3);    /* Create kbd_io Task */

	P0 = 1;
	
	while(1)
	{
		
		P0 = _cror_(P0 , 1);
		os_wait2(K_IVL,250);
	}

}

void check_serial_io_task (void) _task_ 1
{
	P1 = 1;
	while(1)
	{
		P1 = _cror_(P1 , 1);
		os_wait2(K_IVL,250);

	}

}

void process_serial_cmds_task (void) _task_ 2
{
	P2 = 1;
	while(1)
	{
		P2 = _cror_(P2 , 1);
		os_wait2(K_IVL,250);
	}

}

void check_kbd_io_task (void) _task_ 3
{
//	P3 = 1;
	while(1)
	{
//		P3 = _cror_(P3 , 1);
		os_wait2(K_IVL,250);
	}

}



