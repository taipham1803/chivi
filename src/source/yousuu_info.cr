require "json"
require "./source_util"

struct BookSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class YousuuInfo
  include JSON::Serializable

  property _id : Int32

  property title = ""
  property author = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?

  property tags = [] of String
  property cover = ""

  property status = 0_i32
  property shielded = false
  # property recom_ignore = false

  property countWord = 0_f32
  property commentCount = 0_i32

  property scorerCount = 0_i32
  property score = 0_f32

  property addListCount = 0_i32
  property addListTotal = 0_i32

  property updateAt = Time.utc(2000, 1, 1)
  property sources = [] of BookSource

  def cover
    return "" unless @cover.starts_with?("http")
    @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
  end

  def genre
    @category.try(&.[:className]) || ""
  end

  def tags
    @tags.map(&.split("-")).flatten.uniq.reject! do |tag|
      tag == @title || tag == @author
    end
  end

  def first_source
    @sources.first?.try(&.link)
  end

  alias Data = NamedTuple(bookInfo: YousuuInfo, bookSource: Array(BookSource))

  def self.load!(file : String)
    text = File.read(file)
    return unless text.includes?("\"success\"")

    json = NamedTuple(data: Data).from_json(text)

    info = json[:data][:bookInfo]
    info.sources = json[:data][:bookSource]

    info.title = SourceUtil.fix_title(info.title)
    info.author = SourceUtil.fix_author(info.author, info.title)

    info
  end
end

# pp YousuuInfo.load!("var/.book_cache/yousuu/serials/176814.json")
