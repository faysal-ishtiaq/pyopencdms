$STORAGE:2
      SUBROUTINE WRTGRAF(GRAFNAME,ITYPE,ITEMP,RTNFLAG)
C
C   ROUTINE TO WRITE THE CURRENT GRAPH DEFINITION TO THE GDF FILE.      
C   THE DEFINITION IS WRITTEN INTO 2 FILES: 'GRAPHICS.GDF' CONTAINS THE
C   DEFINITION OF THE CURRENT GRAPH TO BE USED BY GRAFMAN; THE OTHER IS
C   NAMED WITH THE GRAPH NAME AND HOLDS THE GRAPH DEFINITION PERMANENTLY.
C
C   INPUT:
C      GRAFNAME...NAME OF THE CURRENT GRAPH (CHAR*8)
C      ITYPE......CLICOM INTEGER OBS-TYPE FOR THE CURRENT GRAPH
C      ITEMP......0=WRITE TO TEMPORARY AND PERMANENT FILES
C                 1=WRITE TO TEMPORARY FILE ONLY
C   OUTPUT:
C      RTNFLAG....'4F' IF USER HAS PRESSED F4 OR ROUTINE IS UNABLE TO 
C                 THE DEFINITION TO DISK.
C
C    ------------------------------------------------------------------
C    |  NOTE: THIS ROUTINE HAS BEEN WRITTEN AND TESTED IN CONJUNCTION |
C    |        WITH GRAFINIT.  ADDITIONAL CODE MUST BE WRITTEN TO      |
C    |        INCORPORATE THIS ROUTINE INTO GRAFMAN.                  |
C    ------------------------------------------------------------------
C
      CHARACTER*8 GRAFNAME
      CHARACTER*2 RTNFLAG
      INTEGER*2 ITYPE,ITEMP
C      
C       ** LOCAL COMMON TO SAVE SPACE IN D-GROUP
C
      REAL*4 XLL,YLL
      INTEGER*2 NBRCHR,MSGLEN(4)
      LOGICAL FIRSTPASS,NEWNAME
      CHARACTER*80 MSGLIN(4)
      CHARACTER*32 GRAFDESC
      CHARACTER*28 STRG1,STRG2
      CHARACTER*20 GRAFFILE
      CHARACTER*1 REPLY,RTNCODE
      CHARACTER*2 YESUP,YESLO
      CHARACTER*8 SAVNAM
C
      COMMON /WRTGSV/ XLL,YLL,    NBRCHR,MSGLEN,    FIRSTPASS,NEWNAME,
     +                MSGLIN,GRAFDESC,GRAFFILE,REPLY,RTNCODE,
     +                YESUP,YESLO,SAVNAM,STRG1,STRG2
C      
      LOGICAL FIRSTCALL,BLNKFLG
C      
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'GRAFVAR.INC'
      DATA FIRSTCALL /.TRUE./
C
C   IF THIS IS THE FIRST CALL TO THIS ROUTINE - READ MESSAGE TEXT AND
C   DETERMINE HOW LONG EACH IS.
C
      IF (FIRSTCALL) THEN
         FIRSTCALL = .FALSE.
         CALL GETYN(1,2,YESUP,YESLO)
         MSGLIN(3) = ' '
         NMSG=366
         CALL GETMSG(NMSG,MSGLIN(3))
         CALL PARSE1(MSGLIN(3),80,2,80,MSGLIN(1),RTNCODE)
         CALL GETMSG(367,MSGLIN(3))
         CALL GETMSG(181,MSGLIN(4))
         CALL GETMSG(999,MSGLIN(4))
         DO 30 I1 = 1,4
            DO 20 I2 = 78,1,-1
               IF (MSGLIN(I1)(I2:I2).NE.' ') THEN
                  MSGLEN(I1) = I2 + 1
                  GO TO 30
               ENDIF
20          CONTINUE
30       CONTINUE            
      ENDIF
C
C   FIND THE CURRENT VIDEO MODE
C
      CALL STATUS(IMODE,ICOLS,IPAGE)
