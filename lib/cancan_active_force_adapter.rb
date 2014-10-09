if defined? ActiveForce && defined? CanCan
  # TODO: Update with next version of ActiveForce which includes 'where' patch
  if  Gem::Version.new(ActiveForce::VERSION) >= Gem::Version.new('0.6.1')
    require 'cancan_active_force_adapter/active_force_adapter'
    require 'cancan_active_force_adapter/version'
  end
end