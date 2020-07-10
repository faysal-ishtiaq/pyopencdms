$STORAGE:2
      SUBROUTINE WINDROSE(RVAL,MXDATROW,RTNCODE)
C--------------------------------------------------------------------------
C     DRAW AN 8 OR 16 POINT WINDROSE
C 
C     INPUT ARGUMENTS:
C
C     RVAL     REAL     TABLE THAT IS 50 ROWS (UNIT SPEED CATAGORY) BY
C                       8 OR 16 COLUMNS (WIND DIRECTION) AND THE VALUES ARE
C                       THE FREQUENCY OF OCCURRENCE. # COLUMNS IS IN /GRAFVAR/ 
C     MXDATROW INT2     MAXIMUM NUMBER OF DATA ROWS SET BY GRAFMAN
C
C     OUTPUT ARGUMENTS:
C
C     RTNCODE  CHAR     RETURN STATUS  
C                       0 = OK
C                       1 = QUIT VIA ESC OR F4 KEY
C                       6 = FILE WROSPOKE.PRM NOT FOUND. QUIT
C--------------------------------------------------------------------------
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'GRAFVAR.INC'
$INCLUDE: 'CURRPLT.INC'
      PARAMETER    (MAXCAT = MXWRCAT)
      CHARACTER*1  BLK/' '/,  ISTAT, RTNCODE
      CHARACTER*2  INCHAR
      CHARACTER*20 TXTLB(MAXCAT)
      CHARACTER*28 OCLABL, TTLTXT
      CHARACTER*78 MESSAGE
      INTEGER*2    FREQTBL(MAXCAT,16), NUMCAT, INTRVL, NUMPTS, LOSP, 
     +             HISP, CALM, SPKTYP, WINDCODE(20), PCTRING, MXRADPR
      REAL         RVAL(MXDATROW,*), ANGL16(4)/10.,60.,170.,300./
      REAL         ADJRING, COMPTS(16), DGTORD, FVAL(16), SMVAL(16),
     +             SPKWID(6,3), RGLBSZ, XB(6), YB(6)
      COMMON /WINVAR/ FREQTBL, NUMCAT, INTRVL, NUMPTS, LOSP, HISP,
     +                ADJRING, COMPTS, DGTORD, FVAL, SMVAL, SPKWID,
     +                XB, YB, TXTLB, OCLABL, TTLTXT, MESSAGE
C
C --- GET WINDROSE DRAWING PARAMETERS FROM GRAFVAR COMMON BLOCK
C
      NCA    = MAX0(LOWCOL,1)
      NCB    = MIN0(HICOL,MXWRDIR)
      IDPLT  = 1
      NUMPTS = PLTWID
      NUMCAT = NCHRBT
      INTRVL = NDECLF(1)
      PCTRING= NDECLF(2)
      SPKTYP = NDECLF(3)
      NBRING = NDECLF(4)
      LPLTNG = NDECLF(5)
C      
      MXRADPR = INT(.98*LFTSCALE(2,1))
      RADINR = .1 * MXRADPR
      DRADPR  = MXRADPR - RADINR
      ADJRING= DRADPR/PCTRING
C      
      INCR   =  16/NUMPTS
      RTNCODE= '0'
C
C---- READ THE FILE WHICH DEFINES THE WIDTHS OF THE SPOKES ON THE WINDROSE
C
      OPEN(UNIT=66,FILE='O:\DATA\WROSPOKE.PRM',STATUS='OLD',
     +     IOSTAT=IOCHK)
      IF (IOCHK .EQ. 0) THEN
          DO 50 N=1,3
             READ(66,*) (SPKWID(K,N),K=1,6)
   50     CONTINUE
          DO 55 K=1,16
             READ(66,*)
   55     CONTINUE
          READ(66,*) NMPAIR
          DO 57 K=1,NMPAIR
             READ(66,*) WINDCODE(K*2-1), WINDCODE (K*2)
   57     CONTINUE
          CLOSE(66)
      ELSE
C---     FILE ERROR - WROSPOKE.PRM FILE NOT FOUND. STOP PROCESSING
         CALL GRAFNOTE(.1,.95,464,202,' ',0,INCHAR)
         RTNCODE= '6'
         RETURN
      ENDIF
