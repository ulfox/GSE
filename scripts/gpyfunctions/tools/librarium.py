#!/usr/bin/env python3.4

gse_des = '''\
		-----------------------------------------------------------------

		GSE: This project was built under GSoC 2017 for Gentoo Fundation. 
		For more informations see man gse.5 or the project's wiki at: 
		https://wiki.gentoo.org/wiki/User:Ulfox/GSoC-GSE

		-----------------------------------------------------------------

		System: For system menu, run: gse system -h
		Controller: For controller menu, run: gse controller -h
		'''
gse_usage="%(prog)s system --base=[precomp/catalyst] [options] / controller [options] / [-h/--help]"

gse_ver = '%(prog)s Experimental'

# System arguments
def _export_args(sequence):
	'''
	Here all project's arguments and options are defined.

	The definition has 4 phases.
		On phase 1 the general project's arguments and options are defined.
		On phase 2 the special arguments and options are defined, based on the sequence that is given.
		On phase 3 special sub-options are defined. Those options are enabled only from some special options.
		Last, on phase 4, everything is evaluated and returned back the the parent function.
	'''

	# Library for arguments and options parse
	import argparse
	from sys import argv
	
	# Definition of name, usage and description for the options menu
	parser = argparse.ArgumentParser(prog="gse",
		formatter_class=argparse.RawDescriptionHelpFormatter,
		description=gse_des,
		usage=gse_usage,
		epilog="For more information about each option, please see man gse.1 " + 
		"This program is distributed under GPL-2 license",
		add_help=True)

		# Dev opt
	parser.add_argument('--dev',
		help="Marked for removal. Removes all kind of checks. Never run this with super user privileges. It exists only for the experimental developing phase.",
		action="store_true",
		default=False)

	parser.add_argument("target",
		help="Initiate either system or controller scripts. [system/controller] ",
		action="store",
		default=None)

	parser.add_argument("--gmm",
		help="GUI Menu",
		action="store_true",
		default=False)

	parser.add_argument("--mm",
		help="Text Menu",
		action="store_true",
		default=False)

	# Time-warp option
	parser.add_argument('--timewarp', '--time-warp',
		help="Load and execute a saved state. A state is the set of configuration files and arguments that were saved at a given time.",
		action="store",
		type=int)

	# Time-state option
	parser.add_argument('--timestate', '--time-state',
		help="Create, list, set, save and delete configuration states. \
		Syntax: --time-state [save/list/set/delete] [name/-/N/N]",
		action="store",
		default='no',
		nargs='+',
		type=str)

	# No check option
	parser.add_argument('--nochecks', '--no-checks',
		help="Disable all \"simple\" checks. The process will be enabled without requesting a return 0 from the system check function.",
		action="store_true",
		default=False)

	# Keep optional argument.
	parser.add_argument('-k', '--keep',
		help='''Save to backup old work, instead of purging / reconfiguring an old entry. This option does not work with force.''',
		action="store_true",
		default=False)

	# Health check argument
	parser.add_argument('-hc', '--healthcheck', '--health-check',
		help='''Run integrity check for the project's scripts and essential configuration files''',
		action="store_true",
		default=False)

	# Replace new argument
	parser.add_argument('-rpn', '--replacenew', '--replace-new',
		help='''Refresh all the project's scripts and configuration files.
		Warning: All user configuration files will be lost''',
		action="store_true")

	# Minimal build
	parser.add_argument('-bm', '--minimal', '--build-minimal',
		help="""Enable minimal build. This option removes and disables many features. All images under this flag are configured for size.""",
		action="store_true",
		default=False)

	# Verbose option
	parser.add_argument('-v', '--verbose',
		help="Enable verbose output for all actions.",
		action='count')

	# Quiet option
	parser.add_argument('-q', '--quiet',
		help="Enable quiet global flag. This flag suppresses all output with a simple text entry regarding the action.",
		action="store_true",
		default=False)

	# Version
	parser.add_argument('-V', '--version',
		help="Show project's version and exit.",
		action='version',
		version=gse_ver)

	if sequence == 'system':
		# Base definition. While base appears to be optional, it is not, since it's always required to initiate the building sequence
		parser.add_argument('-b', '--base',
			help='''Set the system's fundation. See man gse.1 for more.''',
			action="store",
			type=str,
			default='catalyst')

		# Force new optional argument
		parser.add_argument('-fcn', '--forcenew', '--force-new',
			help='''Enable force to all project's actions. This option purges all previous work done. Not recommended!''',
			action="store_true",
			default=False)

		# Fetch new optional argument
		parser.add_argument('-fn', '--fetchnew', '--fetch-new',
			help="Enable fetch option. Will always download requested files, even if they exist and are up to date.",
			action="store_true",
			default=False)

		# Script's check argument
		parser.add_argument("--sdir",
			help="Give the directory that hosts the scripts. See man gse.1 for more informations.",
			action="store",
			default=None,
			type=str)
		
		for _tmp1 in argv[:]:
			if '--sdir' in str(_tmp1):
				parser.add_argument("--do",
					help="Scripts to be sourced. For the same hook the given order applies to priority.",
					action="store",
					default=None,
					type=str)

				parser.add_argument("--ghook",
					help="Hooks with priority for given scripts.",
					action="store",
					default=None,
					type=str)

		# Disable kernel build optional argument
		parser.add_argument('-ke', '--kernel',
			help='''Enable kernel build action inside the chroot phase''',
			action="store_true",
			default=False)

		# Disable initramfs build optional argument
		parser.add_argument('-i', '--initrd',
			help='''Enable initramfs build action inside the chroot phase''',
			action="store_true",
			default=False)

		# Enable automatic mode.
		parser.add_argument('--auto',
			help="Enable automatic mode. All prompt actions will turn to yes/continue.",
			action="store_true",
			default=False)

		# Enforce arguments
		parser.add_argument('--enforce',
			help="Enforce (force) a specific Part of the process. More about stages and parts at man gse.5",
			action="store",
			default=None,
			type=str)

		# Lawful-good arguments
		parser.add_argument('--lawfulgood', '--lawful-good',
			help="Lawful good (pass) a specific Part of the process. More about stages and parts at man gse.5",
			action="store",
			default=None,
			type=str)

		# Distcc
		parser.add_argument('--distcc',
			help="Enable distcc mode for the system build process. For pump, give --distcc=pump. See man 5 gse for more informations.",
			action="store",
			default=None,
			type=str)

		# Ccache
		parser.add_argument('--ccache',
			help="Enable ccache for the system build process.",
			action="store_true",
			default=False)

		# Edit configs option
		parser.add_argument('-e', '--edit',
			help='''Edit X:Y config. Where X is the category and Y is the file. See man gse.1 for more informations''',
			action="store",
			type=str)

	elif sequence == 'controller':
		# Build the controller option
		parser.add_argument('-bc', '--controller', '--build-controller',
			help='''Request the initramfs-controller image. Not to confuse with the --initrd. See man gse.1 for more informations.''',
			action="store_true",
			default=False)

		# Force option
		parser.add_argument('--force',
			help="Enable Dracut's force flag. The option is for simplicity over --dracut_opt=-f",
			action="store_true",
			default=False)

		# Hook script option
		parser.add_argument('--hook',
			help="Add custom scripts to Dracut hook points. Use this for simple scripts instead of creating new modules.",
			action="store",
			default=None,
			type=str)

		# Net script option
		parser.add_argument('--net',
			help="Import a custom net script to be sourced before initiating the controller scripts. That is after udev has finished.",
			action="store",
			default=None,
			type=str)

		# Module config
		parser.add_argument('--modules',
			help="Import a custom module config file under /etc/modprobe.d with name umod.conf.",
			action="store",
			default=None,
			type=str)

		# Dracut's option cmdline
		parser.add_argument('--dracut_opt',
			help="Include extra options for dracut. For more info see man dracut",
			action="store",
			default=None,
			type=str)

	args = parser.parse_args()

	del parser
	del argparse

	return args


