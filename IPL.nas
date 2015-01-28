HEADSIZE EQU 4

;SunnyDoll

	ORG	0x7c00

;FAT32 Structure

	JMP	entry
	DB	0x90
	DB	"Wind    "	;The name of Boot Sector
	DW	0x0200	;0x0200 bytes per sector
	DB	0x08	;8 sectors per cluster
	DW	0x02FC	;0x02FC sectors reserved
	DB	0x02	;The number of FAT
	DD	0x00
	DB	0xF8	;Type of the storage
	DW	0x00
	DW	0x3F	;0x3F sectors per track
	DW	0xFF	;The number of heads
	DD	0x3F	;The sectors hiden
	DD	0xFA863F	;The total number of sectors
	DD	0x3E82	;0x3E82 sectors per FAT
	DD	0x00
	DD	0x02	;The entry of root directory
	DW	0x01	;The sector containing file system info
	DW	0x06	;The sector containing  backup of boot sector
	DD	0x00, 0x00, 0x00
	DB	0x80	;The drive number
	DB	0x00
	DB	0x29	;Extended boot flag
	DD	0x3A8DDB54	;Disk Serial Number
	DB	"NO NAME    "	;Label
	DB	"FAT32   "		;The name of file system

;IPL Program

entry:
	;Initialize
	MOV	AX, 0
	MOV	SS, AX
	MOV	SP, 0x7c00
	MOV	DS, AX
	MOV	ES, AX

	MOV	AH, 0x10	;0x10 Set video mode
	MOV	AL, 0x12	;640¡Á480 16Colors
	INT	0x10

	MOV	AX, 0x0820
	MOV	ES, AX
	MOV	CH, 0	;Cylinder 0
	MOV	DH, 0	;Head 0
	MOV	CL, 2	;Sector 2
	MOV	DI, 0	;The counter of failures

load:
	MOV	AH, 0x02	;0x13 Interrupt - Read the drive
	MOV	AL, 1	;Read one sector
	MOV	BX, 0
	MOV	DL,  0x80	;The drive number
	INT	0x13
	JC	error;

	ADD	BX, 0x200	;The offset of one sector

	ADD	CL, 1
	CMP	CL, 0x3F
	JB	load
	MOV	CL, 0

	ADD	DH, 1
	CMP	DH, HEADSIZE
	JB	load

	MOV	SI, msg	;Print the welcome message
	JMP	print
error:
	MOV	AH, 0x00	;Reset the drive
	MOV	DL, 0x00
	INT	0x13
	ADD	DI, 1
	CMP	DI, 5
	JB	load
	MOV	SI, errmsg	;Print the error message

print:
	MOV	AL, [SI]
	ADD	SI, 1
	CMP	AL, 0
	JE	end

	MOV	AH, 0x0E	;0x10 Interrupt - Teletype output
	MOV	BL, 0x0A	;Set the color of character
	INT	0x10
	JMP	print

msg:
	DB	"Welcome to the world of Sunny Doll."
	DB	0x0D, 0x0A
	DB	0x00

errmsg:
	DB	"Failed to load the System."
	DB	0x0D, 0x0A
	DB	0x00

end:
	HLT

;The rest empty
	TIMES	0x1FE - ($ - $$)	DB 0x00
	DB	0x55, 0xAA