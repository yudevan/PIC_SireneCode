; Discussion http://www.microchip.com/forums/m937760.aspx
;-----------------------------------------------------------------------------
;LABLE          OPCODE          OPERAND         COMMENTS
                list            R=DEC           ;Set radix to decimal
                list            P=16F84A         ;Set device to pic16F84
                list            F=INHX8m        ;Set format intel 8 bit merged 
;                list            F=picice        ;picice format
;------------------------------------------------------------------------------
;SETTING UP LABLES
;
port_a          equ             5h              ;equate port a
port_b          equ             6h              ;equate port b
same            equ             1               ;same register
_pc             equ             02h             ;program counter
_rtcc           equ             01h             ;rtcc
indirect        equ             00h             ;indirect address contents
_fsr            equ             04h             ;file select register
_status         equ             03h             ;status register
_carry          equ             0               ;carry flag
_zero           equ             2               ;zero flag
;               equ             10h             ;
;               equ             11h             ;
;               equ             12h             ;
_lenth          equ             13h             ;
;               equ             17h             ;
temp1           equ             14h             ;
temp2           equ             15h             ;
temp3           equ             16h             ;
temp4           equ             1Ah             ;
temp5           equ             1Bh             ;
dipval          equ             1Ch             ;
;               equ             1Dh             ;
;               equ             1Eh             ;
;               equ             1Fh             ;
;               equ             0Fh             ;
;               equ             0Dh             ;
;               equ             0Bh             ;
;               equ             09h             ;
;               equ             08h             ;
;               equ             0Ah             ;
;               equ             0Eh             ;
_flags          equ             0Ch             ;flag register
;               equ             18h             ;
;               equ             19h             ;
;-----------------------------------------------------------------------------
;port b pin definitions
;--------------------
;                equ             3               ;
;                equ             2               ;
;                equ             1               ;
sir              equ             0               ;siren drive out
;------------------------------------------------------------------------------
;flags
;               0                               0=siren sweep off
;                                               1=siren sweep on
;------------------------------------------------------------------------------
;               1                               0=
;                                               1=
;------------------------------------------------------------------------------
;               2                               0=
;                                               1=
;------------------------------------------------------------------------------
;               3                               0=
;                                               1=
;------------------------------------------------------------------------------
;               4                               0=
;                                               1=
;-----------------------------------------------------------------------------
;               5                               0=
;                                               1=
;------------------------------------------------------------------------------
;               6                               0=
;                                               1=
;------------------------------------------------------------------------------
;               7                               0=
;                                               1=
;------------------------------------------------------------------------------
;page 0
;------------------------------------------------------------------------------
                ORG             000h            ;originate code here
;------------------------------------------------------------------------------
;Codes start here       
init            movlw           B'01111111'     ;7 output
                tris            port_b          ;
                clrf            port_b          ;resetting port b
                movlw           B'11111111'     ;
                tris            port_a          ;
                clrf            port_a          ;resetting port a
                movlw           B'00001111'     ;setup  wdt 128:1
                option                          ;pul ups off int clock enabled
                clrf            _flags          ;clear all flags
;----------------------------------------------------------------------------
diptest         movf            port_b,w        ;get dip value
                movwf           dipval          ;
                comf            dipval,same     ;
                bcf             dipval,7        ;mask
                bcf             dipval,6        ;
                bcf             dipval,5        ;
                bcf             dipval,4        ;
                movlw           15              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op              ;
                movlw           14              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op14            ;
                movlw           13              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op13            ;
                movlw           12              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op12            ;
                movlw           11              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op11            ;
                movlw           10              ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op10            ;
                movlw           9               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op9             ;
                movlw           8               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op8             ;
                movlw           7               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op7             ;
                movlw           6               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op6             ;
                movlw           5               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op5             ;
                movlw           4               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op4             ;
                movlw           3               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op3             ;
                movlw           2               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op2             ;
                movlw           1               ;
                subwf           dipval,w        ;
                btfsc           _status,_carry  ;set is pos
                goto            op1             ;
                goto            op              ;
