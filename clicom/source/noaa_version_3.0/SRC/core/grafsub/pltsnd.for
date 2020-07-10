$STORAGE:2
      SUBROUTINE PLTSND(PRES,TEMP,TDPR,HGT,NLVLS,
     +                  QCTFLG,QCPLT,CTYP,CTHK,COLR,RTNCODE)
C------------------------------------------------------------------------------
C     PLOT THE TEMPERATURE AND DEW POINT CURVES OF A SOUNDING ON A PREDRAWN 
C     SKEW-T, LOG P DIAGRAM. ALSO PLOT THE HEIGHT LABELS IN KILOMETERS
C     ON THE RIGHT SIDE OF DIAGRAM. ROUTINE SKEWT DRAWS THE BACKGROUND DIAGRAM 
C     PLOT LINE WILL BE IN RED FOR POINTS WITH AN ERROR FLAG WHEN ROUTINE 
C     USED BY AREA QC PROGRAM.
C
C     INPUT ARGUMENTS:
C
C     PRES      REAL ARRAY   SOUNDING PRESSURES (MB)
C     TEMP      REAL ARRAY   SOUNDING TEMPERATURES (C)
C     TDPR      REAL ARRAY   SOUNDING DEW POINT DEPRESSIONS (C)
C     HGT       REAL ARRAY   SOUNDING HEIGHTS (M ASL)
C     QCTFLG    CHAR ARRAY   FLAG THAT CHANGES COLOR OF THE PLOT LINE IF ERROR
C                            FLAG IS SET (BY AREA QC PGM) AND QCPLT IS TRUE
C     QCPLT     LOGICAL      SWITCH SET BY CALLING ROUTINE.  TRUE FOR AREA QC
C     NLVLS     INT2         NUMBER OF SOUNDING LEVELS 
C     CTYP      INT2 ARRAY   LINE TYPE FOR PLOTS
C     CTHK      INT2 ARRAY   LINE THICKNESS FOR PLOTS
C     COLR      INT2 ARRAY   COLOR CODE FOR PLOTS
C
C     OUTPUT ARGUMENTS: 
C     RTNCODE   CHAR         ERROR FLAG   '0'=NO ERRORS
C                                         '7'=PRESSURE/TEMPERATURE OUT OF SORT
C                                         '8'=NOT ENOUGHT DATA TO DRAW A LINE 
C------------------------------------------------------------------------------
C
C     INPUT/OUTPUT ARGUMENTS
C
      REAL         PRES(1), TEMP(1), TDPR(1), HGT(1)
      INTEGER*2    NLVLS, CTYP(1), CTHK(1), COLR(1)
      CHARACTER*1  QCTFLG(*),RTNCODE
      LOGICAL      QCPLT
      PARAMETER    (NM=9)
C
C  ARRAY DECLARATIONS - INTERNAL VARIABLES
C
      REAL         HTM(NM),INTERP,PLAB,TDEW,YM
      REAL         X,Y,X1,Y1,X2,X3,Y3
      INTEGER*2    I,IDXM,K,KMLAB(NM)
      CHARACTER*2  PLOT
      LOGICAL      NOGAP,NODAT
C
C  DEFINE HEIGHT LABELS AND ACTUAL HEIGHT CORRESPONDING TO THOSE LABELS
C
      DATA KMLAB/2,4,6,8,10,12,14,16,18/
      DATA HTM/2000.,4000.,6000.,8000.,10000.,12000.,14000.,
     +        16000.,18000./
C     
      RTNCODE='0'
C
C     PLOT THE SOUNDING TEMPERATURE CURVE
C
      CALL SETCOL(COLR(1))
      CALL SETLNS(CTYP(1))
      CALL SETLNW(CTHK(1))
      NOGAP=.FALSE.
      NODAT=.TRUE.
      DO 100 I=1,NLVLS
         IF (TEMP(I) .NE. -99999. .AND. PRES(I) .NE. -99999.) THEN
            IF (PRES(I) .LT. 100. )    GO TO 200
            Y=SKEWTY(PRES(I))
            X=SKEWTX(TEMP(I),Y)
            IF (NOGAP) THEN
               IF (QCPLT) THEN
C                   .. FOR AREAQC, PLOT ERROR TEMPERATURES IN A
C                      DIFFERENT COLOR                
                  IF (QCTFLG(I).EQ.'C'.OR.QCTFLG(I).EQ.'c') THEN
                     CALL SETCOL(13)
                  ELSE
                     CALL SETCOL(COLR(1))
                  END IF
               ENDIF   
               NODAT=.FALSE.
               CALL LNABS(X,Y)
            ELSE
               CALL MOVABS(X,Y)
               NOGAP=.TRUE.
            END IF      
         ELSE
            NOGAP=.FALSE.
         END IF
  100 CONTINUE
