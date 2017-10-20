.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'

.param vdd = 1.05




********************************************************************************
.subckt mtj nfl npl nr ntheta state = 0

xm1 net1 npl ntheta 0 hys r=22n
xm2 ntheta 0 ani r=22n
xc1 ntheta 0 caps1 r=22n
xrout ntheta nr 0 nfl net1 vcr0 r=22n tox=1n
xrwrite ntheta nfl net1 vcr r=22n tox=1n

.ic V(ntheta) = 'state*3.1415'
.nodeset V(ntheta) = 'state*3.1415'

.ends mtj


*.param topN = .5u 
*.param topP = .5u 
*.param sinkN = .5u 
*.param sinkP = .5u 

.param
+          delta = 0.1u 

+          topN_  = optw(1.2u, 0.5u, 9u, delta)
+          topP_  = optw(1.2u, 0.5u, 9u, delta)
+          sinkP_ = optw(1.6u, 0.5u, 9u, delta)
+          sinkN_ = optw(1.6u, 0.5u, 9u, delta)



********************************************************************************
.subckt write_path vdd wen1 wen2 wen3 wen4 gnd! nrd nrr ntd ntr

xm2 shared wen4 gnd! gnd! n105 w=sinkN_ l=0.03u nf=1 m=1
xm1 nplr wen2 gnd! gnd! n105 w=topN_ l=0.03u nf=1 m=1
xm0 nfld wen2 gnd! gnd! n105 w=topN_ l=0.03u nf=1 m=1
xm5 shared wen3 vdd vdd p105 w=sinkP_ l=0.03u nf=1 m=1
xm4 nfld wen1 vdd vdd p105 w=topP_ l=0.03u nf=1 m=1
xm3 nplr wen1 vdd vdd p105 w=topP_ l=0.03u nf=1 m=1
xi7 shared nplr nrr ntr mtj state = 0
xi6 nfld shared nrd ntd mtj state = 1
.ends write_path

 

********************************************************************************


v1 net10 gnd! dc=1.05

v2 wen1 gnd! dc=0 pulse (1.05 0 0 10p 10p 10n 20n) 
v4 wen2 gnd! dc=0 pulse (1.05 0 0 10p 10p 10n 20n)
v5 wen3 gnd! dc=0 pulse (0 1.05 0 10p 10p 10n 20n)
v3 wen4 gnd! dc=0 pulse (0 1.05 0 10p 10p 10n 20n)




xi0 net10 wen1 wen2 wen4 wen3 gnd! nrd nrr ntd ntr write_path

.ic v(ntd) = 3.14  v(ntr) = 3.14


*************************** MEASUREMENTS *********************************

.measure tran delay1    TRIG V(wen4)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(ntr)      VAL='3.1'           rise=1

.measure tran delay2    TRIG V(wen1)  VAL='0.1*vdd' TD=10n rise=1
+                      TARG V(ntd)      VAL='3.1'           rise=1

.measure tran delay param = 'max(delay1,delay2)'   goal < 7n

.measure area param = 'topN_*2+topP_*2+sinkN_+sinkP_' goal < 9u  weight  = 10


*********optimization**********
.model optw opt
+relin=1e-5 relout=1e-5 itropt=30 grad=1e-9 close=1 cut=4 
+difsiz=1e-9 cendif=1e-9  max=1e10 relv = 1e-4 relvar = 1e-2

************************** ANALYSIS ***********************************


*.include params.sp
.tran 10p 20n 0 uic
*+ SWEEP topP lin 10 0.5u 10u

*+sweep DATA=sweeper_params

+SWEEP optimize = optw results = delay,area model=optw

*.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end