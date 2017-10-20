.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'



.param wp1_ = '1u*wn2*wp1'
*.param wp2_ = '1u*wn1*wp2'
*.param wn1_ = '1u*wn1'
.param wn2_ = '1u*wn2'
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


********************************************************************************

.ic v(net9) = 0 v(mtjr2) = 0 v(mtjl) = 0 v(mtjl2) = 0
.ic v(net8) = 0 v(mtjl2) = 0 v(mtjr) = 0 v(mtjr2) = 0


xm32 mtjl gnd! vdd vdd p105 w=wp1_ l=0.03u nf=1 m=1
xm30 mtjr gnd! vdd vdd p105 w=wp1_ l=0.03u nf=1 m=1


xm36 net8 vdd gnd! gnd! n105 w=wn2_ l=0.03u nf=1 m=1



*xm7 mtjl2 vdd gnd! gnd! n105 w=wn1_ l=0.03u nf=1 m=1
*xm5 mtjr2 vdd gnd! gnd! n105 w=wn1_ l=0.03u nf=1 m=1


*xm8 net9 gnd! vdd vdd p105 w=wp2_ l=0.03u nf=1 m=1

*xi9  net9 mtjl2 npll2 nthetal2 mtj
*xi8  mtjr2 net9 nplr2 ntheatar2 mtj

xi26  net8 mtjl npll nthetal mtj state = 0
xi1  mtjr net8 nplr ntheatar mtj state = 1

v60 vdd gnd! dc=1.05



.measure tran delay    TRIG V(mtjl)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(npll)  VAL='3'         RISE=1


.measure area param = 'wn2_+2*wp1_'

******Analysis************************************************
.include params.sp
.tran .1p 10n start=0 uic

*+sweep wp1 lin 20 0.1u 4u

+sweep DATA=sweeper_params
.option opfile=1 split_dp=1

.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end

