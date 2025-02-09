require "./base_ctrl"

class CV::DboardCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dboard.query.order_by(_sort: :desc)
    total = query.dup.limit(limit * 3 + skips).offset(0).count

    cache_rule :public, 30, 120

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "items" {
          jb.array {
            query.limit(limit).offset(skips).each(&.to_json(jb))
          }
        }
      }
    end
  end

  def show
    dboard = Dboard.load!(params["dboard"].to_i64)
    dboard.update({views: dboard.views + 1})
    
    cache_rule :public, 120, 300, dboard.updated_at.to_s

    # TODO: load user trace
    json_view do |jb|
      jb.object {
        jb.field "bname", dboard.bname
        jb.field "bslug", dboard.bslug
        jb.field "posts", dboard.posts
      }
    end
  rescue err
    halt!(404, "Diễn đàn không tồn tại!")
  end
end
