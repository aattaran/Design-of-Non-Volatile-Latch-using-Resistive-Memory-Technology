*Custom Designer (TM) Version I-2013.12-SP1
*Mon Jun 26 10:53:53 2017

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'

.param vdd = 1.05

********************************************************************************

.subckt ani m n K=1.13e5 a=0.02 r=22n H0=1.5e5 Ms0=4.81e5 mu0=1.26e-6 gamma=1.76e11
.ends ani

********************************************************************************
.subckt mtj nfl npl ntheta nr state = 0 r = 22n tox = 1n tmr = 2

xM1 net1 npl ntheta 0 hys r=r
xM2 ntheta 0 ani r=r
xC1 ntheta 0 caps1 r=r
xRout ntheta nr 0 nfl net1 vcr0 r=r tox=tox TMR0=tmr
xRwrite ntheta nfl net1 vcr r=r tox=tox TMR0=tmr

.ic V(ntheta) = '3.14*state'
.nodeset V(ntheta) = '3.14*state'

.ends mtj


************************** Transistor width and MTJ states ****************************

*up to down!(10)
xm32 net5 gnd! vdd vdd p105 w=wp l=0.03u nf=1 m=1
xm30 net3 gnd! vdd vdd p105 w=wp l=0.03u nf=1 m=1
xm36 net4 vdd gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1

*.param wp = 0.1u

*down to up!(01)
xm35 net4 vdd vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm33 net5 gnd! gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm29 net3 gnd! gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
v1 vdd gnd! dc=1.05

xi26 net4 net5 npll nthetal mtj state = 0
xi1 net3 net4 nplr ntheatar mtj state = 1

*.ic v(shared) = 0  v(nflr) = 0 v(npll) = 0
************************** MEASUREMENTS ***********************************
.measure tran delay    TRIG V(ntheatar)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(npll)      VAL='3.1'           rise=1


*.measure area param = 'wn1_*2+wp1_+0.3u'

************************** ANALYSIS ***********************************

*.include params.sp
.tran .1p 30n start=0 uic

+sweep wp lin 100 0.1u 5u

*+sweep DATA=sweeper_params


.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end