C
C---  CREATE A FREQUENCY TABLE THAT IS NUMCAT BY 16 FROM THE UNIT SPEED VALUES
C---  IN RVAL.  THE SIZE OF EACH NUMCAT IS INTRVL. FOR AN 8 PT WINDROSE, THE
C---  EVEN NUMBERED COLUMNS ARE ZERO. 
C
      DO 105 N=1,MAXCAT
         LGITMWID(N)=0.0
         DO 100 M=1,16
            FVAL(M)=0.0      
            SMVAL(M)=0.0
            FREQTBL(N,M)=0
  100    CONTINUE
  105 CONTINUE
C      IROW=1     : SINCE ROW 1 IS CALM + OTHER LEGEND INFO???
      IROW=2
      DO 160 N=1,NUMCAT
         DO 140 L=1,INTRVL
            KCOL = 1
            DO 130 M=1,NUMPTS
               FVAL(KCOL)=FVAL(KCOL)+RVAL(IROW,M)
               KCOL=KCOL+INCR
  130       CONTINUE
            IROW=IROW+1
  140    CONTINUE
         DO 150 MM=1,16
            FREQTBL(N,MM)=FVAL(MM)+0.5
            SMVAL(MM)=SMVAL(MM)+FVAL(MM)
            FVAL(MM)=0.0
  150    CONTINUE
  160 CONTINUE
C----- GET FOLLOWING DATA FROM RVAL
      CALM   = RVAL(1,1) + 0.5
      AVGSPD = RVAL(1,2)
      NBREPT = RVAL(1,3)
C----  SET THE VALUE OF PCTRING FROM DEFAULT VALUE (-1) DURING  1ST DRAWING
      IF (PCTRING .LT. 0) THEN
         RTEMP = -9999.
         DO 175 MM=1,16
            IF (SMVAL(MM) .GT. RTEMP) THEN
               RTEMP=SMVAL(MM)
            ENDIF
  175    CONTINUE
         NDECLF(2) = MIN0(INT(1.25*RTEMP+0.5),100)
         PCTRING   = NDECLF(2)
         ADJRING   = DRADPR/PCTRING
      ENDIF
C
C---  SET WORLD COORDINATES FOR PROGRAM BASED ON THE NUMBER OF COMPASS
C---  POINTS FOR THE WINDROSE
C            LF = BTSCALE(1)    RG = BTSCALE(2)
C            BO = LFTSCALE(1,1) TP = LFTSCALE(2,1)
C
      RAD= RADINR
      CALL WNDSQPIX(GANWLF,GANWRT,GANWBT,GANWTP)
      CALL BGNPLT(GANWLF,GANWRT,GANWBT,GANWTP,
     +            BTSCALE,LFTSCALE(1,1),0.0,0.0)
C
C---  DETERMINE WORLD ASPECT RATIO AND DEFINE STROKE/DOT TEXT ATTRIBUTES
C
      CALL GETWASP(WORASP)
      CALL MOVABS (0.,0.)
      CALL SETDEG(1)
C
C---  DRAW EACH SPIKE OF WINDROSE. INCR=1 IS A 16-POINT WINDROSE WHILE
C---  INCR=2 IS AN 8-POINT WINDROSE
C
      CALL SETCOL(BKGNCLR)
      CALL CLR
      CALL DEFHLN(BKGNCLR,1,1) 
      DO 400 N=1,16,INCR
         CALL ESCQUIT (*900)
         THETA =COMPTS(N)
         RADIUS=RAD
         BARWID=RAD
C
C------  USE ARC DRAWING COMMAND TO DETERMINE THE 4 POINTS FOR A SPEED 
C------  CATEGORY TO BE DRAWN AT EACH COMPASS POINT OF THE WIND ROSE
C
         DO 300 K=1,NUMCAT
            RWD = SPKWID(K,SPKTYP)
            IF (FREQTBL(K,N).EQ.0 .AND. THETA.NE.0.0)  GO TO 270
C
C--------   THE RATIO, BARWID/RADIUS, IS USED TO ASSURE THAT THE WIDTH OF
C--------   EACH SPEED CATEGORY IS THE SAME EVERYWHERE ON THE WINDROSE
C--------   RWD IS THE WIDTH OF A COMPASS SPIKE (DEGREES OF ARC)
C
            ARCANG= RWD * (BARWID/RADIUS)
            RADSIN= RADIUS
            BOT   = THETA-ARCANG 
            TOP   = THETA+ARCANG
            IF (FREQTBL(K,N).EQ.0.0 )  GO TO 250
            CALL SETCOL(COL1CLR(K))
            CALL    ARC(RADIUS,BOT,TOP)
            CALL INQARC(XB(1),YB(1),XB(3),YB(3))
            RADIUS=RADIUS+(FLOAT(FREQTBL(K,N))*ADJRING)
