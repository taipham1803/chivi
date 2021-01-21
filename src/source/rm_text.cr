require "myhtml"
require "colorize"
require "file_utils"

require "../_utils/*"

class CV::RmText
  def self.init(s_name : String, s_nvid : String, s_chid : String,
                expiry : Time = Time.utc - 10.years, freeze : Bool = true)
    file = path_for(s_name, s_nvid, s_chid)
    expiry = TimeUtils::DEF_TIME if s_name == "jx_la"

    unless html = FileUtils.read(file, expiry)
      url = url_for(s_name, s_nvid, s_chid)
      html = HttpUtils.get_html(url, encoding: HttpUtils.encoding_for(s_name))

      if freeze
        ::FileUtils.mkdir_p(File.dirname(file))
        File.write(file, html)
      end
    end

    new(s_name, s_nvid, s_chid, file: file, html: html)
  end

  def self.path_for(s_name : String, s_nvid : String, s_chid : String)
    "_db/.cache/#{s_name}/texts/#{s_nvid}/#{s_chid}.html"
  end

  def self.url_for(s_name : String, s_nvid : String, s_chid : String) : String
    case s_name
    when "nofff"    then "https://www.nofff.com/#{s_nvid}/#{s_chid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{s_nvid}/#{s_chid}"
    when "jx_la"    then "https://www.jx.la/book/#{s_nvid}/#{s_chid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{s_nvid}/#{s_chid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{s_nvid}/#{s_chid}"
    when "xbiquge"  then "https://www.xbiquge.cc/book/#{s_nvid}/#{s_chid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{s_chid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{s_nvid}/#{s_chid}.html"
    when "duokan8"  then "http://www.duokan8.com/#{prefixed(s_nvid, s_chid)}"
    when "paoshu8"  then "http://www.paoshu8.com/#{prefixed(s_nvid, s_chid)}"
    when "5200"     then "https://www.5200.tv/#{prefixed(s_nvid, s_chid)}"
    when "shubaow"  then "https://www.shubaow.net/#{prefixed(s_nvid, s_chid)}"
    when "bqg_5200" then "https://www.biquge5200.com/#{prefixed(s_nvid, s_chid)}"
    else
      raise "Unsupported remote source <#{s_name}>!"
    end
  end

  private def self.prefixed(s_nvid : String, s_chid : String)
    "#{s_nvid.to_i // 1000}_#{s_nvid}/#{s_chid}.html"
  end

  getter s_name : String
  getter s_nvid : String
  getter s_chid : String
  getter file : String

  def initialize(@s_name, @s_nvid, @s_chid, @file, html = File.read(@file))
    @rdoc = Myhtml::Parser.new(html)
  end

  getter title : String do
    case @s_name
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "hetushu" then @rdoc.css("#content .h2").first.inner_text
    when "zhwenpg" then extract_title("h2")
    else                extract_title("h1")
    end
  end

  private def extract_title(sel : String) : String
    return "" unless node = @rdoc.css(sel).first?
    TextUtils.format_title(node.inner_text)[0]
  end

  getter paras : Array(String) do
    case @s_name
    when "hetushu" then extract_hetushu_paras
    when "69shu"   then extract_paras(".yd_text2")
    when "zhwenpg" then extract_paras("#tdcontent .content")
    when "duokan8" then extract_paras("#htmlContent > p")
    else                extract_paras("#content")
    end
  end

  private def extract_paras(sel : String)
    return [] of String unless node = @rdoc.css(sel).first?

    node.children.each do |tag|
      tag.remove! if {"script", "div"}.includes?(tag.tag_name)
    end

    lines = TextUtils.split_html(node.inner_text("\n"))
    lines.shift if lines.first == title

    case @s_name
    when "zhwenpg"
      title.split(/\s+/).each { |x| lines[0] = lines[0].sub(/^#{x}\s*/, "") }
    when "jx_la"
      lines.pop if lines.last.starts_with?("正在手打中")
    when "5200"
      lines.pop if lines.last.ends_with?("更新速度最快。")
    when "nofff"
      3.times { lines.shift } if lines[1].includes?("eqeq.net")
      lines.pop if lines.last.includes?("eqeq.net")
    when "xbiquge"
      lines.shift if lines.first.starts_with?("笔趣阁")
    when "duokan8"
      lines.shift if lines.first == "<b></b>"
      lines.update(0, &.sub(/.+<\/h1>\s*/, ""))
      lines.map!(&.sub("</div>", "")).reject!(&.empty?)
    when "bqg_5200"
      lines.map! do |line|
        line.gsub(/厺厽\s.+\s厺厽。?/, "").gsub("攫欝攫欝。?", "")
      end
    else
      lines.pop if lines.last == "(本章完)"
    end

    lines
  rescue err
    puts "<remote_text> [#{@s_name}/#{@s_nvid}/#{@s_chid}] error: #{err}".colorize.red
    [] of String
  end

  private def extract_hetushu_paras
    client = hetushu_encrypt_string
    orders = Base64.decode_string(client).split(/[A-Z]+%/)

    res = Array(String).new(orders.size, "")
    jmp = 0

    inp = @rdoc.css("#content div:not([class])").map_with_index do |node, idx|
      ord = orders[idx].to_i

      if ord < 5
        jmp += 1
      else
        ord -= jmp
      end

      res[ord] = node.inner_text(deep: false).strip
    end

    res
  end

  private def hetushu_encrypt_string
    if node = @rdoc.css("meta[name=client]").first?
      return node.attributes["content"]
    end

    meta_file = @file.sub(".html", ".meta")
    return File.read(meta_file) if File.exists?(meta_file)

    html_url = RmText.url_for(@s_name, @s_nvid, @s_chid)
    json_url = html_url.sub("#{@s_chid}.html", "r#{@s_chid}.json")

    headers = HTTP::Headers{
      "Referer"          => html_url,
      "X-Requested-With" => "XMLHttpRequest",
    }

    HTTP::Client.get(json_url, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end
