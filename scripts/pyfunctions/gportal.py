#!/usr/bin/env python3.6

def _gmm():
	import tkinter

	def donothing():
	   filewin = tkinter.Toplevel(portal)
	   button = tkinter.Button(filewin, text="Do nothing button")
	   button.pack()
	
	# Define portal as tkinter.Tk  
	portal = tkinter.Tk()

	# Title
	portal.title("Portal Menu")
	# Window Geometry
	portal.geometry("1200x1024")

	# Define portal menu as portmen
	portmen = tkinter.Menu(portal)

	def _portfile():
		# Create file tab
		portfile = tkinter.Menu(portmen, tearoff=0)
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

		# Create edit tab
		portedit = tkinter.Menu(portmen, tearoff=0)
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
		porthelp = tkinter.Menu(portmen, tearoff=0)
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


