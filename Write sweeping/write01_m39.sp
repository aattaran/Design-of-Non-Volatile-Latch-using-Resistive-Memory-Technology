.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'






.param vdd = 1.05
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

*.ic v(mtjl) = 0  v(mtjr) = 0 v(mtjg) = 0

********************************************************************************

xm39 mtjg gnd! vdd vdd p105 w=wp l=0.03u nf=1 m=1


*xm32 mtjl vdd vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
*xm30 mtjr vdd vdd vdd p105 w=0.1u l=0.03u nf=1 m=1


xi26  mtjg mtjl npll nthetal mtj state = 1
xi1  mtjr mtjg nplr ntheatar mtj state = 0


xm33 mtjr vdd gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm35 mtjl vdd gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1


*xm36 mtjg gnd! gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1


v60 vdd gnd! dc=1.05





.measure tran delay    TRIG V(mtjg)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(npll)  VAL='0.1'         fall=1


*.measure area param = 'wn1_*2+wp1_+0.3u'

******Analysis************************************************
*.include params.sp
.tran .1p 10n start=0 uic

+sweep wp lin 100 0.1u 20u

*+sweep DATA=sweeper_params


.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end