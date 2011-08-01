if Spree::Config.instance
  Spree::Config.set(:products_per_page => 24)
  Spree::Config.set(:admin_products_per_page => 24)
  Spree::Config.set(:site_name => "Asapana Store")
  Spree::Config.set(:site_url => "store.asapana.com")
end
