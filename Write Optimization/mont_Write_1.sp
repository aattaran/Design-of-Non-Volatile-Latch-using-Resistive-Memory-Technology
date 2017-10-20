****Summer 2017 NECRL STT Latch Wite Path Monte Carlo Analysis****
*****************Tyler Sheaves & Aliyar Attaran ******************
.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT

.hdl 'stt.va'
********** FEEL FREE TO CHANGE WIDTHS HERE ************************

******************* Scaling Parameters ***************************
** NOTE YOU CAN DELETE VALUES IF EMBEDED OPTIMIZATION IS NEEDED **

.param n_w        = .5
.param top_scale  =  1.1
.param sink_scalen=  1.5
.param sink_scalep=  1.5

.param n_top      = 'n_w*1u'
.param p_top      = 'n_top*top_scale'
.param n_sink     = 'n_top*sink_scalen'
.param p_sink     = 'p_top*sink_scalep'

**************** Top NMOS ****************************************

xm1 nplr wen2 gnd! gnd! nch w=n_top l=0.03u nf=1 m=1
xm0 nfld wen2 gnd! gnd! nch w=n_top l=0.03u nf=1 m=1

************** Top PMOS *****************************************

xm4 nfld wen1 vdd vdd pch w=p_top l=0.03u nf=1 m=1
xm3 nplr wen1 vdd vdd pch w=p_top l=0.03u nf=1 m=1

**************** Sink *******************************************

xm2 shared wen4 gnd! gnd! nch w=n_sink l=0.03u nf=1 m=1
xm5 shared wen3 vdd vdd pch w=p_sink l=0.03u nf=1 m=1

************ Setting nodes helps with convergance ******************

.nodeset V(shared) = 1.05
.nodeset V(nfld) = 0
.nodeset V(nplr) = 0

********************** DO NOT CHANGE ANYTHING BELOW ****************

v1 vdd gnd! dc=1.05
v5 wen3 gnd! dc=0 pulse ( 1.05 0 10p 10p 10p 30n 60n )
v4 wen4 gnd! dc=0 pulse ( 1.05 0 10p 10p 10p 30n 60n )
v3 wen2 gnd! dc=0 pulse ( 0 1.05 10p 10p 10p 30n 60n )
v2 wen1 gnd! dc=0 pulse ( 0 1.05 10p 10p 10p 30n 60n )

xi7 shared nplr ntr nrr mtj state = 0 r1 = dr_intra tox1 = dt_intra
xi8 nfld shared ntd nrd mtj state = 1 r1 = dr_intra tox1 = dt_intra

.option tnom = 110

** Transistor vto variation .08V at 1 sigma **********************

.param dvtn_intra=AGAUSS(0,0.08,1)
.param dvtp_intra=AGAUSS(0,0.08,1)

** 10% variation in MTJ parameters at 1 sigma ********************

.param dr_intra= AGAUSS(22n,2.2n,1)
.param dt_intra= AGAUSS(1n,.1n,1)

****************** MTJ Write Test Fixture ************************

.subckt mtj nfl npl ntheta nr state = 0 r1 = 22n tox1 = 1n tmr = 1

xM1 net1 npl ntheta 0 hys r=r1
xM2 ntheta 0 ani r=r1
xC1 ntheta 0 caps1 r=r1
xRout ntheta nr 0 nfl net1 vcr0 r=r1 tox=tox1 TMR0=tmr
xRwrite ntheta nfl net1 vcr r=r1 tox=tox1 TMR0=tmr

.nodeset V(ntheta) = '3.14*state'
.ic V(ntheta) = '3.14*state'

.ends

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

.tran 10p 90n 0 uic

********************YOU MAY CHANGE THE ITERATION COUNT ********************

+SWEEP monte=100

************

.MEASURE tran ntrh FIND = V(ntr)  AT = 59n
.MEASURE tran ntdh1 FIND = V(ntd) AT = 29n
.MEASURE tran ntrl1 FIND = V(ntr) AT = 29n
.MEASURE tran ntdl FIND = V(ntd)  AT = 59n
.MEASURE tran ntdh2 FIND = V(ntd) AT = 89n
.MEASURE tran ntrl2 FIND = V(ntr) AT = 89n

.MEASURE tran n_Width PARAM = 'n_top'
.MEASURE tran p_scale PARAM = 'top_scale'
.MEASURE tran si_scalen PARAM = 'sink_scalen'
.MEASURE tran si_scalep PARAM = 'sink_scalep'
.MEASURE tran area PARAM = '((2*n_top) + (2*p_top) + n_sink + p_sink) * .03u'

**** ONLY ENABLE ARTIST = 2 PSF=2 WITH SMALL SWEEP SIZE (monte<10)!!!! *****

******.option ARTIST = 2 PSF = 2

.option MEASFORM = 1
.option opfile=1 split_dp =1