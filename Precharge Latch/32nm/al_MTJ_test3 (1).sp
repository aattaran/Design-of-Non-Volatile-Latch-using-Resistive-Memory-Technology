**ALi**

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'

.subckt mtj nfl npl ntheta nr state = 0 r = 22n tox = 1n tmr = 2

xM1 net1 npl ntheta 0 hys r=r
xM2 ntheta 0 ani r=r
xC1 ntheta 0 caps1 r=r
xRout ntheta nr 0 nfl net1 vcr0 r=r tox=tox TMR0=tmr
xRwrite ntheta nfl net1 vcr r=r tox=tox TMR0=tmr

.ic V(ntheta) = '3.14*state'
.nodeset V(ntheta) = '3.14*state'

.ends mtj

.param wn_min = 0.1u
.param wp_min = '2.55*wn_min'

xi1  npl nfl ntheta nr mtj 
xm2 npl vdd gnd! gnd! n105 w=wn_min l=.03u nf=1 m=1
xm10 nfl gnd! vdd vdd p105 w=wp_min l=.03u nf=1 m=1
v9 vdd gnd! dc=1.05

.ic v(nfl) = 0
.ic v(npl) = 0

******Analysis************************************************

.tran .1p 10n 0 uic
+sweep wn_min lin 100 0.1u 4u

.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end