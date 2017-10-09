#!/usr/bin/env python3.4

def _men_opt(_men_call):
	'''
	GSE text menu output.
		For a given function that is called, this function prints the entries / options of that function.
	'''
	
	from gpyfunctions.tools.gseout import report_colors

	if _men_call is '1':
		print("#####################  " + report_colors.CYAN + "~~Main Menu~~" + report_colors.RESET + "  ######################")
		print("##                                                        ##")
		print("## [ " + report_colors.GREEN + "I   " + report_colors.RESET + "]" + report_colors.YELLOW + " System Menu			   	          " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II  " + report_colors.RESET + "]" + report_colors.YELLOW + " Build the controller image			  " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III " + report_colors.RESET + "]" + report_colors.YELLOW + " GSE Tools					  " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV  " + report_colors.RESET + "]" + report_colors.YELLOW + " Documentations				  " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V   " + report_colors.RESET + "]" + report_colors.YELLOW + " About the project				  " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VI  " + report_colors.RESET + "]" + report_colors.YELLOW + " I shouldn't be here, please let me leave!	  " + report_colors.RESET + "##")
		print("##                                                        ##")
		print("## [ " + report_colors.GREEN + "T   " + report_colors.RESET + "]" + report_colors.GREEN + "				  Terminal	  " + report_colors.RESET + "##")
		print("############################################################")

	elif _men_call is "2":
		print("###################  " + report_colors.CYAN + "~~Documentations~~" + report_colors.RESET + "   ####################")
		print("##							    ##")
		print("## [ " + report_colors.GREEN + "I   " + report_colors.RESET + "]" + report_colors.YELLOW + " Introduction to GSE Directory		    " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II  " + report_colors.RESET + "]" + report_colors.YELLOW + " The Controller 				    " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III " + report_colors.RESET + "]" + report_colors.YELLOW + " The Config.d Directory		 	    " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV  " + report_colors.RESET + "]" + report_colors.YELLOW + " The script's Directory			    " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V   " + report_colors.RESET + "]" + report_colors.GREEN + " Main Menu 					    " + report_colors.RESET + "##")
		print("##							    ##")
		print("##############################################################")

	elif _men_call is "3":
		print("#######################  " + report_colors.CYAN + "~~About~~" + report_colors.RESET + "   ########################")
		print("##							   ##")
		print("## [ " + report_colors.GREEN + "I   " + report_colors.RESET + "]" + report_colors.YELLOW + " About the project				   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II  " + report_colors.RESET + "]" + report_colors.YELLOW + " Linux, Gentoo and the birth of an Idea	   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III " + report_colors.RESET + "]" + report_colors.YELLOW + " Open Source To The End and Beyond	 	   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV  " + report_colors.RESET + "]" + report_colors.GREEN + " Main Menu 					   " + report_colors.RESET + "##")
		print("##							   ##")
		print("#############################################################")

	elif _men_call is "5":
		print("####################  " + report_colors.CYAN + "~~System Menu~~" + report_colors.RESET + "   ###################")
		print("##						         ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " Built a System 		                 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure built variables			 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Select default system for distribution	 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV " + report_colors.RESET + "]" + report_colors.YELLOW + " Create a stage4 tarball			 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V  " + report_colors.RESET + "]" + report_colors.YELLOW + " Return back  					 " + report_colors.RESET + "##")
		print("##							 ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "				Terminal	 " + report_colors.RESET + "##")
		print("##							 ##")
		print("###########################################################")

	elif _men_call is "6":
		print("###################  " + report_colors.CYAN + "~~Builder~~" + report_colors.RESET + "   ##################")
		print("##						   ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " Portage		  	           " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Catalyst				   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Precompiled			   	   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV " + report_colors.RESET + "]" + report_colors.YELLOW + " Return back  				   " + report_colors.RESET + "##")
		print("##						   ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "		  		Terminal   " + report_colors.RESET + "##")
		print("##						   ##")
		print("#####################################################")

	elif _men_call is "7":
		print("######################  " + report_colors.CYAN + "~~Portage~~ " + report_colors.RESET + "  #####################")
		print("##						         ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " Guided/Automatic make.conf	 		 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Manually edit make.conf (Reset)	  	 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Features & ccashe			  	 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit distcc	        	         	 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V  " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit packages.use				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VI " + report_colors.RESET + "]" + report_colors.YELLOW + " Return back  					 " + report_colors.RESET + "##")
		print("##							 ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "				Terminal	 " + report_colors.RESET + "##")
		print("##							 ##")
		print("###########################################################")

	elif _men_call is "8":
		print("##################  " + report_colors.CYAN + "~~Configurations~~" + report_colors.RESET + "   ##################")
		print("##						         ##")
		print("## [ " + report_colors.GREEN + "I    " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure fstab/drives	      	         " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II   " + report_colors.RESET + "]" + report_colors.YELLOW + " Manually edit fstab	 			 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III  " + report_colors.RESET + "]" + report_colors.YELLOW + " Manually edit drive names			 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV   " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit Hostname				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V    " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit /etc/conf.d/net			 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VI   " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit Locales				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VII  " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit Consolefont				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VIII " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit sshd		 	 		 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IX   " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit sshkey		 	 		 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "X    " + report_colors.RESET + "]" + report_colors.YELLOW + " Symlink, bind, overlay and tmpfs		 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XI   " + report_colors.RESET + "]" + report_colors.YELLOW + " Add Scripts					 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XII  " + report_colors.RESET + "]" + report_colors.YELLOW + " Install Packages				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XIII " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit Default Grub				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XIV  " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit runlevels***				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XV   " + report_colors.RESET + "]" + report_colors.YELLOW + " Inject files				 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "XVI  " + report_colors.RESET + "]" + report_colors.YELLOW + " Return back  				 " + report_colors.RESET + "##")
		print("##							 ##")
		print("## [ " + report_colors.GREEN + " T   " + report_colors.RESET + "]" + report_colors.GREEN + "				Terminal	 " + report_colors.RESET + "##")
		print("##							 ##")
		print("###########################################################")

	elif _men_call is "9":
		print("##################  " + report_colors.CYAN + "~~Select Default~~" + report_colors.RESET + "   ##################")
		print("##						         ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " List systems		 	   		 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Edit default					 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Return back					 " + report_colors.RESET + "##")
		print("##							 ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "				Terminal	 " + report_colors.RESET + "##")
		print("##							 ##")
		print("###########################################################")

	elif _men_call is "10":
		print("###################  " + report_colors.CYAN + "~~Catalyst~~" + report_colors.RESET + "   #################")
		print("##						   ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure catalyst.conf	           " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure catalystrc			   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Configure stage1  			   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure stage2  			   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "V  " + report_colors.RESET + "]" + report_colors.YELLOW + " Configure stage3  			   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VI " + report_colors.RESET + "]" + report_colors.PURPLE + " Initiate Build			   " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "VII" + report_colors.RESET + "]" + report_colors.YELLOW + " Return  				   " + report_colors.RESET + "##")
		print("##						   ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "		  		Terminal   " + report_colors.RESET + "##")
		print("##						   ##")
		print("#####################################################")

	elif _men_call is "11":
		print("####################  " + report_colors.CYAN + "~~GSE Tools~~" + report_colors.RESET + "   #####################")
		print("##						         ##")
		print("## [ " + report_colors.GREEN + "I  " + report_colors.RESET + "]" + report_colors.YELLOW + " Renew ALL		 	                 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "II " + report_colors.RESET + "]" + report_colors.YELLOW + " Renew Scripts			                 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "III" + report_colors.RESET + "]" + report_colors.YELLOW + " Version Check					 " + report_colors.RESET + "##")
		print("## [ " + report_colors.GREEN + "IV " + report_colors.RESET + "]" + report_colors.YELLOW + " Return back					 " + report_colors.RESET + "##")
		print("##							 ##")
		print("## [ " + report_colors.GREEN + "T  " + report_colors.RESET + "]" + report_colors.GREEN + "				Terminal	 " + report_colors.RESET + "##")
		print("##							 ##")
		print("###########################################################")

	
	del _men_call, report_colors




