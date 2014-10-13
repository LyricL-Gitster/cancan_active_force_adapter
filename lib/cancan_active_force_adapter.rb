if defined? ActiveForce && defined? CanCan
  if  Gem::Version.new(ActiveForce::VERSION) >= Gem::Version.new('0.7.0')
    require 'cancan_active_force_adapter/active_force_adapter'
    require 'cancan_active_force_adapter/version'
  end
end