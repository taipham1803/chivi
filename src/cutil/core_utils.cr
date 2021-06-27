require "digest"

module CV::CoreUtils
  extend self

  # return semi unique hash string
  def digest32(input : String, limit : Int32 = 8)
    digest = Digest::SHA1.hexdigest(input)
    length = (limit &* 6 / 5).ceil.to_i

    number = digest[0, length].to_i64(base: 16)
    encode32(number).ljust(limit, '0')
  end

  # from base16 to base32
  def hexto32(input : String, limit : Int32 = 8)
    number = input[0, (limit &* 6 / 5).ceil.to_i].to_i64(base: 16)
    encode32(number).ljust(limit, '0')
  end

  B32_CF = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  # convert integer to zbase32
  def encode32(number : Int32 | Int64)
    String.build do |io|
      while number >= 32
        io << B32_CF.unsafe_fetch(number % 32)
        number //= 32
      end

      io << B32_CF.unsafe_fetch(number)
    end
  end

  # convert zbase32 to integer
  def decode32(input : String)
    number = 0_i64

    input.chars.reverse_each do |char|
      number = number &* 32 &+ map32(char)
    end

    number
  end

  private def map32(char : Char)
    {% begin %}
      case char
      {% for val, idx in B32_CF %}
      when {{val}} then {{idx}}
      {% end %}
      when 'o' then 0
      when 'l', 'i' then 0
      when 'u' then 27
      else 0
      end
    {% end %}
  end

  B32_ZH = {
    '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b',
    'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm',
    'n', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
    'y', 'z',
  }

  def encode32_zh(number : Int32 | Int64)
    String.build do |io|
      while number >= 32
        io << B32_ZH.unsafe_fetch(number % 32)
        number //= 32
      end

      io << B32_ZH.unsafe_fetch(number)
    end
  end

  # convert zbase32 to integer
  def decode32_zh(input : String)
    number = 0_i64

    input.chars.reverse_each do |char|
      number = number &* 32 &+ map32_zh(char)
    end

    number.to_i64
  end

  private def map32_zh(char : Char) : Int32
    {% begin %}
      case char
      {% for val, idx in B32_ZH %}
      when {{val}} then {{idx}}
      else 0
      {% end %}
      end
    {% end %}
  end
end

# puts CV::CoreUtils.digest32("95410")
# puts CV::CoreUtils.encode32(95410).ljust(8, '0')
# puts CV::CoreUtils.decode32("j5x20000")
# puts CV::CoreUtils.decode32("j5x20")
