.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT


.param vdd = 1.05

*********************** Include Files **************************
    
    .hdl 'stt.va'
    .param min_time_step= 100p
    .param wn = .1u
    *.param PMOS_Size_Sense_Amp  = .1u
    *.param NMOS_Size_Sink       = .2u
    .param dvtnth_intra=AGAUSS(0,0.08,1)
    .param dvtpth_intra=AGAUSS(0,0.08,1)
    .param dvtn_intra=AGAUSS(0,0.08,1)
    .param dvtp_intra=AGAUSS(0,0.08,1)
    .param dr_intra= AGAUSS(22n,0.04n,1)
    .param dt_intra= AGAUSS(1.2n,0.01n,1)
    
    
  *******************Transistor Variations **********************
  ********************** Sweep Parameters **********************

  ****MTJ radius (W) and oxide thickness (tox) variaiton model ***

************* Process Variation Models ************************

  *********** MTJ Process Variations ***************************

.subckt ani m n K=1.13e5 a=0.02 r=45e-9 H0=1.5e5 Ms0=4.81e5 mu0=1.26e-6 gamma=1.76e11
.ends ani


.ic v(MTJ) = 0
.ic v(MTJL) = 0
.ic v(MTJR) = 0

  .subckt mtj nfl npl ntheta nr state = 0 r = 22n tox = 1.2n tmr = 2
  
  .param r1 = dr_intra
  .param tox1 = dt_intra
  
    xM1 net1 npl ntheta gnd! hys r= r1
    xM2 ntheta gnd! ani r = r1
    xC1 ntheta gnd! caps1 r = r1
    xRout ntheta nr gnd! nfl net1 vcr0 r=r1 tox=tox1 TMR0=tmr
    xRwrite ntheta nfl net1 vcr r=r1 tox=tox1 TMR0=tmr    
    
    .nodeset V(ntheta)     = '3.1415*state'
    .nodeset V(ntheta)     = '3.1415*state'    
            
  .ends

  ***********Transistor model with Vt variation applied ******
  
  .subckt nch D G S B w=100n l=30n 
  
    xMN D Gn S B n105 w=w l=l
    Vdvtn G Gn DC='(dvtn_intra/sqrt((w*l)/(3e-15)))'
    
  .ends

  .subckt pch D G S B w=100n l=30n 
   
      xMP D Gp S B p105 w=w l=l
      Vdvtp Gp G DC='(dvtp_intra/sqrt((w*l)/(3e-15)))'
            
  .ends

  ****LVT Transistor model with Vt variation applied ********
  
  .subckt nch_lvt D G S B w=100n l=30n 
  
    xMN D Gn S B n105_lvt w=w l=l
    Vdvtn G Gn DC='(dvtnth_intra/sqrt((w*l)/(3e-15)))'
        
  .ends
  
  .subckt pch_lvt D G S B w=100n l=30n 
     
    xMP D Gp S B p105_lvt w=w l=l
    Vdvtp Gp G DC='(dvtpth_intra/sqrt((w*l)/(3e-15)))'
        
  .ends
  


********************************************************************************
.subckt nor2 a b out vdd vss
xm18 net4 a vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm16 out b net4 vdd p105 w=0.1u l=0.03u nf=1 m=1
xm19 out b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm17 out a vss vss n105 w=0.1u l=0.03u nf=1 m=1
.ends nor2

********************************************************************************



********************************************************************************


********************************************************************************
.subckt nand2 a b c out vdd vss
xm6 out c vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm18 out a vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm16 out b vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm0 net6 c net7 vss n105 w=0.1u l=0.03u nf=1 m=1
xm19 net7 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm17 out a net6 vss n105 w=0.1u l=0.03u nf=1 m=1
.ends nand2


********************************************************************************
.subckt nand3 a b out vdd vss
xm18 out a vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm16 out b vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm19 net2 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm17 out a net2 vss n105 w=0.1u l=0.03u nf=1 m=1
.ends nand3


********************************************************************************
.subckt inverter in out vdd vss
xm0 out in vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm1 out in vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
.ends inverter


