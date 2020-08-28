require "../utils/han_to_int"
require "../utils/normalize"

require "../utils/chap_util"
require "./library/base_dict"
require "./convert/*"

module Libcv::Convert
  extend self

  def translit(input : String, dict : BaseDict, apply_cap = false, pad_space = true)
    res = tokenize(input.chars, dict)
    res.capitalize! if apply_cap
    res.pad_spaces! if pad_space

    res
  end

  def cv_plain(input : String, *dicts : BaseDict)
    res = tokenize(input.chars, *dicts)
    res.grammarize!
    res.capitalize!
    res.pad_spaces!
    res
  end

  TITLE_RE = /^(第?([零〇一二两三四五六七八九十百千]+|\d+)([集卷章节幕回]))([,.:\s]*)(.*)$/

  def cv_title(input : String, *dicts : BaseDict)
    res = CvData.new

    title, label = ChapUtil.split_label(input)

    unless label.empty? || label == "正文"
      if match = TITLE_RE.match(label)
        _, group, idx, tag, trash, label = match

        num = Utils.han_to_int(idx)
        res << CvNode.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !label.empty?
          res << CvNode.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvNode.new(trash, "", 0)
        end
      end

      if label.empty?
        res << CvNode.new("", ": ", 0) unless title.empty?
      else
        res.concat(cv_plain(label, *dicts))
        res << CvNode.new("", " - ", 0) unless title.empty?
      end
    end

    unless title.empty?
      if match = TITLE_RE.match(title)
        _, group, idx, tag, trash, title = match

        num = Utils.han_to_int(idx)
        res << CvNode.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !title.empty?
          res << CvNode.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvNode.new(trash, "", 0)
        end
      end

      res.concat(cv_plain(title, *dicts)) unless title.empty?
    end

    res
  end

  private def cv_title_tag(label = "")
    case label
    when "章" then "Chương"
    when "卷" then "Quyển"
    when "集" then "Tập"
    when "节" then "Tiết"
    when "幕" then "Màn"
    when "回" then "Hồi"
    when "折" then "Chiết"
    else          "Chương"
    end
  end

  def tokenize(chars : Array(Char), *dicts : BaseDict)
    choices = [CvNode.new("", "")]
    weights = [0.0]

    norms = chars.map_with_index do |char, idx|
      norm = Utils.normalize(char)
      dict = norm.to_s =~ /[\p{L}\p{N}]/ ? 1 : 0

      choices << CvNode.new(char, norm, dict)
      weights << idx + 1.0

      norm
    end

    dict_count = dicts.size &+ 1

    0.upto(chars.size) do |idx|
      dicts.each_with_index do |dict, jdx|
        cost = 2 + (jdx + 1) * 0.25

        dict.scan(norms, idx) do |item|
          next if item.vals.empty?

          size = item.key.size
          jump = idx &+ size
          weight = weights[idx] + size ** cost

          if weight >= weights[jump]
            weights[jump] = weight
            choices[jump] = CvNode.new(item.key, item.vals[0], jdx &+ 2)
          end
        end
      end
    end

    res = CvData.new
    idx = chars.size

    while idx > 0
      acc = choices[idx]
      idx -= acc.key.size

      if acc.dic == 1
        while idx > 0
          node = choices[idx]
          break if node.dic != 1
          acc.combine!(node)
          idx -= node.key.size
        end
      elsif acc.dic == 0
        while idx > 0
          node = choices[idx]
          break if node.dic > 0 || acc.key[0] != node.key[0]

          acc.combine!(node)
          idx -= node.key.size
        end
      end
      res << acc
    end

    res.data.reverse!
    res
  end
end
