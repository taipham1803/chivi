module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?
        break unless succ.succ?(&.ude1?)
        return fold!(node, succ, PosTag::Adjt, dic: 2)
      when .middot?
        break unless succ_2 = succ.succ?
        break unless succ_2.human?

        return fold!(node, succ_2, PosTag::Person, dic: 2)
      when .ptitle?
        node.tag = PosTag::Person
        node = fold!(node, succ, PosTag::Person, dic: 2)
      when .names?
        break unless node.names?
        node = fold!(node, succ, succ.tag, dic: 3)
      when .place?
        return fold_swap!(node, succ, PosTag::Noun, dic: 3)
      when .uzhi?
        return fold_uzhi!(succ, node)
      when .veno?
        succ = heal_veno!(succ)
        break if succ.verbs?

        node = fold_swap!(node, succ, PosTag::Noun, dic: 4)
      when .noun?
        case node
        when .names?
          node = fold_swap!(node, succ, PosTag::Noun, dic: 3)
        when .noun?
          node = fold_swap!(node, succ, PosTag::Noun, dic: 4)
        else return node
        end
      when .penum?, .concoord?
        break unless (succ_2 = succ.succ?) && can_combine_noun?(node, succ_2)
        succ = heal_concoord!(succ) if succ.concoord?
        fold!(node, succ_2, tag: node.tag, dic: 8)
      when .suf_verb?
        return fold_suf_verb!(node, succ)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
      else break
      end

      break if succ == node.succ?
    end

    node
  end

  def fold_noun_left!(node : MtNode, mode = 1)
    return node if node.veno?

    while node.nouns?
      break unless prev = node.prev?
      case prev
      when .penum?, .concoord?
        break unless (prev_2 = prev.prev?) && can_combine_noun?(node, prev_2)
        prev = heal_concoord!(prev) if prev.concoord?
        node = fold!(prev_2, node, tag: node.tag, dic: 3)
      when .nquants?
        break if node.veno? || node.ajno?

        if prev.key.ends_with?('个')
          prev.val = prev.val.sub(" cái", "")
        end

        node = fold!(prev, node, PosTag::Nphrase, 3)
        # puts node.body.deep_inspect
        # gets
      when .prodeics?
        # puts [node, prev]
        # gets
        return fold_prodeic_noun!(prev, node)
      when .prointrs?
        return fold_什么_noun!(prev, node) if prev.key == "什么"

        return fold_swap!(prev, node, PosTag::Nphrase, 3)
      when .amorp? then node = fold!(prev, node)
      when .place?, .adesc?, .ahao?, .ajno?, .modifier?, .modiform?
        node = fold_swap!(prev, node, PosTag::Nphrase, 2)
      when .ajav?, .adjt?
        break if prev.key.size > 1
        node = fold_swap!(prev, node, PosTag::Nphrase, 2)
      when .ude1?
        break if mode < 1
        node = fold_ude1!(node, prev)
      else
        break
      end

      break if prev == node.prev?
    end

    node
  end

  def fold_什么_noun!(prev : MtNode, node : MtNode)
    succ = MtNode.new("么", "gì", prev.tag, 1, prev.idx + 1)

    prev.key = "什"
    prev.val = "cái"

    succ.fix_succ!(node.succ?)
    node.fix_succ!(succ)

    fold!(prev, succ, PosTag::Nphrase, 3)
  end
end
