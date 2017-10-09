#!/usr/bin/env python3.4

# Initiates the text main menu loop
def _call_menu(CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR):
	'''
	Imports important porject's directories and initiates the text's menu loop
	'''

	from gpyfunctions.menu.txmen.gsub_men import _call_sub
	from gpyfunctions.menu.txmen.gsetxmen import _men_opt
	from gpyfunctions.preliminary import _clear

	# _init_sub initiated the requested sub_menu and its functions
	def _init_sub(men, bpar, spar, ccal, *args):
		'''
		_init_sub initiated the requested sub_menu and its functions
			men: menu entry to be printed
			bpar: which is the parent of men
			spar: relates men with case (if conditions) about the current men
			ccal: the function that will be executed after the menu has been printed
			*args: additional arguments for the functions that are called.
		'''

		try:
			del _sub_call

			c = [_PARENT, _CHILD, _STAY]
		
			for i in c[:]:
				del i
		
		except NameError:
			pass

		while True:
			# Clear screen then print the related menu
			_clear()
			_men_opt(men)

			try:
				# Call the related function
				_sub_call = _call_sub(ccal, *args)

			except KeyboardInterrupt:
				from gpyfunctions.tools.gseout import e_report
				e_report("\n\nKeyboard interrupt detected.\n")
				exit(1)
				
			except EOFError:
				from gpyfunctions.tools.gseout import b_report
				b_report("\n\nEOFError. Maybe CTRL-D?\nIf not, please report this bug!\n")
				exit(1)

			# Check if the menu entry was a valid one
			if _sub_call is "err":
				pass

			else:
				# For valid entry, set _PARENT, _CHILD OR _STAY
				# _PARR requests the parent menu of the sub-menu
				# _CHILD calls for a child = {NAME} sub-menu
				# _STAY requests the same menu
				for k, v in _sub_call.items():
					if k is "_PARENT" and v == 0:
						BACKTO = bpar

					elif k is "_CHILD":
						BACKTO = v

					elif k is "_STAY" and v == 0:
						BACKTO = spar
					
				return BACKTO

	# Main menu loop function
	def _main_loop(minit, CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR):
		'''
		Main menu loop function
		This function simply reads the BACKTO from the _init_sub function and executes
		the return menu.
		See _init_sub above for the given variables.
		'''

		BACKTO = minit

		while True:
			# Main menu
			if BACKTO is "MM":
				BACKTO = _init_sub("1", "Q", "MM", "main_f", CWORKDIR)

			elif BACKTO is "DOC":
				# Documentation menu
				BACKTO = _init_sub("2", "MM", "DOC", "doc_f", CWORKDIR)
			
			elif BACKTO is "AB":
				# About menu
				BACKTO = _init_sub("3", "MM", "AB", "about_f", CWORKDIR)
			
			elif BACKTO is "PORT_M":
				# Portage menu
				BACKTO = _init_sub("7", "SM", "PORT_M", "portage_men_f", CCONFDIR)
			
			elif BACKTO is "CATA_M":
				# Catalyst menu
				BACKTO = _init_sub("10", "SM", "CATA_M", "catalyst_f", CCONFDIR)

			elif BACKTO is "SM":
				# Builder menu
				BACKTO = _init_sub("6", "BSM", "SM", "bs_f", CWORKDIR)

			elif BACKTO is "BSM":
				# System menu
				BACKTO = _init_sub("5", "MM", "BSM", "bs_menu_f", CWORKDIR)

			elif BACKTO is "CO_F":
				# Controller menu
				BACKTO = _init_sub("8", "BSM", "CO_F", "config_f", CCONFDIR)

			elif BACKTO is "SELDEF":
				# Select defaults menu
				BACKTO = _init_sub("9", "BSM", "SELDEF", "selectdef_f", CWORKDIR)

			elif BACKTO is "GSET":
				# GSE tools menu
				BACKTO = _init_sub("11", "MM", "GSET", "gse_t", CWORKDIR)

			elif BACKTO is "CONTR":
				# Controller
				BACKTO = _init_sub('', "MM", "CONTR", "controller_f", CWORKDIR)

			elif BACKTO is "Q":
				break
			else:
				_parameter_error()


	_main_loop("MM", CWORKDIR, CFUNCTIONS, CCONFDIR, CDISTDIR)

	return 0




