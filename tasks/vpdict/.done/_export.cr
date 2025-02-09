require "./shared/*"
require "../../src/libcv/libcv"

puts "\n[Load deps]".colorize.cyan.bold

class CV::ExportDicts
  LEXICON = ::ValueSet.load(".result/lexicon.tsv", true)
  CHECKED = ::ValueSet.load(".result/checked.tsv", true)

  REJECT_STARTS = File.read_lines("#{__DIR__}/consts/reject-starts.txt")
  REJECT_ENDS   = File.read_lines("#{__DIR__}/consts/reject-ends.txt")

  def should_keep?(key : String, val : String = "")
    return key =~ /\p{Han}/ if key.size == 1
    return false if val =~ /[:(\/{})]/
    # return true if key.ends_with?("目的")
    LEXICON.includes?(key) || CHECKED.includes?(key)
  end

  def should_reject?(key : String)
    REJECT_STARTS.each { |word| return true if key.starts_with?(word) }
    REJECT_ENDS.each { |word| return true if key.ends_with?(word) }

    key !~ /\p{Han}/
  end

  getter out_regular : Vdict = Vdict.load("regular", reset: true)
  getter out_various : Vdict = Vdict.load("various", reset: true)
  getter out_suggest : Vdict = Vdict.load("suggest", reset: true)

  getter cv_hanviet : Cvmtl { Cvmtl.hanviet }
  getter cv_regular : Cvmtl { Cvmtl.new(@out_regular) }

  def match_hanviet?(key : String, val : String)
    cv_hanviet.translit(key, false).to_s == val
  end

  def match_convert?(key : String, val : String)
    cv_regular.tl_plain(key).downcase == val
  end

  def initialize
    @nouns = Set(String).new
    @nouns.concat File.read_lines(::QtUtil.path(".result/ce-nouns.txt"))
    @nouns.concat File.read_lines(::QtUtil.path(".result/qt-nouns.txt"))

    @verbs = Set(String).new
    @verbs.concat File.read_lines(::QtUtil.path(".result/ce-verbs.txt"))

    @adjes = Set(String).new
    @adjes.concat File.read_lines(::QtUtil.path(".result/ce-adjes.txt"))
    # @adjes.concat File.read_lines(::QtUtil.path(".result/qt-adjes.txt"))
  end

  def is_noun?(key : String, val : String)
    @nouns.includes?(key) || val != val.downcase || noun_and_adje?(key, val)
  end

  def is_adje?(key : String, val : String)
    @adjes.includes?(key) || noun_and_adje?(key, val)
  end

  def noun_and_adje?(key : String, val : String)
    return false if key.size < 2

    return true if key.ends_with?("色") && val.starts_with?("màu ")
    return true if key.ends_with?("上") && val.starts_with?("trên ")
    return true if key.ends_with?("下") && val.starts_with?("dưới ")
    return true if key.ends_with?("中") && val.starts_with?("trong ")
    return true if key.ends_with?("里") && val.starts_with?("trong ")
    return true if key.ends_with?("内") && val.starts_with?("trong ")

    false
  end

  def export_regular!
    puts "\n[Export regular]".colorize.cyan.bold

    input = QtDict.load(".result/regular.txt", true)
    input.to_a.sort_by(&.[0].size).each do |key, vals|
      next unless value = vals.first?
      next if value.empty?

      match = value.downcase
      unless should_keep?(key, value)
        next if should_reject?(key)
        unless match_hanviet?(key, match)
          next if match_convert?(key, match)
        end
      end

      @out_regular.set(key, vals)
    end

    puts "\n- load hanviet".colorize.cyan.bold

    CV::Vdict.hanviet.each(full: false) do |term|
      next if term.key.size > 1 || @out_regular.find(term.key)
      @out_regular.set(term.key, term.vals)
    end

    @out_regular.each do |term|
      next if term.empty?

      # term.attr = 0
      term.set_attr!(:noun) if is_noun?(term.key, term.vals.first)
    end

    @out_regular.load!("_db/vp_dicts/remote/common/regular.tab")
    @out_regular.save!(prune: true)
  end

  def export_uniques!
    puts "\n[Export uniques]".colorize.cyan.bold

    Dir.glob("_db/vp_dicts/remote/unique/*.tab").each do |file|
      dict = Vdict.load(File.basename(file, ".tab"))
      dict.load!(file)

      dict.each do |term|
        # unless term.empty?
        #   if term.key.size < 2
        #     term.prio = 0
        #   elsif term.key.size > 3
        #     term.prio = LEXICON.includes?(term.key) ? 2 : 1
        #   end

        #   term.attr |= 1 if is_noun?(term.key, term.vals.first)
        # end

        # add to suggestion
        suggest_term = @out_suggest.gen_term(term.key, term.vals)
        if old_term = @out_suggest.find(term.key)
          suggest_term.vals.concat(old_term.vals).uniq!
        end

        @out_suggest.set(suggest_term)

        next if term.key.size < 3 || term.key.size > 6 || term.vals.empty?
        next unless capped?(term.vals[0])

        various_term = @out_various.gen_term(term.key, term.vals, 2, 1)
        @out_various.set(various_term)
      end

      dict.save!(prune: true)
    end
  end

  private def capped?(val : String)
    val != val.downcase
  end

  def export_suggest!
    puts "\n[Export suggest]".colorize.cyan.bold

    inp_suggest = ::QtDict.load(".result/suggest.txt", true)
    inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
      next unless value = vals.first?

      next if value.empty?
      match = value.downcase

      unless should_keep?(key, value)
        next if should_reject?(key)
        next if key =~ /[的了是]/
        next if match_convert?(key, match)
      end

      out_suggest.set(key, vals)
    rescue err
      pp [err, key, vals]
    end

    out_suggest.save!(prune: true)
  end

  def export_various!
    puts "\n[Export various]".colorize.cyan.bold

    inp_various = ::QtDict.load(".result/various.txt", true)
    inp_various.to_a.sort_by(&.[0].size).each do |key, vals|
      next if key.size < 3 || key.size > 6
      unless should_keep?(key, vals.first)
        next if should_reject?(key)
      end

      @out_various.set(key, vals)
    end

    @out_various.save!(prune: true)
  end

  def export_recycle!
    puts "\n[Export recycle]".colorize.cyan.bold

    inp_recycle = QtDict.load(".result/recycle.txt", true)
    out_recycle = CV::Vdict.load("recycle", 0)

    inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
      unless should_keep?(key)
        next if should_skip?(key)
      end

      out_recycle.set(key, vals)
    end
    out_recycle.save!
  end
end

tasks = CV::ExportDicts.new

tasks.export_regular!
tasks.export_uniques!
tasks.export_suggest!
tasks.export_various!