C 
C--------   THE RATIO OF THE INNER RADIUS TO THE OUTER RADIUS IS USED TO
C--------   DRAW THE SAME DISTANCED ARC SO THAT A CATEGORY BOX IS RECTANGULAR
C 
            ARCANG= RWD * (BARWID/RADIUS)
            BOT   = THETA-ARCANG
            TOP   = THETA+ARCANG
            CALL    ARC(RADIUS,BOT,TOP)
            CALL INQARC(XB(2),YB(2),XB(4),YB(4))
            IF (THETA.EQ.90. .OR. THETA.EQ.270.) THEN
               XB(1) = AMAX1(XB(1),XB(2))
               XB(2)=XB(1)
               XB(3) = AMIN1(XB(3),XB(4))
               XB(4)=XB(3)
            ELSE IF (THETA.EQ.0. .OR. THETA.EQ.180.) THEN
               YB(1) = AMAX1(YB(1),YB(2))
               YB(2)=YB(1)
               YB(3) = AMIN1(YB(3),YB(4))
               YB(4)=YB(3)
            ENDIF
            CALL SETHAT (COLTYPE(K))
            CALL MOVABS (XB(1),YB(1))
            CALL LNABS  (XB(2),YB(2))
            CALL MOVABS (XB(3),YB(3))
            CALL LNABS  (XB(4),YB(4))
C
C--------   FIND A POINT INSIDE THE BOX TO BE FILLED BY TRAVERSING THE CENTER
C--------   LINE OF THE SPOKE. A VALID POINT IS FOUND WHEN THE COLOR OF THE
C--------   POINT IS THE SAME AS THE BACKGROUND COLOR OR THE FILL POINT IS
C--------   WITHIN THE WORLD COORDINATES.  OTHERWISE NO COLOR FILL.
C
            DO 230 L=1,9
               XTO = RADSIN + (L * 0.1) * (RADIUS-RADSIN)
               YTO = THETA * DGTORD
               XB(5) = XTO * COS(YTO)
               YB(5) = XTO * SIN(YTO) * WORASP
               CALL INQCLR (XB(5),YB(5),ICLR)
               IF (ICLR .EQ. BKGNCLR) THEN
                  CALL MOVABS (XB(5),YB(5))
                  CALL INQERR(IFUNC,IERR)
                  IF (IERR .EQ. 0) THEN
                     CALL FLOOD  (COL1CLR(K))
                     GO TO 240
                  ENDIF
               ENDIF
  230       CONTINUE
  240       CALL MOVABS (0.,0.)
C
C---        DETERMINE THE BAR WIDTH FOR THIS CATEGORY SO THAT IT IS KNOWN
C---        TO THE LEGEND DRAWING ROUTINE.
C
  250       IF (THETA .EQ. 0.0) THEN
               LGLINBAR(K)='B'
               LGCOLR(K)  =COL1CLR(K)
               LGSTYL(K)  =COLTYPE(K)
               XB(1)=(RADIUS)*COS(BOT*DGTORD)
               YB(1)=(RADIUS)*SIN(BOT*DGTORD)*WORASP
               XB(3)=(RADIUS)*COS(TOP*DGTORD)
               YB(3)=(RADIUS)*SIN(TOP*DGTORD)*WORASP
               LGITMWID(K)=ABS(YB(3)-YB(1))
            ENDIF
  270       CONTINUE
  300    CONTINUE
  400 CONTINUE
C
      TXASP = 0.9 
      IF (NBRING .LT. 6) THEN
         RGLBSZ = .04 * (GANWTP - GANWBT)
      ELSE
         RGLBSZ = .03 * (GANWTP - GANWBT)
      ENDIF
      CALL DEFHST(LEGFONT,1,0.0,TXASP,RGLBSZ,STSIZ)
      CALL DEFHDT(1,14,14,0,1,1,0)
