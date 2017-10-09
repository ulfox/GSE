#!/usr/bin/env python3.4

from sys import exit

# Output colors
class report_colors:
	'''
	Class that defines and saves various color formats
	'''

	SRED   = "\033[0;31m"  
	LRED   = "\033[1;31m"
	BLUE  = "\033[0;34m"
	YELLOW = "\033[0;33m"
	CYAN  = "\033[1;36m"
	GREEN = "\033[0;32m"
	PURPLE = "\033[2;35m"
	RESET = "\033[0;0m"

# Die function
def die(error):
	'''
	Print red error and kill the process
	'''

	print(report_colors.SRED + error + report_colors.RESET)
	exit(1)

# Red report function
def lr_report(report):
	'''
	Print a light red warning
	'''

	print(report_colors.LRED + report + report_colors.RESET)

# Yellow report function
def e_report(report):
	'''
	Print a yellow warning
	'''

	print(report_colors.YELLOW + report + report_colors.RESET)

# Blue report function
def b_report(report):
	'''
	Print a blue warning
	'''

	print(report_colors.BLUE + report + report_colors.RESET)

# Green report function
def g_report(report):
	'''
	Print a green warning
	'''

	print(report_colors.GREEN + report + report_colors.RESET)

# Purpule report function
def p_report(report):
	'''
	Print a purple warning
	'''

	print(report_colors.PURPLE + report + report_colors.RESET)








