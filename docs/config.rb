# https://github.com/middleman/middleman/issues/1857#issuecomment-200930893
# the source directory of webpack should exists before starting
require 'fileutils'
FileUtils.mkdir_p('.webpack')
FileUtils.rm_rf(Dir.glob('.webpack/*'))

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  activate :gzip
  activate :livereload
  config[:places_lib_url] = 'places'
  config[:places_autocomplete_dataset_lib_url] = 'placesAutocompleteDataset'
  config[:places_instantsearch_widget_lib_url] = 'placesInstantsearchWidget'
  config[:instantsearch_lib_url] = 'https://cdn.jsdelivr.net/instantsearch.js/1.6.0/instantsearch.min.js'
  config[:instantsearch_googlemaps_lib_url] = 'https://cdn.jsdelivr.net/instantsearch-googlemaps/1.2.4/instantsearch-googlemaps.min.js'
  config[:google_maps_lib_url] = 'https://maps.googleapis.com/maps/api/js'
  activate :external_pipeline,
    name: 'places',
    command: 'npm run js:watch -- --output-path docs/.webpack/js',
    source: '.webpack'
end

set :js_dir, 'js'
ignore '/javascripts/*'

set :markdown_engine, :kramdown
set :markdown, input: 'GFM'

activate :syntax, line_numbers: true, css_class: 'codehilite'

# JS entry points
[:index, :common, :support, 'documentation-layout'].each do |name|
  activate :external_pipeline,
    name: name,
    command: "BUNDLE=#{name} npm run docs:js:#{build? ? :build : :watch}",
    source: '.webpack'
end

activate :protect_emails

###
# Helpers
###

config[:places_lib_version] = ENV['VERSION']
config[:places_cdn_url] = 'https://cdn.jsdelivr.net/places.js/1/places.min.js'
config[:places_autocomplete_dataset_cdn_url] = 'https://cdn.jsdelivr.net/places.js/1/placesAutocompleteDataset.min.js'
config[:places_instantsearch_widget_cdn_url] = 'https://cdn.jsdelivr.net/places.js/1/placesInstantsearchWidget.min.js'

helpers do
  def nav_active(path)
    current_page.path == path ? {:class => "active"} : {}
  end
end

# Build-specific configuration
configure :build do
  config[:places_lib_url] = config[:places_cdn_url]
  config[:places_autocomplete_dataset_lib_url] = config[:places_autocomplete_dataset_cdn_url]
  config[:places_instantsearch_widget_lib_url] = config[:places_instantsearch_widget_cdn_url]
  config[:instantsearch_lib_url] = 'https://cdn.jsdelivr.net/instantsearch.js/1.6.0/instantsearch.min.js'
  config[:instantsearch_googlemaps_lib_url] = 'https://cdn.jsdelivr.net/instantsearch-googlemaps/1.2.4/instantsearch-googlemaps.min.js'
  config[:google_maps_lib_url] = 'https://maps.googleapis.com/maps/api/js'
  # this may trigger bad behavior, if so, see
  # https://github.com/middleman/middleman-minify-html
  activate :minify_html
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  # website is hosted on a subpath /places.js so we use relative links
  # and assets
  activate :relative_assets
  set :relative_links, true
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.deploy_method = :git
  deploy.remote   = "https://#{ENV['GH_TOKEN']}@github.com/algolia/places.git"
end
