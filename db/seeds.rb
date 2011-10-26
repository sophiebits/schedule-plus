print "SEEDING SEMESTERS..."
Seeder.seed_semesters
puts "done!"

print "SEEDING DEPARTMENTS..."
Seeder.seed_departments
puts "done!"

print "SEEDING SOC..."
Seeder.seed_soc(nil)
puts "done!"