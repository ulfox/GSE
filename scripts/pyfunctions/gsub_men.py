#!/usr/bin/env python3.6

def _call_sub(*args):
	from gseout import report_colors, e_report, b_report
	from sys import exit
	from preliminary import portalin
	
	def main_f(*args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# Call builder submenu
			_sub_call = {"_CHILD": "BSM"}
		
		elif SELCT in ['II', 'ii', '2']:
			# Call controller submenu
			_sub_call = {"_CHILD": "CONTR"}

		elif SELCT in ['III', 'iii', '3']:
			# GSE renew submenu
			_sub_call = {"_CHILD": "GSET"}

		elif SELCT in ['IV', 'iv', '4']:
			# Call documentation submenu
			_sub_call = {"_CHILD": "DOC"}

		elif SELCT	in ['V', 'v', '5']:
			# Call about submenu
			_sub_call = {"_CHILD": "AB"}

		elif SELCT in ['VI', 'vi', '6', 'q', 'Q']:
			e_report("Exiting...")
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def gse_t(*args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			pass
			exit(0)

		elif SELCT in ['II', 'ii', '2']:
			pass
			exit(0)

		elif SELCT in ['III', 'iii', '3']:
			# Version check
			# import version check function here
			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def bs_menu_f(*args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# Call build system submenu
			_sub_call = {"_CHILD": "SM"}

		elif SELCT in ['II', 'ii', '2']:
			# Call configuration submenu
			_sub_call = {"_CHILD": "CO_F"}

		elif SELCT in ['III', 'iii', '3']:
			# CALL SELECT DEFAULT SYSTEM SUBMENU
			_sub_call = {"_CHILD": "SELDEF"}

		elif SELCT in ['IV', 'iv', '4']:
			# TBU: WILL INCLUDE A STAGE4 TARBALL CREATION
			_sub_call = {"_STAY": 0}

		elif SELCT	in ['V', 'v', '5']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def bs_f(*args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# CALL PORTAGE SUBMENU)
			_sub_call = {"_CHILD": "PORT_M"}

		elif SELCT in ['II', 'ii', '2']:
			# CALL CATALYST SUBMENU
			_sub_call = {"_CHILD": "CATA_M"}

		elif SELCT in ['III', 'iii', '3']:
			# START PRE PRECOMPILED
			# import warp "--base=precomp" "args" here
			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def portage_men_f(CCONFDIR, *args):
		from subprocess import call

		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# Make make.conf: Automatic or guided configuration
			_ex_stat = makeconf_ed

			if _ex_stat == 0:
				print(report_colors.YELLOW + "[ * ]" + report_colors.RESET + "Configuration was successful")
			else:
				print(report_colors.SRED + "[ * ]" + report_colors.RESET + "Something went wrong")

			del _ex_stat

			_sub_call = {"_STAY": 0}
		
		elif SELCT in ['II', 'ii', '2']:
			# Edit of make.conf
			call(["vim", CCONFDIR + "/system/portage/make.conf"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			# Edit features
			call(["vim", CCONFDIR + "/system/coptions"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			# Edit distcc's hosts
			call(["vim", CCONFDIR + "/system/hosts"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT	in ['V', 'v', '5']:
			# Edit USEFLAGS
			call(["vim", CCONFDIR + "/system/portage/package.use/sysbuild"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['VI', 'vi', '6']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT, call

		return _sub_call


	def catalyst_f(CCONFDIR, args):
		from subprocess import call

		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# Edit catalyst.conf
			call(["vim", CCONFDIR + "/system/catalyst/catalyst.conf"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}
		
		elif SELCT in ['II', 'ii', '2']:
			# Edit catalystrc
			call(["vim", CCONFDIR + "/system/catalyst/catalystrc"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			# Edit stage1.spec
			call(["vim", CCONFDIR + "/system/catalyst/stage1.spec"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			# Edit stage2.spec
			call(["vim", CCONFDIR + "/system/catalyst/stage2.spec"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT	in ['V', 'v', '5']:
			# Edit stage3.spec
			call(["vim", CCONFDIR + "/system/catalyst/stage3.spec"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['VI', 'vi', '6']:
			# Initiate system build
			#warp "--base=catalyst" "${lppar[@]}"
			_sub_call = {"_STAY": 0}

		elif SELCT in ['VII', 'vii', '7']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT, call

		return _sub_call


	def config_f(CCONFDIR, *args):
		from subprocess import call

		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			# Marked for removal
			#drv_interface

			_sub_call = {"_STAY": 0}
		
		elif SELCT in ['II', 'ii', '2']:
			# Edit fstab
			call(["vim", CCONFDIR + "/system/fstab"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			# Edit devname.info
			call(["vim", CCONFDIR + "/system/devname.info"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			# Edit hostname
			call(["vim", CCONFDIR + "/system/hostname"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT	in ['V', 'v', '5']:
			# Edit conf.d/net
			call(["vim", CCONFDIR + "/system/net"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['VI', 'vi', '6']:
			# Edit locale
			call(["vim", CCONFDIR + "/system/locale.gen"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['VII', 'vii', '7']:
			# Edit consolefont
			call(["vim", CCONFDIR + "/system/consolefont"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['VIII', 'viii', '8']:
			# Edit sshd_config
			call(["vim", CCONFDIR + "/system/sshd"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IX', 'ix', '9']:
			# Edit id_rsa.pub
			call(["vim", CCONFDIR + "/system/ssh.pub"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['X', 'x', "10"]:
			# Edit system links
			call(["vim", CCONFDIR + "/system/system_links"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XI', 'xi', '11']:
			# Edit custom scripts
			call(["vim", CCONFDIR + "/system/custom_scripts"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XII', 'xii', '12']:
			# Edit custom package list
			call(["vim", CCONFDIR + "/system/custom_pacl"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XIII', 'xiii', '13']:
			# Edit /etc/default/grub
			call(["vim", CCONFDIR + "/system/grub"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XIV', 'xiv', '14']:
			# Edit runlevels
			call(["vim", CCONFDIR + "/system/runlevels"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XV', 'xv', '15']:
			# Edit files
			call(["vim", CCONFDIR + "/system/inject_files"], stdout=None, stderr=None)

			_sub_call = {"_STAY": 0}

		elif SELCT in ['XVI', 'xvi', '16']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT, call

		return _sub_call


	def selectdef_f(*args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			_sub_call = {"_STAY": 0}

		elif SELCT in ['II', 'ii', '2']:
			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def doc_f(CWORKDIR, *args):
		from subprocess import call

		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			call(["man", CWORKDIR + "/docs/documentations/overview_gse.5"])
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['II', 'ii', '2']:
			call(["man", CWORKDIR + "/docs/documentations/overview_controller.5"])
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			call(["man", CWORKDIR + "/docs/documentations/overview_config.d.5"])
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			call(["man", CWORKDIR + "/docs/documentations/overview_scripts.5"])
			portalin("_key")
			
			_sub_call = {"_STAY": 0}

		elif SELCT in ['V', 'v', '5']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT, call

		return _sub_call


	def about_f(CWORKDIR, *args):
		SELCT = portalin("_input")

		if SELCT in ['I', 'i', '1']:
			e_report("About submenu option a)")
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['II', 'ii', '2']:
			e_report("About submenu option b)")
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['III', 'iii', '3']:
			e_report("About submenu option c)")
			portalin("_key")

			_sub_call = {"_STAY": 0}

		elif SELCT in ['IV', 'iv', '4']:
			_sub_call = {"_PARENT": 0}

		elif SELCT in ['t', 'T']: 
			from preliminary import _shell
			_shell()

			_sub_call = {"_STAY": 0}

			del _shell

		del SELCT

		return _sub_call


	def controller_f(*args):
		e_report("Initiating controller build")

		_sub_call = {"_PARENT": 0}

		return _sub_call

	_sub_call = eval(args[0]+'(args[1])')
	
	del portalin, report_colors, e_report, b_report, exit

	return _sub_call



