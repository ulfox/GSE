#!/usr/bin/env python3.6

def _call_main():
	# Essential libraries
	import os, sys
	from os import system, getcwd
	from sys import argv, exit

	# Export current working category
	CWORKDIR = getcwd()

	if CWORKDIR in '/usr/bin' and os.path.isfile('/usr/lib64/gse/gse'):
		# If the project has been installed to root
		#prnt("system") # Exists only: for testing
		CWORKDIR = '/usr/lib64/gse'
		CGSE = CWORKDIR + '/gse.py'
		CCONFDIR = CWORKDIR + '/config.d'
		CDISTDIR = '/var/tmp/gse/dist.d'
		CLOCALLG = CWORKDIR + '/local'
		CLOGLG = '/var/log/gse'
		CSYSROOT = '/home/gse'
		CLOCALLIB = '/var/lib/gse'
		CFUNCTIONS = CWORKDIR + 'scripts/pyfunctions'

	elif os.path.isdir(os.path.dirname(CWORKDIR)+'/.git'):
		# If the project has been git cloned or simply copied to a location
		CWORKDIR = os.path.dirname(CWORKDIR)
		#print(CWORKDIR) # Exists only: for testing
		CFUNCTIONS = CWORKDIR+'/scripts/pyfunctions'
		CCONFDIR = CWORKDIR+'/config.d'
		CDISTDIR = CWORKDIR+'/dist.d'
		CLOCALLG = CWORKDIR+'/local'
		CLOGLG = CWORKDIR+'/var/log'
		CSYSROOT = CWORKDIR+'/sysroot'
		CLOCALLIB = CWORKDIR+'/var/lib'


	# Append new python path at CWORKDIR + /scripts/pyfunctions
	sys.path.append(CFUNCTIONS)


	# Simplle die function
	from gseout import die

	# Import yellow, green, blue and purple color reports
	from gseout import e_report, g_report, b_report, p_report

	# Cmdline argument's function
	def gse_args():
		if 'system' in argv[1:2]:
			sequence = "system"
		elif 'controller' in argv[1:2]:
			sequence = "controller"
		elif '-h' in argv[1:2] or '--help' in argv[1:2]:
			sequence = "target"
		else:
			sequence = "err"

		# Check if base and controller are issues at the same time. If yes, exit with error
		if sequence in 'system' or sequence in 'controller':
			if any('system' in item1 for item1 in argv[1:]) and any ("controller" in item2 for item2 in argv[1:]):
				die("Error: System and Controller arguments can not be issued at the same time. " +
					"Only one operating at a given time can be supported.")

		if sequence == "system":
			# Export arguments for system sequence
			from arg_opt import _export_args

			b_report("System sequence enabled")
			args = _export_args(sequence)

			del _export_args

			from arg_opt import _check_args
			_check_args(args)

			del _check_args


		elif sequence == 'controller':
			# Export arguments for controller sequence
			from arg_opt import _export_args

			b_report("Controller sequence enabled")
			args = _export_args(sequence)

			del _export_args

			from arg_opt import _ct_check_args
			_ct_check_args(args)

			del _ct_check_args

		elif sequence == 'target':
			from arg_opt import _export_args

			args = _export_args(sequence)
		elif sequence == "err":	
			e_report("You must specify exactly one of: 'system' or 'controller' targets as the first argument")
			e_report("See gse -h or gse 5 for more info and gse 1 for options manpage")
			die('')


		return args, sequence


	# Import the returned arguments
	args, sequence = gse_args()

	del gse_args

	# Import dist check function
	from preliminary import _is_gentoo

	# Check the output. In case of a fail, issue warning and abort
	if _is_gentoo() == 0:
		pass
	else:
		if args.dev == 0:
			e_report("Dev is enabled: Ignoring dist check fail")
		else:
			e_report("The building process has been developed for Gentoo Linux.")
			e_report("If you have a compatible system and you wish to run your scripts AT YOUR OWN RISK, ")
			e_report("then edit " + CWORKDIR + "/bin/gse.py, and remove the die entry from if _is_gentoo statement.")
			die("Aborting")

	# Clear check function
	del _is_gentoo

	# Import super user check function
	from preliminary import _is_su

	# Pass if super user, issue warning if not and abort
	if _is_su() == 0:
		e_report("Super user privileges found. Proceeding.")
	else:
		if args.dev == True:
			e_report("Dev is enabled: Ignoring su fail")
		else:
			die("No super user privileges found. Can not continue.")


	del _is_su

	# If args.mm, initiate text menu
	if args.mm:
		from preliminary import _call_menu
		_ex_stat = _call_menu(CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR)
		
		del _call_menu

	# if args.gmm, initiate gui menu
	if args.gmm:
		from gportal import _gmm
		_ex_stat = _gmm()

		del _gmm

	return _ex_stat

# Main function
if __name__ == "__main__":
	_ex_stat = _call_main()
	
	if _ex_stat == 0:
		print("Success")
		exit(0)
	else:
		print("Fail")
		exit(1)


