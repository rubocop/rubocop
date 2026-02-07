class Builders::TailwindJit < SiteBuilder
  def build
    return if ARGV.include?("--skip-tw-jit")

    fast_refreshing = false

    hook :site, :fast_refresh do
      fast_refreshing = true
    end

    hook :site, :post_write do
      if fast_refreshing
        fast_refreshing = false
        Thread.new do
          sleep 0.75
          refresh_file = site.in_root_dir("frontend", "styles", "jit-refresh.css")
          File.write refresh_file, "/* #{Time.now.to_i} */"
        end
      end
    end
  end
end
