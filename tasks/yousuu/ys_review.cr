require "./shared/http_client"
require "../shared/raw_yscrit"

class CV::CrawlYscrit
  DIR = "_db/yousuu/crits-latest"

  @counter = {} of Int64 => Int32

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)

    Ysbook.query.order_by(id: :desc).each_with_cursor(20) do |ysbook|
      @counter[ysbook.id] = ysbook.crit_count
    end
  end

  def crawl!(page = 1)
    count = 0
    queue = [] of Int64

    @counter.each do |snvid, count|
      count -= (page - 1) * 20
      queue << snvid if count > 3
    end

    until queue.empty?
      count += 1
      puts "\n[page: #{page}, loop: #{count}, size: #{queue.size}]".colorize.cyan

      fails = [] of Int64

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Int64?).new(limit)

      queue.each_with_index(1) do |snvid, idx|
        return if @http.no_proxy?

        spawn do
          label = "(#{page}) <#{idx}/#{queue.size}> [#{snvid}]"
          inbox.send(crawl_crit!(snvid, page, label: label))
        end

        inbox.receive.try { |snvid| fails << snvid } if idx > limit
      end

      limit.times do
        inbox.receive.try { |snvid| fails << snvid }
      end

      queue = fails
      break if @http.no_proxy?
    end
  end

  def crawl_crit!(snvid : Int64, page = 1, label = "1/1/1") : Int64?
    group = snvid.//(1000).to_s.rjust(3, '0')
    file = "#{DIR}/#{group}/#{snvid}-#{page}.json"

    return if still_good?(file, page)

    link = "https://api.yousuu.com/api/book/#{snvid}/comment?type=latest&page=#{page}"
    return snvid unless @http.save!(link, file, label)

    crits = RawYscrit.parse_raw(File.read(file))
    crits.each(&.seed!)
  rescue err
    puts err
  end

  FRESH = 2.days

  private def still_good?(file : String, page = 1)
    return false unless info = File.info?(file)
    still_fresh = Time.utc - FRESH * page
    info.modification_time >= still_fresh
  end

  delegate no_proxy?, to: @http
end

reload_proxy = ARGV.includes?("proxy")
worker = CV::CrawlYscrit.new(reload_proxy)

1.upto(10) do |page|
  worker.crawl!(page) unless worker.no_proxy?
end
