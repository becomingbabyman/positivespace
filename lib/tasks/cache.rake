namespace :cache do
	desc "Clears Rails cache"
	task :clear => :environment do
		Rails.cache.clear
	end
	
	desc "Warms Rails cache"
	task :warm => :environment do
		User.find_in_batches do |group|
		  sleep(30) # Make sure it doesn't get too crowded in there!
		  group.each do |u|
				Rabl::Renderer.new('api/v1/users/_base', u, format:'json').render
		  end
		end
	end
end
