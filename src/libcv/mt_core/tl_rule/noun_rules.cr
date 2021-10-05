module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .middot?
        break unless succ_2 = succ.succ?
        break unless succ_2.human?

        node.tag = PosTag::Person
        node.fold!(succ, node.val).fold!(succ_2)
      when .ptitle?
        node.tag = PosTag::Person
        node.fold!(succ)
      when .names?
        break unless node.names?
        node.tag = succ.tag
        node.fold!(succ)
      when .space?
        node = fold_noun_space?(node, succ)
      when .place?
        node.tag = PosTag::Noun
        node.fold!(succ, "#{succ.val} #{node.val}")
      when .noun?
        case node
        when .names?
          node.tag = PosTag::Noun
          node.fold!(succ, "#{succ.val} #{node.val}")
        when .noun?
          node.dic = 9
          node.fold!(succ, "#{succ.val} #{node.val}")
        when .veno?
          # TODO: check more noun verb case
          break unless node.prev?(&.ude1?)

          node.dic = 9
          node.fold!(succ, "#{succ.val} #{node.val}")
        else break
        end
      when .concoord?
        node = fold_near_concoord!(node, succ, succ.succ)
        break if node.succ == succ
      when .penum?
        node = fold_near_penum!(node, succ, succ.succ)
        break node.succ == succ
      when .suf_verb?
        node = heal_suf_verb!(node, succ)
        break
      when .suffix们?
        node = heal_suffix_们!(node, succ)
        break
      else break
      end
    end

    node
  end

  def fold_noun_space?(node : MtNode, succ = node.succ)
    node.tag = PosTag::Place

    case succ.key
    when "上"
      node.fold!("trên #{node.val}")
    when "下"
      node.fold!("dưới #{node.val}")
    else
      node.fold!("#{succ.val} #{node.val}")
    end
  end
end
