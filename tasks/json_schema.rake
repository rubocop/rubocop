# frozen_string_literal: true

namespace :json_schema do
  desc 'Generate a JSON schema incorporating extensions to assets/schema.json'
  task :generate do
    path = File.expand_path('./json_schema_generate.rb', __dir__)
    status = system('ruby', path)
    puts "\nTry running this instead:\n  ruby tasks/json_schema_generate.rb" unless status
  end

  desc 'Validate our validator against some popular configs on github'
  task :validate_popular_configs do
    require 'json_schemer'
    require 'net/http'

    repos = [
      ['rails/rails'],
      # ['gitlabhq/gitlabhq'], # too much erb
      ['mastodon/mastodon'],
      ['community/community'],
      ['Shopify/bootsnap'],
      ['Shopify/ruby-lsp'],
      ['guard/guard', 'master'],
      ['ViewComponent/view_component'],
      ['celluloid/celluloid', 'master'],
      ['beefproject/beef', 'master'],
      ['activeadmin/activeadmin', 'master'],
      ['realm/jazzy', 'master'],
      ['github/licensed'],
      ['spree/spree'],
      ['rspec/rspec-core'],
      ['rspec/rspec-core', 'main', '.rubocop_rspec_base.yml'],
      ['activemerchant/active_merchant', 'master'],
      ['Homebrew/brew', 'master', 'Library/Homebrew/.rubocop.yml']
    ]

    schema = JSONSchemer.schema(File.read('assets/schema.json'), output_format: 'basic')

    Net::HTTP.start('raw.githubusercontent.com', 443, use_ssl: true) do |http|
      repos.each do |(repo, ref, file_path)|
        print "Checking #{repo} - "

        url_path = [repo, ref || 'main', file_path || '.rubocop.yml'].join('/')
        req = Net::HTTP::Get.new("/#{url_path}")
        res = http.request(req)
        if res.code_type != Net::HTTPOK
          puts "Problem getting #{url_path}"
          next
        end

        config = YAML.safe_load(res.body)

        validation = schema.validate(config)
        if validation['valid']
          puts 'Valid'
        else
          puts 'INVALID - (probably us)'
          p validations['errors'].to_a
        end

        sleep 0.25
      end
    end
  end
end
