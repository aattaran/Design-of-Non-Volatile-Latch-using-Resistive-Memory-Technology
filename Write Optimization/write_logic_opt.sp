.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'
*.include params.sp
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


********************************************************************************
.subckt and_gate a and b c nand vdd vss

xm7 and nand vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm5 net42 c vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm4 net43 b net42 vss n105 w=0.1u l=0.03u nf=1 m=1
xm0 nand a net43 vss n105 w=0.1u l=0.03u nf=1 m=1
xm8 and nand vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm3 nand c vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm2 nand b vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm1 nand a vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
.ends and_gate
********************************************************************************
.subckt nand a b nand vdd vss

xm10 nand a vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm9 nand b vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm6 nand a net31 vss n105 w=0.1u l=0.03u nf=1 m=1
xm8 net31 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
.ends nand
********************************************************************************
.subckt xor a ab b bb vdd vss xor

xm3 xor ab net15 vss n105 w=0.1u l=0.03u nf=1 m=1
xm2 xor a net11 vss n105 w=0.1u l=0.03u nf=1 m=1
xm1 net15 bb vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm0 net11 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm7 net31 b vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm6 net27 a vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
xm5 xor ab net31 vdd p105 w=0.26u l=0.03u nf=1 m=1
xm4 xor bb net27 vdd p105 w=0.26u l=0.03u nf=1 m=1
.ends xor
********************************************************************************
.subckt inverter input output vdd vss

xm0 output input vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm1 output input vdd vdd p105 w=0.26u l=0.03u nf=1 m=1
.ends inverter
********************************************************************************
.subckt control_logic d ren sen sep vdd vss wen wen1 wen2 wen3 wen4

xi1 wen wen4 renb db wen1 vdd vss and_gate
xi0 wen wen2 renb d wen3 vdd vss and_gate
xi2 wenb ren net20 vdd vss nand
xi3 ren renb wen wenb vdd vss sep xor
xi7 net20 sen vdd vss inverter
xi6 d db vdd vss inverter
xi5 ren renb vdd vss inverter
xi4 wen wenb vdd vss inverter
.ends control_logic


********************************************************************************
*.param topN = 0.81u 
*.param topP = 1.12u 
*.param sinkN = 1.74u 
*.param sinkP = 2.4u 

.param
+          delta = 0.1u 

+          topN  = optw(1.6u, 0.5u, 9u, delta)
+          topP  = optw(1.6u, 0.5u, 9u, delta)
+          sinkP = optw(2.6u, 0.5u, 9u, delta)
+          sinkN = optw(2.6u, 0.5u, 9u, delta)

********************************************************************************
.subckt write_path vdd wen1 wen2 wen3 wen4 gnd! nrd nrr ntd ntr

xm2 shared wen4 gnd! gnd! n105 w=sinkN l=0.03u nf=1 m=1
xm1 nplr wen2 gnd! gnd! n105 w=topN l=0.03u nf=1 m=1
xm0 nfld wen2 gnd! gnd! n105 w=topN l=0.03u nf=1 m=1
xm5 shared wen3 vdd vdd p105 w=sinkP l=0.03u nf=1 m=1
xm4 nfld wen1 vdd vdd p105 w=topP l=0.03u nf=1 m=1
xm3 nplr wen1 vdd vdd p105 w=topP l=0.03u nf=1 m=1
xi7 shared nplr nrr ntr mtj state = 0
xi6 nfld shared nrd ntd mtj state = 1
.ends write_path

********************************************************************************
.subckt control_logic_tb sen sep wen1 wen2 wen3 wen4

xi0 d ren sen sep net7 gnd! wen wen1 wen2 wen3 wen4 control_logic
v1 net7 gnd! dc=1.05
v4 d gnd! pulse ( 1.05 0 10p 10p 10p 10n 20n )
v3 ren gnd! dc=0 pulse ( 1.05 0 10p 10p 10p 20n 40n )
v2 wen gnd! dc=0 pulse ( 1.05 0 10p 10p 10p 40n 80n )
.ends control_logic_tb
********************************************************************************

xi0 net10 wen1 wen2 wen4 wen3 gnd! nrd nrr ntd ntr write_path
v1 net10 gnd! dc=1.05
xi8 sen sep wen1 wen2 wen3 wen4 control_logic_tb




.ic v(ntd) = 3.14  v(ntr) = 3.14


*************************** MEASUREMENTS *********************************

.measure tran delay1    TRIG V(wen4)  VAL='0.1*vdd' TD=0n RISE=1
+                      TARG V(ntr)      VAL='3.1'           rise=1

.measure tran delay2    TRIG V(wen1)  VAL='0.1*vdd' TD=10n rise=1
+                      TARG V(ntd)      VAL='3.1'           rise=1

.measure tran delay param = 'max(delay1,delay2)'   goal < 7n

.measure area param = 'topN*2+topP*2+sinkN+sinkP' goal < 9u  weight  = 10


*********optimization**********
.model optw opt
+relin=1e-5 relout=1e-5 itropt=30 grad=1e-9 close=1 cut=4 
+difsiz=1e-9 cendif=1e-9  max=1e10 relv = 1e-4 relvar = 1e-2

************************** ANALYSIS ***********************************


*.include params.sp
.tran 10p 100n 0 uic
*+ SWEEP topP lin 10 0.5u 10u

*+sweep DATA=sweeper_params

*+SWEEP optimize = optw results = delay,area model=optw

.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end
