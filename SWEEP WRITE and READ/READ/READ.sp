*Custom Designer (TM) Version I-2013.12-SP1
*Mon Jun 26 10:27:27 2017

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'
.include params.sp

*****************************MTJ Subcircuit************************************
.subckt mtj nfl npl ntheta nr state = 0 r = 22n tox = 1n tmr = 2

xM1 net1 npl ntheta 0 hys r=r
xM2 ntheta 0 ani r=r
xC1 ntheta 0 caps1 r=r
xRout ntheta nr 0 nfl net1 vcr0 r=r tox=tox TMR0=tmr
xRwrite ntheta nfl net1 vcr r=r tox=tox TMR0=tmr

.ic V(ntheta) = '3.14*state'
.nodeset V(ntheta) = '3.14*state'

.ends


***************************Latch Transistors and MTJ States**************************

xm15 mtj se gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm9 q net1 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm5 net1 net2 mtjr gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm3 qb net2 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm0 net2 net1 mtjl gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm8 net1 se vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm7 q net1 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm6 net1 net2 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm2 net2 se vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm4 qb net2 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm1 net2 net1 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1

xi26 mtj mtjl nthetal nrl mtj state = 0
xi1 mtjr mtj  nthetar nrr mtj state = 1

v3 se gnd! dc=0 pulse ( 0 1.05 0 10p 10p 5n 10n )
v1 vdd gnd! dc=1.05


***************************MEASUREMENTS**************************





***************************ANALYSIS**************************






