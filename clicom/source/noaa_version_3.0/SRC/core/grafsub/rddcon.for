$STORAGE:2
      SUBROUTINE RDDCON(RDPLSP,OKOPT,NOK,OPTCHR,RTNCODE)
C
C       ** INPUT:
C             RDPLSP....0=DO NOT READ VARIABLES FOR /PLTSPEC/
C                       1=READ VARIABLES FOR /PLTSPEC/ 
C             OKOPT.....VALUES FOR VALID OPTION FLAGS
C             NOK.......NUMBER OF VALID OPTION FLAGS
C       ** OUTPUT:
C             OPTCHR....CURRENT OPTION FLAG IN FILE
C             RTNCODE...ERROR FLAG
C                       '0'=NO ERROR
C                       '2'=ERROR IN OPENING FILE
C                       '3'=INVALID OPTION CHARACTER
C
      INTEGER*2 NOK,RDPLSP
      CHARACTER*2 OKOPT(*),OPTCHR
      CHARACTER*1 RTNCODE      
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'FRMPOS.INC'
$INCLUDE: 'DATAVAL.INC'
$INCLUDE: 'CURRPLT.INC'
$INCLUDE: 'PLTSPEC.INC'
C
      LOGICAL OKREAD
C      
      RTNCODE = '0'
C      
      OPEN(51,FILE='O:\DATA\DATACOM.CON',STATUS='OLD',FORM='FORMATTED',
     +        MODE='READ',IOSTAT=ISTAT)
      IF (ISTAT.NE.0) THEN
         RTNCODE = '2'
         RETURN
      ENDIF    
C 
C       ** CHECK FOR A VALID OPTION FLAG
C
      READ(51,*) OPTCHR
C      
      OKREAD = .TRUE.
      DO 15 I=1,NOK
         IF (OPTCHR.EQ.OKOPT(I)) GO TO 16
   15 CONTINUE   
      OKREAD = .FALSE.
   16 CONTINUE   
C
      IF (OKREAD) THEN
C          .. VARIABLES IN COMMON -- FRMPOS      
         READ(51,*) LORFRM,HIRFRM,FRM1D,FRM2D
         READ(51,*) NBRFRM,(FRMPTR(I),I=1,NBRFRM)
C          .. VARIABLES IN COMMON -- DATAVAL         
         READ(51,*) MXDATROW,NDATROW,NPLTROW      
C          .. VARIABLES IN COMMON -- CURRPLT         
         READ(51,*) IDPLT,NCA,NCB
         IF (RDPLSP.EQ.1) THEN
C          .. VARIABLES IN COMMON -- PLTSPEC         
            READ(51,*) XMIN,XMAX,YMIN,YMAX
            READ(51,*) XORG,YORG
         ENDIF   
      ELSE   
         RTNCODE='3'
C         
         LORFRM=0
         HIRFRM=0
         FRM1D=0
         FRM2D=0
         NBRFRM=1
         FRMPTR(1)=1
         NDATROW=0
         NPLTROW=0
         MXDATROW=0
         IDPLT=0
         NCA=0
         NCB=0
      ENDIF   
C
      CLOSE (51)
C
      RETURN
      END
      SUBROUTINE WRTDCON(WRPLSP,IFLG,OPTCHR,RTNCODE)            
C
C       ** INPUT:
C             WRPLSP.....FLAG TO READ VALUES FOR PLTSPEC COMMON
C                        0=DO NOT READ  1=READ 
C             IFLG.......FLAG TO INDICATE VALUES USED FOR COMMON CONSTANTS
C                        0=SET CONSTANTS TO ZERO
C                        1=USE CURRENT VALUES FOR CONSTANTS
C             OPTCHR.....OPTION FLAG THAT WILL BE WRITTEN TO FILE
C       ** OUTPUT:
C             RTNCODE....FLAG TO INDICATE ERROR STATUS
C                        '0'=NO ERROR
C                        '2'=ERROR IN OPENING FILE      
C
      INTEGER*2 WRPLSP,IFLG
      CHARACTER*2 OPTCHR
      CHARACTER*1 RTNCODE      
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'DATAVAL.INC'
$INCLUDE: 'FRMPOS.INC'
$INCLUDE: 'CURRPLT.INC'
$INCLUDE: 'PLTSPEC.INC'
C      
      RTNCODE = '0'
C      
      OPEN(51,FILE='O:\DATA\DATACOM.CON',STATUS='UNKNOWN',
     +        FORM='FORMATTED',MODE='WRITE',IOSTAT=ISTAT)
      IF (ISTAT.NE.0) THEN
         RTNCODE = '2'
         RETURN
      ENDIF    
C
      IF (IFLG.EQ.0) THEN
         LORFRM=0
         HIRFRM=0
         FRM1D=0
         FRM2D=0
         NBRFRM=1
         FRMPTR(1)=1
         NDATROW=0
         NPLTROW=0
         MXDATROW=0
         IDPLT=0
         NCA=0
         NCB=0
      ENDIF   
C
      WRITE(51,505) OPTCHR
C          .. VARIABLES IN COMMON -- FRMPOS      
      WRITE(51,500) LORFRM,HIRFRM,FRM1D,FRM2D
      WRITE(51,500) NBRFRM,(FRMPTR(I),I=1,NBRFRM)
C          .. VARIABLES IN COMMON -- DATAVAL         
      WRITE(51,500) MXDATROW,NDATROW,NPLTROW      
C          .. VARIABLES IN COMMON -- CURRPLT         
      WRITE(51,500) IDPLT,NCA,NCB
      IF (WRPLSP.EQ.1) THEN
C          .. VARIABLES IN COMMON -- PLTSPEC         
         WRITE(51,510) XMIN,XMAX,YMIN,YMAX
         WRITE(51,510) XORG,YORG
      ENDIF   
C
      CLOSE (51)
C
      RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(12(I4,:,','))      
  505 FORMAT('''',A2,'''')
  510 FORMAT(4(F10.3,:,','))
      END
      