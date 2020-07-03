require "file_utils"

require "../../src/import/remote_seed.cr"

def fetch_seed(seed, sbid, expiry = 24.hours) : Void
  puts "\n[ #{seed} / #{sbid} ]\n".colorize(:yellow)

  RemoteUtil.mkdir!(seed)
  task = RemoteSeed.new(seed, sbid, expiry: expiry, freeze: true)

  puts task.extract_info!.to_pretty_json
  puts task.extract_misc!.to_pretty_json
  # puts info.chaps.first(10).to_pretty_json
end

# fetch_seed("jx_la", "7")
# fetch_seed("nofff", "18288")
# fetch_seed("rengshu", "181")
# fetch_seed("xbiquge", "51918")
# fetch_seed("hetushu", "5")
# fetch_seed("hetushu", "4420")
# fetch_seed("duokan8", "6293")
# fetch_seed("paoshu8", "817")
fetch_seed("69shu", "30062")
# fetch_seed("zhwenpg", "junthn")
# fetch_seed("zhwenpg", "kun6m7")
