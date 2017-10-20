

.temp 110
.GLOBAL 0 gnd!
.lib '/packages/process_kit/generic/generic_32nm/ipdk32_28nm_apr2017/SAED_PDK32nm/hspice/saed32nm.lib' TT
  

.param lmin = 0.03u
*.param wn_min = 0.1u
*.param wp_min = 0.1u
.param vdd = 1.05

.param
+          delta = 0.1u 
.param 
+          wn_min = optw(0.2u, 0.1u, 0.5u, delta)
+          wp_min = optw(0.2u, 0.1u, 0.5u, delta)


.global gnd!

xm0 out in gnd! gnd! n105 w=wn_min l=lmin 
xm1 out in vdd vdd p105 w=wp_min l=lmin


v2 in gnd! dc=0 pulse ( 0 1.05 0 10p 10p 2n 4n )
*******************************vddply voltage************************************************
vvdd vdd gnd! dc = 1.05
vvss gnd! 0 dc=0

*********plot V(Z) and V(Zbar)*******************************

.probe V(in) V(out) i(vdd)


.MEASURE TRAN ptot AVG power  from=0 to=10n


.MEASURE TRAN tphl     TRIG V(in)  VAL='0.5*vdd' TD=2n fall=1
+                      TARG V(out)  VAL='0.5*vdd'         RISE=1
.MEASURE TRAN tplh     TRIG V(in)  VAL='0.5*vdd' TD=4n RISE=1
+                      TARG V(out)  VAL='0.5*vdd'      fall=1

.MEASURE TRAN DELAY	PARAM='Max(tphl,tplh)'

.MEASURE PDP	PARAM='ptot*DELAY' goal < 1e-25


*******optimization**********

.model opt1 opt relout = .001 relin = .0001
*.model opt1 opt relin=1e-5 relout=1e-5 itropt=40

*.model optmod opt1 
*+relin=1e-5 relout=1e-5 itropt=30 grad=1e-9 close=1 cut=4 
*+difsiz=1e-9 cendif=1e-9  max=1e10
  

******Analysis************************************************

.tran 10p 100n 
*+sweep wp_min lin 10 0.1u 5u
+SWEEP optimize = optw results = PDP model=opt1


.options post probe  MEASFORM=1

.end