<script context="module">
  export async function load({ fetch, page: { query } }) {
    const res = await fetch(`/api/crits?${query.toString()}&take=10`)
    return { props: { ...(await res.json()) } }
  }

  const sorts = {
    mtime: 'Gần nhất',
    stars: 'Cho điểm',
    likes: 'Ưa thích',
  }

  const _navi = { replace: true, scrollto: '#sorts' }
</script>

<script>
  import { page } from '$app/stores'
  import SIcon from '$atoms/SIcon.svelte'
  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import Header from '$sects/Header.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.path, $page.query, { sort: 'mtime', page: 1 })
  $: _sort = $page.query.get('sort') || 'mtime'
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<Header>
  <svelte:fragment slot="left">
    <a href="/crits" class="header-item _active">
      <SIcon name="messages" />
      <span class="header-text">Đánh giá</span>
    </a>
  </svelte:fragment>
</Header>

<Vessel>
  <section class="main">
    <div class="sorts" id="sorts">
      <span class="h3 -label">Đánh giá</span>
      {#each Object.entries(sorts) as [sort, name]}
        <a
          href={pager.url({ sort, page: 1 })}
          class="-sort"
          use:navigate={_navi}
          class:_active={sort == _sort}>{name}</a>
      {/each}
    </div>

    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} view_all={crit.vhtml.length < 640}>
          {@html crit.vhtml}
        </Yscrit>
      {/each}

      <footer class="pagi">
        <Mpager {pager} {pgidx} {pgmax} {_navi} />
      </footer>
    </div>
  </section>
</Vessel>

<style lang="scss">
  .main {
    border-radius: 0.5rem;
    @include bgcolor(tert);

    margin-top: 1rem;
    @include bps(margin-left, calc(var(--gutter) * -1), 0);
    @include bps(margin-right, calc(var(--gutter) * -1), 0);
    padding: var(--gutter) calc(var(--gutter) * 2);
  }

  .sorts {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);

    .-label {
      flex: 1;
      // font-weight: 500;
      // @include ftsize(xl);
    }

    .-sort {
      @include fgcolor(tert);
      padding: 0 0.125rem;
      height: 2rem;

      &._active {
        border-bottom: 2px solid color(primary, 5);
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
