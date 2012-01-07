namespace :import do
  desc "Import data from version 1 schema"
  task :all => :environment do
    Importer.import_all
  end
end
