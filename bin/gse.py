#!/usr/bin/env python3.4

def _call_main(_gpyfunc_):
	'''
	Main function
		This function:
			Detects the project's directory and exports it with it's sub-dirs
			Exports the given arguments and options
			Exports the build sequence
			Brings up the text/gui menu if given from the arguments
			Last, enables the exported sequence (build process)
	'''

	# Simple die function and yellow, green, blue and purple color reports
	from gpyfunctions.tools.gseout import die, e_report, g_report, b_report, p_report

	# Check target and export args
	def gse_args():
		'''
			Exports the sequence variable
			Calls _export_args which defines and exports the final arguments based on the sequence
		'''
		
		if any('system' in _tmp1 for _tmp1 in argv[1:]):
			sequence = "system"
		elif any('controller' in _tmp1 for _tmp1 in argv[1:]):
			sequence = "controller"
		elif any('-h' in _tmp1 for _tmp1 in argv[1:]) or any('--help' in _tmp2 for _tmp2 in argv[1:]):
			# For missing target arguments and given help option. Call general args.
			sequence = "help"
		elif any('-V' in _tmp1 for _tmp1 in argv[1:]) or any('--version' in _tmp2 for _tmp2 in argv[1:]):
			# For missing target arguments and given version option. Print version.
			sequence = "version"
		else:
			# Die for missing target and help opt
			e_report("You must specify exactly one of: 'system' or 'controller' targets")
			e_report("See gse -h or gse 5 for more info and gse 1 for options manpage")
			die('')

		# # Check if base and controller are issues at the same time. If yes, exit with error
		# if sequence in 'system' or sequence in 'controller':
		# 	if any('system' in item1 for item1 in argv[1:]) and ("controller" in item2 for item2 in argv[1:]):
		# 		die("Error: System and Controller arguments can not be issued at the same time. " +
		# 			"Only one operating at a given time can be supported.")

		if sequence == "system":
			# Export arguments for system sequence
			from gpyfunctions.tools.librarium import _export_args

			# Evaluate the arguments
			p_report("System sequence enabled")
			args = _export_args(sequence)

			del _export_args

		elif sequence == 'controller':
			# Export arguments for controller sequence
			from gpyfunctions.tools.librarium import _export_args

			# Evaluate the arguments
			p_report("Controller sequence enabled")
			args = _export_args(sequence)

			del _export_args

		elif sequence == 'help':
			# Print --help
			from gpyfunctions.tools.librarium import _export_args
			args = _export_args(sequence)
		elif sequence == 'version':
			# Print --version
			from gpyfunctions.tools.librarium import _export_args
			args = _export_args(sequence)


		return args, sequence


	# Import the returned arguments
	args, sequence = gse_args()

	del gse_args

	# Import dist check function
	from gpyfunctions.preliminary import _is_gentoo

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
	from gpyfunctions.preliminary import _is_su

	# Pass if super user, issue warning if not and abort
	if _is_su() == 0:
		e_report("Super user privileges found. Proceeding.")
	else:
		if args.dev == True:
			e_report("Dev is enabled: Ignoring su fail")
		else:
			die("No super user privileges found. Can not continue.")


	del _is_su

	if (args.mm or args.gmm):
		# Check for mm && gmm conflict
		if args.mm and args.gmm:
			die("Error: Use one of [--mm/--gmm]")
		
		# If args.mm, initiate text menu
		if args.mm:
			from gpyfunctions.menu.txmen.gsetxf import _call_menu
			_ex_stat = _call_menu(CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR)
			
			del _call_menu

		# if args.gmm, initiate GUI menu
		if args.gmm:
			from gpyfunctions.menu.portal.gportal import _gmm
			_ex_stat = _gmm()

			del _gmm

		return _ex_stat

	elif sequence is "system" or sequence is "controller":
		from gpyfunctions.tools.warp import warp
		_ex_stat = warp(sequence, args, CWORKDIR, CCONFDIR, CLOCALLG)

		del warp
		
		return _ex_stat
	else:
		return 9

# EO_call_main


# Essential libraries
from sys import argv, exit
from os import path as ospath
from sys import path as syspath

# Append gpyfunctions from /usr/lib64/gse/scripts/
if ospath.isdir('/usr/lib64/gse/scripts/gpyfunctions'):
	if ospath.isfile('/usr/lib64/gse/scripts/gpyfunctions/__init__.py'):
		syspath.append('/usr/lib64/gse/scripts')
		_gpyfunc_ = "sys"

# Append gpyfunctions from git chase
elif ospath.isdir('../scripts/gpyfunctions'):
	if ospath.isfile('../scripts/gpyfunctions/__init__.py'):
		syspath.append("../scripts")
		_gpyfunc_ = ".git"
else:
	print("Could not locate gpy modules path")
	exit(1)

def __gse_mod_check():
	from sys import exit

	try:
		import gpyfunctions
		del gpyfunctions

		from gpyfunctions import preliminary
		del preliminary

		from gpyfunctions.tools import gseout
		del gseout

		from gpyfunctions.tools import librarium
		del librarium

		from gpyfunctions.tools import warp
		del warp

		from gpyfunctions.menu.txmen import gsub_men
		del gsub_men

		from gpyfunctions.menu.txmen import gsetxmen
		del gsetxmen

		from gpyfunctions.menu.txmen import gsetxf
		del gsetxf

		from gpyfunctions.menu.portal import gportal
		del gportal
		
	except ImportError:
		raise
		exit(1)

	print("\033[1;35mAll gse modules are healthy\033[0;0m\n")


# Check gpy modules. This function exists only in the experimental phase.
__gse_mod_check()

del __gse_mod_check, ospath, syspath

# Import function for exporting CWORDKIR, ... PATHS
from gpyfunctions.preliminary import _gse_path

# Export the paths from _gse_path()
CWORKDIR, CGSE, CFUNCTIONS, CCONFDIR, \
CDISTDIR, CLOCALLG, CLOGLG, CSYSROOT, \
CLOCALLIB = _gse_path(_gpyfunc_)

del _gse_path

# Main function
if __name__ == "__main__":
	try:
		_ex_stat = _call_main(_gpyfunc_)

	except KeyboardInterrupt:
		from gpyfunctions.tools.gseout import e_report
		e_report("\n\nKeyboard interrupt detected.\n")
		exit(1)
				
	except EOFError:
		from gpyfunctions.tools.gseout import b_report
		b_report("\n\nEOFError. Maybe CTRL-D?\nIf not, please report this bug!\n")
		exit(1)
	
	if _ex_stat == 0:
		print("Success")
		exit(0)

	elif _ex_stat == 9:
		print("No valid sequence")
		exit(9)

	else:
		print("Fail")
		exit(1)

else:
	print("Not Main")
	exit(1)