;---------------------------------------------------------------------------
op              bsf             _flags,0        ;fast sweep
                movlw           250             ;
                movwf           temp2           ;sweep = 255
                movlw           5               ;255 /10 th = variable rate 5
                movwf           _lenth          ;
                movlw           3               ;
                movwf           temp3           ;pitch preset to 25
siren           bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp2,same      ;sweep timer
                goto            var             ;
                movlw           250             ;reset sweep timer
                movwf           temp2           ;
                goto            tog             ;toggle if sweep over
;--------------------------------------------------------------------------
tog             btfsc           _flags,0        ;test if sweep off
                goto            down            ;pitch down
                goto            up              ;pitch up
down            bcf             _flags,0        ;
                goto            siren           ;
up              bsf             _flags,0        ;
                goto            siren           ;
;---------------------------------------------------------------------------
var             decfsz          _lenth,same     ;
                goto            siren           ;
                btfsc           _flags,0        ;test if sweep up or down
                goto            re              ;
                decfsz          temp3,same      ;
                goto            qw1             ;
                bsf             _flags,0        ;
qw1             movlw           5               ;reset /10      5
                movwf           _lenth          ;
                goto            siren           ;
re              incf            temp3,same      ;
                movlw           5               ;
                movwf           _lenth          ;reset /10      5
                goto            siren           ;
;---------------------------------------------------------------------------
pit             movf            temp3,w         ;
                movwf           temp4           ;
g               clrwdt                          ;kick dog
                decfsz          temp4,same      ;
                goto            g               ;
                retlw           0               ;
;--------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op1             bsf             _flags,0        ;very slow sweep
                movlw           230             ;
                movwf           temp2           ;sweep = 255
                movlw           3               ;255 /10 th = variable rate
                movwf           _lenth          ;
                movlw           85              ;
                movwf           temp3           ;pitch preset to 25
siren1          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp2,same      ;sweep timer
                goto            var1            ;
                movlw           230             ;reset sweep timer
                movwf           temp2           ;
                goto            tog1            ;toggle if sweep over
;--------------------------------------------------------------------------
tog1            btfsc           _flags,0        ;test if sweep off
                goto            down1           ;pitch down
                goto            up1             ;pitch up
down1           bcf             _flags,0        ;
                goto            siren1          ;
up1             bsf             _flags,0        ;
                goto            siren1          ;
;---------------------------------------------------------------------------
var1            decfsz          _lenth,same     ;
                goto            siren1          ;
                btfsc           _flags,0        ;test if sweep up or down
                goto            re1             ;
                decf            temp3,same      ;
                movlw           3               ;reset /10
                movwf           _lenth          ;
                goto            siren1          ;
re1             incf            temp3,same      ;
                movlw           3               ;
                movwf           _lenth          ;reset /10
                goto            siren1          ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op2             bsf             _flags,0        ;medium sweep
                movlw           10              ;
                movwf           temp3           ;pitch preset to 25
siren2          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                goto            var2            ;
;---------------------------------------------------------------------------
var2            btfsc           _flags,0        ;test if sweep up or down
                goto            re2             ;
                decfsz          temp3,same      ;
                goto            siren2          ;
                bsf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren2          ;
re2             incf            temp3,same      ;
                movlw           150             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set if pos
                bcf             _flags,0        ;
                goto            siren2          ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op3             bsf             _flags,0        ;police siren
                movlw           5               ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren3          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren3          ;
                movlw           5               ;reset delayed sweep
                movwf           temp1           ;
                btfsc           _flags,0        ;test if up or down sweep
                goto            m1              ;
                goto            m2              ;
m1              decfsz          temp2,same      ;sweep timer
                goto            var3            ;
                goto            tog3            ;toggle if sweep over
m2              movlw           5               ;
                subwf           temp2,same      ;
                movf            temp2,w         ;
                btfsc           _status,_zero   ;
                goto            var3            ;
                goto            tog3            ;toggle if sweep over
;--------------------------------------------------------------------------
tog3            btfsc           _flags,0        ;test if sweep off
                goto            down3           ;pitch down
                goto            up3             ;pitch up
down3           bcf             _flags,0        ;
                goto            siren3          ;
up3             bsf             _flags,0        ;
                goto            siren3          ;
