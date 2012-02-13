namespace :seed do
  desc "Seed the database with SoC information"
  task :soc => :environment do
    print "Seeding SoC..."
    if ENV['semester'].nil?
      Seeder.seed_soc(nil)
    else
      Seeder.seed_soc(Semester.where("name " + Rails.application.config.like_operator + " ?", "%#{ENV['semester']}%").first)
    end
    puts "done!"
  end
  
  desc "Seed the database with semester information"
  task :semesters => :environment do
    print "Seeding semesters..."
    Seeder.seed_semesters
    puts "done!"
  end
  
  desc "Seed the database with SoC, department, and semester information"
  task :all => [:semesters, :soc]
end