module CV::TlRule
  def heal_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    succ.tag = PosTag::Verb if succ && (succ.veno? || succ.vead?)

    case node
    when .vhui?   then node = heal_vhui!(node, succ, nega)
    when .vxiang? then node = heal_vxiang!(node, succ, nega)
    else               node = node.fold_left!(nega)
    end

    if succ && succ.verb?
      node.tag = succ.tag
      node.fold!(succ)
    else
      node
    end
  end

  def heal_vhui!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    nega = prev.try(&.adv_bu?)

    if is_learnable_skill?(succ) || prev.try(&.prev?(&.key.== "也"))
      val = nega ? "không biết" : "biết"
    else
      val = nega ? "sẽ không" : "sẽ"
    end

    prev ? prev.fold!(node, val) : node.heal!(val)
  end

  def is_learnable_skill?(succ : MtNode?) : Bool
    return false unless succ
    return true if succ.nouns? || succ.exmark? || succ.qsmark?

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
        unless succ_is_verb?(succ.succ?)
          node.val = "nhớ"
          node.tag = PosTag::Verb
        end
      end
    end

    node.fold_left!(nega)
  end

  private def succ_is_verb?(node : MtNode?) : Bool
    return false unless node

    node = fold_adverbs!(node) if node.adverbs?
    node.verbs?
  end
end