C  
C---  DRAW VALUE FOR CALM WINDS AT CENTER OF WINDROSE 
C
      MESSAGE='               '
      CALL GETMSG(484,MESSAGE)
      CALL GETMSG(999,MESSAGE)
      TXTLB(1) = '  '
      WRITE(UNIT=TXTLB(1),FMT='(I2)') CALM
      YPOS = -0.6*RADINR 
      CALL DRWTXT(TXTLB(1),0.0,YPOS,1,0.0)
      CALL PARSE1(MESSAGE,78,3,20,TXTLB,ISTAT)
C
C---  DRAW THE PERCENTAGE RINGS 
C
      CALL MOVABS (0.,0.)
      CALL SETCOL (1)
      CALL CIR    (RAD)
      IP   = 0
      RTEMP=PCTRING
      INCR = RTEMP/NBRING + 0.5
      IF (NBRING*INCR .GT. PCTRING) THEN
          NBRING=NBRING-1
      ENDIF
      DO 450 K=1,NBRING
         RAD = RAD + INCR*ADJRING
         CALL CIR (RAD)
C  
C---  LABEL THE RINGS. DO EVERY RING IF LESS THAN 6, AND ALTERNATE RINGS 
C---  IF 6 OR MORE RINGS.
C
         IF (LPLTNG .GT. 0) THEN
            IP = IP + INCR
            OCLABL = ' '
            IF (NBRING.LT.6 .OR. MOD(K,2).EQ.0) THEN
               OCLABL(1:3) = '^22%^'
               CALL INQSTS(OCLABL,HGT,WID,OFFSET)
               OCLABL = ' '
               IF (IP .LT. 10) THEN 
                  WRITE(UNIT=OCLABL(1:2),FMT='(I1,1H%)') IP
               ELSE
                  IF (IP .LT. 100) THEN 
                     WRITE(UNIT=OCLABL(1:3),FMT='(I2,1H%)') IP
                  ELSE
                     WRITE(UNIT=OCLABL(1:4),FMT='(I3,1H%)') IP
                  ENDIF            
               ENDIF
               ANGL = ANGL16(LPLTNG)
               XB(6)=(RAD)*COS(ANGL*DGTORD)
               YB(6)=(RAD)*SIN(ANGL*DGTORD)*WORASP
C
C---           ADJUST TEXT POSITIONING FOR THE DIFFERENT ANGLES. ONLY WEST
C---           USES BOTTOM RIGHT POSITION.  MOVE THE LOWER LEFT POSITION DOWN
C---           BY THE OFFSET FOR NORTH AND BY THE HEIGHT FOR SOUTH POSITION.
C
               IF     (LPLTNG.EQ.1) THEN
                      LPLFLG = 0
               ELSEIF (LPLTNG.EQ.2) THEN
                      LPLFLG = 0
                      YB(6) = YB(6) - OFFSET
               ELSEIF (LPLTNG.EQ.3) THEN
                      LPLFLG = 2
               ELSEIF (LPLTNG.EQ.4) THEN
                      LPLFLG = 0
                      YB(6) = YB(6) - HGT
               ENDIF
               CALL DRWTXT(OCLABL,XB(6),YB(6),LPLFLG,0.0)
            ENDIF
         ENDIF
  450 CONTINUE
C
C---  DRAW PLOT TITLE, SUBTITLE, AND FREE TEXT (IF ANY) LINES
C
      IF (GRTITLE.EQ.' ') THEN
         TTLTXT = DATATITLE
      ELSE
         TTLTXT = GRTITLE
      ENDIF      
      IF (TLLOC(1) .EQ. -99999.0 .OR. TLLOC(2) .EQ. -99999.0) THEN
         TLLOC(1) = 0.1
         TLLOC(2) = 0.9
      ENDIF
      NTITL = 1
      CALL PLTTITL(TTLTXT,NTITL,TLLOC,TLFONT,TLSIZE,TLASP,TLCLR)
      IF (GRSUBTITLE.EQ.' ') THEN
         TTLTXT = DATASUB
      ELSE
         TTLTXT = GRSUBTITLE
      ENDIF      
      IF (STLLOC(1) .EQ. -99999.0 .OR. STLLOC(2) .EQ. -99999.0) THEN
         STLLOC(1) = 0.9
         STLLOC(2) = 0.9
      ENDIF
      NTITL = 2
      CALL PLTTITL(TTLTXT,NTITL,STLLOC,STLFONT,STLSIZE,STLASP,STLCLR)
      NTITL = 3
      CALL PLTTITL(FTXT,NTITL,FTXTLOC,FTXTFONT,FTXTSIZE,FTXTASP,FTXTCLR)
