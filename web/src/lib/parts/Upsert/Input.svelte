<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let ztext = ''
  export let lower = 0
  export let upper = 1

  export let pinyin = ''
  export let output = ''

  $: output = ztext.substring(lower, upper)
  $: prefix = Array.from(ztext.substring(lower - 5, lower))
  $: suffix = Array.from(ztext.substring(upper, upper + 5))

  function move_lower_left() {
    lower -= 1
  }

  function move_lower_right() {
    lower += 1
    if (upper <= lower) upper += 1
  }

  function move_upper_left() {
    upper -= 1
    if (lower >= upper) lower -= 1
  }

  function move_upper_right() {
    upper += 1
  }
</script>

<div class="ztext">
  <button
    class="_left"
    data-kbd="h"
    disabled={lower >= ztext.length - 1}
    on:click={move_lower_right}>
    <SIcon name="chevron-right" />
  </button>

  <button
    class="_left"
    data-kbd="j"
    disabled={lower == 0}
    on:click={move_lower_left}>
    <SIcon name="chevron-left" />
  </button>

  <div class="key">
    <div class="key-txt">
      <div class="key-pre">
        {#each prefix as chr, idx}
          <span class="key-btn" on:click={() => (lower -= prefix.length - idx)}
            >{chr}</span>
        {/each}
      </div>

      <div class="key-out">
        {#each output as chr, idx}
          <span
            class="key-btn"
            on:click={() => ((lower += idx), (upper = lower + 1))}>{chr}</span>
        {/each}
      </div>

      <div class="key-suf">
        {#each suffix as chr, idx}
          <span class="key-btn" on:click={() => (upper += idx + 1)}>{chr}</span>
        {/each}
      </div>
    </div>
  </div>

  <button
    class="_right"
    data-kbd="k"
    disabled={upper == ztext.length}
    on:click={move_upper_right}>
    <SIcon name="chevron-right" />
  </button>

  <button
    class="_right"
    data-kbd="l"
    disabled={upper == 1}
    on:click={move_upper_left}>
    <SIcon name="chevron-left" />
  </button>

  <div class="pinyin">
    <span class="pinyin-txt">{pinyin}</span>
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .ztext {
    display: flex;
    width: calc(100% - 4.5rem);
    height: $height;
    position: relative;
    background-color: inherit;
  }

  .key {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    font-size: rem(19px);
    @include border(--bd-soft, $loc: left-right);
  }

  .key-txt {
    font-weight: 500;
    position: relative;
    max-width: 100%;
    line-height: $height;
    > * {
      display: inline;
    }
  }

  .key-out {
    @include clamp($width: 20vw);
    @include fgcolor(main);
  }

  .key-pre,
  .key-suf {
    display: block;
    position: absolute;
    top: 0;
    font-weight: 400;
    height: 100%;
    white-space: nowrap;
    @include fgcolor(mute);
  }

  .key-pre {
    right: 100%;
  }

  .key-suf {
    left: 100%;
  }

  .key-btn {
    cursor: pointer;
    @include hover {
      @include fgcolor(tert);
    }
  }

  .pinyin {
    display: flex;
    justify-content: center;

    position: absolute;
    left: 4.25rem;
    right: 4.25rem;
    bottom: -0.45rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(10px);
  }

  .pinyin-txt {
    padding: 0 0.25rem;
    display: inline-block;
    @include clamp($width: null);
    @include fgcolor(tert);
    @include bgcolor(tert);
  }

  button {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    max-width: 65vw;

    @include ftsize(lg);
    @include fgcolor(secd);

    &._left {
      @include border(--bd-soft, $loc: left);
    }

    &._right {
      @include border(--bd-soft, $loc: right);
    }

    &:hover {
      // @include bgcolor(tert);
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }
  }
</style>