C
C   IF IN TEXT MODE, ASSUME ROUTINE IS CALLED FROM GRAFINIT SO CURSOR
C   POSITION HAS ALREADY BEEN SET.  ALSO USE TEXT MODE DISPLAY ROUTINES
C   TO ASK FOR USER INPUT
C
      NEWNAME = .FALSE.
      IF (ITEMP.EQ.1) GO TO 140
      IF (IMODE.EQ.3) THEN
         CALL POSLIN(IROW,ICOL)
      ENDIF
80    CONTINUE
      IF (IMODE.EQ.3) THEN
100      CONTINUE
         CALL LOCATE(IROW,ICOL,IERR)
         IF (GRAFNAME.EQ.' ') THEN
            CALL WRTSTR(MSGLIN(1),MSGLEN(1),14,0)
            CALL GETSTR(0,GRAFNAME,8,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               RETURN
            ELSE IF (GRAFNAME.EQ.' ') THEN
               GO TO 100
            ENDIF
            NEWNAME = .TRUE.
         ELSE
            CALL WRTSTR(MSGLIN(3),MSGLEN(3),14,0)
            REPLY = ' '
            CALL GETSTR(0,REPLY,1,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               RETURN
            ELSE IF (REPLY.EQ.YESUP(1:1)) THEN
               CALL LOCATE(IROW+1,ICOL,IERR)
               CALL WRTSTR(MSGLIN(1),MSGLEN(1),14,0)
               CALL GETSTR(0,GRAFNAME,8,15,1,RTNFLAG)
               IF (RTNFLAG.EQ.'4F') THEN
                  GO TO 100
               ENDIF
               NEWNAME = .TRUE.
            ENDIF
         ENDIF
         IF (NEWNAME) THEN
            CALL LOCATE(IROW+2,ICOL,IERR)
            CALL WRTSTR(MSGLIN(2),MSGLEN(2),14,0)
            GRAFDESC = ' '
            CALL GETSTR(1,GRAFDESC,32,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               GO TO 100
            ENDIF
         ENDIF
C
C   IF NOT IN TEXT MODE, USE GRAPHICS MODE TEXT DISPLAY ROUTINES TO ASK
C   FOR USER INPUT.
C---------------------------------------------------------------------------
C (............ THIS SECTION MUST BE WRITTEN .........)
C---------------------------------------------------------------------------
      ELSE
  110    XLL = 0.3
         YLL = 0.9
         NBCHR = 0
         IF (GRAFNAME.EQ.' ') THEN
C
C---  ASK THE USER TO SUPPLY A FILE NAME TO SAVE THE GRAPH DEFINITION FILE 
C 
  120       CALL GRAFMSG(XLL,YLL,526,527,' ',0,0,8,GRAFNAME,NBCHR)
            IF (GRAFNAME .EQ. 'ES') THEN
               RTNFLAG = '4F'
               RETURN
            ELSE
               IF (NBCHR .LT. 1) THEN
                  GO TO 120
               ENDIF
            ENDIF
C            CALL NAMECAPS(GRAFNAME)
            NEWNAME = .TRUE.
         ELSE
            RTNFLAG = '  '
            CALL GRAFNOTE(XLL,YLL,532,503,' ',0,RTNFLAG)
            IF (RTNFLAG .EQ. 'ES') THEN
               RTNFLAG = '4F'
               RETURN
            ELSE
               IF (RTNFLAG.EQ.YESUP .OR. RTNFLAG.EQ.YESLO) THEN
                  SAVNAM=GRAFNAME
                  CALL GRAFMSG(XLL,YLL,526,527,' ',0,0,8,GRAFNAME,NBCHR)
                  IF (GRAFNAME .EQ. 'ES'. OR. NBCHR .LT. 1) THEN
                     GRAFNAME=SAVNAM
                     GO TO 110
                  ENDIF
C                  CALL NAMECAPS(GRAFNAME)
                  NEWNAME = .TRUE.
               ENDIF
            ENDIF
         ENDIF
         IF (NEWNAME) THEN
            GRAFDESC = ' '
            NBCHR = 0
            CALL GRAFMSG(XLL,YLL,533,508,' ',0,1,32,GRAFDESC,NBCHR)
            IF (GRAFDESC .EQ. 'ES') THEN
               GO TO 110
            ENDIF
         ENDIF
      ENDIF
  140 CONTINUE      
      IF (ITEMP.EQ.1) THEN
C
C         .. OPEN THE TEMPORARY OUTPUT GRAPH DEFINITION FILE        
C            ONLY THE TEMPORARY FILE IS WRITTEN
         FIRSTPASS = .FALSE.
         NEWNAME   = .FALSE.
         GRAFFILE = 'O:\DATA\GRAPHICS.GDF'
      ELSE
C      
C          .. OPEN THE PERMANENT OUTPUT GRAPH DEFINITION FILE
         FIRSTPASS = .TRUE.
         NBCHR = LNG(GRAFNAME)
         BLNKFLG = NBCHR.LE.0
         DO 145 I1 = NBCHR,1,-1
            IF (GRAFNAME(I1:I1).NE.' ') GO TO 145
            BLNKFLG = .TRUE.
  145    CONTINUE
         IF (BLNKFLG) THEN
            WRITE(STRG1,'(A8)') GRAFNAME     
            NBCHR = MIN0(LNG(STRG1),8)
            IF (IMODE.EQ.3) THEN
C                .. TEXT MODE MESSAGE  
               CALL WRTMSG(21-IROW,295,12,1,1,STRG1,NBCHR)
               CALL CLRMSG(21-IROW)
            ELSE
C                .. GRAPHICS MODE MESSAGE  
               XLL = 0.3
               YLL = 0.9
               RTNFLAG = '  '
               CALL GRAFNOTE(XLL,YLL,295,202,STRG1,NBCHR,RTNFLAG)
            ENDIF   
            GO TO 80
         ENDIF   
         GRAFFILE = 'O:\DATA\'//GRAFNAME
         DO 150 I1 = 20,1,-1
            IF (GRAFFILE(I1:I1).NE.' ') THEN
               GO TO 160
            ENDIF
150      CONTINUE
160      CONTINUE
         I1 = I1 + 1
         GRAFFILE(I1:I1+3) = '.GDF'         
      ENDIF
      IF (NEWNAME) THEN
         OPEN (11,FILE=GRAFFILE,STATUS='NEW',FORM='FORMATTED'
     +        ,MODE='WRITE',IOSTAT=IOCHK)
         IF (IOCHK.NE.0) THEN
            IF (NEWNAME) THEN
               IF (IMODE.EQ.3) THEN
                  CALL LOCATE(IROW+4,ICOL,IERR)
                  CALL WRTSTR(MSGLIN(4),MSGLEN(4),12,0)
                  CALL BEEP
                  CALL GETCHAR(0,RTNFLAG)
                  CALL CLRMSG(21-IROW)
               ELSE
C--------------------------------------------------------------------------
C INSERT CODE HERE FOR GRAPHICS MODE MESSAGES  
C--------------------------------------------------------------------------
                  XLL = 0.3
                  YLL = 0.9
                  NBCHR = 0
                  RTNFLAG = '  '
                  CALL GRAFNOTE(XLL,YLL,531,505,' ',0,RTNFLAG)
               ENDIF   
               IF (RTNFLAG.NE.YESUP.AND.RTNFLAG.NE.YESLO) THEN
                  GO TO 80
               ELSE
                  OPEN (11,FILE=GRAFFILE,STATUS='OLD'
     +                 ,FORM='FORMATTED',MODE='WRITE',IOSTAT=ICHKOLD)
               ENDIF
            ENDIF
         ENDIF
      ELSE
         OPEN (11,FILE=GRAFFILE,STATUS='OLD',FORM='FORMATTED'
     +        ,MODE='WRITE',IOSTAT=ICHKOLD)
      ENDIF
      IF (ICHKOLD.NE.0) THEN
         WRITE(STRG1,'(A20,1X,I5)') GRAFFILE,ICHKOLD     
         NBCHR = MIN0(LNG(STRG1),28)
         IF (IMODE.EQ.3) THEN
C             .. TEXT MODE MESSAGE  
            CALL WRTMSG(21-IROW,157,12,1,1,STRG1,NBCHR)
            CALL CLRMSG(21-IROW)
         ELSE
C             .. GRAPHICS MODE MESSAGE  
            XLL = 0.3
            YLL = 0.9
            RTNFLAG = '  '
            CALL GRAFNOTE(XLL,YLL,157,202,STRG1,NBCHR,RTNFLAG)
         ENDIF   
         GO TO 80
      ENDIF   
C
C       **  WRITE THE GRAPH DEFINITION
C
  180 CONTINUE
         GDFNAME = GRAFNAME
         IOBSTYP = ITYPE
         WRITE(11,500) IGRAPH,IOBSTYP,NBRELEM,NROWDIM,NUMCOL,NUMPLT
     +                ,ITYPSET,NFRSET,OBSTYPE,GDFNAME
C
C      WRITE DEFINITION IF IT IS A TIME-SERIES (X-Y) PLOT
C
         IF (IGRAPH.EQ.1) THEN
            MXNVAL = MIN0(NUMCOL,MXELEM)        
            WRITE(11,510) (GRAFELEM(I1),I1=1,NBRELEM)
            WRITE(11,514) LOWROW,LOWCOL,HIROW,HICOL
     +                   ,LEGEND,PLTWID,NGRFSCR
            WRITE(11,518) VPNDLF,VPNDRT,VPNDBT,VPNDTP
     +                   ,GANWLF,GANWRT,GANWBT,GANWTP
            WRITE(11,516) ((LFTSCALE(I1,J1),I1=1,2),J1=1,MXNVAL)
            WRITE(11,516) (( RTSCALE(I1,J1),I1=1,2),J1=1,MXNVAL)
            WRITE(11,516)    BTSCALE(1),BTSCALE(2)
            CALL APOSTRG(GRTITLE,   STRG1)
            CALL APOSTRG(GRSUBTITLE,STRG2)
            WRITE(11,512)  STRG1,STRG2
            DO 190 I1=1,MXNVAL
               CALL APOSTRG(LFTTXT(I1),STRG1)
               CALL APOSTRG( RTTXT(I1),STRG2)
               WRITE(11,512)  STRG1,STRG2
  190       CONTINUE
            CALL APOSTRG(BOTTXT,STRG1)
            WRITE(11,512)  STRG1
            CALL APOSTRG(FTXT,STRG1)
            WRITE(11,512)  STRG1
            WRITE(11,514) BKGNCLR
            WRITE(11,520) 
     +            TLCLR,  TLFONT  ,TLSIZE,  TLASP,  TLLOC(1),  TLLOC(2) 
     +         , STLCLR, STLFONT, STLSIZE, STLASP, STLLOC(1), STLLOC(2)
     +         ,LTXTCLR,LTXTFONT,LTXTSIZE,LTXTASP,LTXTLOC(1),LTXTLOC(2)
     +         ,RTXTCLR,RTXTFONT,RTXTSIZE,RTXTASP,RTXTLOC(1),RTXTLOC(2)
     +         ,BTXTCLR,BTXTFONT,BTXTSIZE,BTXTASP,BTXTLOC(1),BTXTLOC(2)
     +         ,FTXTCLR,FTXTFONT,FTXTSIZE,FTXTASP,FTXTLOC(1),FTXTLOC(2)
     +         , LEGCLR, LEGFONT, LEGSIZE, LEGASP, LEGLOC(1), LEGLOC(2)
            WRITE(11,521) AXSCLR,AXSFONT,AXSTHK,ATXTSIZE,ATXTASP,TICSIZE
            WRITE(11,522) NCHRBT,(NDECLF(I1),I1=1,MXNVAL)
     +                          ,(NDECRT(I1),I1=1,MXNVAL)
            WRITE(11,524) XMAJBT,(YMAJLFT(I1),I1=1,MXNVAL)
            WRITE(11,524)         (YMAJRT(I1),I1=1,MXNVAL)
            WRITE(11,522) XMINBT,(YMINLFT(I1),I1=1,MXNVAL)
            WRITE(11,522)         (YMINRT(I1),I1=1,MXNVAL)
            WRITE(11,522) XGRDCLR,XGRDTHK,YGRDCLR,YGRDTHK
            WRITE(11,522) (XGRDTYP(I1),I1=1,MXNVAL)
     +                   ,(YGRDTYP(I1),I1=1,MXNVAL)
            WRITE(11,523) PALETTE,((PALDEF(I1,J1),I1=1,16),J1=1,12)
            DO 200 I1 = 1,MXNVAL
               WRITE(11,522) COLTYPE(I1),COLAXIS(I1),COLTHK(I1)
     +                      ,COL1CLR(I1),COL2CLR(I1)
  200       CONTINUE     
C
C      WRITE DEFINITION IF IT IS A MAP
C
         ELSE IF (IGRAPH.EQ.2) THEN
            MXNVAL = MIN0(NUMCOL,MXELEM) - 2       
            WRITE(11,505) LOWLAT,HILAT,LOWLON,HILON
            WRITE(11,510) (GRAFELEM(I1),I1=1,NBRELEM)
            WRITE(11,514) LOWROW,LOWCOL,HIROW,HICOL
     +                   ,LEGEND,PLTWID,NGRFSCR
            WRITE(11,518) VPNDLF,VPNDRT,VPNDBT,VPNDTP
     +                   ,GANWLF,GANWRT,GANWBT,GANWTP
            WRITE(11,516) LFTSCALE(1,1),LFTSCALE(2,1)
            WRITE(11,516)  BTSCALE(1),   BTSCALE(2)
            CALL APOSTRG(GRTITLE,   STRG1)
            CALL APOSTRG(GRSUBTITLE,STRG2)
            WRITE(11,512)  STRG1,STRG2
            DO 290 I1=1,MXNVAL
               CALL APOSTRG(LFTTXT(I1),STRG1)
               WRITE(11,512)  STRG1
  290       CONTINUE
            CALL APOSTRG(BOTTXT,STRG1)
            WRITE(11,512)  STRG1
            CALL APOSTRG(FTXT,STRG1)
            WRITE(11,512)  STRG1
            WRITE(11,514) BKGNCLR
            WRITE(11,520) 
     +            TLCLR,  TLFONT  ,TLSIZE,  TLASP,  TLLOC(1),  TLLOC(2) 
     +         , STLCLR, STLFONT, STLSIZE, STLASP, STLLOC(1), STLLOC(2)
     +         ,LTXTCLR,LTXTFONT,LTXTSIZE,LTXTASP,LTXTLOC(1),LTXTLOC(2)
     +         ,BTXTCLR,BTXTFONT,BTXTSIZE,BTXTASP,BTXTLOC(1),BTXTLOC(2)
     +         ,FTXTCLR,FTXTFONT,FTXTSIZE,FTXTASP,FTXTLOC(1),FTXTLOC(2)
     +         , LEGCLR, LEGFONT, LEGSIZE, LEGASP, LEGLOC(1), LEGLOC(2)
            WRITE(11,521) AXSCLR,AXSFONT,AXSTHK,ATXTSIZE,ATXTASP,TICSIZE
            WRITE(11,526) NDECRT(3),YMAJRT(1),YMAJRT(2)
            WRITE(11,526) RTXTFONT,RTXTSIZE,RTXTASP
            WRITE(11,522) NDECRT(1)
            WRITE(11,524) XMAJBT,YMAJLFT(1)
            WRITE(11,522) XMINBT,YMINLFT(1)
            WRITE(11,522) XGRDCLR,XGRDTHK,(XGRDTYP(I1),I1=1,MXNVAL)
            WRITE(11,522) YGRDTHK,YGRDTYP(1)
            WRITE(11,523) PALETTE,((PALDEF(I1,J1),I1=1,16),J1=1,12)
            DO 309 I1=1,MXNVAL
               WRITE(11,522) COLTYPE(I1),COLTHK(I1),COL1CLR(I1)
  309       CONTINUE   
            DO 310 I1 = 1,MXNVAL
               WRITE(11,522) COLAXIS(I1),COL2CLR(I1)
  310       CONTINUE     
            WRITE(11,522) NDECRT(4),(MPCODE(I1),I1=1,5)
            WRITE(11,524) (CONINCR(I1),I1=1,MXNVAL)
            WRITE(11,522) NCONLEV,NDECRT(2)
            WRITE(11,525) (CONLEV(I1),I1=1,MXCONLEV)
C
C      WRITE DEFINITION IF IT IS A SOUNDING
C
         ELSE IF (IGRAPH.EQ.3) THEN
            WRITE(11,514) LOWROW,LOWCOL,HIROW,HICOL
     +                   ,LEGEND,PLTWID,NGRFSCR
            WRITE(11,518) VPNDLF,VPNDRT,VPNDBT,VPNDTP
     +                   ,GANWLF,GANWRT,GANWBT,GANWTP
            WRITE(11,516) LFTSCALE(1,1),LFTSCALE(2,1),LFTSCALE(2,2)
            WRITE(11,516)  BTSCALE(1),   BTSCALE(2)
            CALL APOSTRG(GRTITLE,   STRG1)
            CALL APOSTRG(GRSUBTITLE,STRG2)
            WRITE(11,512)  STRG1,STRG2
            CALL APOSTRG(FTXT,STRG1)
            WRITE(11,512)  STRG1
            WRITE(11,514) BKGNCLR
            WRITE(11,520) 
     +            TLCLR,  TLFONT  ,TLSIZE,  TLASP,  TLLOC(1),  TLLOC(2) 
     +         , STLCLR, STLFONT, STLSIZE, STLASP, STLLOC(1), STLLOC(2)
     +         ,FTXTCLR,FTXTFONT,FTXTSIZE,FTXTASP,FTXTLOC(1),FTXTLOC(2)
     +         , LEGCLR, LEGFONT, LEGSIZE, LEGASP, LEGLOC(1), LEGLOC(2)
            WRITE(11,523) PALETTE,((PALDEF(I1,J1),I1=1,16),J1=1,12)
            DO 330 I1 = 1,2
               WRITE(11,522) COLTYPE(I1),COLTHK(I1),COL1CLR(I1)
330         CONTINUE     
C
C      WRITE DEFINITION IF IT IS A WIND ROSE
C
         ELSE IF (IGRAPH.EQ.4) THEN
            MXNVAL = MXWRCAT
            WRITE(11,510) (GRAFELEM(I1),I1=1,NBRELEM)
            WRITE(11,514) LOWROW,LOWCOL,HIROW,HICOL
     +                   ,LEGEND,PLTWID,NGRFSCR
            WRITE(11,518) VPNDLF,VPNDRT,VPNDBT,VPNDTP
     +                   ,GANWLF,GANWRT,GANWBT,GANWTP
            WRITE(11,516) LFTSCALE(1,1),LFTSCALE(2,1)
            WRITE(11,516)  BTSCALE(1),   BTSCALE(2)
            CALL APOSTRG(GRTITLE,   STRG1)
            CALL APOSTRG(GRSUBTITLE,STRG2)
            WRITE(11,512)  STRG1,STRG2
            CALL APOSTRG(FTXT,STRG1)
            WRITE(11,512)  STRG1
            WRITE(11,514) BKGNCLR
            WRITE(11,520) 
     +            TLCLR,  TLFONT  ,TLSIZE,  TLASP,  TLLOC(1),  TLLOC(2) 
     +         , STLCLR, STLFONT, STLSIZE, STLASP, STLLOC(1), STLLOC(2)
     +         ,FTXTCLR,FTXTFONT,FTXTSIZE,FTXTASP,FTXTLOC(1),FTXTLOC(2)
     +         , LEGCLR, LEGFONT, LEGSIZE, LEGASP, LEGLOC(1), LEGLOC(2)
            WRITE(11,514) NCHRBT,(NDECLF(I),I=1,5)
            WRITE(11,523) PALETTE,((PALDEF(I1,J1),I1=1,16),J1=1,12)
            DO 340 I1=1,MXNVAL
               WRITE(11,522) COL1CLR(I1),COLTYPE(I1)
  340       CONTINUE
         ENDIF
C
C   REPEAT OUTPUT STATEMENTS FOR THE TEMPORARY OUTPUT FILE
C
      IF (FIRSTPASS) THEN
         FIRSTPASS = .FALSE.
         CLOSE (11)
         OPEN (11,FILE='O:\DATA\GRAPHICS.GDF',STATUS='UNKNOWN'
     +        ,FORM='FORMATTED',MODE='WRITE')
         GO TO 180
      ENDIF
C
C   IF THIS IS A NEW GRAPH ENTER THE NAME AND DESCRIPTION INTO THE
C   GRAPH DEFINITION INDEX FILE
C
      CLOSE(11)
      IF (NEWNAME) THEN
         CALL GRAFIDX(GRAFNAME,GRAFDESC)
      ENDIF
      RETURN
C
C       ** FORMAT STATEMENTS
C      
  500 FORMAT(I3,7(',',I3),',''',A3,''',''',A28,'''')
  505 FORMAT(4(F8.2,:,','))
  510 FORMAT(24(I4.3,:,','))
  512 FORMAT(24('''',A28,'''',:,','))
  514 FORMAT(7(I3,:,','))
  516 FORMAT(24(F10.3,:,','))
  518 FORMAT(8(F6.4,:,','))
  520 FORMAT(7(2(I3,','),4(F11.4,:,','),/))
  521 FORMAT(3(I3,','),3(F11.4,:,','))
  522 FORMAT(193(I2,:,','))
  523 FORMAT(I2,',',16(I2,:,','))
  524 FORMAT(25(F8.3,:,','))
  525 FORMAT(10(F10.3,:,','))
  526 FORMAT(I3,',',2(F11.4,:,','))
      END
************************************************************************ 

      SUBROUTINE GRAFIDX(GRAFNAME,GRAFDESC)
C
C   ROUTINE TO STORE THE CURRENT GRAPH NAME AND DESCRIPTION INTO THE 
C   GRAPH DEFINITION INDEX FILE (\DATA\GRAFDEF.IDX).  
C
      CHARACTER*8 GRAFNAME
      CHARACTER*32 GRAFDESC
C      
      CHARACTER*1 CHRRTN,LNFEED
      CHARACTER*43 INREC
      CHRRTN = CHAR(13)
      LNFEED = CHAR(10)
C
      OPEN (51,FILE='O:\DATA\GRAFDEF.IDX',STATUS='UNKNOWN'
     +     ,FORM='BINARY',ACCESS='DIRECT',RECL=43)
      IDEL = 0
      DO 100 I = 1,9999
         READ(51,REC=I,ERR=110) INREC
         IF (INREC(1:8).EQ.GRAFNAME) THEN
            INREC(10:41) = GRAFDESC
            IDEL = 0
            GO TO 200
         ELSE IF (INREC(1:8).EQ.'********') THEN
            IDEL = I
         ENDIF
100   CONTINUE
110   CONTINUE
      WRITE(INREC,'(A8,1X,A32,2A1)') GRAFNAME, GRAFDESC,CHRRTN,LNFEED
C
200   CONTINUE
      IF (IDEL.GT.0) THEN
         WRITE(51,REC=IDEL) INREC
      ELSE
         WRITE(51,REC=I) INREC
      ENDIF
      CLOSE (51)
      RETURN
      END
*****************************************************************************
      SUBROUTINE APOSTRG(ORGTXT,NEWTXT)
C
C     THIS SUBROUTINE WILL PUT A DOUBLE APOSTROPHE IN A STRING SO THAT
C     FORTRAN WILL RECOGNIZE THE APOSTROPHE AS A CHARACTER, NOT A DELIMETER
C
      CHARACTER*(*) ORGTXT, NEWTXT
C
      K = LEN(NEWTXT)           ! DEFINED LENGTH OF NEW STRING
      M = LNG(ORGTXT)           ! ACTUAL LENGTH OF ORIGINAL STRING
      N = 1
      NEWTXT = ' '
      DO 100 L=1,M
         NEWTXT(N:N) = ORGTXT(L:L)
         IF (ORGTXT(L:L) .EQ. '''') THEN
            N = N + 1
            NEWTXT(N:N) = ''''
         ENDIF
         N = N + 1
         IF (N .GT. K) THEN     ! STOP MOVING TEXT WHEN NEW STRING IS FULL
            RETURN
         ENDIF
  100 CONTINUE
      RETURN
      END
      