*******FinFET Model****
.lib 'models' ptm10hp
*******temperature in degree C****
.temp 110
**********************************

.param 
+          fins_p1 = 1
+          fins_p2 = 1
+          fins_p3 = 1
+          fins_n1 = 1
+          fins_n2 = 1
+          fins_n3 = 1


****MTJ Model*****
.include '../MTJ/mtj_res.subckt'

***Finfet Vth shift model ***
.include '../finfet/finfet_var.subckt'

**********Variation model and parameters*************************

******Vt Variation Model***
.param vt0= 185m ***Nominal threshold voltage
.param dvtn_intra=AGAUSS(0,'0.1*vt0',1)
.param dvtp_intra=AGAUSS(0,'0.1*vt0',1)

.param dvth_inter=0 *AGAUSS(0,'0.1*vt0',1)
.param dvtn_inter=dvth_inter
.param dvtp_inter=dvth_inter

****MTJ radious (r) and oxide thickness (t) variaiton model ***
.param r0=14n  ***nominal MTJ radious
.param tox0=0.85n  ***nominal MgO thickness
.param tmr0=2 ***nominal TMR

.param dr_intra=AGAUSS(0,'0.1*r0',1)
.param dt_intra=AGAUSS(0,'0.1*tox0',1)

.param drad_inter=0 *AGAUSS(0,'0.1*r0',1)
.param dtmgo_inter=0 *AGAUSS(0,'0.1*tox0',1)

.param dr_inter=drad_inter
.param dt_inter=dtmgo_inter
****************************************************************


**************Netlist*****************
.param delta = 1

.param 
+       fins=1
*+      fins=opt1(1,1,10,delta)

.include precharge_latch.subckt

xlatch vdd vss se q qbar  mtj_latch stat=1

*******************Load Transistors for FO4 load*****************

XLoad   0 q 0 0 nfet nfin=4
XLoad2   0 qbar 0 0 nfet nfin=4

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
+sweep fins_p1 lin 20 1 10
.options post probe  MEASFORM=1

.end