#!/usr/local/bin/python
##############################################################################
#Programed by Hamid Mahmoodi
#Nano-electronics & Computing Research Lab
#March 14, 2016
#Measurement extraction from Hspice output file'''
##############################################################################

hspout = 'al_sp.mt0';
fail_count=0
line=5

################################################################
# Main loop begin
################################################################
INHSPOUT = open(hspout)
   
inpline = INHSPOUT.readline()
inpline = INHSPOUT.readline()
inpline = INHSPOUT.readline()
inpline = INHSPOUT.readline()
tmpix = inpline.split()
for inpline in INHSPOUT: 
	tmpd = inpline.split()
	ptot = tmpd[tmpix.index('ptot')]
	delay = tmpd[tmpix.index('delay')]

	if (delay == 'failed') or (float(delay) > 500e-12):
		fail_count = fail_count +1
		print "Failure at line number %s : delay= %s" % (line, delay)

	line = line +1

total_sim = line -5
print "\nTotal failure count of %s out of %s cases\n" % (fail_count, total_sim)
fr=100.00*fail_count/total_sim
print "Failure rate of %s%%\n" % fr

INHSPOUT.close()

