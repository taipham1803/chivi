export const labels = {
  _: 'Không rõ',
  ns: 'Địa danh',
  nt: 'Tổ chức',
  nz: 'Tên riêng khác',
  nr: 'Tên người',
  nf: 'Dòng họ',
  nw: 'Danh xưng',

  n: 'Danh từ',
  nc: 'Danh từ trừu tượng',
  s: 'Nơi chốn',
  f: 'Phương vị',
  t: 'Thời gian',
  ng: 'Ngữ tố danh từ',
  tg: 'Ngữ tố thời gian',

  a: 'Hình dung từ',
  b: 'Khu biệt từ',
  az: 'Trạng thái từ',
  an: 'Danh hình từ',
  ad: 'Phó hình từ',
  ag: 'Ngữ tố tính từ',

  v: 'Động từ',
  vd: 'Phó động từ',
  vn: 'Danh động từ',
  vi: 'Nội động từ',
  vf: 'Động từ xu hướng',
  vx: 'Động từ hình thức',
  vm: 'Động từ năng nguyện',
  vg: 'Ngữ tố động từ',

  rr: 'Đại từ nhân xưng',
  rz: 'Đại từ chỉ thị',
  ry: 'Đại từ nghi vấn',
  rzhe: 'Đại từ chỉ thị 这',
  rna1: 'Đại từ chỉ thị 那',
  rna2: 'Đại từ nghi vấn 哪',
  rji: 'Đại từ nghi vấn 几',
  r: 'Đại từ chưa phân loại',

  i: 'Thành/quán ngữ',
  nl: 'Danh quán ngữ',
  vl: 'Động quán ngữ',
  al: 'Hình quán ngữ',
  bl: 'Khu biệt quán ngữ',

  m: 'Số từ',
  mx: 'Chữ ả rập',
  mz: 'Chữ số hán',
  q: 'Lượng từ',
  qt: 'Lượng từ thời gian',
  mq: 'Số lượng từ',

  d: 'Phó từ',
  dbu: 'Phó từ 不',
  dmei: 'Phó từ 没',
  dfei: 'Phó từ 非',

  c: 'Liên từ',
  cc: 'Liên từ liệt kê',
  p: 'Giới từ',
  u: 'Trợ từ',
  e: 'Thán từ',
  y: 'Ngữ khí',
  o: 'Tượng thanh',

  // affixes
  kn: 'Hậu tố danh từ',
  ka: 'Hậu tố tính từ',
  kv: 'Hậu tố động từ',

  kmen: 'Hậu tố 们',
  kshi: 'Hậu tố 时',
  k: 'Hậu tố chưa phân loại',

  // specials
  ahao: 'Tính từ 好',
  vshi: 'Động từ 是',
  vyou: 'Động từ 有',
  vneng: 'Động từ 能',
  vhui: 'Động từ 会',
  vxiang: 'Động từ 想',

  pba: 'Giới từ 把',
  pbei: 'Giới từ 被',
  pdui: 'Giới từ 对',

  uzhe: 'Trợ từ 着',
  ule: 'Trợ từ 了',
  uguo: 'Trợ từ 过',
  ude1: 'Trợ từ 的',
  ude2: 'Trợ từ 地',
  ude3: 'Trợ từ 得',
  usuo: 'Trợ từ 所',
  uzhi: 'Trợ từ 之',
  ulian: 'Trợ từ 连',
  udh: 'Trợ từ 的话',
  udeng: '等/等等/云云',
  uyy: '一样/一般/...',
  uls: '来讲/而言/...',

  x: 'Chữ latin',
  xx: 'Kaomoji',
  xu: 'Đường link',

  w: 'Dấu câu',

  sp: 'Từ đặc biệt',
  vp: 'Cụm động từ',
  np: 'Cụm danh từ',
  ap: 'Cụm tính từ',
  sv: 'Cụm chủ + vị (động)',
  sa: 'Cụm chủ + vị (tính)',
}

export const gnames = ['Cơ bản', 'Hiếm gặp', 'Đặc biệt']
export const groups = [
  // prettier-ignore
  [
    'ns','nt', 'nz',
    'nr', 'nf',
    '-',
    'n', 'nw', // 'nc',
    't', 's', 'f',
    '-',
    'a', 'an', 'ad',
    'b', 'az',
    '-',
    'v', 'vn', 'vd',
    'vi', 'vf', 'vx',
    'vm',
    '-',
    'i', 'nl', 'vl',
    'al', 'bl',
    '-',
    'rr', 'rz', 'ry',
    'rzhe', 'rna1', 'rna2',
    'rji', 'r',
  ],
  // prettier-ignore
  [
    'm', 'mx', 'mz',
    'q', 'qt', 'mq',
    '-',
    'd', 'p', 'u',
    'c', 'cc', 'e',
    'y', 'o', 'sp',
    '-',
    'kn', 'ka', 'kv',
    'kmen', 'kshi', 'k',
    'ng', 'ag', 'vg', 'tg',
    '-',
  ],
  // prettier-ignore
  [
    'dbu' ,'dmei', 'dfei',
    'ahao', 'vshi', 'vyou',
    'vneng','vhui', 'vxiang',
    'pba', 'pbei', 'pdui',
    '-',
    'uzhe', 'ule', 'uguo',
    'ude1', 'ude2', 'ude3',
    'uzhi', 'ulian', 'udh',
    'udeng', 'uyy', 'uls',
    '-',
    'x', 'xx', 'xu',
    'w'
  ],
]

export function tag_label(tag) {
  return labels[tag] || tag
}

export function find_group(tag) {
  for (const [idx, group] of groups.entries()) {
    if (group.includes(tag)) return idx
  }

  return -1
}
