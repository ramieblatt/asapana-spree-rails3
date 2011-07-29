namespace :db do
  namespace :seed do
    
    def regular_tables
      [
        "addresses",
        "adjustments",
        "assets",
        "checkouts",
        "coupons",
        "line_items",
        "option_types",
        "option_values",
        "orders",
        "payment_methods",
        "preferences",
        "product_groups",
        "product_scopes",
        "products",
        "properties",
        "prototypes",
        "shipments",
        "shipping_categories",
        "shipping_methods",
        "tax_categories",
        "taxonomies",
        "taxons",
        "users",
        "variants"      ]
    end
    
    def join_tables
      [
        "product_option_types",
        "product_properties",
      ]
    end
    
    def all_tables
      regular_tables.concat(join_tables)
    end
  
    desc "Export given interesting_tables into YAML files."
    task :export, :table, :needs => :environment do |t, args|  
      specific_table = args[:table] 
      target_tables = []
      unless specific_table.blank? 
        target_tables << specific_table
      else
        target_tables = all_tables
      end
      dir = Rails.root.to_s + '/db/seed'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
      
      target_tables.each do |tbl|
        puts "Writing #{tbl}..."
        if join_tables.include?(tbl)
          File.open("#{tbl}.yml", 'w+') { |f| YAML.dump ActiveRecord::Base.connection.select_all("SELECT * FROM #{tbl}"), f }
        else
          File.open("#{tbl}.yml", 'w+') { |f| YAML.dump ActiveRecord::Base.connection.select_all("SELECT * FROM #{tbl} ORDER BY id"), f }      
        end
      end
    
    end
  
    desc "Import given interesting_tables into current db overwiting anything present"
    task :import, :table, :needs => :environment do |t, args| 
      specific_table = args[:table] 
      target_tables = []
      unless specific_table.blank? 
        target_tables << specific_table
      else
        target_tables = all_tables
      end
      dir = Rails.root.to_s + '/db/seed'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
    
      target_tables.each do |tbl|

        ActiveRecord::Base.connection.execute "DELETE FROM #{tbl}"
        ActiveRecord::Base.transaction do 
          puts "Loading #{tbl}..."
          YAML.load_file("#{tbl}.yml").each do |fixture|
            ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{fixture.keys.join(",")}) VALUES (#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
          end
          ActiveRecord::Base.connection.execute "SELECT SETVAL('#{tbl}_id_seq', max(id)) from #{tbl}" unless join_tables.include?(tbl)
        end
      end
    
    end
  
  end
end
