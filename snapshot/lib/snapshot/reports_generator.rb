require 'erb'
require 'fastimage'

module Snapshot
  class ReportsGenerator
    def generate
      UI.message "Generating HTML Report"

      screens_path = Snapshot.config[:output_directory]

      @data = {}

      Dir[File.join(screens_path, "*")].sort.each do |language_folder|
        language = File.basename(language_folder)
        Dir[File.join(language_folder, '*.png')].sort.each do |screenshot|
          available_devices.each do |key_name, output_name|
            next unless File.basename(screenshot).include?(key_name)

            # This screenshot is from this device
            @data[language] ||= {}
            @data[language][output_name] ||= []

            resulting_path = File.join('.', language, File.basename(screenshot))
            @data[language][output_name] << resulting_path
            break # to not include iPhone 6 and 6 Plus (name is contained in the other name)
          end
        end
      end

      html_path = File.join(lib_path, "snapshot/page.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success "Successfully created HTML file with an overview of all the screenshots: '#{export_path}'"
      system("open '#{export_path}'") unless Snapshot.config[:skip_open_summary]
    end

    private

    def lib_path
      if !Helper.is_test? and Gem::Specification.find_all_by_name('snapshot').any?
        return [Gem::Specification.find_by_name('snapshot').gem_dir, 'lib'].join('/')
      else
        return './lib'
      end
    end

    def available_devices
      # The order IS important, since those names are used to check for include?
      # and the iPhone 6 is inlucded in the iPhone 6 Plus
      {
        'iPhone6sPlus' => "5.5-Inch",
        'iPhone6Plus' => "5.5-Inch",
        'iPhone6s' => "4.7-Inch",
        'iPhone6' => "4.7-Inch",
        'iPhone5' => "4-Inch",
        'iPhone4' => "3.5-Inch",
        'iPadPro' => "iPad Pro",
        'iPad' => "iPad",
        'Mac' => "Mac"
      }
    end
  end
end
