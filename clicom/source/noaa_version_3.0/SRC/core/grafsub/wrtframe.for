$STORAGE:2
      SUBROUTINE WRTFRAME(IGRAPH,TITLE,SUBTITLE,COLHDR,ROWHDR,HLDARRAY,
     +                    MXDATCOL,NUMCOL,NUMROW,RTNCODE)
C     
C       ** OBJECTIVE:  OPEN GRAPHICS.API FILE; WRITE DATA TO FILE
C
C       ** INPUT:
C            TITLE......
C            SUBTITLE...
C            COLHDR.....
C            ROWHDR.....
C            HLDARRAY...
C            MXDATCOL
C            NUMCOL.....
C            NUMROW.....
C       ** OUTPUT:
C            RTNCODE....ERROR FLAG
C                       '0'=NO ERROR   '1'=MAXIMUM FILE SIZE EXCEEDED
C
$INCLUDE:  'GRFPARM.INC'      
C
      CHARACTER*(LENTXTD) TITLE,SUBTITLE,COLHDR(*)
      CHARACTER*12        ROWHDR(*)      
      CHARACTER*1         RTNCODE
      REAL*4              HLDARRAY(MXDATCOL,*)
      INTEGER*2           NUMCOL,NUMROW
C
      CHARACTER*(MXRECL) INREC,BLCRLF
      CHARACTER*1 CHRRTN,LNFEED
      LOGICAL FIRSTCALL
C
C       ** COMMON TO SAVE FILE POSITION FOR CLOSING FILE
C
      COMMON /WFRMPOS/LSTFRM,IREC,BLCRLF
C
      DATA FIRSTCALL /.TRUE./
      DATA MAXREC/32600/
C      
      CHRRTN = CHAR(13)
      LNFEED = CHAR(10)
      CALL GTRECL(IGRAPH,NUMCOL,NRECL,NCOLCHR)
      MXCWRT = NRECL-2
      BLCRLF = ' '
      BLCRLF(MXCWRT+1:MXCWRT+2) = CHRRTN//LNFEED
C
C       ** OPEN GRAPHICS.API FILE; WRITE FILE POSITION RECORD
C            
      IF (FIRSTCALL) THEN
         FIRSTCALL = .FALSE.
   10    OPEN(17,FILE='O:\DATA\GRAPHICS.API',STATUS='UNKNOWN',
     +           RECL=NRECL,FORM='BINARY',ACCESS='DIRECT',MODE='WRITE',
     +           IOSTAT=IOCHK)
         IF (IOCHK.NE.0) THEN
            CALL OPENMSG('O:\DATA\GRAPHICS.API  ','WRTFRAME    ',IOCHK)
            GO TO 10
         END IF
         CLOSE (17,STATUS='DELETE')
         OPEN(17,FILE='O:\DATA\GRAPHICS.API',STATUS='NEW',
     +           RECL=NRECL,FORM='BINARY',ACCESS='DIRECT',MODE='WRITE')
         INREC = BLCRLF
         NOWFRM = 2
         IREC=1
         WRITE(INREC(1:MXCWRT),505) NOWFRM
         WRITE(17,REC=IREC) INREC(1:NRECL)
         LSTFRM  = -1
         NLSTREC = 2
      ENDIF
C
C       ** WRITE FRAME HEADER:  LSTFRM = RECORD NUMBER OF LAST FRAME
C                               NXTFRM = RECORD NUMBER OF NEXT FRAME
C                               NCURREC= NUMBER OF RECORDS IN CURRENT FRAME
C                                        DOES NOT INCLUDE FRAME HEADER
C
      RTNCODE='0'
      NOWFRM = LSTFRM + NLSTREC + 1
      IREC = NOWFRM
      NCURREC =NUMROW+3
      NXTFRM = NOWFRM + NCURREC +1
      IF (NXTFRM.GE.MAXREC .OR. NOWFRM.GE.MAXREC) THEN
         RTNCODE='1'
         GO TO 100
      ENDIF   
      INREC = BLCRLF
      WRITE(INREC(1:MXCWRT),505) LSTFRM,NXTFRM,NCURREC
      WRITE(17,REC=IREC) INREC(1:NRECL)
C
C       ** WRITE TITLE, SUBTITLE, COLUMN HEADERS
C
      INREC = BLCRLF
      IREC=IREC+1
      WRITE(INREC(1:MXCWRT),500) TITLE
      WRITE(17,REC=IREC) INREC(1:NRECL)
      INREC = BLCRLF
      IREC=IREC+1
      WRITE(INREC(1:MXCWRT),500) SUBTITLE
      WRITE(17,REC=IREC) INREC(1:NRECL)
      INREC = BLCRLF
      IREC=IREC+1
      WRITE(INREC(1:MXCWRT),510) (COLHDR(I)(1:NCOLCHR),I=1,NUMCOL)
      WRITE(17,REC=IREC) INREC(1:NRECL)
C
C       ** WRITE DATA RECORDS
C
      DO 30 I=1,NUMROW
         INREC = BLCRLF
         IREC=IREC+1
         WRITE(INREC(1:MXCWRT),515) I,ROWHDR(I),
     +                             (HLDARRAY(J,I),J=1,NUMCOL)
         WRITE(17,REC=IREC) INREC(1:NRECL)
   30 CONTINUE
C
C       ** SET UP FILE POSITION FOR NEXT RECORD      
C      
      LSTFRM  = NOWFRM
      NLSTREC = NCURREC
C      
  100 RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(A)
  505 FORMAT(I5,1X,I5,1X,I5)
  510 FORMAT(16X,36(1X,A,:))
  515 FORMAT(I3,1X,A12,36(1X,F9.2,:))
C
      END        
      SUBROUTINE ENDFRAME(IGRAPH,NUMCOL)
C
C       ** OBJECTIVE:  WRITE FINAL FRAME HEADER INDICATING END OF 
C                      GRAPHICS.API FILE; CLOSE FILE
C       ** INPUT:
C             LSTFRM...RECORD NUMBER OF LAST FRAME
C                      (INPUT THRU COMMON; DEFINED IN WRTFRAME)
C      
C       ** COMMON TO SAVE FILE POSITION FOR CLOSING FILE
C
$INCLUDE:  'GRFPARM.INC'      
      CHARACTER*(MXRECL) INREC,BLCRLF
      COMMON /WFRMPOS/LSTFRM,IREC,BLCRLF
C
C       ** WRITE FRAME HEADER:  LSTFRM = RECORD NUMBER OF LAST FRAME
C                               NXTFRM = RECORD NUMBER OF NEXT FRAME
C                               NCURREC= NUMBER OF RECORDS IN CURRENT FRAME
C
      IREC=IREC+1
      NXTFRM = -1
      NCURREC = 0
      CALL GTRECL(IGRAPH,NUMCOL,NRECL,NCOLCHR)
      MXCWRT=NRECL-2
      INREC = BLCRLF
      WRITE(INREC(1:MXCWRT),505) LSTFRM,NXTFRM,NCURREC
      WRITE(17,REC=IREC) INREC(1:NRECL)
C
      CLOSE (17)
C
      RETURN
C
C       ** FORMAT STMTS
C      
  505 FORMAT(I5,1X,I5,1X,I5)
C  
      END            
      