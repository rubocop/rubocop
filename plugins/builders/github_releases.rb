class Builders::GithubReleases < SiteBuilder
  RELEASES_URL = "https://api.github.com/repos/rubocop/rubocop/releases"

  RELEASE_COUNT = 3

  def build
    hook :site, :post_read do
      site.data[:latest_releases] = fetch_latest_releases
    end
  end

  private

  def fetch_latest_releases
    response = Faraday.get(RELEASES_URL, { per_page: RELEASE_COUNT })

    unless response.success?
      Bridgetown.logger.warn("GithubReleases", "GitHub API returned #{response.status}")
      return []
    end

    JSON.parse(response.body).map do |release|
      {
        name: release["name"],
        tag: release["tag_name"],
        url: release["html_url"],
        published_at: Date.parse(release["published_at"]).strftime("%B %-d, %Y"),
        sections: release["body"].to_s.scan(/^###\s+(.+)/).flatten
      }
    end
  rescue Faraday::Error, JSON::ParserError => e
    Bridgetown.logger.warn("GithubReleases", "Failed to fetch releases: #{e.message}")
    []
  end
end
