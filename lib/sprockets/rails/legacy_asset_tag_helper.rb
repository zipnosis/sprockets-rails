require 'sprockets'

module Sprockets
  module Rails
    # Backports of AssetTagHelper methods for Rails 2.x and 3.x.
    module LegacyAssetTagHelper
      include ActionView::Helpers::TagHelper

      def image_alt(src)
        File.basename(src, '.*').sub(/-[[:xdigit:]]{32}\z/, '').capitalize
      end

     def image_tag(source, options = {})
        options.symbolize_keys!

        src = options[:src] = path_to_image(source)

        unless src =~ /^(?:cid|data):/ || src.blank?
          options[:alt] = options.fetch(:alt){ image_alt(src) }
        end

        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %{^\d+x\d+$}
        end

        if mouseover = options.delete(:mouseover)
          options[:onmouseover] = "this.src='#{path_to_image(mouseover)}'"
          options[:onmouseout]  = "this.src='#{src}'"
        end

        tag("img", options)
      end

      def javascript_include_tag(*sources)
        options = sources.extract_options!.stringify_keys
        sources.uniq.map { |source|
          tag_options = {
            "src" => path_to_javascript(source)
          }.merge(options)
          content_tag(:script, "", tag_options)
        }.join("\n").html_safe
      end

      def stylesheet_link_tag(*sources)
        options = sources.extract_options!.stringify_keys
        sources.uniq.map { |source|
          tag_options = {
            "rel" => "stylesheet",
            "media" => "screen",
            "href" => path_to_stylesheet(source)
          }.merge(options)
          tag(:link, tag_options)
        }.join("\n").html_safe
      end
    end
  end
end
