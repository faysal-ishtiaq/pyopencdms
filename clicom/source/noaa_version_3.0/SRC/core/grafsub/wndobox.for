$STORAGE:2
      SUBROUTINE WNDOBOX(ICNTRL,XMIN,YMIN,XMAX,YMAX)
C
C       ** OBJECTIVE:  OPEN OR CLOSE A WINDOW ON A HALO GRAPHICS SCREEN
C       ** INPUT
C            ICNTRL...... 1=OPEN WINDOW
C                         2=OPEN WINDOW VIEWPORT
C                        -1=CLOSE WINDOW VIEWPORT; DO NOT CLEAR SCREEN
C                        -2=CLOSE WINDOW VIEWPORT; CLEAR SCREEN 
C            XMIN,YMIN...UPPER LEFT WINDOW CORNER IN NORMALIZED DEVICE 
C                        COORDINATES (0.0 - 1.0) 
C            XMAX,YMAX...LOWER RIGHT WINDOW CORNER IN NORMALIZED DEVICE COORD
C
C       ** NOTE:  XMIN,YMIN,XMAX,YMAX CAN BE MODIFIED BY THIS ROUTINE
C                 AND THUS SHOULD BE VARIABLES IN THE CALLING ROUTINE.
C                 IF THEY ARE EXPRESSIONS YOU CAN GET UNPREDICTABLE 
C                 RESULTS.
C
      REAL X1,Y1,X2,Y2, XLOW,YLOW,XHIGH,YHIGH
C
C       ** OPEN A NEW WINDOW 
C
      IF (ICNTRL.GT.0) THEN
         IF (ICNTRL.EQ.1) THEN
C
C             ** SAVE THE CURRENT VIEWPORT, WORLD COORDINATES, AND BACKGROUND 
C                COLOR SO THEY CAN BE RESTORED LATER.
C          
            CALL INQVIE(X1,Y1,X2,Y2)
            CALL INQWOR(XLOW,YLOW,XHIGH,YHIGH)
            IF (YMAX.LT.YMIN) THEN
               YTEMP = YMIN
               YMIN = YMAX
               YMAX = YTEMP
            END IF
C
C             ** MAKE SURE THE WINDOW DOESN'T EXTEND OUTSIDE OF THE DEVICE.
C                ADJUST LOCATION IF IT DOES.
C
            XWIDTH = ABS(XMAX-XMIN)
            XHEIGHT = ABS(YMAX-YMIN)
            IF (XMIN.GT.XMAX) THEN
               TEMP = XMIN
               XMIN = XMAX
               XMAX = TEMP
            END IF
            IF (YMIN.GT.YMAX) THEN
               TEMP = YMIN
               YMIN = YMAX
               YMAX = TEMP
            END IF
            IF (XMIN.LT.0.01) THEN
               XMIN = 0.01
               XMAX = XMIN + XWIDTH
            ELSE IF (XMAX.GT.0.99) THEN
               XMAX = .99
               XMIN = XMAX - XWIDTH
            END IF
            IF (YMIN.LT.0.01) THEN
               YMIN = 0.01
               YMAX = YMIN + XHEIGHT
            ELSE IF (YMAX.GT.0.99) THEN
               YMAX = 0.99
               YMIN = YMAX - XHEIGHT
            END IF
C
C      SET THE VIEWPORT TO THE WHOLE SCREEN AND SET THE WORLD COORDS
C      TO 0,0 - 100,100.   DETERMINE THE WORLD COORDS FOR THE 
C      NORMALIZED DEVICE COORDINATE WINDOW BOUNDARIES THAT WERE PASSED.
C      REMEMBER TO SWAP UP AND DOWN DIRECTIONS.
C
C            CALL SETVIE(0.,0.,1.,1.,-1,-1)
C            CALL SETWOR(0.0,0.0,100.,100.)
C            XMINW = XMIN*100.
C            XMAXW = XMAX*100.
C            YMINW = (1.-YMAX) * 100.
C            YMAXW = (1.-YMIN) * 100.
C
C     OPEN THE NEW VIEWPORT. (MAKE IT SMALLER TO AVOID ROUND OFF ERRORS)
C
C            CALL SETHAT(1)
C            CALL SETCOL(0)
C            CALL BAR(XMINW,YMINW,XMINW+1.5,YMAXW-1.5)
C            CALL BAR(XMINW,YMINW,XMAXW-1.5,YMINW+1.5)
C            CALL SETVIE(XMIN+.012,YMIN+.005,XMAX-.005,YMAX-.015,2,3)
            XNDCNT = XMIN + .5*(XMAX-XMIN)
            YNDCNT = YMIN + .5*(YMAX-YMIN)
            CALL MAPNTD(XNDCNT,YNDCNT,IXDCNT,IYDCNT)
            CALL SETVIE(XMIN+.012,YMIN+.005,XMAX-.005,YMAX-.015,-1,-1)
            CALL INQCLR(IXDCNT,IYDCNT,IBGCOLOR)
            CALL SETVIE(XMIN+.012,YMIN+.005,XMAX-.005,YMAX-.015,2,3)
         ELSE   
            CALL SETVIE(XMIN+.012,YMIN+.005,XMAX-.005,YMAX-.015,-1,-1)
         ENDIF   
         CALL SETWOR(0.0,0.0,100.,100.)
C
C  SET THE BACKGROUND COLOR BACK TO WHAT IT WAS, CLOSE THE WINDOW AND
C  RESTORE THE SCREEN, VIEWPORT, AND COORDINATES ----
C
      ELSE
         IF (ICNTRL.EQ.-1) THEN
            CALL SETVIE(XMIN,YMIN,XMAX,YMAX,-1,-1)
         ELSE 
            CALL SETVIE(XMIN,YMIN,XMAX,YMAX,-1,IBGCOLOR)
         ENDIF
         IF (X2.NE.0) THEN
            CALL SETVIE(X1,Y1,X2,Y2,-1,-1)
         END IF
         CALL SETWOR(XLOW,YLOW,XHIGH,YHIGH)
      END IF      
      RETURN
      END