;---------------------------------------------------------------------------
var3            btfsc           _flags,0        ;test if sweep up or down
                goto            re3             ;
                decf            temp3,same      ;
                goto            siren3          ;
re3             movlw           255             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set is positive
                bcf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren5          ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op4             bsf             _flags,0        ;slow rise
                movlw           6               ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren4          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren4          ;
                movlw           6               ;reset delayed sweep
                movwf           temp1           ;
                btfss           _flags,0        ;test if up or down sweep
                goto            m3              ;
                goto            m4              ;
m3              decfsz          temp2,same      ;sweep timer
                goto            var4            ;
                goto            tog4            ;toggle if sweep over
m4              movlw           5               ;
                subwf           temp2,same      ;
                movf            temp2,w         ;
                btfsc           _status,_zero   ;
                goto            var4            ;
                goto            tog4            ;toggle if sweep over
;--------------------------------------------------------------------------
tog4            btfsc           _flags,0        ;test if sweep off
                goto            down4           ;pitch down
                goto            up4             ;pitch up
down4           bcf             _flags,0        ;
                goto            siren4          ;
up4             bsf             _flags,0        ;
                goto            siren4          ;
;---------------------------------------------------------------------------
var4            btfsc           _flags,0        ;test if sweep up or down
                goto            re4             ;
                decf            temp3,same      ;
                goto            siren4          ;
re4             movlw           255             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set is positive
                bcf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren5          ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op5             bsf             _flags,0        ;ultra low sweep (air raid)
                movlw           20              ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren5          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren5          ;
                movlw           20              ;reset delayed sweep
                movwf           temp1           ;
                decfsz          temp2,same      ;sweep timer
                goto            var5            ;
                goto            tog5            ;toggle if sweep over
;--------------------------------------------------------------------------
tog5            btfsc           _flags,0        ;test if sweep off
                goto            down5           ;pitch down
                goto            up5             ;pitch up
down5           bcf             _flags,0        ;
                goto            siren5          ;
up5             bsf             _flags,0        ;
                goto            siren5          ;
;---------------------------------------------------------------------------
var5            btfsc           _flags,0        ;test if sweep up or down
                goto            re5             ;
                decf            temp3,same      ;
                goto            siren5          ;
re5             movlw           255             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set is positive
                bcf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren5          ;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;---------------------------------------------------------------------------
op6             bsf             _flags,0        ;two tone high pitch
                movlw           2               ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           50              ;
                movwf           temp3           ;pitch preset to 25
siren6          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren6          ;
                movlw           2               ;reset delayed sweep
                movwf           temp1           ;
                decfsz          temp2,same      ;sweep timer
                goto            siren6          ;
                btfsc           _flags,0        ;test if high or low
                goto            m5              ;
                goto            m6              ;
m5              movlw           20              ;
                movwf           temp3           ;
                bcf             _flags,0        ;
                goto            siren6          ;
m6              movlw           50              ;
                movwf           temp3           ;
                bsf             _flags,0        ;
                goto            siren6          ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;----------------------------------------------------------------------------
op7             bsf             _flags,0        ;continues
                movlw           40              ;
                movwf           temp3           ;pitch preset to 25
siren7          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                goto            siren7          ;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
op8             movlw           40              ;telephone
                movwf           temp3           ;pitch preset to 25
                movlw           100              ;
                movwf           _lenth          ;lenth timer
siren8          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          _lenth,same     ;
                goto            siren8          ;
                movlw           100             ;reset lenth timer
                movwf           _lenth          ;
                movlw           50              ;
                movwf           temp3           ;pitch preset to 25
siren9          bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          _lenth,same     ;
                goto            siren9          ;
                movlw           100             ;reset lenth timer
                movwf           _lenth          ;
                goto            op8             ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op9             movlw           40              ;buzzer
                movwf           temp3           ;pitch preset to 25
                movlw           2               ;
                movwf           _lenth          ;lenth timer
siren10          bsf             port_b,7       ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          _lenth,same     ;
                goto            siren10         ;
                movlw           2               ;reset lenth timer
                movwf           _lenth          ;
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren11         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          _lenth,same     ;
                goto            siren11         ;
                movlw           2               ;reset lenth timer
                movwf           _lenth          ;
                goto            op9             ;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;---------------------------------------------------------------------------