C
C     CALCULATE DEW POINT SINCE ONLY THE DEW POINT DEPRESSION IS
C     PASSED TO THE SUBROUTINE. DEW PT = SOUNDING TEMP - DEPRESSION
C     IF SOUNDING TEMP IS MISSING (-99999), DEW PT IS SET TO MISSING
C
C     PLOT THE SOUNDING DEW POINT TEMPERATURE CURVE.
C     THE CUTOFF FOR THIS CURVE IS A PRESSURE LEVEL OF 300, NOT 100 AS
C     IN OTHER TESTS USING PRESSURE.  THAT IS THE TEST USED IN THE 
C     ORIGINAL PROGRAM THAT WAS THE BASIS FOR THIS PROGRAM.  19-NOV-91
C
  200 CALL SETCOL(COLR(2))
      CALL SETLNS(CTYP(2))
      CALL SETLNW(CTHK(2))
      NOGAP=.FALSE.
      DO 300 I=1,NLVLS
         IF (TEMP(I) .NE. -99999. .AND. TDPR(I) .NE. -99999.) THEN
            IF (PRES(I).LE.300.) THEN
               IF (PRES(I) .EQ. -99999.) THEN 
                  NOGAP=.FALSE.
                  GO TO 300
               ELSE 
                  GO TO 301
               END IF
            ELSE   
               TDEW=TEMP(I)-TDPR(I)
               Y   =SKEWTY(PRES(I))
               X   =SKEWTX(TDEW,Y)
               IF (NOGAP) THEN
                  CALL LNABS(X,Y)
               ELSE
                  CALL MOVABS(X,Y)
                  NOGAP=.TRUE.
               END IF      
            END IF
         ELSE
            NOGAP=.FALSE.
         END IF
  300 CONTINUE
  301 CONTINUE
      CALL SETLNW(1)
      CALL SETLNS(1)
C
C  PLOT THE HEIGHT LABELS IN KM ALONG PREDRAWN SCALE. IDXM POINTS 
C  TO LOCATIONS IN KILOMETER SEARCH ARRAYS. IF A LOCATION'S ELEVATION
C  IS ABOVE 2000 METERS, THEN 4000 METERS WILL BE THE FIRST LABEL,
C  AND THE INITIAL INDEX (IDXM) IS SET TO 2, AND SO ON.
C
      CALL DEFHST(3,6,0.0,0.9,0.035,STLHG)
      CALL SETCOL(6)
      IDXM=1
      IF (HGT(1).GT.HTM(1))  IDXM=2
      IF (HGT(1).GT.HTM(2))  IDXM=3
C
C  PLOT HEIGHT SCALE ON SKEW-T, LOG P DIAGRAM; QUIT HEIGHT SCALE IF
C  PRESSURE OR TEMPERATURE ARE OUT OF SORT
C
C      PRVHGT  =  HGT(1)
C      PRVPRES = PRES(1)
      PRVHGT  =  -99999.
      PRVPRES = 99999.
      DO 400 I=1,NLVLS
C
C  CHECK FOR MISSING AND OUT OF SORT HEIGHTS         
         IF (HGT(I)  .EQ. -99999.) GO TO 400
         IF (HGT(I).LT.PRVHGT) THEN
            RTNCODE = '7'
            GO TO 500
         ENDIF
         PRVHGT = HGT(I)   
C         
C  CHECK FOR MISSING AND OUT OF SORT PRESSURES         
         IF (PRES(I)  .EQ. -99999.) GO TO 400
         IF (PRES(I).GT.PRVPRES) THEN
            RTNCODE = '7'
            GO TO 500
         ENDIF
         PRVPRES = PRES(I)   
         IF (PRES(I) .LT. 100. )    GO TO 500
         IF (HGT(I).GE.HTM(IDXM)) THEN
C---     GET PRIOR HGT/PRES VALUES FOR CALCULATIONS THAT ARE NOT MISSING
            K = I            
  350       K = K - 1
            IF (K .LT. 1) GO TO 400
            IF (HGT(K).EQ. -99999. .OR. PRES(K).EQ. -99999.) GO TO 350
            Y1=ALOG(PRES(K))
            Y3=ALOG(PRES(I))
            X1=HGT(K)
            X2=HTM(IDXM)
            X3=HGT(I)
            PLAB=EXP(INTERP(Y1,Y3,X1,X2,X3))
            YM=SKEWTY(PLAB) 
            CALL MOVABS(29.7,YM)
            CALL LNABS (30.3,YM)
            WRITE(UNIT=PLOT,FMT=800) KMLAB(IDXM)
            CALL DRWTXT(PLOT,30.5,YM-0.5,0,0.0)
            IDXM=IDXM+1
         ENDIF
  400 CONTINUE
  500 CALL SETCOL(1)
      IF (RTNCODE.EQ.'0' .AND. NODAT) RTNCODE='8'
      RETURN
C      
  800 FORMAT(I2)
      END
