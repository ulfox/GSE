#!/usr/bin/env python3.6

# Images
class image(object):
	# Image products, with type

	# Attributes:
	#	name: A string with the image's name
	#	date: A string with the image's creation date

	def __init__(img, name):
		# Return the image's name
		img.name = name

	def set_date(img, date):
		# Return the image's date of creation
		img.date = date

