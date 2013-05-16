object false

node(:total) { |i| @users.total_count }
node(:total_pages) { |i| @users.num_pages }

child @users => :collection do
	attributes :id, :slug

	node :typeahead do |u|
		html = ''
			html << "<div class='z1'>"
				html << "<div class='z2'>"
					html << "<div class='z3'>"
						html << image_tag(u.avatar_thumb_url, :class => "z4")
					html << "</div>"
					html << "<div class='z3z'>"
						html << u.username
						html << "<br/>"
						html << "<div class='z3z3'>#{u.name}</div>" if u.name != u.username
					html << "</div>"
				html << "</div>"
				html << "<div class='z5'>"
					html << u.body
				html << "</div>"
				html << "<div class='z6'>"
					html << u.location.truncate(20)
				html << "</div>"
				html << "<div class='z7'>"
					html << u.personal_url_root.truncate(20)
				html << "</div>"
			html << "</div>"
		html
	end
end
