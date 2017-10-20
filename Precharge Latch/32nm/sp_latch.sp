*******32 Model****
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT
  
*******temperature in degree C****
.temp 110
**********************************

****MTJ Model*****
.include '../MTJ/mtj_res.subckt'


**********Variation model and parameters*************************

******Vt Variation Model***
.param dvtn_intra=AGAUSS(0,0.03,1)
.param dvtp_intra=AGAUSS(0,0.03,1)

.param dvth_inter=0 *AGAUSS(0,0.06,1)
.param dvtn_inter=dvth_inter
.param dvtp_inter=dvth_inter


****MTJ width (W) and oxide thickness (t) variaiton model ***
.param dw_intra= AGAUSS(0,0.1,1)
.param dt_intra= AGAUSS(0,0.1,1)

.param dwidth_inter= 0 *AGAUSS(0,0.1,1)
.param dtmgo_inter= 0 *AGAUSS(0,0.1,1)

****Transistor model with Vt variation applied ******
.subckt nch D G S B w=wn_min l=lmin 
MN D Gn S B nmos w=w l=l
Vdvtn G Gn DC='dvtn_inter+(dvtn_intra/sqrt((w*l)/(480e-18)))'
.ends

.subckt pch D G S B w=wp_min l=lmin
MP D Gp S B pmos w=w l=l
Vdvtp Gp G DC='dvtp_inter+(dvtp_intra/sqrt((w*l)/(480e-18)))'
.ends


****MTJ radious (r) and oxide thickness (t) variaiton model ***

.param tmr0=2 ***nominal TMR
.param r0 = 32n  ***nominal MTJ radious
.param tox0 = 1n ***nominal MgO thickness

.param dr_intra=AGAUSS(0,'0.1*r0',1)
.param dt_intra=AGAUSS(0,'0.1*tox0',1)

.param drad_inter=0 *AGAUSS(0,'0.1*r0',1)
.param dtmgo_inter=0 *AGAUSS(0,'0.1*tox0',1)

.param dr_inter=drad_inter
.param dt_inter=dtmgo_inter
****************************************************************


**************Netlist*****************
.param delta = 1

.param lmin = 0.03u
.param wn_min = 0.1u
.param wp_min = 0.1u
.param vdd = 1.05

.include sp_latch.subckt

xlatch vdd vss se q qbar  mtj_latch stat=1

*******************Load Transistors for FO4 load*****************

XLoad   0 out 0 0 n105 w=wn_min l=lmin

************************* Voltages************************************************************

*vse se vss dc=0 pulse ( 0 vdd 2n 0.1n 0.1n 1.9n 4n)
*vse se  vss dc=0

*******************************supply voltage************************************************

vvdd vdd 0 dc=vdd
vvss vss 0 dc=0

***********************************Sense Enable************************************************

vse se vss dc=0 pwl (0 0 2n 0 2.2n vdd)
*vse se vss dc=0


****************************plot V(Z) and V(Zbar)************************************************

.probe V(se) v(q) v(qbar) 

*******************measuremnts**************************************************************



.MEASURE TRAN delay      TRIG V(se)  VAL='0.5*vdd' TD=2n rise=1
+                          TARG V(q)  VAL='0.5*vdd'        rise=1

.measure ptot avg power from=2n to=20n *weight=1 *minval=1000nw

.MEASURE pdp	PARAM='ptot*delay' *goal < '1e-25'


*.model optmod opt 
*+relin=1e-5 relout=1e-5 itropt=30 grad=1e-9 close=1 cut=4 
*+difsiz=1e-9 cendif=1e-9  max=1e10
******************************Analysis***************************************


.tran 10p 20n 
*+sweep optimize=opt1 results=pdp   model=optmod
*+sweep monte=1000
.options post probe  MEASFORM=1

.end