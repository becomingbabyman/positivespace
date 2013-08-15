require 'rubygems'
require 'sitemap_generator'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.positivespace.io"
SitemapGenerator::Sitemap.sitemaps_host = "http://static.positivespace.io/"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add "/", :priority => 0.9, :changefreq => 'always'
  add "/purpose", :priority => 0.89, :changefreq => 'weekly'
  add "/contact", :priority => 0.88, :changefreq => 'weekly'
  add "/jobs", :priority => 0.87, :changefreq => 'weekly'
  add "/terms", :priority => 0.86, :changefreq => 'monthly'
  add "/privacy", :priority => 0.85, :changefreq => 'monthly'

  # add '/', :priority => 0.8, :changefreq => 'daily', :host => 'http://blog.positivespace.io'
  # add '/', :priority => 0.8, :changefreq => 'daily', :host => 'http://tech.positivespace.io'

  User.endorsed.order('magnetism desc').find_each do |user|
    add "/#{user.slug}", :lastmod => user.updated_at, :priority => 0.7, :changefreq => 'daily'
  end
end
