#pragma large

#include <config.h>            

#define PRODUCER_NBR 1 /* Task number for the producer task */
#define CONSUMER_NBR 0 /* Task number for the consumer task */
#define SSS 2 /* Task number for the consumer task */
#define OS_STARTUP 3


#pragma REGISTERBANK (2)
void example_2 (void) _task_ SSS _priority_ 3
{
	static u16 ch;
	u8 i = 0;
	while(1)
	{
		
		os_wait (K_MBX+1, 0xff, &ch);
		for(i = 0;i<10;i++)
		{
			os_wait2 (K_IVL, 100);//10ms
		}
		
		printf("\x0c\033[1;32m");
		printf("tasks%d\n",(int)os_running_task_id());
		printf("%s", *( (u8 *xdata*)(ch)));
		os_wait (K_MBX+1, 0xff, &ch);
		printf(" %s", *( (u8 *xdata*)(ch)));
		printf("\r\n");

		printf("\033[1;35;40m good!!! \033[1;37m Hello,NSFocus \n");
//		printf("\n\rby DoYoung V1.0 2006.11.11\a");
//		SendString("\x0c\033[1;32m");

	}
}
#pragma REGISTERBANK (0)


void serial_init ()
{
	S1_8bit();
	S1_RX_Enable();
	S1_BRT_UseTimer2();		
	Timer2_1T();
	Timer2_Load(0xFFC3);
	Timer2_Run();
	os_enable_isr (4);                 /* enable serial port interrupt        */
}

void producer_task (void) _task_ PRODUCER_NBR
{
	unsigned int send_mes;
	u8 * ss = __TIME__;
	send_mes = 1;
	for (;;) { /* end-less loop */
	/* Send actual value of "send_mes" to the mailbox 0 */
	/* If the mailbox is full, wait until there is room */
	/* for the message */
		os_send_message (0, send_mes, 0xff);
		send_mes++;
		os_send_message (1, (u16)&ss, 0xff);

	}
}


void consumer_task (void) _task_ CONSUMER_NBR _priority_ 1
{
	unsigned int rec_mes;
	u8* sd = __DATE__;
	for (;;) {
	/* Read from the mailbox 0 to the variable "rec_mes" */
	/* Wait for a message if the mailbox is empty */
		os_wait (K_MBX+0, 0xff, &rec_mes);
		/*
		... Perform some calculations with "rec_mes"
		*/
		os_send_message (1, (u16)&sd, 0xff);
	}
}
void startup_task (void) _task_ OS_STARTUP 
{
	os_set_slice(2800);//0.1ms
	serial_init ();
	os_create_task (PRODUCER_NBR); 
	os_create_task (CONSUMER_NBR); /* Create the consumer task */
	os_create_task (SSS); /* Create the consumer task */
	os_delete_task (OS_STARTUP);
}

void main (void)
{
/* Initialize the system and start the producer task */
	
	S1_USE_P16P17();

	Timer1_1T();
	Timer0_1T();
	TI = 1;
	os_start_system (OS_STARTUP);
	
}