C
C---  GET WIND SPEED UNITS FROM ELEM.DEF FILE FOR LEGEND LABELS
C
      TXTLB(4) = ' '      
      OPEN (UNIT=30,FILE='P:\DATA\ELEM.DEF',ACCESS='DIRECT',RECL=110,
     +      STATUS='OLD',IOSTAT=IOCHK)
      IF (IOCHK .EQ. 0) THEN
         NMPAIR = NMPAIR * 2
         DO 470 K=1,NMPAIR,2
            IF (GRAFELEM(1) .EQ. WINDCODE(K) .OR. 
     +          GRAFELEM(2) .EQ. WINDCODE(K)) THEN
                READ(30,REC=WINDCODE(K)) MESSAGE,TTLTXT(1:7),TXTLB(4)
            GO TO 475
            ENDIF
  470    CONTINUE
C---     ELEMENT CODE ERROR. NO WIND SPEED UNITS FOR THE LEGEND 
         CALL GRAFNOTE(.1,.95,463,202,' ',0,INCHAR)
  475    CLOSE(30)
      ELSE
C---     FILE ERROR - ELEM.DEF,  NO WIND SPEED UNITS FOR THE LEGEND 
         CALL GRAFNOTE(.1,.95,462,202,' ',0,INCHAR)
      ENDIF
C  
C-----  BUILD SPEED LABEL STRING FOR EACH SPEED CATEGORY, THEN MEAN SPEED
C-----  AND NUMBER OF REPORTS STRINGS FOR LEGEND
C
      DO 600 K=1,NUMCAT
         LOSP  = (K-1) * INTRVL +1
         HISP  = K* INTRVL
         LGTEXT(K)=BLK
         WRITE(UNIT=LGTEXT(K)(1:2),FMT='(I2)') LOSP
         WRITE(UNIT=LGTEXT(K)(4:5),FMT='(I2)') HISP
         LGTEXT(K)(3:3) = '-'
  600 CONTINUE

      K = NUMCAT + 1
      KL = LNG(TXTLB(3))
      LGTEXT(K)   = TXTLB(3)(1:KL) // TXTLB(4)
      LGLINBAR(K) = 'T'
      LGSTYL(K)   = 1
      LGITMWID(K) = 1.0
      LGCOLR(K)   = LEGCLR

      K = K + 1
      LGTEXT(K)=TXTLB(1)
      KL = LNG(LGTEXT(K))
      WRITE(UNIT=LGTEXT(K)(KL+1:KL+4),FMT='(F4.1)') AVGSPD
      LGLINBAR(K) = 'T'
      LGSTYL(K)   = 1
      LGITMWID(K) = 1.0
      LGCOLR(K)   = LEGCLR

      K = K + 1
      LGTEXT(K)=TXTLB(2)
      KL = LNG(LGTEXT(K))
      WRITE(UNIT=LGTEXT(K)(KL+1:KL+4),FMT='(I4)') NBREPT
      LGLINBAR(K) = 'T'
      LGSTYL(K)   = 1
      LGITMWID(K) = 1.0
      LGCOLR(K)   = LEGCLR
C
C---  SET LEGEND ATTRIBUTES AND DRAW LEGEND IF SO REQUESTED
C
      CALL SETCOL(0) 
      IF (LEGEND .GT. 0) THEN
         IF (LEGLOC(1).EQ.-99999. .OR. LEGLOC(2).EQ.-99999.) THEN
            LEGLOC(1) = .1
            LEGLOC(2) = .1
         ENDIF   
         LGALIGN = 1
         LGBRDR  = 'Y'
         LGNTRY  = NUMCAT + 3
         CALL DEFHST(LEGFONT,1,0.0,LEGASP,LEGSIZE,STSIZ)
         CALL DRWLGND (LEGEND,LGBRDR,LGNTRY,LGLINBAR,LGSTYL,LGITMWID,
     +   LGCOLR,LGTEXT,LEGCLR,LEGFONT,LEGSIZE,LEGLOC,LEGASP,LGALIGN)
      ENDIF
      RETURN
  900 RTNCODE = '1'
      RETURN
      END
      SUBROUTINE WNDSQPIX(GANWLF,GANWRT,GANWBT,GANWTP)
