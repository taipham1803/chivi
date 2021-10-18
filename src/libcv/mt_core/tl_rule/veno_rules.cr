module CV::TlRule
  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .auxils?
        return node.set!(PosTag::Noun)
      when .preposes?
        return node.set!(PosTag::Verb) unless prev.key == "给"
      when .adverbs?, .vmodals?, .vpro?
        return node.set!(PosTag::Verb)
      when .numeric?
        if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
          return node.set!(PosTag::Noun)
        end
      when .pro_dem?
        unless node.succ?(&.ude1?)
          return node.set!(PosTag::Noun)
        end
      end
    end

    return node unless succ = node.succ?

    case succ
    when .puncts?, .ude1?
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