# Check system's arguments
def _check_args(args):
	'''
	This function is directly related to the _export_args function.
		The purpose of this function is to check given options and arguments and either give a pass or kill the process.
			The pass/kill is defined from conditions that are not allowed to be executed simultaneously or they are either
			missing or holding an invalid entry.
			
			Example 1: for --enforce gccat. This will kill the process, since gccat is not defined as one of the building hooks.
			Example 2: for --sdir ~/my_scripts --do sc1:sc2:sc3 --ghook -gseed:+gportage:. Here the scripts are more than the hooks.
	'''

	# Libraries for
	import os
	from sys import argv
	from gpyfunctions.tools.gseout import die, e_report, b_report

	# Opt conditions
	def _opt_cond(args):
		'''
		Check if there are enabled options that "collide" with each other.
		If yes, issue a warning or die if the "collision" is significant.
		'''

		if args.quiet and not args.verbose == None:
		  	die("Error: Quiet and Verbose can not be used at the same time")

		if args.forcenew and args.keep:
		 	die("Error: Force new can not be used with keep")

		if args.edit and not len(argv[1:]) == 2:
			die("Invalid options for --edit. Edit can only be used alone as option. Please give only the related XY number.")

		if args.forcenew and not args.lawfulgood == None:
			die("Warning: --force-new suppresses --lawful-good")
		
		if not args.lawfulgood  == None and not args.enforce == None:
			e_report("Warning: --lawful-good suppresses --enforce")

		if args.healthcheck and not len(argv[1:]) == 1:
			die("Warning: --health-check unknown parameters")

		if args.replacenew and not len(argv[1:]) == 1:
			die("Warning: --replace-new unknown parameters")

		# Issue warning if minimal and enforce with ginst or gkernel or gintrid are enabled simultaneously
		if args.minimal:
			_minimal_exclude = [ "ginst", "gkernel", "gintrid"]

			for i in _minimal_exclude[:]:
				if i in args.enforce[:] and args.minimal:
					e_report("Warning: --build-minimal suppresses " + i)

			del _minimal_exclude

	# Call opt conditions
	_opt_cond(args)

	del _opt_cond

	def _hook_set():
		'''
		Here are defined the hooks of the system build process.
		'''

		# Create set with valid hook entries
		__set = {"gfund", "gseed", "gcat", "gextr", "gprec", "gparta", "gupdate", "gportage", "grebuild", "gsnap"}
		__set.add("gconfigure")
		__set.add("ginst")
		__set.add("grun")
		__set.add("gkernel")
		__set.add("ginitrd")
		__set.add("gdes")
		__set.add("gpartb")
		__set.add("gclean")
		
		return __set

	# Check if --base=[catalyst/precomp]
	if args.base == 'catalyst' or args.base == 'precomp':
		e_report("System base set to: " + args.base)
	else:
		die("Wrong base entry. Please give either 'catalyst' or 'precomp'")

	# Export enforce hook point entries
	if not args.enforce == None:
		en_args = args.enforce

		args.enforce = []
		args.enforce = [x.strip() for x in en_args.split(':')]
		
		del en_args

		# Export default hook entries
		_args_set = _hook_set()

		for _tmp1 in args.enforce[:]:
			if not _tmp1 in _args_set:
				die("Enforce: " + _tmp1 + " is not a valid hook point")

		del _args_set, _tmp1

		# Print enforce hooks
		e_report("Enforce enabled")
		print("\033[0;34m	Hooks:", "\033[0;33m", end='')
		print(*args.enforce)
		print("\033[0;0m")

	
	# Export lawful-good hook point entries
	if not args.lawfulgood == None:
		lg_args = args.lawfulgood
	
		args.lawfulgood = []
		args.lawfulgood = [x.strip() for x in lg_args.split(':')]
	
		del lg_args

		# Export default hook entries
		_args_set = _hook_set()
		
		for _tmp1 in args.lawfulgood[:]:
			if not _tmp1 in _args_set:
				die("Lawful-good: " + _tmp1 + " is not a valid hook point")

		del _args_set, _tmp1

		# Print lawful-good hooks
		e_report("Lawful enabled")
		print("\033[0;34m	Hooks:", "\033[0;33m", end='')
		print(*args.lawfulgood)
		print("\033[0;0m")

	# Script's --sdir checks
	if not args.sdir == None:
		if not os.path.isdir(args.sdir):
			die("Sdir's location is not a directory")

		# Check if --do option has been given.
		if not args.do == None:
			do_args = args.do

			args.do = []
			args.do = [x.strip() for x in do_args.split(':')]

			del do_args

			# Check if given scripts exist
			for i in args.do:
				__sdir= (args.sdir + '/')
				__is_file = (__sdir + i)

				if not os.path.isfile(__is_file):
					die("The file " + i + " does not exist. " + "Please be sure that " + args.sdir + " is the correct directory that hosts the scripts.")

				del __is_file, __sdir

			# Count the number of scripts to compare them with the number of hook points later
			do_nargs = len(args.do[:])

		else:
			# Issue error for missing --do
			die("Scripts: --do script1:script2:...:scriptN are missing")

		# Check if --ghook option has been given
		if not args.ghook == None:
			ghook_args = args.ghook

			args.ghook = []
			args.ghook = [x.strip() for x in ghook_args.split(':')]

			del ghook_args

			# Check if given hook entries have a priority mark, issue warning and die otherwise
			for _tmp1 in args.ghook[:]:
				if _tmp1[0] != '-' and _tmp1[0] != '+':
					die("Please give - or + at the beginning of each hook. See gse.1 and gse.5 for more informations and examples.")

					del _tmp1

			# Export default hook entries
			_args_set = _hook_set()

			# Check if the given entries are valid entries
			for _tmp1 in args.ghook[:]:
				if not _tmp1[1:] in _args_set:
					die("Enforce: " + _tmp1 + " is not a valid hook point")
			
			del _tmp1, _args_set

			# Count ghook entries
			ghook_nargs = len(args.ghook[:])
			
			# Compare if scripts have equal hook points
			if do_nargs == ghook_nargs:
				del ghook_nargs, do_nargs

			else:
				# Die if scripts are not equal to hook points and vice versa
				die("Number of hook point entries does not match the number of given scripts")

		else:
			# Die for missing
			die("Hook points are missing: --ghook [+-]hook1:[+-]hook2:...:[+-]hookN:")


		# Print the args.sdir, *args.do and *args.ghook
		e_report("Scripts enabled")
		print("\033[0;34m	Directory: ", "\033[0;33m", end='')
		print(args.sdir)
		print("\033[0;34m	Scripts: ", "\033[0;33m", end='')
		print(*args.do)
		print("\033[0;34m	Hooks: ", "\033[0;33m", end='')
		print(*args.ghook)
		print("\033[0;0m")

	del die, argv, e_report, b_report


# Check controller's arguments
def _ct_check_args(args):
	'''
		This function checks the controller arguments.

		Compared to the _export_args, while similar, this is more simple, since
		Most of the controller flags are true/false entries and those that are not, are simple
		input file entries.
	'''

	pass






