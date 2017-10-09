#!/usr/bin/env python3.4

# Gentoo check function
def _is_gentoo():
	'''
	Check if the project has been initiated from a Gentoo system
	'''
	
	from subprocess import call

	# Grep Gentoo from the releases file.
	_dist_check = call("grep ^NAME= /etc/*release | awk -F '=' '{print $2}' | grep -q Gentoo", stdout=None, stderr=None, shell=True)
	
	del call

	# Return 0 in case grep was successful, or 1 otherwise.
	if _dist_check == 0:
		del _dist_check
		return 0
	else:
		return 1

# Check for superuser privileges
def _is_su():
	'''
	Check if the project has been initiated with super user permissions
	'''
	
	from subprocess import call

	# The check is very simple. It checks if the $UID is equal to 0. In case it is not, it returns a value of 1
	_super_u = call("if [[ $(echo $UID) == 0 ]]; then exit 0; else exit	1; fi", stdout=None, stderr=None, shell=True)

	del call

	# Test the return value and return either 0 or 1
	if _super_u == 0:
		del _super_u
		return 0
	else:
		return 1

# Simple input call
def portalin(_input):
	'''
	Calls for a user input.
		There are two calls for input
			I 	) The first one requests an input and returns it to the function that requested it
			II 	) The second asks for a user input and does nothing. This one is for visual purpose like (press any key)
	'''

	from gpyfunctions.tools.gseout import report_colors
	
	# Ask for user input
	if _input is "_input":
		portin = input(report_colors.YELLOW + "Input :: <= " + report_colors.RESET)
		return portin

	# Asks for an input to continue the process.
	# The main difference of this one from the above, apart from the stdout text is that it does not return anything.
	elif _input is "_key":
		portin = input(report_colors.BLUE + "Press any key to continue" + report_colors.RESET)

	del report_colors


# Simple shell call
def _shell():
	'''
	Shell function that:
		Exports the current $SHELL of the system
		Initiates a call subprocess on the given $SHELL
		Resumes the process when the call shell subprocess finishes
	'''

	from gpyfunctions.tools.gseout import e_report
	from os import environ

	# Export $SHELL
	active_shell = environ['SHELL']
	
	e_report("Calling " + active_shell + ", please exit to resume script")
	
	# Import time and wait 3 seconds before initiating a shell
	import time
	time.sleep(1.5)
	
	from subprocess import call
	
	# Open shell terminal with as $SHELL
	call([active_shell], stdout=None, stderr=None, shell=True)
	e_report("Proceeding")
	
	# Clear and exit
	del e_report, time, call, active_shell, environ

# Simple clear screen function
def _clear():
	'''
	Very simply screen clear function.
		When called, it executes system("clear") for os module
		This function exists only to aid the text menu functions.
	'''

	from os import system
	system("clear")

# Parameter error function
def _parameter_error():
	'''
	Parameter miss match error
	This error will be printed before key point actions.
	Example: All actions that request write access in the system.
	'''

	from gpyfunctions.tools.gseout import die
	from os import system
	die("""
		[ FATAL ]
		
		If this message is printed while using the Maim Menu
		That means essential files are altered or something bad is happening.

		Please run a health-check from the ~Main Menu~ and a Version check first.
		If you see this again after the health/version check, please submit a bug report
		and stop using the program, or data loss may occur.

		Exiting...
		""")


# Export important project's sub-directories
def _gse_path(_gpyfunc_):
	'''
	The purpose of this function is to read the given _gpygunc_ variable and export
		the all important project's sub-directories
		The subdirectories are:
			CCGSE
			CCONFDIR
			CDISTDIR
			CLOCALLG
			CLOGLG
			CSYSROOT
			CLOCALLIB
			CFUNCTIONS
	'''

	from os import getcwd, path
	from sys import exit

	# Export current working category
	CWORKDIR = getcwd()

	if _gpyfunc_ == 'sys':
		CWORKDIR = '/usr/lib64/gse'
		CGSE = CWORKDIR + '/gse.py'
		CCONFDIR = CWORKDIR + '/config.d'
		CDISTDIR = '/var/tmp/gse/dist.d'
		CLOCALLG = CWORKDIR + '/local'
		CLOGLG = '/var/log/gse'
		CSYSROOT = '/home/gse'
		CLOCALLIB = '/var/lib/gse'
		CFUNCTIONS = CWORKDIR + 'scripts/pyfunctions'

	elif _gpyfunc_ == '.git':
		# If the project has been git cloned or simply copied to a location
		CWORKDIR = path.dirname(CWORKDIR)
		CFUNCTIONS = CWORKDIR+'/scripts/pyfunctions'
		CGSE = CWORKDIR + '/gse.py'
		CCONFDIR = CWORKDIR+'/config.d'
		CDISTDIR = CWORKDIR+'/dist.d'
		CLOCALLG = CWORKDIR+'/local'
		CLOGLG = CWORKDIR+'/var/log'
		CSYSROOT = CWORKDIR+'/sysroot'
		CLOCALLIB = CWORKDIR+'/var/lib'

	else:
		print("\033[0;31m Could not find project's directory \033[0;0m")
		exit(1)

	del getcwd, path, exit

	return CWORKDIR, CGSE, CFUNCTIONS, CCONFDIR, CDISTDIR, CLOCALLG, CLOGLG, CSYSROOT, CLOCALLIB




