module CV::TlRule
  def heal_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    case node
    when .vhui?   then heal_vhui!(node, succ, nega)
    when .vxiang? then heal_vxiang!(node, succ, nega)
    else               node.fold_left!(nega)
    end
  end

  def heal_vhui!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    if is_learnable_skill?(succ)
      val = nega ? "#{nega.val} biết" : "biết"
    else
      val = nega ? "sẽ #{nega.val}" : "sẽ"
    end

    if nega
      nega.val = val
      nega.key += node.key
      nega
    else
      node.val = val
      node
    end
  end

  def is_learnable_skill?(succ : MtNode?) : Bool
    return false unless succ
    return true if succ.nouns?

    case succ.key[0]?
    when '打', '说', '做' then true
    else
      {"跳舞", "做饭", "开车", "游泳"}.includes?(succ.key)
    end
  end

  def heal_vxiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    if succ
      if succ_is_verb?(succ)
        node.val = "muốn"
      elsif succ.nouns? || succ.pronouns?
        node.val = "nhớ" unless succ_is_verb?(succ.succ?)
      end
    end

    node.fold_left!(nega)
  end

  def succ_is_verb?(node : MtNode) : Bool
    node = fold_adverbs!(node) if node.adverbs?
    node.verbs?
  end

  def succ_is_verb?(node : Nil) : Nil
    false
  end
end
