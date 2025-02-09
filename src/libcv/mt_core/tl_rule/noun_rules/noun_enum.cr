module CV::TlRule
  def fold_noun_penum!(head : MtNode, join : MtNode)
    while node = join.succ?
      break unless node.nouns? || node.pronouns?
      tail = node

      break unless join = node.succ?

      if join.ude1?
        break unless (succ = join.succ?) && succ.nouns?
        join.val = "của"
        node = fold_swap!(node, succ, succ.tag, dic: 7)
        break unless join = node.succ?
      end

      break unless join.penum?
    end

    tail ? fold!(head, tail, PosTag::Nphrase, dic: 8) : head
  end
end
