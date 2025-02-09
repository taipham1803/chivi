module CV::TlRule
  def scan_noun!(head : MtNode, mode = 0)
    case head
    when .nphrase? then head
    when .nouns?
      head = fold_noun!(head, mode: 1) # fold noun but do not consume penum
      head = scan_noun!(head) if head.verb?
      head
    when .numeric?
      head = fold_numbers!(head)
      return head if head.noun?

      return head unless (succ = head.succ?) && !succ.ends?
      succ = scan_noun!(succ)
      return head unless succ.noun?
      fold_nquant_noun!(node, succ)
    when .adverbs?
      head = fold_adverbs!(head)
      return head unless (succ = head.succ?) && succ.ude1?
      fold_left_ude1_noun!(left, succ.succ?)
    when .verbs?
      head = fold_verbs!(head)
      return head unless (succ = head.succ?) && succ.ude1?
      fold_left_ude1_noun!(left, succ.succ?)
    when .adjts?
      head = fold_adjts!(head)
      return head unless (succ = head.succ?) && succ.ude1?
      fold_left_ude1_noun!(left, succ.succ?)
    when .modifier?, .modiform?
      return head unless succ = head.succ?
      fold_swap!(head, scan_noun!(succ), PosTag::Nphrase, dic: 4)
    else
      head
    end
  end

  def fold_head_ude1_noun!(head : MtNode, tail : MtNode?)
    return head unless tail
    fold_swap!(head, scan_noun!(tail), PosTag::Nphrase, dic: 4)
  end
end
