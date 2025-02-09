require "./shared/seed_util"
require "./shared/raw_yscrit"

class CV::SeedYscrit
  def seed_file!(file : String)
    crits = RawYscrit.parse_raw(File.read(file))
    crits.each(&.seed!)
  end

  def save_progress!
    @checker.save!
  end

  DIR = "_db/yousuu/crits"

  def self.run!
    worker = new

    Dir.children(DIR).each do |dir|
      files = Dir.glob("#{DIR}/#{dir}/*.json")
      files.each_with_index(1) do |file, idx|
        puts "- <#{idx}/#{files.size}> #{file}"
        worker.seed_file!(file)
      rescue err
        puts err
      end
    end
  end
end

CV::SeedYscrit.run!
