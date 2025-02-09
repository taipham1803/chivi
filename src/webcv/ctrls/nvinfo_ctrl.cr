require "./base_ctrl"

class CV::NvinfoCtrl < CV::BaseCtrl
  private def extract_params
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 25)
    {page, take, (page - 1) * take}
  end

  def index
    pgidx, limit, offset = extract_params

    query =
      Cvbook.query
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_zseed(params["sname"]?)
        .filter_genre(params["genre"]?)

    if uname = params["uname"]?.try(&.downcase)
      cvuser = Cvuser.load!(uname)
      status = Ubmemo.status(params.fetch_str("bmark", "reading"))

      query = query.where("id IN (SELECT cvbook_id from ubmemos where cvuser_id=#{cvuser.id} and status=#{status})")
    end

    total = query.dup.limit(offset + limit * 3).offset(0).count

    query.sort_by(params.fetch_str("order", "bumped"))
    response.headers.add("Cache-Control", "public, min-fresh=180")

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "books" {
          jb.array {
            query.limit(limit).offset(offset).with_author.each do |book|
              CvbookView.render(jb, book, full: false)
            end
          }
        }
      }
    end
  rescue err
    puts err.inspect_with_backtrace
    halt! 500, err.message
  end

  LOOKUP = TsvStore.new("priv/lookup.tsv")

  def find
    bname = params["bname"]
    response.headers.add("Cache-Control", "public, min-fresh=60")
    response.content_type = "text/plain; charset=utf-8"
    context.content = LOOKUP.fval(bname) || bname
  end

  def show : Nil
    unless cvbook = Cvbook.find({bslug: params["bslug"]})
      return halt!(404, "Quyển sách không tồn tại!")
    end

    cvbook.bump! if u_privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, cvbook.id)

    if ubmemo.lr_chidx == 0
      ubmemo.lr_zseed = cvbook.zhseed_ids.find(0, &.> 0)
      zhbook = Zhbook.load!(cvbook.id, ubmemo.lr_zseed)

      if chinfo = zhbook.chinfo(0)
        ubmemo.lr_chidx = -1
        ubmemo.lc_title = chinfo.title
        ubmemo.lc_uslug = chinfo.uslug
      end
    end

    response.headers.add("Cache-Control", "min-fresh=30")

    json_view do |jb|
      jb.object {
        jb.field "cvbook" { CvbookView.render(jb, cvbook, full: true) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }
      }
    end
  end
end
