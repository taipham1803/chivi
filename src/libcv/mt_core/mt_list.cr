require "./mt_node"
require "./tl_rule"

class CV::MtList
  include MTL::PadSpace

  getter head = MtNode.new("", "")

  def first
    @head.succ?
  end

  def concat!(list : self)
    self.tail.set_succ(list.first)
    self
  end

  def tail(node = @head)
    while node = node.succ?
      return node unless node.succ?
    end

    @head
  end

  def prepend!(node : MtNode)
    @head.set_succ(node)
  end

  def each(node = @head)
    while node = node.succ?
      yield node
    end
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    @head.succ?(&.print_val(io))
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    @head.succ?(&.serialize(io))
  end

  def inspect(io : IO) : Nil
    @head.succ?(&.deep_inspect(io))
  end

  def capitalize!(cap = true) : self
    @head.apply_cap!(cap)
    self
  end

  def pad_spaces! : self
    @head.succ?.try(&.pad_spaces!(@head))
    self
  end

  def fix_grammar!(mode = 1)
    TlRule.fix_grammar!(@head, mode: mode)
  end
end