********************************************************************************
.subckt xor a b out vdd vss
xm1 out bbar net2 vdd p105 w=0.1u l=0.03u nf=1 m=1
xm0 net2 a vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm22 out b net1 vdd p105 w=0.1u l=0.03u nf=1 m=1
xm21 net1 abar vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm3 net6 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm2 net8 abar vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm24 out b net6 vss n105 w=0.1u l=0.03u nf=1 m=1
xm23 out abar net8 vss n105 w=0.1u l=0.03u nf=1 m=1
.ends xor


********************************************************************************
.subckt and2 a b out vdd vss
xm1 out net7 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm18 net7 a vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm16 net7 b vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm19 net1 b vss vss n105 w=0.1u l=0.03u nf=1 m=1
xm17 net7 a net1 vss n105 w=0.1u l=0.03u nf=1 m=1
xm0 out net7 vss vss n105 w=0.1u l=0.03u nf=1 m=1
.ends and2


*****************************netlist************************************

xm36 mtj wen4 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm33 mtjl wen2 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1

xm15 mtj sen gnd! gnd! n105 w=wn l=0.03u nf=1 m=1

xm29 mtjr wen2 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm9 q net20 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm5 net20 net19 mtjr gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm3 qb net19 gnd! gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm0 net19 net20 mtjl gnd! n105 w=0.1u l=0.03u nf=1 m=1
xm35 mtj wen3 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm32 mtjl wen1 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm30 mtjr wen1 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm8 net20 sep vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm7 q net20 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm6 net20 net19 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm2 net19 sep vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm4 qb net19 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1
xm1 net19 net20 vdd vdd p105 w=0.1u l=0.03u nf=1 m=1


********************control logic gates********************


xi47 gse wenbar lsep vdd gnd! nor2
xi39 renbar blb wen wen2 vdd gnd! nand2
xi38 wen bl renbar wen4 vdd gnd! nand2
xi46 gse wen lsen vdd gnd! nand3
xi43 wen2 wen3 vdd gnd! inverter
xi42 wen4 wen1 vdd gnd! inverter
xi41 ren renbar vdd gnd! inverter
xi45 bl blb vdd gnd! inverter
xi48 wen wenbar vdd gnd! inverter
xi0 wen ren sep vdd gnd! xor
xi2 ren wenbar sen vdd gnd! and2


xi26 mtj mtjl_  nthetal npll mtj
xi1 mtjr_ mtj  ntheatar nplr mtj


********************voltages********************

v68 gse gnd! dc=0 pulse ( 0 1.05 0 10p 10p 10n 20n )
v60 vdd gnd! dc=1.05

v73 bl gnd! dc=0 pwl ( 0 0 80n 0 80.01n 1.05 160n 1.05 160.01n 0 r=0 td=0 )

*v73 bl gnd! dc=0 pwl ( 0 0 20n 0 20.01n 1.05 60n 1.05 60.01n 0 r=0 td=0 )

v72 ren gnd! dc=0 pwl ( 0 0 20n 0 33.3n 0 33.31n 1.05 46.6n 1.05 46.61n 0 60n 0
+ r=0 td=0 )
v69 wen gnd! dc=0 pwl ( 0 0 20n 0 20.01n 1.05 60n 1.05 60.01n 0 80n 0 r=0 td=0 )





*****************measurement****************


*r1 mtjl mtjl_ r=0
*r2 mtjr mtjr_ r=0

vr1 mtjl mtjl_ dc=0
vr2 mtjr mtjr_ dc=0


.MEASURE TRAN ptot AVG power  from=0 to=200n

.measure tran delay    TRIG V(ren)  VAL='0.5*vdd' TD=93n RISE=1
+                      TARG V(q)  VAL='0.5*vdd'         fall=1

.measure tran ileft find '(i(vr1))' at = 93.30n
.measure tran iright find i(vr2) at = 93.5n

 
.measure tran idiff2 param ='ileft-iright'

.measure tran idiff max 'abs(I(vr1)-I(vr2))' from =93.3n to= 93.5n

.MEASURE PDP	PARAM='ptot*delay' 

******Analysis************************************************

.tran .1p 200n 0 uic
+sweep monte = 1000

*+sweep wn lin 100 0.1u 10u

.options post node list MEASFORM=1
*.option opfile = 1 split_dp = 1
*.option artist = 2 psf =2

*.option itl4 = 1
*.option gshunt=1e-13 cshunt=1e-17

.end
