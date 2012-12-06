desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
    puts "Updating data from Amazon..."
    Camera.get_cameras_from_amazon
    puts "done."
end