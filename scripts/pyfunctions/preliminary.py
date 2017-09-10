#!/usr/bin/env python3.6

# Gentoo check function
def _is_gentoo():
	from subprocess import call

	_dist_check = call("grep ^NAME= /etc/*release | awk -F '=' '{print $2}' | grep -q Gentoo", stdout=None, stderr=None, shell=True)
	
	del call

	if _dist_check == 0:
		del _dist_check
		return 0
	else:
		return 1

# Check for superuser privileges
def _is_su():
	from subprocess import call

	_super_u = call("if [[ $(echo $UID) == 0 ]]; then exit 0; else exit	1; fi", stdout=None, stderr=None, shell=True)

	del call

	if _super_u == 0:
		del _super_u
		return 1
	else:
		return 1


# Simple shell call
def _shell():
	from gseout import e_report
	from os import environ

	active_shell = environ['SHELL']
	
	e_report("Calling " + active_shell + ", please exit to resume script")
	
	import time
	time.sleep(3)
	
	from subprocess import call
	
	call([active_shell], stdout=None, stderr=None, shell=True)
	e_report("Proceeding")
	
	del e_report, time, call, active_shell, environ

# Simple clear screen function
def _clear():
	from os import system
	system("clear")

def _parameter_error():
	from gseout import die
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



