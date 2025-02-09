module CV::TlRule
  def fold_ndigit!(node : MtNode, prev : MtNode? = nil)
    return node unless succ = node.succ?
    return fold_ndigit_nhanzi!(node, succ) if succ.nhanzi?

    if prev && (succ.key == "点")
      return fold_number_hour!(node, succ)
    end

    return node unless (succ_2 = succ.succ?) && succ_2.ndigit?

    case succ.tag
    when .pdeci? # case 1.2
      fold_ndigit_succs!(node, succ, succ_2, PosTag::Ndigit)
    when .pdash? # case 3-4
      fold_ndigit_succs!(node, succ, succ_2, PosTag::Number)
    when .colon? # for 5:6 format
      node = fold_ndigit_succs!(node, succ, succ_2, PosTag::Time)

      # for 5:6:7 format
      return node unless (succ_3 = succ_2.succ?) && (succ_4 = succ_3.succ?)
      return node unless succ_3.colon? && succ_4.ndigit?

      fold_ndigit_succs!(node, succ_3, succ_4, PosTag::Time)
    else
      return node unless succ.key == "点"
      fold_number_hour!(node, succ)
    end
  end

  private def fold_ndigit_succs!(node : MtNode, succ : MtNode, tail : MtNode, tag : PosTag)
    node.key = "#{node.key}#{succ.key}#{tail.key}"
    node.set!("#{node.val}#{succ.val}#{tail.val}", tag)
    node.fix_succ!(tail.succ?)
  end

  def fold_ndigit_nhanzi!(node : MtNode, succ : MtNode) : MtNode
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    match_tag = PosTag::Nhanzi

    while succ.tag == match_tag
      key_io << succ.key
      val_io << " " << succ.val
      break unless succ = succ.succ?
      match_tag = PosTag::Ndigit
    end

    node.key = key_io.to_s
    node.val = val_io.to_s # TODO: correct unit system

    node.tag = PosTag::Nhanzi
    node.fix_succ!(succ)
  end
end
