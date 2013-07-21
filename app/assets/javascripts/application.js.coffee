# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
# Vendor JS
# TODO: deprecate jquery - for now Angular UI depends on it
#= require jquery
#= require jquery_ujs
#= require select2
#= require angularjs/angular-1.0.6.min
#= require_tree ../../../vendor/assets/javascripts/angularjs/
#= require underscore-min
#= require bootstrap-button
#
# App JS
#= require routes
#= require services
#= require filters
#= require_tree ./controllers/
#= require_tree ./directives/
#
# Plugins
#= require tinycon
#= require dropzone.jquery
#= require jquery.scrollTo-min
#= require jquery.autosize
#= require opentip-jquery
#= require jquery.transit.min
#= require modernizr.min
#= require jquery.placeholder.min
#= require raphael-min
#= require g.raphael-min
#= require g.line-min
#= require moment.min
#= require json2
#= require gestures
#= require amplify.core.min
#= require amplify.store.min
#
# Not Currently Required
# require jquery.jlabel
# require sisyphus.min
#

String.prototype.addHttp = () ->
	@.replace(/^.*\/\//, 'http://')

window.log = (content) ->
	console.log content

window.retargetExternalLinks = ->
	$(document.links).filter( () ->
		this.hostname != window.location.hostname
	).attr('target', '_blank')

$.fn.serializeJSON = ->
	json = {}
	jQuery.map $(this).serializeArray(), (n, i) ->
		json[n["name"]] = n["value"]
	json

window.parallaxify = (element) ->
	$(window).scroll ->
		s = $(@).scrollTop() - $(element).offset().top
		$(element).css "background-position", "center " + s/3 + "px"
	$(window).scroll()

window.videoResize = ($iframe, newWidth) ->
	width = $iframe.attr('width')
	height = $iframe.attr('height')
	aspectRatio = height/width
	$iframe.attr('width', newWidth)
	$iframe.attr('height', newWidth*aspectRatio)

# To Select Text
window.selectText = (className) ->
	doc = document
	text = doc.getElementsByClassName(className)[0]
	range = undefined
	selection = undefined
	if doc.body.createTextRange #ms
		range = doc.body.createTextRange()
		range.moveToElementText text
		range.select()
	else if window.getSelection #all others
		selection = window.getSelection()
		range = doc.createRange()
		range.selectNodeContents text
		selection.removeAllRanges()
		selection.addRange range

window.openCenter = (url, title, w, h) ->
	left = (screen.width/2)-(w/2)
	top = (screen.height/2)-(h/2)
	window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left)

# Call it on input checkbox elements to turn them into on off switchs
$.fn.onoffswitch = ->
	$(@).addClass "onoffswitch-checkbox"
	$(@).wrap "<div class='onoffswitch'></div>"
	$(@).after """
		<label class="onoffswitch-label" for="#{$(@).attr('id')}">
			<div class="onoffswitch-inner"></div>
			<div class="onoffswitch-switch"></div>
		</label>
	"""
