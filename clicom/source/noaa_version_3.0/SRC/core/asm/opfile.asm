PAGE ,132
;******************************************************************************
;			PROCEDURE OPFILE
;
;	Calling Language: MICROSOFT FORTRAN
;
;	Parameters: CHARACTER*1 FCB(44)
;		    INTEGER*2  EFLAG
;
;	Entry Conditions: FCB contains information necessay for DOS file
;		 	  control block.  See DOS Programmer's Reference Manual
;
;	DESCRIPTION: Uses DOS Function number 15 to open a file that already
;  		     exists based on the information contained in the FCB. 
;		     EFLAG is set to one (1) to indicate success in opening
;		     the file.  Otherwise, the EFLAG is set to zero (0) to
;		     indicate an error.
;
;******************************************************************************
;
DATA	SEGMENT PUBLIC 'DATA'

EMSG1	DB	'OPFILE failed to open the file$'
EPTR1	DD	EMSG1

DATA	ENDS
DGROUP	GROUP DATA

STACKF	STRUC				;Define Stack Addresses
   SAVEBP	DW ?
   RTNADR	DD ?
   EFLAG	DD ?
   FCBPTR       DD ?
STACKF	ENDS

CODE	SEGMENT 'CODE'
ASSUME	CS:CODE, DS:DGROUP, SS:DGROUP

PUBLIC	OPFILE
OPFILE	PROC FAR

	PUSH	BP			;Save FORTRAN registers on the stack
	MOV	BP,SP
	PUSH	DI
	PUSH	ES
	PUSH	DS

INCLUDE WTERR.INC

;******************************************************************************
;	Set up registers and call DOS Funtion #15. Set EFLAG if successful
;******************************************************************************

	LDS	DX,DWORD PTR [BP].FCBPTR	;Load pointer to FCB into DS:DX
	
	MOV	AH,0FH			;Call DOS Function #15
	INT	21H			;to open the file

	LES 	DI,DWORD PTR [BP].EFLAG	;Set up pointer to EFLAG
	
	CMP 	AL,00H			;Test for success in creating file
	JNE	ERROR

	MOV	BYTE PTR ES:[DI],01H	;Set EFLAG = 1 for success
	JMP	SHORT EXIT

;******************************************************************************
;		Set EFLAG = 0 to indicate failure to create file
;******************************************************************************

ERROR:	MOV	BYTE PTR ES:[DI],00H
	LES	DI,EPTR1		;Write out the error message
	_WTERR

;******************************************************************************

EXIT:	POP	DS			;Restore FORTRAN registers from stack
	POP	ES
	POP	DI
	POP	BP

	RET	08H			;Return to calling program

OPFILE	ENDP
CODE	ENDS
END
