<script>
  export let books = []
  export let nvtab = 'index'

  import Nvinfo from '$molds/Nvinfo.svelte'
</script>

<div class="list">
  {#each books as nvinfo (nvinfo)}
    <Nvinfo {nvinfo} {nvtab} />
  {/each}
</div>

<style lang="scss">
  .list {
    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(3, 1fr);

    @include bp-min(pl) {
      grid-template-columns: repeat(4, 1fr);
    }

    @include bp-min(tm) {
      grid-template-columns: repeat(5, 1fr);
    }

    @include bp-min(ls) {
      grid-template-columns: repeat(6, 1fr);
    }
  }
</style>