C
C
C       ** OBJECTIVE:  DETERMINE THE NUMBER OF PIXELS IN THE Y DIRECTION
C                      OF THE PLOT AREA.  AFTER ADJUSTING THE NUMBER OF
C                      PIXELS FOR THE ASPECT RATIO, CORRECT THE LEFT AND 
C                      RIGHT LIMITS OF THE PLOT AREA SO THAT THE CORRECTED
C                      NUMBER OF X PIXELS EQUALS THE NUMBER OF Y PIXELS.
C                      THIS PREVENTS THE WINDROSE RINGS FROM EXTENDING
C                      OFF THE SCREEN.
C
C       ** INPUT:
C             GANWLF........X-COORDINATE OF LEFT EDGE OF PLOT AREA
C             GANWRT........X-COORDINATE OF RIGHT EDGE OF PLOT AREA
C             GANWBT........Y-COORDINATE OF BOTTOM EDGE OF PLOT AREA
C             GANWTP........Y-COORDINATE OF TOP EDGE OF PLOT AREA
C       ** OUTPUT: 
C             GANWLF........X-COORDINATE OF LEFT EDGE OF PLOT AREA ADJUSTED TO
C                           EQUAL THE Y PIXELS CORRECTED FOR ASPECT RATIO
C             GANWRT........X-COORDINATE OF RIGHT EDGE OF PLOT AREA ADJUSTED TO
C                           EQUAL THE Y PIXELS CORRECTED FOR ASPECT RATIO
C
      CALL INQASP(ASP)
      CALL INQDRA(IXMX,IYMX)
C
C       ** PLOT AREA IS SPECIFIED IN NORMALIZED WORLD COORDINATES -- GET VALUES
C          IN DEVICE COORDINATES
C
      CALL SETWOR(0.,0.,1.,1.)
      CALL MAPWTD(GANWLF,GANWTP,IXDVLF,IYDVTP)
      CALL MAPWTD(GANWRT,GANWBT,IXDVRT,IYDVBT)
C
C       ** DETERMINE THE NUMBER OF X,Y PIXELS -- CORRECT Y-PIXELS FOR 
C          ASPECT RATIO
C
      IXPIX = IXDVRT-IXDVLF
      IYPIX = IYDVBT-IYDVTP
      IXFYPIX = IYPIX/ASP
C
C       ** ADJUST PLOT AREA ONLY IF NUMBER OF X PIXELS EXCEEDS THE NUMBER OF
C          CORRECTED Y PIXELS      
C
      IF (IXPIX-IXFYPIX .GT. 2) THEN
C
C          ** CALCULATE THE NEW X LIMITS FOR THE PLOT AREA KEEPING THE SAME
C             CENTER LOCATION
C
         IHXPIX = .5*IXFYPIX
         IXDVCN = IXDVLF + .5*(IXDVRT-IXDVLF)
         IXDVLF = MAX0((IXDVCN-IHXPIX),0)
         IXDVRT = MIN0((IXDVCN+IHXPIX),IXMX)
         CALL MAPDTW(IXDVLF,IYDVTP,GANWLF,YDUM)
         CALL MAPDTW(IXDVRT,IYDVTP,GANWRT,YDUM)
      ENDIF   
C
      RETURN
      END      
      BLOCK DATA
C
C---  VARIABLES PUT IN COMMON BLOCK TO SAVE SPACE IN D-GROUP SEGMENT
C
$INCLUDE:  'GRFPARM.INC'
      PARAMETER    (MAXCAT = MXWRCAT)
      CHARACTER*20 TXTLB(MAXCAT)
      CHARACTER*28 OCLABL, TTLTXT
      CHARACTER*78 MESSAGE
      INTEGER*2    FREQTBL(MAXCAT,16), NUMCAT, INTRVL, NUMPTS, LOSP, 
     +             HISP 
      REAL         ADJRING, COMPTS(16), DGTORD, FVAL(16), SMVAL(16),
     +             SPKWID(6,3), XB(6), YB(6)
      COMMON /WINVAR/ FREQTBL, NUMCAT, INTRVL, NUMPTS, LOSP, HISP,
     +                ADJRING, COMPTS, DGTORD, FVAL, SMVAL, SPKWID,
     +                XB, YB, TXTLB, OCLABL, TTLTXT, MESSAGE
      DATA   COMPTS /90.0,67.5,45.0,22.5,0.0,337.5,315.0,292.5,270.0,
     +       247.5,225.0,202.5,180.0,157.5,135.0,112.5/, 
     +       DGTORD /0.0174533/
      END