op10            bsf             _flags,0        ;laser shoot fast
                movlw           1               ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren12         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren12         ;
                movlw           1               ;reset delayed sweep
                movwf           temp1           ;
                btfsc           _flags,0        ;test if up or down sweep
                goto            m11             ;
                goto            m12             ;
m11             decfsz          temp2,same      ;sweep timer
                goto            var11           ;
                goto            tog13           ;toggle if sweep over
m12             movlw           5               ;
                subwf           temp2,same      ;
                movf            temp2,w         ;
                btfsc           _status,_zero   ;
                goto            var11            ;
                goto            tog13            ;toggle if sweep over
;--------------------------------------------------------------------------
tog13           btfsc           _flags,0        ;test if sweep off
                goto            down13          ;pitch down
                goto            up13            ;pitch up
down13          bcf             _flags,0        ;
                goto            siren12         ;
up13            bsf             _flags,0        ;
                goto            siren12         ;
;---------------------------------------------------------------------------
var11           btfsc           _flags,0        ;test if sweep up or down
                goto            re13            ;
                decf            temp3,same      ;
                goto            siren12         ;
re13            movlw           255             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set is positive
                bcf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren12         ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op11            bsf             _flags,0        ;laser shoot slow
                movlw           2               ;sweep delay timer
                movwf           temp1           ;
                movlw           255             ;
                movwf           temp2           ;sweep = 255
                movlw           255             ;
                movwf           temp3           ;pitch preset to 25
siren13         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp1,same      ;delay sweep
                goto            siren13         ;
                movlw           2               ;reset delayed sweep
                movwf           temp1           ;
                btfsc           _flags,0        ;test if up or down sweep
                goto            m13             ;
                goto            m14             ;
m13             decfsz          temp2,same      ;sweep timer
                goto            var13           ;
                goto            tog14           ;toggle if sweep over
m14             movlw           5               ;
                subwf           temp2,same      ;
                movf            temp2,w         ;
                btfsc           _status,_zero   ;
                goto            var13            ;
                goto            tog14            ;toggle if sweep over
;--------------------------------------------------------------------------
tog14           btfsc           _flags,0        ;test if sweep off
                goto            down14          ;pitch down
                goto            up14            ;pitch up
down14          bcf             _flags,0        ;
                goto            siren13         ;
up14            bsf             _flags,0        ;
                goto            siren13         ;
;---------------------------------------------------------------------------
var13           btfsc           _flags,0        ;test if sweep up or down
                goto            re14            ;
                decf            temp3,same      ;
                goto            siren13         ;
re14            movlw           255             ;
                subwf           temp3,w         ;
                btfsc           _status,_carry  ;set is positive
                bcf             _flags,0        ;
                incf            temp3,same      ;
                goto            siren13         ;
;--------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
op12            bsf             _flags,0        ;continues pulsed
                movlw           40              ;
                movwf           temp3           ;pitch preset to 25
                movlw           255             ;pulse timer
                movwf           temp5           ;
siren14         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp5,same      ;
                goto            siren14         ;
qw3             clrwdt                          ;kick dog
                call            pit             ;
                decfsz          temp5,same      ;
                goto            qw3             ;
                decfsz          temp3           ;
                goto            qw3             ;
                goto            op12            ;
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
op13            bsf             _flags,0        ;double sweep fast
                movlw           200             ;
                movwf           temp3           ;pitch preset to 25
siren15         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                decfsz          temp3,same      ;
                goto            siren15         ;
                movlw           200             ;
                movwf           temp3           ;
                goto            siren15         ;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
op14            bsf             _flags,0        ;
                movlw           10              ;
                movwf           temp3           ;pitch preset to 25
siren16         bsf             port_b,7        ;beeper on
                call            pit             ;variable pitch
                bcf             port_b,7        ;beeper off
                call            pit             ;variable pitch
                movlw           1               ;
                addwf           temp3,same      ;
                goto            siren16         ;
;----------------------------------------------------------------------------
                org             3ffh            ;
                goto            init            ;
                END                             ;
