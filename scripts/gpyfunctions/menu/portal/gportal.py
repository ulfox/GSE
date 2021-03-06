#!/usr/bin/env python3.4

def _gmm():
	'''
	Definition of the project's GUI menu
	'''

	import tkinter
	from tkinter import Tk, Toplevel, Button, Menu

	def donothing():
	   filewin = Toplevel(portal)
	   button = Button(filewin, text="Do nothing button")
	   button.pack()
	
	# Define portal as Tk  
	portal = Tk()

	# Title
	portal.title("Portal Menu")
	# Window Geometry
	portal.geometry("1200x1024")

	# Define portal menu as portmen
	portmen = Menu(portal)

	def _portfile():
		'''
		Definition of "file tab"
		'''

		# Create file tab
		portfile = Menu(portmen, tearoff=0)
		# Label the tab as File
		portmen.add_cascade(label="File", menu=portfile)

		# File's sub-menu
		portfile.add_command(label="New", command=donothing)
		portfile.add_command(label="Open", command=donothing)
		portfile.add_command(label="Save", command=donothing)
		portfile.add_command(label="Save as...", command=donothing)
		portfile.add_command(label="Close", command=donothing)
		portfile.add_separator()
		portfile.add_command(label="Exit", command=portal.quit)

		return portfile

	
	def _portedit():
		'''
		Definition of edit tab
		'''

		# Create edit tab
		portedit = Menu(portmen, tearoff=0)
		# Label the tab as edit
		portmen.add_cascade(label="Edit", menu=portedit)

		portedit.add_command(label="Undo", command=donothing)
		portedit.add_separator()

		portedit.add_command(label="Cut", command=donothing)
		portedit.add_command(label="Copy", command=donothing)
		portedit.add_command(label="Paste", command=donothing)
		portedit.add_command(label="Delete", command=donothing)
		portedit.add_command(label="Select All", command=donothing)

		return portedit


	def _porthelp():
		'''
		Definition of help tab
		'''
		
		porthelp = Menu(portmen, tearoff=0)
		portmen.add_cascade(label="Help", menu=porthelp)
		
		porthelp.add_command(label="Help Index", command=donothing)
		porthelp.add_command(label="About...", command=donothing)
		
		return porthelp

	portfile = _portfile()
	portedit = _portedit()
	porthelp = _porthelp()

	portal.config(menu=portmen)
	portal.mainloop()

	return 0


