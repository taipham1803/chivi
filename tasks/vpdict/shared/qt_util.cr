require "colorize"
require "file_utils"

require "../../../src/libcv/vdict"
require "../../../src/libcv/vp_dict"

DIR = "_db/vpinit"

class ValueSet
  getter file : String
  getter data = Set(String).new
  forward_missing_to @data

  def self.load(path : String, preload = true)
    new(File.join(DIR, path), preload)
  end

  def initialize(@file, preload = false)
    load!(@file) if preload && File.exists?(@file)
  end

  def load!(file : String = @file) : Nil
    File.each_line(file) do |line|
      key, val = line.split('\t')

      case val
      when "T" then @data.add(key)
      when "F" then @data.delete(key)
      end
    rescue err
      puts "[ERROR loading #{file}: #{err}, line: #{line}]".colorize.red
    end

    puts "- <value_set> [#{@file}] loaded: #{@data.size} entries".colorize.green
  end

  def add!(key : String)
    return unless @data.add(key)
    File.open(@file, "a") { |io| io.puts "#{key}\tT" }
  end

  def delete!(key : String)
    return unless @data.delete(key)
    File.open(@file, "a") { |io| io.puts "#{key}\tF" }
  end

  def save! : Nil
    File.open(@file, "w") do |io|
      @data.each { |key| io.puts("#{key}\tT") }
    end

    puts "- <value_set> [#{@file}] saved: #{@data.size} entries".colorize.yellow
  end
end

module QtUtil
  extend self

  def path(file : String)
    File.join(DIR, file)
  end

  class_getter lexicon : ValueSet { ValueSet.load(".temps/lexicon.tsv") }

  def has_hanzi?(input : String)
    input =~ /\p{Han}/
  end

  PINYINS = Hash(String, String).from_json {{ read_file("#{__DIR__}/binh_am.json") }}

  def fix_pinyin(input : String)
    input
      .downcase
      .gsub("u:", "ü")
      .split(/[\s\-]/x)
      .map { |x| PINYINS.fetch(x, x) }
      .join(" ")
  end

  def convert(dict : CV::Vdict, text : String, join = "")
    output = [] of String

    chars = text.chars
    caret = 0

    while caret < chars.size
      char = chars[caret]
      keep = CV::Vterm.new(char.to_s, [char.to_s])

      dict.scan(chars, caret) do |term|
        next if term.vals.empty? || term.vals.first.empty?
        keep = term
      end

      output << keep.vals.first
      caret += keep.key.size
    end

    output.join(join)
  end

  def convert(dict : CV::VpDict, text : String, join = "")
    output = [] of String

    chars = text.chars
    caret = 0

    while caret < chars.size
      char = chars[caret]
      keep = dict.new_term(char.to_s, [char.to_s])

      dict.scan(chars, caret) do |term|
        keep = term unless term.empty?
      end

      output << keep.val.first
      caret += keep.key.size
    end

    output.join(join)
  end
end
