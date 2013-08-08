object false

node(:total) { |i| @users.total_count }
node(:total_pages) { |i| @users.num_pages }

child @users => :collection do
	# cache @users

	attributes :id, :slug

	node :typeahead do |u|
		html = ''
			html << "<div class='z1'>"
				html << "<div class='z2'>"
					html << "<div class='z3'>"
						html << image_tag(u.avatar_thumb_url, :class => "z4") if u.avatar_thumb_url
					html << "</div>"
					html << "<div class='z3z'>"
						html << "<i></i>" if u.state == 'endorsed'
						html << u.username if u.username
						html << "<br/>"
						html << "<div class='z3z3'>#{u.name}</div>" if u.name and u.name != u.username
					html << "</div>"
				html << "</div>"
				if u.bio and u.bio.size > 0
					html << "<div class='z4z4'>"
						html << u.bio if u.bio
					html << "&nbsp;</div>"
				end
				html << "<div class='z5'>"
					html << u.current_space_prompt if u.current_space_prompt
				html << "&nbsp;</div>"
				html << "<div class='z6'>"
					html << u.location.truncate(20) if u.location
				html << "</div>"
				html << "<div class='z7'>"
					html << u.personal_url_root.truncate(20) if u.personal_url_root
				html << "&nbsp;</div>"
			html << "</div>"
		html
	end
end
