<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ fetch, stuff }) {
    const { cvbook, ubmemo } = stuff

    const sname = ubmemo.sname || 'chivi'

    const page = chidx_to_page(+ubmemo.chidx)

    const url = `chaps/${cvbook.id}/${sname}?page=${page}`

    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > cvbook.mftime) cvbook.mftime = chinfo.utime
    return { props: { cvbook, ubmemo, chinfo } }
  }

  function chidx_to_page(chidx, psize = 32) {
    if (chidx < 1) return 1
    return Math.floor((chidx - 1) / psize) + 1
  }
</script>

<script>
  import ChapPage from './_layout/ChapPage.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo
</script>

<ChapPage {cvbook} {ubmemo} {chinfo} />
