#!/usr/bin/env python3.4

# Time state function
def time_state(args, CWORKDIR, CCONFDIR, CLOCALLG):
	'''
	Time sate function.
		Saves a state of configuration files + options + arguments for later use
		Lists the saved states
		Sets a state as a default state. The state must exist before this option is used
		Deletes a saved state from the list
	'''

	import os
	import datetime
	from gpyfunctions.tools.gseout import die, e_report, b_report, lr_report
	
	# Create state directory, for hosting the state entries
	if not os.path.exists(CLOCALLG + "/states"):
		os.makedirs(CLOCALLG + "/states")

	# Save a state
	if args.timestate[0] == "save":
		
		# Check if state name has been given, die if not
		try:
			if args.timestate[1]:
				pass

			# Counter for the states mark
			k = 1
			# Export directory's contents to a state list
			_tmp_state_list =os.listdir(CLOCALLG + "/states/")

			# Define state's mark (k) value
			for _tmp1 in _tmp_state_list[:]:
				try:
					if k < 10:
						if str(k) == _tmp1[0:1]:
							k += 1

					elif k >= 10:
						if str(k) == _tmp1[0:2]:
							k += 1

				except IndexError:
					break
			
			del _tmp_state_list

			try:
				del _tmp1

			except NameError:
				pass

			# Date and time
			_state_date = str(datetime.datetime.today().strftime("date-%Y-%m-%d-time-%H-%M"))
			
			del datetime

			# Check if the state directory is indeed missing then create it. Issue warning and die otherwise
			if not os.path.exists(CLOCALLG + "/states/" + str(k) + "_" + args.timestate[1] + "-" + _state_date):
				os.makedirs(CLOCALLG + "/states/" + str(k) + "_" + args.timestate[1] + "-" + _state_date)
				# Text report
				print("\033[0;33mCreated state entry:", "\033[0;33m", end='')
				print("\033[0;34m" + str(k) + "_" + args.timestate[1] + "-" + _state_date)

			else:
				die("Can not create state: " + args.timestate[1] + ", because the state already exists")

		except IndexError:
			# Name has not been given, since 1 gives an index error
			die("Missing name for --time-state save")

		
		# Full path and state name
		_abs_state_name = (CLOCALLG + "/states/" + str(k) + "_" + args.timestate[1] + "-" + _state_date)
		_state_name = (str(k) + "_" + args.timestate[1] + "-" + _state_date)
			
		# Function for copying config.d/system directory
		def _copy_config_target(CCONFDIR, target, _abs_state_name):
			'''
			Copy either .../config.d/system or .../config.d/controller to the newly created state.
			The decision is based on the nature of the saved state. If it was called under the sequence=system variable,
			then system is copied and if it was called under the sequence=controller variable, then controller is copied.
			'''

			# Import shutil for enabling copy functionality
			import shutil

			try:
				# Copy the system directory
				shutil.copytree(CCONFDIR + '/' + target, _abs_state_name + '/' + target)
						
				# Text report
				print("\033[0;33m		Saving:", "\033[0;33m", end='')
				b_report("config.d/" + target + " to state")
					
			except FileNotFoundError:
				die("		File not found error. If config.d/system exists, please report this bug.")

			except FileExistsError:
				die("		File exists error. Please report the bug!")
	
			del shutil
		
		# System case
		if args.target == 'system':
			# Create main_flags file under state directory and make it writable
			with open(_abs_state_name + '/main_flags', 'w') as _s_entry:
				_system_entries = {}
				_system_entries["State name: "] = _state_name
				_system_entries["State target : "] = args.target
				_system_entries["System target: "] = args.base
				_system_entries["Auto: "] = args.auto
				_system_entries["Ccache: "] = args.ccache
				_system_entries["Dev: "] = args.dev
				_system_entries["Distcc: "] = args.distcc
				
				if args.enforce == None:
					_system_entries["Enforce: "] = args.enforce
				else:
					_system_entries["Enforce: "] = "Enabled"

				if args.lawfulgood == None:
					_system_entries["Lawful-good: "] = args.lawfulgood
				else:
					_system_entries["Lawful-good: "] = "Enabled"

				if args.sdir == None:
					_system_entries["Sdir :"] = args.sdir
					_system_entries["Do scripts :"] = "None"
					_system_entries["GHooks :"] = "None"
				else:
					_system_entries["Sdir : "] = "Enabled"
					_system_entries["Do scripts :"] = "Enabled"
					_system_entries["GHooks :"] = "Enabled"

				_system_entries["Fetch new: "] = args.fetchnew
				_system_entries["Force new: "] = args.forcenew
				_system_entries["Initrd: "] = args.initrd
				_system_entries["Keep: "] = args.keep
				_system_entries["Kernel: "] = args.kernel
				_system_entries["Minimal build: "] = args.minimal
				_system_entries["No checks: "] = args.nochecks
				_system_entries["Quiet :"] = args.quiet
				_system_entries["Verbose : "] = args.verbose

				# Write system enabled/disabled options
				for key, value in _system_entries.items():
					_s_entry.write(str(key) + str(value) + '\n')

				# Text report
				print("\033[0;33m	Saving:", "\033[0;33m", end='')
				b_report("Main options")

			if _s_entry.closed:
				del _s_entry
			else:
				_s_entry.close()
				del _s_entry

			# Write enforce entries
			if args.enforce != None:
				with open(_abs_state_name + '/enforce_hooks', 'w') as _e_entry:
					for i in range(len(args.enforce[:])):
						_e_entry.write("Hook " + str(i) + " : " + args.enforce[i] + '\n')

				if _e_entry.closed:
					del _e_entry
				else:
					_e_entry.close()
					del _e_entry
				
				del i

				# Text report
				print("\033[0;33m	Saving:", "\033[0;33m", end='')
				b_report("Enforce arguments")

			# Write lawful-good entries
			if args.lawfulgood != None:
				with open(_abs_state_name + '/lawfulgood_hooks', 'w') as _l_entry:
					for i in range(len(args.lawfulgood[:])):
						_l_entry.write("Hook " + str(i) + " : " + args.lawfulgood[i] + '\n')


				if _l_entry.closed:
					del _l_entry
				else:
					_l_entry.close()
					del _l_entry
				
				del i

				# Text report
				print("\033[0;33m	Saving:", "\033[0;33m", end='')
				b_report("Lawful-good arguments")

			# Write do scripts
			if args.sdir != None:
				# Import shutil for enabling copy functionality
				import shutil

				# Create doscripts file with write permissions
				with open(_abs_state_name + '/doscripts', 'w') as _do_entry:
					# Text report
					print("\033[0;33m	Configuring:", "\033[0;33m", end='')
					b_report("Do scripts")

					# Write the directory path
					_do_entry.write("Do scripts : Enabled" + '\n')
					_do_entry.write("Path : " + args.sdir +'\n')
						
					# Write the total number of scripts
					_do_entry.write('\n')
					_do_entry.write("Script's Num : " + str(len(args.do)) + '\n')

					# Create do_scripts directory to host the requested do scripts
					os.makedirs(_abs_state_name + '/do_scripts')

					# Write the requested scripts entries and copy the script files at do_scripts
					for i in range(len(args.do[:])):
						_do_entry.write("Requested Script " + str(i) + " : " + args.do[i] + '\n')

						try:
							shutil.copy2(args.sdir + '/' + args.do[i], _abs_state_name + '/do_scripts', follow_symlinks=True)

						except FileNotFoundError:
							die("File not found error. If the scripts exist, please report this bug.")

						except FileExistsError:
							die("File exists error. Please report the bug!")

					# Text report
					print("\033[0;33m		Saving:", "\033[0;33m", end='')
					b_report("Scripts to state")
						
					# Write the total hook's number. Must be equal to total script's number
					_do_entry.write('\n')
					_do_entry.write("Hook's Num : " + str(len(args.ghook)) + '\n')

					# Write the requested scripts entries and copy the script files at do_scripts
					for j in range(len(args.ghook[:])):
						_do_entry.write("Requested Hook-Point " + str(i) + " : " + args.ghook[j] + '\n')

					# Text report
					print("\033[0;33m		Saving:", "\033[0;33m", end='')
					b_report("Hooks to state")

					del i, j, shutil

				if _do_entry.closed:
					del _do_entry
				else:
					_do_entry.close()
					del _do_entry

			# Call system copy function
			_copy_config_target(CCONFDIR, "system", _abs_state_name)

			del _copy_config_target
		
		elif args.target == 'controller':
			# Create main_flags file under state directory and make it writable
			with open(_abs_state_name + '/main_flags', 'w') as _s_entry:
				_controller_entries = {}
				_controller_entries["State name: "] = _state_name
				_controller_entries["State target : "] = args.target
				_controller_entries["System target: "] = "None"
				_controller_entries["Build Controller: "] = args.controller
				_controller_entries["Force: "] = args.force
				_controller_entries["Dev: "] = args.dev
				_controller_entries["Keep: "] = args.keep
				_controller_entries["Minimal build: "] = args.minimal
				_controller_entries["No checks: "] = args.nochecks
				_controller_entries["Quiet :"] = args.quiet
				_controller_entries["Verbose : "] = args.verbose	

				if args.hook == None:
					_controller_entries["Hook scripts: "] = "None"
				else:
					_controller_entries["Hook scripts: "] = "Enabled"

				if args.net == None:
					_controller_entries["Net script: "] = "None"
				else:
					_controller_entries["Net script: "] = "Enabled"

				if args.modules == None:
					_controller_entries["Custom modules config: "] = "None"
				else:
					_controller_entries["Custom modules config: "] = "Enabled"

				if args.dracut_opt == None:
					_controller_entries["Dracut options: "] = "None"
				else:
					_controller_entries["Dracut options: "] = "Enabled"

				# Write system enabled/disabled options
				for key, value in _controller_entries.items():
					_s_entry.write(str(key) + str(value) + '\n')

				del _controller_entries, key, value

				if _s_entry.closed:
					del _s_entry
				else:
					_s_entry.close()
					del _s_entry

			# Call system copy function
			_copy_config_target(CCONFDIR, "controller", _abs_state_name)

		e_report("===========================================================================================")
		e_report("State has been saved. To refer at this state in the future, use --time-warp=[state's mark]")
		e_report("===========================================================================================")

	# List states
	elif args.timestate[0] == "list":
		try:
			if args.timestate[1]:
				print("\033[0;33mTime state:", "\033[0;33m")
				die("	Unknown " + args.timestate[1] + " option.")

		except IndexError:
			if os.path.isdir(CLOCALLG + "/states"):
				_list_states = os.listdir(CLOCALLG + "/states/")
			
				print("\033[0;33mStates list:", "\033[0;33m")			
				for i in _list_states[:]:
					b_report("	" + i)

				del _list_states, i

			else:
				print("\033[0;33mTime state:", "\033[0;33m")
				b_report("	Nothing to show. No state has been saved!")
	
	elif args.timestate[0] == 'set':
		try:
			if args.timestate[1]:
				pass

			if args.timestate[1] != '-':
				if os.path.isdir(CLOCALLG + "/states"):
					_list_states = os.listdir(CLOCALLG + "/states/")

					_list_marks = []
					for i in _list_states[:]:
						_list_marks.append(i[0])

					del _list_states, i
				
					for j in _list_marks[:]:
						if args.timestate[1] == j:
							_set_state = str(j)
							break
						else:
							_set_state = None

					del _list_marks, j

					if _set_state == None:
						print("\033[0;33mTime state:", "\033[0;33m")
						die("	No such a state mark.")
					else:
						try:
							os.remove(CLOCALLG + "/states/default")
						except FileNotFoundError:
							pass
					
						with open(CLOCALLG + "/states/default", 'w') as _set_default:
							_set_default.write("Default : " + _set_state + '\n')

						if _set_default.closed:
							del _set_default
						else:
							_set_default.close()
							del _set_default

						print("\033[0;33mTime state:", "\033[0;33m")
						b_report("	Default state has been set to: " + _set_state)
						del _set_state
				else:
					print("\033[0;33mTime state:", "\033[0;33m")
					die("	No state has been configured, hence none can be set.")

			elif args.timestate[1] == '-':
				if os.path.isfile(CLOCALLG + "/states/default"):
					os.remove(CLOCALLG + "/states/default")

				with open(CLOCALLG + "/states/default", 'w') as _set_default:
					_set_default.write("Default : None" + '\n')
					
					print("\033[0;33mTime state:", "\033[0;33m")
					b_report("	Default state has been unset")

				if _set_default.closed:
					del _set_default
				else:
					_set_default.close()
					del _set_default

		except IndexError:
			print("\033[0;33mTime state:", "\033[0;33m")
			die("	Error: missing mark [M]. To unset a default entry give \'-\' instead of mark. See man 1 gse.")
	
	elif args.timestate[0] == 'del':
		try:
			if args.timestate[1]:
				pass

			if os.path.isdir(CLOCALLG + "/states"):
				_list_states = os.listdir(CLOCALLG + "/states/")

				for i in _list_states[:]:
					if args.timestate[1] == i[0]:
						_del_state = str(i)
						break
					else:
						_del_state = None
				
				del _list_states, i

				if _del_state == None:
					print("\033[0;33mTime state:", "\033[0;33m")
					die("	State does not exist.")
				else:
					import shutil
					try:
						shutil.rmtree(CLOCALLG + "/states/" + _del_state, ignore_errors=False, onerror=None)
						print("\033[0;33mTime state:", "\033[0;33m")
						b_report("	State: " + _del_state + " has been deleted")
						del  shutil

					except FileNotFoundError:
						print("\033[0;33mTime state:", "\033[0;33m")
						die("	Error file not found. If the state exists, please report this bug.")

				del _del_state
			
			else:
				print("\033[0;33mTime state:", "\033[0;33m")
				die("	No state has been configured, hence none can be deleted.")

		except IndexError:
			die("Time-state: Error no state mark [M] was given")

	else:
		print("\033[0;33mTime state:", "\033[0;33m")
		die("	No valid option. Please give --time-state [save/list/set/del] [sstate_name/-/M/M]")


def warp(target, args, CWORKDIR, CCONFDIR, CLOCALLG):
	'''
	Warp function.
		This is function is the function that controls all actions that are made after a sequence has been set and enabled.
		Simply put, the _call_main function, which is the one initiated under the __init__ == __main__ condition, is only
		checking / exporting environmental variables before calling this warp.
	'''

	# Check the arguments
	if target is "system":
		# system arguments
		from gpyfunctions.tools.librarium import _check_args
		_check_args(args)

		del _check_args
		
	elif target is "controller":
		# controller arguments
		from gpyfunctions.tools.librarium import _ct_check_args
		_ct_check_args(args)

		del _ct_check_args
	
	# Call time state
	if args.timestate is not 'no':
		time_state(args, CWORKDIR, CCONFDIR, CLOCALLG)
	
	exit(1)
	return 0

# 	_auto_def_silence_def "$@"

# 	_flags_stagea+=("${_flag_base}")

# 	if [[ -n "${_flag_base}" ]]; then
# 			source "${CWORKDIR}/scripts/sinit" "${_flags_stagea[@]}"
# 	elif [[ -z "${_flag_base}" && -n "${_flag_fetch}" ]]; then
# 		_call_fetch_new "$@"
# 	fi

# 	# STAGE C
# }