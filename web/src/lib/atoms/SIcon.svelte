<script>
  export let name = 'x'
  export let spin = false
</script>

<svg class="m-icon" class:a-spin={spin}>
  <use xlink:href="/icons/tabler.svg#{name}" />
</svg>
