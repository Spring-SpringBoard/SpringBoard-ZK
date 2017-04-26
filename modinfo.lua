return {
  name = 'SpringBoard ZK',
  shortName = 'SB_ZK',
  gameName = 'SpringBoard ZK',
  shortGame = 'SB_ZK',
  description = 'SpringBoard for Zero-K',
  version = '$VERSION',
  mutator = 'Official',
  modtype = 1,
  depend = {
      'rapid://sbc:test',
      --'SpringBoard Core $VERSION',
      'rapid://zk:stable',
      --'Zero-K $VERSION',
  },
}
