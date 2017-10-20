*Custom Designer (TM) Version I-2013.12-SP1
*Mon Jul 17 14:48:32 2017

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'
.include params.sp
.param vdd = 1.05

*****************************MTJ Subcircuit*********************************
.subckt mtj nfl npl ntheta nr state = 0 r = 22n tox = 1n tmr = 2

xM1 net1 npl ntheta 0 hys r=r
xM2 ntheta 0 ani r=r
xC1 ntheta 0 caps1 r=r
xRout ntheta nr 0 nfl net1 vcr0 r=r tox=tox TMR0=tmr
xRwrite ntheta nfl net1 vcr r=r tox=tox TMR0=tmr

.ic V(ntheta) = '3.14*state'
.nodeset V(ntheta) = '3.14*state'

.ends

********************Latch Transistors and MTJ States***************

xm36 mtj gnd! gnd! gnd! n105 w='SinkN' l=0.03u nf=1 m=1
xm33 mtjl gnd! gnd! gnd! n105 w='TopN' l=0.03u nf=1 m=1
xm15 mtj sen gnd! gnd! n105 w='WN2' l=0.03u nf=1 m=1
xm29 mtjr gnd! gnd! gnd! n105 w='TopN' l=0.03u nf=1 m=1
xm9 q net1 gnd! gnd! n105 w=0.1u l=0.03u nf=1.0 m=1
xm5 net1 net2 mtjr gnd! n105 w='WN1' l=0.03u nf=1 m=1
xm3 qb net2 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm0 net2 net1 mtjl gnd! n105 w='WN1' l=0.03u nf=1 m=1
xm10 net8 wen vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm35 mtj vdd vdd vdd p105 w='SinkP' l=0.03u nf=1 m=1
xm32 mtjl vdd vdd vdd p105 w='TopP' l=0.03u nf=1 m=1
xm30 mtjr vdd vdd vdd p105 w='TopP' l=0.03u nf=1 m=1
xm8 net1 sen net8 vdd p105 w=0.1u l=0.03u nf=1 m=1
xm7 q net1 vdd vdd p105 w='WP2' l=0.03u nf=1 m=1
xm6 net1 net2 vdd vdd p105 w='WP1' l=0.03u nf=1 m=1
xm2 net2 sen net8 vdd p105 w=0.1u l=0.03u nf=1 m=1
xm4 qb net2 vdd vdd p105 w='WP2' l=0.03u nf=1 m=1
xm1 net2 net1 vdd vdd p105 w='WP1' l=0.03u nf=1 m=1
xi26 gnd! mtj mtjl npll nthetal mtj
xi1 gnd! mtjr mtj nplr ntheatar mtj
v60 vdd gnd! dc=1.05
v16 sen gnd! dc=0 pulse ( 1.05 0 0 0 0 0 0 )
v15 wen gnd! dc=0 pulse ( 0 1.05 0 0 0 0 0 )


***************************MEASUREMENTS*****************************

.measure tran delay1    TRIG V(wen4)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(ntr)      VAL='3.1'           rise=1

.measure tran delay2    TRIG V(wen1)  VAL='0.1*vdd' TD=10n rise=1
+                      TARG V(ntd)      VAL='3.1'           rise=1

.measure tran delay param = 'max(delay1,delay2)'


************************** OPTIMIZATION ****************************

.model optw opt
+relin=1e-5 relout=1e-5 itropt=30 grad=1e-9 close=1 cut=4 
+difsiz=1e-9 cendif=1e-9  max=1e10 relv = 1e-4 relvar = 1e-2


***************************ANALYSIS*********************************

*.include params.sp
.tran .1p 30n start=0 uic
*+sweep wp lin 100 0.1u 5u

*+SWEEP optimize = optw results = delay,area model=optw

*+sweep DATA=sweeper_params


.options post node list MEASFORM=1

.end




