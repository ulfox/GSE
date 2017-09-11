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

# Simple input call
def portalin(_input):
	from gseout import report_colors
	
	if _input is "_input":
		portin = input(report_colors.YELLOW + "Input :: <= " + report_colors.RESET)

	elif _input is "_key":
		portin = input(report_colors.YELLOW + "Press any key to continue" + report_colors.RESET)

	del report_colors
	return portin


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

# Parameter miss match error
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


# Text main menu
def _call_menu(CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR):
	from gsub_men import _call_sub
	from gmen_opt import _men_opt

	def _init_sub(men, bpar, spar, ccal, *args):
		print(*args)

		try:
			del _sub_call

			c = [_PARENT, _CHILD, _STAY]
		
			for i in c[:]:
				del i
		
		except NameError:
			pass

		while True:
			_clear()

			_men_opt(men)
			
			_sub_call = _call_sub(ccal, *args)

			for k, v in _sub_call.items():
				if k is "_PARENT" and v == 0:
					BACKTO = bpar

				elif k is "_CHILD":

					BACKTO = v

				elif k is "_STAY" and v == 0:
					BACKTO = spar


			return BACKTO

	def _main_loop(minit, CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR):
		BACKTO = minit

		while True:
			if BACKTO is "MM":
				BACKTO = _init_sub("1", "Q", "MM", "main_f", CWORKDIR)

			elif BACKTO is "DOC":
				BACKTO = _init_sub("2", "MM", "DOC", "doc_f", CWORKDIR)
			
			elif BACKTO is "AB":
				BACKTO = _init_sub("3", "MM", "DOC", "about_f", CWORKDIR)
			
			elif BACKTO is "PORT_M":
				BACKTO = _init_sub("7", "SM", "PORT_M", "portage_men_f", CCONFDIR)
			
			elif BACKTO is "CAT_M":
				BACKTO = _init_sub("10", "SM", "CATA_M", "catalyst_f", CCONFDIR)

			elif BACKTO is "SM":
				BACKTO = _init_sub("6", "BSM", "SM", "bs_f", CWORKDIR)

			elif BACKTO is "BSM":
				BACKTO = _init_sub("5", "MM", "BSM", "bs_menu_f", CWORKDIR)

			elif BACKTO is "CO_F":
				BACKTO = _init_sub("8", "BSM", "CO_F", "config_f", CCONFDIR)

			elif BACKTO is "SELDEF":
				BACKTO = _init_sub("9", "BSM", "SELDEF", "selectdef_f", CWORKDIR)

			elif BACKTO is "GSET":
				BACKTO = _init_sub("11", "MM", "GSET", "gse_t", CWORKDIR)

			elif BACKTO is "CONTR":
				BACKTO = _init_sub('', "MM", "CONTR", "controller_f", CWORKDIR)

			elif BACKTO is "Q":
				break


	_main_loop("MM", CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR)

	return 0



