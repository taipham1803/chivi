class CV::Dboard
  include Clear::Model

  self.table = "dboards"
  primary_key

  # has_many dtopics : Dtopic, foreign_key: "dtopic_id"

  column bname : String
  column bslug : String

  column posts : Int32 = 0
  column views : Int32 = 0

  timestamps

  def bump!(time = Time.utc)
    update!({updated_at: time})
  end

  #################

  CACHE_INT = RamCache(Int64, self).new(2048, ttl: 2.hours)
  CACHE_STR = RamCache(String, self).new(2048, ttl: 2.hours)

  def self.load!(id : Int64) : self
    CACHE_INT.get(id) { find({id: id}) || init!(id) }
  end

  def self.load!(bslug : String) : self
    CACHE_STR.get(bslug) { load!(guess_id(bslug)) }
  end

  def self.init!(id : Int64) : self
    bname, bslug =
      case id
      when  0_i64 then {"Đại sảnh", "dai-sanh"}   # general place
      when -1_i64 then {"Thông cáo", "thong-cao"} # show in top of board list
      when -2_i64 then {"Quảng bá", "quang-ba"}   # show in every page
      else
        raise "Unknown book!" unless cvbook = Cvbook.load!(id)
        {cvbook.bname, cvbook.bslug}
      end

    new({id: id, bname: bname, bslug: bslug}).tap(&.save!)
  end

  def self.guess_id(bslug : String) : Int64
    case bslug
    when "dai-sanh"  then 0_i64
    when "thong-cao" then -1_i64
    when "quang-ba"  then -2_i64
    else
      raise "Unknown book!" unless cvbook = Cvbook.load!(bslug)
      cvbook.id
    end
  end
end
