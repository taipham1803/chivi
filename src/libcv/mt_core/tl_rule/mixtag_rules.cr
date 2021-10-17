module CV::TlRule
  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .auxils?
        return node.set!(PosTag::Noun)
      when .adverbs?, .preposes?, .vmodals?, .vpro?
        return node.set!(PosTag::Verb)
      when .nquants?
        if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
          return node.set!(PosTag::Noun)
        end
      end
    end

    return node unless succ = node.succ?

    case succ
    when .puncts?
      # tag = node.prev?(&.preposes?) ? PosTag::Verb : PosTag::Noun
      # node.set!(tag: tag)
      node
    when .suf_nouns?
      node.set!(PosTag::Noun)
    when .auxils?, .vdir?
      node.set!(PosTag::Verb)
    else
      node
    end
  end
end
