define [
  'i18n!dashboard'
  'compiled/views/Dashboard/SideBarSectionView'
  'compiled/collections/ComingUpCollection'
  'compiled/views/Dashboard/ComingUpItemView'
], (I18n, SideBarSectionView, ComingUpCollection, ComingUpItemView) ->

  class ComingUpView extends SideBarSectionView
    collectionClass: ComingUpCollection
    itemView:        ComingUpItemView
    #title:           I18n.t 'coming_up', 'Coming Up'
    title:           '即将到来'
    listClassName:   'coming-up-list'

