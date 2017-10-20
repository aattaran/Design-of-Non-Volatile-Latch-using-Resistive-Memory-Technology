*Custom Designer (TM) Version I-2013.12-SP1
*Mon Jul 17 14:48:32 2017

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'

.param vdd = 1.05




.param
******************added
+          delta = 0.002

+          WN1r  = optw(1.3, 0.1, 2, delta)
+          WN2r  = optw(0.7, 0.1, 2, delta)
+          Wp1r  = optw(1.55, 0.1, 2, delta)
+          WP2r  = optw(0.1, 0.1, 2, delta)

+       sinkN = 0.74u
+       topN = .353u
+       topP = .458u
+       sinkP  = 1.054u

*+      sinkN = 2.961u
*+      topN = 1.41u
*+      topP = 1.833u
*+      sinkP  = 4.216u

+      WN1_ = 'WN1r*1u'
+      WN2_ = 'WN2r*1u'
+      Wp1_ = 'Wp1r*1u'
+      WP2_ = 'Wp2r*1u'



.option tnom = 110

** Transistor vto variation .08V at 1 sigma **********************

.param dvtn_intra=AGAUSS(0,0.08,1)
.param dvtp_intra=AGAUSS(0,0.08,1)

** 10% variation in MTJ parameters at 1 sigma ********************

.param dr_intra= AGAUSS(22n,2.2n,1)
.param dt_intra= AGAUSS(1n,.1n,1)


***********Transistor model with Vt variation applied *************

**NMOS model card with Vt variation *******************************

.subckt nch D G S B w=100n l=30n 

xMN D Gn S B n105 w=w l=l
Vdvtn G Gn DC='(dvtn_intra/sqrt((w*l)/(3e-15)))'

.ends

**PMOS model card with Vt variation ***************************************

.subckt pch D G S B w=100n l=30n 

xMP D Gp S B p105 w=w l=l
Vdvtp Gp G DC='(dvtp_intra/sqrt((w*l)/(3e-15)))'
        
.ends

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


*** Write drivers ***

xm33 mtjl gnd! gnd! gnd! n105 w='TopN' l=0.03u nf=4 m=1
xm29 mtjr gnd! gnd! gnd! n105 w='TopN' l=0.03u nf=4 m=1
xm32 mtjl vdd vdd vdd p105 w='TopP' l=0.03u nf=4 m=1
xm30 mtjr vdd vdd vdd p105 w='TopP' l=0.03u nf=4 m=1
xm35 mtj vdd vdd vdd p105 w='SinkP' l=0.03u nf=4 m=1
xm36 mtj gnd! gnd! gnd! n105 w='SinkN' l=0.03u nf=4 m=1

*v1 nthetal gnd! dc=3.14
*v2 ntheatar gnd! dc=0

*** read  ***

xm15 mtj sen gnd! gnd! nch w='WN2_' l=0.03u nf=1 m=1
xm9 q net1 gnd! gnd! nch w=0.1u l=0.03u nf=1.0 m=1
xm5 net1 net2 mtjr gnd! nch w='WN1_' l=0.03u nf=1 m=1
xm3 qb net2 gnd! gnd! nch w=0.1u l=0.03u nf=1 m=1
xm0 net2 net1 mtjl gnd! nch w='WN1_' l=0.03u nf=1 m=1
xm10 net8 wen vdd vdd pch w=0.1u l=0.03u nf=1 m=1
xm8 net1 sen net8 vdd pch w=0.1u l=0.03u nf=1 m=1
xm7 q net1 vdd vdd pch w='WP2_' l=0.03u nf=1 m=1
xm6 net1 net2 vdd vdd pch w='WP1_' l=0.03u nf=1 m=1
xm2 net2 sen net8 vdd pch w=0.1u l=0.03u nf=1 m=1
xm4 qb net2 vdd vdd pch w='WP2_' l=0.03u nf=1 m=1
xm1 net2 net1 vdd vdd pch w='WP1_' l=0.03u nf=1 m=1


xi26  mtj mtjl nthetal npll  mtj state = 1  r1 = dr_intra tox1 = dt_intra           ** q
xi1  mtjr mtj ntheatar nplr  mtj state = 0  r2 = dr_intra tox2 = dt_intra           ** qbar
v60 vdd gnd! dc=1.05
v16 sen gnd! dc=0 pulse ( 1.05 0 0 10p 10p 30n 60n )
v15 wen gnd! dc=0 pulse ( 0 1.05  0 10p 10p 30n 60n )

.nodeset v(q) = 0 v(qb) = 0

***************************MEASUREMENTS*****************************

.measure tran delay    TRIG V(sen)  VAL='0.5*vdd' TD=30n RISE=1
+                      TARG V(q)      VAL='0.5*vdd'    RISE=1  goal < 100p  weight=1

.MEASURE tran area PARAM = '0.5u + 2*wp2 + 2*wp1 + wn1*2 + wn2*1 ' goal < 10u weight=10

.MEASURE tran vq FIND = V(q) AT = 35n
.MEASURE tran vqb FIND = V(qb) AT = 35n

.MEASURE tran WN1 PARAM = 'WN1_'
.MEASURE tran WN2 PARAM = 'WN2_'
.MEASURE tran WP1 PARAM = 'WP1_'
.MEASURE tran WP2 PARAM = 'WP2_'

*********optimization**********
*.model optw opt
*+relin=1e-5 relout=1e-5 itropt=40 grad=1e-9 close=.1 cut=2 
*+difsiz=1e-3 cendif=1e-6  max=1e3 relv = 1e-4 relvar = 1e-2 
*+ LEVEL=1 PARMIN = 1

.model optw opt
+relin=1e-5 relout=1e-5 itropt=40 grad=1e-9 close=1 cut=1.5
+difsiz=1e-3 cendif=1e-6  max=1e3 relv = 1e-4 relvar = 1e-2
+ LEVEL=1 PARMIN = 1
***************************ANALYSIS*********************************

.include read.sp
.tran .1p 60n start=0 uic
*+sweep wp lin 100 0.1u 5u

+SWEEP optimize = optw results = area,delay model=optw

*+sweep DATA=sweeper_params

*+SWEEP monte=1000

*.option MEASFORM=1

*.option opfile=1 split_dp=1

.options post node list MEASFORM=1




 
 
 
.end

