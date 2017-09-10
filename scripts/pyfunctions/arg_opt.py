#!/usr/bin/env python3.6

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
	# Library for arguments and options parse
	import argparse
	
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

		# Keep optional argument.
		parser.add_argument('-k', '--keep',
			help='''Enable gse keep old work instead of purging / reconfiguring. This option does not work with force''',
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

		# Disable kernel build optional argument
		parser.add_argument('-ke', '--kernel',
			help='''Disable kernel build action inside the chroot phase''',
			action="store_true",
			default=False)

		# Disable initramfs build optional argument
		parser.add_argument('-i', '--initrd',
			help='''Disable initramfs build action inside the chroot phase''',
			action="store_true",
			default=False)

		# Enable automatic mode.
		parser.add_argument('--auto',
			help="Enable automatic mode. All prompt actions will turn to yes/continue.",
			action="store_true",
			default=False)

		# Minimal build
		parser.add_argument('-bm', '--minimal', '--build-minimal',
			help="""Enable minimal build. This option removes and disables many features. The system image configured for size.""",
			action="store_true",
			default=False)

		# Enforce arguments
		parser.add_argument('--enforce',
			help="Enforce (force) a specific Part of the process. More about stages and parts at man gse.5",
			action="store",
			nargs='+',
			default=None,
			type=str)

		# Lawful-good arguments
		parser.add_argument('--lawfulgood', '--lawful-good',
			help="Lawful good (pass) a specific Part of the process. More about stages and parts at man gse.5",
			action="store",
			nargs='+',
			default=None,
			type=str)

		# Time-warp option
		parser.add_argument('--timewarp', '--time-warp',
			help="Load and execut a saved state. A state is the set of configuration files and arguments that were saved at a given time.",
			action="store",
			type=int)

		# Time-state option
		parser.add_argument('--timestate', '--time-state',
			help="Create a state. The state can be initiated by time-warp function.",
			action="store",
			default='no',
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

		# No check option
		parser.add_argument('--nochecks', '--no-checks',
			help="Disable all checks. The process will be enabled without requesting a return 0 from the system check function.",
			action="store_true",
			default=False)

		# Edit configs option
		parser.add_argument('-e', '--edit',
			help='''Edit X:Y config. Where X is the category and Y is the file. See man gse.1 for more informations''',
			action="store",
			type=str)

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

		# Version
		parser.add_argument('-V', '--version',
			help="Show project's version and exit.",
			action='version',
			version=gse_ver)

	args = parser.parse_args()

	del parser
	del argparse

	return args


# Check system's arguments
def _check_args(args):
	# Libraries for
	from sys import argv
	from gseout import die, e_report

	if args.quiet and not args.verbose == None:
	  	die("Error: Quiet and Verbose can not be used at the same time")

	if args.forcenew and args.keep:
	 	die("Error: Force new can not be used with keep")

	if args.edit and not len(argv[2:]) == 1:
		die("Invalid options for --edit. Please give only the related XY number.")

	if args.forcenew and not args.lawfulgood == None:
		die("Warning: --force-new suppresses --lawful-good")
	
	if not args.lawfulgood  == None and not args.enforce == None:
		e_report("Warning: --lawful-good suppresses --enforce")

	if args.healthcheck and not len(argv[1:]) == 1:
		die("Warning: --health-check unknown parameters")

	if args.replacenew and not len(argv[1:]) == 1:
		die("Warning: --replace-new unknown parameters")

	if args.base == 'catalyst' or args.base == 'precomp':
		e_report("System base saved for " + args.base)
	else:
		die("Wrong base entry. Please give either 'catalyst' or 'precomp'")

	# Export enforce hook point entries
	if not args.enforce == None:
		en_args = args.enforce[0]
		args.enforce = []
		args.enforce = [x.strip() for x in en_args.split(':')]
		del en_args
	
	# Export lawful-good hook point entries
	if not args.lawfulgood == None:
		lg_args = args.lawfulgood[0]
		args.lawfulgood = []
		args.lawfulgood = [x.strip() for x in lg_args.split(':')]
		del lg_args

	# Issue warning if minimal and enforce with ginst or gkernel or gintrid are enabled simultaneously
	if args.minimal:
		_minimal_exclude = [ "ginst", "gkernel", "gintrid"]

		for i in _minimal_exclude[:]:
			if i in args.enforce[:] and args.minimal:
				e_report("Warning: --build-minimal suppresses " + i)

		del _minimal_exclude



	del die, argv, e_report


# Check controller's arguments
def _ct_check_args(args):
	pass






