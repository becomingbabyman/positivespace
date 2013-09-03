root = global ? window


root.positivespaceWidgetGlobalNamespace = (() ->
	ps = {}

	# Constants
	ps.DOMAIN = 'localhost:3000'


	# Helpers
	ps.styleOf = (el, property) ->
		if (window.getComputedStyle) then document.defaultView.getComputedStyle(el, null).getPropertyValue(property)


	# Embed
	ps.links = ->
		result = []
		for link in document.getElementsByTagName('a')
			if link.href.indexOf(ps.DOMAIN) > -1 then result.push(link)
		result

	ps.embedableLinks = ->
		# TODO: check that the link can be embedded
		# Do this with an Ajax API call that returns the embeddable uri
		# TODO: style the text based on the current font-size and line-height and font-weight, etc...
		result = []
		for link in ps.links()
			id = (a = link.href.split("/"); a[a.length - 1])
			uri = "http://#{ps.DOMAIN}/embed/u/#{id}?text=#{link.innerHTML}&ff=#{ps.styleOf(link, 'font-family')}&fs=#{ps.styleOf(link, 'font-size')}&fw=#{ps.styleOf(link, 'font-weight')}&lh=#{ps.styleOf(link, 'line-height')}&ls=#{ps.styleOf(link, 'letter-spacing')}&ws=#{ps.styleOf(link, 'word-spacing')}&co=#{ps.styleOf(link, 'color')}"
			result.push
				el: link
				embedUri: uri
		result

	ps.embedLinks = ->
		result = []
		for link in ps.embedableLinks()
			result.push link.el.outerHTML = """
				<iframe class="ps-embed ps-embed-link" src="#{link.embedUri}" frameborder="0" border="0" cellspacing="0" style="border-style: none;width: #{link.el.offsetWidth}px; height: #{link.el.offsetHeight}px; vertical-align: bottom;" scrolling="no"></iframe>
			"""
		result


	# Initialize the widgets
	ps.embedLinks()


	# Return the ps object
	ps
)()


# Change namespace to ps if available
unless root.ps?
	root.ps = root.positivespaceWidgetGlobalNamespace
	delete root.positivespaceWidgetGlobalNamespace