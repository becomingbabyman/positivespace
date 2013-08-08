# object @image
cache root_object

attributes :id, :name, :lat, :lng, :image_type
node do |image|
	i = image.image
	{
		url: i.url,
		large_url: i.large.url,
		medium_url: i.medium.url,
		small_url: i.small.url,
		big_thumb_url: i.big_thumb.url,
		thumb_url: i.thumb.url
	}
end
