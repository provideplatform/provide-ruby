class ScrapeHouzzJob
  @queue = :houzz

  class << self
    def perform(zip, category)
      houzz = Provide::Houzz.new
      houzz.crawl(zip, category)
    end
  end
end
